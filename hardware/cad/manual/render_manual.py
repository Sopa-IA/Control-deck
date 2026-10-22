#!/usr/bin/env python3
"""Regenera los PNG del manual desde hardware/cad/manual/escena.scad.

Vista previa de OpenSCAD (sin --render): el color de la pieza del paso
solo llega al PNG en la vista previa. El fondo es el del esquema de color.

Uso, desde la raíz del repo:
  python3 hardware/cad/manual/render_manual.py
  python3 hardware/cad/manual/render_manual.py 01_base_explosion 05_placa_io
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[3]
ESCENA = RAIZ / "hardware" / "cad" / "manual" / "escena.scad"
SALIDA = RAIZ / "docs" / "manual_montaje" / "img"
OPENSCAD = "openscad"

# nombre, escena, resalte, sep, alz, modo, cámara, tamaño
# modo "all": viewall + autocenter (la cámara solo gira).
# modo "cam": cámara explícita x,y,z,rx,ry,rz,dist, sin viewall.
# En la vista previa, viewall usa la caja de ANTES del intersection,
# así que los zooms no se recortan: se encuadran con la cámara.
TRABAJOS = [
    ("00_conjunto", "conjunto", "", 0, 0, "all", "0,0,0,58,0,30,0", (1400, 980)),
    ("00_piezas", "piezas", "todo", 0, 0, "all", "0,0,0,55,0,28,0", (1500, 1000)),
    ("01_base_explosion", "base_expl", "bases", 72, 0, "all", "0,0,0,58,0,32,0", (1400, 980)),
    ("01_pletinas", "pletinas", "pletinas", 0, 0, "all", "0,0,0,58,0,32,0", (1400, 980)),
    ("01_zoom_pletina", "zoom_pletina", "pletinas", 0, 0, "cam", "228,186,10,62,0,28,140", (1100, 820)),
    ("02_carcasa_explosion", "carcasa_expl", "carcasa_0_1", 90, 0, "all", "0,0,0,56,0,28,0", (1400, 980)),
    ("02_zoom_pasador", "zoom_pasador", "carcasa_0_1", 28, 0, "cam", "228,293,32,58,0,78,150", (1100, 820)),
    ("03_carcasa_base", "carcasa_base", "", 0, 80, "all", "0,0,0,58,0,30,0", (1400, 980)),
    ("03_zoom_orejeta_auto", "zoom_oreja_auto", "", 0, 0, "cam", "424,292,22,58,0,40,230", (1100, 820)),
    ("03_zoom_orejeta_inserto", "zoom_oreja_inserto", "", 0, 0, "cam", "197,292,20,58,0,-20,230", (1100, 820)),
    ("04_hp_disco", "hp", "", 0, 0, "all", "0,0,0,62,0,32,0", (1400, 980)),
    ("04_zoom_separador", "zoom_separador", "", 0, 0, "cam", "23,284,18,60,0,42,160", (1100, 820)),
    ("05_placa_io", "placa_io", "placa_io", 0, 0, "cam", "102,310,42,62,0,200,220", (1200, 860)),
    ("06_io_frontal", "io_frontal", "", 0, 0, "cam", "10,230,100,60,0,120,340", (1200, 860)),
    ("07_bandeja", "bandeja", "", 0, 0, "all", "0,0,0,60,0,28,0", (1400, 980)),
    ("07_bandeja_planta", "bandeja_planta", "", 0, 0, "all", "0,0,0,0,0,0,0", (1100, 1400)),
    ("07_zoom_hueco", "zoom_hueco", "", 0, 0, "cam", "362,116,20,58,0,26,180", (1100, 820)),
    ("08_tapa", "tapa", "", 0, 0, "cam", "370,274,175,52,0,30,240", (1200, 860)),
    ("09_panel", "panel", "", 0, 0, "cam", "287,270,110,58,0,175,240", (1200, 860)),
    ("10_bisel", "bisel", "bisel", 0, 0, "all", "0,0,0,58,0,22,0", (1400, 980)),
    ("10_mandos", "mandos", "", 0, 0, "all", "0,0,0,52,0,16,0", (1400, 980)),
    ("11_cableado", "cableado", "", 0, 0, "all", "0,0,0,0,0,0,0", (1600, 1200)),
]


def comando(nombre, escena, resalte, sep, alz, modo, cam, tam):
    png = SALIDA / f"{nombre}.png"
    w, h = tam
    args = [
        OPENSCAD,
        "-o", str(png),
        "--imgsize", f"{w},{h}",
        "--camera", cam,
        "--projection", "ortho",
        "--colorscheme", "Tomorrow",
    ]
    if modo == "all":
        args += ["--viewall", "--autocenter"]
    args += [
        "-D", f'escena="{escena}"',
        "-D", f'resalte="{resalte}"',
        "-D", f"sep={sep}",
        "-D", f"alz={alz}",
        str(ESCENA),
    ]
    return args


def main(argv):
    SALIDA.mkdir(parents=True, exist_ok=True)
    pedidas = set(argv[1:])
    trabajos = [t for t in TRABAJOS if not pedidas or t[0] in pedidas]
    if pedidas and len(trabajos) != len(pedidas):
        conocidos = {t[0] for t in TRABAJOS}
        faltan = pedidas - conocidos
        print("No existen:", ", ".join(sorted(faltan)), file=sys.stderr)
        return 2
    fallos = 0
    for t in trabajos:
        png = SALIDA / f"{t[0]}.png"
        print("RENDER", t[0], flush=True)
        proc = subprocess.run(comando(*t), capture_output=True, text=True)
        malo = proc.returncode != 0 or "ERROR:" in proc.stderr or "Parser error" in proc.stderr
        if "Current top level object is empty" in proc.stderr:
            malo = True
        if not png.exists() or png.stat().st_size < 2000:
            malo = True
        if malo:
            fallos += 1
            print("FALLO", t[0], proc.returncode, flush=True)
            err = [ln for ln in proc.stderr.splitlines() if "ERROR" in ln or "error" in ln or "WARNING" in ln]
            print("\n".join(err[-12:]), flush=True)
        else:
            print("OK", t[0], png.stat().st_size, flush=True)
    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
