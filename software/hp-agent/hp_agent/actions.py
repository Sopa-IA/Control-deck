"""Traducción de acciones de la lista blanca a órdenes FIJAS del sistema (sin shell, sin texto libre)."""
from __future__ import annotations

import logging
import platform
import subprocess
from typing import Optional

import orbit_protocol as P

from .volume import VolumeDevice, apply_windows

log = logging.getLogger("hp_agent.actions")

SIN_ORDEN = None  # no hay una orden de consola: el volumen y la tecla de medios van aparte

_HECHO = {
    "hp.lock_screen": "Sesión bloqueada.",
    "hp.shutdown": "El equipo se apagará en un minuto. Puedes anularlo.",
    "hp.restart": "El equipo se reiniciará en un minuto. Puedes anularlo.",
    "hp.shutdown_cancel": "Apagado anulado.",
    "hp.open_app": "Aplicación abierta.",
    "hp.ping": "El HP responde.",
    "hp.media_play_pause": "Reproducción o pausa enviada.",
}


def command_for(action: str, params: dict, system: str, apps: dict[str, list[str]]) -> Optional[list[str]]:
    """Devuelve la orden (lista de argumentos) o None si no hay implementación real. Lanza ProtocolError
    si la acción no está en la lista blanca o los parámetros no son válidos."""
    P.check_action(action, params, target="hp")
    win = system == "Windows"
    if action == "hp.ping":
        return []
    if action == "hp.lock_screen":
        return ["rundll32.exe", "user32.dll,LockWorkStation"] if win else ["loginctl", "lock-session"]
    if action == "hp.volume_set":
        return SIN_ORDEN if win else ["pactl", "set-sink-volume", "@DEFAULT_SINK@", f"{int(params['level'])}%"]
    if action == "hp.volume_mute":
        return SIN_ORDEN if win else ["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"]
    if action == "hp.media_play_pause":
        return SIN_ORDEN if win else ["playerctl", "play-pause"]
    if action == "hp.open_app":
        cmd = apps.get(params["app"])
        if not cmd or not isinstance(cmd, list) or not all(isinstance(x, str) for x in cmd):
            raise P.ProtocolError("bad_params", f"aplicación no configurada en el agente: {params['app']}")
        return list(cmd)
    if action == "hp.shutdown":
        return ["shutdown", "/s", "/t", "60"] if win else ["shutdown", "-h", "+1"]
    if action == "hp.restart":
        return ["shutdown", "/r", "/t", "60"] if win else ["shutdown", "-r", "+1"]
    if action == "hp.shutdown_cancel":
        return ["shutdown", "/a"] if win else ["shutdown", "-c"]
    raise P.ProtocolError("not_allowed", f"sin traducción para {action}")  # pragma: no cover


def run_action(action: str, params: dict, *, live: bool, apps: dict[str, list[str]],
               system: Optional[str] = None, volume_device: Optional[VolumeDevice] = None) -> dict:
    """Ejecuta (o simula en dry-run) una acción. Devuelve payload de action_result."""
    system = system or platform.system()
    if system == "Windows" and action in ("hp.volume_set", "hp.volume_mute"):
        try:
            return apply_windows(action, params, live=live, device=volume_device)
        except P.ProtocolError as exc:
            return {"action": action, "ok": False, "dry_run": not live, "simulated": False, "message": exc.message}
    if system == "Windows" and action == "hp.media_play_pause":
        from .media import apply_play_pause
        try:
            return apply_play_pause(live=live)
        except P.ProtocolError as exc:
            return {"action": action, "ok": False, "dry_run": not live, "simulated": False, "message": exc.message}
    try:
        cmd = command_for(action, params, system, apps)
    except P.ProtocolError as exc:
        return {"action": action, "ok": False, "dry_run": not live, "simulated": False, "message": exc.message}
    if cmd == []:
        return {"action": action, "ok": True, "dry_run": not live, "simulated": False, "message": "El HP responde."}
    if cmd is None:
        return {"action": action, "ok": False, "dry_run": not live, "simulated": False,
                "message": f"No está disponible en {system}."}
    pretty = " ".join(cmd)
    if not live:
        log.info("DRY-RUN %s -> %s", action, pretty)
        return {"action": action, "ok": True, "dry_run": True, "simulated": False,
                "message": "Preparado. No se ha ejecutado."}
    try:
        if action == "hp.open_app":
            subprocess.Popen(cmd, shell=False)  # noqa: S603 - orden de la lista local
        else:
            r = subprocess.run(cmd, shell=False, capture_output=True, text=True, timeout=10)  # noqa: S603
            if r.returncode != 0:
                detalle = (r.stderr or r.stdout).strip()[:200]
                return {"action": action, "ok": False, "dry_run": False, "simulated": False,
                        "message": f"No se ha podido.{(' ' + detalle) if detalle else ''}"}
        return {"action": action, "ok": True, "dry_run": False, "simulated": False,
                "message": _HECHO.get(action, "Hecho.")}
    except (OSError, subprocess.TimeoutExpired) as exc:
        return {"action": action, "ok": False, "dry_run": False, "simulated": False, "message": f"error: {exc}"[:500]}
