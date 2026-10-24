"""Cliente WebSocket del HP: hello+token, telemetría periódica, latido y acciones de lista blanca."""
from __future__ import annotations

import asyncio
import functools
import json
import logging
import platform
import socket
import subprocess
import time

import aiohttp
import psutil

import orbit_protocol as P

from . import __version__
from .actions import run_action
from .config import AgentConfig
from .volume import read_default

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


_temp_cache: tuple[float, float | None] | None = None
_TEMP_TTL_S = 30.0


def celsius_from_acpi_tenths(raw: str) -> float | None:
    """MSAcpi_ThermalZoneTemperature.CurrentTemperature viene en décimas de kelvin.

    Fuera de 5–100 °C se descarta: un cero o un valor absurdo no se enseña.
    """
    for line in raw.splitlines():
        piece = line.strip()
        if not piece:
            continue
        try:
            value = float(piece)
        except ValueError:
            continue
        celsius = value / 10.0 - 273.15
        if 5.0 <= celsius <= 100.0:
            return round(celsius, 1)
    return None


def _temp_psutil() -> float | None:
    # En Windows psutil.sensors_temperatures lanza NotImplementedError. No es un fallo del agente.
    try:
        readings = psutil.sensors_temperatures() or {}
    except (AttributeError, OSError, NotImplementedError):
        return None
    for values in readings.values():
        if values:
            return round(values[0].current, 1)
    return None


def _temp_windows_cached() -> float | None:
    global _temp_cache
    now = time.monotonic()
    if _temp_cache is not None and now - _temp_cache[0] < _TEMP_TTL_S:
        return _temp_cache[1]
    value = _read_acpi_temp()
    _temp_cache = (now, value)
    return value


def _read_acpi_temp() -> float | None:
    if platform.system() != "Windows":
        return None
    flags = getattr(subprocess, "CREATE_NO_WINDOW", 0)
    try:
        done = subprocess.run(
            ["powershell", "-NoProfile", "-NonInteractive", "-Command",
             "Get-CimInstance -Namespace root/wmi -ClassName MSAcpi_ThermalZoneTemperature "
             "-ErrorAction SilentlyContinue | Select-Object -ExpandProperty CurrentTemperature"],
            capture_output=True, text=True, timeout=1.5, creationflags=flags,
        )
    except (OSError, subprocess.TimeoutExpired):
        return None
    return celsius_from_acpi_tenths(done.stdout or "")


def _cpu_temp_c() -> float | None:
    got = _temp_psutil()
    if got is not None:
        return got
    if platform.system() != "Windows":
        return None
    return _temp_windows_cached()


# Lectura anterior de bytes enviados y recibidos, para pasar de contadores a kb/s.
_last_net: tuple[float, int, int] | None = None


def _nic_cuenta(nombre: str) -> bool:
    """Suma Wi-Fi (internet) y Ethernet (cable a la Pi). Fuera: loopback y Virtual Display Driver."""
    n = nombre.strip().lower()
    if n in {"lo", "lo0"} or "loopback" in n:
        return False
    if "virtual display" in n or "virtualdisplay" in n:
        return False
    return True


def _bytes_red() -> tuple[int, int]:
    """Bytes enviados y recibidos. Por interfaz si se puede; si no, el total de psutil."""
    try:
        per = psutil.net_io_counters(pernic=True)
    except (AttributeError, OSError, NotImplementedError):
        per = None
    if per:
        sent = recv = 0
        for nombre, c in per.items():
            if not _nic_cuenta(str(nombre)):
                continue
            sent += int(c.bytes_sent)
            recv += int(c.bytes_recv)
        return sent, recv
    try:
        total = psutil.net_io_counters()
    except (AttributeError, OSError, NotImplementedError):
        return 0, 0
    if not total:
        return 0, 0
    return int(total.bytes_sent), int(total.bytes_recv)


def _net_kbps() -> tuple[float, float]:
    """Subida y bajada en kb/s, la misma cuenta que la Pi: bytes de diferencia × 8 / 1000 / segundos."""
    global _last_net
    sent, recv = _bytes_red()
    now = time.monotonic()
    if _last_net is None:
        _last_net = (now, sent, recv)
        return 0.0, 0.0
    t0, s0, r0 = _last_net
    _last_net = (now, sent, recv)
    dt = max(now - t0, 1e-3)
    up = max(0, sent - s0) * 8 / 1000 / dt
    down = max(0, recv - r0) * 8 / 1000 / dt
    return round(up, 1), round(down, 1)


def telemetry() -> dict:
    vm = psutil.virtual_memory()
    try:
        disk = psutil.disk_usage("C:\\" if platform.system() == "Windows" else "/").percent
    except OSError:
        disk = 0.0
    up, down = _net_kbps()
    out = {"host": "hp", "simulated": False, "hostname": socket.gethostname()[:64],
           "model": machine_model(), "os": os_label(),
           "cpu_pct": round(psutil.cpu_percent(interval=None), 1), "mem_pct": round(vm.percent, 1),
           "mem_used_mb": round((vm.total - vm.available) / 2**20, 1), "mem_total_mb": round(vm.total / 2**20, 1),
           "disk_pct": round(disk, 1), "temp_c": _cpu_temp_c(), "uptime_s": round(time.time() - psutil.boot_time()),
           "net_up_kbps": up, "net_down_kbps": down}
    # Opcional: un orbitd anterior no conoce estas claves y rechazaría toda la telemetría.
    # La Pi tiene que actualizarse antes que el HP. Si no hay mezclador, no se envían.
    heard = read_default()
    if heard is not None:
        out["volume_pct"] = heard[0]
        out["volume_muted"] = heard[1]
    return out


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
