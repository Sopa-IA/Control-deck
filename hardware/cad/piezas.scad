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
// BANDEJA DE SERVICIO. Huecos fijos (2026-10-22): Pi, dos Nano, ESP8266
// y el step-down. Sin carros. El contorno, el ala y los 4 M3 a la base
// no se mueven. La rejilla bajo el SoC tampoco.
// ---------------------------------------------------------------------
function tornillos_placa(b) = [
    for (sx = [-1, 1], sy = [-1, 1])
        [sx < 0 ? b[0] - b3_torn_lx : b[0] + b[2] + b3_torn_lx,
         sy < 0 ? b[1] - b3_torn_ly : b[1] + b[3] + b3_torn_ly]
];
// Agujeros del módulo, en esquinas opuestas. El centro a la esquina es
// buck_ag_ins [PENDIENTE]. Los otros dos cantos llevan brida.
function agujeros_buck() = [
    [b3_buck[0] + buck_ag_ins, b3_buck[1] + buck_ag_ins],
    [b3_buck[0] + b3_buck[2] - buck_ag_ins, b3_buck[1] + b3_buck[3] - buck_ag_ins]
];
// La brida trasera no puede salir por detrás: el sobremolde HDMI empieza
// en y = 171,5. Va en el canto −X, 1 mm antes del borde trasero de la PCB.
function bridas_buck() = [
    [b3_buck[0] + b3_buck[2] + b3_torn_lx, b3_buck[1] - b3_torn_ly],
    [b3_buck[0] - b3_torn_lx, b3_buck[1] + b3_buck[3] - 1]
];

