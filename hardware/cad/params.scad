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
// I/O separado. Orden a lo largo del borde (de DC a audio): jack DC, VGA, HDMI, 2x USB,
// RJ45 + USB, audio. En Orbit (vista superior, I/O hacia atrás) el audio queda a la izquierda
// (X baja) y el jack DC a la derecha. Posiciones exactas [PENDIENTE de medir].
// La ventana de Orbit es una abertura LIBRE del tamaño de la abertura estándar (no asume escudo).
// Para cerrar el hueco alrededor de los conectores hace falta una PLACA I/O IMPRESA a medida
// (pendiente de medir los conectores; no se modela aún). Ver docs/diseno-mecanico.md.
hp_io_h = 44.45;            // [FUENTE estándar ATX] abertura del escudo I/O 158,75 x 44,45 mm
hp_io_w = 158.75;
hp_io_prof = 25;            // [PENDIENTE] fondo de la pila de conectores traseros sobre la placa
hp_io_x0 = 5.6;             // [PENDIENTE de medir] posición de la abertura respecto al borde izq.
hp_io_baja = 2.24;          // [PENDIENTE] la abertura empieza ~2,2 mm bajo la cara superior de la PCB
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
usar_adaptador_video = true;   // [DISEÑO] reserva el hueco del adaptador HDMI->USB-C

// Capturadora HDMI->USB (UVC) para el modo C (RECOMENDADO): HDMI del HP -> capturadora -> USB
// de la Pi. Referencia vista en Amazon.es el 2026-10-18 (marca SUOFEIXIANG, "4K30 entrada /
// 1080p", 14,69 €, sin URL): tipo "pincho" con cable corto USB-A/USB-C. Medidas NO publicadas.
// Es una RESERVA DE ESPACIO [DISEÑO], no la medida del aparato: cuerpo + clavija HDMI recta.
// Va en la bandeja de servicio, por delante del hueco del adaptador (se fija con velcro o brida).
usar_capturadora = true;       // [DISEÑO]
captura = [72, 30, 20];        // [DISEÑO reserva; PENDIENTE de medir el aparato real]
cap_x = pi_x;
cap_y = adap_y - 12 - captura[1];
cap_z = suelo + 2;

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
serv_x = (usar_distribucion ? min(psu_x, pi_x) : pi_x) - 6;
serv_y = (usar_distribucion ? min(psu_y, sop_ard_y0) : sop_ard_y0) - 6;   // v1: la bandeja incluye el soporte del Arduino
serv_w = (W - pared - 21) - serv_x;     // v1: deja libres las orejetas del lateral derecho
serv_d = (pi_y + pi_d + 4) - serv_y;
serv_ala = 8;        // [DISEÑO] ala de atornillado alrededor
serv_ala_t = 2;      // [DISEÑO] espesor del ala (queda dentro de la altura de los pies)

$fn = 48;
