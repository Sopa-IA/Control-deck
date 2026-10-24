"""Temperatura de la CPU en el HP.

LibreHardwareMonitor (MPL-2.0) publica los sensores en http://127.0.0.1:8085/data.json
mientras corre. Si ese dato no está, se prueba WMI en root/LibreHardwareMonitor y,
al final, MSAcpi_ThermalZoneTemperature. Sin dato, None: la tarjeta sigue en raya
y el resto de la telemetría no se toca.
"""
from __future__ import annotations

import json
import logging
import re
import subprocess
import time
import urllib.error
import urllib.request

log = logging.getLogger("hp_agent.temp")

LHM_URL = "http://127.0.0.1:8085/data.json"
_NUM = re.compile(r"-?\d+(?:[.,]\d+)?")
_TTL_S = 30.0
_cache: tuple[float, float | None] | None = None


def parse_celsius(value) -> float | None:
    """Un número ya en °C, o un texto tipo «45,0 °C». Fuera de 5–115 °C no se enseña."""
    if isinstance(value, bool) or value is None:
        return None
    if isinstance(value, (int, float)):
        celsius = float(value)
    else:
        match = _NUM.search(str(value))
        if not match:
            return None
        celsius = float(match.group(0).replace(",", "."))
    if 5.0 <= celsius <= 115.0:
        return round(celsius, 1)
    return None


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


def _rango_cpu(text: str, ident: str) -> int | None:
    """0 es el paquete, 1 un núcleo. None no es la CPU."""
    blob = f"{text} {ident}".lower()
    if any(token in blob for token in ("gpu", "nvme", "hdd", "ssd", "nic", "wifi", "ethernet")) and "cpu" not in blob:
        return None
    if not any(token in blob for token in ("cpu", "package", "tctl", "tdie")):
        return None
    if any(token in blob for token in ("package", "tctl", "tdie")):
        return 0
    return 1


def _elige(candidatos: list[tuple[int, float]]) -> float | None:
    if not candidatos:
        return None
    mejor = min(rango for rango, _ in candidatos)
    valores = [valor for rango, valor in candidatos if rango == mejor]
    # Varios núcleos: el más caliente. Un solo paquete: ese.
    return max(valores) if mejor == 1 else valores[0]


def cpu_celsius_from_lhm_json(data) -> float | None:
    """Árbol data.json de LibreHardwareMonitor. Elige CPU Package, Tctl/Tdie o el núcleo más caliente."""
    candidatos: list[tuple[int, float]] = []

    def walk(node, hardware_id: str = "") -> None:
        if isinstance(node, list):
            for item in node:
                walk(item, hardware_id)
            return
        if not isinstance(node, dict):
            return
        hid = str(node.get("HardwareId") or hardware_id)
        ident = str(node.get("SensorId") or hid)
        text = str(node.get("Text") or node.get("Name") or "")
        tipo = str(node.get("Type") or node.get("SensorType") or "")
        if tipo.lower() == "temperature" or "/temperature/" in ident.lower():
            rango = _rango_cpu(text, ident)
            if rango is not None:
                valor = parse_celsius(node.get("Value"))
                if valor is None:
                    valor = parse_celsius(node.get("RawValue"))
                if valor is not None:
                    candidatos.append((rango, valor))
        for child in node.get("Children") or []:
            walk(child, hid)

    walk(data)
    return _elige(candidatos)


def cpu_celsius_from_wmi(data) -> float | None:
    """Filas de la clase Sensor en root/LibreHardwareMonitor."""
    if isinstance(data, dict):
        data = [data]
    if not isinstance(data, list):
        return None
    candidatos: list[tuple[int, float]] = []
    for row in data:
        if not isinstance(row, dict):
            continue
        tipo = str(row.get("SensorType") or "")
        if tipo and tipo.lower() != "temperature":
            continue
        text = str(row.get("Name") or "")
        ident = str(row.get("Identifier") or "")
        rango = _rango_cpu(text, ident)
        if rango is None:
            continue
        valor = parse_celsius(row.get("Value"))
        if valor is not None:
            candidatos.append((rango, valor))
    return _elige(candidatos)


def _http_lhm() -> float | None:
    try:
        with urllib.request.urlopen(LHM_URL, timeout=0.8) as response:
            raw = response.read(1_000_000)
        data = json.loads(raw.decode("utf-8", "replace"))
    except (OSError, urllib.error.URLError, TimeoutError, ValueError, json.JSONDecodeError):
        return None
    return cpu_celsius_from_lhm_json(data)


def _wmi_lhm() -> float | None:
    flags = getattr(subprocess, "CREATE_NO_WINDOW", 0)
    script = (
        "Get-CimInstance -Namespace root/LibreHardwareMonitor -ClassName Sensor "
        "-ErrorAction SilentlyContinue | "
        "Where-Object { $_.SensorType -eq 'Temperature' } | "
        "Select-Object Name,Identifier,Value | ConvertTo-Json -Compress"
    )
    try:
        done = subprocess.run(
            ["powershell", "-NoProfile", "-NonInteractive", "-Command", script],
            capture_output=True, text=True, timeout=1.5, creationflags=flags,
        )
    except (OSError, subprocess.TimeoutExpired):
        return None
    text = (done.stdout or "").strip()
    if not text:
        return None
    try:
        data = json.loads(text)
    except json.JSONDecodeError:
        return None
    return cpu_celsius_from_wmi(data)


def _acpi() -> float | None:
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


def windows_cpu_c() -> float | None:
    """HTTP de LibreHardwareMonitor, luego WMI, luego ACPI. El fallo se recuerda 30 s."""
    global _cache
    now = time.monotonic()
    if _cache is not None and now - _cache[0] < _TTL_S:
        return _cache[1]
    value = _http_lhm()
    if value is None:
        value = _wmi_lhm()
    if value is None:
        value = _acpi()
    if value is None:
        log.debug("sin temperatura de CPU")
    _cache = (now, value)
    return value
