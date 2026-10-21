// ORBIT TERMINAL · CARCASA SUPERIOR (cuerpo en cuña) · PROVISIONAL
include <lib.scad>

tina_fondo = 4;     // [DISEÑO] espesor de la repisa bajo la pantalla
tina_pared = 3;     // [DISEÑO]
repisa     = 10;    // [DISEÑO] ancho de apoyo de la pantalla en su perímetro

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
            // Postes de la tapa de la Pi. Entran 0,4 mm en el techo para quedar unidos a la piel.
            for (y = [tapa_y0 + 12, tapa_y1 - 12])
                translate([tapa_x1 + 8, y, H - pared - 7.6]) cylinder(d = 10, h = 8, $fn = 28);
        }
        // --- vaciados ---
        alojamiento_pantalla();
        // Hueco de la tapa, solo en el lomo plano, a la derecha de la pantalla.
        translate([tapa_x0, tapa_y0, H - pared - 1])
            cube([tapa_x1 - tapa_x0, tapa_y1 - tapa_y0, pared + 4]);
        for (y = [tapa_y0 + 12, tapa_y1 - 12])
            translate([tapa_x1 + 8, y, H - 6]) cylinder(d = inserto_d, h = 12, $fn = 20);
        mandos_vaciado();
        canal_luz_frontal();
        ventilacion();
        cortes_traseros();
        cortes_panel_practicas();
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
        // v1: puertos del canto DERECHO del MSI (Type-C2, Type-C1, Mini-HDMI).
        // Se abre la pared de la tina y la repisa en ese tramo para que las clavijas
        // (rectas o en L) bajen al interior; la piel exterior queda intacta (3 mm).
        translate([aloj_x0 + aloj_w - repisa - 1, aloj_y0 + aloj_h*puertos_v0, -aloj_t - tina_fondo - 1])
            cube([repisa + 1 + puertos_hueco, aloj_h*(puertos_v1 - puertos_v0), aloj_t + tina_fondo + 1 - 3]);
        // v1: ventana de acceso a las teclas OSD (encendido, arriba/abajo) del canto derecho:
        // atraviesa la piel para poder pulsarlas con el dedo (cambio de entrada HP/Pi).
        translate([aloj_x0 + aloj_w - 1, aloj_y0 + aloj_h*osd_v0, -aloj_t])
            caja_r([osd_ancho + 1, aloj_h*(osd_v1 - osd_v0), aloj_t + 20], 2);
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
    // pastilla bajo cada potenciómetro (solo si el casquillo lo permite) y nervio
    // de rigidez a lo largo de la consola
    en_pendiente() {
        if (refuerzo_pot > 0) for (p = pos_knobs)
            translate([p[0], p[1], -pared - refuerzo_pot]) cylinder(d = pot_cuerpo_d + 8, h = refuerzo_pot + 0.5);
    }
}

