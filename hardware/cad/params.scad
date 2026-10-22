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
//   [MEDIDO]    medida real tomada por Miguel (fecha e instrumento indicados)
//   [FOTO]      observación en una foto de Miguel (posición/orden, NO es una medida)
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
hp_preset = "iris_mitx_desnuda";   // [DISEÑO] ver sección 5 (HP Slimline 260-a110ns desmontado)
W_min_hw = 17 + (hp_preset == "desktop_mini_ref" ? 177.04 : 170) + 12 + (usar_kvm ? 140 + 8 : 0) + 153 + 3;   // ver sección 5
D_min_hw = (hp_preset == "desktop_mini_ref" ? 174.75 + 12 : 170 + 3) + 3 + 100;
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
// HP: HP Slimline 260-a110ns (confirmado 2026-10-18), SE DESMONTA DE SU CAJA.
// En Orbit va solo la placa base (+ disipador/ventilador, RAM, SSD, I/O frontal).
// Datos del propietario 2026-10-18: placa HP "Iris-A6" (id provisional), AMD A6-7310,
// 2 DIMM DDR3L, adaptador EXTERNO 65 W 19,5 V 3,33 A (sin red eléctrica dentro de Orbit).
// [FUENTE HP, modelos hermanos, consultado 2026-10-18]: placas Iris-E2/Iris-A8 de la
// serie 260-a1xx = Mini ITX 17,0 x 17,0 cm; I/O trasero con entrada DC, VGA, HDMI,
// 2x USB 3.0, 2x USB 2.0, RJ45, audio (support.hp.com c05102388, c05341421, c05296965).
// Ver docs/datos-pendientes-hp.md. Todo lo marcado [PENDIENTE] es "de medir tras desmontar".
//
// "iris_mitx_desnuda": placa mini-ITX en horizontal, I/O trasero contra la pared
//                      posterior (ventana tipo escudo I/O). POR DEFECTO.
// "desktop_mini_ref":  caja v1 (EliteDesk 800 G3 Desktop Mini, solo referencia histórica).
// hp_preset: definido en la sección de mínimos de hardware (más arriba)
hp_desnuda = hp_preset == "iris_mitx_desnuda";
mitx = 170;                 // [FUENTE] mini-ITX 170 x 170 mm (HP: "Mini ITX 17.0 x 17.0 cm")
                            // [MEDIDO 2026-10-18, Miguel] la placa mide 17 x 17 cm: coincide.
// Agujeros: patrón estándar mini-ITX (C, F, H, J). No medidos con calibre.
// 2026-10-19: Miguel imprimió hardware/impresion/plantillas/PRUEBA_plantilla_agujeros_HP.stl
// y los 4 agujeros C/F/H/J cuadraron con su placa (verificado físicamente con esa plantilla).
// [FUENTE estándar ATX/mini-ITX: agujeros C-F-H-J; cotas relativas a C:
// F = (+157,48 a lo largo del borde I/O, +22,86 hacia delante), H = (0, +154,94), J = (+157,48,
// +154,94); C a 6,35 mm del lateral y 10,16 mm del borde trasero]. Comprobado con el plano de
// una placa mini-ITX comercial (FLEX-WIZARD-IMX8M-MINI, ES France: 6,35 / 163,83 / 10,16 /
// 33,02 / 165,1 mm). v2 tenía F alineado con C (sin los 22,86 mm): corregido en v3.
// [FOTO] el agujero trasero más cercano al borde I/O está en el extremo del audio (C, X baja
// en Orbit) y el más retrasado (F) en el extremo del jack DC.
mitx_agujeros = [157.48, 154.94];   // [FUENTE estándar] C->F/J a lo largo del borde I/O; C->H/J hacia delante
mitx_ag_f = 22.86;                  // [FUENTE estándar] F está 22,86 mm (0,9") más adentro que C
mitx_ag_borde = [6.35, 10.16];      // [FUENTE estándar] agujero C: 6,35 mm del lateral y
                            // 10,16 mm del borde trasero (I/O). No medido en la placa HP.
hp_separador = 6.35;        // [FUENTE estándar ATX] altura de separadores 6,35 mm (1/4")
hp_pcb = 1.6;               // [PENDIENTE] espesor PCB típico
hp_comp_h = 35;             // [MEDIDO 2026-10-18, Miguel] altura máxima sobre la placa: 35 mm
                            // (el disipador con su ventilador es lo más alto). Límite del modelo:
                            // 41 mm con 3 mm de holgura a la tina. v2: supuesto de 38 mm.
