#!/usr/bin/env bash
# ORBIT TERMINAL · exporta las piezas imprimibles a STL (PROVISIONAL)
set -e
cd "$(dirname "$0")"
OUT=export/stl; mkdir -p "$OUT"; rm -f "$OUT"/*.stl
read NX NY NBX NBY NG < <(openscad -o /tmp/orbit_info.echo -D 'parte="info"' partes.scad >/dev/null 2>&1; \
  grep INFO /tmp/orbit_info.echo | sed 's/.*INFO;nx;\([0-9]*\);ny;\([0-9]*\);nbx;\([0-9]*\);nby;\([0-9]*\);ng;\([0-9]*\).*/\1 \2 \3 \4 \5/')
jobs_list=()
for ((i=0;i<NX;i++)); do for ((j=0;j<NY;j++)); do
  jobs_list+=("carcasa $i $j 0 PROVISIONAL_carcasa_x${i}_y${j}")
  jobs_list+=("base $i $j 0 PROVISIONAL_base_x${i}_y${j}")
done; done
for ((i=0;i<NBX;i++)); do for ((j=0;j<NBY;j++)); do jobs_list+=("bisel $i $j 0 PROVISIONAL_bisel_x${i}_y${j}"); done; done
for ((k=0;k<NG;k++)); do jobs_list+=("guia 0 0 $k PROVISIONAL_guia_luz_frontal_${k}"); done
jobs_list+=("bandeja 0 0 0 PROVISIONAL_bandeja_servicio" "pomo 0 0 0 PROVISIONAL_pomo_x2" "anillo 0 0 0 PROVISIONAL_anillo_luz_x2" \
            "soporte_arduino 0 0 0 PROVISIONAL_soporte_arduino" "pletina 0 0 0 PROVISIONAL_pletina_empalme_x4")
printf '%s\n' "${jobs_list[@]}" | xargs -P "$(nproc)" -L1 bash -c \
  'openscad -o "'"$OUT"'/$4.stl" -D "parte=\"$0\"" -D ix=$1 -D iy=$2 -D k=$3 partes.scad >/dev/null 2>&1 && \
   sed -i "1s/.*/solid $4/" "'"$OUT"'/$4.stl" && echo "ok $4"'
