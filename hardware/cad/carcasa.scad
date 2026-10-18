// ORBIT TERMINAL · CARCASA SUPERIOR (cuerpo en cuña) · PROVISIONAL
include <lib.scad>

tina_fondo = 4;     // [DISEÑO] espesor de la repisa bajo la pantalla
tina_pared = 3;     // [DISEÑO]
repisa     = 10;    // [DISEÑO] ancho de apoyo de la pantalla en su perímetro
// Ranuras de cable a izquierda/derecha del alojamiento: el MSI MP161 tiene
// los conectores en los cantos laterales; posición exacta [PENDIENTE] (medir).
ranura_cable_v0 = 0.2;   // fracción de aloj_h donde empieza
ranura_cable_v1 = 0.8;   // fracción donde termina

module carcasa_superior() {
    difference() {
        union() {
            difference() {
                cuerpo_exterior();
                volumen_interior();
                // abierta por abajo: la base es pieza aparte
                translate([-1, -1, -1]) cube([W + 2, D + 2, suelo + 1]);
            }
            intersection() {
                volumen_interior(-0.01);
                union() {
                    tina_pantalla();
                    torretas_bisel();
                    orejetas_base();
                    costillas_union();
                    refuerzos_mandos();
                }
            }
        }
        // --- vaciados ---
        alojamiento_pantalla();
        mandos_vaciado();
        canal_luz_frontal();
        ventilacion();
        cortes_traseros();
        ranura_pod();
        pasadores_union();
        // insertos de orejetas (desde abajo)
        for (p = orejetas) translate([p[0], p[1], suelo - 0.01]) cylinder(d = inserto_d, h = inserto_l + 0.5);
    }
}

// Alojamiento de pantalla (cuna para el monitor completo)
module alojamiento_pantalla() {
    en_pendiente() {
        translate([aloj_x0, aloj_y0, -aloj_t]) cube([aloj_w, aloj_h, aloj_t + 20]);
        // abertura de la repisa (cables, aire, peso)
        translate([aloj_x0 + repisa, aloj_y0 + repisa, -aloj_t - tina_fondo - 1])
            cube([aloj_w - 2*repisa, aloj_h - 2*repisa, tina_fondo + 2]);
        // ranuras laterales de cable
        for (sx = [aloj_x0 - tina_pared - 1, aloj_x0 + aloj_w - 1])
            translate([sx, aloj_y0 + aloj_h*ranura_cable_v0, -aloj_t])
                cube([tina_pared + 2, aloj_h*(ranura_cable_v1 - ranura_cable_v0), aloj_t - 3]);
        // asiento del bisel (rebaje 0.6 mm para alinear)
        translate([aloj_x0 - bisel_sol, aloj_y0 - bisel_sol, -0.6])
            caja_r([aloj_w + 2*bisel_sol, aloj_h + 2*bisel_sol, 5], 4);
        // insertos del bisel
        for (p = torn_bisel()) translate([p[0], p[1], -inserto_l - 1]) cylinder(d = inserto_d, h = inserto_l + 2);
    }
}

module tina_pantalla() {
    en_pendiente()
        translate([aloj_x0 - tina_pared, aloj_y0 - tina_pared, -aloj_t - tina_fondo])
            cube([aloj_w + 2*tina_pared, aloj_h + 2*tina_pared, aloj_t + tina_fondo]);
}

module torretas_bisel() {
    en_pendiente() for (p = torn_bisel()) translate([p[0], p[1], -pared - 7]) cylinder(d = boss_d, h = 7.5);
}

module orejetas_base() {
    // las frontales son columnas hasta el techo (detrás del carril LED);
    // el resto son tacos de 11 mm pegados a la pared
    for (p = orejetas) translate([p[0] - 6, p[1] - 6, suelo])
        cube([12, 12, (p[1] > pared + 10 && p[1] < 40) ? H : 11]);
    // puente de la columna frontal a la pared
    for (p = orejetas) if (p[1] > pared + 10 && p[1] < 40) translate([p[0] - 2, 0, luz_z0 + luz_alto + 3]) cube([4, p[1], H]);
}

// Costillas internas a ambos lados de cada plano de corte (anillo pegado a
// las paredes, profundidad "costilla"), donde van los pasadores de alineación
module costillas_union() {
    difference() {
        union() {
            for (i = [1 : 1 : nx_cortes - 1]) translate([corte_x(i) - 7, 0, 0]) cube([14, D, H]);
            for (j = [1 : 1 : ny_cortes - 1]) translate([0, corte_y(j) - 7, 0]) cube([W, 14, H]);
        }
        volumen_interior(costilla);
        translate([0, 0, -20]) volumen_interior(costilla);   // sin franja a ras de suelo
    }
}

module refuerzos_mandos() {
    // pastilla de 2 mm extra bajo cada encoder y botón
    en_pendiente() for (p = concat(pos_knobs, pos_botones))
        translate([p[0], p[1], -pared - 2]) cylinder(d = 24, h = 2.5);
}

module mandos_vaciado() {
    en_pendiente() {
        for (p = pos_knobs) translate([p[0], p[1], 0]) {
            translate([0, 0, -20]) cylinder(d = agujero_encoder, h = 40);
            // pasante anular para la guía de luz, con 3 puentes de 2.4 mm
            difference() {
                translate([0, 0, -20]) cylinder(d = anillo_ext, h = 40, $fn = 96);
                translate([0, 0, -21]) cylinder(d = anillo_int, h = 42, $fn = 96);
                for (a = [90, 210, 330]) rotate([0, 0, a]) translate([0, -1.2, -22]) cube([anillo_ext, 2.4, 44]);
            }
            // anti-giro del encoder [PENDIENTE: confirmar posición de la pestaña PEC11R]
            translate([-7.6, -1.1, -pared - 3]) cube([2.2, 2.2, pared + 2.5]);
        }
        for (p = pos_botones) translate([p[0], p[1], -20]) cylinder(d = pulsador_agujero, h = 40);
    }
}

