"""Orbit Terminal · protocolo compartido v1 (sobre JSON por WebSocket).

Fuente de verdad: ../schemas/protocol.schema.json y ../actions.json.
Instalar en modo editable (pip install -e software/shared/python) para que
encuentre esos archivos.
"""
from __future__ import annotations

import json
import secrets
import time
import uuid
from pathlib import Path
from typing import Any

import jsonschema

PROTOCOL_VERSION = 1
SHARED_DIR = Path(__file__).resolve().parents[2]
SCHEMA_PATH = SHARED_DIR / "schemas" / "protocol.schema.json"
ACTIONS_PATH = SHARED_DIR / "actions.json"
DEFAULT_MAPPING_PATH = SHARED_DIR / "controls.default.json"

HEARTBEAT_S = 5.0          # orbitd envía ping cada 5 s
HEARTBEAT_TIMEOUT_S = 15.0  # sin pong en 15 s -> cliente desconectado
CONFIRM_TTL_S = 15.0        # validez del desafío de confirmación
MAX_MESSAGE_BYTES = 16 * 1024

_schema = json.loads(SCHEMA_PATH.read_text(encoding="utf-8"))
_validator = jsonschema.Draft202012Validator(_schema)
ACTIONS: dict[str, dict[str, Any]] = json.loads(ACTIONS_PATH.read_text(encoding="utf-8"))["actions"]
CONTROL_FUNCTIONS: dict[str, dict[str, Any]] = {
    k: v for k, v in json.loads(ACTIONS_PATH.read_text(encoding="utf-8"))["control_functions"].items()
    if not k.startswith("$")
}


class ProtocolError(ValueError):
    """Mensaje inválido o acción no permitida. `code` sigue el enum de error del esquema."""

    def __init__(self, code: str, message: str):
        super().__init__(message)
        self.code = code
        self.message = message


def now_ms() -> int:
    return int(time.time() * 1000)


def make(type_: str, src: str, payload: dict[str, Any] | None = None, reply_to: str | None = None) -> dict[str, Any]:
    """Construye un mensaje válido (lanza ProtocolError si no cumple el esquema)."""
    msg: dict[str, Any] = {"v": PROTOCOL_VERSION, "type": type_, "id": uuid.uuid4().hex[:16],
                           "ts": now_ms(), "src": src, "payload": payload or {}}
    if reply_to:
        msg["reply_to"] = reply_to
    validate(msg)
    return msg


def validate(msg: Any) -> dict[str, Any]:
    errors = sorted(_validator.iter_errors(msg), key=lambda e: list(e.path))
    if errors:
        e = errors[0]
        where = "/".join(str(p) for p in e.path) or "(raíz)"
        raise ProtocolError("bad_message", f"{where}: {e.message}"[:500])
    return msg


def parse(raw: str | bytes) -> dict[str, Any]:
    if len(raw) > MAX_MESSAGE_BYTES:
        raise ProtocolError("bad_message", "mensaje demasiado grande")
    try:
        msg = json.loads(raw)
    except (json.JSONDecodeError, UnicodeDecodeError) as exc:
        raise ProtocolError("bad_message", f"JSON inválido: {exc}") from exc
    return validate(msg)


def check_action(action: str, params: dict[str, Any] | None, target: str | None = None) -> dict[str, Any]:
    """Comprueba la acción contra la lista blanca y valida sus parámetros.
    Devuelve la definición de la acción. Nunca ejecuta nada."""
    spec = ACTIONS.get(action)
    if spec is None:
        raise ProtocolError("not_allowed", f"acción no permitida: {action}")
    if target is not None and spec["target"] != target:
        raise ProtocolError("not_allowed", f"{action} no corresponde a {target}")
    params = params or {}
    pschema = {"type": "object", "properties": spec["params"], "required": list(spec["params"].keys()),
               "additionalProperties": False}
    errs = list(jsonschema.Draft202012Validator(pschema).iter_errors(params))
    if errs:
        raise ProtocolError("bad_params", f"{action}: {errs[0].message}"[:500])
    return spec


def check_mapping(mapping: dict[str, Any]) -> dict[str, Any]:
    """Valida una asignación de controles: cada función debe existir y admitir el tipo de control."""
    for group, kind in (("pots", "pot"), ("buttons", "button")):
        for control, fn in mapping.get(group, {}).items():
            spec = CONTROL_FUNCTIONS.get(fn)
            if spec is None:
                raise ProtocolError("bad_params", f"función desconocida para {control}: {fn}")
            if kind not in spec["kinds"]:
                raise ProtocolError("bad_params", f"{fn} no se puede asignar a un {kind} ({control})")
    return mapping


def load_default_mapping() -> dict[str, Any]:
    m = json.loads(DEFAULT_MAPPING_PATH.read_text(encoding="utf-8"))
    return {"version": m.get("version", 1), "pots": m["pots"], "buttons": m["buttons"]}


def new_challenge() -> str:
    return secrets.token_hex(8)


def tokens_equal(a: str | None, b: str | None) -> bool:
    """Comparación en tiempo constante; un token vacío o ausente nunca es válido."""
    if not a or not b:
        return False
    return secrets.compare_digest(a.encode(), b.encode())