module guia_m3(x, y, z_techo, prof) {
    if (fijacion == "autorroscante")
        translate([x, y, z_techo - prof])
            cylinder(d = rosca_d, h = prof + 0.6, $fn = 24);
    else
        translate([x, y, z_techo - inserto_l])
            cylinder(d = inserto_d, h = inserto_l + 0.6, $fn = 24);
}
// Puente de cable: dos postes y una barra. El cable entra por debajo.
// La barra salva unos 6 mm; en la cama es un puente corto, sin soporte.
module puente_cable(x, y, dx, dy) {
    z0 = suelo - 0.2;
    zb = suelo + 4.2;
    translate([x, y, z0]) cube([2, 2, zb + 1.6 - z0]);
    translate([x + dx, y + dy, z0]) cube([2, 2, zb + 1.6 - z0]);
    hull() {
        translate([x, y, zb]) cube([2, 2, 1.6]);
        translate([x + dx, y + dy, zb]) cube([2, 2, 1.6]);
    }
}
// Bolsillo de una placa con pines macho hacia abajo. Bajo cada fila hay un
// canal hasta el suelo: desde la PCB hasta cualquier plástico quedan
// pin_bajo_pcb. El apoyo es un escalón en la banda central de cada canto
// corto, fuera del último pin. En el canto del USB ese escalón se parte
// y, si el resto no llega a 1,6 mm, no se imprime: sujetan las arandelas.
// usb_sy = −1 el conector mira a −Y; +1 mira a +Y.
module bolsillo_pines(b, usb_sy, pcb_t) {
    x0 = b[0]; y0 = b[1]; lx = b[2]; ly = b[3];
    z0 = suelo - 0.2;
    z_pcb = suelo + b3_pin_z;
    z1 = z_pcb + pcb_t;
    h = z1 - z0;
    difference() {
        union() {
            translate([x0 - b3_holg - b3_pared, y0 - b3_holg - b3_pared, z0])
                cube([b3_pared, ly + 2*b3_holg + 2*b3_pared, h]);
            translate([x0 + lx + b3_holg, y0 - b3_holg - b3_pared, z0])
                cube([b3_pared, ly + 2*b3_holg + 2*b3_pared, h]);
            translate([x0 - b3_holg - b3_pared, y0 - b3_holg - b3_pared, z0])
                cube([lx + 2*b3_holg + 2*b3_pared, b3_pared, h]);
            translate([x0 - b3_holg - b3_pared, y0 + ly + b3_holg, z0])
                cube([lx + 2*b3_holg + 2*b3_pared, b3_pared, h]);
            apoyo_centro(x0, y0 - b3_holg - 0.3, y0 + b3_apoyo, lx, z0, z_pcb, usb_sy < 0);
            apoyo_centro(x0, y0 + ly - b3_apoyo, y0 + ly + b3_holg + 0.3, lx, z0, z_pcb, usb_sy > 0);
            for (p = tornillos_placa(b))
                translate([p[0], p[1], z0]) cylinder(d = b3_boss, h = h, $fn = 24);
        }
        // La PCB entra desde arriba. El poste no pisa la placa.
        translate([x0 - 0.01, y0 - 0.01, z_pcb - 0.01]) cube([lx + 0.02, ly + 0.02, 40]);
        // Paso del conector, en el canto usb_sy.
        translate([x0 + lx/2 - b3_usb/2,
                   usb_sy < 0 ? y0 - b3_holg - b3_pared - 0.4 : y0 + ly + b3_holg - 0.2,
                   z_pcb - 0.6])
            cube([b3_usb, b3_pared + 0.8, 20]);
        // Canal de cada fila. El cilindro no se resta: deja rosca_pared
        // alrededor de la guía, y ese cilindro no llega a pin_extremo.
        difference() {
            union() {
                translate([x0, y0, z0 - 0.01]) cube([pin_fila_w, ly, z_pcb - z0 + 0.02]);
                translate([x0 + lx - pin_fila_w, y0, z0 - 0.01]) cube([pin_fila_w, ly, z_pcb - z0 + 0.02]);
            }
            for (p = tornillos_placa(b))
                translate([p[0], p[1], z0 - 0.2])
                    cylinder(d = rosca_d + 2*rosca_pared, h = z_pcb - z0 + 1, $fn = 24);
        }
    }
}
// Escalón en la banda central. No entra en la huella de las filas.
// En el canto del USB, cada lado tiene que medir al menos 1,6 mm.
module apoyo_centro(x0, y_lo, y_hi, lx, z0, z_pcb, abrir_usb) {
    xL = x0 + pin_fila_w;
    xR = x0 + lx - pin_fila_w;
    hh = z_pcb - z0;
    dy = y_hi - y_lo;
    if (abrir_usb) {
        xa = x0 + lx/2 - b3_usb/2;
        xb = xa + b3_usb;
        if (xa - xL >= 1.6)
            translate([xL, y_lo, z0]) cube([xa - xL, dy, hh]);
        if (xR - xb >= 1.6)
            translate([xb, y_lo, z0]) cube([xR - xb, dy, hh]);
    } else
        translate([xL, y_lo, z0]) cube([xR - xL, dy, hh]);
}
// Step-down. En el modelo no hay regleta: solo buck_suelda bajo la PCB.
// Reborde perimetral, dos tornillos por los
// agujeros del módulo y dos bridas en los otros cantos.
module bolsillo_buck() {
    x0 = b3_buck[0]; y0 = b3_buck[1]; lx = b3_buck[2]; ly = b3_buck[3];
    z0 = suelo - 0.2;
    z_pcb = suelo + buck_suelda;
    z1 = z_pcb + buck_pcb;
    h = z1 - z0;
    lab = 2.2;
    sol = b3_holg + 0.3;
    difference() {
        union() {
            translate([x0 - b3_holg - b3_pared, y0 - b3_holg - b3_pared, z0])
                cube([b3_pared, ly + 2*b3_holg + 2*b3_pared, h]);
            translate([x0 + lx + b3_holg, y0 - b3_holg - b3_pared, z0])
                cube([b3_pared, ly + 2*b3_holg + 2*b3_pared, h]);
            translate([x0 - b3_holg - b3_pared, y0 - b3_holg - b3_pared, z0])
                cube([lx + 2*b3_holg + 2*b3_pared, b3_pared, h]);
            translate([x0 - b3_holg - b3_pared, y0 + ly + b3_holg, z0])
                cube([lx + 2*b3_holg + 2*b3_pared, b3_pared, h]);
            translate([x0 - sol, y0 - sol, z0]) cube([lx + 2*sol, lab + sol, z_pcb - z0]);
            translate([x0 - sol, y0 + ly - lab, z0]) cube([lx + 2*sol, lab + sol, z_pcb - z0]);
            translate([x0 - sol, y0, z0]) cube([lab + sol, ly, z_pcb - z0]);
            translate([x0 + lx - lab, y0, z0]) cube([lab + sol, ly, z_pcb - z0]);
            for (p = agujeros_buck())
                translate([p[0], p[1], z0]) cylinder(d = 8, h = z_pcb - z0, $fn = 24);
            for (p = bridas_buck())
                translate([p[0], p[1], z0]) cylinder(d = b3_boss, h = h, $fn = 24);
        }
        translate([x0 - 0.01, y0 - 0.01, z_pcb - 0.01]) cube([lx + 0.02, ly + 0.02, 30]);
    }
}
// Paredes de la Pi. Bajas, a ras de la PCB: el HAT no está medido.
// Sin reborde sobre la rejilla. El canto +Y (USB/RJ45) queda abierto.
// El canto +X solo por detrás de los HDMI.
module paredes_pi() {
    z0 = suelo - 0.2;
    z1 = pi_z + 1.5;
    h = z1 - z0;
    translate([pi_x0 - b3_holg - b3_pared, pi_y0 - b3_holg - b3_pared, z0])
        cube([b3_pared, pi_d + 2*b3_holg + 2*b3_pared, h]);
    // −Y partido: la muesca de la micro-SD queda libre (x = 346 a 368).
    translate([pi_x0 - b3_holg - b3_pared, pi_y0 - b3_holg - b3_pared, z0])
        cube([346 - (pi_x0 - b3_holg - b3_pared), b3_pared, h]);
    translate([368, pi_y0 - b3_holg - b3_pared, z0])
        cube([pi_x0 + pi_w + b3_holg + b3_pared - 368, b3_pared, h]);
    translate([pi_x0 + pi_w + b3_holg, 216, z0])
        cube([b3_pared, 34, h]);
    for (p = b3_pi_torn)
        translate([p[0], p[1], z0]) cylinder(d = b3_boss, h = h, $fn = 24);
}

