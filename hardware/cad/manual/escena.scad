// ORBIT TERMINAL · escenas del manual de montaje.
// No incluye ensamblaje.scad ni partes.scad: los dos emiten geometría.
// Vista previa (sin --render): si no, color() del padre no llega al PNG.
//   openscad -o salida.png -D 'escena="conjunto"' --imgsize=1400,980 \
//     --camera=0,0,0,58,0,30,0 --projection=ortho --viewall --autocenter \
//     hardware/cad/manual/escena.scad
include <../componentes.scad>

escena  = "conjunto";
resalte = "";
sep     = 64;
alz     = 55;

GRIS = [0.58, 0.59, 0.62];
RES  = [0.93, 0.46, 0.08];
TINTA = [0.12, 0.12, 0.13];

module celda(i, j, nx, ny, x0, x1, y0, y1, z0 = -50, z1 = 400) {
    xa = i == 0 ? x0 - 50 : x0 + (x1 - x0) * i / nx;
    xb = i == nx - 1 ? x1 + 50 : x0 + (x1 - x0) * (i + 1) / nx;
    ya = j == 0 ? y0 - 50 : y0 + (y1 - y0) * j / ny;
    yb = j == ny - 1 ? y1 + 50 : y0 + (y1 - y0) * (j + 1) / ny;
    translate([xa, ya, z0]) cube([xb - xa, yb - ya, z1 - z0]);
}

function marcado(n) = resalte == n || resalte == "todo";
function tinta(n) = marcado(n) ? RES : GRIS;

bis_x0 = aloj_x0 - bisel_sol;
bis_x1 = aloj_x0 + aloj_w + bisel_sol;
bis_y0 = aloj_y0 - bisel_sol;
bis_y1 = aloj_y0 + aloj_h + bisel_sol;
nbx = ceil((bis_x1 - bis_x0) / (cama_x - margen_cama));
nby = ceil((bis_y1 - bis_y0) / (cama_y - margen_cama));
nrm = [0, -sin(inclinacion), cos(inclinacion)];

module cuadrante_base(ix, iy) {
    intersection() {
        base();
        celda(ix, iy, nx_cortes, ny_cortes, 0, W, 0, D, -8, 30);
    }
}
module cuadrante_carcasa(ix, iy) {
    intersection() {
        carcasa_superior();
        celda(ix, iy, nx_cortes, ny_cortes, 0, W, 0, D);
    }
}
module dentro(x, y, z, dx, dy, dz) {
    intersection() {
        children();
        translate([x, y, z]) cube([dx, dy, dz]);
    }
}

// Pletinas sobre los pares de torretas de empalmes().
// El par (k, k+1) sale de empalmes(): 0..3 a lo largo de X, 4..7 a lo largo de Y.
module pletinas_puestas(z) {
    pts = empalmes();
    for (k = [0, 2]) {
        mx = (pts[k][0] + pts[k + 1][0]) / 2;
        my = (pts[k][1] + pts[k + 1][1]) / 2;
        color(tinta("pletinas"))
            translate([mx - 15, my - 5, z]) pletina_empalme();
    }
    for (k = [4, 6]) {
        mx = (pts[k][0] + pts[k + 1][0]) / 2;
        my = (pts[k][1] + pts[k + 1][1]) / 2;
        color(tinta("pletinas"))
            translate([mx + 5, my - 15, z]) rotate([0, 0, 90]) pletina_empalme();
    }
}

module bases_sueltas(s, zextra) {
    for (ix = [0 : nx_cortes - 1], iy = [0 : ny_cortes - 1])
        color(tinta("bases"))
            translate([(ix - 0.5) * s, (iy - 0.5) * s, zextra])
                cuadrante_base(ix, iy);
}
module carcasas_sueltas(s, zextra) {
    for (ix = [0 : nx_cortes - 1], iy = [0 : ny_cortes - 1])
        color(tinta(str("carcasa_", ix, "_", iy)))
            translate([(ix - 0.5) * s, (iy - 0.5) * s, zextra])
                cuadrante_carcasa(ix, iy);
}

