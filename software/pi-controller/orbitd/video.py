"""Cambio del sistema visible (HP / Pi).

La MSI va solo a la Pi (micro-HDMI a mini-HDMI). El HP se ve con Moonlight contra
Sunshine: el HP en 10.0.0.1 y la Pi en 10.0.0.2, por el cable de red directo.
El teclado y el ratón son Bluetooth, emparejados con la Pi. Vista por defecto: **integrada**.
Chromium sigue a pantalla completa con el marco de Orbit OS y labwc coloca
Moonlight, sin bordes ni título, en el hueco que deja la barra (1920×1040 si la
barra mide 40 px y la barra lateral está cerrada). La alternativa es Moonlight
a pantalla completa 1920×1080 y 60 fps.

El botón físico (``pi.switch_visible``) abre Moonlight y, si ya está abierto,
lo cierra y devuelve Orbit OS al frente. ``pi.stream_layout`` y el atajo
Ctrl+Alt+Mayús+X cambian de vista. Ctrl+Alt+Mayús+Q lo cierra el propio Moonlight.

El cambio de entrada de la MSI sigue en el código si se configura. Este montaje no
lo usa: el instalador no define esas variables.

Moonlight es una aplicación nativa: no se puede incrustar en la página. La
integración es colocar la ventana.
"""
from __future__ import annotations

import asyncio
import json
import logging
import os
import re
import shlex
import shutil
from dataclasses import dataclass, field
from pathlib import Path
from typing import Callable, Optional

log = logging.getLogger("orbitd.video")

_VCP_RE = re.compile(r"^(0x)?[0-9a-fA-F]{1,2}$")
_DEV_RE = re.compile(r"^/dev/(video[0-9]{1,3}|v4l/by-(id|path)/[A-Za-z0-9._:+-]{1,200})$")
_ADDR_RE = re.compile(r"(\d+)\\(?:manualAddress|localAddress|remoteAddress|address)=(.*)$")
_PAIR_RE = re.compile(r"(\d+)\\pairState=(\d+)$")

_MARCO_PATH = Path(__file__).resolve().parents[2] / "shared" / "marco.json"


def marco_spec() -> dict:
    return json.loads(_MARCO_PATH.read_text(encoding="utf-8"))


def marco_hole(sidebar: bool, spec: Optional[dict] = None) -> tuple[int, int, int, int]:
    """x, y, ancho, alto del hueco. Sin barra lateral: 0,40,1920,1040."""
    s = spec or marco_spec()
    side = int(s["sidebar_px"]) if sidebar else 0
    return side, int(s["bar_px"]), int(s["screen_w"]) - side, int(s["screen_h"]) - int(s["bar_px"])


def pairing_message(host: str) -> str:
    return (f"Moonlight no está emparejado con Sunshine en el HP ({host}). "
            "Hasta emparejarlo no se abre el escritorio.")


def conf_paired_with(text: str, host: str) -> bool:
    """QSettings de Moonlight Qt: ``N\\manualAddress`` y ``N\\pairState`` (1 = emparejado)."""
    addrs: dict[str, set[str]] = {}
    states: dict[str, int] = {}
    for raw in text.splitlines():
        line = raw.strip()
        m = _ADDR_RE.match(line)
        if m:
            addrs.setdefault(m.group(1), set()).add(m.group(2).strip())
            continue
        m = _PAIR_RE.match(line)
        if m:
            states[m.group(1)] = int(m.group(2))
    return any(host in values and states.get(idx, 0) >= 1 for idx, values in addrs.items())


def moonlight_config_paths(home: Path) -> list[Path]:
    return [
        home / ".config" / "Moonlight Game Streaming Project" / "Moonlight.conf",
        home / ".config" / "Moonlight Game Streaming Project.conf",
    ]


def moonlight_paired(host: str, home: Optional[Path] = None, extra: Optional[str] = None) -> bool:
    home = home or Path.home()
    paths: list[Path] = []
    if extra:
        paths.append(Path(extra))
    paths.extend(moonlight_config_paths(home))
    for p in paths:
        try:
            text = p.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        if conf_paired_with(text, host):
            return True
    return False