// I/O trasero [FOTO 2026-10-18]: los conectores asoman por la chapa de la caja HP; NO hay escudo
// I/O separado. En Orbit (vista superior, I/O hacia atrás) el audio queda a la izquierda
// (X baja) y el jack DC a la derecha. La ventana ya impresa de carcasa_x0_y1 no se toca.
// La placa impresa se acota en la ventana, mirando la trasera: x desde el borde izquierdo,
// z desde el borde inferior. Ese orden es el de la foto, no el de la X del mundo.
hp_io_h = 44.45;            // [FUENTE estándar ATX] abertura del escudo I/O 158,75 x 44,45 mm
hp_io_w = 158.75;
hp_io_prof = 25;            // [PENDIENTE] fondo de la pila de conectores traseros sobre la placa
hp_io_x0 = 5.6;             // [PENDIENTE de medir] posición de la abertura respecto al borde izq.
hp_io_baja = 2.24;          // [PENDIENTE] la abertura empieza ~2,2 mm bajo la cara superior de la PCB
// Placa I/O impresa (PROVISIONAL_placa_io_hp). Entra por dentro de la ventana ya
// impresa. El reborde apoya en la cara interior; el tetón centra. No se atornilla:
// la pared tiene 3 mm y carcasa_x0_y1 no se reimprime. `fijacion` no se usa aquí.
// Huecos [PENDIENTE] [FOTO 2026-10-22]: la ventana 159,75 × 45,45 es la escala de la
// foto casi perpendicular. Cada hueco lleva ya ~1 mm por lado. Donde dos conectores
// salen casi pegados el nervio queda en 2 mm (ahí la holgura es menor de 1 mm).
// [nombre, x, z, ancho, alto] en mm, desde la esquina inferior izquierda de la ventana.
io_placa_t = 1.4;            // [DISEÑO] chapa 1,2–1,6 mm; el tetón repite este grueso
io_placa_labio = 6;         // [DISEÑO] reborde interior, arriba y a los lados
io_placa_labio_inf = 4.5;   // [DISEÑO] abajo hay ~5,2 mm hasta el suelo de la base
io_placa_holg = 0.4;        // [DISEÑO] el tetón entra con 0,4 mm por lado (no es apriete)
io_huecos = [
    ["dc",      0,   0,    7,    8],   // jack DC, a ras del borde inferior; el barril no se ve
    ["vga",     9,   4,   24.5, 14],
    ["hdmi",   35.5, 3.5, 15.5, 10],   // solo el conector; la pestaña de encima queda tapada
    ["usb3",   73,   4,   17,   16],   // 2 USB 3 azules, apilados
    ["rj_usb", 92,   3,   24,   31],   // RJ45 sobre 2 USB 2
    ["audio", 126,   2,   23,   32],   // columna de 3 jacks y su chapita
    ["pines", 151,   1,    7,    7],   // cabecera suelta, abajo a la derecha
];
function datos_hp(p) = p == "desktop_mini_ref" ? [177.04, 174.75, 34.29]
                     : p == "iris_mitx_desnuda" ? [mitx, mitx, hp_separador + hp_pcb + hp_io_h - hp_io_baja]
                     : [200, 200, 45];
HPD = datos_hp(hp_preset);
hp_w = HPD[0]; hp_d = HPD[1]; hp_h = HPD[2];   // envolvente (con separadores y pila I/O)
hp_holgura = 3;      // [DISEÑO]
hp_x = pared + 14;   // [DISEÑO] posición (izquierda, contra la trasera; deja sitio a orejetas)
hp_atras = hp_desnuda ? 3 : 14;   // [DISEÑO] placa desnuda: borde trasero a 3 mm de la pared
                                  // (los conectores sobresalen ~1-2 mm y asoman por la ventana)
hp_y = D - pared - hp_atras - hp_d;
hp_z = hp_desnuda ? suelo : suelo + 5;   // desnuda: separadores desde el suelo
hp_pcb_z = hp_z + hp_separador;          // cara inferior de la PCB
function hp_agujeros() = [for (i = [0, 1], j = [0, 1])   // C (0,0), H (0,1), F (1,0), J (1,1)
    [hp_x + mitx_ag_borde[0] + i*mitx_agujeros[0],
     hp_y + hp_d - mitx_ag_borde[1] - (j == 1 ? mitx_agujeros[1] : i*mitx_ag_f)]];

// Disco vigente (2026-10-20): HDD Toshiba 3,5" del propietario. El modelo usa SFF-8301
// (101,6 x 147 x 26,1), no la medición a ojo de ~150 x 100 x 25. El SSD 2,5"
// (SFF-8201: 100,45 x 69,85 x 9,5) queda como opción con usar_hdd_35 = false.
// La grabadora DVD SE RETIRA (no se modela).
usar_hdd_35 = true;         // [DISEÑO] true = soporte para el HDD 3,5" original
                            // 2026-10-19: true. El disco real de Miguel es un Toshiba 3,5" (foto, MAR-2017).
                            // 2026-10-20: Miguel lo midió a ojo ~150 x 100 x 25 mm. El modelo NO usa esa
                            // medición: sigue las cotas SFF-8301 de la línea siguiente.
