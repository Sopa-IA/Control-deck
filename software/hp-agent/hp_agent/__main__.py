"""CLI de hp-agent.  Por defecto en DRY-RUN; --live para ejecutar órdenes reales."""
from __future__ import annotations

import argparse
import asyncio
import json
import logging
import os
import platform
import sys
from logging.handlers import RotatingFileHandler
from pathlib import Path

from . import config as config_mod
from .agent import run_forever, telemetry


class _Redact(logging.Filter):
    """Si un mensaje llevara el token, lo tapa. El token no se registra a propósito."""

    def __init__(self, secret: str) -> None:
        super().__init__()
        self._secret = secret

    def filter(self, record: logging.LogRecord) -> bool:
        if not self._secret:
            return True
        rendered = record.getMessage()
        if self._secret not in rendered:
            return True
        record.msg = rendered.replace(self._secret, "***")
        record.args = ()
        return True


def configure_logging(verbose: bool) -> None:
    level = logging.DEBUG if verbose else logging.INFO
    handlers: list[logging.Handler] = []
    # pythonw.exe no tiene consola: stderr es None y un StreamHandler petaría.
    if sys.stderr is not None:
        handlers.append(logging.StreamHandler())
    if platform.system() == "Windows":
        folder = Path(os.environ.get("LOCALAPPDATA", str(Path.home()))) / "orbit"
        try:
            folder.mkdir(parents=True, exist_ok=True)
            handlers.append(RotatingFileHandler(
                folder / "hp-agent.log", maxBytes=512_000, backupCount=2, encoding="utf-8"))
        except OSError:
            pass
    logging.basicConfig(level=level, format="%(asctime)s %(name)s %(levelname)s %(message)s",
                        handlers=handlers or None)


def main(argv: list[str] | None = None) -> None:
    ap = argparse.ArgumentParser(prog="orbit-hp-agent")
    ap.add_argument("--config", type=Path, default=None)
    ap.add_argument("--hub", default=None, help="URL ws:// de orbitd (sobrescribe la config)")
    ap.add_argument("--live", action="store_true", help="ejecuta órdenes reales (por defecto: dry-run, o live del toml)")
    ap.add_argument("--once-telemetry", action="store_true", help="imprime una lectura de telemetría y sale")
    ap.add_argument("-v", "--verbose", action="store_true")
    a = ap.parse_args(argv)
    configure_logging(a.verbose)
    if a.once_telemetry:
        print(json.dumps(telemetry(), indent=2, ensure_ascii=False))
        return
    cfg = config_mod.load(a.config)
    if a.hub:
        cfg.hub_url = a.hub
    # Sin --live se respeta el toml (el instalador escribe live ahí). --live solo lo enciende.
    if a.live:
        cfg.live = True
    if cfg.token:
        logging.getLogger().addFilter(_Redact(cfg.token))
    if not cfg.token:
        raise SystemExit("hp-agent: falta el token (ORBIT_HP_TOKEN o 'token' en el archivo de configuración local)")
    asyncio.run(run_forever(cfg))


if __name__ == "__main__":
    main()
