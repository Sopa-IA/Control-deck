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
C=242,153,70
r 01_msi_frontal_3-4   montado      "-200,-700,520,$C"
r 01b_msi_frontal_der_3-4 montado   "560,-640,360,$C"
VIEWALL=0 r 02_msi_lateral montado  "-330,153,77,242,153,77" --projection=o
r 03_msi_trasera_3-4   montado      "-260,950,430,$C"
r 04_msi_explosionado  explosionado "-300,-720,520,$C"
r 05_msi_interior      interior     "-120,-430,720,$C"
r 06_w123_comparativa_frontal_3-4 montado "-200,-700,520,$C" -D 'pantalla="waveshare_12_3"'
