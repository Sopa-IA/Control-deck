"""Potenciómetros del Nano de mandos.

A0 y A1 pueden estar al aire. Una entrada flotante salta de un lado a otro y no
debe publicar ni disparar acciones. Un giro de verdad se asienta y solo entonces
cambia el valor, con una zona muerta del 3 % y sin repetir el mismo nivel.
"""
from __future__ import annotations

from dataclasses import dataclass

ADC_MAX = 1023
DEADBAND = 31  # 3 % de 1023: un 6 % y un 7 % no son un giro
CONFIRM = 3
WINDOW = 12
AGREE = 20
FLOAT_SPAN = 80
FLOAT_REVERSALS = 3

# Asignación de fábrica anterior. Al pasar a la versión 2 esos pots quedan en none
# una sola vez. Lo que el usuario guarde después, con version >= 2, se respeta.
FACTORY_POTS_V1 = {"P1": "hp.volume_set", "P2": "ui.scroll"}


@dataclass(frozen=True)
class PotDecision:
    show: int | None
    act: bool
    level: int | None


class PotGate:
    def __init__(self) -> None:
        self._shown: dict[str, int] = {}
        self._window: dict[str, list[int]] = {}
        self._last_level: dict[str, int] = {}

    def feed(self, control: str, raw: int) -> PotDecision:
        raw = max(0, min(ADC_MAX, int(raw)))
        window = self._window.setdefault(control, [])
        window.append(raw)
        del window[:-WINDOW]
        if _flotante(window) or len(window) < CONFIRM:
            return PotDecision(None, False, None)
        tail = window[-CONFIRM:]
        if max(tail) - min(tail) > AGREE:
            return PotDecision(None, False, None)
        settled = int(round(sum(tail) / len(tail)))
        level = int(round(settled * 100 / ADC_MAX))
        shown = self._shown.get(control)
        if shown is None:
            self._shown[control] = settled
            self._last_level[control] = level
            return PotDecision(settled, False, None)
        if abs(settled - shown) < DEADBAND:
            return PotDecision(None, False, None)
        self._shown[control] = settled
        if self._last_level.get(control) == level:
            return PotDecision(settled, False, None)
        self._last_level[control] = level
        return PotDecision(settled, True, level)


def _flotante(window: list[int]) -> bool:
    if len(window) < 8:
        return False
    if max(window) - min(window) < FLOAT_SPAN:
        return False
    reversals = 0
    prev = 0
    for a, b in zip(window, window[1:]):
        delta = b - a
        if abs(delta) < 15:
            continue
        sign = 1 if delta > 0 else -1
        if prev and sign != prev:
            reversals += 1
        prev = sign
    return reversals >= FLOAT_REVERSALS


def normalize_mapping(raw: dict) -> tuple[dict, bool]:
    """Sube un controls.json viejo a la versión 2 sin borrar botones ni una asignación ya elegida."""
    pots = dict(raw.get("pots") or {})
    buttons = dict(raw.get("buttons") or {})
    try:
        version = int(raw.get("version") or 1)
    except (TypeError, ValueError):
        version = 1
    changed = False
    if version < 2:
        for pot, fn in FACTORY_POTS_V1.items():
            if pots.get(pot) == fn:
                pots[pot] = "none"
        version = 2
        changed = True
    return {"version": version, "pots": pots, "buttons": buttons}, changed
