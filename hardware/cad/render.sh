#!/usr/bin/env bash
# ORBIT TERMINAL · genera los renders PNG (vista previa OpenCSG, no fotorrealista)
set -e
cd "$(dirname "$0")"
OUT=../../assets/renders
mkdir -p "$OUT"
r() { # nombre vista cam [extra...]
  local n=$1 v=$2 cam=$3; shift 3
  local va="--viewall --autocenter"; [ "${VIEWALL:-1}" = 0 ] && va=""
  xvfb-run -a openscad -o "$OUT/$n.png" --imgsize=1600,1000 --colorscheme="Tomorrow Night" \
    --camera="$cam" $va -D "vista=\"$v\"" "$@" ensamblaje.scad 2>&1 | grep -iE "warning|error" || true
}
C=228,150,70   # centro aproximado de la v1 (W/2, D/2, ~H/2)
r 01_msi_frontal_3-4   montado      "-200,-700,520,$C"
r 01b_msi_frontal_der_3-4 montado   "560,-640,360,$C"
VIEWALL=0 r 02_msi_lateral montado  "-330,150,77,228,150,77" --projection=o
r 03_msi_trasera_3-4   montado      "-260,950,430,$C"
r 04_msi_explosionado  explosionado "-300,-720,520,$C"
r 05_msi_interior      interior     "-120,-430,720,$C"
r 05b_msi_interior_mandos interior  "620,-420,560,$C" -D 'interior_con_mandos=true'
# detalle del lado derecho: ventana OSD, consola en columna y puertos del MSI
VIEWALL=0 r 07_msi_detalle_consola montado "640,-260,360,400,110,90"
# (la comparativa con la Waveshare 12,3" se retiró en v1: ese preset no está adaptado a la consola en columna)
