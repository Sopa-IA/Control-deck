// =====================================================================
// ORBIT TERMINAL · Carcasa v1 · PARÁMETROS
// ---------------------------------------------------------------------
// ¡¡ DISEÑO PROVISIONAL — NO APTO PARA FABRICACIÓN !!
// Unidades: milímetros y grados. Ejes: X = ancho (izq→der),
// Y = fondo (frente y=0 → trasera), Z = altura (suelo z=0).
// Cada cota lleva su origen:
//   [FUENTE]    dato de fabricante con URL (comprobado 2026-10-18)
//   [DISEÑO]    decisión de diseño de este modelo (modificable)
//   [PENDIENTE] valor provisional; hay que medirlo o confirmarlo
// =====================================================================

// ---------------------------------------------------------------------
// 1. PANTALLA (preset principal)
// ---------------------------------------------------------------------
// "msi_15_6"       -> MSI PRO MP161 E2U, monitor de Miguel (prototipo)
// "waveshare_12_3" -> Waveshare 12.3inch 1920x720 LCD In-Cell (SKU 28481)
// "waveshare_11_6" -> Waveshare 11.6inch HDMI LCD (H), sin carcasa
pantalla = "msi_15_6";

// Datos por preset: [ancho, alto, grosor, activa_ancho, activa_alto]
// MSI PRO MP161 E2U [FUENTE]: 362.26 x 233.84 x 18.8 mm (W x H x D, con
//   el soporte plegable integrado), área activa 344.16 x 193.59 mm.
//   https://www.msi.com/Portable-Monitor/PRO-MP161-E2U/Specification
//   (El manual oficial da 232.92 mm de alto; usamos el mayor, 233.84.)
//   Posición del área activa dentro del marco: [PENDIENTE] -> centrada.
// Waveshare 12.3" [FUENTE]: 301.2 x 123.35 x 12.4; activa 293.10 x 110.20
//   https://www.waveshare.com/wiki/12.3inch_1920x720_LCD
// Waveshare 11.6" (H) [FUENTE]: vidrio 279.50 x 177.09; espesor 21.20;
//   activa 256.32 x 144.18 — plano oficial:
//   https://files.waveshare.com/wiki/11.6inch_HDMI_LCD_H/11.6inch_HDMI_LCD_H.pdf
function datos_pantalla(p) =
    p == "msi_15_6"       ? [362.26, 233.84, 18.8, 344.16, 193.59] :
    p == "waveshare_12_3" ? [301.20, 123.35, 12.4, 293.10, 110.20] :
    p == "waveshare_11_6" ? [279.50, 177.09, 21.2, 256.32, 144.18] :
                            [362.26, 233.84, 18.8, 344.16, 193.59];

DP = datos_pantalla(pantalla);
pant_w = DP[0]; pant_h = DP[1]; pant_t = DP[2];
act_w  = DP[3]; act_h  = DP[4];
act_off_x = 0;      // [PENDIENTE] desplazamiento del área activa respecto al centro
act_off_y = 0;      // [PENDIENTE]

// Overlay táctil IR opcional (el MSI MP161 E2U NO es táctil).
// Referencia: Obeytouch OB156AP-3K1-T99 [FUENTE]: exterior 382 x 235,
// grosor 7.9, área activa 345 x 198, USB 5 V 100 mA.
// https://www.obtouch.com/product/15-6-inch-ir-touch-screen-overlay-with-2-4-6-touchpoints/
usar_overlay_ir = false;
ovl_w = 382; ovl_h = 235; ovl_t = 7.9;

holgura_pantalla = 1.0;      // [DISEÑO] holgura por lado en el alojamiento

// Alojamiento resultante (pantalla o overlay, el mayor)
aloj_w = (usar_overlay_ir ? max(pant_w, ovl_w) : pant_w) + 2*holgura_pantalla;
aloj_h = (usar_overlay_ir ? max(pant_h, ovl_h) : pant_h) + 2*holgura_pantalla;
aloj_t = pant_t + (usar_overlay_ir ? ovl_t : 0) + 0.5;

// ---------------------------------------------------------------------
// 2. FORMA GENERAL (cuña)
// ---------------------------------------------------------------------
inclinacion   = 30;   // [DISEÑO] ángulo de la cara superior/pantalla respecto a la horizontal (20–45)
alto_frontal  = 22;   // [DISEÑO] altura del frente (parte fina)
labio_frontal = 18;   // [DISEÑO] tramo horizontal delante de la pantalla (canal ámbar)
lomo_base     = 54;   // [DISEÑO] tramo horizontal superior trasero (v0: 60; v1: 54 = mínimo con >= 3 mm entre HP y tina)
marco_lat     = 14;   // [DISEÑO] borde de carcasa a cada lado del alojamiento
marco_inf     = 14;   // [DISEÑO] borde bajo el alojamiento (sobre la pendiente)
marco_sup     = 14;   // [DISEÑO] borde sobre el alojamiento
// Disposición de mandos: "columna" (v1: 2 pomos en vertical + 2 botones en fila; consola estrecha)
//                        "fila"    (v0: 2 pomos lado a lado; necesita consola de >= 92 mm)
disposicion_mandos = "columna";
pod_base      = disposicion_mandos == "fila" ? 92 : 64;  // [DISEÑO] ancho mínimo de la consola de mandos
radio_borde   = 5;    // [DISEÑO] redondeo de aristas del perfil
chaflan_lat   = 3;    // [DISEÑO] chaflán en las aristas laterales

