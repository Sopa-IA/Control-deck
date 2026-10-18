// ORBIT TERMINAL · BISEL, BASE, BANDEJA, GUÍAS DE LUZ Y MANDOS · PROVISIONAL
include <carcasa.scad>

// ---------------------------------------------------------------------
// BISEL (marco de pantalla) — se atornilla con M3 a insertos en la carcasa
// ---------------------------------------------------------------------
ventana_holgura = 1.0;   // [DISEÑO] margen sobre el área activa por lado
module bisel() { en_pendiente() bisel_local(); }
module bisel_local() {
    difference() {
        translate([aloj_x0 - bisel_sol + 0.3, aloj_y0 - bisel_sol + 0.3, -0.6])
            caja_r([aloj_w + 2*bisel_sol - 0.6, aloj_h + 2*bisel_sol - 0.6, bisel_t + 0.6], 4);
        // ventana = área activa + holgura, con chaflán interior de 45°
        translate([act_cx, act_cy, 0]) hull() {
            translate([0, 0, -1]) cube([act_w + 2*ventana_holgura, act_h + 2*ventana_holgura, 0.01 + 2*(1 + 0.6)], center = true);
            translate([0, 0, bisel_t + 0.01]) cube([act_w + 2*ventana_holgura + 3, act_h + 2*ventana_holgura + 3, 0.02], center = true);
        }
        for (p = torn_bisel()) translate([p[0], p[1], -1]) {
            cylinder(d = tornillo_d, h = 10);
            translate([0, 0, bisel_t - 1.7 + 1 - 0.6]) cylinder(d1 = tornillo_d, d2 = 6.4, h = 1.71);  // avellanado M3 [PENDIENTE tornillo]
        }
    }
}

// ---------------------------------------------------------------------
// BASE (suelo) con abertura para la bandeja de servicio
// ---------------------------------------------------------------------
module base() {
    difference() {
        union() {
            intersection() { cuerpo_exterior(); translate([-1, -1, 0]) cube([W + 2, D + 2, suelo]); }
            // raíles del HP
            for (dx = [12, hp_w - 22]) translate([hp_x + dx, hp_y + 10, suelo - 0.01]) cube([10, hp_d - 20, hp_z - suelo]);
            // topes del HP (frontal y lateral)
            translate([hp_x + 30, hp_y - 5, suelo - 0.01]) cube([hp_w - 60, 3, 14]);
            // torretas de la bandeja
            for (p = torretas_bandeja()) translate([p[0], p[1], suelo - 0.01]) cylinder(d = boss_d, h = 5);
            // torretas del KVM [PENDIENTE: el TESmart no publica agujeros; brida adhesiva o abrazadera]
            for (x = [kvm_x - 4, kvm_x + kvm_w + 4], y = [kvm_y + 15, kvm_y + kvm_d - 15])
                translate([x, y, suelo - 0.01]) torreta(8);
            // torretas de empalme en las juntas de la base
            for (p = empalmes()) translate([p[0], p[1], suelo - 0.01]) cylinder(d = boss_d, h = 5);
        }
        // abertura de servicio
        translate([serv_x, serv_y, -1]) cube([serv_w, serv_d, suelo + 2]);
        // pasos de tornillo a las orejetas de la carcasa (avellanados desde abajo)
        for (p = orejetas) translate([p[0], p[1], -1]) {
            cylinder(d = tornillo_d, h = suelo + 2);
            translate([0, 0, 0.99]) mirror([0, 0, 1]) cylinder(d1 = tornillo_d, d2 = 6.6, h = 1.8);
        }
        // insertos de la bandeja (desde abajo) y de los empalmes
        for (p = concat(torretas_bandeja(), empalmes())) translate([p[0], p[1], -0.01]) cylinder(d = inserto_d, h = inserto_l + 0.5);
        // ranuras de entrada de aire bajo el HP
        for (y = [hp_y + 20 : 9 : hp_y + hp_d - 25]) translate([hp_x + 30, y, -1]) caja_r([hp_w - 60, 4, suelo + 2], 1.9);
        // alojamientos de pies de goma Ø12 x 1 mm [PENDIENTE: pie elegido]
        for (p = pies()) translate([p[0], p[1], -0.01]) cylinder(d = 12.4, h = 1);
    }
}
function torretas_bandeja() = [for (x = [serv_x - serv_ala/2, serv_x + serv_w + serv_ala/2],
                                    y = [serv_y - serv_ala/2, serv_y + serv_d + serv_ala/2]) [x, y]];
function pies() = [[25, 25], [W - 25, 25], [25, D - 25], [W - 25, D - 25]];
// Empalmes: pares de torretas a ambos lados de cada junta de la base
function empalmes() = concat(
    [for (i = [1 : 1 : nx_cortes - 1]) for (y = [D*0.3, D*0.62]) for (s = [-1, 1]) [corte_x(i) + s*9, y]],
    [for (j = [1 : 1 : ny_cortes - 1]) for (x = [W*0.22, W*0.5 + 30]) for (s = [-1, 1]) [x, corte_y(j) + s*9]]);
// Pletina de empalme (une dos trozos de base por dentro con 2 tornillos M3)
module pletina_empalme() { difference() { caja_r([30, 10, 3], 2);
    for (x = [6, 24]) translate([x, 5, -1]) cylinder(d = tornillo_d, h = 5); } }

