// ORBIT TERMINAL · utilidades geométricas · PROVISIONAL
include <params.scad>

// --- Perfil lateral (plano Y-Z) en dos piezas convexas solapadas ------
// A: labio frontal (bloque bajo).  B: cuña principal.
module perfil_A(d = 0) {
    offset(delta = -d) offset(r = radio_borde) offset(delta = -radio_borde)
        polygon([[0,0],[y_pend0 + 25, 0],[y_pend0 + 25, alto_frontal],[0, alto_frontal]]);
}
module perfil_B(d = 0) {
    ext = y_pend0 - 2;   // la prolongación queda oculta dentro del labio A
    offset(delta = -d) offset(r = radio_borde) offset(delta = -radio_borde)
        polygon([[y_pend0 - ext, 0],[D, 0],[D, H],[y_pend1, H],
                 [y_pend0, alto_frontal],
                 [y_pend0 - ext, alto_frontal - ext * tan(inclinacion)]]);
}

// Extruye un perfil 2D (Y,Z) a lo largo de X entre x0 y x1
module extruir_x(x0, x1) {
    translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0) children();
}

// Pieza convexa con chaflán en ambos extremos X
module pieza_chaflan(cual) {
    hull() {
        extruir_x(0, 0.01)            { if (cual == "A") perfil_A(chaflan_lat); else perfil_B(chaflan_lat); }
        extruir_x(chaflan_lat, W - chaflan_lat) { if (cual == "A") perfil_A(); else perfil_B(); }
        extruir_x(W - 0.01, W)        { if (cual == "A") perfil_A(chaflan_lat); else perfil_B(chaflan_lat); }
    }
}

// Sólido exterior completo
module cuerpo_exterior() { union() { pieza_chaflan("A"); pieza_chaflan("B"); } }

// Volumen interior (desplazado d hacia dentro además de la pared)
module volumen_interior(extra = 0) {
    t = pared + extra;
    extruir_x(t, W - t) union() { perfil_A(t); perfil_B(t); }
}

// Sistema de coordenadas sobre la pendiente:
// origen en el pliegue frontal (x=0, y=y_pend0, z=alto_frontal),
// X local = X, Y local = subiendo la pendiente, Z local = normal exterior.
module en_pendiente() {
    translate([0, y_pend0, alto_frontal]) rotate([inclinacion, 0, 0]) children();
}
// Transforma un punto local de la pendiente a coordenadas mundo
function pend_a_mundo(p) = [p[0],
    y_pend0 + p[1]*cos(inclinacion) - p[2]*sin(inclinacion),
    alto_frontal + p[1]*sin(inclinacion) + p[2]*cos(inclinacion)];

// Torreta para inserto térmico M3
module torreta(h, d = boss_d) {
    difference() {
        cylinder(d = d, h = h);
        translate([0, 0, -0.01]) cylinder(d = inserto_d, h = inserto_l + 0.5);
    }
}

// Caja redondeada en planta (XY)
module caja_r(s, r = 3) {
    hull() for (x = [r, s[0]-r], y = [r, s[1]-r]) translate([x, y, 0]) cylinder(r = r, h = s[2]);
}

// Centro del alojamiento de pantalla (local) y del área activa
aloj_x0 = marco_lat;
aloj_y0 = marco_inf;
act_cx = aloj_x0 + aloj_w/2 + act_off_x;
act_cy = aloj_y0 + aloj_h/2 + act_off_y;

// Posiciones de mandos (local, sobre la pendiente)
pod_cx = pod_x0 + ancho_pod/2;
pos_knobs   = disposicion_mandos == "fila"
    ? [[pod_cx - knob_sep/2, knob_v], [pod_cx + knob_sep/2, knob_v]]
    : [[pod_cx, knob_v], [pod_cx, knob_v - knob_sep]];          // columna: superior e inferior
pos_botones = [[pod_cx - boton_sep/2, boton_v], [pod_cx + boton_sep/2, boton_v]];

// --- Puertos laterales del MSI MP161 E2U -----------------------------------
// [FUENTE] manual oficial (PRO-MP161-E2-English.pdf, "Overview of the monitor") y
// reseña de PCMag: botón de encendido, tecla arriba/abajo, Type-C2, Type-C1 y Mini-HDMI
// están en el CANTO DERECHO. Posición exacta a lo largo del canto: [PENDIENTE medir].
// Fracciones de aloj_h medidas desde el borde inferior (v local = subiendo la pendiente).
osd_v0 = 0.66; osd_v1 = 0.92;       // [PENDIENTE] botón de encendido + tecla arriba/abajo
puertos_v0 = 0.14; puertos_v1 = 0.60;   // [PENDIENTE] Type-C2, Type-C1, Mini-HDMI
osd_ancho = 13;                      // [DISEÑO] ventana para pulsar las teclas del canto con el dedo
puertos_hueco = 28;                  // [DISEÑO] espacio lateral para clavijas acodadas (cables en L de serie)

// Tornillos del bisel (local): esquinas + 1/4 y 3/4 de cada lado
bisel_sol = 9;          // [DISEÑO] solape del bisel más allá del alojamiento
bisel_t   = 3;          // [DISEÑO] espesor del bisel
function torn_bisel() = let(
    x0 = aloj_x0 - bisel_sol/2, x1 = aloj_x0 + aloj_w + bisel_sol/2,
    y0 = aloj_y0 - bisel_sol/2, y1 = aloj_y0 + aloj_h + bisel_sol/2)
    [ [x0,y0],[x1,y0],[x0,y1],[x1,y1],
      [x0 + (x1-x0)*0.25, y0],[x0 + (x1-x0)*0.75, y0],
      [x0 + (x1-x0)*0.25, y1],[x0 + (x1-x0)*0.75, y1],
      [x0, y0 + (y1-y0)*0.25],[x0, y0 + (y1-y0)*0.75],
      [x1, y0 + (y1-y0)*0.25],[x1, y0 + (y1-y0)*0.75] ];

// Orejetas de unión carcasa-base (posiciones XY), evitando planos de corte
function lejos_de_cortes(v, n, L, m = 18) =
    min([for (i = [1:1:n-1]) abs(v - L*i/n)]) > m;
orejetas = concat(
    [for (x = [40 : 95 : W-30]) if (nx_cortes < 2 || lejos_de_cortes(x, nx_cortes, W)) [x, pared + 15]],  // tras el carril LED
    [for (x = [40 : 95 : W-30]) if ((nx_cortes < 2 || lejos_de_cortes(x, nx_cortes, W))
        && (x < hp_x - 6 || x > hp_x + hp_w + 10)) [x, D - pared - 5]],   // no tapar la ventana I/O del HP
    [[hp_x + hp_w + 10, D - pared - 5]],   // orejeta junto a la ventana del HP
    [for (y = [45 : 80 : D-40]) if (ny_cortes < 2 || lejos_de_cortes(y, ny_cortes, D)) [pared + 5, y]],
    [for (y = [45 : 80 : D-40]) if (ny_cortes < 2 || lejos_de_cortes(y, ny_cortes, D)) [W - pared - 5, y]]
);
