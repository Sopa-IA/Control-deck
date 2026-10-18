// ORBIT TERMINAL · COMPONENTES (marcadores de posición, NO imprimibles) · PROVISIONAL
include <piezas.scad>

// Colores de render
C_CUERPO = [0.19, 0.19, 0.205];
C_BISEL  = [0.10, 0.10, 0.11];
C_AMBAR  = [1.0, 0.58, 0.10];
C_POMO   = [0.20, 0.20, 0.22];
C_VIDRIO = [0.02, 0.03, 0.05];

// Potenciómetro y pulsador genéricos: ver params.scad (datos_pot, datos_boton) [PENDIENTE]
panel_pot = pared + refuerzo_pot;   // espesor de panel en los pomos

// Cajas AABB de cada componente (mundo): [nombre, [x,y,z], [dx,dy,dz]]
function cajas_componentes() = [
    ["HP (" , hp_preset, ")", [hp_x, hp_y, hp_z], [hp_w, hp_d, hp_h]],
    ["Raspberry Pi", "", "", [pi_x, pi_y, pi_z], [pi_w, pi_d, pi_h]],
    if (usar_kvm) ["KVM", "", "", [kvm_x, kvm_y, kvm_z], [kvm_w, kvm_d, kvm_h]],
    ["Distribucion DC", "", "", [psu_x, psu_y, psu_z], [psu_w, psu_d, psu_h]],
    ["Arduino Micro + soporte", "", "", [ard_cx - sop_ard_w/2, sop_ard_y0, sop_ard_z0], [sop_ard_w, ard_y + ard_l + ard_usb_sale - sop_ard_y0, ard_altura_soporte + ard_pcb + ard_arriba]],
    ["Clavija micro-USB", "", "", [ard_cx - 5, ard_y + ard_l + ard_usb_sale, ard_pcb_z - 1], [10, ard_clavija, 6]],
    ["Clavija USB-A en la Pi", "", "", [pi_x + pi_w, pi_y + 21, pi_z + 1.6], [35, 16, 16]]
];
// Cajas en coordenadas de la pendiente (x, v, n): cuerpo bajo el panel
function cajas_mandos() = concat(
    [for (p = pos_knobs) ["Potenciometro", [p[0] - pot_cuerpo_d/2, p[1] - pot_cuerpo_d/2, -panel_pot - pot_prof], [pot_cuerpo_d, pot_cuerpo_d, pot_prof]]],
    [for (p = pos_botones) ["Pulsador", [p[0] - boton_tuerca_d/2, p[1] - boton_tuerca_d/2, -pared - boton_prof], [boton_tuerca_d, boton_tuerca_d, boton_prof]]]);

module monitor() {
    en_pendiente() translate([aloj_x0 + holgura_pantalla, aloj_y0 + holgura_pantalla, -aloj_t]) {
        color([0.13, 0.13, 0.14]) caja_r([pant_w, pant_h, pant_t], 3);
        // área activa con una interfaz de ejemplo (solo ilustrativa)
        translate([pant_w/2 + act_off_x - act_w/2, pant_h/2 + act_off_y - act_h/2, pant_t]) {
            color(C_VIDRIO) cube([act_w, act_h, 0.2]);
            ui_ejemplo(act_w, act_h);
        }
    }
}

module ui_ejemplo(w, h) {
    m = 8;
    color(C_AMBAR) translate([0, 0, 0.2]) {
        // marco de interfaz
        for (r = [[m, h - m - 1.2, w - 2*m, 1.2], [m, m, w - 2*m, 0.8], [m, m, 0.8, h - 2*m], [w - m - 0.8, m, 0.8, h - 2*m]])
            translate([r[0], r[1], 0]) cube([r[2], r[3], 0.2]);
        // cabecera "ORBIT" (bloques)
        for (i = [0 : 4]) translate([m + 4 + i*9, h - m - 10, 0]) cube([7, 6, 0.2]);
        // órbita central
        translate([w*0.35, h*0.48, 0]) {
            rotate_extrude($fn = 120) translate([h*0.26 - 1, 0]) square([1, 0.2]);
            rotate_extrude($fn = 120) translate([h*0.16 - 0.8, 0]) square([0.8, 0.2]);
            cylinder(r = 4, h = 0.2);
            rotate([0, 0, 35]) translate([h*0.26, 0, 0]) cylinder(r = 3, h = 0.2);
        }
        // barras de estado a la derecha
        for (i = [0 : 5]) translate([w*0.66, h*0.25 + i*h*0.09, 0]) cube([w*0.08 + (i*37 % 50)*0.9, 3, 0.2]);
        for (i = [0 : 5]) translate([w*0.66 - 8, h*0.25 + i*h*0.09, 0]) cube([4, 3, 0.2]);
    }
}

module hp_marcador() {
    translate([hp_x, hp_y, hp_z]) {
        color([0.28, 0.28, 0.30]) cube([hp_w, hp_d, hp_h]);
        color([0.6, 0.6, 0.62]) translate([hp_w/2, hp_d - 30, hp_h]) cylinder(d = 22, h = 0.3);
    }
}
module pi_marcador() {
    translate([pi_x, pi_y, pi_z]) {
        color([0.05, 0.42, 0.18]) caja_r([pi_w, pi_d, 1.6], 3);
        color([0.75, 0.75, 0.78]) {
            translate([pi_w - 21, 2, 1.6]) cube([21, 16, 13.5]);    // RJ45 (ilustrativo)
            translate([pi_w - 17, 22, 1.6]) cube([17, 13, 16]);     // USB
            translate([pi_w - 17, 39, 1.6]) cube([17, 13, 16]);
        }
        color([0.15, 0.15, 0.15]) translate([25, 20, 1.6]) cube([15, 15, 2]);
    }
}
module caja_marcador(p, s, c, etiqueta = "") { color(c) translate(p) cube(s); }

