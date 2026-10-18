// ORBIT TERMINAL · COMPONENTES (marcadores de posición, NO imprimibles) · PROVISIONAL
include <piezas.scad>

// Colores de render
C_CUERPO = [0.19, 0.19, 0.205];
C_BISEL  = [0.10, 0.10, 0.11];
C_AMBAR  = [1.0, 0.58, 0.10];
C_POMO   = [0.20, 0.20, 0.22];
C_VIDRIO = [0.02, 0.03, 0.05];

// Codificador PEC11R: cuerpo bajo panel [PENDIENTE medidas exactas; ver hoja de datos]
enc_cuerpo = [13, 13, 9];
// Pulsador bajo cada botón [PENDIENTE modelo]
pul_cuerpo = [12, 12, 9];

// Cajas AABB de cada componente (mundo): [nombre, [x,y,z], [dx,dy,dz]]
function cajas_componentes() = [
    ["HP (" , hp_preset, ")", [hp_x, hp_y, hp_z], [hp_w, hp_d, hp_h]],
    ["Raspberry Pi", "", "", [pi_x, pi_y, pi_z], [pi_w, pi_d, pi_h]],
    ["KVM", "", "", [kvm_x, kvm_y, kvm_z], [kvm_w, kvm_d, kvm_h]],
    ["Distribucion DC", "", "", [psu_x, psu_y, psu_z], [psu_w, psu_d, psu_h]]
];

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

module encoders_marcador() {
    en_pendiente() {
        for (p = pos_knobs) translate([p[0] - enc_cuerpo[0]/2, p[1] - enc_cuerpo[1]/2, -pared - 2 - enc_cuerpo[2]]) {
            color([0.5, 0.5, 0.52]) cube(enc_cuerpo);
            color([0.05, 0.3, 0.12]) translate([-6, -6, -1.6]) cube([enc_cuerpo[0] + 12, enc_cuerpo[1] + 12, 1.6]);
        }
        for (p = pos_botones) translate([p[0] - pul_cuerpo[0]/2, p[1] - pul_cuerpo[1]/2, -pared - 2 - pul_cuerpo[2]]) color([0.3, 0.3, 0.3]) cube(pul_cuerpo);
    }
}

module componentes_internos() {
    hp_marcador();
    pi_marcador();
    caja_marcador([kvm_x, kvm_y, kvm_z], [kvm_w, kvm_d, kvm_h], [0.22, 0.22, 0.25]);
    caja_marcador([psu_x, psu_y, psu_z], [psu_w, psu_d, psu_h], [0.35, 0.18, 0.12]);
    encoders_marcador();
    // tira LED frontal
    color(C_AMBAR) translate([luz_margen, pared + 4.4, luz_z0 + luz_alto/2 - 5]) cube([W - 2*luz_margen, 1.5, 10]);
}

// Mandos montados (pomos, anillos, tapas)
module mandos_montados() {
    en_pendiente() {
        for (p = pos_knobs) translate([p[0], p[1], 0]) {
            color(C_POMO) translate([0, 0, 1.2]) pomo();
            color(C_AMBAR) translate([0, 0, -pared]) anillo_luz();
            color(C_AMBAR) translate([0, knob_d/2 - 5, 1.2 + knob_h - 0.75]) cylinder(d = 2.3, h = 0.8);
        }
        for (i = [0 : 1]) let(p = pos_botones[i]) translate([p[0], p[1], 0.8]) {
            color(i == 0 ? [0.16, 0.16, 0.17] : [0.16, 0.16, 0.17]) tapa_boton();
            color(C_AMBAR) translate([0, 0, 5.45]) cylinder(d = 7.6, h = 0.6);
        }
    }
}

// Para la vista interior: encoders y pulsadores sin la carcasa
module mandos_montados_sueltos() { mandos_montados(); }
