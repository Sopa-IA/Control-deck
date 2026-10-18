"""CLI de orbitd.  Ejemplo:  python -m orbitd --sim --static ../interface/dist"""
from __future__ import annotations

import argparse
import logging
import os
from pathlib import Path

from aiohttp import web

from .hub import Config, build_app
from .video import VideoConfig


def main(argv: list[str] | None = None) -> None:
    ap = argparse.ArgumentParser(prog="orbitd", description="Hub de Orbit Terminal (Raspberry Pi)")
    ap.add_argument("--host", default=os.environ.get("ORBIT_HOST", "127.0.0.1"))
    ap.add_argument("--port", type=int, default=int(os.environ.get("ORBIT_PORT", "8765")))
    ap.add_argument("--static", type=Path, default=None, help="carpeta dist/ de la interfaz")
    ap.add_argument("--state-dir", type=Path, default=None)
    ap.add_argument("--serial", default=os.environ.get("ORBIT_SERIAL"), help="p.ej. /dev/ttyACM0 (Arduino Micro)")
    ap.add_argument("--baud", type=int, default=115200)
    ap.add_argument("--sim", action="store_true", help="simula HP y controles")
    ap.add_argument("--sim-hp", action="store_true")
    ap.add_argument("--sim-controls", action="store_true")
    ap.add_argument("--sim-buttons", action="store_true", help="con controles simulados, pulsa botones al azar")
    ap.add_argument("-v", "--verbose", action="store_true")
    a = ap.parse_args(argv)
    logging.basicConfig(level=logging.DEBUG if a.verbose else logging.INFO, format="%(asctime)s %(name)s %(levelname)s %(message)s")
    cfg = Config(host=a.host, port=a.port, static_dir=a.static, serial_port=a.serial, serial_baud=a.baud,
                 hp_token=os.environ.get("ORBIT_HP_TOKEN") or None, ui_token=os.environ.get("ORBIT_UI_TOKEN") or None,
                 sim_hp=a.sim or a.sim_hp, sim_controls=a.sim or a.sim_controls, sim_buttons=a.sim_buttons,
                 video=VideoConfig.from_env())
    if a.state_dir:
        cfg.state_dir = a.state_dir
    cfg.check()
    logging.getLogger("orbitd").info("orbitd en http://%s:%d (modo HP %s, controles %s)", cfg.host, cfg.port,
                                     "SIMULADO" if cfg.sim_hp else "real", "SIMULADOS" if cfg.sim_controls else "reales")
    web.run_app(build_app(cfg), host=cfg.host, port=cfg.port, print=None)


if __name__ == "__main__":
    main()
