#!/usr/bin/env bash
# Genera tokens aleatorios (ORBIT_HP_TOKEN y ORBIT_UI_TOKEN) y los guarda en .env (ignorado por git).
# ORBIT_HP_TOKEN debe configurarse también en el HP (variable de entorno o %APPDATA%\orbit\hp-agent.toml).
# Uso: scripts/gen-token.sh [--force]   (sin --force no sobrescribe tokens existentes)
set -euo pipefail
cd "$(dirname "$0")/.."
touch .env && chmod 600 .env
for VAR in ORBIT_HP_TOKEN ORBIT_UI_TOKEN; do
  if grep -q "^$VAR=." .env && [ "${1:-}" != "--force" ]; then
    echo "$VAR ya existe en .env (usa --force para regenerarlo)"; continue
  fi
  T=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
  { grep -v "^$VAR=" .env || true; echo "$VAR=$T"; } > .env.tmp && mv .env.tmp .env && chmod 600 .env
  echo "$VAR generado"
done
echo "Tokens en $(pwd)/.env (no se suben al repositorio). Copia ORBIT_HP_TOKEN al HP por un canal seguro."