pared  = 3.0;   // [DISEÑO] espesor de paredes (PETG/ASA, 0.4 mm boquilla)
suelo  = 4.0;   // [DISEÑO] espesor de la base inferior
alto_pies = 4;  // [DISEÑO] pies de goma (placeholder)

// Mínimos impuestos por el hardware interno (HP [+ KVM] + columna Pi/DC en
// fila; HP con 12 mm trasero y ~100 mm por delante para salir de la tina).
// Con pantallas pequeñas la carcasa la dimensiona el HP, no la pantalla.
// KVM: NO se usa en el prototipo (cambio de entrada por el OSD del MSI).
usar_kvm = false;    // [DISEÑO] true = reserva la bahía del KVM (marcador 140 x 90 x 30)
W_min_hw = 17 + 177.04 + 12 + (usar_kvm ? 140 + 8 : 0) + 153 + 3;   // ver sección 5
D_min_hw = 174.75 + 12 + 3 + 100;
// Derivadas
L_pend = marco_inf + aloj_h + marco_sup;        // longitud sobre la pendiente
run    = L_pend * cos(inclinacion);
subida = L_pend * sin(inclinacion);
ancho_pod = max(pod_base, W_min_hw - (2*marco_lat + aloj_w));
lomo_trasero = max(lomo_base, D_min_hw - labio_frontal - run);
W = marco_lat + aloj_w + marco_lat + ancho_pod; // ancho total
D = labio_frontal + run + lomo_trasero;         // fondo total
H = alto_frontal + subida;                      // altura total (sin pies)
y_pend0 = labio_frontal;            // inicio de la pendiente
y_pend1 = labio_frontal + run;      // fin de la pendiente
function z_sup(y) = y <= y_pend0 ? alto_frontal :
                    y >= y_pend1 ? H :
                    alto_frontal + (y - y_pend0) * tan(inclinacion);

// ---------------------------------------------------------------------
// 3. CONSOLA DE MANDOS (derecha) — coordenadas locales sobre la pendiente
//    u = a lo largo de X desde el borde izq. del pod; v = subiendo la pendiente
// ---------------------------------------------------------------------
pod_x0      = W - ancho_pod;
knob_d      = 30;    // [DISEÑO] diámetro de pomo impreso (o pomo comercial equivalente)
knob_h      = 17;    // [DISEÑO]
knob_sep    = disposicion_mandos == "fila" ? 40 : 58;  // [DISEÑO] separación entre ejes (en "columna": a lo largo de la pendiente)
knob_v      = L_pend * 0.74;  // [DISEÑO] posición del pomo superior (columna) o de ambos (fila)
boton_v     = L_pend * 0.36;  // [DISEÑO] fila de botones
boton_sep   = disposicion_mandos == "fila" ? 40 : 28;  // [DISEÑO] separación entre botones (en X)

// Potenciómetros rotativos GENÉRICOS (marcadores) — modelo [PENDIENTE de medir].
// Valores típicos de catálogo para formatos de 16 y 24 mm, NO de una pieza concreta:
// [casquillo_rosca, agujero_panel, cuerpo_d, prof_tras_panel (con terminales),
//  long_casquillo, radio_antigiro (0 = sin pestaña)]
pot_tipo = "24mm";   // "16mm" | "24mm"   [PENDIENTE] según el que tenga Miguel
function datos_pot(t) =
    t == "16mm" ? [7, 7.4, 17, 18, 7, 7.8] :     // M7 (típico), cuerpo ~Ø17
                  [9.5, 9.9, 25, 22, 9, 10.2];   // 3/8"/M9 (típico), cuerpo ~Ø25
PT = datos_pot(pot_tipo);
agujero_pot   = PT[1];      // [PENDIENTE]
pot_cuerpo_d  = PT[2];      // [PENDIENTE]
pot_prof      = PT[3];      // [PENDIENTE]
pot_casquillo = PT[4];      // [PENDIENTE] determina el espesor máximo de panel
pot_antigiro_r= PT[5];      // [PENDIENTE] 0 = sin hueco antigiro
eje_pot_d     = 6.0;        // [ACORDADO, PENDIENTE de medir] eje de 6 mm (D o estriado)
// Espesor del panel en los pomos: pared + refuerzo, dejando >= 4.5 mm de rosca para tuerca y arandela
refuerzo_pot  = max(0, min(2, pot_casquillo - 4.5 - 3.0));