module ranura_pod() {
    // ranura decorativa en V que separa la consola de mandos de la pantalla
    en_pendiente() translate([pod_x0 - 1, -60, 0]) rotate([0, 45, 0]) translate([-1, 0, -1]) cube([2, L_pend + 120, 2]);
}

module canal_luz_frontal() {
    translate([luz_margen, -1, luz_z0]) cube([W - 2*luz_margen, pared + 2, luz_alto]);
}

module zonas_corte(m) {
    for (i = [1 : 1 : nx_cortes - 1]) translate([corte_x(i) - m, -5, -5]) cube([2*m, D + 10, H + 10]);
    for (j = [1 : 1 : ny_cortes - 1]) translate([-5, corte_y(j) - m, -5]) cube([W + 10, 2*m, H + 10]);
}
module ventilacion() { difference() { _ventilacion(); zonas_corte(10); } }
module _ventilacion() {
    // laterales: ranuras horizontales que siguen la pendiente (zona trasera)
    for (z = [suelo + 14 : 7 : H - 18]) {
        y_min = max(y_pend0 + (z + 16 - alto_frontal) / tan(inclinacion), D - 120);
        y_max = D - 18;
        if (y_max - y_min > 12)
            for (x = [-1, W - pared - 1]) translate([x, y_min, z]) hull() {
                translate([0, 0, 0]) cube([pared + 2, 0.01, 3]);
                translate([0, y_max - y_min, 0]) cube([pared + 2, 0.01, 3]);
            }
    }
    // trasera: rejilla superior sobre la zona del HP y del KVM
    for (z = [H - 40 : 6 : H - 14]) {
        translate([22, D - pared - 1, z]) cube([hp_w - 10, pared + 2, 3]);
        translate([kvm_x + 4, D - pared - 1, z]) cube([kvm_w - 8, pared + 2, 3]);
    }
}

// --- Conectores traseros ---------------------------------------------
// Ventana I/O del HP: el HP queda con su trasera hacia la pared posterior.
// Tamaño y posición de sus puertos [PENDIENTE: modelo real del HP].
ventana_hp = [hp_w - 8, hp_h + 2];
// Panel de conectores Orbit (prolongadores de montaje en panel, modelos [PENDIENTE]):
// [nombre, x_centro, z_centro, ancho, alto, forma("r"|"c")]
// Medidas de hueco orientativas [PENDIENTE], ajustar al prolongador comprado.
conectores = let(z0 = suelo + 20, x0 = kvm_x + kvm_w + 14) [
    ["audio",  x0,       z0, 6.5, 6.5, "c"],
    ["usb_a1", x0 + 18,  z0, 14.5, 7.5, "r"],
    ["usb_a2", x0 + 38,  z0, 14.5, 7.5, "r"],
    ["usb_c1", x0 + 56,  z0, 10, 4.2, "r"],
    ["usb_c2", x0 + 70,  z0, 10, 4.2, "r"],
    ["hdmi",   x0 + 18,  z0 + 18, 16, 7, "r"],
    ["hdmi2",  x0 + 38,  z0 + 18, 16, 7, "r"],
    ["rj45",   x0 + 61,  z0 + 20, 17, 14.5, "r"],
    ["dc_in",  x0 + 80,  z0 + 20, 11.5, 11.5, "c"]
];
module cortes_traseros() {
    translate([hp_x + 4, D - pared - 1, hp_z]) rotate([-90, 0, 0])
        translate([0, -ventana_hp[1], 0]) caja_r([ventana_hp[0], ventana_hp[1], pared + 2], 2);
    for (c = conectores) translate([c[1], D + 1, c[2]]) rotate([90, 0, 0])
        if (c[5] == "c") cylinder(d = c[3], h = pared + 2);
        else translate([-c[3]/2, -c[4]/2, 0]) caja_r([c[3], c[4], pared + 2], 1.2);
}

// Agujeros para pasadores Ø3 en los planos de corte (dentro de las costillas)
zr_inf = (suelo + pared + costilla) / 2;   // centro del anillo inferior
dc = pared + costilla/2;                              // distancia a la pared exterior
function pos_pasadores_x() = concat(
    [for (z = [30 : 40 : H - 25]) [D - dc, z]],
    [for (y = [y_pend1 + 8, D - 25]) if (y < D - 15) [y, H - dc]]);
function pos_pasadores_y(yc) = concat(
    [for (x = [dc, W - dc]) for (z = [25 : 30 : z_sup(yc) - 20]) [x, z]]);
module pasadores_union() {
    for (i = [1 : 1 : nx_cortes - 1]) for (p = pos_pasadores_x())
        translate([corte_x(i) - pasador_l/2, p[0], p[1]]) rotate([0, 90, 0]) cylinder(d = pasador_d, h = pasador_l, $fn = 20);
    for (j = [1 : 1 : ny_cortes - 1]) for (p = pos_pasadores_y(corte_y(j)))
        translate([p[0], corte_y(j) - pasador_l/2, p[1]]) rotate([-90, 0, 0]) cylinder(d = pasador_d, h = pasador_l, $fn = 20);
}
