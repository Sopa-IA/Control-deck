#!/usr/bin/env python3
"""ORBIT TERMINAL · Comprobación programática de interferencias (v1, PROVISIONAL).

Ejecuta OpenSCAD en modo vista="check" (que hace echo de parámetros, cajas de
componentes y obstáculos) y comprueba por muestreo de puntos:
  1. Cada componente queda dentro del volumen interior libre de la carcasa
     (paredes, techo inclinado, tina de la pantalla, torretas del bisel,
     costillas de unión junto a los planos de corte, orejetas y carril LED).
  2. Solapes por pares entre cajas de componentes (incluidos potenciómetros y
     pulsadores, que se transforman desde la pendiente).
  3. (v1) Los cuerpos de mandos quedan dentro de paredes y suelo, y la bandeja de
     servicio (con su ala) no pisa ninguna orejeta de unión carcasa-base.
Es una comprobación de CAJAS ENVOLVENTES (AABB) sobre marcadores de posición,
NO una validación con modelos reales. Uso:
  python3 comprobar_interferencias.py [-D 'pantalla="waveshare_12_3"'] ...
"""
import math, re, subprocess, sys, tempfile, itertools, os
TRAY = None

HERE = os.path.dirname(os.path.abspath(__file__))

def run_check(defs):
    out = tempfile.NamedTemporaryFile(suffix=".echo", delete=False).name
    cmd = ["openscad", "-o", out, "-D", 'vista="check"'] + sum([["-D", d] for d in defs], []) + [os.path.join(HERE, "ensamblaje.scad")]
    subprocess.run(cmd, check=True, capture_output=True)
    P, comps, local, obst, cutx, cuty = {}, [], [], [], [], []
    global TRAY
    for line in open(out):
        m = re.search(r'ECHO: "(.*)"', line)
        if not m: continue
        f = m.group(1).split(";")
        if f[0] == "PARAM":
            try: P[f[1]] = float(f[2])
            except ValueError: P[f[1]] = f[2]
        elif f[0] == "COMP": comps.append((f[1], list(map(float, f[2:8]))))
        elif f[0] == "LOCAL": local.append((f[1], list(map(float, f[2:8]))))
        elif f[0] == "OBST": obst.append((f[1], list(map(float, f[2:8]))))
        elif f[0] == "CUTX": cutx.append(float(f[1]))
        elif f[0] == "CUTY": cuty.append(float(f[1]))
        elif f[0] == "TRAY": TRAY = list(map(float, f[1:5]))
        elif f[0] == "SOPORTE_EN_BANDEJA": P["sop_ok"] = f[1] == "1"
        elif f[0] == "PANEL_CONECTORES": P["panel"] = (float(f[1]), float(f[2]), float(f[4]), float(f[5]), float(f[6]))
    return P, comps, local, obst, cutx, cuty