def labwc_rc_text(layout: str, sidebar: bool) -> str:
    """rc.xml de labwc: atajos y, en vista integrada, la ventana de Moonlight en el hueco."""
    x, y, w, h = marco_hole(sidebar)
    if layout == "integrada" or layout == "integrado":
        rule = f"""    <windowRule identifier="*moonlight*">
      <serverDecoration>no</serverDecoration>
      <skipTaskbar>yes</skipTaskbar>
      <fixedPosition>yes</fixedPosition>
      <ignoreConfigureRequest>yes</ignoreConfigureRequest>
      <action name="SetDecorations" decorations="none" forceSSD="yes" />
      <action name="MoveTo" x="{x}" y="{y}" />
      <action name="ResizeTo" width="{w}" height="{h}" />
      <action name="ToggleAlwaysOnTop" />
      <action name="Raise" />
    </windowRule>"""
    else:
        rule = "    <!-- vista completa: Moonlight va a pantalla completa por su cuenta -->"
    return f"""<?xml version="1.0"?>
<labwc_config>
  <core>
    <gap>0</gap>
  </core>
  <keyboard>
    <keybind key="C-A-S-x" overrideInhibition="yes">
      <action name="Execute" command="/usr/local/bin/orbit-atajo layout" />
    </keybind>
    <keybind key="C-A-t">
      <action name="Execute" command="/usr/local/bin/orbit-atajo pausa" />
    </keybind>
    <keybind key="C-A-q">
      <action name="Exit" />
    </keybind>
  </keyboard>
  <windowRules>
{rule}
  </windowRules>
</labwc_config>
"""


def write_labwc_rc(path: Path, layout: str, sidebar: bool) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    bak = path.with_name(path.name + ".orbit-bak")
    if path.exists() and not bak.exists():
        previous = path.read_text(encoding="utf-8", errors="replace")
        if "orbit-atajo" not in previous:
            bak.write_text(previous, encoding="utf-8")
    path.write_text(labwc_rc_text(layout, sidebar), encoding="utf-8")


@dataclass
class VideoConfig:
    ddc_enabled: bool = False
    ddc_value_hp: Optional[str] = None
    ddc_value_pi: Optional[str] = None
    ddc_bus: Optional[str] = None
    remote_cmd: list[str] = field(default_factory=list)
    capture_device: Optional[str] = None
    capture_cmd: list[str] = field(default_factory=list)
    timeout_s: float = 10.0
    moonlight_bin: str = ""
    hp_host: str = "10.0.0.1"
    moonlight_app: str = "Desktop"
    labwc_rc: str = ""
    focus_cmd: list[str] = field(default_factory=list)

    @classmethod
    def from_env(cls, env: Optional[dict] = None) -> "VideoConfig":
        e = os.environ if env is None else env
        spec = marco_spec()
        cmd = e.get("ORBIT_REMOTE_CMD", "").strip()
        ccmd = e.get("ORBIT_CAPTURE_CMD", "").strip()
        focus = e.get("ORBIT_FOCUS_CMD", "").strip()
        return cls(ddc_enabled=e.get("ORBIT_VIDEO_DDC", "0") == "1",
                   ddc_value_hp=e.get("ORBIT_DDC_HP") or None,
                   ddc_value_pi=e.get("ORBIT_DDC_PI") or None,
                   ddc_bus=e.get("ORBIT_DDC_BUS") or None,
                   remote_cmd=shlex.split(cmd) if cmd else [],
                   capture_device=e.get("ORBIT_CAPTURE_DEVICE", "").strip() or None,
                   capture_cmd=shlex.split(ccmd) if ccmd else [],
                   moonlight_bin=e.get("ORBIT_MOONLIGHT_BIN", "").strip(),
                   hp_host=(e.get("ORBIT_HP_HOST") or spec["hp_host"]).strip(),
                   moonlight_app=(e.get("ORBIT_MOONLIGHT_APP") or spec["app"]).strip(),
                   labwc_rc=e.get("ORBIT_LABWC_RC", "").strip(),
                   focus_cmd=shlex.split(focus) if focus else [])