module mandos_marcador() {   // cuerpos bajo el panel (genéricos)
    en_pendiente() {
        for (p = pos_knobs) translate([p[0], p[1], -panel_pot]) {
            color([0.55, 0.55, 0.58]) translate([0, 0, -pot_prof + 6]) cylinder(d = pot_cuerpo_d, h = pot_prof - 6);   // cuerpo
            color([0.75, 0.6, 0.3]) for (dx = [-5, 0, 5]) translate([dx - 0.6, pot_cuerpo_d/2 - 2, -pot_prof]) cube([1.2, 1, 6]);  // terminales
            color([0.7, 0.7, 0.72]) cylinder(d = PT[0], h = panel_pot + 2);                                              // casquillo + tuerca
        }
        for (p = pos_botones) translate([p[0], p[1], -pared]) {
            color([0.25, 0.25, 0.27]) translate([0, 0, -boton_prof]) cylinder(d = pulsador_agujero - 0.4, h = boton_prof);
            color([0.6, 0.6, 0.62]) translate([0, 0, -4]) cylinder(d = boton_tuerca_d, h = 3, $fn = 6);
        }
    }
}

module componentes_internos() {
    hp_marcador();
    pi_marcador();
    if (usar_kvm) caja_marcador([kvm_x, kvm_y, kvm_z], [kvm_w, kvm_d, kvm_h], [0.22, 0.22, 0.25]);
    caja_marcador([psu_x, psu_y, psu_z], [psu_w, psu_d, psu_h], [0.35, 0.18, 0.12]);
    mandos_marcador();
    arduino_marcador();
    cables_ilustrativos();
    // tira LED frontal
    color(C_AMBAR) translate([luz_margen, pared + 4.4, luz_z0 + luz_alto/2 - 5]) cube([W - 2*luz_margen, 1.5, 10]);
}

// Mandos montados (pomos, anillos, tapas)
module mandos_montados() {
    en_pendiente() {
        for (p = pos_knobs) translate([p[0], p[1], 0]) {
            color(C_POMO) translate([0, 0, 1.2]) pomo();
            if (anillos_luz) color(C_AMBAR) translate([0, 0, -pared]) anillo_luz();
            color(C_AMBAR) translate([0, knob_d/2 - 5, 1.2 + knob_h - 0.75]) cylinder(d = 2.3, h = 0.8);
        }
        // pulsadores de panel genéricos (brida y actuador comerciales) [PENDIENTE modelo]
        for (i = [0 : 1]) let(p = pos_botones[i]) translate([p[0], p[1], 0]) {
            color([0.55, 0.55, 0.58]) cylinder(d = boton_d, h = 1.2);
            color([0.16, 0.16, 0.17]) cylinder(d = pulsador_agujero - 2.5, h = boton_alto);
            color(C_AMBAR) translate([0, 0, boton_alto]) cylinder(d = pulsador_agujero - 7, h = 0.4);
        }
    }
}

// Cables ilustrativos (NO son un recorrido validado): micro-USB Arduino -> Pi,
// Mini-HDMI MSI -> Pi y USB-C MSI -> pasacables trasero (HP / fuente PD)
module cable(pts, d = 4, c = [0.08, 0.08, 0.08]) {
    color(c) for (i = [0 : len(pts) - 2]) hull() { translate(pts[i]) sphere(d = d, $fn = 10); translate(pts[i+1]) sphere(d = d, $fn = 10); }
}
module cables_ilustrativos() {
    zc = ard_pcb_z + 1.5;
    cable([[ard_cx, ard_y + ard_l + ard_usb_sale + ard_clavija, zc], [ard_cx, canal_usb_y0, suelo + 3],
           [ard_cx, canal_usb_y1, suelo + 3], [pi_x + pi_w + 30, pi_y + 37, pi_z + 10], [pi_x + pi_w + 2, pi_y + 37, pi_z + 10]], 3.5);
    pm = pend_a_mundo([aloj_x0 + aloj_w + 8, aloj_y0 + aloj_h*(puertos_v0 + 0.08), -aloj_t/2]);
    pc = pend_a_mundo([aloj_x0 + aloj_w + 8, aloj_y0 + aloj_h*(puertos_v0 + 0.28), -aloj_t/2]);
    cable([pm, [pm[0], pm[1] + 10, pm[2] - 30], [pi_x + 30, psu_y + psu_d/2, psu_z + psu_h + 8], [pi_x + 30, pi_y - 7, psu_z + psu_h + 4], [pi_x + 30, pi_y - 7, pi_z + 4]], 5, [0.12, 0.12, 0.3]);
    cable([pc, [pc[0] - 10, pc[1] + 20, pc[2] - 40], [pasacables_x + 17, D - 40, pasacables_z + 7], [pasacables_x + 17, D - pared - 1, pasacables_z + 7]], 4.5, [0.3, 0.12, 0.12]);
}

// Para la vista interior: encoders y pulsadores sin la carcasa
module mandos_montados_sueltos() { mandos_montados(); }
