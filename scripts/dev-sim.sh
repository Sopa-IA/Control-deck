#!/usr/bin/env bash
# Compila la interfaz y arranca orbitd en modo simulación sirviéndola en http://127.0.0.1:8765/
set -euo pipefail
cd "$(dirname "$0")/.."
PY=${PYTHON:-.venv/bin/python}
(cd software/interface && npm run build)
exec "$PY" -m orbitd --sim --static software/interface/dist "$@"