disco = usar_hdd_35 ? [101.6, 147, 26.1] : [100.45, 69.85, 9.5];   // [x, y, z]
// Patas del soporte. SSD: 8 (la plancha queda 3 mm sobre las torretas de empalme de 5 mm).
// HDD 3,5" (2026-10-19): la plancha (147 mm de fondo) cubre 6 torretas de empalme (las 4 del
// corte Y en x = 201/258 y las 2 del corte X en y = 186), con sus pletinas y tornillos debajo.
// Pila bajo la plancha: torreta 5 + pletina 3 + cabeza M3 ~3 [PENDIENTE tornillo] = z 16 sobre
// el suelo de la pieza; + cabeza 6-32 del disco ~2,4 [PENDIENTE] colgando bajo la plancha + 0,6
// de holgura -> plancha a z = suelo + 14.
disco_soporte_h = usar_hdd_35 ? 14 : 8;   // [DISEÑO]
disco_x = hp_x + hp_w + 6;
disco_y = usar_hdd_35 ? D - pared - 30 - disco[1] : D - pared - 30 - disco[1];
disco_z = suelo + disco_soporte_h + 2;   // plancha de 2 mm sobre las patas
// Agujeros inferiores del disco: distancia de su eje al lateral del disco.
// HDD 3,5" [FUENTE SFF-8301 rev 1.9, A4 = 95,25 entre agujeros, A5 = 3,18 al lateral; rosca 6-32;
//   pares a lo largo: A7 = 41,28, A6 = 44,45, A13 = 76,20; https://members.snia.org/document/dl/25862 ,
//   consultado 2026-10-19]. SSD: 6 = valor previo del modelo (no verificado con SFF-8201).
disco_ag_lado = usar_hdd_35 ? 3.18 : 6;   // los colisos van a lo largo (Y) y cubren todas las posiciones

// I/O frontal del HP (USB 2.0, audio, lector SD según el propietario) reubicado en el
// lateral IZQUIERDO, zona trasera alta. Placa y conectores [PENDIENTE de medir tras desmontar].
io_frontal = [16, 70, 26];  // [PENDIENTE] marcador x(fondo) y(ancho) z(alto)
io_frontal_y = D - pared - 28 - io_frontal[1];   // detrás de la tina de pantalla
io_frontal_z = 70;
// Pulsador de encendido del HP (contacto seco en paralelo al cabezal del botón original;
// patillaje [PENDIENTE de medir con polímetro]) + LED de encendido, lateral izquierdo.
boton_hp_d = 12;            // [DISEÑO] pulsador de panel Ø12 [PENDIENTE modelo]
boton_hp_prof = 22;         // [PENDIENTE]
boton_hp_y = D - pared - 25;
boton_hp_z = 112;
// El Ø12,2 y el Ø3,1 están cortados en carcasa.scad (literal 14 mm). No se regenera.
led_hp_dz = 14;             // el mismo 14 mm del agujero ya impreso
// Capuchón impreso. Holgura radial en el Ø12,2: 0,3 mm por lado → vástago Ø11,6. [DISEÑO]
// En PETG, 0,15 mm por lado suele agarrotar. La PRUEBA_boton lo comprueba.
cap_holg = 0.30;
cap_brida_d = 16;           // no pasa el Ø12,2
cap_brida_t = 1.6;
cap_sale = 2.4;             // asoma en reposo, por fuera de la pared
cap_recorrido = 1.5;        // hasta el tope duro. El clic del táctil va al final.
cap_simbolo_h = 0.45;       // símbolo de encendido hundido
cap_vastago_d = boton_hp_d + 0.2 - 2 * cap_holg;
cap_vastago_l = pared + cap_sale;
// Táctil de catálogo, en paralelo al botón original. sw_tipo = "12x12" | "6x6".
// Carrera 0,25 mm [FUENTE] CUI TS13-1212-73 y serie Omron B3F.
// El reparto cuerpo / vástago es [DISEÑO], no un calibre: 5,0 + 2,3 = 7,3 y 3,0 + 1,3 = 4,3.
sw_tipo = "12x12";
sw_carrera = 0.25;
sw_holg = 0.25;             // por lado, en el cajeado
function sw_lado() = sw_tipo == "6x6" ? 6 : 12;
function sw_cuerpo_h() = sw_tipo == "6x6" ? 3.0 : 5.0;
function sw_vastago_h() = sw_tipo == "6x6" ? 1.3 : 2.3;
function sw_vastago_d() = sw_tipo == "6x6" ? 2.4 : 3.6;
// Soporte. Se pega a la cara interior. Los Ø2,7 son el plan B, no el montaje.
sop_t = 1.8;
sop_ala = 16;               // semiancho de la placa de pegado
sop_suelo_t = 2.0;
sop_bajo = cap_brida_d / 2 + 0.6 + sop_suelo_t;   // bajo el eje: deja pasar la pestaña
guia_diag = 2.40;           // entra en el Ø3,1
guia_entra = 1.25;          // cuánto entra en la pared, desde la cara interior
taladro_b_y = 14;           // plan B: a cada lado del eje
taladro_b_d = 2.7;          // paso del Ø2,5 en el soporte (la pared se taladra a Ø2,0)

