// Plantilla fina con pivotes en vez de tornillos (prueba de ajuste).
// Cada esquina lleva un diámetro distinto para ver cuál entra mejor.
$fn = 48;
mitx = 170; e = 1.6; ancho = 6;
sep_h = 3; sep_d = 7;
pcb = 1.6;          // grosor típico de placa
piv_h = pcb + 1.4;  // sobresale 1,4 mm por encima de la placa
C = [6.35, 10.16];
F = [6.35 + 157.48, 10.16 + 22.86];
H = [6.35, 10.16 + 154.94];
J = [6.35 + 157.48, 10.16 + 154.94];
P = [C, F, H, J];
D = [3.8, 3.6, 3.4, 3.2]; // C, F, H, J
module barra(a, b) { hull() { translate(a) cylinder(d = ancho, h = e); translate(b) cylinder(d = ancho, h = e); } }
module pivote(d) {
  translate([0, 0, -0.5]) cylinder(d = d, h = piv_h - 0.3);
  translate([0, 0, piv_h - 0.8]) cylinder(d1 = d, d2 = d - 1.2, h = 0.8); // punta achaflanada
}
union() {
  // sin marco exterior: solo barras
  barra(C, F); barra(F, J); barra(J, H); barra(H, C); barra(C, J);
  for (i = [0:3]) translate(P[i]) {
    translate([0, 0, -0.01]) cylinder(d = sep_d, h = e + sep_h + 0.01);
    translate([0, 0, e + sep_h - 0.01]) pivote(D[i]);
  }
}