module mandos_vaciado() {
    en_pendiente() {
        for (p = pos_knobs) translate([p[0], p[1], 0]) {
            translate([0, 0, -20]) cylinder(d = agujero_pot, h = 40);
            // pasante anular para la guía de luz, con 3 puentes de 2.4 mm
            if (anillos_luz) difference() {
                translate([0, 0, -20]) cylinder(d = anillo_ext, h = 40, $fn = 96);
                translate([0, 0, -21]) cylinder(d = anillo_int, h = 42, $fn = 96);
                for (a = [90, 210, 330]) rotate([0, 0, a]) translate([0, -1.2, -22]) cube([anillo_ext, 2.4, 44]);
            }
            // anti-giro del potenciómetro (ciego, por dentro) [PENDIENTE: posición de la pestaña]
            if (pot_antigiro_r > 0) translate([-pot_antigiro_r - 1.2, -1.4, -pared - refuerzo_pot - 1]) cube([2.4, 2.8, pared + refuerzo_pot - 0.6 + 1]);
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
            for (x = [-1, W - pared - 1]) if (!(hp_desnuda && x < 0 && z > io_frontal_z - 10)) translate([x, y_min, z]) hull() {
                translate([0, 0, 0]) cube([pared + 2, 0.01, 3]);
                translate([0, y_max - y_min, 0]) cube([pared + 2, 0.01, 3]);
            }
    }
    // trasera: rejilla superior sobre la zona del HP (y del KVM si se usa)
    for (z = [H - 40 : 6 : H - 14]) {
        translate([22, D - pared - 1, z]) cube([hp_w - 10, pared + 2, 3]);
        if (usar_kvm) translate([kvm_x + 4, D - pared - 1, z]) cube([kvm_w - 8, pared + 2, 3]);
        else translate([pi_x + 4, D - pared - 1, z]) cube([pi_w - 8, pared + 2, 3]);   // sobre la Pi
    }
}

// --- Panel de prácticas (cara trasera) -------------------------------
// Huecos y rótulos [DISEÑO]. El mapa de pines está en
// software/arduino-pruebas/README.md. No es un conector comprado.
// Mirando la trasera: X mundo crece hacia la izquierda del observador,
// así que el texto se gira 180° para leerse de izquierda a derecha.
module rotulo_trasero(x, z, s, h = 2.4) {
    translate([x, D - 0.35, z]) rotate([90, 0, 180])
        linear_extrude(0.8) text(s, size = h, font = "Noto Sans", halign = "center", valign = "center");
}
module agujero_panel(x, z, d = 1.6) {
    translate([x, D + 1, z]) rotate([90, 0, 0]) cylinder(d = d, h = pared + 2, $fn = 12);
}
module cortes_panel_practicas() {
    // ventana de la OLED (el módulo va por dentro; la cota real es [PENDIENTE])
    translate([panel_x0 + 8, D - pared - 1, panel_z0 + panel_h - 22])
        cube([oled_ventana[0], pared + 2, oled_ventana[1]]);
    // hueco del prolongador USB de programación. 14 x 8 mm [DISEÑO];
    // el recorte del conector de panel que se compre es [PENDIENTE].
    translate([panel_x0 + panel_w - 18, D - pared - 1, panel_z0 + panel_h - 20])
        cube([14, pared + 2, 8]);
    // Visto desde fuera, +X queda a la izquierda. La columna 0 es ese extremo
    // izquierdo: se numera restando, no sumando.
    // Nano: fila de arriba (mayor z) D2..D13 de izquierda a derecha; fila de
    // abajo A0 A1 A2 A3 A4 A5 A6 A7 GND RST 5V 3V3.
    for (col = [0 : 11], row = [0 : 1])
        agujero_panel(panel_x0 + 6 + (11 - col) * 2.54, panel_z0 + 36 + row * 2.54);
    // Pi: 2 x 20, orden oficial. Pin 1 = 3V3, fila de arriba, extremo izquierdo.
    // Pin 2 = 5V, fila de abajo, mismo extremo. El mapa está en el README.
    for (col = [0 : 19], row = [0 : 1])
        agujero_panel(panel_x0 + 4 + (19 - col) * 2.54, panel_z0 + 14 + row * 2.54);
    // marca cuadrada del pin 1 de la Pi (a la izquierda del observador, fila de arriba)
    translate([panel_x0 + 4 + 19 * 2.54 + 1.5, D - pared - 1, panel_z0 + 14 + 2.54 + 1.5]) cube([1.3, pared + 2, 1.3]);
    // El paso de 2,54 mm no da para rotular cada pin. Se graban los grupos;
    // el mapa pin a pin está en software/arduino-pruebas/README.md.
    rotulo_trasero(panel_x0 + panel_w - 22, oled_cz, "OLED", 2.2);
    rotulo_trasero(panel_x0 + panel_w - 11, panel_z0 + panel_h - 4, "PRG", 2.2);
    rotulo_trasero(panel_x0 + 18, panel_z0 + 44, "ARD 5V", 2.2);
    rotulo_trasero(panel_x0 + 28, panel_z0 + 24, "PI 3V3", 2.2);
    rotulo_trasero(panel_x0 + 36, panel_z0 + 5, "NO UNIR", 2.6);
}

// --- Conectores traseros ---------------------------------------------
// Ventana I/O del HP: el HP queda con su trasera hacia la pared posterior.
// Tamaño y posición de sus puertos [PENDIENTE: modelo real del HP].
// HP v2 (placa desnuda): abertura estándar de escudo I/O 158,75 x 44,45 mm [FUENTE estándar ATX];
// posición exacta y si HP usa escudo [PENDIENTE de medir tras desmontar]. El jack DC del adaptador
// externo de 19,5 V está en este I/O trasero (HP, placas hermanas Iris-E2/Iris-A8).
ventana_hp = hp_desnuda ? [hp_io_w + 1, hp_io_h + 1] : [hp_w - 8, hp_h + 2];
ventana_hp_x = hp_desnuda ? hp_x + hp_io_x0 - 0.5 : hp_x + 4;
ventana_hp_z = hp_desnuda ? hp_pcb_z + hp_pcb - hp_io_baja - 0.5 : hp_z;
// Panel de conectores Orbit (prolongadores de montaje en panel, modelos [PENDIENTE]):
// [nombre, x_centro, z_centro, ancho, alto, forma("r"|"c")]
// Medidas de hueco orientativas [PENDIENTE], ajustar al prolongador comprado.
// v1: pasacables trasero junto al HP: el cable de vídeo del HP (p.ej. DP/HDMI -> USB-C)
// sale por la ventana I/O y vuelve a entrar por aquí hacia el USB-C del MSI; también
// entra por aquí el cable de la fuente USB-C PD del monitor (> 15 W según el manual).
// HP v2: por él pasan el HDMI del HP (-> Mini-HDMI MSI) y la fuente USB-C PD de la MSI (USB-C 2).
pasacables = [40, 16];     // [DISEÑO] ancho x alto
pasacables_x = hp_x + hp_w/2 - pasacables[0]/2;   // encima de la ventana I/O del HP
pasacables_z = ventana_hp_z + ventana_hp[1] + 12;
// v1: bloque compacto (77 mm) entre la costilla del corte X y la Pi.
// Con KVM el bloque queda sobre la Pi: se sube por encima de ella.
conectores = let(z0 = usar_kvm ? pi_z + pi_h + 12 : suelo + 20,
                 x0 = usar_kvm ? kvm_x + kvm_w + 14 : max(hp_x + hp_w + 14, corte_x(1) + 7 + 9)) [
    ["audio",  x0,       z0, 6.5, 6.5, "c"],
    ["usb_a1", x0 + 14,  z0, 14.5, 7.5, "r"],
    ["usb_a2", x0 + 32,  z0, 14.5, 7.5, "r"],
    ["usb_c1", x0 + 48,  z0, 10, 4.2, "r"],
    ["usb_c2", x0 + 61,  z0, 10, 4.2, "r"],
    ["hdmi",   x0 + 10,  z0 + 18, 16, 7, "r"],
    ["hdmi2",  x0 + 30,  z0 + 18, 16, 7, "r"],
    ["rj45",   x0 + 50,  z0 + 20, 17, 14.5, "r"],
    ["dc_in",  x0 + 68,  z0 + 20, 11.5, 11.5, "c"]
];
echo(str("PANEL_CONECTORES;", conectores[0][1] - 3.25, ";", conectores[8][1] + 5.75, ";PI_X;", pi_x, ";", conectores[0][2] - 4, ";", pi_z + pi_h));

// Tapa de acceso a los USB y al RJ45. Placa plana: el hueco está en el lomo,
// que es horizontal. Dos tornillos M3 al inserto del techo, en la oreja derecha.
// Una muesca delantera para abrirla con el dedo.
module tapa_pi() {
    ancho = tapa_x1 - tapa_x0 + tapa_sol + 16;
    fondo = tapa_y1 - tapa_y0 + 2*tapa_sol;
    difference() {
        translate([tapa_x0 - tapa_sol, tapa_y0 - tapa_sol, 0]) cube([ancho, fondo, tapa_t]);
        translate([(tapa_x0 + tapa_x1)/2 - 7, tapa_y0 - tapa_sol - 1, -1]) cube([14, 8, tapa_t + 2]);
        for (y = [tapa_y0 + 12, tapa_y1 - 12])
            translate([tapa_x1 + 8, y, -1]) cylinder(d = tornillo_d, h = tapa_t + 2, $fn = 20);
    }
}
module cortes_traseros() {
    translate([ventana_hp_x, D - pared - 1, ventana_hp_z]) rotate([-90, 0, 0])
        translate([0, -ventana_hp[1], 0]) caja_r([ventana_hp[0], ventana_hp[1], pared + 2], 2);
    // HP v2: lateral izquierdo: ventana del I/O frontal del HP, pulsador de encendido y LED [PENDIENTE medidas]
    if (hp_desnuda) {
        translate([-1, io_frontal_y + 4, io_frontal_z + 4]) cube([pared + 2, io_frontal[1] - 8, io_frontal[2] - 8]);
        translate([-1, boton_hp_y, boton_hp_z]) rotate([0, 90, 0]) cylinder(d = boton_hp_d + 0.2, h = pared + 2);
        translate([-1, boton_hp_y, boton_hp_z + 14]) rotate([0, 90, 0]) cylinder(d = 3.1, h = pared + 2);   // LED 3 mm
    }
    translate([pasacables_x, D - pared - 1, pasacables_z]) rotate([-90, 0, 0])
        translate([0, -pasacables[1], 0]) caja_r([pasacables[0], pasacables[1], pared + 2], 4);
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