// Raspberry Pi 4 (Miguel, 2026-10-20, con la placa delante: es una Pi 4).
// Encima va un HAT VHF con OLED y antena SMA que se pliega sobre la Pi.
// Miguel dice que la carcasa cierra de sobra: es una observación, no una cota.
// El HAT no se modela: sus medidas no se han tomado [PENDIENTE]. pi_h NO incluye el HAT.
// Placa 85 x 56 mm, agujeros M2.5 a 58 x 49 mm, a 3,5 mm del borde [FUENTE]
//   https://datasheets.raspberrypi.com/rpi4/raspberry-pi-4-mechanical-drawing.pdf
//   agujeros Ø2,7. El dibujo (y el modelo de process1183/openscad-library, rpi_4b.scad,
//   que cita ese plano) pone USB-A y RJ45 en el canto ox = 85 (el de 56 mm),
//   micro-HDMI y USB-C en el canto oy = 0, micro-SD junto a ox = 0 y el GPIO en oy = 56.
// Bandeja v2, orientación de la foto de Miguel (2026-10-21) [FOTO].
// La Pi suelta queda en la mitad izquierda del hueco, pegada a la trasera:
//   USB-A y RJ45 hacia +Y (la rejilla / la trasera), clavija del Nano por arriba;
//   micro-HDMI y USB-C hacia +X (la canaleta);
//   micro-SD hacia −Y; GPIO y el lado del OLED del HAT hacia −X;
//   la antena SMA del HAT apunta a +X y se tumba sobre la bandeja [PENDIENTE medir].
// El eje largo (85 mm) va en Y. En X el hueco mide 110 mm: 85 + una clavija
// no caben, así que los USB no pueden mirar a ±X.
// La foto los deja casi en el borde trasero del hueco (y = 274,5). Detrás de
// ese borde la pared interior está a 23 mm (y = 297,5): una clavija recta no
// cabe. La placa se adelanta hasta dejar 42 mm entre la cara del conector y
// la pared (36 mm de clavija + 6 mm). Sigue siendo la orientación de Miguel.
pi_w = 56; pi_d = 85; pi_h = 20;      // X, Y. Altura de la placa con conectores, SIN el HAT [PENDIENTE]
pi_x0 = 330;                          // [DISEÑO] borde GPIO (oy = 56), a −X. Centro de la placa en x = 358,
                                      // entre el HDD (acaba en x = 294,6) y la canaleta (x ≈ 420)
pi_y0 = 167.5;                        // [DISEÑO] borde de la micro-SD (ox = 0). Cara de los USB en y = 255,5
pi_x = pi_x0; pi_y = pi_y0;
pi_agujeros = [58, 49];               // [FUENTE] en ejes de la placa (ox, oy), no en X/Y de la bandeja
pi_agujero_borde = 3.5;               // [FUENTE]
pi_z = suelo + 8;                     // separadores de 8 mm
// Clavija USB-A. La carcasa metálica mide unos 12 mm (USB-IF, tipo A). El
// sobremolde de un cable normal no está normalizado: en cables cortos suele
// quedar entre 30 y 40 mm desde la punta. [DISEÑO] se reservan 36 mm desde
// la cara del conector (el conector de la Pi sale ~3 mm de la PCB, misma fuente).
pi_clavija = 36;

// KVM: TESmart HKS201-P23-V2 recomendado, dimensiones NO publicadas.
// Marcador [PENDIENTE] 140 x 90 x 30 mm.
kvm_w = 140; kvm_d = 90; kvm_h = 30;
kvm_x = hp_x + hp_w + 12;          // solo si usar_kvm
kvm_y = D - pared - 8 - 6 - kvm_d;   // 8 = costilla (definida más abajo)   // por delante de la costilla trasera
kvm_z = suelo + 4;

// Distribución de alimentación (regleta DC / DC-DC / fusibles) [PENDIENTE]
// HP v2: NO hace falta (HP con su adaptador externo de 19,5 V al jack DC de la placa;
// Pi y MSI con sus fuentes USB-C certificadas). Se conserva como opción.
usar_distribucion = false;   // [DISEÑO]
psu_w = 110; psu_d = 60; psu_h = 30;
psu_x = pi_x + pi_w - psu_w - 6;   // a la izquierda del carril derecho (cable USB del Arduino)
psu_y = pi_y - 14 - psu_d;
psu_z = suelo + 4;

// Adaptador de vídeo de la Pi: HDMI (entrada, desde la micro-HDMI de la Pi) -> USB-C
// DP Alt Mode (salida, a la USB-C 1 de la MSI). Debe funcionar EN ESE SENTIDO (activo).
// Miguel tiene uno UGREEN sin verificar (probablemente del sentido contrario, USB-C -> HDMI).
// Hueco reservado en la bandeja, por delante de la Pi. Medidas [PENDIENTE] del adaptador real.
adap_video = [72, 32, 16];   // [PENDIENTE] marcador x y z (incluye holgura de cables)
adap_x = pi_x;
adap_y = pi_y - 12 - adap_video[1];
adap_z = suelo + 2;
// Modo B ahora poco probable (los manuales de la MSI no documentan DDC/CI): el hueco se conserva.
// Bandeja v2: el hueco de 72 mm del adaptador no cabe junto a la Pi girada,
// los carros y la capturadora. Se quita de la bandeja. Recolocar cuando se
// mida el aparato. [PENDIENTE]
usar_adaptador_video = false;

