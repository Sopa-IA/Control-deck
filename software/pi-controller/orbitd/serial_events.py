"""Lectura de eventos del Arduino Nano de mandos (protocolo serie de PROTOCOLO.md §7) y simulador.

El Nano con CH340 se reinicia al abrir el puerto: el conversor pulsa DTR y eso
llega a RESET. Lo que se escriba durante el bootloader se pierde. Por eso, tras
abrir, se lee lo que ya llegue y solo se pide el saludo ('?') cuando ha pasado
NANO_RESET_WAIT_S. Esos 2 s no están medidos en el clon de Miguel.
"""
from __future__ import annotations

import asyncio
import logging
import random
import re
import threading
import time
from dataclasses import dataclass
from typing import Callable, Optional

log = logging.getLogger("orbitd.serial")

# [DISEÑO] Espera tras abrir el puerto, antes de escribir '?'. Cubre el bootloader
# nuevo (Optiboot) y el viejo (ATmegaBOOT) sin haber cronometrado este clon.
NANO_RESET_WAIT_S = 2.0

_RE_POT = re.compile(r"^P([1-9][0-9]?) (\d{1,4})$")
_RE_BTN = re.compile(r"^B([1-9][0-9]?) ([01L])$")
_RE_HELLO = re.compile(r"^H (\S+) (\S+) P(\d+) B(\d+)$")


@dataclass
class Hello:
    firmware: str
    version: str
    pots: int
    buttons: int


def parse_line(line: str, simulated: bool = False) -> Optional[dict | Hello]:
    """Convierte una línea serie en payload de control_event (dict), Hello, o None si es inválida."""
    line = line.strip()
    if not line:
        return None
    m = _RE_POT.match(line)
    if m:
        val = int(m.group(2))
        if val > 1023:
            return None
        return {"control": f"P{m.group(1)}", "kind": "pot", "value": val, "simulated": simulated}
    m = _RE_BTN.match(line)
    if m:
        ev = {"1": "press", "0": "release", "L": "long"}[m.group(2)]
        return {"control": f"B{m.group(1)}", "kind": "button", "event": ev, "simulated": simulated}
    m = _RE_HELLO.match(line)
    if m:
        return Hello(m.group(1), m.group(2), int(m.group(3)), int(m.group(4)))
    return None


class SerialReader:
    """Lee el puerto serie en un hilo y entrega líneas al bucle asyncio. Reintenta cada 2 s."""

    def __init__(self, port: str, baud: int, loop: asyncio.AbstractEventLoop,
                 on_line: Callable[[str], None], on_status: Callable[[bool, str], None],
                 reset_wait_s: float = NANO_RESET_WAIT_S, open_port: Optional[Callable[..., object]] = None):
        self.port, self.baud, self.loop = port, baud, loop
        self.on_line, self.on_status = on_line, on_status
        self.reset_wait_s = reset_wait_s
        self._open_port = open_port
        self._stop = threading.Event()
        self._thread = threading.Thread(target=self._run, name="orbitd-serial", daemon=True)

    def start(self) -> None:
        self._thread.start()

    def stop(self) -> None:
        self._stop.set()

    def _open(self):
        if self._open_port is not None:
            return self._open_port(self.port, self.baud, 0.5)
        import serial  # pyserial

        return serial.Serial(self.port, self.baud, timeout=0.5)

    def _run(self) -> None:
        while not self._stop.is_set():
            try:
                with self._open() as ser:
                    self.loop.call_soon_threadsafe(self.on_status, True, f"{self.port} @ {self.baud}")
                    # No escribir durante el reinicio. El saludo que el sketch manda
                    # al arrancar se lee igual; el '?' cubre el caso en que abrir el
                    # puerto no haya reiniciado la placa.
                    asked = self.reset_wait_s <= 0
                    deadline = time.monotonic() + max(0.0, self.reset_wait_s)
                    if asked:
                        ser.write(b"?\n")
                    while not self._stop.is_set():
                        if not asked and time.monotonic() >= deadline:
                            ser.write(b"?\n")
                            asked = True
                        raw = ser.readline()
                        if raw:
                            self.loop.call_soon_threadsafe(self.on_line, raw.decode("ascii", "replace"))
            except Exception as exc:  # puerto ausente, desconexión...
                self.loop.call_soon_threadsafe(self.on_status, False, f"{self.port}: {exc}")
                self._stop.wait(2.0)


class SimControls:
    """Genera líneas serie SIMULADAS (mismo formato que el firmware) para desarrollo sin Arduino."""

    def __init__(self, pots: int = 2, buttons: int = 2, seed: Optional[int] = None, press_buttons: bool = False):
        self.pots, self.buttons, self.press_buttons = pots, buttons, press_buttons
        self.rng = random.Random(seed)
        self.values = [512] * pots
        self._next_btn = time.monotonic() + 6

    def hello(self) -> str:
        return f"H orbit-controls-sim 1 P{self.pots} B{self.buttons}"

    def step(self) -> list[str]:
        out = []
        i = self.rng.randrange(self.pots)
        if self.rng.random() < 0.6:
            nv = max(0, min(1023, self.values[i] + self.rng.randint(-60, 60)))
            if abs(nv - self.values[i]) >= 4:
                self.values[i] = nv
                out.append(f"P{i + 1} {nv}")
        if self.press_buttons and time.monotonic() >= self._next_btn:
            b = self.rng.randrange(self.buttons) + 1
            out += [f"B{b} 1", f"B{b} 0"]
            self._next_btn = time.monotonic() + self.rng.uniform(5, 10)
        return out
