"""Cliente WebSocket del HP: hello+token, telemetría periódica, latido y acciones de lista blanca."""
from __future__ import annotations

import asyncio
import functools
import json
import logging
import platform
import socket

import aiohttp
import psutil

import orbit_protocol as P

from . import __version__
from .actions import run_action
from .config import AgentConfig

log = logging.getLogger("hp_agent")


def machine_model() -> str:
    """Nombre comercial del equipo. En Windows, del registro. Si no se puede leer, queda pendiente."""
    if platform.system() == "Windows":
        try:
            import winreg
            with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"HARDWARE\DESCRIPTION\System\BIOS") as key:
                value, _ = winreg.QueryValueEx(key, "SystemProductName")
            text = str(value).strip()
            if text:
                return text[:128]
        except (OSError, ImportError, AttributeError):
            pass
    return "HP (modelo PENDIENTE)"


def os_label() -> str:
    system = platform.system()
    if system == "Windows":
        ver = platform.version()
        text = f"Windows {platform.release()}"
        if ver:
            text = f"{text} ({ver})"
        return text[:128]
    return f"{system} {platform.release()}"[:128]


def _cpu_temp_c() -> float | None:
    # En Windows psutil.sensors_temperatures lanza NotImplementedError. No es un fallo del agente.
    try:
        readings = psutil.sensors_temperatures() or {}
    except (AttributeError, OSError, NotImplementedError):
        return None
    for values in readings.values():
        if values:
            return round(values[0].current, 1)
    return None


def telemetry() -> dict:
    vm = psutil.virtual_memory()
    try:
        disk = psutil.disk_usage("C:\\" if platform.system() == "Windows" else "/").percent
    except OSError:
        disk = 0.0
    import time
    return {"host": "hp", "simulated": False, "hostname": socket.gethostname()[:64],
            "model": machine_model(), "os": os_label(),
            "cpu_pct": round(psutil.cpu_percent(interval=None), 1), "mem_pct": round(vm.percent, 1),
            "mem_used_mb": round((vm.total - vm.available) / 2**20, 1), "mem_total_mb": round(vm.total / 2**20, 1),
            "disk_pct": round(disk, 1), "temp_c": _cpu_temp_c(), "uptime_s": round(time.time() - psutil.boot_time())}


async def run_once(cfg: AgentConfig) -> None:
    async with aiohttp.ClientSession() as s:
        async with s.ws_connect(cfg.hub_url, heartbeat=None, max_msg_size=P.MAX_MESSAGE_BYTES) as ws:
            await ws.send_str(json.dumps(P.make("hello", "hp", {"role": "hp-agent", "client": socket.gethostname()[:64],
                                                                "version": __version__, "token": cfg.token or ""})))
            first = P.parse((await ws.receive(timeout=5)).data)
            if first["type"] != "welcome":
                raise PermissionError(first["payload"].get("message", "rechazado"))
            log.info("conectado a %s (modo %s, %s)", cfg.hub_url, first["payload"]["mode"],
                     "LIVE" if cfg.live else "DRY-RUN")

            async def tele() -> None:
                while True:
                    await ws.send_str(json.dumps(P.make("telemetry", "hp", telemetry())))
                    await asyncio.sleep(cfg.telemetry_period_s)

            task = asyncio.ensure_future(tele())
            try:
                async for raw in ws:
                    if raw.type != aiohttp.WSMsgType.TEXT:
                        continue
                    try:
                        msg = P.parse(raw.data)
                    except P.ProtocolError as exc:
                        log.warning("mensaje inválido: %s", exc.message)
                        continue
                    if msg["type"] == "ping":
                        await ws.send_str(json.dumps(P.make("pong", "hp", {"seq": msg["payload"]["seq"]}, msg["id"])))
                    elif msg["type"] == "action":
                        p = msg["payload"]
                        # get_running_loop: en 3.12 get_event_loop() avisa y, fuera de un bucle, falla.
                        res = await asyncio.get_running_loop().run_in_executor(
                            None, functools.partial(run_action, p["action"], p.get("params", {}), live=cfg.live, apps=cfg.apps))
                        await ws.send_str(json.dumps(P.make("action_result", "hp", res, msg["id"])))
                    elif msg["type"] == "error":
                        log.warning("orbitd: %s", msg["payload"]["message"])
            finally:
                task.cancel()


async def run_forever(cfg: AgentConfig) -> None:
    delay = 1.0
    while True:
        try:
            await run_once(cfg)
            delay = 1.0
        except PermissionError as exc:
            log.error("autenticación rechazada: %s (revisa ORBIT_HP_TOKEN)", exc)
            delay = 30.0
        except (aiohttp.ClientError, asyncio.TimeoutError, OSError) as exc:
            log.warning("sin conexión con orbitd (%s); reintento en %.0f s", exc, delay)
        await asyncio.sleep(delay)
        delay = min(delay * 2, 30.0)