// Pulsadores de panel GENÉRICOS (marcadores) — modelo [PENDIENTE].
// [agujero_panel, brida_d (frontal), prof_tras_panel (con terminales), tuerca_d, alto_frontal]
boton_tipo = "16mm";  // "12mm" | "16mm"   [PENDIENTE] según el que tenga Miguel
function datos_boton(t) =
    t == "12mm" ? [12.2, 15, 20, 16, 3] :
                  [16.2, 19, 25, 21, 4];
BT = datos_boton(boton_tipo);
pulsador_agujero = BT[0];   // [PENDIENTE]
boton_d          = BT[1];   // [PENDIENTE] brida frontal (solo para render y separación)
boton_prof       = BT[2];   // [PENDIENTE]
boton_tuerca_d   = BT[3];   // [PENDIENTE]
boton_alto       = BT[4];   // [PENDIENTE]
anillos_luz = true;         // [DISEÑO] guía de luz anular bajo cada pomo (tira LED [PENDIENTE])
// Anillo de luz bajo cada pomo
anillo_ext = knob_d + 6;
anillo_int = knob_d + 1;

// ---------------------------------------------------------------------
// 4. CANAL DE LUZ ÁMBAR (frontal inferior)
// ---------------------------------------------------------------------
luz_z0     = 6;    // [DISEÑO] altura del canal sobre el suelo
luz_alto   = 5;    // [DISEÑO]
luz_margen = 30;   // [DISEÑO] distancia a los laterales

// ---------------------------------------------------------------------
// 5. COMPONENTES INTERNOS (marcadores de posición)
// ---------------------------------------------------------------------
// HP: modelo exacto DESCONOCIDO (torre/mini de ~2017).
// "desktop_mini_ref" usa las medidas de chasis del HP EliteDesk 800 G3
// Desktop Mini como REFERENCIA ilustrativa [FUENTE, NO es el equipo de
// Miguel]: 177.04 x 34.29 x 174.75 mm (W x H x D, sin bisel).
// https://support.hp.com (doc. c05371240, copia consultada en
// https://server-shop.ua/assets/images/resources/18163/hp-elitedesk-800-g3-desktop-mini-business-pc-35-w-65-w-specifications-hp-customer-support.pdf)
// "generico": caja provisional [PENDIENTE] 200 x 200 x 45.
// Un SFF (~2017) NO cabe en esta cuña: requeriría rediseño.
hp_preset = "desktop_mini_ref";
function datos_hp(p) = p == "desktop_mini_ref" ? [177.04, 174.75, 34.29] : [200, 200, 45];
HPD = datos_hp(hp_preset);
hp_w = HPD[0]; hp_d = HPD[1]; hp_h = HPD[2];
hp_holgura = 3;      // [DISEÑO]
hp_x = pared + 14;   // [DISEÑO] posición (izquierda, contra la trasera; deja sitio a orejetas)
hp_y = D - pared - 14 - hp_d;   // 14 mm: orejetas + holgura de conectores traseros
hp_z = suelo + 5;    // [DISEÑO] sobre raíles de 5 mm (flujo de aire inferior)

// Raspberry Pi: placa 85 x 56 mm, agujeros M2.5 a 58 x 49 mm [FUENTE]
// (dibujo mecánico oficial Pi 4: https://datasheets.raspberrypi.com/rpi4/raspberry-pi-4-mechanical-drawing.pdf ; agujeros Ø2.7)
pi_w = 85; pi_d = 56; pi_h = 20;      // altura con conectores [PENDIENTE] según modelo
pi_agujeros = [58, 49];
pi_agujero_borde = 3.5;               // [FUENTE] agujeros a 3.5 mm del borde
pi_usb_hueco = 40;                    // [DISEÑO] espacio libre ante los USB de la Pi para clavijas (Arduino, ratón)
pi_x = W - pared - pi_usb_hueco - pi_w;  // atrás a la derecha; USB hacia la pared derecha
pi_y = D - pared - 27 - pi_d;         // v1: la bandeja (con su ala) termina antes de las orejetas traseras
pi_z = suelo + 8;                     // separadores de 8 mm

// KVM: TESmart HKS201-P23-V2 recomendado, dimensiones NO publicadas.
// Marcador [PENDIENTE] 140 x 90 x 30 mm.
kvm_w = 140; kvm_d = 90; kvm_h = 30;
kvm_x = hp_x + hp_w + 12;          // solo si usar_kvm
kvm_y = D - pared - 8 - 6 - kvm_d;   // 8 = costilla (definida más abajo)   // por delante de la costilla trasera
kvm_z = suelo + 4;

