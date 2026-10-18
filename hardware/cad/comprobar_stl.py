#!/usr/bin/env python3
"""ORBIT TERMINAL · comprueba cada STL exportado (PROVISIONAL):
caja envolvente frente a la cama (por defecto 256x256x256, margen 10),
estanqueidad de malla (cada arista compartida por exactamente 2 caras) y volumen.
Uso: python3 comprobar_stl.py [cama_x cama_y cama_z margen]"""
import glob, os, sys, struct
from collections import Counter

def load(path):
    tris, cur = [], []
    with open(path) as f:
        for line in f:
            t = line.split()
            if t and t[0] == "vertex":
                cur.append(tuple(round(float(v), 4) for v in t[1:4]))
                if len(cur) == 3: tris.append(cur); cur = []
    return tris

def main():
    bx, by, bz, m = (list(map(float, sys.argv[1:5])) + [256, 256, 256, 10][len(sys.argv)-1:])[:4]
    ok = True
    print(f"Cama {bx:.0f}x{by:.0f}x{bz:.0f} mm, margen {m:.0f} mm")
    print(f"{'pieza':<44}{'X':>8}{'Y':>8}{'Z':>8}  {'vol cm3':>8}  cama  malla")
    d = os.path.join(os.path.dirname(os.path.abspath(__file__)), "export", "stl")
    for p in sorted(glob.glob(os.path.join(d, "*.stl"))):
        tris = load(p)
        pts = [v for t in tris for v in t]
        lo = [min(v[i] for v in pts) for i in range(3)]; hi = [max(v[i] for v in pts) for i in range(3)]
        s = [hi[i] - lo[i] for i in range(3)]
        fit = (s[2] <= bz) and ((s[0] <= bx - m and s[1] <= by - m) or (s[1] <= bx - m and s[0] <= by - m))
        edges = Counter()
        vol = 0.0
        for a, b, c in tris:
            for e in ((a, b), (b, c), (c, a)): edges[tuple(sorted(e))] += 1
            vol += (a[0]*(b[1]*c[2]-b[2]*c[1]) - a[1]*(b[0]*c[2]-b[2]*c[0]) + a[2]*(b[0]*c[1]-b[1]*c[0])) / 6
        closed = all(n == 2 for n in edges.values())
        ok &= fit and closed
        print(f"{os.path.basename(p)[:43]:<44}{s[0]:8.1f}{s[1]:8.1f}{s[2]:8.1f}  {abs(vol)/1000:8.1f}  {'OK' if fit else 'NO':<5} {'cerrada' if closed else 'ABIERTA'}")
    print("RESULTADO:", "todas las piezas caben y son mallas cerradas" if ok else "REVISAR")
    return 0 if ok else 1

if __name__ == "__main__":
    sys.exit(main())
