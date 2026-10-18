// ORBIT TERMINAL · ENSAMBLAJE Y VISTAS · PROVISIONAL — NO APTO PARA FABRICACIÓN
// Uso:  openscad -D 'vista="montado"' ensamblaje.scad
// vistas: "montado" | "interior" | "explosionado" | "check"
include <componentes.scad>

vista = "montado";
interior_con_mandos = false;   // vista interior: muestra también pomos y carcasa translúcida
expl  = 75;     // separación en la vista explosionada

module guias_luz_montadas() {
    color(C_AMBAR) for (k = [0 : n_guia - 1]) let(t = tramo_guia(k))
        guia_luz_frontal(t[0], t[1], k == 0 ? 3 : 0, k == n_guia - 1 ? 3 : 0);
}

nrm = [0, -sin(inclinacion), cos(inclinacion)];   // normal de la pendiente
module conjunto(e = 0) {
    zc = 2.3*e;                                       // elevación de la carcasa
    color(C_CUERPO) translate([0, 0, zc]) carcasa_superior();
    translate([0, 0, zc] + nrm*1.1*e) monitor();
    color(C_BISEL) translate([0, 0, zc] + nrm*2.0*e) bisel();
    translate([0, 0, zc] + nrm*0.9*e) mandos_montados();
    color(C_CUERPO) base();
    color([0.15, 0.15, 0.16]) translate([0, 0, -0.9*e]) bandeja_servicio();
    color([0.13, 0.13, 0.14]) translate([0, 0, -0.9*e + 0.3*e]) soporte_arduino();
    if (hp_desnuda) color([0.16, 0.16, 0.17]) translate([0, 0, 0.3*e]) soporte_disco();
    translate([0, -1.4*e, 0.15*e]) guias_luz_montadas();
    translate([0, 0, 0.6*e]) componentes_internos();
    color([0.03, 0.03, 0.03]) for (p = pies()) translate([p[0], p[1], -alto_pies - 0.4*e]) cylinder(d = 12, h = alto_pies + 1);
}

if (vista == "montado") conjunto(0);
else if (vista == "explosionado") conjunto(expl);
else if (vista == "interior") {
    color(C_CUERPO) base();
    color([0.14, 0.14, 0.15]) bandeja_servicio();
    color([0.13, 0.13, 0.14]) soporte_arduino();
    if (hp_desnuda) color([0.16, 0.16, 0.17]) soporte_disco();
    componentes_internos();
    if (interior_con_mandos) { translate([0, 0, 0]) mandos_montados(); color(C_BISEL, 0.25) carcasa_superior(); }
    guias_luz_montadas();

}
else if (vista == "check") {
    echo(str("PARAM;W;", W)); echo(str("PARAM;D;", D)); echo(str("PARAM;H;", H));
    echo(str("PARAM;pared;", pared)); echo(str("PARAM;suelo;", suelo));
    echo(str("PARAM;inclinacion;", inclinacion)); echo(str("PARAM;alto_frontal;", alto_frontal));
    echo(str("PARAM;y_pend0;", y_pend0)); echo(str("PARAM;y_pend1;", y_pend1));
    echo(str("PARAM;aloj_x0;", aloj_x0)); echo(str("PARAM;aloj_y0;", aloj_y0));
    echo(str("PARAM;aloj_w;", aloj_w)); echo(str("PARAM;aloj_h;", aloj_h)); echo(str("PARAM;aloj_t;", aloj_t));
    echo(str("PARAM;tina_fondo;", tina_fondo)); echo(str("PARAM;tina_pared;", tina_pared));
    echo(str("PARAM;costilla;", costilla)); echo(str("PARAM;alto_pies;", alto_pies));
    echo(str("PARAM;pantalla;", pantalla)); echo(str("PARAM;hp_preset;", hp_preset));
    for (i = [1 : 1 : nx_cortes - 1]) echo(str("CUTX;", corte_x(i)));
    for (j = [1 : 1 : ny_cortes - 1]) echo(str("CUTY;", corte_y(j)));
    for (c = cajas_componentes()) echo(str("COMP;", c[0], c[1], c[2], ";", c[3][0], ";", c[3][1], ";", c[3][2], ";", c[4][0], ";", c[4][1], ";", c[4][2]));
    // Encoders y pulsadores (local -> se pasan como cajas locales)
    for (c = cajas_mandos()) echo(str("LOCAL;", c[0], ";", c[1][0], ";", c[1][1], ";", c[1][2], ";", c[2][0], ";", c[2][1], ";", c[2][2]));
    echo(str("PARAM;pod_x0;", pod_x0)); echo(str("PARAM;usar_kvm;", usar_kvm ? 1 : 0));
    echo(str("PARAM;cama;", cama_x, "x", cama_y, "x", cama_z)); echo(str("PARAM;impresora;", impresora));
    // bandeja de servicio con ala (para comprobar que no pisa orejetas)
    echo(str("SOPORTE_EN_BANDEJA;", (ard_cx - sop_ard_w/2 >= serv_x && ard_cx + sop_ard_w/2 <= serv_x + serv_w && sop_ard_y0 >= serv_y && sop_ard_y0 + sop_ard_l <= serv_y + serv_d) ? 1 : 0));
    echo(str("TRAY;", serv_x - serv_ala, ";", serv_y - serv_ala, ";", serv_w + 2*serv_ala, ";", serv_d + 2*serv_ala));
    echo(str("OBST;Canal USB;", ard_cx - canal_usb_ancho/2 - 1.6, ";", canal_usb_y0, ";", suelo, ";", canal_usb_ancho + 3.2, ";", canal_usb_y1 - canal_usb_y0, ";", 8));
    for (p = orejetas) echo(str("OBST;Orejeta;", p[0] - 6, ";", p[1] - 6, ";", suelo, ";", 12, ";", 12, ";", (p[1] > pared + 10 && p[1] < 40) ? H : 11));
    for (p = empalmes()) echo(str("OBST;Torreta empalme;", p[0] - boss_d/2, ";", p[1] - boss_d/2, ";", suelo, ";", boss_d, ";", boss_d, ";", 5));
    if (hp_desnuda) echo(str("PARAM;hp_io;", ventana_hp_x, ";", ventana_hp_z, ";", ventana_hp[0], ";", ventana_hp[1]));
    echo(str("OBST;Carril LED;", luz_margen - 3, ";", 0, ";", suelo, ";", W - 2*luz_margen + 6, ";", pared + 8.2, ";", luz_z0 + luz_alto + 2 - suelo));
    cube(1);
}
