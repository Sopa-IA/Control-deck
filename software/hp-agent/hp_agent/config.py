"""Carga de configuración: variables de entorno > archivo TOML local (fuera del repo) > valores por defecto."""
from __future__ import annotations

import os
import platform
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

try:
    import tomllib  # Python 3.11+
except ModuleNotFoundError:  # pragma: no cover
    tomllib = None  # type: ignore


def _as_bool(value: object) -> bool:
    if isinstance(value, str):
        return value.strip().lower() in {"1", "true", "yes", "si", "sí"}
    return bool(value)


def default_config_path() -> Path:
    if platform.system() == "Windows":
        return Path(os.environ.get("APPDATA", Path.home())) / "orbit" / "hp-agent.toml"
    return Path.home() / ".config" / "orbit" / "hp-agent.toml"


@dataclass
class AgentConfig:
    hub_url: str = "ws://127.0.0.1:8765/ws"
    token: Optional[str] = None
    telemetry_period_s: float = 2.0
    apps: dict[str, list[str]] = field(default_factory=dict)
    live: bool = False


def load(path: Optional[Path] = None, env: Optional[dict] = None) -> AgentConfig:
    env = os.environ if env is None else env
    cfg = AgentConfig()
    p = path or (Path(env["ORBIT_HP_CONFIG"]) if env.get("ORBIT_HP_CONFIG") else default_config_path())
    if p.exists() and tomllib is not None:
        data = tomllib.loads(p.read_text(encoding="utf-8"))
        cfg.hub_url = data.get("hub_url", cfg.hub_url)
        cfg.token = data.get("token") or None
        cfg.telemetry_period_s = float(data.get("telemetry_period_s", cfg.telemetry_period_s))
        cfg.apps = {k: list(v) for k, v in data.get("apps", {}).items()}
        if "live" in data:
            cfg.live = _as_bool(data.get("live"))
    if env.get("ORBIT_HUB_URL"):
        cfg.hub_url = env["ORBIT_HUB_URL"]
    if env.get("ORBIT_HP_TOKEN"):
        cfg.token = env["ORBIT_HP_TOKEN"]
    return cfg
