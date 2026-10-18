#!/usr/bin/env bash
# ORBIT TERMINAL · renders fotorrealistas (Blender + Cycles) del prototipo con las piezas de Miguel.
# Requisitos: openscad, freecadcmd, Blender >= 4.2 con OpenImageDenoise (el paquete de Debian no lo trae:
# usar el binario oficial de blender.org y pasarlo en BLENDER=...), python3 + Pillow.
set -e
cd "$(dirname "$0")"
BLENDER=${BLENDER:-blender}
T=${T:-/tmp/orbit-render}
OUT=../../assets/renders/prototipo
OUT=$T/stl ./exportar_partes.sh > /dev/null
DEST=$T ./descargar_modelos.sh
python3 etiqueta_hdd.py "$T/etiqueta_hdd.png"
"$BLENDER" -b -P escena_blender.py -- --stl "$T/stl" --pi "$T/pi_parts" --label "$T/etiqueta_hdd.png" \
  --out "$T/raw" --samples "${SAMPLES:-128}" ${VISTAS:+--vistas $VISTAS}
python3 postproceso.py "$T/raw" "$OUT" ${FOTOS:+"$FOTOS"}
