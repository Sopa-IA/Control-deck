#!/usr/bin/env python3
"""Regenera los PNG de docs/manual_montaje desde escena.scad.

Vista previa (sin --render): el naranja del subpaso solo llega así al PNG.

Uso, desde la raíz del repo:
  python3 hardware/cad/manual/render_manual.py
  python3 hardware/cad/manual/render_manual.py s1_2 s7_1
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[3]
ESCENA = RAIZ / "hardware" / "cad" / "manual" / "escena.scad"
SALIDA = RAIZ / "docs" / "manual_montaje" / "img"
OPENSCAD = "openscad"

# nombre, sub, modo, cámara, tamaño
# modo "all": viewall + autocenter. modo "cam": cámara explícita, sin viewall.
# En la vista previa, viewall usa la caja de antes del intersection:
# los subpasos recortados van siempre en modo "cam".
RENDERS = [
    ("portada", "portada", "all", "0,0,0,58,0,30,0", (1400, 980)),
    ("s1_1", "1.1", "cam", "228,150,40,54,0,32,1080", (1400, 980)),
    ("s1_2", "1.2", "cam", "228,90,22,58,0,28,250", (1100, 820)),
    ("s1_3", "1.3", "cam", "228,186,22,58,0,28,250", (1100, 820)),
    ("s1_4", "1.4", "cam", "201,150,22,58,0,42,250", (1100, 820)),
    ("s1_5", "1.5", "cam", "258,150,22,58,0,-18,250", (1100, 820)),
    ("s2_1", "2.1", "cam", "80,150,85,50,0,74,540", (1200, 860)),
    ("s2_2", "2.2", "cam", "380,150,85,50,0,-74,540", (1200, 860)),
    ("s2_3", "2.3", "cam", "228,230,95,48,0,80,580", (1200, 860)),
    ("s3_1", "3.1", "cam", "228,150,30,50,0,28,920", (1400, 980)),
    ("s3_2", "3.2", "cam", "228,150,110,56,0,30,1000", (1400, 980)),
    ("s3_3", "3.3", "cam", "370,250,55,50,0,32,500", (1100, 820)),
    ("s3_4", "3.4", "cam", "230,0,55,52,0,6,820", (1200, 860)),
    ("s3_5", "3.5", "cam", "10,130,55,50,0,72,540", (1100, 820)),
    ("s3_6", "3.6", "cam", "197,210,45,50,0,8,360", (1100, 820)),
    ("s3_7", "3.7", "cam", "448,80,55,52,0,-80,400", (1100, 820)),
    ("s4_1", "4.1", "cam", "244,190,28,62,0,26,380", (1100, 820)),
    ("s4_2", "4.2", "cam", "244,190,48,54,0,30,520", (1100, 820)),
    ("s4_3", "4.3", "cam", "244,195,48,54,0,28,400", (1100, 820)),
    ("s4_4", "4.4", "cam", "110,210,42,56,0,26,440", (1100, 820)),
    ("s5_1", "5.1", "cam", "120,305,50,60,0,188,270", (1200, 860)),
    ("s6_1", "6.1", "cam", "0,7,6,62,0,28,130", (1100, 820)),
    ("s6_2", "6.2", "cam", "0,272,112,68,0,0,200", (1100, 820)),
    ("s6_3", "6.3", "cam", "18,272,116,66,0,155,200", (1100, 820)),
    ("s6_4", "6.4", "cam", "22,272,116,64,0,148,180", (1100, 820)),
    ("s6_5", "6.5", "cam", "0,235,85,64,0,0,300", (1200, 860)),
    ("s7_1", "7.1", "cam", "360,210,36,50,0,22,310", (1100, 820)),
    ("s7_2", "7.2", "cam", "408,76,11,8,0,180,110", (1100, 820)),
    ("s7_3", "7.3", "cam", "368,125,32,52,0,18,250", (1100, 820)),
    ("s7_4", "7.4", "cam", "412,96,30,52,0,14,210", (1100, 820)),
    ("s7_5", "7.5", "cam", "412,148,30,52,0,16,220", (1100, 820)),
    ("s7_6", "7.6", "cam", "412,236,32,52,0,14,220", (1100, 820)),
    ("s7_7", "7.7", "cam", "378,164,32,52,0,26,480", (1200, 860)),
    ("s7_8", "7.8", "cam", "378,164,40,54,0,28,520", (1200, 860)),
    ("s8_1", "8.1", "cam", "400,273,158,48,0,32,210", (1100, 820)),
    ("s9_1", "9.1", "cam", "290,330,110,58,0,195,260", (1200, 860)),
    ("s10_1", "10.1", "cam", "228,140,105,54,0,18,880", (1400, 980)),
    ("s10_2", "10.2", "cam", "270,155,24,36,0,16,820", (1400, 980)),
    ("s10_3", "10.3", "cam", "228,135,115,52,0,16,880", (1400, 980)),
    ("s10_4", "10.4", "cam", "228,145,120,50,0,18,900", (1400, 980)),
    ("s10_5", "10.5", "cam", "228,55,45,55,0,12,800", (1400, 980)),
    ("s10_6", "10.6", "cam", "400,80,110,48,0,18,300", (1100, 820)),
    ("s10_7", "10.7", "cam", "390,105,105,48,0,22,360", (1100, 820)),
    ("s10_8", "10.8", "cam", "390,70,75,50,0,18,320", (1100, 820)),
    ("s11_1", "11.1", "cam", "265,90,20,0,0,0,540", (1500, 980)),
    ("s11_2", "11.2", "cam", "265,90,20,0,0,0,540", (1500, 980)),
    ("s11_3", "11.3", "cam", "265,90,20,0,0,0,540", (1500, 980)),
    ("s11_4", "11.4", "cam", "265,90,20,0,0,0,540", (1500, 980)),
    ("s11_5", "11.5", "cam", "265,90,20,0,0,0,540", (1500, 980)),
]


def comando(nombre, sub, modo, cam, tam):
    png = SALIDA / f"{nombre}.png"
    w, h = tam
    args = [
        OPENSCAD,
        "-o", str(png),
        "--imgsize", f"{w},{h}",
        "--camera", cam,
        "--projection", "ortho",
        "--colorscheme", "Tomorrow",
        "-D", f'sub="{sub}"',
    ]
    if modo == "all":
        args += ["--viewall", "--autocenter"]
    args.append(str(ESCENA))
    return args


def main(argv):
    SALIDA.mkdir(parents=True, exist_ok=True)
    pedidas = set(argv[1:])
    trabajos = [t for t in RENDERS if not pedidas or t[0] in pedidas]
    if pedidas and len(trabajos) != len(pedidas):
        conocidos = {t[0] for t in RENDERS}
        print("No existen:", ", ".join(sorted(pedidas - conocidos)), file=sys.stderr)
        return 2
    fallos = 0
    for nombre, sub, modo, cam, tam in trabajos:
        png = SALIDA / f"{nombre}.png"
        print("RENDER", nombre, flush=True)
        proc = subprocess.run(comando(nombre, sub, modo, cam, tam), capture_output=True, text=True)
        malo = proc.returncode != 0 or "ERROR:" in proc.stderr or "Parser error" in proc.stderr
        if "Current top level object is empty" in proc.stderr or "unknown module" in proc.stderr:
            malo = True
        if not png.exists() or png.stat().st_size < 2000:
            malo = True
        if malo:
            fallos += 1
            print("FALLO", nombre, proc.returncode, flush=True)
            err = [ln for ln in proc.stderr.splitlines()
                   if "ERROR" in ln or "error" in ln or "WARNING" in ln or "unknown" in ln]
            print("\n".join(err[-16:]), flush=True)
        else:
            print("OK", nombre, png.stat().st_size, flush=True)
    if fallos == 0 and not pedidas:
        vivos = {f"{nombre}.png" for nombre, *_ in RENDERS}
        for png in SALIDA.glob("*.png"):
            if png.name not in vivos:
                png.unlink()
                print("BORRADO", png.name, flush=True)
    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