// ---------------------------------------------------------------------
// BANDEJA DE SERVICIO: lleva la Raspberry Pi y la distribución de energía
// ---------------------------------------------------------------------
module bandeja_servicio() {
    difference() {
        union() {
            translate([serv_x + 0.3, serv_y + 0.3, 0]) cube([serv_w - 0.6, serv_d - 0.6, suelo]);
            translate([serv_x - serv_ala, serv_y - serv_ala, -serv_ala_t])
                caja_r([serv_w + 2*serv_ala, serv_d + 2*serv_ala, serv_ala_t], 3);
            // separadores de la Pi (M2.5)
            for (p = agujeros_pi()) translate([p[0], p[1], suelo - 0.01]) cylinder(d = 6, h = pi_z - suelo);
            // torretas para la distribución [PENDIENTE: placa elegida]
            for (x = [psu_x + 6, psu_x + psu_w - 6], y = [psu_y + 6, psu_y + psu_d - 6])
                translate([x, y, suelo - 0.01]) torreta(4);
        }
        for (p = agujeros_pi()) translate([p[0], p[1], 1.5]) cylinder(d = 2.7, h = 20);   // rosca/inserto M2.5 [PENDIENTE]
        for (p = torretas_bandeja()) translate([p[0], p[1], -5]) cylinder(d = tornillo_d, h = 10);
        // rejilla bajo la Pi
        for (y = [pi_y + 12 : 7 : pi_y + pi_d - 12]) translate([pi_x + 15, y, -5]) caja_r([pi_w - 30, 3.5, 12], 1.6);
    }
}
function agujeros_pi() = [for (dx = [0, pi_agujeros[0]], dy = [0, pi_agujeros[1]])
    [pi_x + pi_agujero_borde + dx, pi_y + pi_agujero_borde + dy]];

// ---------------------------------------------------------------------
// GUÍA DE LUZ FRONTAL (PETG translúcido natural) con canal para tira LED
// ---------------------------------------------------------------------
tira_ancho = 10.4;   // [PENDIENTE] tira SK6812 WWA de 10 mm (verificar)
module guia_luz_frontal(x0, x1, e0 = 3, e1 = 3) {
    translate([x0, 0, 0]) difference() {
        union() {
            translate([0.15, 0.25, luz_z0 + 0.15]) cube([x1 - x0 - 0.3, pared, luz_alto - 0.3]);       // lengüeta visible
            translate([-e0, pared + 0.2, luz_z0 - 2]) cube([x1 - x0 + e0 + e1, 2, luz_alto + 4]);      // pestaña de retención
            translate([-e0, pared + 2.2, suelo + 0.4]) cube([x1 - x0 + e0 + e1, 6, luz_z0 + luz_alto + 2 - suelo - 0.4]);  // carril LED
        }
        translate([-4, pared + 4.2, luz_z0 + luz_alto/2 - tira_ancho/2]) cube([x1 - x0 + 8, 5, tira_ancho]);
    }
}
// Tramos de la guía frontal que caben en la cama
n_guia = ceil((W - 2*luz_margen + 6) / (min(cama_x, cama_y) - margen_cama));
function tramo_guia(k) = [luz_margen + (W - 2*luz_margen) * k / n_guia, luz_margen + (W - 2*luz_margen) * (k+1) / n_guia];

// ---------------------------------------------------------------------
// MANDOS
// ---------------------------------------------------------------------
module pomo() {   // pomo Ø30 moleteado, eje D de 6 mm
    difference() {
        union() {
            cylinder(d = knob_d, h = knob_h - 2, $fn = 72);
            translate([0, 0, knob_h - 2]) cylinder(d1 = knob_d, d2 = knob_d - 3, h = 2, $fn = 72);
        }
        for (a = [0 : 10 : 359]) rotate([0, 0, a]) translate([knob_d/2 + 0.2, 0, -1]) cylinder(d = 1.6, h = knob_h - 3, $fn = 8);
        difference() { translate([0, 0, -1]) cylinder(d = eje_encoder_d + 0.2, h = 14); translate([1.5 + 0.1, -5, -2]) cube([10, 10, 20]); }
        translate([0, 0, -1]) cylinder(d = 12, h = 2.5);
        translate([0, knob_d/2 - 5, knob_h - 0.8]) cylinder(d = 2.4, h = 2);   // marca de posición (relleno ámbar)
    }
}
module anillo_luz() {  // guía de luz anular bajo cada pomo (PETG translúcido)
    difference() {
        union() {
            cylinder(d = anillo_ext - 0.4, h = pared + 0.6, $fn = 96);
            translate([0, 0, -2]) cylinder(d = anillo_ext + 5, h = 2, $fn = 96);
        }
        translate([0, 0, -3]) cylinder(d = anillo_int + 0.4, h = 10, $fn = 96);
        for (a = [90, 210, 330]) rotate([0, 0, a]) translate([0, -1.5, -0.01]) cube([anillo_ext, 3, 10]);
    }
}
module tapa_boton() {
    difference() {
        union() { cylinder(d = boton_d, h = 6); translate([0, 0, -1.5]) cylinder(d = boton_d + 4, h = 1.5); }
        translate([0, 0, 5.4]) cylinder(d = 8, h = 1);     // icono / indicador ámbar
        translate([0, 0, -2]) cylinder(d = 3.8, h = 5);    // vástago del pulsador [PENDIENTE]
    }
}
