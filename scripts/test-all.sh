#!/usr/bin/env bash
# Lint + tests de todo el proyecto (lo mismo que .github/workflows/ci.yml).
set -euo pipefail
cd "$(dirname "$0")/.."
PY=${PYTHON:-.venv/bin/python}
"$PY" -m ruff check software tests
"$PY" -m pytest -q
(cd software/interface && npm run lint && npm test)
