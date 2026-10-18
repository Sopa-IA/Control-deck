# ORBIT TERMINAL · Diseño mecánico v1 + HP v2 (Fase 3 preliminar)

> **⚠️ NO APTO PARA FABRICACIÓN.** Volumen de diseño industrial paramétrico para validar proporciones, distribución interna y la estrategia de impresión. Hay varias cotas **PENDIENTES** (medidas de la placa del HP tras desmontarla, posición de puertos y teclas del MSI, potenciómetros, pulsadores, insertos), no se ha impreso ni montado ninguna pieza y las comprobaciones son **simulaciones geométricas sobre cajas envolventes**, no pruebas físicas. Los STL llevan el prefijo `PROVISIONAL_`.

Fecha: 2026-10-18 (UTC+1). Fuentes comprobadas el 2026-10-18 salvo que se indique otra cosa.

## 0b. HP v2: HP Slimline 260-a110ns desmontado (2026-10-18)

El HP de Miguel es un **HP Slimline 260-a110ns** (torre estrecha de ~307 × 100 × 275 mm según tiendas): **la caja no cabe en la cuña**, así que, por decisión de Miguel, **se desmonta** y en Orbit va un **módulo de placa desnuda**. Datos y fuentes: `datos-pendientes-hp.md` (datos del propietario 2026-10-18 + fichas HP de las placas hermanas Iris-E2/Iris-A8, **Mini ITX 17 × 17 cm**, entrada DC en el I/O trasero). Nota de seguridad del desmontaje: `datos-pendientes-hp.md` §B.

| Elemento | Modelado en CAD (`hp_preset = "iris_mitx_desnuda"`, por defecto) | Estado |
|---|---|---|
| Placa mini-ITX 170 × 170 | En horizontal, atrás a la izquierda (`hp_x` = 17 mm, borde trasero a 3 mm de la pared), componentes hacia arriba | Formato: fuente HP (hermanas) |
| Separadores | 4 torretas impresas en la base, Ø9, **6,35 mm** (estándar ATX), con inserto M3, en el **patrón estándar mini-ITX** (157,48 × 154,94 mm; agujero C a 6,35 mm del lateral y 10,16 mm del borde I/O) | **PENDIENTE de medir tras desmontar** (H-2) |
| Altura de componentes | Caja de 38 mm sobre la PCB (DIMM DDR3 en vertical + disipador). El modelo admite **hasta 41 mm con 3 mm de holgura** a la tina de la pantalla (43 mm con 1 mm; 45 mm interfiere) | **PENDIENTE** (H-3) |
| Ventana I/O trasera | Abertura estándar de escudo I/O **158,75 × 44,45 mm** (+1 mm de holgura) a ras de la placa; sustituye la ventana genérica de v1. El jack DC del adaptador de 19,5 V entra por aquí | Posición y si HP usa escudo: **PENDIENTE** (H-4) |
| Flujo de aire | **Entrada:** ranuras de la base bajo la placa y ranuras bajas del lateral izquierdo (zona trasera, hasta z ≈ 60 mm). **Salida:** rejilla superior trasera sobre la placa (el aire caliente sube). Se conserva el disipador/ventilador original | Sentido real del ventilador: **PENDIENTE** (H-5); térmica: U-20 |
| Disco | **SSD 2,5"** (100,45 × 69,85 × 9,5, SFF-8201) en un **soporte impreso** nuevo (`PROVISIONAL_soporte_disco`), a la derecha de la placa, sobre 4 torretas; la plancha queda 3 mm por encima de las torretas de empalme. **Opción HDD 3,5"** (`usar_hdd_35 = true`, 101,6 × 147 × 26,1, SFF-8301) en el mismo sitio, también sin interferencias | Agujeros de los discos: **PENDIENTE** (colisos en el soporte) |
| DVD | **Retirado**; no se modela | — |
| Fuente | **No hay fuente dentro**: adaptador externo 65 W 19,5 V al jack DC de la placa (`usar_distribucion = false`: desaparece la caja de distribución DC de v1) | Datos del propietario + HP |
| I/O frontal del HP | Ventana de 62 × 18 mm en el **lateral izquierdo** (zona trasera alta, detrás de la tina) para la placa original de USB 2.0 / audio / lector SD; marcador de 16 × 70 × 26 mm | **PENDIENTE** (H-7) |
| Encendido del HP | **Pulsador de panel Ø12** + **LED de 3 mm** en el lateral izquierdo, cableados en paralelo al cabezal del botón original (contacto seco) | Patillaje: **PENDIENTE con polímetro** (H-6) |
| Vídeo / cables | **Pasacables trasero ampliado a 40 × 16 mm** (HDMI del HP → Mini-HDMI de la MSI y cargador USB-C PD de la MSI). **Hueco reservado de 72 × 32 × 16 mm** en la bandeja, delante de la Pi, para el **adaptador HDMI→USB-C** del modo B | Ver `conmutacion-video-usb.md` §V |
| Empalmes de la base (corte Y) | Se desplazan a la derecha de la placa (x = 201 y 258 mm) para no quedar bajo la PCB; la propia placa, atornillada a los dos trozos de base, refuerza la junta | — |