// Capturadora HDMI->USB (UVC) para el modo C (RECOMENDADO): HDMI del HP -> capturadora -> USB
// de la Pi. Referencia vista en Amazon.es el 2026-10-18 (marca SUOFEIXIANG, "4K30 entrada /
// 1080p", 14,69 €, sin URL): tipo "pincho" con cable corto USB-A/USB-C. Medidas NO publicadas.
// Es una RESERVA DE ESPACIO [DISEÑO], no la medida del aparato: cuerpo + clavija HDMI recta.
// Va en la bandeja de servicio, por delante del hueco del adaptador (se fija con velcro o brida).
// La reserva nominal sigue siendo 72 mm. Las dos torretas DC ya impresas (y el riel que
// se atornilla a ellas) comen el extremo derecho: la caja que se comprueba acaba en riel_x0a.
usar_capturadora = true;       // [DISEÑO]
captura = [72, 30, 20];        // [DISEÑO] reserva nominal; PENDIENTE de medir el aparato real
// Con la Pi a la izquierda el hueco de 72 mm no entra. El nido es el bolsillo
// que queda a +X de la Pi, entre los micro-HDMI y el giro de la canaleta.
// [PENDIENTE] medir el aparato: si no cabe aquí, el nido se mueve.
cap_hueco = [26, 32, 14];
cap_x = 390;
cap_y = 220;
cap_z = suelo + 2;
// El nido cae donde ahora va el Nano de mandos. No se dibuja ni se comprueba.
// [PENDIENTE] dónde queda la capturadora.
usar_nido_captura = false;

// Arduino Nano de MANDOS (2026-10-20). Sustituye al Micro. Clon ATmega328P,
// mini-USB, conversor USB-serie probablemente CH340 (dato de Miguel, no leído
// el chip). [FUENTE] PCB 18 x 45 mm, 7 g, mini-USB:
//   https://store.arduino.cc/products/arduino-nano
//   https://docs.arduino.cc/hardware/nano/
// La placa de la foto no se ha medido [PENDIENTE]: largo, ancho, alto y cuánto
// sale el mini-USB. El CAD usa la cota de catálogo.
ard_l = 45; ard_w = 18; ard_pcb = 1.6;
ard_arriba = 4;      // [PENDIENTE]
ard_pines  = 11.5;   // [PENDIENTE] pin macho más largo, separador incluido. El aire es pin_bajo_pcb − ard_pines
ard_usb_sale = 1.5;  // [PENDIENTE] cuánto sobresale el mini-USB del borde de la PCB
ard_clavija = 22;    // [PENDIENTE] clavija mini-USB + alivio (recta), por detrás del borde
ard_altura_soporte = 16;   // [DISEÑO] PCB sobre la bandeja (deja sitio a los dupont)
// Soporte: en la bandeja de servicio, bajo la consola, eje largo en Y con el USB hacia atrás (hacia la Pi)
ard_cx = W - pared - 35;               // [DISEÑO] carril derecho; el soporte cabe por la abertura de la bandeja (se desmonta con ella)
ard_y  = 70;                           // [DISEÑO] borde frontal de la PCB. El Nano es 3 mm más corto que el Micro: el mini-USB queda más lejos de la boca del canal
sop_tab = 8;                           // [DISEÑO] orejeta de atornillado en cada extremo
// Bandeja YA IMPRESA (Miguel, 2026-10-20). Estas dos cotas salen del Micro
// (ard_l 48, ard_y 70, sop_tab 8) y no se recalculan: las torretas están en
// y = sop_ard_y0 + sop_tab/2 = 63 y y = sop_ard_y0 + sop_ard_l - sop_tab/2 = 125.
sop_ard_w = ard_w + 8;                 // el ancho del soporte sí sigue a la placa; las torres están en el eje X
sop_ard_y0 = 59;                       // [DISEÑO] congelado a la bandeja impresa
sop_ard_l = 70;                        // [DISEÑO] congelado a la bandeja impresa
sop_ard_z0 = suelo + 4;                // sobre torretas de 4 mm de la bandeja
ard_pcb_z = sop_ard_z0 + ard_altura_soporte;   // cara inferior de la PCB
canal_usb_ancho = 10;                  // [DISEÑO] canal impreso; el cable mini-USB puede ir más justo que el micro-USB [PENDIENTE]

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
// Miguel no usa insertos: el tornillo autorroscante entra en el PETG.
// "inserto" recupera el Ø4 × 5,7. Las piezas YA impresas (base, carcasas
// x0_y0 / x0_y1 / x1_y0, soporte, biseles) no leen este parámetro.
fijacion   = "autorroscante";   // [DISEÑO] "autorroscante" | "inserto"
rosca_d    = 2.5;   // [DISEÑO] guía para autorroscante M3 en PETG
rosca_prof = 8;     // [DISEÑO] profundidad mínima cuando el plástico llega
rosca_pared = 2.5;  // [DISEÑO] pared mínima alrededor de la guía, para que no raje
boss_d     = 8.0;   // [DISEÑO]
tornillo_d = 3.4;   // [DISEÑO] paso libre M3 (la cabeza no rosca: carros, tapa, base)
echo(str("FIJACION;", fijacion, ";d;", rosca_d, ";prof_min;", rosca_prof, ";paso_libre;", tornillo_d));
pasador_d  = 3.2;   // [DISEÑO] alojamiento para pasador Ø3 (varilla acero o filamento)
pasador_l  = 16;    // [DISEÑO] longitud total (8 mm por lado)
costilla   = 8;     // [DISEÑO] profundidad de costillas de unión internas

// Cortes de impresión (automáticos según cama)
nx_cortes = ceil(W / (cama_x - margen_cama));
ny_cortes = ceil(D / (cama_y - margen_cama));
function corte_x(i) = W * i / nx_cortes;
function corte_y(j) = D * j / ny_cortes;

