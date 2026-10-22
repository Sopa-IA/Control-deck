// ORBIT TERMINAL · un subpaso del manual por imagen.
// Vista previa, sin --render: si no, el naranja no llega al PNG.
// Lo que se añade va en naranja. Lo ya montado, en gris.
// El número marca el agujero. El tornillo sale explotado hacia el lado por donde entra.
// No incluye ensamblaje.scad ni partes.scad (los dos emiten geometría).
include <../componentes.scad>

sub = "portada";

GRIS   = [0.58, 0.59, 0.62];
RES    = [0.93, 0.46, 0.08];
TUERCA = [0.78, 0.76, 0.72];
ARAND  = [0.90, 0.91, 0.93];
TINTA  = [0.10, 0.10, 0.12];
BLANCO = [0.97, 0.97, 0.96];

module celda(i, j, nx, ny, x0, x1, y0, y1, z0 = -50, z1 = 400) {
    xa = i == 0 ? x0 - 50 : x0 + (x1 - x0) * i / nx;
    xb = i == nx - 1 ? x1 + 50 : x0 + (x1 - x0) * (i + 1) / nx;
    ya = j == 0 ? y0 - 50 : y0 + (y1 - y0) * j / ny;
    yb = j == ny - 1 ? y1 + 50 : y0 + (y1 - y0) * (j + 1) / ny;
    translate([xa, ya, z0]) cube([xb - xa, yb - ya, z1 - z0]);
}

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

bis_x0 = aloj_x0 - bisel_sol;
bis_x1 = aloj_x0 + aloj_w + bisel_sol;
bis_y0 = aloj_y0 - bisel_sol;
bis_y1 = aloj_y0 + aloj_h + bisel_sol;
nbx = ceil((bis_x1 - bis_x0) / (cama_x - margen_cama));
nby = ceil((bis_y1 - bis_y0) / (cama_y - margen_cama));
nrm = [0, -sin(inclinacion), cos(inclinacion)];

// La pletina apoya en la torreta. La torreta sale 5 mm del suelo.
z_pletina = suelo + 5;
// El ala de la bandeja (2 mm, de z = −2 a 0) apoya en esa misma torreta.
z_bandeja = z_pletina - (-serv_ala_t);

function es_guia(p) = p[0] >= corte_x(1) && p[1] >= corte_y(1);
function orej_guia() = [for (p = orejetas) if (es_guia(p)) p];
function orej_paso() = [for (p = orejetas) if (!es_guia(p)) p];
function orej_frente() = [for (p = orejetas) if (p[1] < 40) p];
function orej_izq() = [for (p = orejetas) if (p[0] < 20) p];
function orej_resto() = [for (p = orejetas) if (!es_guia(p) && p[1] >= 40 && p[0] >= 20) p];

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

// Entra desde arriba. La arandela, si la hay, va bajo la cabeza.
module torn_arriba(x, y, z, n, arandela = false) {
    color(RES) translate([x, y, z + 14]) cylinder(d = 3.2, h = 11, $fn = 14);
    color(RES) translate([x, y, z + 25]) cylinder(d = 6.2, h = 2.6, $fn = 16);
    if (arandela)
        color(ARAND) translate([x, y, z + 12]) cylinder(d = 9, h = 1.1, $fn = 20);
    color(RES) translate([x, y, z + 3]) cylinder(d1 = 1.2, d2 = 5.2, h = 7, $fn = 12);
    n_en(x + 8, y + 7, z + 16, n);
}
// Entra desde abajo. El tornillo se dibuja al lado, en el aire, para verlo
// desde arriba: debajo de la base la cámara no lo alcanza.
module torn_abajo(x, y, n, avellanado = false, z = 18) {
    // Hacia el interior, para que no quede fuera de la pared.
    ox = x < W / 2 ? 16 : -16;
    oy = y < D / 2 ? 10 : -10;
    color(RES) translate([x + ox, y + oy, z]) cylinder(d = 3.4, h = 12, $fn = 14);
    if (avellanado)
        color(RES) translate([x + ox, y + oy, z - 4]) cylinder(d1 = 6.6, d2 = 3.4, h = 3.4, $fn = 16);
    else
        color(RES) translate([x + ox, y + oy, z - 3]) cylinder(d = 6.2, h = 2.6, $fn = 16);
    color(RES) translate([x, y, z - 12]) cylinder(d1 = 1.3, d2 = 6, h = 8, $fn = 12);
    n_en(x + ox * 0.4, y + oy * 0.5, z + 4, n);
}
module tuerca_abajo(x, y) {
    color(TUERCA) translate([x, y, -8]) rotate([0, 0, 30]) cylinder(d = 7.2, h = 2.6, $fn = 6);
}
module anillo(x, y, z, n) {
    color(RES) translate([x, y, z]) difference() {
        cylinder(d = 14, h = 1.4, $fn = 24);
        translate([0, 0, -0.4]) cylinder(d = 5, h = 2.4, $fn = 18);
    }
    n_en(x + 10, y + 8, z + 2, n);
}

