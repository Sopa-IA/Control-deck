#!/usr/bin/env bash
# Prepara el entorno de desarrollo: venv de Python con los tres paquetes y dependencias de la interfaz.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 -m venv .venv
. .venv/bin/activate
pip install -q --upgrade pip
pip install -q -e software/shared/python -e software/pi-controller -e software/hp-agent pytest pytest-asyncio ruff
(cd software/interface && npm ci)
echo "Listo. Activa el entorno con: . .venv/bin/activate"
