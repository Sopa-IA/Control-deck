#!/usr/bin/env python3
"""Verifica en los STL que cada separador HP tiene el agujero ABIERTO por arriba:
punto-en-sólido por trazado de rayos (paridad) en z = cima - 0,08 mm (la tapa antigua iba de 10,18 a 10,35):
centro del agujero (r=0) y r=1,5 deben estar FUERA; r=3,5 (pared, entre Ø4 y Ø9) DENTRO.
También a 3 mm bajo la cima (dentro del agujero del inserto). Comprueba malla cerrada.

Sin argumentos comprueba las cuatro bases de hardware/cad/export/stl.
"""
import os
import sys
from collections import Counter

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
STL_DIR = os.path.join(REPO, "hardware", "cad", "export", "stl")

def load(p):
    T, c = [], []
    for l in open(p):
        t = l.split()
        if t and t[0] == "vertex":
            c.append(tuple(float(v) for v in t[1:])); 
            if len(c) == 3: T.append(c); c = []
    return T
def inside(T, q):
    # rayo en +X ligeramente inclinado para evitar aristas
    d = (1.0, 0.000123, 0.000271); n = 0
    for a, b, c in T:
        e1 = [b[i]-a[i] for i in range(3)]; e2 = [c[i]-a[i] for i in range(3)]
        h = [d[1]*e2[2]-d[2]*e2[1], d[2]*e2[0]-d[0]*e2[2], d[0]*e2[1]-d[1]*e2[0]]
        det = sum(e1[i]*h[i] for i in range(3))
        if abs(det) < 1e-12: continue
        f = 1/det; s = [q[i]-a[i] for i in range(3)]
        u = f*sum(s[i]*h[i] for i in range(3))
        if u < 0 or u > 1: continue
        qq = [s[1]*e1[2]-s[2]*e1[1], s[2]*e1[0]-s[0]*e1[2], s[0]*e1[1]-s[1]*e1[0]]
        v = f*sum(d[i]*qq[i] for i in range(3))
        if v < 0 or u + v > 1: continue
        if f*sum(e2[i]*qq[i] for i in range(3)) > 1e-9: n += 1
    return n % 2 == 1
TOP = 4 + 6.35   # suelo + hp_separador
HOLES = {"C": (23.35, 284.332), "H": (23.35, 129.392), "F": (180.83, 261.472), "J": (180.83, 129.392)}
ok = True
paths = sys.argv[1:] or [
    os.path.join(STL_DIR, f"PROVISIONAL_base_x{i}_y{j}.stl") for i in (0, 1) for j in (0, 1)
]
for path in paths:
    T = load(path)
    E = Counter(tuple(sorted(e)) for t in T for e in ((t[0],t[1]),(t[1],t[2]),(t[2],t[0])))
    closed = all(v == 2 for v in E.values()); ok &= closed
    zmax = max(v[2] for t in T for v in t)
    print(f"{path.split('/')[-1]}: malla {'cerrada' if closed else 'ABIERTA'}, z máx {zmax:.2f}")
    xlo = min(v[0] for t in T for v in t); xhi = max(v[0] for t in T for v in t)
    ylo = min(v[1] for t in T for v in t); yhi = max(v[1] for t in T for v in t)
    for nm, (x, y) in HOLES.items():
        # Las bases de la derecha no llevan separadores del HP: no marcarlas como fallo.
        if not (xlo <= x <= xhi and ylo <= y <= yhi): continue
        for z in (TOP - 0.08, TOP - 3.0):
            c0 = inside(T, (x, y, z)); c1 = inside(T, (x + 1.5, y, z)); w = inside(T, (x + 3.5, y, z))
            g = (not c0) and (not c1) and w; ok &= g
            print(f"  [{'OK' if g else 'XX'}] {nm} z={z:.2f}: centro {'sólido' if c0 else 'hueco'}, r1,5 {'sólido' if c1 else 'hueco'}, pared r3,5 {'sólido' if w else 'hueco'}")
print("RESULTADO:", "agujeros abiertos por arriba y mallas cerradas" if ok else "REVISAR"); sys.exit(0 if ok else 1)