module pletina_par(k, z, col) {
    pts = empalmes();
    mx = (pts[k][0] + pts[k + 1][0]) / 2;
    my = (pts[k][1] + pts[k + 1][1]) / 2;
    color(col) {
        if (k < 4)
            translate([mx - 15, my - 5, z]) pletina_empalme();
        else
            translate([mx + 5, my - 15, z]) rotate([0, 0, 90]) pletina_empalme();
    }
}
module tornillos_par(k) {
    pts = empalmes();
    for (i = [0 : 1]) {
        torn_arriba(pts[k + i][0], pts[k + i][1], z_pletina + 18, i + 1);
        tuerca_abajo(pts[k + i][0], pts[k + i][1]);
    }
}
module bases(ixs, iys) {
    for (ix = ixs, iy = iys)
        color(GRIS) cuadrante_base(ix, iy);
}

module losa(x, y, z, lx, ly, h) {
    color(RES) translate([x, y, z]) cube([lx, ly, h]);
}

// Placa I/O: x local hacia −X, y local hacia +Z, z local hacia fuera (+Y).
module placa_io_en_ventana(salida) {
    color(RES)
        translate([ventana_hp_x + ventana_hp[0],
                   D - pared - io_placa_t + salida,
                   ventana_hp_z])
            rotate([-90, 0, 0]) rotate([0, 0, 180])
                placa_io_hp();
}

module bisel_trozo(ix, iy) {
    intersection() {
        bisel_local();
        celda(ix, iy, nbx, nby, bis_x0, bis_x1, bis_y0, bis_y1, -8, 20);
    }
}

module marca_orejas(lista) {
    for (i = [0 : len(lista) - 1])
        anillo(lista[i][0], lista[i][1], 6, i + 1);
}
module atornilla_orejas(lista) {
    for (i = [0 : len(lista) - 1])
        torn_abajo(lista[i][0], lista[i][1], i + 1, true);
}

module hueco(b, z, h) {
    losa(b[0], b[1], z, b[2], b[3], h);
}
module tornillos_de(pts, z, arandela) {
    for (i = [0 : len(pts) - 1])
        torn_arriba(pts[i][0], pts[i][1], z, i + 1, arandela);
}

module ficha(x, y, w, h, c, lineas) {
    color(c) translate([x, y, 0]) cube([w, h, 2.2]);
    for (i = [0 : len(lineas) - 1])
        color(TINTA) translate([x + 4, y + h - 9 - i * 7.4, 2.4])
            linear_extrude(0.5)
                text(lineas[i], size = 5.6, font = "Liberation Sans",
                     halign = "left", valign = "center");
}
module hilo(a, b, activo) {
    color(activo ? RES : [0.62, 0.63, 0.66]) hull() {
        translate(a) cylinder(d = 3.4, h = 1.2, $fn = 10);
        translate(b) cylinder(d = 3.4, h = 1.2, $fn = 10);
    }
}
module diagrama(cual) {
    color(TINTA) translate([0, 250, 3])
        linear_extrude(0.5)
            text("Solo las uniones que ya estan escritas. Lo gris no se cablea.",
                 size = 6.4, font = "Liberation Sans", halign = "left");
    ficha(0, 176, 112, 58, cual == "dc" || cual == "todo" ? RES : GRIS,
          ["Adaptador HP", "19,5 V  65 W", "queda fuera"]);
    ficha(250, 176, 120, 58, cual == "dc" || cual == "todo" ? RES : GRIS,
          ["Jack DC", "placa HP", "I/O trasero"]);
    hilo([112, 204, 1], [250, 204, 1], cual == "dc" || cual == "todo");

