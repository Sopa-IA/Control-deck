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

// Bandeja v2: la capturadora usa el nido que cabe (cap_hueco), no los 72 mm nominales.
cap_dx = cap_hueco[0];
adap_dx = usar_adaptador_video ? adap_video[0] : 0;
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
    if (usar_capturadora && usar_nido_captura) ["Capturadora (nido en bandeja)", "", "", [cap_x, cap_y, cap_z], cap_hueco],
    // La Pi va partida en PCB, conectores y clavijas (mas abajo) para no inflar una sola caja.
    if (usar_kvm) ["KVM", "", "", [kvm_x, kvm_y, kvm_z], [kvm_w, kvm_d, kvm_h]],
    if (usar_distribucion) ["Distribucion DC", "", "", [psu_x, psu_y, psu_z], [psu_w, psu_d, psu_h]],
    // La orejeta trasera del soporte es baja (no llega a la clavija). Van en cajas distintas
    // para no marcar un solape que en la pieza no existe.
    ["Nano mandos", "", "", [b3_man[0], b3_man[1], suelo + b3_pin_z - ard_pines], [b3_man[2], b3_man[3], ard_pines + ard_pcb + ard_arriba]],
    ["Clavija mini-USB mandos", "", "", [b3_man[0] + 4, b3_man[1] + b3_man[3], suelo + b3_pin_z + 1], [10, ard_clavija, 6]],
    // PCB hasta donde empieza el RJ45 (ox = 66,8). Los conectores van en sus cajas.
    ["Pi PCB", "", "", [pi_x0, pi_y0, pi_z], [pi_w, 66.8, 1.5]],
    ["Pi USB-A", "", "", [pi_x0 + 21.75, pi_y0 + 70.5, pi_z + 1.5], [32.5, 17.5, 16]],
    ["Pi RJ45", "", "", [pi_x0 + 2.25, pi_y0 + 66.8, pi_z + 1.5], [16, 21.2, 14]],
    ["Clavijas USB-A Pi", "", "", [pi_x0 + 21.75, pi_y0 + 88, pi_z + 1.5], [32.5, pi_clavija, 16]],
    ["Clavija RJ45 Pi", "", "", [pi_x0 + 2.25, pi_y0 + 88, pi_z + 1.5], [16, 30, 14]],
    ["Pi HDMI y USB-C", "", "", [pi_x0 + pi_w, pi_y0 + 4, pi_z + 2], [26, 42, 8]],
    ["Nano practicas", "", "", [b3_prac[0], b3_prac[1], suelo + b3_pin_z - ard_pines], [b3_prac[2], b3_prac[3], ard_pines + ard_pcb + pr_icsp[2]]],
    ["USB Nano practicas", "", "", [b3_prac[0] + 4, b3_prac[1] - pr_clavija, suelo + b3_pin_z + 1], [10, pr_clavija, 6]],
    ["ESP8266", "", "", [b3_esp[0], b3_esp[1], suelo + b3_pin_z - ard_pines], [b3_esp[2], b3_esp[3], ard_pines + esp_pcb + esp_mod[2]]],
    ["USB ESP8266", "", "", [b3_esp[0] + b3_esp[2]/2 - 5, b3_esp[1] + b3_esp[3], suelo + b3_pin_z + 1], [10, esp_clavija, 6]],
    ["Buck LM2596", "", "", [b3_buck[0], b3_buck[1], suelo + buck_suelda], [b3_buck[2], b3_buck[3], buck_pcb + buck_h]],
    ["OLED 0,96 SSD1306", "", "", [oled_cx - oled_mod[0]/2, D - pared - 1.5 - oled_mod[1], oled_cz - oled_mod[2]/2], oled_mod]
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
    // ox a lo largo de +Y, oy = 0 en el canto +X. El HAT no se dibuja: no está medido.
    translate([pi_x0, pi_y0, pi_z]) {
        difference() {
            color([0.05, 0.42, 0.18]) cube([56, 85, 1.5]);
            // ventana sobre la rejilla del suelo, para verla en la planta
            translate([13.2, 15.8, -0.4]) cube([27.4, 32.4, 2.4]);
        }
        color([0.12, 0.12, 0.12]) translate([0.4, 17, 1.5]) cube([5, 51, 8.5]);   // GPIO, canto −X
        color([0.75, 0.75, 0.78]) {
            translate([56 - 16.25, 70.5, 1.5]) cube([14.5, 17.5, 16]);             // USB junto al HDMI
            translate([56 - 34.25, 70.5, 1.5]) cube([14.5, 17.5, 16]);
            translate([2.25, 66.8, 1.5]) cube([16, 21.2, 13.5]);                   // RJ45, lado GPIO
        }
        color([0.72, 0.72, 0.75]) translate([55.2, 5, 1.6]) cube([2.2, 34, 3.5]); // micro-HDMI y USB-C
        color([0.15, 0.15, 0.15]) translate([22, -0.4, -1.1]) cube([14, 12, 1.1]); // micro-SD, por debajo
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
    if (usar_capturadora && usar_nido_captura) capturadora_marcador();
    mandos_marcador();
    arduino_marcador();
    placas_fantasma(false, false);
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
// Placas de los huecos, translúcidas. La Pi y el Nano de mandos tienen
// su propio marcador en el ensamblaje; aquí se pueden omitir.
module placas_fantasma(con_pi = true, con_mandos = true) {
    a = 0.4;
    if (con_pi) {
        color([0.15, 0.62, 0.32, a]) translate([pi_x0, pi_y0, pi_z]) cube([pi_w, pi_d, 1.5]);
        color([0.75, 0.75, 0.8, 0.55]) translate([pi_x0 + 21.75, pi_y0 + 70.5, pi_z + 1.5]) cube([32.5, 14, 12]);
        color([0.75, 0.75, 0.8, 0.55]) translate([pi_x0 + 2.25, pi_y0 + 66.8, pi_z + 1.5]) cube([16, 16, 10]);
    }
    if (con_mandos)
        color([0.2, 0.48, 0.72, a]) translate([b3_man[0], b3_man[1], suelo + b3_pin_z]) cube([b3_man[2], b3_man[3], ard_pcb]);
    color([0.2, 0.48, 0.72, a]) translate([b3_prac[0], b3_prac[1], suelo + b3_pin_z]) cube([b3_prac[2], b3_prac[3], ard_pcb]);
    color([0.15, 0.22, 0.55, a]) translate([b3_esp[0], b3_esp[1], suelo + b3_pin_z]) cube([b3_esp[2], b3_esp[3], esp_pcb]);
    color([0.15, 0.15, 0.16, 0.45])
        translate([b3_esp[0] + b3_esp[2]/2 - esp_mod[0]/2, b3_esp[1] + b3_esp[3]/2 - esp_mod[1]/2, suelo + b3_pin_z + esp_pcb])
            cube(esp_mod);
    color([0.55, 0.28, 0.12, a]) translate([b3_buck[0], b3_buck[1], suelo + buck_suelda]) cube([b3_buck[2], b3_buck[3], buck_pcb]);
    color([0.25, 0.25, 0.28, 0.35])
        translate([b3_buck[0] + 4, b3_buck[1] + 8, suelo + buck_suelda + buck_pcb]) cube([12, 12, buck_h]);
}

module cables_ilustrativos() {
    zc = suelo + b3_pin_z + 3;
    // USB derecho de la Pi. El cable de mandos baja por el canto +X de la bandeja.
    usb_x = pi_x0 + 47;
    jack_y = pi_y0 + 88;
    mx = b3_man[0] + b3_man[2]/2;
    my = b3_man[1] + b3_man[3] + ard_usb_sale;
    rx = 428;
    cable([[mx, my, zc], [rx, my, suelo + 6], [rx, 200, suelo + 6],
           [rx, 200, pi_z + 10], [usb_x, 210, pi_z + 10], [usb_x, jack_y + 2, pi_z + 8]], 3.5);
    pm = pend_a_mundo([aloj_x0 + aloj_w + 8, aloj_y0 + aloj_h*(puertos_v0 + 0.08), -aloj_t/2]);
    pc = pend_a_mundo([aloj_x0 + aloj_w + 8, aloj_y0 + aloj_h*(puertos_v0 + 0.28), -aloj_t/2]);
    pp = [pasacables_x + pasacables[0]/2 - 8, D - pared - 1, pasacables_z + 7];
    hdmi = [pi_x0 + pi_w, pi_y0 + 22, pi_z + 4];
    if (usar_capturadora) {
        // Modo C: Mini-HDMI MSI <- micro-HDMI de la Pi (canto +X)
        cable([pm, [pm[0] - 10, pm[1] + 10, pm[2] - 30], [hdmi[0] + 18, hdmi[1] - 10, hdmi[2] + 8], hdmi], 5, [0.12, 0.12, 0.3]);
        // El nido de la capturadora salió de la bandeja. Sin hueco no se dibuja el cable.
        if (usar_nido_captura) {
            cx = canal_x0 + canal_rib + canal_paso/2;
            gy = canal_giro_y0 + canal_rib + canal_paso/2;
            cable([pp, [pp[0], D - 40, pp[2]], [cap_x + cap_hueco[0]/2, cap_y - 6, cap_z + cap_hueco[2]], [cap_x + 4, cap_y + cap_hueco[1]/2, cap_z + cap_hueco[2]/2]], 5, [0.3, 0.2, 0.08]);
            cable([[cap_x + cap_hueco[0], cap_y + cap_hueco[1]/2, cap_z + 6], [cx, cap_y + cap_hueco[1]/2, suelo + 3], [cx, gy, suelo + 3], [pi_x0 + 29, jack_y + 2, pi_z + 8]], 3.5, [0.12, 0.3, 0.3]);
        }
    } else {
        cable([pm, [pm[0] - 10, pm[1] + 20, pm[2] - 30], [pp[0], D - 40, pp[2]], pp], 5, [0.12, 0.12, 0.3]);
    }
    if (usar_adaptador_video && !usar_capturadora) {
        cable([pc, [pc[0], pc[1] + 5, pc[2] - 30], [adap_x + adap_video[0]/2, adap_y - 6, adap_z + adap_video[2] + 6], [adap_x + adap_video[0]/2, adap_y, adap_z + adap_video[2]/2]], 4.5, [0.3, 0.12, 0.12]);
        cable([[adap_x + 20, adap_y + adap_video[1], adap_z + 8], hdmi], 4, [0.12, 0.3, 0.3]);
    }
}

// Para la vista interior: encoders y pulsadores sin la carcasa
module mandos_montados_sueltos() { mandos_montados(); }
