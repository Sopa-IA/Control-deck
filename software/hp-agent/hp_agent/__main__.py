"""CLI de hp-agent.  Por defecto en DRY-RUN; --live para ejecutar órdenes reales."""
from __future__ import annotations

import argparse
import asyncio
import json
import logging
from pathlib import Path

from . import config as config_mod
from .agent import run_forever, telemetry


def main(argv: list[str] | None = None) -> None:
    ap = argparse.ArgumentParser(prog="orbit-hp-agent")
    ap.add_argument("--config", type=Path, default=None)
    ap.add_argument("--hub", default=None, help="URL ws:// de orbitd (sobrescribe la config)")
    ap.add_argument("--live", action="store_true", help="ejecuta órdenes reales (por defecto: dry-run)")
    ap.add_argument("--once-telemetry", action="store_true", help="imprime una lectura de telemetría y sale")
    ap.add_argument("-v", "--verbose", action="store_true")
    a = ap.parse_args(argv)
    logging.basicConfig(level=logging.DEBUG if a.verbose else logging.INFO, format="%(asctime)s %(name)s %(levelname)s %(message)s")
    if a.once_telemetry:
        print(json.dumps(telemetry(), indent=2, ensure_ascii=False))
        return
    cfg = config_mod.load(a.config)
    if a.hub:
        cfg.hub_url = a.hub
    cfg.live = a.live
    if not cfg.token:
        raise SystemExit("hp-agent: falta el token (ORBIT_HP_TOKEN o 'token' en el archivo de configuración local)")
    asyncio.run(run_forever(cfg))


if __name__ == "__main__":
    main()