class VideoSwitcher:
    def __init__(self, cfg: VideoConfig):
        self.cfg = cfg
        self.visible = "pi"
        self.layout = "integrado"
        self.sidebar = False
        self.last_mode = self.mode()
        self.detail = "Orbit OS visible"
        self._viewer: Optional[asyncio.subprocess.Process] = None
        self._viewer_kind: Optional[str] = None
        self._watch: Optional[asyncio.Task] = None
        self._stopping = False
        self._lock = asyncio.Lock()
        self.on_exit: Optional[Callable] = None
        if self.last_mode == "remoto" and self._uses_moonlight() and not self.is_paired():
            self.detail = pairing_message(self.cfg.hp_host)

    def ddc_ready(self) -> bool:
        c = self.cfg
        return (c.ddc_enabled and shutil.which("ddcutil") is not None
                and all(v is not None and _VCP_RE.match(v) for v in (c.ddc_value_hp, c.ddc_value_pi))
                and (c.ddc_bus is None or c.ddc_bus.isdigit()))

    def capture_configured(self) -> bool:
        c = self.cfg
        return bool(c.capture_cmd) and c.capture_device is not None and _DEV_RE.match(c.capture_device) is not None

    def capture_argv(self) -> list[str]:
        dev = self.cfg.capture_device or ""
        return [a.replace("{device}", dev) for a in self.cfg.capture_cmd]

    def mode(self) -> str:
        if self.ddc_ready():
            return "ddc"
        return "captura" if self.capture_configured() else "remoto"

    def _uses_moonlight(self) -> bool:
        argv = self.cfg.remote_cmd or ([self.cfg.moonlight_bin] if self.cfg.moonlight_bin else [])
        if not argv:
            return False
        name = Path(argv[0]).name.lower()
        return "moonlight" in name

    def is_paired(self) -> bool:
        if not self._uses_moonlight():
            return False
        extra = os.environ.get("ORBIT_MOONLIGHT_CONFIG", "").strip() or None
        return moonlight_paired(self.cfg.hp_host, extra=extra)

    def hole(self) -> tuple[int, int, int, int]:
        return marco_hole(self.sidebar)

    def stream_argv(self) -> list[str]:
        """Orden de Moonlight. ``ORBIT_REMOTE_CMD`` fija la orden y no cambia con la vista."""
        if self.cfg.remote_cmd:
            return list(self.cfg.remote_cmd)
        if not self.cfg.moonlight_bin:
            return []
        spec = marco_spec()
        bin_ = self.cfg.moonlight_bin
        argv = [bin_, "stream", self.cfg.hp_host, self.cfg.moonlight_app or spec["app"],
                "--fps", str(int(spec["fps"])), "--absolute-mouse", "--no-game-optimization",
                "--capture-system-keys", "never"]
        if self.layout == "completa":
            return argv + ["--display-mode", "fullscreen", "--1080"]
        _x, _y, w, h = self.hole()
        return argv + ["--display-mode", "windowed", "--resolution", f"{w}x{h}"]

    def state(self) -> dict:
        d: dict = {"system": self.visible, "mode": self.last_mode, "detail": self.detail[:200]}
        if self.last_mode == "remoto":
            x, y, w, h = self.hole()
            d["pairing"] = "hecho" if self.is_paired() else "pendiente"
            d["layout"] = self.layout
            d["sidebar"] = "abierto" if self.sidebar else "cerrado"
            d["hole"] = {"x": x, "y": y, "w": w, "h": h}
        return d

    async def switch(self, target: Optional[str] = None) -> dict:
        async with self._lock:
            return await self._switch(target)

    async def _switch(self, target: Optional[str] = None) -> dict:
        target = target or ("hp" if self.visible == "pi" else "pi")
        if self.mode() == "ddc":
            ok, msg = await self._ddc(target)
            if ok:
                await self._stop_viewer()
                self.visible, self.last_mode = target, "ddc"
                self.detail = f"Entrada de la MSI cambiada por DDC/CI a {'HP' if target == 'hp' else 'Pi'}"
                if target == "pi":
                    await self._focus_orbit()
                return self._res(True, False, self.detail)
            log.warning("DDC/CI falló (%s): se usa el modo captura o remoto", msg)
            if target == "hp":
                await self._ddc("pi")
            fallback = f"DDC/CI no disponible ({msg}); "
        else:
            fallback = ""
        if self.capture_configured():
            ok, msg = await self._capture(target)
            if ok:
                self.visible, self.last_mode = target, "captura"
                self.detail = fallback + msg
                if target == "pi":
                    await self._focus_orbit()
                return self._res(True, False, self.detail)
            log.warning("Captura no disponible (%s): se usa el modo remoto", msg)
            fallback += f"Captura no disponible ({msg}); "
        ok, dry, msg = await self._remote(target)
        salio = target == "hp" and ok and not dry and not self._viewer_alive()
        if dry and target == "hp" and self._uses_moonlight() and not self.is_paired():
            self.visible = "pi"
        elif salio:
            self.visible = "pi"
            msg = "Orbit OS visible (Moonlight cerrado)"
        else:
            self.visible = target
        self.last_mode = "remoto"
        self.detail = (fallback + msg)[:200]
        if self.visible == "pi":
            await self._focus_orbit()
        return self._res(ok, dry, self.detail)

    async def set_layout(self, layout: str) -> dict:
        async with self._lock:
            if layout not in ("integrado", "completa"):
                return self._res(False, False, "Vista desconocida.", action="pi.stream_layout")
            self.layout = layout
            await self._apply_place()
            if self.visible == "hp" and self._viewer_alive():
                await self._stop_viewer()
                ok, dry, msg = await self._remote("hp")
                if dry:
                    self.visible = "pi"
                self.detail = msg[:200]
                return self._res(ok, dry, self.detail, action="pi.stream_layout")
            nombre = "integrada" if layout == "integrado" else "a pantalla completa"
            self.detail = f"Vista {nombre} lista para la próxima vez que se abra el HP."[:200]
            return self._res(True, False, self.detail, action="pi.stream_layout")

    async def toggle_layout(self) -> dict:
        return await self.set_layout("completa" if self.layout == "integrado" else "integrado")

    async def set_sidebar(self, open_: bool) -> dict:
        async with self._lock:
            self.sidebar = open_
            await self._apply_place()
            _x, _y, w, h = self.hole()
            if self.visible == "hp" and self.layout == "integrado" and self._viewer_alive():
                await self._stop_viewer()
                ok, dry, msg = await self._remote("hp")
                if dry:
                    self.visible = "pi"
                self.detail = msg[:200]
                return self._res(ok, dry, self.detail, action="pi.marco_sidebar")
            estado = "abierta" if open_ else "cerrada"
            self.detail = f"Barra lateral {estado}. Hueco {w}×{h}."[:200]
            return self._res(True, False, self.detail, action="pi.marco_sidebar")

    def _res(self, ok: bool, dry: bool, message: str, action: str = "pi.switch_visible") -> dict:
        return {"action": action, "ok": ok, "dry_run": dry, "simulated": False, "message": message[:500]}

    def _viewer_alive(self) -> bool:
        return self._viewer is not None and self._viewer.returncode is None

    async def _apply_place(self) -> None:
        if self.cfg.labwc_rc:
            try:
                write_labwc_rc(Path(self.cfg.labwc_rc), self.layout, self.sidebar)
            except OSError as exc:
                log.warning("no se pudo escribir labwc rc: %s", exc)
        if self.cfg.labwc_rc and shutil.which("labwc"):
            try:
                p = await asyncio.create_subprocess_exec(
                    "labwc", "--reconfigure", stdout=asyncio.subprocess.DEVNULL, stderr=asyncio.subprocess.DEVNULL)
                await asyncio.wait_for(p.wait(), 3)
            except (OSError, asyncio.TimeoutError) as exc:
                log.warning("labwc --reconfigure: %s", exc)

    async def _ddc(self, target: str) -> tuple[bool, str]:
        value = self.cfg.ddc_value_hp if target == "hp" else self.cfg.ddc_value_pi
        argv = ["ddcutil"] + (["--bus", self.cfg.ddc_bus] if self.cfg.ddc_bus else []) + ["setvcp", "60", str(value)]
        try:
            p = await asyncio.create_subprocess_exec(*argv, stdout=asyncio.subprocess.DEVNULL,
                                                     stderr=asyncio.subprocess.PIPE)
            _, err = await asyncio.wait_for(p.communicate(), self.cfg.timeout_s)
        except (OSError, asyncio.TimeoutError) as exc:
            return False, f"ddcutil: {exc.__class__.__name__}"
        if p.returncode != 0:
            return False, (err or b"").decode(errors="replace").strip()[:160] or f"código {p.returncode}"
        return True, "ok"

    async def _capture(self, target: str) -> tuple[bool, str]:
        if target == "pi":
            await self._stop_viewer()
            return True, "Orbit OS visible (visor cerrado)"
        dev = self.cfg.capture_device or ""
        if not os.path.exists(dev):
            return False, f"no existe {dev}"
        if self._viewer_alive():
            if self._viewer_kind == "captura":
                return True, "Visor ya abierto"
            await self._stop_viewer()
        try:
            self._viewer = await asyncio.create_subprocess_exec(
                *self.capture_argv(), stdout=asyncio.subprocess.DEVNULL, stderr=asyncio.subprocess.DEVNULL)
        except OSError as exc:
            self._viewer = None
            return False, f"no se pudo abrir el visor: {exc.strerror or exc.__class__.__name__}"
        self._viewer_kind = "captura"
        self._arm_watch()
        return True, f"HP visible por el visor ({dev})"

    async def _remote(self, target: str) -> tuple[bool, bool, str]:
        if target == "pi":
            await self._stop_viewer()
            return True, False, "Orbit OS visible (Moonlight cerrado)"
        if self._uses_moonlight() and not self.is_paired():
            return True, True, pairing_message(self.cfg.hp_host)
        argv = self.stream_argv()
        if not argv:
            return True, True, "HP en modo remoto: Moonlight sin configurar (ORBIT_MOONLIGHT_BIN). No se lanza nada."
        if self._viewer_alive():
            if self._viewer_kind == "remoto":
                return True, False, "Moonlight ya está abierto"
            await self._stop_viewer()
        await self._apply_place()
        ok, err = await self._spawn(argv)
        if not ok:
            return False, False, err
        if self.layout == "completa":
            return True, False, "Moonlight a pantalla completa, 1920×1080 a 60 fps."
        _x, _y, w, h = self.hole()
        return True, False, f"Moonlight integrado, ventana sin bordes de {w}×{h} a 60 fps."

    async def _spawn(self, argv: list[str]) -> tuple[bool, str]:
        env = os.environ.copy()
        env["QT_WAYLAND_DISABLE_WINDOWDECORATION"] = "1"
        try:
            self._viewer = await asyncio.create_subprocess_exec(
                *argv, stdout=asyncio.subprocess.DEVNULL, stderr=asyncio.subprocess.DEVNULL, env=env)
        except OSError as exc:
            self._viewer = None
            return False, f"No se pudo abrir Moonlight: {exc.strerror or exc}"
        self._viewer_kind = "remoto"
        self._arm_watch()
        return True, ""

    def _arm_watch(self) -> None:
        proc = self._viewer
        if proc is None:
            return
        if self._watch is not None and not self._watch.done():
            self._watch.cancel()
        self._watch = asyncio.create_task(self._watch_viewer(proc, self._viewer_kind))

    async def _watch_viewer(self, proc: asyncio.subprocess.Process, kind: Optional[str]) -> None:
        try:
            await proc.wait()
        except asyncio.CancelledError:
            return
        if self._stopping or self._viewer is not proc:
            return
        self._viewer = None
        self._viewer_kind = None
        if self.visible == "hp":
            self.visible = "pi"
            self.detail = ("Orbit OS visible (visor cerrado)" if kind == "captura"
                           else "Orbit OS visible (Moonlight cerrado)")
            await self._focus_orbit()
            cb = self.on_exit
            if cb is not None:
                result = cb()
                if asyncio.iscoroutine(result):
                    await result

    async def _stop_viewer(self) -> None:
        self._stopping = True
        watch, self._watch = self._watch, None
        if watch is not None:
            watch.cancel()
            try:
                await watch
            except asyncio.CancelledError:
                pass
        v, self._viewer, self._viewer_kind = self._viewer, None, None
        self._stopping = False
        if v is None or v.returncode is not None:
            return
        v.terminate()
        try:
            await asyncio.wait_for(v.wait(), 5)
        except asyncio.TimeoutError:
            v.kill()

    async def _focus_orbit(self) -> None:
        if not self.cfg.focus_cmd:
            return
        try:
            p = await asyncio.create_subprocess_exec(
                *self.cfg.focus_cmd, stdout=asyncio.subprocess.DEVNULL, stderr=asyncio.subprocess.DEVNULL)
            await asyncio.wait_for(p.wait(), 3)
        except (OSError, asyncio.TimeoutError) as exc:
            log.warning("no se pudo traer Orbit OS al frente: %s", exc)

    async def close(self) -> None:
        await self._stop_viewer()
