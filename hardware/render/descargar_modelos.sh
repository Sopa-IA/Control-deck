#!/usr/bin/env bash
# Descarga los modelos 3D de terceros usados en el render (NO se guardan en el repo; ver CREDITOS-MODELOS.md)
# y convierte la Raspberry Pi 4 (STEP) a STL por piezas con FreeCAD.
set -e
DEST=${DEST:-/tmp/orbit-render}
mkdir -p "$DEST/modelos"
# Raspberry Pi 4 Model B · Innerscene 3D Parts Library · CC0 1.0 (reconstrucción a partir del plano oficial)
# https://www.innerscene.com/tools/library/3d-parts/raspberry-pi-4-model-b-layout-821bd96d
[ -s "$DEST/modelos/raspberry-pi-4.step" ] || curl -fsSL -o "$DEST/modelos/raspberry-pi-4.step" \
  "https://www.innerscene.com/api/library/raspberry-pi-4-model-b-layout-821bd96d/download"
sha256sum "$DEST/modelos/raspberry-pi-4.step"
freecadcmd "$(dirname "$0")/convertir_step.py" "$DEST/modelos/raspberry-pi-4.step" "$DEST/pi_parts" 2>/dev/null | grep -a "^PIEZAS" || true
