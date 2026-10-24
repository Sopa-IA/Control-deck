"""Hub WebSocket de orbitd: autenticación, latido, lista blanca, confirmaciones y reenvío al HP."""
from __future__ import annotations

import asyncio
import json
import logging
import time
import uuid
from dataclasses import dataclass, field
from pathlib import Path
from typing import Callable, Optional

from aiohttp import WSMsgType, web

import orbit_protocol as P

from . import __version__
from .ardu_lab import FQBN_OLD, ArduLab
from .power import power_allowed, read_device_model, run_power
from .pots import PotGate, normalize_mapping
from .serial_events import NANO_RESET_WAIT_S, Hello, SerialReader, SimControls, parse_line
from .telemetry import local_telemetry, simulated_hp_telemetry
from .video import VideoConfig, VideoSwitcher

log = logging.getLogger("orbitd")


def is_loopback(host: str | None) -> bool:
    if not host:
        return False
    h = host.split("%", 1)[0]
    return h in {"127.0.0.1", "::1", "localhost"} or h.startswith("::ffff:127.")


@dataclass
class Config:
    host: str = "127.0.0.1"
    port: int = 8765
    static_dir: Optional[Path] = None
    state_dir: Path = field(default_factory=lambda: Path.home() / ".local" / "state" / "orbitd")
    hp_token: Optional[str] = None
    ui_token: Optional[str] = None
    sim_hp: bool = False
    sim_controls: bool = False
    sim_buttons: bool = False   # pulsaciones aleatorias de botones simulados (desactivado: abren diálogos)
    serial_port: Optional[str] = None
    serial_baud: int = 115200
    serial_reset_wait_s: float = NANO_RESET_WAIT_S
    heartbeat_s: float = P.HEARTBEAT_S
    heartbeat_timeout_s: float = P.HEARTBEAT_TIMEOUT_S
    telemetry_period_s: float = 2.0
    video: VideoConfig = field(default_factory=VideoConfig)
    ardu_ports_file: Optional[Path] = None
    ardu_sketch_dir: Optional[Path] = None
    ardu_cli: str = "arduino-cli"
    ardu_fqbn: str = FQBN_OLD
    ardu_by_path: Path = field(default_factory=lambda: Path("/dev/serial/by-path"))
    # ORBIT_POWER_LIVE=1 lo escribe el instalador solo en una Pi. None lee /proc.
    power_live: bool = False
    device_model: Optional[str] = None
    power_runner: Optional[Callable[[list[str]], int]] = None

    def check(self) -> None:
        if self.host not in ("127.0.0.1", "localhost", "::1") and not (self.hp_token and self.ui_token):
            raise SystemExit("orbitd: para escuchar fuera de localhost hay que definir ORBIT_HP_TOKEN y ORBIT_UI_TOKEN")


@dataclass
class Client:
    ws: web.WebSocketResponse
    role: str
    session: str
    last_rx: float
    seq: int = 0
    rate: list = field(default_factory=list)


