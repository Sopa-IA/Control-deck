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

// La reserva nominal de capturadora y adaptador es 72 mm. El riel (tramo de
// anclaje) llega hasta riel_x0a: la caja comprobada acaba ahí. Un aparato de
// 72 mm ya chocaría con las torretas Ø8 impresas, que empiezan en riel_x0.
reserva_x1 = riel_x0a;
cap_dx = min(captura[0], reserva_x1 - cap_x);
adap_dx = min(adap_video[0], reserva_x1 - adap_x);
function caja_comp(nombre, b) = [nombre, "", "", [b[0], b[1], b[2]], [b[3], b[4], b[5]]];

// Cajas AABB de cada componente (mundo): [nombre, [x,y,z], [dx,dy,dz]]
function cajas_componentes() = [
    if (!hp_desnuda) ["HP (" , hp_preset, ")", [hp_x, hp_y, hp_z], [hp_w, hp_d, hp_h]],
    if (hp_desnuda) ["Placa HP + RAM/disipador", "", "", [hp_x, hp_y, hp_pcb_z], [hp_w, hp_d - hp_io_prof, hp_pcb + hp_comp_h]],
    if (hp_desnuda) ["Placa HP zona I/O trasera", "", "", [hp_x, hp_y + hp_d - hp_io_prof, hp_pcb_z], [hp_w, hp_io_prof + 2, hp_pcb + hp_io_h - hp_io_baja]],
    if (hp_desnuda) [usar_hdd_35 ? "HDD 3,5 + soporte" : "SSD 2,5 + soporte", "", "", [disco_x - 4, disco_y, disco_z - 2], [disco[0] + 8, disco[1], 2 + disco[2]]],
    if (hp_desnuda) ["I/O frontal HP (lateral izq.)", "", "", [pared, io_frontal_y, io_frontal_z], io_frontal],
    if (hp_desnuda) ["Pulsador encendido HP", "", "", [pared, boton_hp_y - boton_hp_d/2 - 2, boton_hp_z - boton_hp_d/2 - 2], [boton_hp_prof, boton_hp_d + 4, boton_hp_d + 4]],
    if (usar_adaptador_video) ["Adaptador HDMI->USB-C (Pi)", "", "", [adap_x, adap_y, adap_z], [adap_dx, adap_video[1], adap_video[2]]],
    if (usar_capturadora) ["Capturadora HDMI->USB (reserva)", "", "", [cap_x, cap_y, cap_z], [cap_dx, captura[1], captura[2]]],
    ["Raspberry Pi", "", "", [pi_x, pi_y, pi_z], [pi_w, pi_d, pi_h]],
    if (usar_kvm) ["KVM", "", "", [kvm_x, kvm_y, kvm_z], [kvm_w, kvm_d, kvm_h]],
    if (usar_distribucion) ["Distribucion DC", "", "", [psu_x, psu_y, psu_z], [psu_w, psu_d, psu_h]],
    // La orejeta trasera del soporte es baja (no llega a la clavija). Van en cajas distintas
    // para no marcar un solape que en la pieza no existe.
    ["Arduino Nano mandos + soporte", "", "", [ard_cx - sop_ard_w/2, sop_ard_y0, sop_ard_z0], [sop_ard_w, ard_y + ard_l + ard_usb_sale - sop_ard_y0, ard_altura_soporte + ard_pcb + ard_arriba]],
    ["Orejeta trasera soporte Nano", "", "", [ard_cx - sop_ard_w/2, ard_y + ard_l + ard_usb_sale, sop_ard_z0], [sop_ard_w, sop_ard_y0 + sop_ard_l - (ard_y + ard_l + ard_usb_sale), 4]],
    ["Clavija mini-USB mandos", "", "", [ard_cx - 5, ard_y + ard_l + ard_usb_sale, ard_pcb_z - 1], [10, ard_clavija, 6]],
    ["Riel placas, tramo delantero", "", "", [riel_x0, riel_y0, suelo], [riel_x1f - riel_x0, (riel_yq - 0.2) - riel_y0, riel_h]],
    ["Riel placas, tramo anclaje", "", "", [riel_x0a, riel_yq - 0.2, suelo], [riel_x1a - riel_x0a, riel_y1 - (riel_yq - 0.2), riel_h]],
    if (carro_conjunto == "nano_esp" || carro_conjunto == "nano_proto")
        caja_comp("Carro Nano practicas", carro_caja(nano_est, pr_l, pr_w, pr_h, pr_clavija)),
    if (carro_conjunto == "nano_esp" || carro_conjunto == "nano_proto")
        caja_comp("Pestana carro Nano", carro_pestana_caja(nano_est)),
    if (carro_conjunto == "nano_esp")
        caja_comp("Carro ESP8266", carro_caja(esp_est, esp_l, esp_w, esp_h, esp_clavija)),
    if (carro_conjunto == "nano_esp")
        caja_comp("Pestana carro ESP", carro_pestana_caja(esp_est)),
    if (carro_conjunto == "nano_proto")
        caja_comp("Carro proto 30x70", carro_caja(proto_est, proto_l, proto_w, pr_h, 0)),
    if (carro_conjunto == "nano_proto")
        caja_comp("Pestana carro proto", carro_pestana_caja(proto_est)),
    ["OLED 0,96 SSD1306", "", "", [oled_cx - oled_mod[0]/2, D - pared - 1.5 - oled_mod[1], oled_cz - oled_mod[2]/2], oled_mod],
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

module hp_marcador() { if (hp_desnuda) hp_placa_marcador(); else hp_caja_marcador(); }
// Placa mini-ITX desnuda (ilustrativa: posiciones de RAM/disipador/conectores [PENDIENTE de medir]).
// v3: disposición según la foto de Miguel [FOTO, no medida]: 2 zócalos DDR3L paralelos al borde
// delantero (opuesto al I/O), tarjeta Wi-Fi M.2 junto a ellos, disipador con ventilador en el centro;
// altura total del disipador + ventilador = hp_comp_h [MEDIDO].
module hp_placa_marcador() {
    for (p = hp_agujeros()) color([0.75, 0.7, 0.4]) translate([p[0], p[1], hp_z]) cylinder(d = 5.5, h = hp_separador, $fn = 6);
    translate([hp_x, hp_y, hp_pcb_z]) {
        color([0.05, 0.30, 0.16]) cube([hp_w, hp_d, hp_pcb]);
        translate([0, 0, hp_pcb]) {
            color([0.2, 0.2, 0.22]) for (i = [0, 1]) translate([14, 26 + i*10, 0]) cube([133.35, 6, 30.35]);  // 2x DDR3L (ilustrativo)
            color([0.1, 0.35, 0.2]) translate([120, 4, 0]) cube([30, 22, 4]);                                 // Wi-Fi M.2 (ilustrativo)
            color([0.55, 0.55, 0.6]) translate([50, 70, 0]) cube([66, 66, hp_comp_h - 10]);                  // disipador (ilustrativo)
            color([0.12, 0.12, 0.12]) translate([58, 78, hp_comp_h - 10]) cube([50, 50, 10]);                 // ventilador: techo = hp_comp_h
            color([0.7, 0.7, 0.74]) translate([hp_io_x0, hp_d - hp_io_prof + 2, 0]) cube([hp_io_w, hp_io_prof, hp_io_h - hp_io_baja - 4]);  // pila I/O
        }
    }
    // disco, I/O frontal, pulsador y LED
    color([0.25, 0.27, 0.32]) translate([disco_x, disco_y, disco_z]) cube(disco);
    color([0.3, 0.3, 0.32]) translate([pared, io_frontal_y, io_frontal_z]) cube(io_frontal);
    color([0.6, 0.6, 0.62]) translate([pared, boton_hp_y, boton_hp_z]) rotate([0, 90, 0]) cylinder(d = boton_hp_d, h = boton_hp_prof);
}
module hp_caja_marcador() {
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
// Capturadora HDMI->USB: RESERVA de espacio (cuerpo + clavija HDMI); forma ilustrativa
module capturadora_marcador() {
    translate([cap_x, cap_y, cap_z]) {
        color([0.42, 0.45, 0.5]) translate([22, 3, 3]) caja_r([min(captura[0] - 26, cap_dx - 24), captura[1] - 6, captura[2] - 8], 3);  // cuerpo, sin entrar en el riel
        color([0.08, 0.08, 0.08]) translate([2, 7, 5]) cube([20, captura[1] - 14, captura[2] - 12]);                   // clavija HDMI
        color([0.18, 0.2, 0.24, 0.25]) cube([cap_dx, captura[1], captura[2]]);                                          // envolvente que cabe junto al riel
    }
}

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
    if (usar_distribucion) caja_marcador([psu_x, psu_y, psu_z], [psu_w, psu_d, psu_h], [0.35, 0.18, 0.12]);
    if (usar_adaptador_video) caja_marcador([adap_x, adap_y, adap_z], [adap_dx, adap_video[1], adap_video[2]], [0.18, 0.22, 0.35]);   // adaptador HDMI->USB-C [PENDIENTE]
    if (usar_capturadora) capturadora_marcador();
    mandos_marcador();
    arduino_marcador();
    color([0.22, 0.22, 0.24]) riel_placas();
    if (carro_conjunto == "nano_esp" || carro_conjunto == "nano_proto")
        carro_en_puesto(nano_est, pr_l, pr_w, pr_clavija);
    if (carro_conjunto == "nano_esp")
        carro_en_puesto(esp_est, esp_l, esp_w, esp_clavija);
    if (carro_conjunto == "nano_proto")
        carro_en_puesto(proto_est, proto_l, proto_w, 0);
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
    pp = [pasacables_x + pasacables[0]/2 - 8, D - pared - 1, pasacables_z + 7];
    if (usar_capturadora) {
        // Modo C: Mini-HDMI MSI <- micro-HDMI de la Pi (con el adaptador Mini-HDMI de Miguel)
        cable([pm, [pm[0] - 10, pm[1] + 10, pm[2] - 30], [pi_x + 30, pi_y - 4, pi_z + 14], [pi_x + 30, pi_y + 2, pi_z + 4]], 5, [0.12, 0.12, 0.3]);
        // HDMI del HP (sale por la ventana I/O, vuelve por el pasacables) -> capturadora -> USB de la Pi
        cable([pp, [pp[0], D - 40, pp[2]], [cap_x - 10, cap_y + captura[1]/2, cap_z + 30], [cap_x - 4, cap_y + captura[1]/2, cap_z + captura[2]/2], [cap_x + 2, cap_y + captura[1]/2, cap_z + captura[2]/2]], 5, [0.3, 0.2, 0.08]);
        cable([[cap_x + captura[0], cap_y + captura[1]/2, cap_z + 10], [pi_x + pi_w + 25, cap_y + captura[1]/2, cap_z + 12], [pi_x + pi_w + 25, pi_y + 47, pi_z + 10], [pi_x + pi_w + 2, pi_y + 47, pi_z + 10]], 3.5, [0.12, 0.3, 0.3]);
    } else {
        // HP v2: Mini-HDMI MSI <- HDMI del HP (sale por la ventana I/O y vuelve por el pasacables)
        cable([pm, [pm[0] - 10, pm[1] + 20, pm[2] - 30], [pp[0], D - 40, pp[2]], pp], 5, [0.12, 0.12, 0.3]);
    }
    // USB-C 1 MSI <- adaptador HDMI->USB-C <- micro-HDMI de la Pi (modo B, poco probable)
    if (usar_adaptador_video && !usar_capturadora) {
        cable([pc, [pc[0], pc[1] + 5, pc[2] - 30], [adap_x + adap_video[0]/2, adap_y - 6, adap_z + adap_video[2] + 6], [adap_x + adap_video[0]/2, adap_y, adap_z + adap_video[2]/2]], 4.5, [0.3, 0.12, 0.12]);
        cable([[adap_x + 20, adap_y + adap_video[1], adap_z + 8], [adap_x + 20, pi_y + 2, pi_z + 4]], 4, [0.12, 0.3, 0.3]);
    }
}

// Para la vista interior: encoders y pulsadores sin la carcasa
module mandos_montados_sueltos() { mandos_montados(); }
