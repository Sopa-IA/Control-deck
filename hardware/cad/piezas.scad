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
            for (p = agujeros_pi()) translate([p[0], p[1], suelo - 0.01]) cylinder(d = 6, h = pi_z - suelo);
            cuna_nano_mandos();
            riel_bahia();
            canal_bandeja_v2();
            // nido de la capturadora: marco bajo, sin tapa. La medida real es [PENDIENTE].
            translate([cap_x, cap_y, suelo - 0.2]) difference() {
                cube([cap_hueco[0], cap_hueco[1], 6]);
                translate([1.6, 1.6, 2]) cube([cap_hueco[0] - 3.2, cap_hueco[1] - 3.2, 6]);
            }
        }
        for (p = agujeros_pi()) translate([p[0], p[1], 1.5]) cylinder(d = 2.7, h = 20);
        for (p = torretas_bandeja()) translate([p[0], p[1], -5]) cylinder(d = tornillo_d, h = 10);
        // dedo para la micro-SD, que sale hacia −Y. La ranura exacta es [PENDIENTE]:
        // el plano la sitúa junto a ox = 0; la muesca cubre oy ≈ 20–38.
        translate([pi_x0 + 18, pi_y0 - 16, -1]) cube([18, 20, suelo + 2]);
        // Rejilla bajo el SoC. Atraviesa el ala (z = −2) y el suelo (z = 0 a 4).
        // En la cama son agujeros verticales: no piden soporte. Dos tramos en Y
        // con un nervio de 2 mm en medio, para que la plancha no quede en tiras.
        for (i = [0 : pi_rej_n - 1], tramo = [[183, 14], [199, 16]])
            translate([pi_rej_x0 + i * pi_rej_paso, tramo[0], -2.4])
                cube([pi_rej_ancho, tramo[1], 7]);
        // asiento de la PCB del Nano de mandos y paso del mini-USB
        translate([ard_cx - ard_w/2 - 0.4, ard_y - 0.4, ard_pcb_z]) cube([ard_w + 0.8, ard_l + 0.8, 30]);
        translate([ard_cx - 7, ard_y + ard_l - 6, ard_pcb_z - 1]) cube([14, 28, 30]);
        for (y = bay_est) {
            // Cajeado abierto por arriba. El fondo es el suelo de la bandeja.
            translate([bay_x - bay_caj_x/2, y - bay_caj_y/2, suelo - 0.02])
                cube([bay_caj_x, bay_caj_y, 6.5]);
            for (p = bay_torn)
                translate([bay_x + p[0], y + p[1], -1.5])
                    cylinder(d = inserto_d, h = suelo + 1.7, $fn = 24);
        }
    }
}
// Cuna del Nano de mandos, impresa con la bandeja. La PCB apoya en los dos
// extremos; los pines cuelgan hasta el suelo (20 mm: entra un Dupont de 17).
// Cada poste tiene un reborde hacia fuera para el retenedor.
module cuna_nano_mandos() {
    x0 = ard_cx - sop_ard_w/2;
    union() {
        for (yb = [[ard_y - 3.2, 6.2], [ard_y + ard_l - 3.0, 6.2]])
            translate([x0, yb[0], suelo - 0.2]) cube([sop_ard_w, yb[1], ard_pcb_z - suelo + 0.6]);
        for (sx = [-1, 1], sy = [0, 1]) {
            py = sy == 0 ? ard_y - 3.2 : ard_y + ard_l - 3.0;
            px = ard_cx + sx * (ard_w/2 + 0.5);
            translate([sx < 0 ? px - 3.4 : px, py, suelo - 0.2])
                cube([3.4, 6.2, ard_pcb_z - suelo + ard_pcb + 2.8]);
            // reborde: el gancho del retenedor entra por debajo
            translate([sx < 0 ? px - 4.5 : px + 3.2, py + 1.1, ard_pcb_z + ard_pcb - 2.4])
                cube([2.0, 4.0, 1.8]);
        }
    }
}
// Riel de los carros. En cada puesto, un cajeado para la zapata. Los dos
// insertos M3 van en el suelo, bajo el cajeado. [PENDIENTE] probar el inserto.
module riel_bahia() {
    y0 = bay_est[0] - 22;
    y1 = bay_est[1] + 22;
    translate([bay_x - 5, y0, suelo - 0.2]) cube([10, y1 - y0, 6.2]);
}
// Canaleta del mini-USB de mandos. Ribetes de 1,6 mm, paso 8 mm, 5 mm de alto.
// Sube por x = 420 y gira hacia el USB derecho de la Pi. No sale de la bandeja.
module canal_bandeja_v2() {
    z = suelo - 0.2;
    x1 = canal_x0 + canal_rib + canal_paso;
    y1 = canal_giro_y0 + canal_rib + canal_paso;
    for (x = [canal_x0, x1])
        translate([x, canal_y0, z]) cube([canal_rib, y1 + canal_rib - canal_y0, 5.2]);
    for (y = [canal_giro_y0, y1])
        translate([canal_giro_x0, y, z]) cube([x1 + canal_rib - canal_giro_x0, canal_rib, 5.2]);
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
// ---------------------------------------------------------------------
// RIEL MODULAR (2026-10-21). Se atornilla a las 2 torretas DC de la
// izquierda de la canaleta. No modifica la bandeja ni el soporte de mandos.
// Agujero de cada torreta: Ø4, ~4 mm de fondo (la torreta mide 4 mm; el
// inserto de params, 5,7 mm, no cabe entero). Hace falta un inserto M3
// corto. No se ha probado en la pieza impresa [PENDIENTE].
// El carro entra por un tetón en el mortise y un tornillo M3 al inserto
// del riel. La cabeza del tornillo apoya sobre la pestaña: no hay cajeado
// (el tramo delantero solo mide ~7 mm y un avellanado Ø6,2 se sale).
// Ajuste del cajeado, del mortise y del inserto: [PENDIENTE].
// ---------------------------------------------------------------------
riel_mort_x = 6.2;   // el tramo delantero mide 7,1 mm: el mortise no puede abrirlo por los lados
riel_mort_y = 4.8;
riel_mort_z = 2.0;
carro_holg = 1.0;
carro_cama_t = 2.4;
carro_labio_h = 1.6;
carro_labio_t = 1.4;
// Pestaña sobre el riel, en coordenadas locales del tornillo del carro.
carro_pest_x0 = -3.3;
carro_pest_x1 = 3.3;
carro_pest_y = 3.6;
carro_pest_z0 = riel_h + 0.05;
carro_pest_h = 2.6;

module riel_placas() {
    difference() {
        union() {
            translate([riel_x0, riel_y0, suelo])
                cube([riel_x1f - riel_x0, riel_yq - riel_y0 + 0.4, riel_h]);
            translate([riel_x0a, riel_yq - 0.2, suelo])
                cube([riel_x1a - riel_x0a, riel_y1 - (riel_yq - 0.2), riel_h]);
        }
        // cajeado de la torreta, abierto por abajo. El techo (~1,8 mm) lleva el tornillo.
        // La cabeza M3 queda por encima: no se avellana, para no dejar un techo de 0,5 mm.
        for (y = [dc_riel_ya, dc_riel_yb]) {
            translate([dc_riel_x, y, suelo - 0.1]) cylinder(d = riel_caj_d, h = 4.3, $fn = 48);
            translate([dc_riel_x, y, suelo + 4.0]) cylinder(d = tornillo_d, h = riel_h, $fn = 24);
        }
        // puestos de carro: mortise + agujero de inserto M3 (no pasante)
        for (y = riel_est) {
            translate([riel_hueco_x - riel_mort_x/2, y - riel_mort_y/2, suelo + riel_h - riel_mort_z])
                cube([riel_mort_x, riel_mort_y, riel_mort_z + 0.1]);
            translate([riel_hueco_x, y, suelo + riel_h - riel_mort_z - 3.3])
                cylinder(d = inserto_d, h = 3.4, $fn = 24);
        }
    }
}

// Carro de la bahía v2. Origen local: tornillo en (0, 0), z = 0 sobre la bandeja.
// La placa crece hacia +X y su USB mira a +X. modo "bordes" (Nano y proto) o
// "columnas" (ESP, cuatro postes en los agujeros de esquina). Bajo la PCB hay
// pcb_z = 17,5 mm: cabe un Dupont de 17 mm. Cuatro uñas pisan las esquinas de
// la PCB (no el USB ni el ICSP) y una pestaña queda sobre el conector.
bay_pcb0 = 3;
module carro_solido(largo, ancho, pcb_z, modo = "bordes") {
    x0 = bay_pcb0;
    x1 = bay_pcb0 + largo;
    yb = ancho/2;
    zap_x = bay_caj_x - 2*bay_holg;
    zap_y = bay_caj_y - 2*bay_holg;
    union() {
        // Zapata: entra en el cajeado. El collar deja plano para la cabeza M3.
        translate([-zap_x/2, -zap_y/2, 0]) cube([zap_x, zap_y, 4]);
        translate([-2.6, -6.6, 3.8]) cube([5.2, 13.2, 3.2]);
        if (modo == "columnas") {
            for (sx = [-1, 1], sy = [-1, 1]) {
                cx = (x0 + x1)/2 + sx * (largo/2 - esp_ag_inset);
                cy = sy * (ancho/2 - esp_ag_inset);
                translate([cx, cy, 0]) cylinder(d = 5.6, h = pcb_z, $fn = 24);
                translate([cx, cy, pcb_z - 0.2]) cylinder(d = 2.4, h = 2.4, $fn = 18);
            }
            translate([x0 - 1, -(yb - 2.4), 0]) cube([6.8, 2*(yb - 2.4), 3.2]);
            translate([x1 - 5.8, -(yb - 2.4), 0]) cube([6, 2*(yb - 2.4), 3.2]);
            translate([x0, -2.2, 0]) cube([largo, 4.4, 2.8]);
        } else {
            for (sy = [-1, 1])
                translate([x0, sy * (yb - 3.2) - 1.3, 0]) cube([largo, 2.6, pcb_z]);
            translate([x0 - 1, -(yb - 0.8), 0]) cube([5.2, 2*(yb - 0.8), pcb_z]);
            translate([x1 - 4.2, -(yb - 0.8), 0]) cube([4.2, 2*(yb - 0.8), pcb_z]);
        }
        for (sx = [0, 1], sy = [-1, 1]) {
            fy = sy * (yb - 2.6) - 1.2;
            fx = sx == 0 ? x0 - 0.4 : x1 - 2.0;
            translate([fx, fy, 0]) cube([2.4, 2.4, pcb_z + 3.2]);
            translate([sx == 0 ? x0 + 0.4 : x1 - 2.6, fy, pcb_z + 1.85]) cube([2.2, 2.4, 1.3]);
        }
        translate([x1 - 3.6, -4, pcb_z + 6.0]) cube([2.8, 8, 1.4]);
        translate([x1 - 1.4, -1.2, 0]) cube([1.6, 2.4, pcb_z + 7.6]);
    }
}
module carro_imprimible(largo, ancho, pcb_z, modo = "bordes") {
    difference() {
        carro_solido(largo, ancho, pcb_z, modo);
        for (p = bay_torn)
            translate([p[0], p[1], -0.2]) cylinder(d = tornillo_d, h = 12, $fn = 24);
    }
}
module carro_en_puesto(i, largo, ancho, pcb_z, modo = "bordes", icsp = false) {
    translate([bay_x, bay_est[i], suelo]) {
        carro_imprimible(largo, ancho, pcb_z, modo);
        color([0.15, 0.45, 0.62])
            translate([bay_pcb0, -ancho/2, pcb_z]) cube([largo, ancho, 1.6]);
        color([0.75, 0.75, 0.78])
            translate([bay_pcb0 + largo - 2, -4, pcb_z + 1.6]) cube([3, 8, 4]);
        if (icsp)
            color([0.1, 0.1, 0.1])
                translate([bay_pcb0 + 1, -pr_icsp[1]/2, pcb_z + 1.6]) cube(pr_icsp);
        if (modo == "columnas")
            color([0.15, 0.15, 0.16])
                translate([bay_pcb0 + largo/2 - esp_mod[0]/2, -esp_mod[1]/2, pcb_z + 1.6]) cube(esp_mod);
    }
}
function carro_caja(i, largo, ancho, pcb_z) = [
    bay_x - 5,
    bay_est[i] - ancho/2 - 1,
    suelo,
    bay_pcb0 + largo + 5,
    ancho + 2,
    pcb_z + 1.6 + 6.2
];
function carro_usb_caja(i, ancho, pcb_z, clavija, largo) = [
    bay_x + bay_pcb0 + largo,
    bay_est[i] - 5,
    suelo + pcb_z + 1.6,
    clavija,
    10,
    6
];
// Retenedor del Nano de mandos. Pieza aparte: engancha los rebordes de la
// cuna, pisa las cuatro esquinas de la PCB y lleva un tope sobre el mini-USB.
module retenedor_nano() {
    x0 = ard_cx - ard_w/2;
    ztop = ard_pcb_z + ard_pcb;
    union() {
        // dos barras de canto a canto, por fuera de la PCB, unen los cuatro ganchos
        for (sx = [-1, 1])
            translate([ard_cx + sx * (ard_w/2 + 2.6) - 1.1, ard_y - 3, ztop - 3.4])
                cube([2.2, ard_l + 6, 2.4]);
        for (sy = [0, 1]) {
            py = sy == 0 ? ard_y - 3.2 : ard_y + ard_l - 4.2;
            translate([x0 - 4.9, py, ztop - 2.2]) cube([ard_w + 10.9, 5.2, 2.2]);
            translate([x0 + 0.8, py + 1.4, ztop - 0.2]) cube([3.4, 2.4, 1.4]);
            translate([x0 + ard_w - 4.2, py + 1.4, ztop - 0.2]) cube([3.4, 2.4, 1.4]);
            for (sx = [-1, 1]) {
                hx = ard_cx + sx * (ard_w/2 + 1.2);
                translate([sx < 0 ? hx - 4.0 : hx + 2.4, py + 0.6, ztop - 4.2])
                    cube([2.6, 4.0, 4.4]);
            }
        }
        // tope sobre el mini-USB, unido a la barra trasera
        translate([ard_cx - 4, ard_y + ard_l - 4.2, ztop + 4.6]) cube([8, 6.4, 1.4]);
        translate([ard_cx - 1.2, ard_y + ard_l - 4.2, ztop - 2.2]) cube([2.4, 3.2, 8.4]);
    }
}

// Agujeros de la Pi ya girada. Oficial (ox, oy) → mundo (pi_x0 + 56 − oy, pi_y0 + ox).
function agujeros_pi() = [
    [pi_x0 + 52.5, pi_y0 + 3.5],
    [pi_x0 + 3.5,  pi_y0 + 3.5],
    [pi_x0 + 3.5,  pi_y0 + 61.5],
    [pi_x0 + 52.5, pi_y0 + 61.5]
];

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
