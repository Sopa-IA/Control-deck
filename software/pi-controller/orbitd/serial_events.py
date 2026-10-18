"""Lectura de eventos del Arduino Micro (protocolo serie de PROTOCOLO.md §7) y simulador."""
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
                 on_line: Callable[[str], None], on_status: Callable[[bool, str], None]):
        self.port, self.baud, self.loop = port, baud, loop
        self.on_line, self.on_status = on_line, on_status
        self._stop = threading.Event()
        self._thread = threading.Thread(target=self._run, name="orbitd-serial", daemon=True)

    def start(self) -> None:
        self._thread.start()

    def stop(self) -> None:
        self._stop.set()

    def _run(self) -> None:
        import serial  # pyserial

        while not self._stop.is_set():
            try:
                with serial.Serial(self.port, self.baud, timeout=0.5) as ser:
                    self.loop.call_soon_threadsafe(self.on_status, True, f"{self.port} @ {self.baud}")
                    ser.write(b"?\n")
                    while not self._stop.is_set():
                        raw = ser.readline()
                        if raw:
                            self.loop.call_soon_threadsafe(self.on_line, raw.decode("ascii", "replace"))
            except Exception as exc:  # puerto ausente, desconexión...
                self.loop.call_soon_threadsafe(self.on_status, False, f"{self.port}: {exc}")
                self._stop.wait(2.0)


class SimControls:
    """Genera líneas serie SIMULADAS (mismo formato que el firmware) para desarrollo sin Arduino."""

    def __init__(self, pots: int = 3, buttons: int = 4, seed: Optional[int] = None, press_buttons: bool = False):
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