def main():
    defs = [a for a in sys.argv[1:] if a != "-D"]
    P, comps, local, obst, cutx, cuty = run_check(defs)
    a = math.radians(P["inclinacion"]); sa, ca = math.sin(a), math.cos(a)
    y0, hf, H, W, D = P["y_pend0"], P["alto_frontal"], P["H"], P["W"], P["D"]

    def to_local(p):
        x, y, z = p; dy, dz = y - y0, z - hf
        return (x, dy*ca + dz*sa, -dy*sa + dz*ca)
    def to_world(q):
        x, v, n = q
        return (x, y0 + v*ca - n*sa, hf + v*sa + n*ca)

    def inside(p, t, m):
        x, y, z = p; t = t + m
        if not (t <= x <= W - t and P["suelo"] - 1e-6 + (m if t > P["pared"] + m else 0) <= z): return False
        inA = t <= y <= y0 + 25 - t and z <= hf - t
        inB = y <= D - t and z <= H - t and to_local(p)[2] <= -t and y >= 2 + t
        return inA or inB

    def occupied_by_screen(p, m):
        x, v, n = to_local(p)
        ax0, ay0, aw, ah = P["aloj_x0"], P["aloj_y0"], P["aloj_w"], P["aloj_h"]
        e = P["tina_pared"] + m
        if ax0 - e <= x <= ax0 + aw + e and ay0 - e <= v <= ay0 + ah + e and n >= -(P["aloj_t"] + P["tina_fondo"]) - m:
            return "tina de pantalla"
        e2 = 9/2 + 8/2 + m
        if ax0 - e2 <= x <= ax0 + aw + e2 and ay0 - e2 <= v <= ay0 + ah + e2 and n >= -(P["pared"] + 7) - m:
            return "torretas del bisel"
        return None

    def in_rib(p, m):
        x, y, z = p
        near = any(abs(x - c) <= 7 + m for c in cutx) or any(abs(y - c) <= 7 + m for c in cuty)
        t = P["pared"] + P["costilla"]
        return near and not (inside(p, t, m) or inside((x, y, z + 20), t, m))

    def box_pts(b, n=9):
        x, y, z, dx, dy, dz = b
        r = [i/(n-1) for i in range(n)]
        return [(x+dx*i, y+dy*j, z+dz*k) for i in r for j in r for k in r]

    def aabb_overlap(b1, b2, m=0):
        return all(b1[i] < b2[i] + b2[i+3] + m and b2[i] < b1[i] + b1[i+3] + m for i in range(3))

    def check_comp(b, m):
        for p in box_pts(b):
            if not inside(p, P["pared"], m): return "fuera del volumen interior (pared/techo)"
            s = occupied_by_screen(p, m)
            if s: return s
            if in_rib(p, m): return "costilla de unión"
        for name, ob in obst:
            if aabb_overlap(b, ob, m): return name
        return None

    print(f"Preset pantalla: {P['pantalla']} · HP: {P['hp_preset']} · inclinación {P['inclinacion']}°")
    print(f"Envolvente: W={W:.1f} D={D:.1f} H={H:.1f} mm (sin pies; +{P['alto_pies']:.0f} mm con pies) · KVM: {'sí' if P.get('usar_kvm') else 'no'} · cama {P.get('cama')} ({P.get('impresora')})")
    print(f"Cortes X: {cutx}  Cortes Y: {cuty}")
    ok_all = True
    for name, b in comps:
        r0 = check_comp(b, 0)
        best, lim = 0, ""
        for m in [1, 2, 3, 5, 8, 10]:
            r = check_comp(b, m)
            if r is None: best = m
            else: lim = r; break
        status = "OK" if r0 is None else f"INTERFERENCIA con {r0}"
        if r0: ok_all = False
        print(f"  [{'OK' if r0 is None else 'XX'}] {name:<34} {status}; holgura mínima ≥ {best} mm{(' (limita: ' + lim + ')') if lim else ''}" if r0 is None else f"  [XX] {name:<34} {status}")
    # cajas locales (bajo la consola): a mundo AABB
    wl = []
    for name, q in local:
        x, v, n, dx, dv, dn = q
        pts = [to_world((x+i*dx, v+j*dv, n+k*dn)) for i in (0,1) for j in (0,1) for k in (0,1)]
        lo = [min(p[i] for p in pts) for i in range(3)]; hi = [max(p[i] for p in pts) for i in range(3)]
        wl.append((name, lo + [hi[i]-lo[i] for i in range(3)]))
    print("Cuerpos de mandos (bajo la pendiente) dentro de paredes y suelo:")
    for name, q in local:
        x, v, n, dx, dv, dn = q
        pts = [to_world((x+i*dx, v+j*dv, n+k*dn)) for i in (0,1) for j in (0,1) for k in (0,1)]
        mx = min(min(p[0] for p in pts) - P["pared"], W - P["pared"] - max(p[0] for p in pts))
        mz = min(p[2] for p in pts) - P["suelo"]
        ok = mx >= 0 and mz >= 0
        if not ok: ok_all = False
        print(f"  [{'OK' if ok else 'XX'}] {name:<34} margen a pared lateral {mx:.1f} mm · sobre el suelo {mz:.1f} mm")
    if TRAY:
        tx, ty, tw, td = TRAY
        hits = [ob for nm, ob in obst if nm == "Orejeta" and ob[0] < tx + tw and tx < ob[0] + ob[3] and ob[1] < ty + td and ty < ob[1] + ob[4]]
        if hits: ok_all = False
        print(f"  [{'XX' if hits else 'OK'}] Bandeja de servicio + ala ({tw:.0f} x {td:.0f} mm) frente a orejetas: {len(hits)} solapes")
    if "sop_ok" in P:
        if not P["sop_ok"]: ok_all = False
        print(f"  [{'OK' if P['sop_ok'] else 'XX'}] Soporte del Arduino dentro de la abertura de la bandeja (se desmonta con ella)")
    if "panel" in P:
        x0, x1, pix, pz0, pitop = P["panel"]
        okp = (x1 < pix - 5 or pz0 > pitop + 5) and all(abs(c - x) > 7 + 2 for c in cutx for x in (x0, x1)) and not any(x0 < c < x1 for c in cutx)
        if not okp: ok_all = False
        print(f"  [{'OK' if okp else 'XX'}] Panel de conectores traseros x={x0:.0f}–{x1:.0f} mm: sin cortar costillas ni invadir la Pi (Pi en x≥{pix:.0f}, z≤{pitop:.0f}; panel desde z={pz0:.0f})")
    allb = comps + wl
    print("Solapes entre componentes (AABB):")
    any_ov = False
    for (n1, b1), (n2, b2) in itertools.combinations(allb, 2):
        if aabb_overlap(b1, b2):
            any_ov = True; ok_all = False; print(f"  [XX] {n1} ↔ {n2}")
    if not any_ov: print(f"  [OK] ningún solape entre {len(allb)} cajas")
    print("RESULTADO:", "SIN INTERFERENCIAS (en cajas envolventes)" if ok_all else "HAY INTERFERENCIAS")
    return 0 if ok_all else 1

if __name__ == "__main__":
    sys.exit(main())
