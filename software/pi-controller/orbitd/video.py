"""Cambio del «sistema visible» (HP / Pi) en la pantalla MSI, siempre desde Orbit OS.

Requisito: Miguel nunca toca el menú OSD del monitor. Dos modos:

* ``remoto`` (modo A, BASE, siempre disponible): la MSI muestra SIEMPRE la Pi. Ver el HP
  significa abrir en la Pi un visor de escritorio remoto del HP por el Ethernet interno
  (p. ej. Moonlight contra Sunshine en el HP). La orden del visor se configura con
  ``ORBIT_REMOTE_CMD`` (la escribe el instalador, nunca la interfaz). Sin orden configurada
  el cambio se registra y la interfaz muestra su propio panel «HP», pero no se lanza nada.
* ``ddc`` (modo B, OPCIONAL, imagen directa): la Pi cambia la entrada de la MSI por DDC/CI
  (``ddcutil setvcp 60 <valor>``). El HP entra por Mini-HDMI y la Pi por USB-C con un
  adaptador HDMI->USB-C (DP Alt). NI el adaptador NI el soporte DDC/CI de la MSI están
  verificados; los valores VCP 0x60 de cada entrada son PENDIENTES (``ddcutil capabilities``).
  Si ddcutil falla, se vuelve al modo A automáticamente.

No se miden ni se prometen latencias.
"""
from __future__ import annotations

import asyncio
import logging
import os
import re
import shlex
import shutil
from dataclasses import dataclass, field
from typing import Optional

log = logging.getLogger("orbitd.video")

_VCP_RE = re.compile(r"^(0x)?[0-9a-fA-F]{1,2}$")


@dataclass
class VideoConfig:
    ddc_enabled: bool = False          # ORBIT_VIDEO_DDC=1
    ddc_value_hp: Optional[str] = None  # ORBIT_DDC_HP, valor VCP 0x60 de la entrada Mini-HDMI [PENDIENTE]
    ddc_value_pi: Optional[str] = None  # ORBIT_DDC_PI, valor VCP 0x60 de la entrada USB-C del adaptador [PENDIENTE]
    ddc_bus: Optional[str] = None       # ORBIT_DDC_BUS (número de bus I2C; opcional)
    remote_cmd: list[str] = field(default_factory=list)  # ORBIT_REMOTE_CMD
    timeout_s: float = 10.0

    @classmethod
    def from_env(cls, env: Optional[dict] = None) -> "VideoConfig":
        e = os.environ if env is None else env
        cmd = e.get("ORBIT_REMOTE_CMD", "").strip()
        return cls(ddc_enabled=e.get("ORBIT_VIDEO_DDC", "0") == "1",
                   ddc_value_hp=e.get("ORBIT_DDC_HP") or None,
                   ddc_value_pi=e.get("ORBIT_DDC_PI") or None,
                   ddc_bus=e.get("ORBIT_DDC_BUS") or None,
                   remote_cmd=shlex.split(cmd) if cmd else [])


class VideoSwitcher:
    def __init__(self, cfg: VideoConfig):
        self.cfg = cfg
        self.visible = "pi"           # al arrancar, la MSI muestra Orbit OS
        self.last_mode = self.mode()
        self.detail = "Orbit OS visible"
        self._viewer: Optional[asyncio.subprocess.Process] = None

    # -------------------------------------------------------------- modo
    def ddc_ready(self) -> bool:
        c = self.cfg
        return (c.ddc_enabled and shutil.which("ddcutil") is not None
                and all(v is not None and _VCP_RE.match(v) for v in (c.ddc_value_hp, c.ddc_value_pi))
                and (c.ddc_bus is None or c.ddc_bus.isdigit()))

    def mode(self) -> str:
        return "ddc" if self.ddc_ready() else "remoto"

    def state(self) -> dict:
        return {"system": self.visible, "mode": self.last_mode, "detail": self.detail[:200]}

    # ---------------------------------------------------------- acciones
    async def switch(self, target: Optional[str] = None) -> dict:
        """Cambia al sistema indicado (o alterna). Devuelve el resultado para action_result."""
        target = target or ("hp" if self.visible == "pi" else "pi")
        if self.mode() == "ddc":
            ok, msg = await self._ddc(target)
            if ok:
                await self._stop_viewer()   # en modo B no hace falta visor
                self.visible, self.last_mode = target, "ddc"
                self.detail = f"Entrada de la MSI cambiada por DDC/CI a {'HP' if target == 'hp' else 'Pi'}"
                return self._res(True, False, self.detail)
            log.warning("DDC/CI falló (%s): se usa el modo remoto", msg)
            # si la MSI quedó en otra entrada, intenta devolverla a la Pi antes de seguir
            if target == "hp":
                await self._ddc("pi")
            fallback = f"DDC/CI no disponible ({msg}); "
        else:
            fallback = ""
        ok, dry, msg = await self._remote(target)
        self.visible, self.last_mode = target, "remoto"
        self.detail = fallback + msg
        return self._res(ok, dry, self.detail)

    def _res(self, ok: bool, dry: bool, message: str) -> dict:
        return {"action": "pi.switch_visible", "ok": ok, "dry_run": dry, "simulated": False,
                "message": message[:500]}

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

    async def _remote(self, target: str) -> tuple[bool, bool, str]:
        if target == "pi":
            await self._stop_viewer()
            return True, False, "Orbit OS visible (visor remoto del HP cerrado)"
        if not self.cfg.remote_cmd:
            return True, True, ("HP en modo remoto: visor sin configurar (ORBIT_REMOTE_CMD, p. ej. Moonlight); "
                                "la interfaz muestra el panel del HP. PENDIENTE de instalar Sunshine/Moonlight.")
        if self._viewer is not None and self._viewer.returncode is None:
            return True, False, "Visor remoto del HP ya abierto"
        try:
            self._viewer = await asyncio.create_subprocess_exec(
                *self.cfg.remote_cmd, stdout=asyncio.subprocess.DEVNULL, stderr=asyncio.subprocess.DEVNULL)
        except OSError as exc:
            return False, False, f"No se pudo abrir el visor remoto: {exc.strerror or exc}"
        return True, False, "Visor remoto del HP abierto (escritorio del HP por Ethernet interno)"

    async def _stop_viewer(self) -> None:
        v, self._viewer = self._viewer, None
        if v is None or v.returncode is not None:
            return
        v.terminate()
        try:
            await asyncio.wait_for(v.wait(), 5)
        except asyncio.TimeoutError:
            v.kill()

    async def close(self) -> None:
        await self._stop_viewer()
