include <../../cad/piezas.scad>
// PRUEBA: tira de la pared trasera de carcasa_x0_y1 (ventana I/O del HP + pasacables), cara exterior abajo
translate([0, 0, D]) rotate([-90, 0, 0])
  intersection() { carcasa_superior(); translate([-1, D - pared - 12, -1]) cube([corte_x(1) + 1, pared + 13, 96]); }
