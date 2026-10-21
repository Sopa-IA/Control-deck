// ORBIT TERMINAL · piezas sueltas para el render fotorrealista (Blender/Cycles)
// Exporta cada pieza en coordenadas de MONTAJE (mm) para asignarle su material.
// Uso: openscad -o carcasa.stl -D 'parte="carcasa"' -D usar_hdd_35=true partes_render.scad
// No cambia ninguna cota: usa los mismos módulos que ../cad/ensamblaje.scad.
include <../cad/componentes.scad>
parte = "carcasa";
module monitor_cuerpo() {
    en_pendiente() translate([aloj_x0 + holgura_pantalla, aloj_y0 + holgura_pantalla, -aloj_t]) caja_r([pant_w, pant_h, pant_t], 3);
}
if (parte == "carcasa") carcasa_superior();
if (parte == "base") base();
if (parte == "bisel") bisel();
if (parte == "bandeja") bandeja_servicio();
if (parte == "sop_ard") soporte_arduino();
if (parte == "sop_disco") soporte_disco();
if (parte == "guias") for (k = [0 : n_guia - 1]) let(t = tramo_guia(k)) guia_luz_frontal(t[0], t[1], k == 0 ? 3 : 0, k == n_guia - 1 ? 3 : 0);
if (parte == "tira_led") translate([luz_margen, pared + 4.4, luz_z0 + luz_alto/2 - 5]) cube([W - 2*luz_margen, 1.5, 10]);
if (parte == "monitor") monitor_cuerpo();
if (parte == "pomos") en_pendiente() for (p = pos_knobs) translate([p[0], p[1], 1.2]) pomo();
if (parte == "marca_pomo") en_pendiente() for (p = pos_knobs) translate([p[0], p[1] + knob_d/2 - 5, 1.2 + knob_h - 0.75]) cylinder(d = 2.3, h = 0.8);
if (parte == "anillos") en_pendiente() for (p = pos_knobs) translate([p[0], p[1], -pared]) anillo_luz();
if (parte == "boton_brida") en_pendiente() for (p = pos_botones) translate([p[0], p[1], 0]) cylinder(d = boton_d, h = 1.2, $fn = 64);
if (parte == "boton_cuerpo") en_pendiente() for (p = pos_botones) translate([p[0], p[1], 0]) cylinder(d = pulsador_agujero - 2.5, h = boton_alto, $fn = 64);
if (parte == "boton_tapa") en_pendiente() for (p = pos_botones) translate([p[0], p[1], boton_alto]) cylinder(d = pulsador_agujero - 7, h = 0.4, $fn = 64);
if (parte == "mandos_int") mandos_marcador();
if (parte == "separadores") for (p = hp_agujeros()) translate([p[0], p[1], hp_z]) cylinder(d = 5.5, h = hp_separador, $fn = 6);
if (parte == "io_frontal") translate([pared, io_frontal_y, io_frontal_z]) cube(io_frontal);
if (parte == "boton_hp") translate([pared - 2.5, boton_hp_y, boton_hp_z]) rotate([0, 90, 0]) cylinder(d = boton_hp_d, h = boton_hp_prof + 2.5, $fn = 48);
if (parte == "cables") cables_ilustrativos();
if (parte == "pies") for (p = pies()) translate([p[0], p[1], -alto_pies]) cylinder(d = 12, h = alto_pies + 1);
if (parte == "captura_cuerpo") translate([cap_x, cap_y, cap_z]) translate([22, 3, 3]) caja_r([min(captura[0] - 26, cap_dx - 24), captura[1] - 6, captura[2] - 8], 3);
if (parte == "captura_clavija") translate([cap_x, cap_y, cap_z]) translate([2, 7, 5]) cube([20, captura[1] - 14, captura[2] - 12]);
if (parte == "captura_reserva") translate([cap_x, cap_y, cap_z]) cube([cap_dx, captura[1], captura[2]]);
if (parte == "adaptador") if (usar_adaptador_video) translate([adap_x, adap_y, adap_z]) cube([adap_dx, adap_video[1], adap_video[2]]);
// Valores para la escena de Blender (vista="params")
if (parte == "params") {
    echo(str("P;W;", W)); echo(str("P;D;", D)); echo(str("P;H;", H));
    echo(str("P;y_pend0;", y_pend0)); echo(str("P;alto_frontal;", alto_frontal)); echo(str("P;inclinacion;", inclinacion));
    echo(str("P;act_x0;", aloj_x0 + holgura_pantalla + pant_w/2 + act_off_x - act_w/2));
    echo(str("P;act_y0;", aloj_y0 + holgura_pantalla + pant_h/2 + act_off_y - act_h/2));
    echo(str("P;act_z;", -aloj_t + pant_t + 0.21)); echo(str("P;act_w;", act_w)); echo(str("P;act_h;", act_h));
    echo(str("P;hp_x;", hp_x)); echo(str("P;hp_y;", hp_y)); echo(str("P;hp_pcb_z;", hp_pcb_z)); echo(str("P;hp_w;", hp_w)); echo(str("P;hp_d;", hp_d));
    echo(str("P;hp_pcb;", hp_pcb)); echo(str("P;hp_comp_h;", hp_comp_h)); echo(str("P;hp_io_x0;", hp_io_x0)); echo(str("P;hp_io_w;", hp_io_w));
    echo(str("P;hp_io_h;", hp_io_h)); echo(str("P;hp_io_baja;", hp_io_baja)); echo(str("P;hp_io_prof;", hp_io_prof));
    echo(str("P;disco_x;", disco_x)); echo(str("P;disco_y;", disco_y)); echo(str("P;disco_z;", disco_z));
    echo(str("P;disco_dx;", disco[0])); echo(str("P;disco_dy;", disco[1])); echo(str("P;disco_dz;", disco[2]));
    echo(str("P;pi_x;", pi_x)); echo(str("P;pi_y;", pi_y)); echo(str("P;pi_z;", pi_z));
    echo(str("P;ard_x0;", ard_cx - ard_w/2)); echo(str("P;ard_y;", ard_y)); echo(str("P;ard_pcb_z;", ard_pcb_z));
    echo(str("P;ard_l;", ard_l)); echo(str("P;ard_w;", ard_w)); echo(str("P;ard_clavija;", ard_clavija));
    echo(str("P;cap_x;", cap_x)); echo(str("P;cap_y;", cap_y)); echo(str("P;cap_z;", cap_z));
    echo(str("P;ventana_hp_x;", ventana_hp_x)); echo(str("P;ventana_hp_z;", ventana_hp_z));
    echo(str("P;pasacables_x;", pasacables_x)); echo(str("P;pasacables_z;", pasacables_z));
    echo(str("P;pod_cx;", pod_cx)); echo(str("P;knob_v0;", pos_knobs[0][1])); echo(str("P;knob_v1;", pos_knobs[1][1])); echo(str("P;boton_v;", boton_v));
    echo(str("P;expl;", 75));
}
