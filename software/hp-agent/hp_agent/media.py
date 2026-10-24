"""Reproducir o pausar en Windows con la tecla de medios del sistema.

No abre programas ni escribe en el mezclador. En seco no pulsa la tecla.
En Linux la orden sigue siendo playerctl, en actions.py.
"""
from __future__ import annotations

import orbit_protocol as P

VK_MEDIA_PLAY_PAUSE = 0xB3
KEYEVENTF_KEYUP = 0x0002


def pulsar_play_pausa() -> None:
    """Pulsa y suelta la tecla de reproducir/pausar. Solo tiene efecto en Windows."""
    import ctypes

    user32 = ctypes.WinDLL("user32", use_last_error=True)
    user32.keybd_event(VK_MEDIA_PLAY_PAUSE, 0, 0, 0)
    user32.keybd_event(VK_MEDIA_PLAY_PAUSE, 0, KEYEVENTF_KEYUP, 0)


def apply_play_pause(*, live: bool, press=None) -> dict:
    """hp.media_play_pause. press sustituye a la tecla real en las pruebas."""
    action = "hp.media_play_pause"
    P.check_action(action, {}, target="hp")
    if not live:
        return {"action": action, "ok": True, "dry_run": True, "simulated": False,
                "message": "Preparado. No se ha pulsado reproducir o pausar."}
    try:
        (press or pulsar_play_pausa)()
    except Exception as exc:
        return {"action": action, "ok": False, "dry_run": False, "simulated": False,
                "message": f"No se ha podido cambiar la reproducción: {exc}"[:500]}
    return {"action": action, "ok": True, "dry_run": False, "simulated": False,
            "message": "Reproducción o pausa enviada."}