// Distribución de alimentación (regleta DC / DC-DC / fusibles) [PENDIENTE]
psu_w = 110; psu_d = 60; psu_h = 30;
psu_x = pi_x + pi_w - psu_w - 6;   // a la izquierda del carril derecho (cable USB del Arduino)
psu_y = pi_y - 14 - psu_d;
psu_z = suelo + 4;

// Arduino Micro (lee potenciómetros y botones; USB a la Pi)
// [FUENTE] tienda oficial: largo 48 mm, ancho 18 mm, 13 g; PCB máx. 48 x 17,7 mm con el
// conector micro-USB sobresaliendo del largo. https://store.arduino.cc/products/arduino-micro
// Alturas [PENDIENTE]: componentes ~4 mm sobre la PCB; pines macho ~8.5 mm por debajo.
ard_l = 48; ard_w = 17.7; ard_pcb = 1.6;
ard_arriba = 4;      // [PENDIENTE]
ard_pines  = 8.5;    // [PENDIENTE] (con conectores dupont hembra debajo hacen falta ~15 mm)
ard_usb_sale = 1.5;  // [PENDIENTE] micro-USB sobresale del borde
ard_clavija = 22;    // [PENDIENTE] clavija micro-USB + alivio (recta) por detrás del borde
ard_altura_soporte = 16;   // [DISEÑO] PCB sobre la bandeja (deja sitio a los dupont)
// Soporte: en la bandeja de servicio, bajo la consola, eje largo en Y con el USB hacia atrás (hacia la Pi)
ard_cx = W - pared - 35;               // [DISEÑO] carril derecho; el soporte cabe por la abertura de la bandeja (se desmonta con ella)
ard_y  = 70;                           // [DISEÑO] borde frontal de la PCB (por delante de la distribución DC)
sop_tab = 8;                           // [DISEÑO] orejeta de atornillado en cada extremo
sop_ard_w = ard_w + 8;
sop_ard_y0 = ard_y - 3 - sop_tab;
sop_ard_l = ard_l + 6 + 2*sop_tab;
sop_ard_z0 = suelo + 4;                // sobre torretas de 4 mm de la bandeja
ard_pcb_z = sop_ard_z0 + ard_altura_soporte;   // cara inferior de la PCB
canal_usb_ancho = 10;                  // [DISEÑO] canal del cable micro-USB hacia la Pi

// ---------------------------------------------------------------------
// 6. FABRICACIÓN
// ---------------------------------------------------------------------
// Impresora de Miguel: Bambu Lab A1 [FUENTE] volumen 256 x 256 x 256 mm, marco abierto.
// https://bambulab.com/en/a1/tech-specs  -> PLA/PETG/TPU "ideal"; ABS/ASA "no recomendado".
// Material recomendado: PETG (ASA/ABS alabean sin cámara cerrada en piezas grandes).
impresora = "bambu_a1";
cama_x = 256; cama_y = 256;   // [FUENTE] Bambu Lab A1
cama_z = 256;                 // [FUENTE]
material = "PETG";            // [DISEÑO] recomendado para A1 (marco abierto)
margen_cama = 10;             // [DISEÑO] margen de seguridad
inserto_d  = 4.0;   // [PENDIENTE] agujero para inserto M3 térmico (según fabricante del inserto)
inserto_l  = 5.7;   // [PENDIENTE]
boss_d     = 8.0;   // [DISEÑO]
tornillo_d = 3.4;   // [DISEÑO] paso libre M3
pasador_d  = 3.2;   // [DISEÑO] alojamiento para pasador Ø3 (varilla acero o filamento)
pasador_l  = 16;    // [DISEÑO] longitud total (8 mm por lado)
costilla   = 8;     // [DISEÑO] profundidad de costillas de unión internas

// Cortes de impresión (automáticos según cama)
nx_cortes = ceil(W / (cama_x - margen_cama));
ny_cortes = ceil(D / (cama_y - margen_cama));
function corte_x(i) = W * i / nx_cortes;
function corte_y(j) = D * j / ny_cortes;

// Bandeja de servicio inferior extraíble (lleva la Pi y la distribución
// de alimentación; se desmonta desde abajo sin abrir la carcasa) [DISEÑO]
serv_x = min(psu_x, pi_x) - 6;
serv_y = min(psu_y, sop_ard_y0) - 6;   // v1: la bandeja incluye el soporte del Arduino
serv_w = (W - pared - 21) - serv_x;     // v1: deja libres las orejetas del lateral derecho
serv_d = (pi_y + pi_d + 4) - serv_y;
serv_ala = 8;        // [DISEÑO] ala de atornillado alrededor
serv_ala_t = 2;      // [DISEÑO] espesor del ala (queda dentro de la altura de los pies)

$fn = 48;