module bandeja_servicio() {
    difference() {
        union() {
            // 0,2 mm dentro del ala: si no, el suelo y el ala solo se tocan.
            translate([serv_x + 0.3, serv_y + 0.3, -0.2]) cube([serv_w - 0.6, serv_d - 0.6, suelo + 0.2]);
            translate([serv_x - serv_ala, serv_y - serv_ala, -serv_ala_t])
                caja_r([serv_w + 2*serv_ala, serv_d + 2*serv_ala, serv_ala_t], 3);
            for (p = agujeros_pi())
                translate([p[0], p[1], suelo - 0.2]) cylinder(d = 6, h = pi_z - (suelo - 0.2));
            paredes_pi();
            bolsillo_pines(b3_esp, +1, esp_pcb);
            bolsillo_pines(b3_prac, -1, ard_pcb);
            bolsillo_pines(b3_man, +1, ard_pcb);
            bolsillo_buck();
            // Canales: el hueco entre paredes es el canal. Estos puentes lo sujetan.
            puente_cable(402, 115.2, 0, 6);
            puente_cable(409, 115.2, 0, 6);
            puente_cable(383, 100, 6, 0);
            puente_cable(383, 132, 6, 0);
            puente_cable(423.5, 148, 6, 0);
            puente_cable(423.5, 198, 6, 0);
            puente_cable(423.5, 238, 6, 0);
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
        // Los postes no entran en la PCB: la arandela es quien la pisa.
        translate([pi_x0, pi_y0, pi_z]) cube([pi_w, pi_d, 30]);
        for (p = b3_pi_torn) {
            echo(str("ROSCA_BOLSILLO;Pi;", p[0], ";", p[1], ";d;", rosca_d, ";prof;", b3_rosca, ";tornillo;M3x10;arandela;9"));
            guia_m3(p[0], p[1], pi_z + 1.5, b3_rosca);
        }
        for (nom = [["ESP", b3_esp], ["Practicas", b3_prac], ["Mandos", b3_man]])
            for (p = tornillos_placa(nom[1])) {
                echo(str("ROSCA_BOLSILLO;", nom[0], ";", p[0], ";", p[1], ";d;", rosca_d, ";prof;", b3_rosca, ";tornillo;M3x10;arandela;9"));
                guia_m3(p[0], p[1], suelo + b3_pin_z + ard_pcb, b3_rosca);
            }
        for (p = agujeros_buck()) {
            echo(str("ROSCA_BOLSILLO;Buck-pasante;", p[0], ";", p[1], ";d;", rosca_d, ";prof;", b3_buck_rosca, ";tornillo;M3x8"));
            guia_m3(p[0], p[1], suelo + buck_suelda, b3_buck_rosca);
        }
        for (p = bridas_buck()) {
            echo(str("ROSCA_BOLSILLO;Buck-brida;", p[0], ";", p[1], ";d;", rosca_d, ";prof;", b3_rosca_baja, ";tornillo;M3x8;arandela;9"));
            guia_m3(p[0], p[1], suelo + buck_suelda + buck_pcb, b3_rosca_baja);
        }
    }
}
// OBSOLETO (2026-10-22). La cuna, el riel y la canaleta de la bahía v2
// ya no se llaman desde bandeja_servicio(). No imprimirlos. El código se
// queda para que las piezas viejas sigan compilando.
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
// tornillos roscan en el suelo, bajo el cajeado (guía o inserto, según
// fijacion). [PENDIENTE] probar el agarre del autorroscante.
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
    // Hueco de mandos (b3_man). La cuna vieja, en ard_cx / ard_y, ya no se usa.
    translate([b3_man[0], b3_man[1], suelo + b3_pin_z]) {
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

// OBSOLETO (2026-10-22). Carro de la bahía v2. No imprimir: la bandeja
// ya no tiene cajeado. Origen local: tornillo en (0, 0), z = 0 sobre la bandeja.
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
// OBSOLETO (2026-10-22). Retenedor del Nano de mandos. No imprimir:
// el hueco nuevo lo pisan cuatro tornillos. Enganchaba los rebordes de la
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

// ---------------------------------------------------------------------
// PLACA I/O DEL HP (ventana ya impresa de carcasa_x0_y1; esa pieza no se toca)
// Origen: esquina inferior izquierda de la ventana. x a la derecha mirando
// la trasera, y hacia arriba, z hacia fuera. Reborde sobre la cama.
// ---------------------------------------------------------------------
io_nervio = 3.2;   // [DISEÑO] marco de la prueba
io_anillo = 2.6;   // [DISEÑO] plástico alrededor de cada hueco de la prueba
io_espina = 3.0;   // [DISEÑO] nervio de cada hueco hasta el marco superior

module placa_io_hp() {
    Ww = ventana_hp[0];
    Wh = ventana_hp[1];
    t = io_placa_t;
    echo(str("PLACA_IO;ventana;", Ww, ";", Wh, ";z0;", ventana_hp_z,
             ";t;", t, ";labio;", io_placa_labio, ";", io_placa_labio_inf,
             ";holg;", io_placa_holg, ";suelo_bajo_ventana;", ventana_hp_z - suelo));
    for (h = io_huecos)
        echo(str("HUECO_IO;", h[0], ";", h[1], ";", h[2], ";", h[3], ";", h[4]));
    difference() {
        union() {
            translate([-io_placa_labio, -io_placa_labio_inf, 0])
                caja_r([Ww + 2*io_placa_labio,
                        Wh + io_placa_labio + io_placa_labio_inf, t], 3);
            // Tetón: mismo centro de arco que la ventana (r = 2) y 0,4 mm dentro.
            translate([io_placa_holg, io_placa_holg, t - 0.25])
                caja_r([Ww - 2*io_placa_holg, Wh - 2*io_placa_holg, t + 0.25],
                       2 - io_placa_holg);
        }
        for (h = io_huecos)
            translate([h[1], h[2], -0.3])
                caja_r([h[3], h[4], 2*t + 1], min(1.2, h[3]/2 - 0.4, h[4]/2 - 0.4));
    }
}

module _cuerpo_prueba_io() {
    Ww = ventana_hp[0];
    Wh = ventana_hp[1];
    t = io_placa_t;
    difference() {
        caja_r([Ww, Wh, t], 2);
        translate([io_nervio, io_nervio, -0.4])
            cube([Ww - 2*io_nervio, Wh - 2*io_nervio, t + 0.8]);
    }
    for (h = io_huecos)
        intersection() {
            caja_r([Ww, Wh, t], 2);
            translate([h[1] - io_anillo, h[2] - io_anillo, 0])
                cube([h[3] + 2*io_anillo, h[4] + 2*io_anillo, t]);
        }
    for (h = io_huecos)
        translate([h[1] + h[3]/2 - io_espina/2,
                   h[2] + h[4] + io_anillo - 0.3, 0])
            cube([io_espina, Wh - io_nervio - (h[2] + h[4] + io_anillo) + 0.6, t]);
}

module prueba_placa_io_hp() {
    Ww = ventana_hp[0];
    Wh = ventana_hp[1];
    echo(str("PRUEBA_IO;ventana;", Ww, ";", Wh, ";t;", io_placa_t,
             ";nervio;", io_nervio, ";anillo;", io_anillo));
    difference() {
        _cuerpo_prueba_io();
        for (h = io_huecos)
            translate([h[1], h[2], -0.4])
                caja_r([h[3], h[4], io_placa_t + 0.8],
                       min(1.2, h[3]/2 - 0.4, h[4]/2 - 0.4));
    }
}

// ---------------------------------------------------------------------
// BOTÓN DE ENCENDIDO (provisional, 2026-10-22)
// La carcasa x0_y1 ya está impresa: estos módulos no la modifican.
// Capuchón por el Ø12,2, soporte pegado por dentro, prueba de ajuste.
// ---------------------------------------------------------------------

function x_empuje() = pared + cap_brida_t;
function x_tope_boton() = x_empuje() + cap_recorrido;
function x_punta_sw() = x_empuje() + cap_recorrido - sw_carrera;
function x_sw0() = x_punta_sw() + sw_vastago_h();
function x_sw1() = x_sw0() + sw_cuerpo_h();
function sop_z0() = boton_hp_z - sop_bajo;
function sop_y0() = boton_hp_y - sop_ala;
function guia_x0() = pared - guia_entra;

// Símbolo IEC 60417-5009 hundido. El palo va en +X de la pieza de impresión:
// al montar, ese +X mira hacia arriba.
module _simbolo_encendido() {
    h = cap_simbolo_h + 0.5;
    difference() {
        cylinder(d = 7.2, h = h, $fn = 48);
        translate([0, 0, -0.2]) cylinder(d = 4.9, h = h + 0.4, $fn = 48);
        translate([1.45, -1.75, -0.2]) cube([3.6, 3.5, h + 0.4]);
    }
    translate([0.15, -0.65, 0]) cube([3.9, 1.3, h]);
}

// Impresión: pestaña en z = 0, vástago hacia arriba, símbolo en la cara de arriba.
module boton_encendido() {
    echo(str("CAP;vastago;", cap_vastago_d, ";brida;", cap_brida_d,
             ";alto;", cap_brida_t + cap_vastago_l, ";recorrido;", cap_recorrido,
             ";sale;", cap_sale));
    difference() {
        union() {
            cylinder(d = cap_brida_d, h = cap_brida_t + 0.02, $fn = 64);
            translate([0, 0, cap_brida_t - 0.02])
                cylinder(d = cap_vastago_d, h = cap_vastago_l + 0.02, $fn = 64);
        }
        translate([0, 0, cap_brida_t + cap_vastago_l - cap_simbolo_h])
            _simbolo_encendido();
    }
}

// En la carcasa, en reposo (pulsado = 0) o hundido. +X es hacia dentro.
module boton_encendido_montado(pulsado = 0) {
    translate([x_empuje() + pulsado, boton_hp_y, boton_hp_z])
        rotate([0, -90, 0]) boton_encendido();
}

// Agujero horizontal con lágrima a 45°: pasa un disco de diámetro d y se imprime sin soportes.
// La punta queda hacia +Z. El eje del agujero es +X.
module gota_x(d, h) {
    r = d / 2;
    s = sin(45);
    rotate([0, 90, 0]) linear_extrude(h, convexity = 4) {
        circle(d = d, $fn = 48);
        polygon([[-r / s, 0], [-r * s, r * s], [-r * s, -r * s]]);
    }
}

// Rombo centrado, extruido de x0 a x1. Cabe en el Ø3,1 si diag <= 2,5.
module rombo_x(x0, x1, y, z, diag) {
    r = diag / 2;
    translate([x0, y, z]) rotate([0, 90, 0])
        linear_extrude(x1 - x0, convexity = 4)
            polygon([[0, r], [r, 0], [0, -r], [-r, 0]]);
}

module _hoja_boton(signo) {
    w = 2.0;
    y0 = boton_hp_y + (signo > 0 ? 3.4 : -3.4 - w);
    z0 = sop_z0() + sop_suelo_t;
    z1 = boton_hp_z + 1.0;
    x_libre = x_empuje() + 0.15;
    x_raiz = x_libre + 1.30;
    hull() {
        translate([x_libre, y0, z1]) cube([0.8, w, 0.35]);
        translate([x_raiz, y0, z0 - 0.35]) cube([0.8, w, 0.7]);
    }
}

module _guia_led() {
    ay = boton_hp_y;
    lz = boton_hp_z + led_hp_dz;
    // Tramo recto por la placa, y cuña a 50° que entra 1,25 mm en la pared.
    rombo_x(guia_x0() + 0.85, pared + sop_t + 0.4, ay, lz, guia_diag);
    hull() {
        rombo_x(guia_x0() + 0.85, guia_x0() + 1.15, ay, lz, guia_diag);
        translate([guia_x0(), ay - 0.32, lz + 0.15]) cube([0.45, 0.64, 0.64]);
    }
    // Abocardado dentro de la placa: une la guía con las paredes del portalámparas.
    rombo_x(pared + sop_t - 0.4, pared + sop_t + 0.55, ay, lz, 4.2);
}

module _portaled() {
    ay = boton_hp_y;
    lz = boton_hp_z + led_hp_dz;
    x0 = pared + sop_t - 0.3;
    ancho = 3.30;                 // cuerpo Ø3,0 [FUENTE T-1] + 0,3
    brida = 4.40;                 // brida ~Ø4 [DISEÑO] + holgura
    pt = 1.35;
    // De la punta a la brida, 5,0 mm [DISEÑO]. La punta queda junto a la guía.
    x_hombro = x0 + 0.7 + 5.0;
    zf = lz - ancho / 2;
    difference() {
        union() {
            translate([x0, ay - ancho / 2 - pt, zf - pt])
                cube([x_hombro - x0 + 1.6, ancho + 2 * pt, ancho / 2 + pt + 2.4]);
            translate([x_hombro - 0.3, ay - brida / 2 - pt, lz - brida / 2 - pt])
                cube([2.4, brida + 2 * pt, brida / 2 + pt + 2.2]);
        }
        // Canal abierto por arriba. No llega a comerse la guía.
        translate([x0 + 0.55, ay - ancho / 2, zf - 0.2])
            cube([x_hombro - x0, ancho, 8]);
        translate([x_hombro - 0.05, ay - brida / 2, lz - brida / 2 - 0.2])
            cube([6, brida, 8]);
    }
}

module _jaula_sw() {
    ay = boton_hp_y;
    az = boton_hp_z;
    semi = sw_lado() / 2 + sw_holg;
    x0 = x_sw0();
    x1 = x_sw1();
    t = 1.5;
    z0 = sop_z0() + sop_suelo_t;
    z_piso = az - semi;
    z1 = az + semi + 0.4;
    y0 = ay - semi;
    // Piso del cajeado, por encima del suelo, para no rozar la pestaña.
    translate([x0 - 0.4, y0 - t, z0 - 0.2])
        cube([x1 - x0 + t + 1.4, 2 * semi + 2 * t, z_piso - z0 + 0.2]);
    // Laterales. Salen 1,2 mm por delante del cuerpo para hacer de tope.
    translate([x0 - 1.2, y0 - t, z_piso]) cube([x1 - x0 + 1.2 + t, t, z1 - z_piso]);
    translate([x0 - 1.2, y0 + 2 * semi, z_piso]) cube([x1 - x0 + 1.2 + t, t, z1 - z_piso]);
    // Labio inferior: el cuerpo no pasa, el vástago sí.
    translate([x0 - 1.2, y0, z_piso])
        cube([1.2, 2 * semi, az - sw_vastago_d() / 2 - 0.55 - z_piso]);
    // Marco trasero con ventana para las patillas (salen por la cara opuesta al vástago).
    difference() {
        translate([x1, y0 - t, z_piso])
            cube([t, 2 * semi + 2 * t, z1 - z_piso]);
        translate([x1 - 0.2, ay - (sw_lado() - 3.2) / 2, az - (sw_lado() - 3.2) / 2])
            cube([t + 0.6, sw_lado() - 3.2, sw_lado() - 3.2]);
    }
    // Tetones: el pulsador entra por arriba y no se sale. 0,4 mm.
    for (s = [-1, 1])
        translate([x0 + 1.2, ay + s * (semi - 0.15) - (s > 0 ? 0 : 0.4), z1 - 2.2])
            cube([2.2, 0.4, 1.1]);
}

module _topes_boton() {
    ay = boton_hp_y;
    az = boton_hp_z;
    z0 = sop_z0() + sop_suelo_t;
    for (s = [-1, 1])
        translate([x_tope_boton(), ay + s * 7.35 - (s > 0 ? 0 : 1.5), z0 - 0.2])
            cube([1.5, 1.5, az + cap_brida_d / 2 + 0.8 - z0]);
}

module _placa_boton() {
    ay = boton_hp_y;
    az = boton_hp_z;
    z0 = sop_z0();
    y0 = sop_y0();
    // Hasta detrás de las patillas, para que el suelo sea la base de impresión.
    x_fin = x_sw1() + 1.5 + 8;
    difference() {
        union() {
            translate([pared, y0, z0])
                cube([sop_t, 2 * sop_ala, az + led_hp_dz + 6 - z0]);
            translate([pared, y0, z0])
                cube([x_fin - pared, 2 * sop_ala, sop_suelo_t]);
        }
        // Paso de la pestaña Ø16, con 0,3 mm por lado. Lágrima para no poner soportes.
        translate([pared - 0.4, ay, az]) gota_x(cap_brida_d + 0.6, sop_t + 1.2);
        // Plan B. El tornillo atraviesa el soporte y muerde la pared.
        for (s = [-1, 1])
            translate([pared - 0.4, ay + s * taladro_b_y, az])
                gota_x(taladro_b_d, sop_t + 1.2);
    }
}

// En coordenadas de la carcasa. Cara de pegar en x = pared.
module soporte_boton() {
    echo(str("SOP;tipo;", sw_tipo, ";z0;", sop_z0(), ";y0;", sop_y0(),
             ";guia_x;", guia_x0(), ";tope_x;", x_tope_boton(),
             ";sw_x;", x_sw0(), ";", x_sw1()));
    union() {
        _placa_boton();
        _jaula_sw();
        _topes_boton();
        _hoja_boton(1);
        _hoja_boton(-1);
        _guia_led();
        _portaled();
    }
}

// Suelo en la cama. La guía queda horizontal; su cara inferior sube a ~50°.
module soporte_boton_impresion() {
    translate([-guia_x0(), -sop_y0(), -sop_z0()]) soporte_boton();
}

// Placa del espesor de la pared, con los dos agujeros a 14 mm.
// Impresión: plana. Comprueba el capuchón; la guía, en el agujero pequeño.
module prueba_boton() {
    echo(str("PRUEBA_BOTON;agujero;", boton_hp_d + 0.2, ";led;3.1;sep;", led_hp_dz));
    difference() {
        translate([-14, -16, 0]) cube([28, 46, pared]);
        translate([0, 0, -0.5]) cylinder(d = boton_hp_d + 0.2, h = pared + 1, $fn = 48);
        translate([0, led_hp_dz, -0.5]) cylinder(d = 3.1, h = pared + 1, $fn = 24);
    }
}