module electronica_sin_cables() {
    hp_marcador();
    pi_marcador();
    mandos_marcador();
    arduino_marcador();
    placas_fantasma(false, false);
    color(C_AMBAR) translate([luz_margen, pared + 4.4, luz_z0 + luz_alto/2 - 5])
        cube([W - 2*luz_margen, 1.5, 10]);
}

module guias_luz_montadas() {
    color(C_AMBAR) for (k = [0 : n_guia - 1]) let(t = tramo_guia(k))
        guia_luz_frontal(t[0], t[1], k == 0 ? 3 : 0, k == n_guia - 1 ? 3 : 0);
}

// Placa I/O: x local hacia −X (el DC de la tabla queda a +X del mundo),
// y local hacia +Z, z local hacia fuera (+Y). `salida` la separa hacia
// atrás para verla; el montaje real entra por dentro.
module placa_io_en_ventana(salida) {
    color(tinta("placa_io"))
        translate([ventana_hp_x + ventana_hp[0],
                   D - pared - io_placa_t + salida,
                   ventana_hp_z])
            rotate([-90, 0, 0]) rotate([0, 0, 180])
                placa_io_hp();
}

module linea(a, b, c = [0.15, 0.15, 0.16]) {
    color(c) hull() {
        translate(a) cylinder(d = 3.2, h = 1.6, $fn = 10);
        translate(b) cylinder(d = 3.2, h = 1.6, $fn = 10);
    }
}
module rotulo(p, s, h = 6.5) {
    color(TINTA) translate(p)
        linear_extrude(0.6)
            text(s, size = h, font = "Liberation Sans", halign = "left", valign = "center");
}
module ficha(x, y, w, h, c, lineas) {
    color(c) translate([x, y, 0]) cube([w, h, 2.4]);
    for (i = [0 : len(lineas) - 1])
        rotulo([x + 4, y + h - 10 - i * 8.2, 2.6], lineas[i], 6.4);
}

module diagrama_cableado() {
    // Solo uniones que los README del firmware y el CAD dan por sabidas.
    // Donde falta el recorrido, la ficha lo dice y no sale ningún hilo.
    rotulo([0, 292, 3], "Conexiones conocidas. Lo gris no lleva hilo.", 9);
    ficha(0, 210, 118, 62, RES, ["Adaptador HP", "19,5 V   65 W", "queda FUERA"]);
    ficha(168, 210, 108, 62, RES, ["Jack DC", "I/O trasero", "de la placa"]);
    ficha(320, 200, 120, 72, [0.10, 0.38, 0.20], ["Placa HP", "Slimline", "mini-ITX"]);
    linea([118, 240, 1.2], [168, 240, 1.2]);
    linea([276, 240, 1.2], [320, 236, 1.2]);

    ficha(0, 118, 130, 68, [0.20, 0.42, 0.68], ["Nano mandos", "mini-USB  115200", "ejemplo ttyUSB"]);
    ficha(320, 118, 130, 68, [0.12, 0.48, 0.28], ["Pi 4", "recibe el USB", "puerto PENDIENTE"]);
    linea([130, 150, 1.2], [320, 150, 1.2], [0.10, 0.28, 0.55]);
    rotulo([148, 164, 3], "USB. Cual de los 4: PENDIENTE", 6.2);

    ficha(0, 28, 130, 68, [0.20, 0.42, 0.68], ["Nano practicas", "SDA A4   SCL A5", "direccion 0x3C"]);
    ficha(200, 28, 130, 68, RES, ["OLED 0,96", "SSD1306", "1 kohm en SDA/SCL"]);
    linea([130, 62, 1.2], [200, 62, 1.2], [0.45, 0.22, 0.08]);
    rotulo([142, 76, 3], "I2C", 7);

