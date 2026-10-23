// Orbit Terminal · figuras del manual completo.
// Una vista por imagen. Naranja: lo que se pone en ese paso. Gris: ya está.
// openscad -D 'vista="nombre"' -o fig.png --viewall --autocenter --projection ortho
include <../componentes.scad>

vista = "ya_cerrada";

GRIS   = [0.58, 0.59, 0.62];
RES    = [0.93, 0.46, 0.08];
AZUL   = [0.18, 0.42, 0.70];
VERDE  = [0.10, 0.48, 0.24];
CAFE   = [0.62, 0.32, 0.12];
ROJO   = [0.78, 0.16, 0.12];
TINTA  = [0.10, 0.10, 0.12];
BLANCO = [0.97, 0.97, 0.96];
CAMA   = [0.90, 0.86, 0.78];

module numero(n) {
    color(BLANCO) cylinder(d = 11, h = 0.8, $fn = 20);
    color(TINTA) translate([0, 0, 0.85])
        linear_extrude(0.45)
            text(str(n), size = 6.2, font = "Liberation Sans",
                 halign = "center", valign = "center");
}
module n_en(x, y, z, n) {
    translate([x, y, z]) numero(n);
}
// Tornillo explotado hacia arriba. z es la boca del agujero.
module torn_arriba(x, y, z, n) {
    color(RES) translate([x, y, z + 16]) cylinder(d = 3.2, h = 12, $fn = 14);
    color(RES) translate([x, y, z + 28]) cylinder(d = 6.4, h = 2.6, $fn = 16);
    color(RES) translate([x, y, z + 4]) cylinder(d1 = 1.4, d2 = 5.4, h = 8, $fn = 12);
    n_en(x + 9, y + 8, z + 18, n);
}
module grapa_en(x, y, z, ang) {
    color(RES) translate([x, y, z]) rotate([0, 0, ang]) grapa_esquina();
}
module torn_grapa(x, y, z, n, cx, cy) {
    torn_arriba(x, y, z, n);
    grapa_en(x, y, z + 12, atan2(cy - y, cx - x));
}
module flecha(desde, hacia) {
    color(RES) hull() {
        translate(desde) sphere(d = 2.2, $fn = 10);
        translate(hacia) sphere(d = 2.2, $fn = 10);
    }
    color(RES) translate(hacia) sphere(d = 7, $fn = 16);
}
module cama() {
    color(CAMA) translate([-30, -30, -1.2]) cube([220, 160, 1.2]);
}
module nano_pcb(b, hacia_y) {
    color(AZUL) translate([b[0], b[1], suelo + b3_pin_z]) cube([b[2], b[3], 1.6]);
    uy = hacia_y > 0 ? b[1] + b[3] : b[1] - 8;
    color([0.78, 0.78, 0.80]) translate([b[0] + 4, uy, suelo + b3_pin_z + 1.2]) cube([10, 8, 4.5]);
    flecha([b[0] + b[2] / 2, b[1] + b[3] / 2, suelo + b3_pin_z + 8],
           [b[0] + b[2] / 2, b[1] + b[3] / 2 + hacia_y * 22, suelo + b3_pin_z + 8]);
}
module esp_pcb() {
    b = b3_esp;
    color([0.15, 0.22, 0.55]) translate([b[0], b[1], suelo + b3_pin_z]) cube([b[2], b[3], 1.6]);
    color([0.12, 0.12, 0.14])
        translate([b[0] + b[2] / 2 - 8, b[1] + b[3] / 2 - 10, suelo + b3_pin_z + 1.6])
            cube([16, 20, 3]);
    color([0.78, 0.78, 0.80])
        translate([b[0] + b[2] / 2 - 5, b[1] + b[3], suelo + b3_pin_z + 1.2])
            cube([10, 8, 4]);
    flecha([b[0] + b[2] / 2, b[1] + b[3] / 2, suelo + b3_pin_z + 10],
           [b[0] + b[2] / 2, b[1] + b[3] + 18, suelo + b3_pin_z + 10]);
}
module buck_pcb() {
    color(CAFE) translate([b3_buck[0], b3_buck[1], suelo + buck_suelda])
        cube([b3_buck[2], b3_buck[3], 1.6]);
    color([0.2, 0.2, 0.22])
        translate([b3_buck[0] + 10, b3_buck[1] + 22, suelo + buck_suelda + 1.6])
            cylinder(d = 10, h = 9, $fn = 20);
}
module grapas_placa(b, z) {
    pts = tornillos_placa(b);
    cx = b[0] + b[2] / 2;
    cy = b[1] + b[3] / 2;
    for (i = [0 : len(pts) - 1])
        torn_grapa(pts[i][0], pts[i][1], z, i + 1, cx, cy);
}
module hilo(a, b, c = RES) {
    color(c) hull() {
        translate(a) sphere(d = 2.4, $fn = 8);
        translate(b) sphere(d = 2.4, $fn = 8);
    }
}
module aspa_roja(x, y, z, s) {
    color(ROJO) {
        translate([x, y, z]) rotate([0, 0, 45]) cube([s, 3, 3], center = true);
        translate([x, y, z]) rotate([0, 0, -45]) cube([s, 3, 3], center = true);
    }
}

