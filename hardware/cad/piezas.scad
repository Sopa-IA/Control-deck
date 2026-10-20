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
        // v1: muesca sobre la ventana OSD del canto derecho
        translate([aloj_x0 + aloj_w - 1, aloj_y0 + aloj_h*osd_v0, -5]) caja_r([osd_ancho + 1, aloj_h*(osd_v1 - osd_v0), 20], 2);
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
            if (!hp_desnuda) {
                // raíles del HP (v1, caja Desktop Mini)
                for (dx = [12, hp_w - 22]) translate([hp_x + dx, hp_y + 10, suelo - 0.01]) cube([10, hp_d - 20, hp_z - suelo]);
                translate([hp_x + 30, hp_y - 5, suelo - 0.01]) cube([hp_w - 60, 3, 14]);
            } else {
                // Separadores mini-ITX impresos (inserto M3). Patrón estándar; la plantilla cuadró
                // con la placa el 2026-10-19 (no es una medida de calibre).
                // 2026-10-19: cilindro macizo; el agujero del inserto se abre desde la cara superior (más abajo)
                for (p = hp_agujeros()) translate([p[0], p[1], suelo - 0.01]) cylinder(d = 9, h = hp_separador + 0.01);
                // torretas del soporte del disco
                for (p = torretas_disco()) translate([p[0], p[1], suelo - 0.01]) cylinder(d = boss_d, h = 2);
            }
            // torretas de la bandeja
            for (p = torretas_bandeja()) translate([p[0], p[1], suelo - 0.01]) cylinder(d = boss_d, h = 5);
            // torretas del KVM (solo si usar_kvm) [PENDIENTE: el TESmart no publica agujeros]
            if (usar_kvm) for (x = [kvm_x - 4, kvm_x + kvm_w + 4], y = [kvm_y + 15, kvm_y + kvm_d - 15])
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
        // 2026-10-19: paso M3 en la cara superior de las torretas de empalme (antes quedaban 2,8 mm
        // macizos sobre el inserto y el tornillo de la pletina, que entra desde arriba, no llegaba)
        for (p = empalmes()) translate([p[0], p[1], inserto_l]) cylinder(d = tornillo_d, h = 10);
        // 2026-10-19: agujero del inserto M3 de los separadores HP desde ARRIBA (antes se modelaba
        // desde abajo y quedaba tapado por ~0,17 mm). Profundidad inserto_l + 0,5; no llega al suelo.
        if (hp_desnuda) for (p = hp_agujeros()) translate([p[0], p[1], suelo + hp_separador - inserto_l - 0.5]) cylinder(d = inserto_d, h = inserto_l + 1.5);
        // pasos M3 (desde abajo) al soporte del disco
        if (hp_desnuda) for (p = torretas_disco()) translate([p[0], p[1], -1]) {
            cylinder(d = tornillo_d, h = suelo + 4);
            translate([0, 0, 0.99]) mirror([0, 0, 1]) cylinder(d1 = tornillo_d, d2 = 6.6, h = 1.8);
        }
        // ranuras de entrada de aire bajo el HP (v2: bajo la placa; entrada de aire fresco)
        for (y = [hp_y + 20 : 9 : hp_y + hp_d - 25]) translate([hp_x + 30, y, -1]) caja_r([hp_w - 60, 4, suelo + 2], 1.9);
        // alojamientos de pies de goma Ø12 x 1 mm [PENDIENTE: pie elegido]
        for (p = pies()) translate([p[0], p[1], -0.01]) cylinder(d = 12.4, h = 1);
    }
}
// Soporte del disco (SSD 2,5" por defecto; HDD 3,5" con usar_hdd_35)
function torretas_disco() = [for (x = [disco_x - 1, disco_x + disco[0] + 1], y = [disco_y + 6, disco_y + disco[1] - 6]) [x, y]];
module soporte_disco() {
    t = 2;
    difference() {
        union() {
            translate([disco_x - 4, disco_y, disco_z - t]) caja_r([disco[0] + 8, disco[1], t], 3);
            for (p = torretas_disco()) translate([p[0], p[1], suelo + 2]) cylinder(d = boss_d, h = disco_z - t - suelo - 2 + 0.01);
            // topes laterales bajos
            for (x = [disco_x - 4, disco_x + disco[0] + 1]) translate([x, disco_y + 15, disco_z - 0.01]) cube([3, disco[1] - 30, 4]);
        }
        for (p = torretas_disco()) translate([p[0], p[1], suelo + 1]) cylinder(d = inserto_d, h = inserto_l + 1);
        // colisos para los tornillos inferiores del disco (posición exacta SFF [PENDIENTE])
        // v3,5": centrados a disco_ag_lado del lateral; empiezan a 12 mm de cada extremo (no cortan las patas)
        for (x = [disco_x + disco_ag_lado - 2, disco_x + disco[0] - disco_ag_lado - 2]) translate([x, disco_y + 12, disco_z - t - 1]) caja_r([4, disco[1] - 24, t + 2], 1.9);
        // ventana central (aire y peso)
        translate([disco_x + 16, disco_y + 14, disco_z - t - 1]) caja_r([disco[0] - 32, disco[1] - 28, t + 2], 4);
    }
}
function torretas_bandeja() = [for (x = [serv_x - serv_ala/2, serv_x + serv_w + serv_ala/2],
                                    y = [serv_y - serv_ala/2, serv_y + serv_d + serv_ala/2]) [x, y]];
