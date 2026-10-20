// Plantilla de prueba: agujeros mini-ITX estándar (C, F, H, J) para la placa del HP 260-a110ns
// Versión fina: barras 6 mm x 1,6 mm, separadores 3 mm (solo para comprobar agujeros).
// Coordenadas desde la esquina trasera izquierda de la placa (borde I/O = y 0). NO medido en la placa real.
$fn = 48;
mitx = 170; e = 1.6; ancho = 6;
sep_h = 3; sep_d = 7; ag_d = 3.0;
C = [6.35, 10.16];
F = [6.35 + 157.48, 10.16 + 22.86];
H = [6.35, 10.16 + 154.94];
J = [6.35 + 157.48, 10.16 + 154.94];
P = [C, F, H, J];
module barra(a, b) { hull() { translate(a) cylinder(d = ancho, h = e); translate(b) cylinder(d = ancho, h = e); } }
difference() {
  union() {
    // contorno de la placa (marco fino) para ver si coincide con los bordes
    difference() { cube([mitx, mitx, 0.8]); translate([2, 2, -1]) cube([mitx - 4, mitx - 4, 4]); }
    barra(C, F); barra(F, J); barra(J, H); barra(H, C); barra(C, J);
    for (p = P) translate(p) cylinder(d = sep_d, h = e + sep_h);
  }
  for (p = P) translate([p[0], p[1], -1]) cylinder(d = ag_d, h = 20);
  // marca "IO" en el borde trasero
  // (sin texto en la versión fina)
}