    ficha(0, -70, 130, 72, [0.18, 0.24, 0.55], ["ESP8266", "GPIO2 (D4)", "dato de WLED"]);
    ficha(200, -70, 150, 72, [0.75, 0.75, 0.78], ["Tira LED", "tension PENDIENTE", "no desde 3,3 V"]);
    linea([130, -34, 1.2], [200, -34, 1.2], [0.55, 0.38, 0.08]);
    rotulo([136, -18, 3], "solo el dato", 6.2);

    ficha(360, 28, 140, 68, GRIS, ["Step-down", "modelo PENDIENTE", "sin cablear"]);
    ficha(470, 200, 140, 72, GRIS, ["MSI MP161", "USB-C propio", "mas de 15 W"]);
    rotulo([0, -102, 3], "Masa de la tira unida a la del ESP. Sin red dentro de Orbit.", 6.4);
    rotulo([0, -116, 3], "Cabezal de 40 pines de la Pi: no cablear. El HAT es PENDIENTE.", 6.4);
    rotulo([0, -130, 3], "Step-down, desplazador y dongle de captura: PENDIENTE. Sin hilo.", 6.4);
}

if (escena == "check") {
    echo(str("MANUAL_PAS_X;", len(pos_pasadores_x())));
    echo(str("MANUAL_PAS_Y;", len(pos_pasadores_y(corte_y(1)))));
    echo(str("MANUAL_ZSUP;", z_sup(corte_y(1))));
    echo(str("MANUAL_OREJ;", len(orejetas)));
    for (p = orejetas)
        echo(str("MANUAL_OREJ;", p[0], ";", p[1], ";",
                 (p[0] >= corte_x(1) && p[1] >= corte_y(1)) ? "auto" : "inserto"));
    echo(str("MANUAL_EMP;", len(empalmes())));
    echo(str("MANUAL_BISEL_TORN;", len(torn_bisel())));
    echo(str("MANUAL_BISEL_REJ;", nbx, ";", nby));
    echo(str("MANUAL_CORTES;", nx_cortes, ";", ny_cortes, ";", corte_x(1), ";", corte_y(1)));
    echo(str("MANUAL_NGUIA;", n_guia));
    echo(str("MANUAL_ENV;", W, ";", D, ";", H));
    for (i = [0 : len(hp_agujeros()) - 1])
        echo(str("MANUAL_HPAG;", i, ";", hp_agujeros()[i][0], ";", hp_agujeros()[i][1]));
    cube(1);
} else if (escena == "conjunto") {
    // Carcasa + base solas. Meter bisel, mandos y marcadores en el mismo
    // árbol pasa de 100000 elementos y OpenSCAD deja el PNG vacío.
    color(GRIS) base();
    color(RES) carcasa_superior();
} else if (escena == "piezas") {
    color(RES) pletina_empalme();
    color(RES) translate([48, 18, 0]) pomo();
    color(RES) translate([96, 18, 0]) anillo_luz();
    color(RES) translate([0, -28, 0]) guia_luz_frontal(0, 180, 3, 3);
    color(RES) translate([0, 70, 0]) placa_io_hp();
    color(GRIS) translate([190, 78, 0]) prueba_placa_io_hp();
    color(RES) translate([-tapa_x0, 150 - tapa_y0, 0]) tapa_pi();
    color(RES) translate([-180 - disco_x, 20 - disco_y, 0]) soporte_disco();
    color(RES) translate([-40 - (serv_x - serv_ala), 200 - (serv_y - serv_ala), 2])
        bandeja_servicio();
} else if (escena == "base_expl") {
    bases_sueltas(sep, 0);
    pletinas_puestas(suelo + 5);
} else if (escena == "pletinas") {
    color(GRIS) base();
    pletinas_puestas(suelo + 16);
} else if (escena == "zoom_pletina") {
    // Sin recorte: la cámara encuadra la junta. El recorte por intersection
    // infla la caja de la vista previa y viewall se aleja.
    color(GRIS) cuadrante_base(0, 1);
    color(GRIS) cuadrante_base(1, 1);
    pletinas_puestas(suelo + 12);
} else if (escena == "carcasa_expl") {
    carcasas_sueltas(sep, 0);
} else if (escena == "zoom_pasador") {
    color(tinta("carcasa_0_1")) translate([-sep / 2, 0, 0]) cuadrante_carcasa(0, 1);
    color(GRIS) translate([sep / 2, 0, 0]) cuadrante_carcasa(1, 1);
} else if (escena == "carcasa_base") {
    color(GRIS) base();
    color(RES) translate([0, 0, alz]) carcasa_superior();
} else if (escena == "zoom_oreja_auto") {
    color(GRIS) cuadrante_base(1, 1);
    color(RES) translate([0, 0, 18]) cuadrante_carcasa(1, 1);
} else if (escena == "zoom_oreja_inserto") {
    color(GRIS) cuadrante_base(0, 1);
    color(RES) translate([0, 0, 18]) cuadrante_carcasa(0, 1);
} else if (escena == "hp") {
    color(GRIS) base();
    color(RES) soporte_disco();
    hp_placa_marcador();
} else if (escena == "zoom_separador") {
    color(GRIS) base();
    hp_placa_marcador();
} else if (escena == "placa_io") {
    color(GRIS) cuadrante_carcasa(0, 1);
    placa_io_en_ventana(36);
} else if (escena == "io_frontal") {
    color(GRIS) cuadrante_carcasa(0, 1);
    hp_placa_marcador();
    // El agujero del LED de 3 mm está en la carcasa. El LED en sí no está medido.
    color([0.85, 0.15, 0.12])
        translate([-1, boton_hp_y, boton_hp_z + 14])
            rotate([0, 90, 0]) cylinder(d = 3, h = pared + 6, $fn = 16);
} else if (escena == "bandeja") {
    color(GRIS) base();
    translate([0, 0, 40]) {
        color(RES) bandeja_servicio();
        placas_fantasma();
        pi_marcador();
        arduino_marcador();
    }
} else if (escena == "bandeja_planta") {
    color(RES) bandeja_servicio();
    placas_fantasma();
    pi_marcador();
    arduino_marcador();
} else if (escena == "zoom_hueco") {
    color(RES) bandeja_servicio();
    placas_fantasma(false, false);
} else if (escena == "tapa") {
    color(GRIS) cuadrante_carcasa(1, 1);
    color(RES) translate([0, 0, H - tapa_t + 28]) tapa_pi();
} else if (escena == "panel") {
    color(GRIS) cuadrante_carcasa(1, 1);
    color(RES) translate([oled_cx - oled_mod[0]/2,
                          D - pared - 1.5 - oled_mod[1] - 14,
                          oled_cz - oled_mod[2]/2])
        cube(oled_mod);
} else if (escena == "bisel") {
    color(GRIS) carcasa_superior();
    color([0.25, 0.25, 0.27]) monitor();
    for (ix = [0 : nbx - 1], iy = [0 : nby - 1])
        color(tinta(ix == 0 && iy == 0 ? "bisel" : "otro"))
            translate(nrm * ((ix == 0 && iy == 0) ? 22 : 8))
                en_pendiente()
                    translate([(ix - 0.5) * 18, (iy - 0.5) * 18, 0])
                        intersection() {
                            bisel_local();
                            celda(ix, iy, nbx, nby, bis_x0, bis_x1, bis_y0, bis_y1, -6, 16);
                        }
} else if (escena == "mandos") {
    color(GRIS) carcasa_superior();
    translate(nrm * 24) mandos_montados();
    translate([0, -32, 14]) guias_luz_montadas();
} else if (escena == "cableado") {
    diagrama_cableado();
} else {
    echo(str("ESCENA_DESCONOCIDA;", escena));
    cube(1);
}
