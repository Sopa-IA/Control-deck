#!/usr/bin/env bash
# Exporta las piezas del CAD a STL (mm, coordenadas de montaje) para el render en Blender.
# Configuración del prototipo de Miguel: HDD 3,5" (usar_hdd_35), modo C con capturadora,
# sin hueco del adaptador HDMI->USB-C (usar_adaptador_video=false).
set -e
cd "$(dirname "$0")"
OUT=${OUT:-/tmp/orbit-render/stl}
mkdir -p "$OUT"
DEFS=(-D usar_hdd_35=true -D usar_capturadora=true -D usar_adaptador_video=false)
openscad -o "$OUT/params.echo" "${DEFS[@]}" -D 'parte="params"' partes_render.scad 2>/dev/null
PARTES="carcasa base bisel bandeja sop_ard sop_disco guias tira_led monitor pomos marca_pomo anillos boton_brida boton_cuerpo boton_tapa mandos_int separadores io_frontal boton_hp cables pies captura_cuerpo captura_clavija captura_reserva"
for p in $PARTES; do
  openscad -o "$OUT/$p.stl" "${DEFS[@]}" -D "parte=\"$p\"" partes_render.scad > "$OUT/$p.log" 2>&1 &
  while [ "$(jobs -r | wc -l)" -ge "${JOBS:-4}" ]; do sleep 0.5; done
done
wait
ls -la "$OUT"