**Resultado del encaje:** la placa desnuda **cabe sin cambiar la envolvente: 456,3 × 300,5 × 153,9 mm** (157,9 mm con pies). Sin interferencias en la configuración por defecto ni con `usar_hdd_35`, `disposicion_mandos="fila"` (484,3 mm de ancho) o `pot_tipo="16mm"`. **No validado:** `usar_kvm = true` (la bahía del KVM choca con el soporte del disco y el corte X cae sobre la zona I/O; el KVM ya no está en el plan) y `usar_distribucion = true` (choca con el disco y con el hueco del adaptador; ya no hace falta).

Renders regenerados (HP v2): `assets/renders/01_msi_frontal_3-4.png`, `02_msi_lateral.png` (lateral izquierdo: ventana I/O frontal, pulsador y LED del HP), `03_msi_trasera_3-4.png` (ventana I/O mini-ITX y pasacables), `04_msi_explosionado.png`, `05_msi_interior.png` (placa, SSD, hueco del adaptador).


## 0. Cambios de v1 respecto a v0 (acordados con Miguel)

| Tema | v0 | v1 |
|---|---|---|
| Impresora | Cama genérica 256³ | **Bambu Lab A1**: 256 × 256 × 256 mm, marco abierto ([especificaciones](https://bambulab.com/en/a1/tech-specs)). Bambu clasifica PLA/PETG/TPU como "ideal" y ABS/ASA como "no recomendado" en la A1 → **material por defecto: PETG** (`impresora`, `material` en `params.scad`) |
| KVM | Bahía de 140 × 90 × 30 | **Sin KVM** (`usar_kvm = false`; con `true` vuelve la bahía y la carcasa crece a 510 mm de ancho). El cambio HP/Pi se hace en el **OSD del MSI** |
| Mandos | 2 encoders PEC11R lado a lado + 2 tapas impresas | **2 potenciómetros rotativos genéricos** (16 o 24 mm, eje de 6 mm, `pot_tipo`) en **columna** + **2 pulsadores de panel genéricos** (12 o 16 mm, `boton_tipo`) en fila. Todo **PENDIENTE de medir**. Se elimina la tapa de botón impresa (los pulsadores de panel traen actuador) |
| Electrónica de mandos | Encoders a GPIO de la Pi | **Arduino Micro** (48 × 18 mm, [tienda oficial](https://store.arduino.cc/products/arduino-micro)) en un **soporte impreso** bajo la consola, sobre la bandeja de servicio, con **canal para el cable micro-USB** hasta la Pi |
| Puertos del MSI | Ranuras genéricas a ambos lados (20–80 %) | El manual y PCMag sitúan **Type-C2, Type-C1, Mini-HDMI, encendido y tecla arriba/abajo en el canto DERECHO**. v1 abre la tina y la repisa en el tramo de puertos (clavijas rectas o en L hacia el interior) y añade una **ventana para pulsar las teclas OSD**. Posiciones a lo largo del canto: **PENDIENTE de medir** |
| Cables HP | — | **Pasacables trasero** (34 × 14 mm) sobre la ventana I/O del HP: el cable de vídeo del HP sale por la ventana I/O y vuelve a entrar hacia el USB-C del MSI; por ahí entra también la fuente USB-C PD del monitor |
| Huella | 484,3 × 306,5 × 153,9 mm | **456,3 × 300,5 × 153,9 mm** (−28 mm de ancho, −6 mm de fondo; altura igual) |

---

## 1. Intención de diseño frente a las imágenes de referencia

| Rasgo de la referencia | Cómo se resuelve en v1 |
|---|---|
| Cuña negra mate, delgada delante y gruesa detrás | Perfil lateral extruido: frente de 22 mm, pendiente de 30°, lomo plano trasero; aristas redondeadas (r = 5 mm) en el perfil y chaflán de 3 mm en los laterales |
| Pantalla a la izquierda, fija e inclinada, sin bisagras | Cuna para el monitor **MSI PRO MP161 E2U** entero dentro de la pendiente, con un bisel atornillado por encima |
| Consola triangular a la derecha con 2 pomos y anillos ámbar | Consola de **64 mm** en la misma pendiente, separada de la pantalla por una ranura en V; 2 pomos Ø30 **en columna** (separados 58 mm a lo largo de la pendiente) sobre potenciómetros genéricos, con guía de luz anular translúcida opcional (`anillos_luz`). La disposición "fila" de v0 sigue disponible (`disposicion_mandos = "fila"`, consola de 92 mm, ancho 484,3 mm) |
| Botones de encendido y de cambio de sistema bajo los pomos | 2 pulsadores de panel genéricos (por defecto 16 mm, hueco Ø16,2) en fila, separados 28 mm (modelo **PENDIENTE**) |
| Tira de luz ámbar en la base | Ranura pasante de 5 mm en el frente inferior, con guía translúcida en 2 tramos y carril para tira LED (tira existente de tipo **PENDIENTE**) |
| Puertos traseros (audio, 2×USB-A, 2×USB-C, 2×HDMI, RJ45, DC) | Bloque compacto de 77 mm para prolongadores de montaje en panel (modelos **PENDIENTES**), ventana I/O directa al HP y pasacables trasero |
| Rejillas laterales | Ranuras horizontales en ambos laterales que siguen la pendiente, más una rejilla superior en la trasera |

Diferencias conscientes con la referencia: (1) en v1 los pomos van en columna para estrechar la consola; (2) la imagen 1 tiene la pantalla más vertical (a ojo, unos 60°). La inclinación es de **30°**, porque con una pantalla de 15,6" a más ángulo la carcasa crece mucho en altura. Es el parámetro `inclinacion` de `params.scad` y se puede subir; la cuña se recalcula sola, pero hay que volver a pasar la comprobación de interferencias.

Renders (vista previa OpenCSG de OpenSCAD, ilustrativos y no fotorrealistas; la interfaz de la pantalla es un dibujo de ejemplo):

| Vista | Archivo |
|---|---|
| 3/4 frontal (principal) | `assets/renders/01_msi_frontal_3-4.png` |
| 3/4 frontal derecha | `assets/renders/01b_msi_frontal_der_3-4.png` |
| Lateral, ortográfica | `assets/renders/02_msi_lateral.png` |
| 3/4 trasera (ventana I/O, pasacables, panel de conectores) | `assets/renders/03_msi_trasera_3-4.png` |
| Explosionada | `assets/renders/04_msi_explosionado.png` |
| Interior, sin carcasa (HP, Pi, distribución, Arduino, canal USB, cables ilustrativos) | `assets/renders/05_msi_interior.png` |
| Interior con carcasa translúcida y mandos | `assets/renders/05b_msi_interior_mandos.png` |
| Detalle de la consola y ventana OSD | `assets/renders/07_msi_detalle_consola.png` |

La comparativa con la Waveshare 12,3" (`06_w123_…`) se retiró en v1: ese preset ya no se mantiene (su pendiente corta no admite la consola en columna; ver §5).

Los renders se regeneran con `hardware/cad/render.sh`.

---

## 2. Pantalla del prototipo: MSI PRO MP161 E2U

### 2.1 Datos oficiales

| Dato | Valor | Fuente |
|---|---|---|
| Panel | 15,6" IPS, 1920×1080, 60 Hz, 250 nits, contraste 800:1 | Página de especificaciones de MSI: https://www.msi.com/Portable-Monitor/PRO-MP161-E2U/Specification |
| Área activa | 344,16 × 193,59 mm (paso de píxel de 0,17925 mm) | Ídem |
| Dimensiones (ancho × fondo × alto) | **362,26 × 18,8 × 233,84 mm**. Es el monitor completo, con su soporte plegable integrado; MSI no publica otra medida sin soporte, porque el soporte forma parte de la trasera | Ídem |
| Dimensiones según el manual | 362,26 × 232,92 × 18,8 mm. No coincide con la web; en el diseño se usa la mayor, **233,84** | Manual oficial: https://download-2.msi.com/archive/mnu_exe/monitor/PRO-MP161-E2-English.pdf |
| Peso | 0,75 kg (neto) | Página de especificaciones |
| VESA | **No figura** en la página de especificaciones; solo una rosca de trípode de 1/4" | Ídem |
| Táctil | **No figura**. El E2U no es táctil; la variante táctil es otro modelo, PRO MP161E6T | Ídem |
| Conectores | 1× Mini-HDMI 2.0b; 2× USB-C (DP 1.2a Alt Mode, con entrada de alimentación por PD) | Ídem |
| Altavoces | 2 × 1,5 W | Ídem |
| Alimentación | Entrada de 5–20 V y 3 A; perfiles PD de 5/9/12/15 V a 3 A; según el manual, la fuente debe dar **más de 15 W** | Manual oficial |
| Lado de conectores y teclas | **Canto derecho**: ① encendido, ② tecla arriba/abajo, ③ Type-C2, ④ Type-C1, ⑤ Mini-HDMI | Manual oficial ("Overview of the monitor") y reseña de PCMag: https://www.pcmag.com/reviews/msi-pro-mp161-e2 |
| Cables incluidos | Mini-HDMI→HDMI y USB-C→USB-C, ambos con clavija en L | Página de especificaciones del MP161 E2 |
| Posición exacta a lo largo del canto | **PENDIENTE**. En el modelo: teclas OSD entre el 66 % y el 92 % de la altura, puertos entre el 14 % y el 60 % (`osd_v0/1`, `puertos_v0/1` en `lib.scad`) | Medir el monitor de Miguel |
| Posición del área activa dentro del marco | **PENDIENTE**. Se supone centrada (`act_off_x/y = 0`) | — |

### 2.2 Decisión: el monitor va entero en una cuna, sin desmontarlo

Se aloja el monitor completo, sin sacar el panel de su carcasa, por estas razones:

1. **Garantía y riesgo:** abrir un monitor portátil de carcasa pegada o con clips puede anular la garantía, y el panel LCD desnudo es frágil (cristal de unos 2–3 mm con la placa de control pegada).
2. **El soporte no estorba:** el soporte plegable va integrado en la trasera y, plegado, el monitor sigue midiendo los 18,8 mm oficiales. Por eso la cuna es un bolsillo de 364,26 × 235,84 × 19,3 mm (1 mm de holgura por lado y 0,5 mm de fondo).
3. **Conectores en el canto derecho (v1):** en el tramo de puertos se abren la pared de la tina y la repisa hasta 28 mm hacia la consola, conservando la piel exterior de 3 mm, para que las clavijas (las L de serie o rectas) bajen al interior. **Mini-HDMI → Pi** (recorrido por encima de la distribución DC hasta el frente de la Pi) y **USB-C → HP / fuente PD** (hacia el pasacables trasero). Los cables dibujados en los renders son **ilustrativos**, no un recorrido validado.
3b. **Teclas OSD accesibles (v1):** ventana de 13 mm × ~61 mm en la piel y el bisel junto al canto derecho, para pulsar con el dedo el encendido y la tecla arriba/abajo (cambio de entrada HP ↔ Pi). Ergonomía **PENDIENTE de probar**.
4. **Reversible:** Miguel puede recuperar su monitor quitando el bisel (12 tornillos M3).

Cómo queda sujeto: el monitor apoya en una repisa perimetral de 10 mm de ancho, y la repisa tiene una gran abertura central para cables, aire y menos peso. Por arriba lo sujeta el bisel, que tapa el marco plástico del monitor y deja una ventana igual al área activa más 1 mm por lado, con chaflán a 45°. Hay que añadir burlete o EVA de 1 mm entre bisel y monitor (**PENDIENTE**, no modelado).

### 2.3 Táctil: el MSI no es táctil

El MP161 E2U **no es táctil**. Para el prototipo hay dos caminos:

**A) Sin táctil (decidido para el prototipo):** ratón USB + los dos potenciómetros y dos botones de la consola (leídos por el Arduino Micro).

**B) Overlay táctil USB de 15,6" puesto delante del monitor.** Opciones reales encontradas:

| Overlay | Tecnología | Medidas | Interfaz | Precio | Fuente |
|---|---|---|---|---|---|
| **Obeytouch OB156AP-3K1-T99** (16:9) | IR, 2/4/6/10 puntos según opción | Exterior **382 × 235 mm**, **grosor 7,9 mm**, marco de 18,5 mm, área activa 345 × 198 mm, vidrio templado de 3 mm (352 × 205 mm) | USB 2.0, 5 V a 100 mA; Windows, Linux y Android | **61,00 USD** (precio en la web del fabricante) | https://www.obtouch.com/product/15-6-inch-ir-touch-screen-overlay-with-2-4-6-touchpoints/ |
| **GreenTouch GT-TM156** | IR de 10 puntos, vidrio templado de 3 mm | Medidas **pendientes de verificar** | USB HID sin driver (Windows, Linux, Android) | **112,88 USD** (Amazon US, según el buscador; la página no se pudo abrir) | https://www.amazon.com/GreenTouch-Infrared-Overlay-Thickness-Tempered/dp/B08SJXHXGL |

El modelo ya lo contempla: con `usar_overlay_ir = true` el bolsillo crece hasta el contorno del Obeytouch (382 × 235 mm) y gana 7,9 mm de profundidad, y la carcasa se ensancha sola. **No se ha comprobado** si el área activa del overlay (345 × 198) queda bien alineada con la del monitor (344,16 × 193,59), ni si un overlay IR funciona bien con el bisel justo encima: los marcos IR necesitan que nada tape sus emisores, así que el bisel tendría que montarse por fuera del marco del overlay. Esto queda pendiente para la siguiente iteración.

---

## 3. Dimensiones generales y lista de piezas

### 3.1 Envolvente (salida de `comprobar_interferencias.py`)

| Configuración | Ancho × Fondo × Alto (sin pies) | Con pies | Resultado |
|---|---|---|---|
| **HP v2 por defecto** (placa HP desnuda, SSD 2,5", MSI, sin KVM, mandos en columna, pot 24 mm, botón 16 mm) | **456,3 × 300,5 × 153,9 mm** | Alto 157,9 mm | Sin interferencias |
| HP v2 con `usar_hdd_35=true` | 456,3 × 300,5 × 153,9 | | Sin interferencias |
| HP v2 con `usar_kvm=true` / `usar_distribucion=true` | 503,0 / 456,3 de ancho | | **Interferencias** (no validado; fuera del plan) |
| v1 con `disposicion_mandos="fila"` | 484,3 × 300,5 × 153,9 | | Sin interferencias |
| v1 con `usar_kvm=true` | 510,0 × 300,5 × 153,9 | | Sin interferencias |
| v1 con `pot_tipo="16mm"` / `boton_tipo="12mm"` | 456,3 × 300,5 × 153,9 | | Sin interferencias |
| v0 (referencia) | 484,3 × 306,5 × 153,9 | | — |

Qué fija cada cota en v1:

- **Ancho:** ahora lo fija la pantalla más la consola (14 + 364,26 + 14 + 64). Sin KVM, el hardware (HP + columna Pi/distribución) cabe bajo la pantalla.
- **Fondo:** lo fija la holgura entre el HP y la tina de la pantalla. `lomo_base` baja de 60 a 54 mm, el mínimo que mantiene ≥ 3 mm. Con 48 mm el margen es de 0 mm.
- **Altura:** no cambia; depende de la pantalla y de la inclinación de 30°.

### 3.2 Piezas imprimibles (Bambu Lab A1: 256 × 256 × 256 mm, margen de 10 mm, PETG)

| Pieza (STL en `hardware/cad/export/stl/`) | Cant. | Caja envolvente (mm) | Material sugerido |
|---|---|---|---|
| `PROVISIONAL_carcasa_x{0,1}_y{0,1}` | 4 trozos | ≤ 228,1 × 150,2 × 150,9 | PETG negro mate |
| `PROVISIONAL_base_x{0,1}_y{0,1}` | 4 trozos | ≤ 228,1 × 150,1 × 18 | PETG negro |
| `PROVISIONAL_bisel_x{0,1}_y{0,1}` (impreso plano, cara vista abajo) | 4 trozos | 190,8 × 126,6 × 3,6 | PETG negro |
| `PROVISIONAL_bandeja_servicio` (Pi, distribución, soporte del Arduino y canal USB) | 1 | 157 × 237,5 × 14 | PETG |
| `PROVISIONAL_soporte_arduino` (**nuevo**) | 1 | 25,7 × 70 × 19,1 | PETG |
| `PROVISIONAL_guia_luz_frontal_{0,1}` | 2 tramos | 201,1 × 9 × 7 | PETG translúcido natural |
| `PROVISIONAL_anillo_luz_x2` | imprimir 2 | 41 × 41 × 5,6 | PETG translúcido natural |
| `PROVISIONAL_pomo_x2` | imprimir 2 | Ø30 × 17 | PETG o PLA negro (o pomo comercial) |
| `PROVISIONAL_pletina_empalme_x4` | imprimir 4 | 30 × 10 × 3 | PETG |

`PROVISIONAL_tapa_boton_x2` **se elimina**: los pulsadores de panel traen su propio actuador.

Volumen de material sólido (cada archivo una vez): unos **1423 cm³** (v0: 1496). El consumo real de filamento depende del relleno y no está calculado.

**Notas de impresión para la A1 (marco abierto):**

- PETG sobre la placa PEI texturizada incluida.
- La A1 no debe cerrarse en un armario según el FAQ de Bambu Lab, así que se evitan ASA y ABS en las piezas grandes.
- Las 4 carcasas son las piezas más altas (150,9 mm). Conviene orientarlas con la cara de corte sobre la cama y probar antes una esquina.

Componentes comprados o reutilizados (marcadores, no se imprimen):

- MSI PRO MP161 E2U.
- HP (modelo desconocido).
- Raspberry Pi.
- Distribución DC.
- **Arduino Micro**.
- **2 potenciómetros de eje de 6 mm**.
- **2 pulsadores de panel**.
- Tira LED (tipo **PENDIENTE**).
- Tornillería:
  - Insertos térmicos M3 y tornillos M3: unos 12 para el bisel, unos 13 orejetas carcasa-base, 4 para la bandeja, 8 para las pletinas, 2 para el soporte del Arduino y 4 para la distribución.
  - 1 prisionero M3 por pomo.
  - Pasadores de acero Ø3 × 16.
  - 1 brida de 3,6 mm.
- 4 pies de goma Ø12.
- Cables:
  - Mini-HDMI (de serie, en L).
  - USB-C (de serie, en L).
  - Micro-USB → USB-A corto.

### 3.3 Uniones y montaje

1. **Carcasa en 4 trozos.** Los planos de corte se calculan solos según la cama (`nx_cortes`, `ny_cortes`). Junto a cada corte hay una costilla interior de 8 mm pegada a la pared, con agujeros Ø3,2 para **pasadores de alineación de Ø3 × 16 mm**. Los trozos se pegan (adhesivo para PETG o ABS/ASA) y quedan alineados por los pasadores.
2. **Base en 4 trozos**, unida por dentro con 4 pletinas atornilladas a torretas con inserto M3. La base se atornilla desde abajo, con tornillos avellanados, a orejetas con inserto M3 de la carcasa. Las orejetas frontales son columnas hasta el techo, detrás del carril LED.
3. **Bisel en 4 trozos**, cada uno con 3 tornillos M3 avellanados propios a insertos de la carcasa. No necesita uniones entre trozos.
4. **Bandeja de servicio:** la Pi (separadores M2.5 con el patrón de 58 × 49 mm), la distribución DC y, en v1, el **soporte del Arduino Micro** y el **canal del cable micro-USB** van montados en la bandeja, que se quita desde abajo con 4 tornillos M3 sin abrir la carcasa (la comprobación verifica que el soporte pasa por la abertura). Hay que dejar holgura en los cables dupont entre el Arduino y los mandos, o usar un conector, para poder bajar la bandeja.
5. **Potenciómetros:** atornillados con su tuerca desde fuera. Panel de 3 mm + refuerzo automático (`refuerzo_pot`, 1,5 mm con el genérico de 24 mm y 0 mm con el de 16 mm) para dejar ≥ 4,5 mm de rosca libre. Hueco anti-giro ciego a `pot_antigiro_r` (**PENDIENTE**). Los pomos llevan agujero de 6 mm, plano en D opcional (`pomo_eje_D`) y **prisionero M3 radial**, así que valen para eje liso o en D. Con eje estriado conviene un pomo comercial.
6. **Pulsadores de panel:** se fijan con su tuerca en la pared de 3 mm.
7. **Arduino Micro:**
   - La PCB apoya por sus extremos en dos bloques con labios de centrado y se sujeta con una brida.
   - Los pines quedan colgando en el hueco central (16 mm) para conectores dupont hembra.
   - El micro-USB mira hacia atrás; el canal de 10 mm lleva el cable hasta el frente de la Pi y de ahí al USB-A (40 mm libres delante de sus USB).
   - La PCB no tiene agujeros de montaje en los datos oficiales consultados. El margen sin pines en los extremos (~2,4 mm) está **PENDIENTE de confirmar** con la placa real.

---

## 4. Cotas: con fuente y PENDIENTES

| Elemento | Valor en el modelo | Estado | Fuente o nota |
|---|---|---|---|
| MSI MP161 E2U, contorno | 362,26 × 233,84 × 18,8 | **Con fuente** | Página de especificaciones de MSI (§2.1) |
| MSI, área activa | 344,16 × 193,59 | **Con fuente** | Ídem |
| MSI, lado de conectores y teclas | Canto derecho | **Con fuente** | Manual oficial + PCMag (§2.1) |
| MSI, desplazamiento del área activa y posición de conectores y teclas a lo largo del canto | Centrada; puertos 14–60 %, OSD 66–92 % | **PENDIENTE** | Medir el monitor |
| Waveshare 12,3" | 301,2 × 123,35 × 12,4; activa 293,10 × 110,20 | **Con fuente** | https://www.waveshare.com/wiki/12.3inch_1920x720_LCD (ver `pantallas.md`) |
| Waveshare 11,6" (H) | 279,50 × 177,09 × 21,20; activa 256,32 × 144,18 | **Con fuente** | Plano de Waveshare (ver `pantallas.md`) |
| Overlay Obeytouch | 382 × 235 × 7,9 | **Con fuente** | Web de Obeytouch (§2.3) |
| HP, preset `desktop_mini_ref` (histórico v1, ya no es el defecto) | 177,04 × 174,75 × 34,29 (ancho × fondo × alto) | **Con fuente, pero solo como REFERENCIA**: son las medidas del chasis del HP EliteDesk 800 G3 Desktop Mini, **no** del equipo de Miguel | Hoja de especificaciones de HP (doc. c05371240). La URL original de support.hp.com ahora da 404; se consultó una copia del mismo documento en https://server-shop.ua/assets/images/resources/18163/hp-elitedesk-800-g3-desktop-mini-business-pc-35-w-65-w-specifications-hp-customer-support.pdf |
| HP real (HP Slimline 260-a110ns), placa mini-ITX desnuda | 170 × 170; separadores 6,35; patrón 157,48 × 154,94 | Formato: **con fuente** (HP, placas hermanas, Mini ITX 17 × 17 cm); patrón y separadores: estándar ATX/mini-ITX, **PENDIENTE de medir tras desmontar** | `datos-pendientes-hp.md` §A |
| Altura de componentes de la placa HP | 38 (supuesto; máx. 41 con 3 mm de holgura) | **PENDIENTE** | H-3 |
| SSD 2,5" / HDD 3,5" (opción) | 100,45 × 69,85 × 9,5 / 101,6 × 147 × 26,1 | **Con fuente** (SFF-8201 / SFF-8301, formatos estándar) | `usar_hdd_35` |
| I/O frontal HP, pulsador Ø12 + LED 3 mm | Marcador 16 × 70 × 26; ventana 62 × 18 | **PENDIENTE** | H-6, H-7 |
| Adaptador HDMI→USB-C (hueco) | 72 × 32 × 16 | **PENDIENTE** (modelo sin verificar) | `adap_video` |
| HP, ventana I/O trasera | 159,75 × 45,45 (abertura de escudo I/O 158,75 × 44,45 + 1 mm) | **Con fuente** (estándar ATX); posición en la placa HP **PENDIENTE** (H-4) | `hp_io_*` |
| Raspberry Pi | Placa 85 × 56; agujeros 58 × 49 a 3,5 mm del borde, Ø2,7 | **Con fuente** | https://datasheets.raspberrypi.com/rpi4/raspberry-pi-4-mechanical-drawing.pdf |
| Raspberry Pi, altura con conectores | 20 | **PENDIENTE** | Según el modelo que tenga Miguel |
| KVM (opcional, desactivado) | 140 × 90 × 30 | **PENDIENTE** | Solo con `usar_kvm = true`. El fabricante no publica medidas (ver `conmutacion-video-usb.md`) |
| Arduino Micro | PCB 48 × 17,7 × 1,6; micro-USB sobresale del largo | **Con fuente** (largo y ancho) | https://store.arduino.cc/products/arduino-micro ("Length 48 mm, Width 18 mm"; "4.8cm and 1.77cm… with the USB connector extending beyond") |
| Arduino Micro, alturas (componentes 4, pines 8,5) y clavija micro-USB (22) | | **PENDIENTE** | Medir la placa y el cable de Miguel |
| Distribución DC (desactivada en HP v2) | 110 × 60 × 30 | Ya no hace falta (`usar_distribucion = false`) | `alimentacion-preliminar.md` §0 |
| Potenciómetro genérico 24 mm (por defecto) | Casquillo 3/8"/M9 (hueco 9,9; 9 mm de largo), cuerpo Ø25 × 22 con terminales, anti-giro a r = 10,2 | **PENDIENTE de medir**: valores típicos de catálogo, no de una pieza concreta | `datos_pot("24mm")` |
| Potenciómetro genérico 16 mm | Casquillo M7 (hueco 7,4; 7 mm), cuerpo Ø17 × 18, anti-giro a r = 7,8 | **PENDIENTE de medir** | `datos_pot("16mm")` |
| Eje del potenciómetro | Ø6 mm | Acordado, **PENDIENTE de medir** (liso, en D o estriado) | — |
| Pulsador de panel genérico 16 mm (por defecto) / 12 mm | Hueco 16,2 / 12,2; brida Ø19 / Ø15; 25 / 20 mm tras el panel; tuerca Ø21 / Ø16 | **PENDIENTE** | `datos_boton()` |
| Insertos M3 | Agujero Ø4,0 × 5,7 | **PENDIENTE** | Según el fabricante del inserto |
| Tira LED | 10,4 mm de ancho | **PENDIENTE** | Tira existente de Miguel, tipo desconocido |
| Huecos de los prolongadores de panel (USB, HDMI, RJ45, DC, audio) | Orientativos | **PENDIENTE** | Ajustar a los prolongadores comprados |
| Bambu Lab A1 | Volumen 256 × 256 × 256; PETG ideal, ASA/ABS no recomendado | **Con fuente** | https://bambulab.com/en/a1/tech-specs y https://wiki.bambulab.com/en/a1/manual/faq |
| Paredes, suelo, inclinación, marcos, radios | 3 / 4 / 30° / 14 / 5 | Decisión de diseño | Modificables en `params.scad` |

---

## 5. Comprobaciones de interferencias (simulación)

**Tipo de comprobación:** programática, por muestreo de puntos (9³ por caja) sobre las **cajas envolventes (AABB) de los marcadores**. No son modelos reales de los componentes, así que cables, radiadores y flujo de aire **no** están evaluados.

`hardware/cad/comprobar_interferencias.py` lanza OpenSCAD en modo `vista="check"` y comprueba:

1. **Componentes dentro del volumen interior libre** (HP, Pi, distribución, Arduino + soporte, clavija micro-USB y clavija USB-A en la Pi), respetando:
   - paredes y techo inclinado;
   - tina y torretas del bisel;
   - costillas de unión;
   - orejetas;
   - carril LED;
   - canal USB.
2. **Solapes por pares** entre todas las cajas, incluidos potenciómetros y pulsadores transformados desde la pendiente.
3. **(v1) Cuerpos de mandos** dentro de las paredes laterales y por encima del suelo.
4. **(v1) Bandeja de servicio:**
   - con su ala no pisa ninguna orejeta (en v0 sí ocurría con 2 orejetas, sin detectarse);
   - el soporte del Arduino pasa por su abertura.
5. **(v1) Panel de conectores traseros:** no corta la costilla del corte X ni invade la Pi.

Resultados del 2026-10-18 (configuración por defecto):

| Elemento | Resultado | Holgura mínima (mayor margen probado sin colisión) |
|---|---|---|
| Placa HP + RAM/disipador (38 mm sobre la PCB) | OK | ≥ 3 mm (limita una orejeta; tina: margen ≥ 3 mm hasta 41 mm de componentes) |
| Placa HP, zona I/O trasera | OK | ≥ 1 mm a la pared trasera (intencionado: los conectores asoman por la ventana) |
| SSD 2,5" + soporte | OK | ≥ 5 mm (limita una torreta de empalme) |
| I/O frontal HP / pulsador HP (lateral izq.) | OK | 0 mm a la pared (van montados en ella) |
| Adaptador HDMI→USB-C (hueco) | OK | ≥ 10 mm |
| Raspberry Pi | OK | ≥ 3 mm (limita el canal USB) |
| Arduino Micro + soporte | OK | ≥ 10 mm |
| Clavija micro-USB | OK | ≥ 10 mm |
| Clavija USB-A en la Pi | OK | ≥ 5 mm (limita la pared) |
| Potenciómetros (×2) | OK | 16,5 mm a la pared lateral; 57–86 mm sobre el suelo |
| Pulsadores (×2) | OK | ≥ 4,5 mm a la pared lateral; 36 mm sobre el suelo |
| Bandeja + ala frente a orejetas | OK | 0 solapes |
| Soporte del Arduino frente a la abertura de la bandeja | OK | — |
| Panel de conectores (x = 241–318 mm) | OK | Pi a partir de x = 328 |
| Solapes por pares (10 cajas) | Ninguno | — |
| **Resultado** | **Sin interferencias** (en cajas envolventes) | |

Variantes probadas sin interferencias:

- `usar_kvm=true`
- `disposicion_mandos="fila"`
- `pot_tipo="16mm"`
- `boton_tipo="12mm"`

**Preset `waveshare_12_3`: interfiere en v1.** Su pendiente es corta (≈ 153 mm), así que los mandos chocan entre sí y con el soporte del Arduino. Ese preset queda **sin mantener** (comparativa histórica de v0).

**Comprobación de piezas frente a la cama** (`comprobar_stl.py`, 2026-10-18):

- Las **20 piezas** (nuevo: `PROVISIONAL_soporte_disco`, 110,5 × 69,8 × 12 mm) caben en 256 × 256 × 256 mm con 10 mm de margen.
- Todas son **mallas cerradas** (cada arista la comparten exactamente 2 caras).
- La pieza más alta es la carcasa trasera (150,9 mm). La bandeja de servicio pasa a 141 × 237,5 mm (sin distribución DC). Volumen sólido total: unos **1404 cm³**.

Holguras que conviene revisar con piezas reales:

- Componentes de la placa HP frente a la tina: ≥ 3 mm solo si miden ≤ 41 mm sobre la PCB (PENDIENTE H-3).
- Canal USB frente a la Pi: unos 3 mm.
- Pulsador exterior frente a la pared derecha: unos 4,5 mm.
- Conectores traseros del HP: a ras por dentro de la pared de 3 mm; comprobar que las clavijas (HDMI, DC, RJ45, USB) entran hasta el fondo a través de 3 mm de PETG (PENDIENTE; si no, rebajar la pared alrededor de la ventana).

---

## 6. Archivos

```
hardware/cad/
  params.scad                  Parámetros documentados en español (presets de pantalla y HP, cuña, mandos, luz, bahías, impresión)
  lib.scad                     Perfil de la cuña, sistema de coordenadas de la pendiente, torretas, posiciones de orejetas y tornillos
  carcasa.scad                 Carcasa superior: cuna y repisa de pantalla, consola de mandos, canal de luz, rejillas,
                               cortes traseros, orejetas, costillas y pasadores
  piezas.scad                  Bisel, base, bandeja de servicio (con canal USB), soporte del Arduino, guía de luz frontal,
                               pomo, anillo de luz y pletina
  componentes.scad             Marcadores de MSI, HP, Pi, KVM (opcional), distribución DC, potenciómetros, pulsadores,
                               Arduino Micro, tira LED y cables ilustrativos; colores de render
  ensamblaje.scad              Vistas: montado | explosionado | interior | check
  partes.scad                  División en piezas imprimibles según la cama
  render.sh                    Genera los PNG en assets/renders/
  exportar.sh                  Exporta todos los STL (en paralelo)
  comprobar_interferencias.py  Comprobación de interferencias (admite -D 'pantalla="..."')
  comprobar_stl.py             Comprobación de cama y malla de los STL
  stl_a_step_freecad.py        Conversión STL → STEP con FreeCAD (STEP facetado)
  export/stl/PROVISIONAL_*.stl (19)
  export/step/                 STEP de v0 (no regenerados en v1; ver LEEME)
assets/renders/*.png (8, 1600×1000)
```

Cómo regenerarlo todo:

```bash
cd hardware/cad
./exportar.sh
python3 comprobar_stl.py
python3 comprobar_interferencias.py
./render.sh
# opcional (lento; v1 no lo regenera): freecadcmd stl_a_step_freecad.py
```

Herramientas usadas: OpenSCAD 2021.01, con `xvfb-run` para trabajar sin pantalla, y FreeCAD (freecadcmd).

**Sobre el STEP (v1):** **no se han regenerado** para v1. Los de v0 ya no corresponden a la geometría actual y no están en el repositorio (`.gitignore`). En v0 se generaron archivos STEP en `export/step/` a partir de los STL. Son **mallas facetadas convertidas a sólido, no B-rep paramétricos**: valen para visualizar o colocar las piezas en otro CAD, no para editar cotas. La comprobación de OpenCASCADE da como **no válidos** los STEP de 3 de los 4 trozos de carcasa (`carcasa_x0_y1`, `x1_y0`, `x1_y1`), aunque los STL de origen son mallas cerradas. **La referencia de geometría son el código OpenSCAD y los STL.** Un STEP B-rep de verdad exigiría rehacer el modelo en CadQuery, FreeCAD Part u Onshape, previsto para una iteración posterior.

---

## 7. Pendiente antes de fabricar (lista no exhaustiva)

1. ~~Identificar el HP real~~ → HP Slimline 260-a110ns, desmontado (§0b). **Medir la placa tras desmontarla** (H-1…H-10 de `datos-pendientes-hp.md`) y ajustar `mitx_*`, `hp_comp_h`, `hp_io_*`, `io_frontal`, `boton_hp_*`.
2. **Medir el MSI de Miguel:**
   - posición de los puertos y de las teclas OSD a lo largo del canto derecho (`puertos_v0/1`, `osd_v0/1`);
   - marcos y desplazamiento del área activa;
   - holgura del soporte plegado.
   Después, probar la ergonomía de la ventana OSD.
3. **Medir los potenciómetros y pulsadores reales:**
   - casquillo, cuerpo y pestaña anti-giro;
   - tipo de eje (liso, en D o estriado);
   - espesor de panel admitido.
   Después, fijar `pot_tipo`/`boton_tipo` o añadir un preset propio.
4. **Arduino Micro:**
   - medir las alturas reales y el margen sin pines en los extremos;
   - decidir entre dupont y conector para poder desmontar la bandeja;
   - medir el largo de la clavija micro-USB del cable.
5. **Recorrido real de cables:**
   - Mini-HDMI → Pi: según el modelo, la Pi 4/5 tiene micro-HDMI y hará falta adaptador o cable Mini-HDMI ↔ micro-HDMI;
   - USB-C → HP/fuente por el pasacables;
   - micro-USB → Pi.
   Añadir alivio de tensión. En los renders están **dibujados**, no validados.
6. **Vídeo:** modo A (visor remoto, sin cambios mecánicos) o modo B (HP HDMI → Mini-HDMI; Pi → adaptador HDMI→USB-C → USB-C 1; MSI alimentada por USB-C 2 con PD > 15 W). Medidas del adaptador real: **PENDIENTE** (hueco de 72 × 32 × 16 mm).
7. Medidas reales de la **distribución DC** y de los **prolongadores de panel**. Ajustar los huecos traseros.
8. **Térmica:** con la placa desnuda, comprobar el sentido del ventilador del disipador, medir temperaturas abierta y cerrada y, si hace falta, añadir un ventilador de extracción en la rejilla trasera (alimentación y modelo PENDIENTES).
9. **Rigidez:** el hueco de la pantalla y ahora las aberturas del tramo de puertos debilitan la pendiente. Revisar si flexa una vez impresa y quizá añadir nervios.
10. Juntas visibles de los cortes: decidir el acabado.
11. Pies de goma, burlete del bisel, tolerancias con la **A1 y el PETG reales** y calibración de los insertos.
12. Seguridad eléctrica: **no se diseña ningún circuito de red**. Toda la alimentación es por fuentes externas homologadas. Batería: solo como estudio futuro.
13. **Impresión de prueba de una esquina** (por ejemplo la consola con un potenciómetro y un pulsador) antes de imprimir el conjunto.
14. Preset `waveshare_12_3`: sin mantener en v1 (interfiere).

> **Recordatorio: NO APTO PARA FABRICACIÓN.** Diseño v1 provisional; todas las comprobaciones son simulaciones geométricas.
