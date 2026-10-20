#!/usr/bin/env python3
"""Comprobación 2D/alturas de la base con HDD 3,5 (cajas y círculos; NO modelos reales).

Se ejecuta desde la raíz del repo (o desde cualquier sitio): usa hardware/cad
salvo que se pase otra carpeta como argumento.
"""
import math
import os
import re
import subprocess
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
CAD = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.join(REPO, "hardware", "cad")
scad = "/tmp/orbit_comprobar_base_hdd.scad"
echo = "/tmp/orbit_comprobar_base_hdd.echo"
piezas = os.path.join(CAD, "piezas.scad")
open(scad, "w").write(f'''include <{piezas}>
echo(str("V;", W, ";", D, ";", corte_x(1), ";", corte_y(1), ";", hp_x, ";", hp_y, ";", hp_w, ";", hp_d, ";",
 disco_x, ";", disco_y, ";", disco[0], ";", disco[1], ";", disco[2], ";", disco_z, ";", suelo, ";", boss_d, ";",
 serv_x, ";", serv_y, ";", serv_w, ";", serv_d, ";", serv_ala, ";", disco_ag_lado, ";", H));
echo(str("TD;", torretas_disco())); echo(str("EMP;", empalmes())); echo(str("ORE;", orejetas));
echo(str("PIES;", pies())); echo(str("HPAG;", hp_agujeros())); echo(str("ZSUP;", z_sup(disco_y)));
cube(1);''')
subprocess.run(["openscad", "-o", echo, scad], check=True, capture_output=True)
os.remove(scad)
txt = open(echo).read()
v = list(map(float, re.search(r'"V;([^"]*)"', txt).group(1).split(";")))
(W, D, cx, cy, hx, hy, hw, hd, dx, dy, dw, dl, dh, dz, suelo, boss, sx, sy, sw, sd, sala, aglado, H) = v
pts = lambda k: [tuple(map(float, p)) for p in re.findall(r'\[([-\d.]+), ([-\d.]+)\]', re.search(k + r';([^"]*)"', txt).group(1))]
TD, EMP, ORE, PIES, HPAG = pts("TD"), pts("EMP"), pts("ORE"), pts("PIES"), pts("HPAG")
ok = True
def rep(c, msg):
    global ok; ok &= c; print(f"  [{'OK' if c else 'XX'}] {msg}")
plate = (dx - 4, dy, dx + dw + 4, dy + dl)   # plancha del soporte (x0,y0,x1,y1)
print(f"Disco 3,5: x {dx:.1f}-{dx+dw:.1f}, y {dy:.1f}-{dy+dl:.1f}, z {dz:.1f}-{dz+dh:.1f}; plancha soporte x {plate[0]:.1f}-{plate[2]:.1f}, z {dz-2:.1f}-{dz:.1f}")
rep(plate[0] - (hx + hw) >= 1, f"plancha frente a placa HP (borde x={hx+hw:.0f}): {plate[0]-(hx+hw):.1f} mm")
rep(min(p[0] for p in TD) - boss/2 - (hx + hw) >= 0.5, f"pata del soporte frente al borde de la placa HP: {min(p[0] for p in TD)-boss/2-(hx+hw):.1f} mm")
rep(sx - sala - plate[2] >= 3, f"plancha frente a abertura de bandeja + ala (x={sx-sala:.0f}): {sx-sala-plate[2]:.1f} mm")
for p in TD:
    rep(abs(p[0]-cx) > boss/2 + 2 and abs(p[1]-cy) > boss/2 + 2, f"torreta disco {p} lejos de cortes (dx={abs(p[0]-cx):.1f}, dy={abs(p[1]-cy):.1f})")
    rep(not (sx - sala <= p[0] <= sx + sw + sala and sy - sala <= p[1] <= sy + sd + sala), f"torreta disco {p} fuera de la abertura de servicio")
    rep(all(math.hypot(p[0]-q[0], p[1]-q[1]) > boss/2 + 6 + 2 for q in PIES), "  ... lejos de pies")
    rep(all(abs(p[0]-o[0]) > 6 + boss/2 or abs(p[1]-o[1]) > 6 + boss/2 for o in ORE), "  ... lejos de orejetas")
for o in ORE:
    if plate[0] - 6 < o[0] < plate[2] + 6 and plate[1] - 6 < o[1] < plate[3] + 6:
        rep(dz - 2 > suelo + 11, f"orejeta {o} bajo la plancha: taco hasta z={suelo+11:.0f}, plancha en z={dz-2:.0f}")
debajo = [e for e in EMP if plate[0] - boss/2 < e[0] < plate[2] + boss/2 and plate[1] - boss/2 < e[1] < plate[3] + boss/2]
print(f"  Torretas de empalme bajo la plancha: {len(debajo)} -> {debajo}")
pila = suelo + 5 + 3 + 3   # torreta + pletina + cabeza M3 [PENDIENTE tornillo]
rep(dz - 2 - 2.4 - pila >= 0.5, f"pila torreta+pletina+cabeza M3 hasta z={pila:.1f}; cabeza 6-32 del disco (~2,4) desde z={dz-2-2.4:.1f}: holgura {dz-2-2.4-pila:.1f} mm")
print(f"  Agujeros inferiores del disco en X (SFF-8301 A5): x={dx+aglado:.2f} y x={dx+dw-aglado:.2f}")
for p in HPAG:
    rep(abs(p[1]-cy) > 4.5 + 2 and abs(p[0]-cx) > 6.5, f"separador HP {p} lejos de cortes")
rep(dz + dh < 0.6 * ( float(re.search(r'ZSUP;([-\d.]+)', txt).group(1)) ) + 99, f"techo sobre el frente del disco z_sup={float(re.search(r'ZSUP;([-\d.]+)', txt).group(1)):.1f} (cara exterior; la tina de pantalla la comprueba comprobar_interferencias.py)")
print("RESULTADO:", "OK (cajas/círculos)" if ok else "HAY CHOQUES")
sys.exit(0 if ok else 1)
