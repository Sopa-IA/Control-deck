"""Cambio del «sistema visible» (HP / Pi) en la pantalla MSI, siempre desde Orbit OS.

Requisito: Miguel nunca toca el menú OSD del monitor; la Pi lo controla todo. Tres modos:

* ``remoto`` (modo A, BASE, siempre disponible): la MSI muestra SIEMPRE la Pi. Ver el HP
  significa abrir en la Pi un visor de escritorio remoto del HP por el Ethernet interno
  (p. ej. Moonlight contra Sunshine en el HP). La orden del visor se configura con
  ``ORBIT_REMOTE_CMD`` (la escribe el instalador, nunca la interfaz). Sin orden configurada
  el cambio se registra y la interfaz muestra su propio panel «HP», pero no se lanza nada.
* ``ddc`` (modo B, OPCIONAL, imagen directa): la Pi cambia la entrada de la MSI por DDC/CI
  (``ddcutil setvcp 60 <valor>``). El HP entra por Mini-HDMI y la Pi por USB-C con un
  adaptador HDMI->USB-C (DP Alt). NI el adaptador NI el soporte DDC/CI de la MSI están
  verificados; los valores VCP 0x60 de cada entrada son PENDIENTES (``ddcutil capabilities``).
  Si ddcutil falla, se vuelve al modo C (si está configurado) o al A automáticamente.
  Poco probable: los manuales de la MSI no documentan DDC/CI.
* ``captura`` (modo C, RECOMENDADO junto al A): el HDMI del HP entra en una capturadora
  HDMI->USB (UVC) conectada a la Pi; la MSI muestra SIEMPRE la Pi y ver el HP significa
  abrir un visor de vídeo del dispositivo de captura (p. ej. ``/dev/video0``). Se configura
  en local con ``ORBIT_CAPTURE_DEVICE`` y ``ORBIT_CAPTURE_CMD`` (orden sin shell; el
  elemento literal ``{device}`` se sustituye por el dispositivo). Teclado y ratón van al HP
  por separado. Si el dispositivo no existe o el visor no arranca, se vuelve al modo A.

Prioridad: ddc (si está listo) > captura (si está configurada) > remoto.
No se miden ni se prometen latencias ni fps (PENDIENTE de medir con el hardware real).
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
# Solo nodos V4L2: /dev/videoN o enlaces estables /dev/v4l/by-id|by-path/<nombre>
_DEV_RE = re.compile(r"^/dev/(video[0-9]{1,3}|v4l/by-(id|path)/[A-Za-z0-9._:+-]{1,200})$")


@dataclass
class VideoConfig:
    ddc_enabled: bool = False          # ORBIT_VIDEO_DDC=1
    ddc_value_hp: Optional[str] = None  # ORBIT_DDC_HP, valor VCP 0x60 de la entrada Mini-HDMI [PENDIENTE]
    ddc_value_pi: Optional[str] = None  # ORBIT_DDC_PI, valor VCP 0x60 de la entrada USB-C del adaptador [PENDIENTE]
    ddc_bus: Optional[str] = None       # ORBIT_DDC_BUS (número de bus I2C; opcional)
    remote_cmd: list[str] = field(default_factory=list)  # ORBIT_REMOTE_CMD
    capture_device: Optional[str] = None                # ORBIT_CAPTURE_DEVICE (p. ej. /dev/video0)
    capture_cmd: list[str] = field(default_factory=list)  # ORBIT_CAPTURE_CMD (visor; {device} se sustituye)
    timeout_s: float = 10.0

    @classmethod
    def from_env(cls, env: Optional[dict] = None) -> "VideoConfig":
        e = os.environ if env is None else env
        cmd = e.get("ORBIT_REMOTE_CMD", "").strip()
        ccmd = e.get("ORBIT_CAPTURE_CMD", "").strip()
        return cls(ddc_enabled=e.get("ORBIT_VIDEO_DDC", "0") == "1",
                   ddc_value_hp=e.get("ORBIT_DDC_HP") or None,
                   ddc_value_pi=e.get("ORBIT_DDC_PI") or None,
                   ddc_bus=e.get("ORBIT_DDC_BUS") or None,
                   remote_cmd=shlex.split(cmd) if cmd else [],
                   capture_device=e.get("ORBIT_CAPTURE_DEVICE", "").strip() or None,
                   capture_cmd=shlex.split(ccmd) if ccmd else [])


class VideoSwitcher:
    def __init__(self, cfg: VideoConfig):
        self.cfg = cfg
        self.visible = "pi"           # al arrancar, la MSI muestra Orbit OS
        self.last_mode = self.mode()
        self.detail = "Orbit OS visible"
        self._viewer: Optional[asyncio.subprocess.Process] = None
        self._viewer_kind: Optional[str] = None   # "remoto" | "captura"

    # -------------------------------------------------------------- modo
    def ddc_ready(self) -> bool:
        c = self.cfg
        return (c.ddc_enabled and shutil.which("ddcutil") is not None
                and all(v is not None and _VCP_RE.match(v) for v in (c.ddc_value_hp, c.ddc_value_pi))
                and (c.ddc_bus is None or c.ddc_bus.isdigit()))

    def capture_configured(self) -> bool:
        """Modo C configurado: dispositivo V4L2 con nombre válido y orden de visor."""
        c = self.cfg
        return bool(c.capture_cmd) and c.capture_device is not None and _DEV_RE.match(c.capture_device) is not None

    def capture_argv(self) -> list[str]:
        dev = self.cfg.capture_device or ""
        return [a.replace("{device}", dev) for a in self.cfg.capture_cmd]

    def mode(self) -> str:
        if self.ddc_ready():
            return "ddc"
        return "captura" if self.capture_configured() else "remoto"

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
            log.warning("DDC/CI falló (%s): se usa el modo captura o remoto", msg)
            # si la MSI quedó en otra entrada, intenta devolverla a la Pi antes de seguir
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
                return self._res(True, False, self.detail)
            log.warning("Captura no disponible (%s): se usa el modo remoto", msg)
            fallback += f"Captura no disponible ({msg}); "
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

    async def _capture(self, target: str) -> tuple[bool, str]:
        """Modo C: abre/cierra el visor de la capturadora. La MSI sigue en la Pi."""
        if target == "pi":
            await self._stop_viewer()
            return True, "Orbit OS visible (visor de la capturadora cerrado)"
        dev = self.cfg.capture_device or ""
        if not os.path.exists(dev):
            return False, f"no existe {dev}"
        if self._viewer is not None and self._viewer.returncode is None:
            if self._viewer_kind == "captura":
                return True, "Visor de la capturadora ya abierto"
            await self._stop_viewer()
        try:
            self._viewer = await asyncio.create_subprocess_exec(
                *self.capture_argv(), stdout=asyncio.subprocess.DEVNULL, stderr=asyncio.subprocess.DEVNULL)
        except OSError as exc:
            self._viewer = None
            return False, f"no se pudo abrir el visor: {exc.strerror or exc.__class__.__name__}"
        self._viewer_kind = "captura"
        return True, f"HP visible por la capturadora HDMI->USB ({dev}); teclado y ratón van al HP"

    async def _remote(self, target: str) -> tuple[bool, bool, str]:
        if target == "pi":
            await self._stop_viewer()
            return True, False, "Orbit OS visible (visor remoto del HP cerrado)"
        if not self.cfg.remote_cmd:
            return True, True, ("HP en modo remoto: visor sin configurar (ORBIT_REMOTE_CMD, p. ej. Moonlight); "
                                "la interfaz muestra el panel del HP. PENDIENTE de instalar Sunshine/Moonlight.")
        if self._viewer is not None and self._viewer.returncode is None:
            if self._viewer_kind == "remoto":
                return True, False, "Visor remoto del HP ya abierto"
            await self._stop_viewer()
        try:
            self._viewer = await asyncio.create_subprocess_exec(
                *self.cfg.remote_cmd, stdout=asyncio.subprocess.DEVNULL, stderr=asyncio.subprocess.DEVNULL)
        except OSError as exc:
            self._viewer = None
            return False, False, f"No se pudo abrir el visor remoto: {exc.strerror or exc}"
        self._viewer_kind = "remoto"
        return True, False, "Visor remoto del HP abierto (escritorio del HP por Ethernet interno)"

    async def _stop_viewer(self) -> None:
        v, self._viewer, self._viewer_kind = self._viewer, None, None
        if v is None or v.returncode is not None:
            return
        v.terminate()
        try:
            await asyncio.wait_for(v.wait(), 5)
        except asyncio.TimeoutError:
            v.kill()

    async def close(self) -> None:
        await self._stop_viewer()
