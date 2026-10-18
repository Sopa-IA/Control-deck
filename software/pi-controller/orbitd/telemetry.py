"""Telemetría de la Pi (REAL, con psutil sobre el equipo donde corre orbitd) y del HP SIMULADO."""
from __future__ import annotations

import math
import platform
import socket
import time
from pathlib import Path

import psutil

_last_net = None


def board_model() -> str:
    p = Path("/proc/device-tree/model")
    try:
        return p.read_text(errors="ignore").strip("\x00\n ") or "desconocido"
    except OSError:
        return "desconocido (no es una Raspberry Pi)"


def is_raspberry_pi() -> bool:
    return board_model().lower().startswith("raspberry pi")


def _temp() -> float | None:
    try:
        temps = psutil.sensors_temperatures()
    except (AttributeError, OSError):
        return None
    for key in ("cpu_thermal", "coretemp", "k10temp", "soc_thermal"):
        if temps.get(key):
            return round(temps[key][0].current, 1)
    for v in temps.values():
        if v:
            return round(v[0].current, 1)
    return None


def _net_kbps() -> tuple[float, float]:
    global _last_net
    c = psutil.net_io_counters()
    now = time.monotonic()
    if _last_net is None:
        _last_net = (now, c.bytes_sent, c.bytes_recv)
        return 0.0, 0.0
    t0, s0, r0 = _last_net
    _last_net = (now, c.bytes_sent, c.bytes_recv)
    dt = max(now - t0, 1e-3)
    return round((c.bytes_sent - s0) * 8 / 1000 / dt, 1), round((c.bytes_recv - r0) * 8 / 1000 / dt, 1)


def local_telemetry(host: str = "pi") -> dict:
    """Lecturas reales del equipo local. simulated=False siempre."""
    vm = psutil.virtual_memory()
    up, down = _net_kbps()
    try:
        disk = psutil.disk_usage("/").percent
    except OSError:
        disk = 0.0
    return {
        "host": host, "simulated": False,
        "hostname": socket.gethostname()[:64],
        "model": board_model()[:128],
        "os": f"{platform.system()} {platform.release()}"[:128],
        "cpu_pct": round(psutil.cpu_percent(interval=None), 1),
        "mem_pct": round(vm.percent, 1),
        "mem_used_mb": round((vm.total - vm.available) / 2**20, 1),
        "mem_total_mb": round(vm.total / 2**20, 1),
        "disk_pct": round(disk, 1),
        "temp_c": _temp(),
        "uptime_s": round(time.time() - psutil.boot_time()),
        "net_up_kbps": up, "net_down_kbps": down,
    }


def simulated_hp_telemetry(t: float | None = None) -> dict:
    """Valores INVENTADOS para desarrollar sin el HP. simulated=True siempre."""
    t = time.time() if t is None else t
    cpu = 18 + 12 * math.sin(t / 7) + 6 * math.sin(t / 1.7)
    mem = 41 + 4 * math.sin(t / 30)
    return {
        "host": "hp", "simulated": True, "hostname": "hp-simulado", "model": "HP (simulado; modelo real PENDIENTE)",
        "os": "simulado", "cpu_pct": round(max(0.0, min(100.0, cpu)), 1), "mem_pct": round(mem, 1),
        "mem_used_mb": round(8192 * mem / 100, 1), "mem_total_mb": 8192.0, "disk_pct": 63.0,
        "temp_c": round(44 + 6 * math.sin(t / 11), 1), "uptime_s": round(t % 86400),
        "net_up_kbps": round(abs(120 * math.sin(t / 5)), 1), "net_down_kbps": round(abs(900 * math.sin(t / 3)), 1),
    }