// Bandeja de servicio. La BASE ya está impresa: el hueco y los 4 M3 no se
// mueven. Estas cuatro cotas son las de la bandeja v1 (salían de la Pi y del
// soporte cuando el USB miraba a +X). Congeladas el 2026-10-21. No volver a
// derivarlas de pi_x/pi_y.
// Tornillos (centro del ala): x = 318,26 y 436,26; y = 49 y 278,492.
serv_x = 322.26;
serv_y = 53;
serv_w = 110;
serv_d = 221.492;
serv_ala = 8;        // [DISEÑO] ala de atornillado alrededor
serv_ala_t = 2;      // [DISEÑO] espesor del ala (queda dentro de la altura de los pies)

// ESP8266 de la foto del 2026-10-21 (módulo ESP-12, micro-USB, cuatro agujeros
// de esquina, pines macho hacia abajo). Puede no ser un NodeMCU DEVKIT 1.0.
// Escala de la foto: una fila de 15 pines a 2,54 mm son 35,6 mm entre centros
// extremos. La placa se ve más larga que esa fila y más ancha que el Nano
// (18 mm). Estimación 58 x 31 mm, del orden de un clon tipo LoLin. No es un
// calibre. [PENDIENTE] de medir. Referencia que NO se usa como cota de esta
// placa: DEVKIT 1.0, 25,4 x 48,26 (NODEMCU_DEVKIT_V1.0.PDF).
// En el carro de la bandeja v2 el micro-USB mira a +X (hacia el centro de la bandeja).
esp_l = 58;                               // [PENDIENTE] estimación de la foto
esp_w = 31;                               // [PENDIENTE] estimación de la foto
esp_clavija = 10;                         // [DISEÑO] reserva del enchufe; no medido
esp_pcb = 1.6;                            // [DISEÑO] PCB típico
esp_pcb_z = 17.5;                         // OBSOLETO, solo el carro. El hueco usa pin_bajo_pcb
esp_mod = [24, 16, 3];                    // ESP-12 sobre la PCB, x y z [DISEÑO]; no medido
esp_ag_inset = 3.5;                       // centro del agujero a la esquina [DISEÑO]; no medido
// Carcasa Dupont hembra de 2,54 mm. La usan los carros obsoletos.
// El hueco fijo no: Miguel pone regletas macho hacia abajo y la cota es pin_bajo_pcb.
dupont_carcasa = 14.5;                    // [DISEÑO] no medido en los cables de Miguel
dupont_separador = 2.5;                   // [DISEÑO] plástico negro bajo la PCB; no medido

// Segundo Nano, de PRÁCTICAS. Foto 2026-10-21: pines macho largos hacia abajo,
// separador negro bajo la PCB, ICSP de 6 pines hacia arriba en el extremo
// contrario al mini-USB. PCB de catálogo 18 x 45. Alturas de pin e ICSP
// [PENDIENTE]. En el carro el mini-USB mira a +X. El ICSP, en el otro extremo, hacia arriba.
pr_l = ard_l; pr_w = ard_w;
pr_pcb = 1.6;
pr_pcb_z = 17.5;                          // OBSOLETO, solo el carro. El hueco usa pin_bajo_pcb
pr_icsp = [7.6, 5.1, 8];                  // 2x3 hacia arriba [DISEÑO]; no medido
pr_clavija = 12;                          // [DISEÑO] reserva del enchufe mini-USB; no medido
// Los carros de la bahía v2 ya no se imprimen. El hueco fijo deja pin_bajo_pcb.