class Hub:
    def __init__(self, cfg: Config):
        self.cfg = cfg
        self.clients: dict[int, Client] = {}
        self.hp: Optional[Client] = None
        self.hp_last_seen: Optional[int] = None
        self.last_telemetry: dict[str, dict] = {}
        self.last_controls: dict[str, dict] = {}
        self.arduino = {"connected": False, "simulated": cfg.sim_controls, "last_seen": None,
                        "detail": "simulado" if cfg.sim_controls else "sin puerto configurado"}
        self.pending_confirm: dict[str, dict] = {}
        self.pending_results: dict[str, Client] = {}
        self.mapping = self._load_mapping()
        self.video = VideoSwitcher(cfg.video)
        self.video.on_exit = self._video_exited
        self.ardu = ArduLab(
            ports_file=cfg.ardu_ports_file or (cfg.state_dir / "arduino-puertos.json"),
            sketch_dir=cfg.ardu_sketch_dir or (cfg.state_dir / "ardu-lab"),
            by_path=cfg.ardu_by_path, cli=cfg.ardu_cli, fqbn=cfg.ardu_fqbn, serial_fallback=cfg.serial_port or "")
        self._last_volume_sent = 0.0
        self._last_volume_level: Optional[int] = None
        self._volume_pending: Optional[int] = None
        self._pot_gate = PotGate()
        self._tasks: list[asyncio.Task] = []
        self._serial: Optional[SerialReader] = None
        self.sim_controls = (
            SimControls(pots=len(self.mapping["pots"]), buttons=len(self.mapping["buttons"]),
                        press_buttons=cfg.sim_buttons)
            if cfg.sim_controls else None)

    # ------------------------------------------------------------------ estado
    @property
    def mode(self) -> str:
        hp_sim = self.hp is None and self.cfg.sim_hp
        ctl_sim = self.cfg.sim_controls
        if hp_sim and ctl_sim:
            return "sim"
        if not hp_sim and not ctl_sim:
            return "real"
        return "mixto"

    def state_payload(self) -> dict:
        hp_conn = self.hp is not None
        return {
            "mode": self.mode,
            "hp": {"connected": hp_conn or self.cfg.sim_hp, "simulated": (not hp_conn) and self.cfg.sim_hp,
                   "last_seen": self.hp_last_seen,
                   "detail": "Conectado" if hp_conn else ("Simulado" if self.cfg.sim_hp else "No conectado")},
            "pi": {"connected": True, "simulated": False, "last_seen": P.now_ms(), "detail": "En este equipo"},
            "arduino": dict(self.arduino),
            "video_input": (self.video.visible if self.video.last_mode == "ddc" else "pi"),
            "visible": self.video.state(),
        }

    # --------------------------------------------------------------- mapeo
    def _mapping_path(self) -> Path:
        return self.cfg.state_dir / "controls.json"

    def _load_mapping(self) -> dict:
        path = self._mapping_path()
        if not path.is_file():
            return P.load_default_mapping()
        try:
            raw = json.loads(path.read_text(encoding="utf-8"))
            mapping, changed = normalize_mapping(raw)
            mapping = P.check_mapping(mapping)
        except (OSError, ValueError, KeyError, TypeError, P.ProtocolError):
            # Un archivo ilegible no se borra: se usa el de fábrica solo en memoria.
            return P.load_default_mapping()
        self.mapping = mapping
        if changed:
            self._save_mapping()
        return mapping

    def _save_mapping(self) -> None:
        try:
            self.cfg.state_dir.mkdir(parents=True, exist_ok=True)
            self._mapping_path().write_text(json.dumps(self.mapping, indent=2), encoding="utf-8")
        except OSError as exc:
            log.warning("no se pudo guardar el mapeo: %s", exc)

    # ------------------------------------------------------------- envíos
    async def send(self, c: Client, type_: str, payload: dict, reply_to: str | None = None) -> None:
        if c.ws.closed:
            return
        try:
            await c.ws.send_str(json.dumps(P.make(type_, "pi", payload, reply_to)))
        except (ConnectionError, RuntimeError) as exc:
            log.debug("envío fallido: %s", exc)

    async def broadcast_ui(self, type_: str, payload: dict) -> None:
        msg = json.dumps(P.make(type_, "pi", payload))
        for c in list(self.clients.values()):
            if c.role == "ui" and not c.ws.closed:
                try:
                    await c.ws.send_str(msg)
                except (ConnectionError, RuntimeError):
                    pass

    async def error(self, c: Client, code: str, message: str, reply_to: str | None = None) -> None:
        await self.send(c, "error", {"code": code, "message": message[:500]}, reply_to)

    # ----------------------------------------------------------- conexión
    async def ws_handler(self, request: web.Request) -> web.WebSocketResponse:
        ws = web.WebSocketResponse(max_msg_size=P.MAX_MESSAGE_BYTES, heartbeat=None)
        await ws.prepare(request)
        tmp = Client(ws, "?", "", time.monotonic())
        try:
            first = await ws.receive(timeout=5)
        except asyncio.TimeoutError:
            await self.error(tmp, "auth_failed", "se esperaba hello en 5 s")
            await ws.close()
            return ws
        if first.type != WSMsgType.TEXT:
            await ws.close()
            return ws
        try:
            hello = P.parse(first.data)
            if hello["type"] != "hello":
                raise P.ProtocolError("auth_failed", "el primer mensaje debe ser hello")
            role, token = hello["payload"]["role"], hello["payload"].get("token")
            if role == "hp-agent":
                if not self.cfg.hp_token:
                    raise P.ProtocolError("auth_failed", "orbitd sin ORBIT_HP_TOKEN configurado: no acepta hp-agent")
                if not P.tokens_equal(token, self.cfg.hp_token):
                    raise P.ProtocolError("auth_failed", "token incorrecto")
            elif (role == "ui" and self.cfg.ui_token and not is_loopback(request.remote)
                  and not P.tokens_equal(token, self.cfg.ui_token)):
                raise P.ProtocolError("auth_failed", "token de interfaz incorrecto")
        except P.ProtocolError as exc:
            log.warning("conexión rechazada: %s", exc.message)
            await self.error(tmp, exc.code if exc.code == "auth_failed" else "bad_message", exc.message)
            await ws.close()
            return ws

        c = Client(ws, "ui" if role == "ui" else "hp", uuid.uuid4().hex[:12], time.monotonic())
        self.clients[id(ws)] = c
        if c.role == "hp":
            if self.hp is not None:
                await self.hp.ws.close()
            self.hp = c
            self.hp_last_seen = P.now_ms()
            log.info("hp-agent conectado (%s)", hello["payload"]["client"])
        await self.send(c, "welcome", {"session": c.session, "server_time": P.now_ms(),
                                       "heartbeat_s": self.cfg.heartbeat_s, "mode": self.mode}, hello["id"])
        if c.role == "ui":
            await self.send(c, "state", self.state_payload())
            await self.send(c, "mapping", self.mapping)
            for t in self.last_telemetry.values():
                await self.send(c, "telemetry", t)
            for ev in self.last_controls.values():
                await self.send(c, "control_event", ev)
        else:
            await self.broadcast_ui("state", self.state_payload())

        try:
            async for raw in ws:
                if raw.type != WSMsgType.TEXT:
                    if raw.type == WSMsgType.ERROR:
                        break
                    continue
                c.last_rx = time.monotonic()
                try:
                    msg = P.parse(raw.data)
                    await self.dispatch(c, msg)
                except P.ProtocolError as exc:
                    await self.error(c, exc.code, exc.message)
        finally:
            self.clients.pop(id(ws), None)
            if self.hp is c:
                self.hp = None
                log.info("hp-agent desconectado")
                await self.broadcast_ui("state", self.state_payload())
        return ws

    # ----------------------------------------------------------- despacho
    def _rate_ok(self, c: Client, limit: int = 5) -> bool:
        now = time.monotonic()
        c.rate = [t for t in c.rate if now - t < 1.0]
        if len(c.rate) >= limit:
            return False
        c.rate.append(now)
        return True

    async def dispatch(self, c: Client, msg: dict) -> None:
        t, p = msg["type"], msg["payload"]
        if t == "pong":
            return
        if c.role == "hp":
            if t == "telemetry":
                p = dict(p, host="hp")
                self.hp_last_seen = P.now_ms()
                self.last_telemetry["hp"] = p
                await self.broadcast_ui("telemetry", p)
            elif t == "action_result":
                dest = self.pending_results.pop(msg.get("reply_to", ""), None)
                if dest:
                    await self.send(dest, "action_result", p)
                else:
                    await self.broadcast_ui("action_result", p)
            else:
                await self.error(c, "not_allowed", f"hp-agent no puede enviar {t}")
            return
        # --- interfaz
        if t == "action_request":
            limit = 10 if p["action"] in ("hp.volume_set", "pi.ardu_monitor") else 5
            if not self._rate_ok(c, limit):
                await self.error(c, "rate_limited", "demasiadas peticiones", msg["id"])
                return
            spec = P.check_action(p["action"], p.get("params"))
            if spec["confirm"]:
                rid, ch = uuid.uuid4().hex[:12], P.new_challenge()
                self.pending_confirm[rid] = {"action": p["action"], "params": p.get("params", {}), "challenge": ch,
                                             "expires": time.monotonic() + P.CONFIRM_TTL_S, "client": c}
                await self.send(c, "confirm_required", {"request_id": rid, "action": p["action"], "challenge": ch,
                                                        "expires_in_s": P.CONFIRM_TTL_S}, msg["id"])
                return
            await self.execute(p["action"], p.get("params", {}), c, msg["id"])
        elif t == "action_confirm":
            pend = self.pending_confirm.pop(p["request_id"], None)
            if (not pend or pend["client"] is not c or time.monotonic() > pend["expires"]
                    or not P.tokens_equal(p["challenge"], pend["challenge"])):
                await self.error(c, "confirm_expired", "confirmación caducada o incorrecta", msg["id"])
                return
            self.pending_confirm = {
                k: v for k, v in self.pending_confirm.items() if v["action"] != pend["action"]
            }
            await self.execute(pend["action"], pend["params"], c, msg["id"])
        elif t == "mapping_set":
            # version 2: los pots de fábrica ya pasaron a none. No volver a escribir 1,
            # o el siguiente arranque desharía lo que el usuario acaba de guardar.
            try:
                version = int(p.get("version") or 2)
            except (TypeError, ValueError):
                version = 2
            if version < 2:
                version = 2
            m = P.check_mapping({"version": version, "pots": p["pots"], "buttons": p["buttons"]})
            self.mapping = m
            self._save_mapping()
            await self.broadcast_ui("mapping", m)
        else:
            await self.error(c, "not_allowed", f"la interfaz no puede enviar {t}", msg["id"])

    async def execute(self, action: str, params: dict, c: Optional[Client], reply_to: Optional[str]) -> None:
        spec = P.check_action(action, params)
        if spec["target"] == "hp":
            if self.hp is not None:
                fwd = P.make("action", "pi", {"action": action, "params": params})
                if c is not None:
                    self.pending_results[fwd["id"]] = c
                await self.hp.ws.send_str(json.dumps(fwd))
                return
            if self.cfg.sim_hp:
                res = {"action": action, "ok": True, "dry_run": True, "simulated": True,
                       "message": f"SIMULADO: el HP no está conectado; no se ha ejecutado «{spec['label']}»."}
            else:
                if c is not None:
                    await self.error(c, "target_offline", "El HP no está conectado.", reply_to)
                return
        elif action == "pi.switch_visible":
            res = await self.video.switch()
            await self.broadcast_ui("state", self.state_payload())
        elif action == "pi.stream_layout":
            res = await self.video.set_layout(str(params.get("layout", "")))
            await self.broadcast_ui("state", self.state_payload())
        elif action == "pi.marco_sidebar":
            res = await self.video.set_sidebar(params.get("sidebar") == "abierto")
            await self.broadcast_ui("state", self.state_payload())
        elif action.startswith("pi.ardu_"):
            res = await self._ardu_action(action, params)
        else:
            res = self._pi_action(action, spec)
        if c is not None:
            await self.send(c, "action_result", res, reply_to)

    def _ardu_blocked(self) -> list[str]:
        extra = []
        if self.cfg.serial_port:
            extra.append(self.cfg.serial_port)
        if self._serial is not None:
            extra.append(self._serial.port)
        return extra

    async def _ardu_action(self, action: str, params: dict) -> dict:
        extra = self._ardu_blocked()
        if action == "pi.ardu_ports":
            return self.ardu.ports_result()
        if action == "pi.ardu_sketch":
            return self.ardu.sketch_result(str(params.get("op", "")), str(params.get("sketch", "")), str(params.get("source", "")))
        if action == "pi.ardu_monitor":
            return self.ardu.monitor_result(str(params.get("op", "")), int(params.get("baud", 0)), extra)
        if action == "pi.ardu_compile":
            return await asyncio.to_thread(self.ardu.compile_result, str(params.get("sketch", "")))
        if action == "pi.ardu_upload":
            return await asyncio.to_thread(self.ardu.upload_result, str(params.get("sketch", "")), extra)
        return {"action": action, "ok": False, "dry_run": True, "simulated": False, "message": "Acción de Ardu Lab desconocida."}

    def _pi_action(self, action: str, spec: dict) -> dict:
        if action == "pi.ping":
            return {"action": action, "ok": True, "dry_run": False, "simulated": False, "message": "La Raspberry Pi responde."}
        if action == "pi.led_mode":
            return {"action": action, "ok": False, "dry_run": False, "simulated": False,
                    "message": "La tira LED no está conectada. No se cambia nada."}
        if action == "pi.restart_ui":
            try:
                asyncio.get_running_loop().create_task(self.broadcast_ui("state", self.state_payload()))
            except RuntimeError:
                pass
            return {"action": action, "ok": True, "dry_run": False, "simulated": False, "message": "Recargando Orbit OS."}
        if action in ("pi.shutdown", "pi.restart"):
            return self._pi_power(action)
        return {"action": action, "ok": False, "dry_run": True, "simulated": False,
                "message": f"«{spec['label']}» no tiene ejecución en la Pi."}

    def _pi_power(self, action: str) -> dict:
        sim = bool(self.cfg.sim_hp or self.cfg.sim_controls)
        model = read_device_model() if self.cfg.device_model is None else self.cfg.device_model
        live = power_allowed(sim=sim, power_live=self.cfg.power_live, model=model)
        return run_power(action, live=live, sim=sim, runner=self.cfg.power_runner)

    async def _ask_confirm(self, action: str, params: dict) -> int:
        """Pide confirmación en cada interfaz conectada. Sin interfaz, no ejecuta."""
        uis = [c for c in self.clients.values() if c.role == "ui"]
        if not uis:
            log.warning("«%s» desde un botón y sin interfaz: no se ejecuta", action)
            return 0
        for c in uis:
            rid, ch = uuid.uuid4().hex[:12], P.new_challenge()
            self.pending_confirm[rid] = {"action": action, "params": params, "challenge": ch,
                                         "expires": time.monotonic() + P.CONFIRM_TTL_S, "client": c}
            await self.send(c, "confirm_required", {"request_id": rid, "action": action, "challenge": ch,
                                                    "expires_in_s": P.CONFIRM_TTL_S})
        return len(uis)

    # -------------------------------------------------------- controles
    async def on_serial_line(self, line: str, simulated: bool = False) -> None:
        ev = parse_line(line, simulated=simulated)
        if ev is None:
            if line.strip():
                log.debug("línea serie ignorada: %r", line)
            return
        self.arduino["last_seen"] = P.now_ms()
        if isinstance(ev, Hello):
            self.arduino["detail"] = f"{ev.firmware} v{ev.version}: {ev.pots} pots, {ev.buttons} botones"
            await self.broadcast_ui("state", self.state_payload())
            return
        if ev["kind"] == "pot" and not simulated:
            decision = self._pot_gate.feed(ev["control"], int(ev.get("value") or 0))
            if decision.show is None:
                return
            ev = dict(ev, value=decision.show)
            self.last_controls[ev["control"]] = ev
            await self.broadcast_ui("control_event", ev)
            fn = self.mapping["pots"].get(ev["control"], "none")
            if fn == "hp.volume_set" and decision.act and decision.level is not None:
                if decision.level != self._last_volume_level:
                    self._last_volume_level = decision.level
                    self._volume_pending = decision.level
            return
        if ev["kind"] == "pot":
            self.last_controls[ev["control"]] = ev
        await self.broadcast_ui("control_event", ev)
        fn = (self.mapping["pots"] if ev["kind"] == "pot" else self.mapping["buttons"]).get(ev["control"], "none")
        if fn == "hp.volume_set" and ev["kind"] == "pot":
            lvl = round(ev["value"] * 100 / 1023)
            if lvl != self._last_volume_level:
                self._last_volume_level = lvl
                self._volume_pending = lvl
        elif ev["kind"] == "button" and fn in P.ACTIONS:
            if P.ACTIONS[fn]["confirm"]:
                # Un toque corto no apaga. Mantener pulsado pide la confirmación en pantalla.
                if ev.get("event") == "long":
                    await self._ask_confirm(fn, {})
            elif ev.get("event") == "press":
                await self.execute(fn, {}, None, None)

    async def _volume_loop(self) -> None:
        while True:
            await asyncio.sleep(0.1)  # agrupa a ≤ 10/s
            if self._volume_pending is not None:
                lvl, self._volume_pending = self._volume_pending, None
                await self.execute("hp.volume_set", {"level": lvl}, None, None)

    def _serial_status(self, ok: bool, detail: str) -> None:
        self.arduino.update(connected=ok, detail=detail, simulated=False)
        asyncio.get_event_loop().create_task(self.broadcast_ui("state", self.state_payload()))

    # ---------------------------------------------------------- bucles
    async def _heartbeat_loop(self) -> None:
        while True:
            await asyncio.sleep(self.cfg.heartbeat_s)
            now = time.monotonic()
            for c in list(self.clients.values()):
                if now - c.last_rx > self.cfg.heartbeat_timeout_s:
                    log.info("cliente %s sin latido: se cierra", c.role)
                    await c.ws.close()
                    continue
                c.seq += 1
                await self.send(c, "ping", {"seq": c.seq})

    async def _telemetry_loop(self) -> None:
        while True:
            pi = local_telemetry("pi")
            self.last_telemetry["pi"] = pi
            await self.broadcast_ui("telemetry", pi)
            if self.hp is None and self.cfg.sim_hp:
                hp = simulated_hp_telemetry()
                self.last_telemetry["hp"] = hp
                await self.broadcast_ui("telemetry", hp)
            await self.broadcast_ui("state", self.state_payload())
            await asyncio.sleep(self.cfg.telemetry_period_s)

    async def _sim_controls_loop(self) -> None:
        assert self.sim_controls is not None
        self.arduino.update(connected=True, simulated=True)
        await self.on_serial_line(self.sim_controls.hello(), simulated=True)
        while True:
            await asyncio.sleep(0.4)
            for line in self.sim_controls.step():
                await self.on_serial_line(line, simulated=True)

    async def _video_exited(self) -> None:
        await self.broadcast_ui("state", self.state_payload())

    async def start(self, app: web.Application) -> None:
        loop = asyncio.get_event_loop()
        self._tasks = [loop.create_task(self._heartbeat_loop()), loop.create_task(self._telemetry_loop()),
                       loop.create_task(self._volume_loop())]
        if self.sim_controls:
            self._tasks.append(loop.create_task(self._sim_controls_loop()))
        else:
            port = self.ardu.mandos_link() or self.cfg.serial_port
            if port:
                def on_line(line: str) -> None:
                    loop.create_task(self.on_serial_line(line))
                self._serial = SerialReader(port, self.cfg.serial_baud, loop, on_line, self._serial_status,
                                             reset_wait_s=self.cfg.serial_reset_wait_s)
                self._serial.start()

    async def stop(self, app: web.Application) -> None:
        for t in self._tasks:
            t.cancel()
        if self._serial:
            self._serial.stop()
        self.ardu.monitor.close()
        await self.video.close()
        for c in list(self.clients.values()):
            await c.ws.close()