    ficha(0, 96, 124, 58, cual == "usb" || cual == "todo" ? RES : GRIS,
          ["Nano mandos", "mini-USB", "115200"]);
    ficha(250, 96, 120, 58, cual == "usb" || cual == "todo" ? RES : GRIS,
          ["Pi 4", "un USB", "cual: sin medir"]);
    hilo([124, 124, 1], [250, 124, 1], cual == "usb" || cual == "todo");

    ficha(0, 16, 124, 58, cual == "i2c" || cual == "todo" ? RES : GRIS,
          ["Nano practicas", "SDA A4  SCL A5", "0x3C"]);
    ficha(250, 16, 120, 58, cual == "i2c" || cual == "todo" ? RES : GRIS,
          ["OLED 0,96", "SSD1306", "1 kohm"]);
    hilo([124, 44, 1], [250, 44, 1], cual == "i2c" || cual == "todo");

    ficha(0, -64, 124, 58, cual == "led" || cual == "todo" ? RES : GRIS,
          ["ESP8266", "GPIO2 (D4)", "dato"]);
    ficha(250, -64, 140, 58, cual == "led" || cual == "todo" ? RES : GRIS,
          ["Tira", "tension sin medir", "no desde 3,3 V"]);
    hilo([124, -36, 1], [250, -36, 1], cual == "led" || cual == "todo");

    ficha(400, 176, 130, 58, GRIS, ["Step-down", "sin medir", "sin hilo"]);
    ficha(400, 96, 130, 58, GRIS, ["MSI", "USB-C propio", "mas de 15 W"]);
}