// Riel modular (2026-10-21). Miguel: los DOS tornillos a la IZQUIERDA de la
// canaleta, en la bandeja ya impresa. Son las dos torretas de la distribución
// DC que caen dentro de la bandeja (x = psu_x + psu_w - 6). Las otras dos,
// en x = psu_x + 6, quedan fuera de la pieza. No son las torretas del soporte
// del Nano de mandos (van en el eje del canal, y = 63 y y = 125: ese soporte
// ya está pasado a imprimir y no se modifica) ni los 4 M3 del ala, que sujetan
// la bandeja a la base. No mover psu_x/y/w/d: son los agujeros impresos.
dc_riel_x  = psu_x + psu_w - 6;
dc_riel_ya = psu_y + 6;
dc_riel_yb = psu_y + psu_d - 6;
riel_x0  = dc_riel_x - boss_d/2;                 // a ras de la torreta; el tramo delantero no entra más
riel_caj_d = boss_d + 0.4;                      // cajeado Ø8,4: 0,2 mm de holgura radial [DISEÑO]
riel_caj_pared = 1.6;                           // pared alrededor del cajeado [DISEÑO]
riel_x0a = dc_riel_x - riel_caj_d/2 - riel_caj_pared;  // el tramo de anclaje es más ancho a la izquierda
riel_x1f = ard_cx - sop_ard_w/2 - 0.9;          // el tramo delantero no toca el soporte de mandos
riel_x1a = dc_riel_x + 7.2;                     // el tramo de anclaje no llega a la pared del canal
riel_y0  = 58;                                  // [DISEÑO] punta delantera, sobre el suelo de la bandeja
riel_yq  = sop_ard_y0 + sop_ard_l + 1;          // 130: a partir de aquí el riel puede ser más ancho
riel_y1  = dc_riel_yb + boss_d/2 + 3;
riel_h   = 6;                                   // [DISEÑO]
riel_hueco_x = (riel_x0 + riel_x1f) / 2;        // eje de los tornillos de los carros
// Dos puestos que caben a la vez (76 y 105). El central (90) solo si no hay
// otro carro: con el Nano en 76 o el ESP en 105 se solapan. [DISEÑO]
riel_est = [76, 90, 105];
// Qué par está montado en la comprobación. El otro carro existe como STL.
carro_conjunto = "nano_esp";                    // "nano_esp" | "nano_proto"
proto_l = 70; proto_w = 30;                     // [DISEÑO] protoboard genérica 30×70, no es una placa medida
proto_pcb_z = 17.5;                             // mismo puesto que el ESP
// OBSOLETO (2026-10-22). La bahía de carros ya no va en la bandeja.
// Estas cotas se quedan para que los módulos de carro sigan compilando.
// No imprimir carros ni el retenedor. Los huecos vigentes son b3_*.
// Bahía v2: tornillo del carro en bay_x, placa hacia +X, USB hacia +X.
// Nano de prácticas en y = 90; ESP o proto 30×70 en y = 124.
bay_x = 328;
bay_est = [90, 124];
nano_est = 0;
esp_est = 1;
proto_est = 1;
// Sujeción del carro (2026-10-21). El puesto sigue centrado en bay_est.
// Dos M3 en diagonal, a 9 mm en Y y 1,6 mm en X, y un cajeado de 6,4 × 14 mm
// en el riel. La zapata entra con 0,15 mm por lado [DISEÑO]: no gira. Los dos
// tornillos impiden que se levante. ESP y proto comparten el puesto y = 124:
// se cambian soltando esos dos M3. Con fijacion = "autorroscante" cada
// puesto lleva dos guías Ø rosca_d. En esta plancha solo hay 6 mm de
// plástico (suelo 4 + ala 2): la guía se queda en 5,2 mm y deja 0,8 mm
// de piel, por debajo de rosca_prof. [PENDIENTE] de probar el agarre.
bay_caj_x = 6.4;
bay_caj_y = 14;
bay_holg = 0.15;
bay_torn = [[-0.8, -4.5], [0.8, 4.5]];

// ---------------------------------------------------------------------
// Huecos fijos de la bandeja (2026-10-22). Sustituyen a la bahía de carros
// y a la cuna del Nano de mandos. Cada placa en su bolsillo, a lo largo
// (dos columnas, no tres). La Pi no se mueve. Holgura 0,5 mm por lado.
// Origen de cada vector: esquina −X −Y de la PCB, luego ancho (X) y largo (Y).
// ---------------------------------------------------------------------
b3_holg = 0.5;          // [DISEÑO] aire entre la PCB y la pared
b3_pared = 2.2;         // [DISEÑO] pared del bolsillo
// Regleta macho de agujero pasante, pines hacia abajo. Miguel: bajo la PCB
// asoman el separador (~2,5 mm) y el pin (~6 mm; algunos llegan a 11,5 mm
// con el separador ya contado). Hasta medirlo, pin largo 11,5 + aire 1,5.
pin_bajo_pcb = 13;      // [PENDIENTE] libre desde la cara inferior de la PCB hasta la bandeja
pin_fila_w = 3.2;       // [DISEÑO] huella de cada fila, desde el canto largo. El dibujo usa 2,5 mm. No medido
pin_extremo = 2.5;      // [DISEÑO] tramo sin pin junto al canto corto. El dibujo empieza a 2,4 mm. No medido
b3_apoyo = 2.0;         // [DISEÑO] escalón del canto corto, solo en la banda central, menor que pin_extremo
b3_pin_z = pin_bajo_pcb;
b3_usb = 10;            // [DISEÑO] hueco del conector, centrado en el canto. El clon no se ha medido
b3_torn_lx = 1.5;       // [DISEÑO] eje del tornillo, fuera del canto largo (X)
b3_torn_ly = 3.0;       // [DISEÑO] eje del tornillo, fuera del canto corto (Y)
b3_boss = 7.6;          // [DISEÑO] poste. Pared (7,6 − 2,5) / 2 = 2,55 ≥ rosca_pared
b3_rosca = 10;          // [DISEÑO] guía en los postes que suben hasta la PCB
b3_rosca_baja = 8;      // [DISEÑO] guía de las bridas del buck (el poste es bajo)
b3_buck_rosca = 7;      // [DISEÑO] guía bajo el agujero del módulo. No atraviesa el ala

// Tabla de placas. lx en X, ly en Y.
b3_prac = [399, 66, 18, 45];     // Nano de prácticas. USB hacia −Y. [FUENTE] 18 × 45
b3_buck = [399, 124, 21, 43];    // step-down. lx = buck_w, ly = buck_l
b3_esp  = [346, 86, 31, 58];     // ESP8266. USB hacia +Y. 58 × 31 [PENDIENTE] [FOTO]
b3_man  = [400, 222, 18, 45];    // Nano de mandos. USB hacia +Y. [FUENTE] 18 × 45

// Pisada de la Pi. Fuera de la PCB, lejos de los postes M2.5 (Ø6 en
// (333,5, 171) y (382,5, 171)). Arandela ancha M3 (Ø9, DIN 9021).
b3_pi_torn = [[328.0, 165.2], [388.0, 165.2], [327.8, 254.2], [388.6, 254.2]];