HUB_KEY = web.AppKey("hub", Hub)


def build_app(cfg: Config) -> web.Application:
    hub = Hub(cfg)
    app = web.Application()
    app[HUB_KEY] = hub
    app.router.add_get("/ws", hub.ws_handler)

    async def health(_: web.Request) -> web.Response:
        return web.json_response({"ok": True, "version": __version__, "mode": hub.mode})

    app.router.add_get("/api/health", health)

    def _local(request: web.Request) -> bool:
        return is_loopback(request.remote)

    async def local_layout(request: web.Request) -> web.Response:
        if not _local(request):
            return web.json_response({"ok": False, "message": "solo localhost"}, status=403)
        res = await hub.video.toggle_layout()
        await hub.broadcast_ui("state", hub.state_payload())
        return web.json_response(res)

    async def local_sidebar(request: web.Request) -> web.Response:
        if not _local(request):
            return web.json_response({"ok": False, "message": "solo localhost"}, status=403)
        try:
            body = await request.json()
        except json.JSONDecodeError:
            body = {}
        res = await hub.video.set_sidebar(body.get("sidebar") == "abierto")
        await hub.broadcast_ui("state", hub.state_payload())
        return web.json_response(res)

    async def local_switch(request: web.Request) -> web.Response:
        if not _local(request):
            return web.json_response({"ok": False, "message": "solo localhost"}, status=403)
        res = await hub.video.switch()
        await hub.broadcast_ui("state", hub.state_payload())
        return web.json_response(res)

    app.router.add_post("/api/local/layout", local_layout)
    app.router.add_post("/api/local/sidebar", local_sidebar)
    app.router.add_post("/api/local/switch", local_switch)
    if cfg.static_dir and (cfg.static_dir / "index.html").exists():
        index = cfg.static_dir / "index.html"

        async def root(_: web.Request) -> web.FileResponse:
            return web.FileResponse(index)

        app.router.add_get("/", root)
        app.router.add_static("/", cfg.static_dir, show_index=False)
    app.on_startup.append(hub.start)
    app.on_cleanup.append(hub.stop)
    return app
