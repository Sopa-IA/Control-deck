"""Volumen del dispositivo de salida por defecto en Windows, con pycaw.

En Linux no se usa: allí sigue pactl. Si pycaw no está, la acción falla con un
mensaje y el resto del agente sigue.
"""
from __future__ import annotations

import logging
from typing import Optional, Protocol

log = logging.getLogger("hp_agent.volume")


class VolumeDevice(Protocol):
    def get(self) -> tuple[int, bool]: ...
    def set_level(self, level: int) -> None: ...
    def set_muted(self, muted: bool) -> None: ...


class _PycawDevice:
    def __init__(self, endpoint) -> None:
        self._endpoint = endpoint

    def get(self) -> tuple[int, bool]:
        level = int(round(float(self._endpoint.GetMasterVolumeLevelScalar()) * 100))
        return max(0, min(100, level)), bool(self._endpoint.GetMute())

    def set_level(self, level: int) -> None:
        self._endpoint.SetMasterVolumeLevelScalar(max(0, min(100, int(level))) / 100.0, None)

    def set_muted(self, muted: bool) -> None:
        self._endpoint.SetMute(1 if muted else 0, None)


def open_default_device() -> VolumeDevice:
    """Mezclador de la salida por defecto. Importa pycaw solo aquí, y solo en Windows."""
    try:
        from pycaw.pycaw import AudioUtilities
    except ImportError as exc:
        raise RuntimeError("falta pycaw: vuelve a lanzar instalar-hp.ps1") from exc
    speakers = AudioUtilities.GetSpeakers()
    endpoint = getattr(speakers, "EndpointVolume", None)
    if endpoint is None:
        from ctypes import POINTER, cast

        from comtypes import CLSCTX_ALL
        from pycaw.pycaw import IAudioEndpointVolume
        interface = speakers.Activate(IAudioEndpointVolume._iid_, CLSCTX_ALL, None)
        endpoint = cast(interface, POINTER(IAudioEndpointVolume))
    return _PycawDevice(endpoint)


def read_default() -> Optional[tuple[int, bool]]:
    """Nivel 0–100 y si está silenciado. None si este sistema no lo ofrece."""
    import platform
    if platform.system() != "Windows":
        return None
    try:
        return open_default_device().get()
    except Exception:
        log.debug("no se pudo leer el volumen", exc_info=True)
        return None


def apply_windows(action: str, params: dict, *, live: bool, device: Optional[VolumeDevice] = None) -> dict:
    """hp.volume_set y hp.volume_mute. En seco no toca el mezclador."""
    import orbit_protocol as P
    P.check_action(action, params, target="hp")
    if not live:
        if action == "hp.volume_set":
            text = f"DRY-RUN: pondría el volumen al {int(params['level'])}%"
        else:
            text = "DRY-RUN: alternaría el silencio"
        return {"action": action, "ok": True, "dry_run": True, "simulated": False, "message": text}
    try:
        mixer = device or open_default_device()
        if action == "hp.volume_set":
            mixer.set_level(int(params["level"]))
        else:
            level, muted = mixer.get()
            mixer.set_muted(not muted)
        level, muted = mixer.get()
    except Exception as exc:
        return {"action": action, "ok": False, "dry_run": False, "simulated": False,
                "message": f"error de volumen: {exc}"[:500]}
    estado = "silenciado" if muted else "con sonido"
    return {"action": action, "ok": True, "dry_run": False, "simulated": False,
            "message": f"volumen al {level}%, {estado}"}