function pies() = [[25, 25], [W - 25, 25], [25, D - 25], [W - 25, D - 25]];
// Empalmes: pares de torretas a ambos lados de cada junta de la base
function empalmes() = concat(
    [for (i = [1 : 1 : nx_cortes - 1]) for (y = [D*0.3, D*0.62]) for (s = [-1, 1]) [corte_x(i) + s*9, y]],
    [for (j = [1 : 1 : ny_cortes - 1]) for (x = (hp_desnuda ? [hp_x + hp_w + 14, W*0.5 + 30] : [W*0.22, W*0.5 + 30])) for (s = [-1, 1]) [x, corte_y(j) + s*9]]);
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
            // v1: torretas del soporte del Arduino (y = 63 y y = 125; la bandeja impresa no se mueve)
            for (p = agujeros_soporte_ard()) translate([p[0], p[1], suelo - 0.01]) torreta(sop_ard_z0 - suelo + 0.01);
            // v1: canal del cable micro-USB (Arduino -> USB de la Pi), dos paredes de 8 mm
            for (sx = [-1, 1]) translate([ard_cx + sx*(canal_usb_ancho/2 + 0.8) - 0.8, canal_usb_y0, suelo - 0.01])
                cube([1.6, canal_usb_y1 - canal_usb_y0, 8]);
            // grapas del canal (puentes cada 30 mm; el cable entra a presión por el lateral)
            for (y = [canal_usb_y0 + 10 : 30 : canal_usb_y1 - 5]) translate([ard_cx - canal_usb_ancho/2 - 1.6, y, suelo + 6.5])
                difference() { cube([canal_usb_ancho/2 + 1.6 + 2, 4, 1.5]); }
        }
        for (p = agujeros_pi()) translate([p[0], p[1], 1.5]) cylinder(d = 2.7, h = 20);   // rosca/inserto M2.5 [PENDIENTE]
        for (p = torretas_bandeja()) translate([p[0], p[1], -5]) cylinder(d = tornillo_d, h = 10);
        // rejilla bajo la Pi
        for (y = [pi_y + 12 : 7 : pi_y + pi_d - 12]) translate([pi_x + 15, y, -5]) caja_r([pi_w - 30, 3.5, 12], 1.6);
    }
}
function agujeros_soporte_ard() = [[ard_cx, sop_ard_y0 + sop_tab/2], [ard_cx, sop_ard_y0 + sop_ard_l - sop_tab/2]];
// Boca del canal USB de la bandeja YA IMPRESA. Con el Micro salía
// ard_y + 48 + 1,5 + 22 + 2 = 143,5. No recalcularla con el Nano (45 mm):
// el canal impreso sigue ahí. El mini-USB del Nano queda unos 3 mm más lejos.
canal_usb_y0 = 143.5;                                              // [DISEÑO] congelado
canal_usb_y1 = pi_y - 4;                                           // hasta el frente de la Pi (luego el cable gira hacia sus USB)