// Marco: x local = ancho de la ventana (Y del mundo), y local = alto (Z),
// z local entra en la carcasa (+X).
module marco_puesto(fuera) {
    translate([-fuera, io_impresa_y0 - marco_labio_frente, io_impresa_z0 - marco_labio_inf])
        rotate([0, -90, 0])
            marco_io_frontal();
}

if (vista == "ya_cerrada") {
    color(GRIS) base();
    color([0.42, 0.43, 0.46]) carcasa_superior();
} else if (vista == "marco_expl") {
    color(GRIS) intersection() {
        carcasa_superior();
        translate([-20, io_impresa_y0 - 30, io_impresa_z0 - 40]) cube([80, 120, 120]);
    }
    color(RES) marco_puesto(28);
    flecha([-6, io_impresa_y0 + 20, io_impresa_z0 + 30], [8, io_impresa_y0 + 20, io_impresa_z0 + 20]);
} else if (vista == "marco_dentro") {
    color(GRIS) intersection() {
        carcasa_superior();
        translate([-20, io_impresa_y0 - 30, io_impresa_z0 - 40]) cube([80, 120, 120]);
    }
    color(RES) marco_puesto(0);
} else if (vista == "prueba_io") {
    color(GRIS) intersection() {
        carcasa_superior();
        translate([W - 40, D - 80, 40]) cube([80, 100, 80]);
    }
    color(RES) translate([W + 18, D - pared - ventana_hp[0], ventana_hp_z])
        rotate([0, 90, 0]) prueba_placa_io_hp();
    flecha([W + 8, D - 20, ventana_hp_z + 20], [W - 4, D - 20, ventana_hp_z + 20]);
} else if (vista == "placa_io") {
    color(GRIS) intersection() {
        carcasa_superior();
        translate([W - 50, D - 90, 30]) cube([90, 110, 90]);
    }
    color(RES) translate([W - pared - 8, D - pared - ventana_hp[0] - io_placa_labio, ventana_hp_z - io_placa_labio_inf])
        rotate([0, 90, 0]) placa_io_hp();
} else if (vista == "tapa_puertos") {
    color(GRIS) intersection() {
        carcasa_superior();
        translate([W - 30, D - 80, 70]) cube([50, 90, 90]);
    }
    color(RES) translate([W - pared - 24, 40, 40]) rotate([0, 90, 0]) placa_puertos_pi();
} else if (vista == "panel") {
    color(GRIS) intersection() {
        carcasa_superior();
        translate([250, D - 40, 60]) cube([180, 60, 100]);
    }
    color(RES) translate([panel_x0 - 8, D + 16, panel_z0 - 8])
        rotate([90, 0, 0]) panel_pines();
    flecha([panel_x0 + 30, D + 8, panel_z0 + 30], [panel_x0 + 30, D - 2, panel_z0 + 30]);
} else if (vista == "regleta20") {
    color(GRIS) translate([panel_x0, D - pared, panel_z0]) cube([70, 3, 40]);
    color(RES) translate([panel_x0 + 4, D - pared - 6, panel_z0 + 12]) cube([50, 8.5, 5.1]);
    flecha([panel_x0 + 28, D - pared - 20, panel_z0 + 16], [panel_x0 + 28, D - pared - 6, panel_z0 + 16]);
} else if (vista == "regleta12") {
    color(GRIS) translate([panel_x0 + 20, D - pared, panel_z0 + 30]) cube([40, 3, 24]);
    color(RES) translate([panel_x0 + 22, D - pared - 6, panel_z0 + 34]) cube([32, 8.5, 5.1]);
    flecha([panel_x0 + 36, D - pared - 20, panel_z0 + 38], [panel_x0 + 36, D - pared - 6, panel_z0 + 38]);
} else if (vista == "capuchon") {
    color(CAMA) translate([-20, -20, -1]) cube([60, 60, 1]);
    color(RES) boton_encendido();
} else if (vista == "prueba_boton") {
    color(CAMA) translate([-5, -5, -1]) cube([50, 70, 1]);
    color(RES) prueba_boton();
    color(RES) translate([28, 8, 0]) boton_encendido();
} else if (vista == "capuchon_puesto") {
    color(GRIS) intersection() {
        carcasa_superior();
        translate([-30, boton_hp_y - 40, boton_hp_z - 30]) cube([70, 80, 80]);
    }
    color(RES) translate([pared - 2, boton_hp_y, boton_hp_z]) rotate([0, 90, 0])
        cylinder(d = 11.6, h = 8, $fn = 32);
    color(RES) translate([-2, boton_hp_y, boton_hp_z]) rotate([0, 90, 0])
        cylinder(d = 16, h = 1.6, $fn = 32);
} else if (vista == "soporte_boton") {
    color(GRIS) intersection() {
        carcasa_superior();
        translate([-20, boton_hp_y - 40, boton_hp_z - 20]) cube([50, 80, 70]);
    }
    color(RES) translate([14, boton_hp_y - 16, boton_hp_z - 16]) soporte_boton();
} else if (vista == "pulsador") {
    color(GRIS) translate([0, 0, 0]) soporte_boton();
    color(RES) translate([10, 16, 22]) cube([12, 12, 7.3]);
    color([0.9, 0.75, 0.2]) translate([10, 16, 36]) cylinder(d = 3, h = 6, $fn = 16);
} else if (vista == "hilos_boton") {
    color(GRIS) cube([40, 30, 4]);
    color(RES) translate([8, 8, 4]) cube([12, 12, 7]);
    hilo([14, 14, 11], [70, 40, 20]);
    hilo([14, 20, 11], [70, 48, 20], [0.15, 0.15, 0.16]);
    color(VERDE) translate([68, 32, 16]) cube([28, 22, 8]);
} else if (vista == "bandeja") {
    color(CAMA) translate([serv_x - 16, serv_y - 16, -4])
        cube([serv_w + 32, serv_d + 32, 1.2]);
    color(RES) bandeja_servicio();
} else if (vista == "pi_puesta") {
    color(GRIS) bandeja_servicio();
    pi_marcador();
    flecha([pi_x0 + 28, pi_y0 + 70, pi_z + 22], [pi_x0 + 28, pi_y0 + 100, pi_z + 22]);
} else if (vista == "pi_tornillos") {
    color(GRIS) bandeja_servicio();
    pi_marcador();
    for (i = [0 : len(agujeros_pi()) - 1]) {
        p = agujeros_pi()[i];
        torn_arriba(p[0], p[1], pi_z + 2, i + 1);
    }
    for (p = b3_pi_torn)
        color(GRIS) translate([p[0], p[1], pi_z]) cylinder(d = 6, h = 2, $fn = 16);
} else if (vista == "esp") {
    color(GRIS) bandeja_servicio();
    esp_pcb();
} else if (vista == "esp_tornillos") {
    color(GRIS) bandeja_servicio();
    esp_pcb();
    grapas_placa(b3_esp, suelo + b3_pin_z + 2);
} else if (vista == "nano_man") {
    color(GRIS) bandeja_servicio();
    nano_pcb(b3_man, +1);
} else if (vista == "nano_man_tornillos") {
    color(GRIS) bandeja_servicio();
    nano_pcb(b3_man, +1);
    grapas_placa(b3_man, suelo + b3_pin_z + 2);
} else if (vista == "zero_span") {
    color(GRIS) bandeja_servicio();
    color([0.35, 0.35, 0.38])
        translate([b3_buck[0], b3_buck[1], suelo + buck_suelda])
            cube([b3_buck[2], b3_buck[3], 1.6]);
    aspa_roja(b3_buck[0] + b3_buck[2] / 2, b3_buck[1] + b3_buck[3] / 2, suelo + 16, 28);
} else if (vista == "buck") {
    color(GRIS) bandeja_servicio();
    buck_pcb();
} else if (vista == "buck_pasante") {
    color(GRIS) bandeja_servicio();
    buck_pcb();
    pts = agujeros_buck();
    for (i = [0 : 1]) torn_arriba(pts[i][0], pts[i][1], suelo + buck_suelda + 2, i + 1);
} else if (vista == "buck_grapa") {
    color(GRIS) bandeja_servicio();
    buck_pcb();
    pts = bridas_buck();
    cx = b3_buck[0] + b3_buck[2] / 2;
    cy = b3_buck[1] + b3_buck[3] / 2;
    for (i = [0 : 1]) torn_grapa(pts[i][0], pts[i][1], suelo + buck_suelda + 2, i + 1, cx, cy);
} else if (vista == "nano_prac") {
    color(GRIS) bandeja_servicio();
    nano_pcb(b3_prac, -1);
} else if (vista == "nano_prac_tornillos") {
    color(GRIS) bandeja_servicio();
    nano_pcb(b3_prac, -1);
    grapas_placa(b3_prac, suelo + b3_pin_z + 2);
} else if (vista == "dupont") {
    color(GRIS) bandeja_servicio();
    esp_pcb();
    nano_pcb(b3_prac, -1);
    nano_pcb(b3_man, +1);
    hilo([b3_esp[0] + b3_esp[2], b3_esp[1] + 20, suelo + 8], [402, 115, suelo + 6]);
    hilo([b3_prac[0] + b3_prac[2], b3_prac[1] + 20, suelo + 8], [423.5, 148, suelo + 6]);
    hilo([b3_man[0] + b3_man[2], b3_man[1] + 10, suelo + 8], [423.5, 220, suelo + 6]);
} else if (vista == "bandeja_torres") {
    color(GRIS) base();
    color(RES) translate([0, 0, 28]) bandeja_servicio();
    flecha([serv_x + 40, serv_y + 40, 70], [serv_x + 40, serv_y + 40, 36]);
} else if (vista == "bandeja_tornillos") {
    color(GRIS) bandeja_servicio();
    pts = torretas_bandeja();
    for (i = [0 : len(pts) - 1])
        torn_arriba(pts[i][0], pts[i][1], 4, i + 1);
} else if (vista == "tapa_cama") {
    // Gira alrededor del centro: el chaflán queda contra la cama y el tetón arriba.
    color(CAMA) translate([300, 230, -1.2]) cube([130, 80, 1.2]);
    color(RES) translate([365, 272, 4.6]) rotate([180, 0, 0]) translate([-365, -272, 0]) tapa_pi();
} else if (vista == "tapa_baja") {
    color(GRIS) intersection() {
        carcasa_superior();
        translate([300, 230, H - 30]) cube([140, 80, 50]);
    }
    color(RES) translate([0, 0, H + 18]) tapa_pi();
    flecha([360, 270, H + 28], [360, 270, H + 6]);
} else if (vista == "tapa_tornillos") {
    color(GRIS) intersection() {
        carcasa_superior();
        translate([300, 230, H - 20]) cube([140, 80, 40]);
    }
    color(RES) translate([0, 0, H]) tapa_pi();
    torn_arriba(tapa_x1 + 8, tapa_y0 + 12, H + 4.6, 1);
    torn_arriba(tapa_x1 + 8, tapa_y1 - 12, H + 4.6, 2);
} else if (vista == "pomos") {
    color(CAMA) translate([-20, -20, -1]) cube([80, 80, 1]);
    color(RES) pomo();
    color(RES) translate([40, 0, 0]) pomo();
} else if (vista == "anillo_pomo") {
    color([0.25, 0.25, 0.27]) cylinder(d = 7, h = 8, $fn = 20);
    color([0.95, 0.72, 0.25]) translate([0, 0, 2]) anillo_luz();
    color(RES) translate([0, 0, 10]) pomo();
    torn_arriba(16, 0, 8, 1);
} else if (vista == "guia") {
    color(GRIS) intersection() {
        carcasa_superior();
        translate([-15, -20, -8]) cube([W + 30, 50, 36]);
    }
    color([0.95, 0.72, 0.25]) for (k = [0 : n_guia - 1]) let(t = tramo_guia(k))
        guia_luz_frontal(t[0], t[1], k == 0 ? 3 : 0, k == n_guia - 1 ? 3 : 0);
} else if (vista == "monitor") {
    color(GRIS) carcasa_superior();
    color(RES) monitor();
} else if (vista == "bisel") {
    color(GRIS) carcasa_superior();
    color(RES) bisel();
} else if (vista == "cable_eth") {
    color(VERDE) translate([0, 0, 0]) cube([85, 56, 1.6]);
    color([0.75, 0.75, 0.78]) translate([2, 48, 1.6]) cube([16, 12, 12]);
    color([0.15, 0.45, 0.18]) translate([160, 0, 0]) cube([170, 170, 1.6]);
    hilo([10, 56, 8], [180, 160, 8], [0.1, 0.35, 0.85]);
    color(TINTA) translate([0, -18, 0]) linear_extrude(0.6)
        text("Pi  10.0.0.2", size = 8, font = "Liberation Sans");
    color(TINTA) translate([160, -18, 0]) linear_extrude(0.6)
        text("HP  10.0.0.1", size = 8, font = "Liberation Sans");
} else if (vista == "diagrama") {
    // Esquema, no un recorrido medido. El ZERO/SPAN no entra.
    color(VERDE) translate([0, 80, 0]) cube([70, 40, 2]);
    color(AZUL) translate([120, 120, 0]) cube([40, 22, 2]);
    color(AZUL) translate([120, 40, 0]) cube([40, 22, 2]);
    color([0.15, 0.22, 0.55]) translate([120, 80, 0]) cube([36, 22, 2]);
    color(CAFE) translate([200, 80, 0]) cube([36, 22, 2]);
    color([0.2, 0.2, 0.22]) translate([200, 130, 0]) cube([28, 16, 2]);
    hilo([70, 100, 2], [120, 130, 2]);
    hilo([70, 90, 2], [120, 50, 2]);
    hilo([70, 95, 2], [120, 90, 2]);
    hilo([160, 90, 2], [200, 90, 2]);
    hilo([136, 40, 2], [210, 130, 2], [0.2, 0.2, 0.22]);
    aspa_roja(40, 20, 4, 24);
    color([0.45, 0.45, 0.48]) translate([20, 8, 0]) cube([40, 16, 2]);
    color(TINTA) translate([0, 150, 0]) linear_extrude(0.5)
        text("Pi", size = 7, font = "Liberation Sans");
    color(TINTA) translate([120, 148, 0]) linear_extrude(0.5)
        text("Mandos", size = 6, font = "Liberation Sans");
    color(TINTA) translate([120, 28, 0]) linear_extrude(0.5)
        text("Pruebas", size = 6, font = "Liberation Sans");
    color(TINTA) translate([120, 70, 0]) linear_extrude(0.5)
        text("ESP", size = 6, font = "Liberation Sans");
    color(TINTA) translate([200, 70, 0]) linear_extrude(0.5)
        text("LM2596", size = 6, font = "Liberation Sans");
    color(TINTA) translate([200, 150, 0]) linear_extrude(0.5)
        text("OLED", size = 6, font = "Liberation Sans");
    color(ROJO) translate([0, 28, 0]) linear_extrude(0.5)
        text("ZERO/SPAN no", size = 6, font = "Liberation Sans");
} else if (vista == "soplante") {
    color(GRIS) intersection() {
        carcasa_superior();
        translate([280, 200, 80]) cube([180, 120, 90]);
    }
    color([0.85, 0.2, 0.12, 0.45]) translate([330, 250, 100]) cube([50, 40, 28]);
} else if (vista == "elec_hp") {
    hp_placa_marcador();
} else if (vista == "elec_hdd") {
    color([0.25, 0.27, 0.32]) cube(disco);
} else if (vista == "elec_pi") {
    pi_marcador();
} else if (vista == "elec_hat") {
    pi_marcador();
    color([0.25, 0.22, 0.2, 0.55]) translate([pi_x0 + 2, pi_y0 + 2, pi_z + 12]) cube([52, 60, 2]);
} else if (vista == "elec_oled") {
    color([0.12, 0.12, 0.14]) cube(oled_mod);
    color([0.15, 0.55, 0.85]) translate([2, 4, oled_mod[2]]) cube([oled_mod[0] - 4, oled_mod[1] - 8, 0.6]);
} else if (vista == "elec_fan") {
    color([0.2, 0.2, 0.22]) cube([50, 50, 10]);
    color([0.55, 0.55, 0.58]) translate([25, 25, 10]) cylinder(d = 22, h = 2, $fn = 24);
} else if (vista == "faltan_dupont") {
    color(RES) hull() {
        translate([0, 0, 0]) cube([2.5, 2.5, 8]);
        translate([14, 0, 6]) cube([2.5, 8, 2.5]);
    }
} else if (vista == "faltan_regleta") {
    color(RES) cube([2.54 * 20, 5.1, 8.5]);
    color([0.75, 0.75, 0.78]) translate([0.4, -6, 2]) cube([2.54 * 20 - 0.8, 6, 0.6]);
} else if (vista == "faltan_632") {
    color([0.72, 0.74, 0.78]) {
        cylinder(d = 3.5, h = 6.4, $fn = 16);
        translate([0, 0, 6.4]) cylinder(d = 6.6, h = 2.2, $fn = 16);
    }
} else {
    echo(str("VISTA_DESCONOCIDA;", vista));
    cube(10);
}