if (sub == "check") {
    echo(str("N_GUIA_OREJ;", len(orej_guia())));
    echo(str("N_PASO_OREJ;", len(orej_paso())));
    echo(str("N_FRENTE;", len(orej_frente())));
    echo(str("N_IZQ;", len(orej_izq())));
    echo(str("N_RESTO;", len(orej_resto())));
    echo(str("N_TRAS;", len([for (p = orej_resto()) if (p[0] < corte_x(1)) p])));
    echo(str("N_DER;", len([for (p = orej_resto()) if (p[0] > corte_x(1)) p])));
    echo(str("N_PAS_X;", len(pos_pasadores_x())));
    echo(str("N_PAS_Y;", len(pos_pasadores_y(corte_y(1)))));
    echo(str("N_EMP;", len(empalmes())));
    echo(str("N_BISEL;", len(torn_bisel())));
    echo(str("N_DISCO;", len(torretas_disco())));
    echo(str("N_BAND;", len(torretas_bandeja())));
    echo(str("NBX;", nbx, ";", nby));
    cube(1);
} else if (sub == "portada") {
    color(GRIS) base();
    color(RES) carcasa_superior();
} else if (sub == "1.1") {
    for (ix = [0 : 1], iy = [0 : 1]) {
        color(RES) translate([(ix - 0.5) * 78, (iy - 0.5) * 78, 0])
            cuadrante_base(ix, iy);
        n_en((ix - 0.5) * 78 + 70, (iy - 0.5) * 78 + 50, 16, iy * 2 + ix + 1);
    }
} else if (sub == "1.2") {
    bases([0, 1], [0]);
    pletina_par(0, z_pletina + 16, RES);
    tornillos_par(0);
} else if (sub == "1.3") {
    bases([0, 1], [1]);
    pletina_par(2, z_pletina + 16, RES);
    tornillos_par(2);
} else if (sub == "1.4") {
    bases([0], [0, 1]);
    pletina_par(4, z_pletina + 16, RES);
    tornillos_par(4);
} else if (sub == "1.5") {
    bases([1], [0, 1]);
    pletina_par(6, z_pletina + 16, RES);
    tornillos_par(6);
} else if (sub == "2.1") {
    color(GRIS) translate([0, -28, 0]) cuadrante_carcasa(0, 0);
    color(RES) translate([0, 28, 0]) cuadrante_carcasa(0, 1);
    izq = [for (p = pos_pasadores_y(corte_y(1))) if (p[0] < W / 2) p];
    for (i = [0 : len(izq) - 1]) {
        color(RES) translate([izq[i][0], corte_y(1) - 8, izq[i][1]])
            rotate([-90, 0, 0]) cylinder(d = 3.1, h = 16, $fn = 14);
        n_en(izq[i][0] + 14, corte_y(1), izq[i][1], i + 1);
    }
} else if (sub == "2.2") {
    color(GRIS) translate([0, -28, 0]) cuadrante_carcasa(1, 0);
    color(RES) translate([0, 28, 0]) cuadrante_carcasa(1, 1);
    der = [for (p = pos_pasadores_y(corte_y(1))) if (p[0] > W / 2) p];
    for (i = [0 : len(der) - 1]) {
        color(RES) translate([der[i][0], corte_y(1) - 8, der[i][1]])
            rotate([-90, 0, 0]) cylinder(d = 3.1, h = 16, $fn = 14);
        n_en(der[i][0] - 16, corte_y(1), der[i][1], i + 1);
    }
} else if (sub == "2.3") {
    color(GRIS) translate([-28, 0, 0]) cuadrante_carcasa(0, 1);
    color(RES) translate([28, 0, 0]) cuadrante_carcasa(1, 1);
    px = pos_pasadores_x();
    for (i = [0 : len(px) - 1]) {
        color(RES) translate([corte_x(1) - 8, px[i][0], px[i][1]])
            rotate([0, -90, 0]) cylinder(d = 3.1, h = 16, $fn = 14);
        n_en(corte_x(1), px[i][0] + 12, px[i][1] + 8, i + 1);
    }
} else if (sub == "3.1") {
    color(GRIS) base();
    marca_orejas(orej_paso());
} else if (sub == "3.2") {
    color(GRIS) base();
    color(RES) translate([0, 0, 48]) carcasa_superior();
} else if (sub == "3.3") {
    color(GRIS) cuadrante_base(1, 1);
    color(GRIS) translate([0, 0, 78]) cuadrante_carcasa(1, 1);
    atornilla_orejas(orej_guia());
} else if (sub == "3.4") {
    bases([0, 1], [0]);
    for (ix = [0, 1]) color(GRIS) translate([0, 0, 78]) cuadrante_carcasa(ix, 0);
    atornilla_orejas(orej_frente());
} else if (sub == "3.5") {
    bases([0], [0, 1]);
    for (iy = [0, 1]) color(GRIS) translate([0, 0, 78]) cuadrante_carcasa(0, iy);
    atornilla_orejas(orej_izq());
} else if (sub == "3.6") {
    color(GRIS) cuadrante_base(0, 1);
    color(GRIS) translate([0, 0, 78]) cuadrante_carcasa(0, 1);
    tras = [for (p = orej_resto()) if (p[0] < corte_x(1)) p];
    atornilla_orejas(tras);
} else if (sub == "3.7") {
    color(GRIS) cuadrante_base(1, 0);
    color(GRIS) translate([0, 0, 78]) cuadrante_carcasa(1, 0);
    der = [for (p = orej_resto()) if (p[0] > corte_x(1)) p];
    atornilla_orejas(der);
} else if (sub == "4.1") {
    color(GRIS) base();
    td = torretas_disco();
    for (i = [0 : len(td) - 1]) anillo(td[i][0], td[i][1], 8, i + 1);
} else if (sub == "4.2") {
    color(GRIS) base();
    color(RES) translate([0, 0, 36]) soporte_disco();
    td = torretas_disco();
    for (i = [0 : len(td) - 1]) torn_abajo(td[i][0], td[i][1], i + 1, true);
} else if (sub == "4.3") {
    color(GRIS) soporte_disco();
    losa(disco_x, disco_y, disco_z + 14, disco[0], disco[1], disco[2]);
    xs = [disco_x + disco_ag_lado, disco_x + disco[0] - disco_ag_lado];
    y0 = disco_y + 12;
    y1 = disco_y + disco[1] - 12;
    ys = [y0 + (y1 - y0) * 0.32, y0 + (y1 - y0) * 0.68];
    for (i = [0 : 1], j = [0 : 1])
        torn_abajo(xs[i], ys[j], j * 2 + i + 1, false, disco_z + 8);
} else if (sub == "4.4") {
    color(GRIS) base();
    color(GRIS) soporte_disco();
    losa(hp_x, hp_y, hp_pcb_z + 16, hp_w, hp_d, hp_pcb);
    ag = hp_agujeros();
    for (i = [0 : len(ag) - 1])
        torn_arriba(ag[i][0], ag[i][1], hp_pcb_z + 18, i + 1, false);
} else if (sub == "5.1") {
    color(GRIS) cuadrante_carcasa(0, 1);
    placa_io_en_ventana(34);
    color(RES) translate([ventana_hp_x + ventana_hp[0] / 2, D - 8, ventana_hp_z + ventana_hp[1] / 2])
        rotate([90, 0, 0]) cylinder(d1 = 10, d2 = 2, h = 16, $fn = 12);
} else if (sub == "6.1") {
    // En el banco. La placa imita la pared: 3 mm, Ø12,2 y Ø3,1 a 14 mm.
    color(GRIS) prueba_boton();
    color(RES) translate([0, 0, 5.5]) boton_encendido();
} else if (sub == "6.2") {
    color(GRIS) cuadrante_carcasa(0, 1);
    color(RES) boton_encendido_montado(0);
} else if (sub == "6.3") {
    color(GRIS) cuadrante_carcasa(0, 1);
    color(GRIS) boton_encendido_montado(0);
    color(RES) soporte_boton();
} else if (sub == "6.4") {
    color(GRIS) cuadrante_carcasa(0, 1);
    color(GRIS) soporte_boton();
    color(GRIS) boton_encendido_montado(0);
    // Pulsador y LED, solo en el dibujo: no forman parte del STL.
    color(RES) translate([x_sw0(), boton_hp_y - sw_lado() / 2, boton_hp_z - sw_lado() / 2])
        cube([sw_cuerpo_h(), sw_lado(), sw_lado()]);
    color(RES) translate([x_punta_sw(), boton_hp_y, boton_hp_z])
        rotate([0, 90, 0]) cylinder(d = sw_vastago_d(), h = sw_vastago_h(), $fn = 18);
    color(RES) translate([pared + sop_t + 1.2, boton_hp_y, boton_hp_z + led_hp_dz])
        rotate([0, 90, 0]) cylinder(d = 3, h = 5, $fn = 16);
    color(RES) translate([x_sw1() + 1.6, boton_hp_y - 2.2, boton_hp_z - 1])
        rotate([0, 68, 0]) cylinder(d = 1.15, h = 16, $fn = 8);
    color(RES) translate([x_sw1() + 1.6, boton_hp_y + 2.2, boton_hp_z - 1])
        rotate([0, 74, 0]) cylinder(d = 1.15, h = 16, $fn = 8);
    n_en(x_sw1() + 10, boton_hp_y - 6, boton_hp_z + 6, 1);
    n_en(x_sw1() + 12, boton_hp_y + 8, boton_hp_z + 4, 2);
} else if (sub == "6.5") {
    color(GRIS) cuadrante_carcasa(0, 1);
    losa(-40, io_frontal_y, io_frontal_z, io_frontal[0], io_frontal[1], io_frontal[2]);
    color(RES) translate([-18, io_frontal_y + io_frontal[1] / 2, io_frontal_z + io_frontal[2] / 2])
        rotate([0, 90, 0]) cylinder(d1 = 8, d2 = 2, h = 14, $fn = 12);
} else if (sub == "7.1") {
    color(GRIS) bandeja_servicio();
    losa(pi_x0, pi_y0, pi_z + 10, pi_w, pi_d, 1.6);
    tornillos_de(b3_pi_torn, pi_z + 12, true);
} else if (sub == "7.2") {
    color(GRIS) bandeja_servicio();
    hueco(b3_esp, suelo + b3_pin_z + 8, esp_pcb);
    tornillos_de(tornillos_placa(b3_esp), suelo + b3_pin_z + 10, true);
} else if (sub == "7.3") {
    color(GRIS) bandeja_servicio();
    hueco(b3_prac, suelo + b3_pin_z + 8, ard_pcb);
    tornillos_de(tornillos_placa(b3_prac), suelo + b3_pin_z + 10, true);
} else if (sub == "7.4") {
    color(GRIS) bandeja_servicio();
    hueco(b3_buck, suelo + buck_suelda + 8, buck_pcb);
    pas = agujeros_buck();
    bri = bridas_buck();
    for (i = [0 : len(pas) - 1])
        torn_arriba(pas[i][0], pas[i][1], suelo + buck_suelda + 10, i + 1, false);
    for (i = [0 : len(bri) - 1])
        torn_arriba(bri[i][0], bri[i][1], suelo + buck_suelda + 10, i + 3, true);
} else if (sub == "7.5") {
    color(GRIS) bandeja_servicio();
    hueco(b3_man, suelo + b3_pin_z + 8, ard_pcb);
    tornillos_de(tornillos_placa(b3_man), suelo + b3_pin_z + 10, true);
} else if (sub == "7.6") {
    color(GRIS) base();
    tb = torretas_bandeja();
    for (i = [0 : len(tb) - 1]) anillo(tb[i][0], tb[i][1], z_pletina + 1, i + 1);
} else if (sub == "7.7") {
    color(GRIS) base();
    color(GRIS) translate([0, 0, z_bandeja]) bandeja_servicio();
    tb = torretas_bandeja();
    for (i = [0 : len(tb) - 1]) {
        torn_arriba(tb[i][0], tb[i][1], z_bandeja + 2, i + 1, false);
        tuerca_abajo(tb[i][0], tb[i][1]);
    }
} else if (sub == "8.1") {
    color(GRIS) cuadrante_carcasa(1, 1);
    color(RES) translate([0, 0, 18]) tapa_pi();
    torn_arriba(tapa_x1 + 8, tapa_y0 + 12, H + 16, 1, false);
    torn_arriba(tapa_x1 + 8, tapa_y1 - 12, H + 16, 2, false);
} else if (sub == "9.1") {
    color(GRIS) cuadrante_carcasa(1, 1);
    color(RES) translate([oled_cx - oled_mod[0] / 2, D + 8, oled_cz - oled_mod[2] / 2])
        cube(oled_mod);
    color(RES) translate([oled_cx, D - 2, oled_cz])
        rotate([-90, 0, 0]) cylinder(d1 = 8, d2 = 2, h = 12, $fn = 12);
} else if (sub == "10.1") {
    color(GRIS) carcasa_superior();
    color(RES) en_pendiente()
        translate([aloj_x0, aloj_y0, -aloj_t + 22])
            cube([pant_w, pant_h, pant_t]);
} else if (sub == "10.2") {
    gap = 28;
    for (ix = [0 : nbx - 1], iy = [0 : nby - 1])
        color(RES) translate([ix * gap, iy * gap, 0]) bisel_trozo(ix, iy);
    pts = torn_bisel();
    sx = (bis_x1 - bis_x0) / nbx;
    sy = (bis_y1 - bis_y0) / nby;
    for (i = [0 : len(pts) - 1]) {
        p = pts[i];
        ix = min(nbx - 1, floor((p[0] - bis_x0) / sx));
        iy = min(nby - 1, floor((p[1] - bis_y0) / sy));
        translate([p[0] + ix * gap + 8, p[1] + iy * gap + 7, 5]) numero(i + 1);
        color(RES) translate([p[0] + ix * gap, p[1] + iy * gap, 3])
            difference() {
                cylinder(d = 12, h = 1.2, $fn = 18);
                translate([0, 0, -0.3]) cylinder(d = 4.2, h = 2, $fn = 14);
            }
    }
} else if (sub == "10.3") {
    color(GRIS) carcasa_superior();
    for (ix = [0 : nbx - 1], iy = [0 : nby - 1])
        color(RES) translate(nrm * (16 + ix * 3 + iy * 3))
            en_pendiente() bisel_trozo(ix, iy);
} else if (sub == "10.4") {
    color(GRIS) carcasa_superior();
    for (ix = [0 : nbx - 1], iy = [0 : nby - 1])
        color(GRIS) en_pendiente() bisel_trozo(ix, iy);
    pts = torn_bisel();
    for (i = [0 : len(pts) - 1]) {
        p = pts[i];
        color(RES) en_pendiente() {
            translate([p[0], p[1], 14]) cylinder(d = 3.4, h = 10, $fn = 12);
            translate([p[0], p[1], 24]) cylinder(d1 = 7.2, d2 = 3.4, h = 3, $fn = 14);
            translate([p[0], p[1], 6]) cylinder(d1 = 1.2, d2 = 5, h = 6, $fn = 10);
            translate([p[0] + 9, p[1] + 7, 18]) numero(i + 1);
        }
    }
} else if (sub == "10.5") {
    color(GRIS) carcasa_superior();
    for (k = [0 : n_guia - 1]) {
        t = tramo_guia(k);
        color(RES) translate([0, -16, 6])
            guia_luz_frontal(t[0], t[1], k == 0 ? 3 : 0, k == n_guia - 1 ? 3 : 0);
        n_en((t[0] + t[1]) / 2, 12, 18, k + 1);
    }
} else if (sub == "10.6") {
    color(GRIS) carcasa_superior();
    for (i = [0 : len(pos_knobs) - 1]) {
        p = pos_knobs[i];
        color(RES) translate(nrm * 22)
            en_pendiente() translate([p[0], p[1], -pared]) anillo_luz();
        translate(pend_a_mundo([p[0] + 16, p[1], 18])) numero(i + 1);
    }
} else if (sub == "10.7") {
    color(GRIS) carcasa_superior();
    for (i = [0 : len(pos_knobs) - 1]) {
        p = pos_knobs[i];
        color(RES) translate(nrm * 16)
            en_pendiente() translate([p[0], p[1], 1.2]) pomo();
        color(RES) translate(nrm * 16)
            en_pendiente() translate([p[0] + knob_d / 2 - 1, p[1], 7.2])
                rotate([0, 90, 0]) cylinder(d = 3, h = 14, $fn = 12);
        translate(pend_a_mundo([p[0] + 22, p[1], 20])) numero(i + 1);
    }
} else if (sub == "10.8") {
    color(GRIS) carcasa_superior();
    for (i = [0 : len(pos_botones) - 1]) {
        p = pos_botones[i];
        color(RES) translate(nrm * 14)
            en_pendiente() translate([p[0], p[1], 0]) cylinder(d = boton_d, h = 4, $fn = 24);
        translate(pend_a_mundo([p[0] + 14, p[1], 12])) numero(i + 1);
    }
} else if (sub == "11.1") {
    diagrama("dc");
} else if (sub == "11.2") {
    diagrama("usb");
} else if (sub == "11.3") {
    diagrama("i2c");
} else if (sub == "11.4") {
    diagrama("led");
} else if (sub == "11.5") {
    diagrama("todo");
} else {
    echo(str("SUB_DESCONOCIDO;", sub));
    cube(1);
}