// Convertidor step-down. Módulo típico con LM2596, 43 × 21 mm, agujeros
// de 3 mm en esquinas opuestas. No es el módulo de Miguel. [PENDIENTE]
buck_l = 43;
buck_w = 21;
buck_pcb = 1.6;         // [DISEÑO] PCB típico
buck_ag_d = 3.2;        // [PENDIENTE] paso del tornillo. El usuario cita agujeros de 3 mm
buck_ag_ins = 3.5;      // [PENDIENTE] centro del agujero a la esquina. Cifra típica, no medida
buck_suelda = 3;        // [DISEÑO] hueco bajo la PCB para las soldaduras
buck_h = 14;            // [PENDIENTE] alto del inductor, solo el marcador. No es una pared
// Tapa del techo, encima de los USB/RJ45. Solo en el lomo plano (y > 246,5),
// dentro de carcasa_x1_y1. No corta el panel de pines, la OLED ni la rejilla
// de la pared trasera (esa rejilla va en z = 114–140; la tapa abre el techo).
tapa_x0 = 324; tapa_x1 = 396;
tapa_y0 = 252; tapa_y1 = 294;
tapa_sol = 6;                                 // solape de la tapa sobre el techo [DISEÑO]
tapa_t = 2.4;
// Ventilación de la Pi (2026-10-21). El HAT tapa la cara de arriba: el aire
// entra por el suelo, recorre los 8 mm que hay bajo la PCB y sale por las
// ranuras de la tapa y por la rejilla de la pared trasera.
// SoC BCM2711, 15 × 15 mm. Esquina (ox, oy) = (21,75, 25); centro oy = 32,5
// y ox = 3,5 + 25,75 = 29,25.
// [FUENTE] plano mecánico de la Pi 4 y el modelo que lo cita:
//   https://datasheets.raspberrypi.com/rpi4/raspberry-pi-4-mechanical-drawing.pdf
//   https://github.com/process1183/openscad-library/blob/master/rpi/rpi_4b.scad
// En la bandeja (x = pi_x0 + 56 − oy, y = pi_y0 + ox): x = 346 a 361,
// y = 189,25 a 204,25. La RAM y el PMIC (MxL7704, 5 × 5) no salen en ese
// plano. La rejilla es una banda alrededor del SoC, hacia el USB-C y hacia
// los USB. [PENDIENTE] la cota del PMIC en la placa de Miguel.
// Ranuras de 2,0 mm a lo largo de Y, paso 3,6 (nervio 1,6). Ocho columnas.
// Quedan a más de 9 mm del eje de los postes M2.5 (Ø6) y la muesca de la
// micro-SD acaba en y = 171,5: las ranuras empiezan en y = 183.
pi_rej_x0 = 343;
pi_rej_paso = 3.6;
pi_rej_ancho = 2.0;
pi_rej_n = 8;
// Ventilador de 5 V opcional, atornillado a la tapa. No va en el modelo.
// Patrón habitual: 40 × 40 con agujeros a 32 mm, o 30 × 30 con agujeros a
// 24 mm. Paso Ø3,2 para un M3. [DISEÑO] El cuerpo de 10 mm no cabe en los
// 8 mm que hay bajo la PCB.
vent_paso_40 = 32;
vent_paso_30 = 24;
vent_ag_d = 3.2;
// Canaleta del mini-USB de mandos. Sube por +X (x = 420) y gira a −X delante
// de las clavijas de la Pi. El cable no sale de la bandeja. Ribete 1,6 mm,
// paso 8 mm, alto 5 mm. [DISEÑO]
canal_x0 = 420;
canal_paso = 8;
canal_rib = 1.6;
canal_y0 = 142;
canal_giro_x0 = 390;
canal_giro_y0 = 258;

// Panel de prácticas en la cara TRASERA [DISEÑO]. A la derecha de la costilla
// del corte X (x = 228) y por encima del bloque de conectores (z ≈ 24–52).
// No es la medida de un conector comprado. La bandeja impresa no cambia.
panel_x0 = 250;
panel_z0 = 68;
panel_w = 74;
panel_h = 72;                             // hasta z = 140; el filete superior es de 5 mm y H ≈ 154
// OLED 0,96" 128x64 I2C SSD1306. Referencia [FUENTE], módulo no elegido ni medido:
//   Waveshare 0.96inch OLED (B): PCB 33,0 x 33,5 mm, área visible 21,70 x 11,20,
//   SSD1306, 128x64, I2C/SPI, amarillo/azul. La ficha dice 3,3 V; la wiki dice
//   3,3 V/5 V. https://www.waveshare.com/0.96inch-oled-b.htm
//   https://www.waveshare.com/wiki/0.96inch_OLED_(B)
oled_mod = [33.5, 12, 33.0];              // x, profundidad hacia el interior, z. La profundidad es [DISEÑO]
oled_ventana = [24, 14];                  // [DISEÑO] hueco a partir del área visible de esa ficha
oled_cx = panel_x0 + 8 + oled_ventana[0]/2;
oled_cz = panel_z0 + panel_h - 22 + oled_ventana[1]/2;

$fn = 48;
