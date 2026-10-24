"""Apagado y reinicio de la Raspberry Pi.

La orden es una lista fija de argumentos, sin shell. Solo se ejecuta si orbitd
no está en simulación, el entorno pide energía en vivo y el equipo es una Pi.
El simulador y un PC de desarrollo no llegan a systemctl.
"""
from __future__ import annotations

import os
import subprocess
from pathlib import Path

SYSTEMCTL = "/usr/bin/systemctl"
# sudoers solo admite estas dos líneas, tal cual.
COMMANDS: dict[str, tuple[str, ...]] = {
    "pi.shutdown": (SYSTEMCTL, "poweroff"),
    "pi.restart": (SYSTEMCTL, "reboot"),
}
_VERBS = {"pi.shutdown": "apagar", "pi.restart": "reiniciar"}


def read_device_model(path: Path | None = None) -> str:
    """Modelo del device-tree. Vacío si este kernel no es una Pi."""
    src = path or Path("/proc/device-tree/model")
    try:
        raw = src.read_bytes()
    except OSError:
        return ""
    return raw.split(b"\0", 1)[0].decode("utf-8", "replace").strip()


def power_allowed(*, sim: bool, power_live: bool, model: str) -> bool:
    if sim or not power_live:
        return False
    return model.startswith("Raspberry Pi")


def argv_for(action: str) -> list[str] | None:
    cmd = COMMANDS.get(action)
    if cmd is None:
        return None
    return ["sudo", "-n", *cmd]


def _refused(action: str, sim: bool) -> dict:
    verb = _VERBS.get(action, "actuar")
    if sim:
        message = f"SIMULADO: no se va a {verb} esta máquina."
    else:
        message = (
            f"No se ha podido {verb}: hace falta una Raspberry Pi con ORBIT_POWER_LIVE=1. "
            "En el simulador y en un PC de desarrollo no se llama a systemctl."
        )
    return {"action": action, "ok": True, "dry_run": True, "simulated": sim, "message": message}


def default_runner(argv: list[str]) -> int:
    """Ejecuta la orden solo si el instalador dejó ORBIT_POWER_ALLOW_EXEC=1.

    Sin esa variable devuelve 126 y no llega a subprocess. Así un test o un
    PC de desarrollo no pueden apagar la máquina aunque el resto del código se equivoque.
    """
    if os.environ.get("ORBIT_POWER_ALLOW_EXEC") != "1":
        return 126
    return subprocess.run(argv, check=False).returncode


def run_power(action: str, *, live: bool, sim: bool, runner=None) -> dict:
    argv = argv_for(action)
    if argv is None:
        return {"action": action, "ok": False, "dry_run": True, "simulated": sim,
                "message": "Acción de energía desconocida."}
    if not live:
        return _refused(action, sim)
    code = (runner or default_runner)(argv)
    if code == 126 and os.environ.get("ORBIT_POWER_ALLOW_EXEC") != "1":
        return _refused(action, sim)
    if code == 0:
        hecho = "La Raspberry Pi se está apagando." if action == "pi.shutdown" else "La Raspberry Pi se está reiniciando."
        return {"action": action, "ok": True, "dry_run": False, "simulated": False, "message": hecho}
    return {"action": action, "ok": False, "dry_run": False, "simulated": False,
            "message": "No se ha podido. Revisa el permiso de apagado."}