// ---------------------------------------------------------------------
// SOPORTE DEL ARDUINO NANO (pieza impresa; se atornilla a las 2 torretas
// que YA están en la bandeja impresa, en y = 63 y y = 125).
// La PCB de catálogo (45 x 18) apoya por sus extremos; los pines quedan
// colgando en el hueco central (dupont hembra). El largo del soporte sigue
// siendo el del Micro (70 mm) para no mover los tornillos.
// Se sujeta con una brida de 3,6 mm por las dos ranuras centrales.
// [PENDIENTE] borde libre de pines y posición real del mini-USB en el clon.
// ---------------------------------------------------------------------
module soporte_arduino() {
    x0 = ard_cx - sop_ard_w/2;
    difference() {
        union() {
            translate([x0, sop_ard_y0, sop_ard_z0]) caja_r([sop_ard_w, sop_ard_l, 3], 2);
            // bloques de apoyo en los extremos de la PCB
            for (yb = [[ard_y - 3, 5.4], [ard_y + ard_l - 2.4, 5.4]])
                translate([x0, yb[0], sop_ard_z0]) cube([sop_ard_w, yb[1], ard_altura_soporte]);
            // labios de centrado (1,5 mm sobre la PCB) en las esquinas
            for (sx = [x0, x0 + sop_ard_w - 3.7], yb = [ard_y - 3, ard_y + ard_l - 2.4])
                translate([sx, yb, sop_ard_z0]) cube([3.7, 5.4, ard_altura_soporte + ard_pcb + 1.5]);
            // paredes laterales bajas (rigidez)
            for (sx = [x0, x0 + sop_ard_w - 2]) translate([sx, ard_y - 3, sop_ard_z0]) cube([2, ard_l + 6, 6]);
        }
        // asiento de la PCB con holgura 0,3
        translate([ard_cx - ard_w/2 - 0.3, ard_y - 0.3, sop_ard_z0 + ard_altura_soporte]) cube([ard_w + 0.6, ard_l + 0.6, 10]);
        // paso del conector mini-USB (extremo trasero, centrado). 14 mm de ancho:
        // [DISEÑO], el enchufe real del clon no se ha medido.
        translate([ard_cx - 7, ard_y + ard_l - 5, sop_ard_z0 + ard_altura_soporte - 1]) cube([14, 20, 10]);
        // tornillos M3 a las torretas de la bandeja
        for (p = agujeros_soporte_ard()) translate([p[0], p[1], sop_ard_z0 - 1]) {
            cylinder(d = tornillo_d, h = 10);
            translate([0, 0, 3.01 - 0.6]) cylinder(d = 6.2, h = ard_altura_soporte);   // cabeza
        }
        // ranuras para brida
        for (sx = [-1, 1]) translate([ard_cx + sx*(ard_w/2 + 2) - 1, ard_y + ard_l/2 - 2, sop_ard_z0 - 1]) cube([2, 4, 5]);
    }
}
// Marcador del Arduino Nano de mandos (PCB + pines + clavija mini-USB).
// Filas de pines a 15,24 mm: cota de protoboard, no medida en el clon [PENDIENTE].
module arduino_marcador() {
    translate([ard_cx - ard_w/2, ard_y, ard_pcb_z]) {
        color([0.05, 0.35, 0.55]) cube([ard_w, ard_l, ard_pcb]);
        color([0.15, 0.15, 0.16]) translate([2, 8, ard_pcb]) cube([ard_w - 4, 22, ard_arriba]);
        color([0.8, 0.75, 0.3]) for (sx = [ard_w/2 - 7.62, ard_w/2 + 7.62]) translate([sx - 1.25, 2.4, -ard_pines]) cube([2.5, ard_l - 4.8, ard_pines]);
        color([0.75, 0.75, 0.78]) translate([ard_w/2 - 4, ard_l - 2, ard_pcb]) cube([8, 2 + ard_usb_sale, 4]);
        color([0.1, 0.1, 0.1]) translate([ard_w/2 - 5, ard_l + ard_usb_sale, ard_pcb - 1]) cube([10, ard_clavija, 6]);
    }
}
// ESP8266 (NodeMCU) y Nano de prácticas: marcadores, no hay pieza impresa nueva.
// Van sobre la bandeja con velcro o brida.
module esp_marcador() {
    translate([esp_x, esp_y, esp_z]) {
        color([0.9, 0.9, 0.88]) cube([esp_w, esp_l, 1.6]);
        color([0.75, 0.62, 0.2]) translate([2, 4, 1.6]) cube([esp_w - 4, 16, 2.5]);            // módulo ESP-12, ilustrativo
        color([0.15, 0.15, 0.16]) translate([esp_w/2 - 4, esp_l, 0]) cube([8, esp_clavija, 3]); // micro-USB hacia atrás
    }
}
module nano_pruebas_marcador() {
    translate([pr_x, pr_y, pr_z]) {
        color([0.05, 0.35, 0.55]) cube([pr_w, pr_l, 1.6]);
        color([0.15, 0.15, 0.16]) translate([2, 8, 1.6]) cube([pr_w - 4, 18, 3]);
        color([0.1, 0.1, 0.1]) translate([pr_w/2 - 5, pr_l, 0]) cube([10, pr_clavija, 6]);    // mini-USB hacia atrás
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
pomo_eje_D = false;   // [PENDIENTE] true si el eje del potenciómetro es en D (plano a 4.5 mm)
module pomo() {   // pomo Ø30 moleteado, eje de 6 mm
    difference() {
        union() {
            cylinder(d = knob_d, h = knob_h - 2, $fn = 72);
            translate([0, 0, knob_h - 2]) cylinder(d1 = knob_d, d2 = knob_d - 3, h = 2, $fn = 72);
        }
        for (a = [0 : 10 : 359]) rotate([0, 0, a]) translate([knob_d/2 + 0.2, 0, -1]) cylinder(d = 1.6, h = knob_h - 3, $fn = 8);
        // eje de 6 mm: agujero redondo + plano en D opcional + prisionero M3 radial
        // (vale para eje en D o liso; estriado: usar pomo comercial) [PENDIENTE medir eje]
        difference() { translate([0, 0, -1]) cylinder(d = eje_pot_d + 0.2, h = 14);
            if (pomo_eje_D) translate([1.5 + 0.1, -5, -2]) cube([10, 10, 20]); }
        translate([0, 0, 6]) rotate([0, 90, 0]) cylinder(d = 2.5, h = knob_d);   // prisionero M3 (rosca a mano o inserto)
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
// v1: la tapa de botón impresa desaparece: los pulsadores de panel genéricos traen
// su propio actuador (modelo [PENDIENTE]).
