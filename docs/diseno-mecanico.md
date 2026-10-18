# ORBIT TERMINAL · Diseño mecánico v0 (Fase 3 preliminar)

> **⚠️ NO APTO PARA FABRICACIÓN.** Esto es un primer volumen de diseño industrial paramétrico para validar proporciones, distribución interna y la estrategia de impresión. Hay varias cotas **PENDIENTES** (HP real, KVM, puertos del monitor, pulsadores, insertos), no se ha impreso ni montado ninguna pieza y las comprobaciones son **simulaciones geométricas sobre cajas envolventes**, no pruebas físicas. Los STL/STEP llevan el prefijo `PROVISIONAL_`.

Fecha: 2026-10-18 (UTC+1). Fuentes comprobadas el 2026-10-18 salvo que se indique otra cosa.

---

## 1. Intención de diseño frente a las imágenes de referencia

| Rasgo de la referencia | Cómo se resuelve en v0 |
|---|---|
| Cuña negra mate, delgada delante y gruesa detrás | Perfil lateral extruido: frente de 22 mm, pendiente de 30°, lomo plano trasero; aristas redondeadas (r = 5 mm) en el perfil y chaflán de 3 mm en los laterales |
| Pantalla a la izquierda, fija e inclinada, sin bisagras | Cuna para el monitor **MSI PRO MP161 E2U** entero dentro de la pendiente, con un bisel atornillado por encima |
| Consola triangular a la derecha con 2 pomos y anillos ámbar | Consola de 92 mm en la misma pendiente, separada de la pantalla por una ranura en V; 2 pomos Ø30 sobre encoders PEC11R y una guía de luz anular translúcida bajo cada uno |
| Botones de encendido y de cambio de sistema bajo los pomos | 2 huecos Ø15,6 con tapas Ø15 que llevan un punto indicador ámbar (pulsador concreto **PENDIENTE**) |
| Tira de luz ámbar en la base | Ranura pasante de 5 mm en el frente inferior, con guía translúcida en 2 tramos y carril para tira SK6812 WWA |
| Puertos traseros (audio, 2×USB-A, 2×USB-C, 2×HDMI, RJ45, DC) | Panel trasero con huecos para prolongadores de montaje en panel (modelos **PENDIENTES**) y una ventana I/O directa al HP |
| Rejillas laterales | Ranuras horizontales en ambos laterales que siguen la pendiente, más una rejilla superior en la trasera |

Diferencia consciente con la referencia: la imagen 1 tiene la pantalla más vertical (a ojo, unos 60°). En v0 la inclinación es de **30°**, porque con una pantalla de 15,6" a más ángulo la carcasa crece mucho en altura. Es el parámetro `inclinacion` de `params.scad` y se puede subir; la cuña se recalcula sola, pero hay que volver a pasar la comprobación de interferencias.

Renders (vista previa OpenCSG de OpenSCAD, ilustrativos y no fotorrealistas; la interfaz de la pantalla es un dibujo de ejemplo):

| Vista | Archivo |
|---|---|
| 3/4 frontal (principal, MSI 15,6") | `assets/renders/01_msi_frontal_3-4.png` |
| 3/4 frontal derecha (MSI) | `assets/renders/01b_msi_frontal_der_3-4.png` |
| Lateral, ortográfica (MSI) | `assets/renders/02_msi_lateral.png` |
| 3/4 trasera (MSI) | `assets/renders/03_msi_trasera_3-4.png` |
| Explosionada (MSI) | `assets/renders/04_msi_explosionado.png` |
| Interior, sin carcasa superior (MSI) | `assets/renders/05_msi_interior.png` |
| Comparativa: Waveshare 12,3" | `assets/renders/06_w123_comparativa_frontal_3-4.png` |

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
| Posición exacta de los conectores | **PENDIENTE**. El manual solo muestra que están en los cantos laterales; hay que medir el monitor de Miguel | — |
| Posición del área activa dentro del marco | **PENDIENTE**. Se supone centrada (`act_off_x/y = 0`) | — |

### 2.2 Decisión: el monitor va entero en una cuna, sin desmontarlo

Se aloja el monitor completo, sin sacar el panel de su carcasa, por estas razones:

1. **Garantía y riesgo:** abrir un monitor portátil de carcasa pegada o con clips puede anular la garantía, y el panel LCD desnudo es frágil (cristal de unos 2–3 mm con la placa de control pegada).
2. **El soporte no estorba:** el soporte plegable va integrado en la trasera y, plegado, el monitor sigue midiendo los 18,8 mm oficiales. Por eso la cuna es un bolsillo de 364,26 × 235,84 × 19,3 mm (1 mm de holgura por lado y 0,5 mm de fondo).
3. **Conectores en los cantos:** la cuna tiene ranuras laterales para los cables (entre el 20 % y el 80 % de la altura, a confirmar midiendo). Se recomiendan cables Mini-HDMI y USB-C acodados.
4. **Reversible:** Miguel puede recuperar su monitor quitando el bisel (12 tornillos M3).

Cómo queda sujeto: el monitor apoya en una repisa perimetral de 10 mm de ancho, y la repisa tiene una gran abertura central para cables, aire y menos peso. Por arriba lo sujeta el bisel, que tapa el marco plástico del monitor y deja una ventana igual al área activa más 1 mm por lado, con chaflán a 45°. Hay que añadir burlete o EVA de 1 mm entre bisel y monitor (**PENDIENTE**, no modelado).

### 2.3 Táctil: el MSI no es táctil

El MP161 E2U **no es táctil**. Para el prototipo hay dos caminos:

**A) Sin táctil:** manejar la interfaz con los dos encoders con pulsador (foco y selección, pensando la UI para navegar con rueda) y, para depurar, un ratón USB conectado al puerto USB-A trasero. Es la opción recomendada para la primera iteración.

**B) Overlay táctil USB de 15,6" puesto delante del monitor.** Opciones reales encontradas:

| Overlay | Tecnología | Medidas | Interfaz | Precio | Fuente |
|---|---|---|---|---|---|
| **Obeytouch OB156AP-3K1-T99** (16:9) | IR, 2/4/6/10 puntos según opción | Exterior **382 × 235 mm**, **grosor 7,9 mm**, marco de 18,5 mm, área activa 345 × 198 mm, vidrio templado de 3 mm (352 × 205 mm) | USB 2.0, 5 V a 100 mA; Windows, Linux y Android | **61,00 USD** (precio en la web del fabricante) | https://www.obtouch.com/product/15-6-inch-ir-touch-screen-overlay-with-2-4-6-touchpoints/ |
| **GreenTouch GT-TM156** | IR de 10 puntos, vidrio templado de 3 mm | Medidas **pendientes de verificar** | USB HID sin driver (Windows, Linux, Android) | **112,88 USD** (Amazon US, según el buscador; la página no se pudo abrir) | https://www.amazon.com/GreenTouch-Infrared-Overlay-Thickness-Tempered/dp/B08SJXHXGL |

El modelo ya lo contempla: con `usar_overlay_ir = true` el bolsillo crece hasta el contorno del Obeytouch (382 × 235 mm) y gana 7,9 mm de profundidad, y la carcasa se ensancha sola. **No se ha comprobado** si el área activa del overlay (345 × 198) queda bien alineada con la del monitor (344,16 × 193,59), ni si un overlay IR funciona bien con el bisel justo encima: los marcos IR necesitan que nada tape sus emisores, así que el bisel tendría que montarse por fuera del marco del overlay. Esto queda pendiente para la siguiente iteración.

---

## 3. Dimensiones generales y lista de piezas

### 3.1 Envolvente (salida de `comprobar_interferencias.py`)

| Preset de pantalla | Ancho × Fondo × Alto (sin pies) | Con pies |
|---|---|---|
| **msi_15_6** (prototipo, renders principales) | **484,3 × 306,5 × 153,9 mm** | Alto 157,9 mm |
| waveshare_12_3 (comparativa) | 483,0 × 289,8 × 98,7 mm | Alto 102,7 mm |
| waveshare_11_6 (opcional) | 483,0 × 289,8 × 125,5 mm | **Interfiere**; ver §5 |

Con pantallas pequeñas, lo que fija el ancho y el fondo es el **hardware interno, no la pantalla**: la fila HP + KVM + columna de Pi y distribución necesita unos 483 mm de ancho, y el HP necesita unos 290 mm de fondo. Por eso la versión de 12,3" no resulta más estrecha, solo más baja, y su consola de mandos queda más ancha. Para que sea compacta haría falta otra distribución, por ejemplo con el KVM encima del HP o un HP más pequeño.

### 3.2 Piezas imprimibles (cama de 256 × 256 × 256 mm, margen de 10 mm)

| Pieza (STL en `hardware/cad/export/stl/`) | Cant. | Caja envolvente (mm) | Material sugerido |
|---|---|---|---|
| `PROVISIONAL_carcasa_x{0,1}_y{0,1}` | 4 trozos | ≤ 242,1 × 153,2 × 150,9 | PETG o ASA negro mate |
| `PROVISIONAL_base_x{0,1}_y{0,1}` | 4 trozos | ≤ 242,1 × 153,1 × 18 | PETG negro |
| `PROVISIONAL_bisel_x{0,1}_y{0,1}` (se imprime plano, cara vista abajo) | 4 trozos | 190,8 × 126,6 × 3,6 | PETG o ASA negro |
| `PROVISIONAL_bandeja_servicio` (lleva la Pi y la distribución) | 1 | 142 × 156 × 14 | PETG |
| `PROVISIONAL_guia_luz_frontal_{0,1}` | 2 tramos | 215,1 × 9 × 7 | PETG translúcido natural |
| `PROVISIONAL_anillo_luz_x2` | imprimir 2 | 41 × 41 × 5,6 | PETG translúcido natural |
| `PROVISIONAL_pomo_x2` | imprimir 2 | Ø30 × 17 | PETG o PLA negro (o pomo comercial) |
| `PROVISIONAL_tapa_boton_x2` | imprimir 2 | Ø19 × 7,5 | PETG negro con indicador ámbar |
| `PROVISIONAL_pletina_empalme_x4` | imprimir 4 | 30 × 10 × 3 | PETG |

El volumen de material sólido de todas las piezas, contando cada archivo una sola vez, es de unos **1496 cm³**. El consumo real de filamento dependerá del relleno y no está calculado.

Componentes comprados o reutilizados (marcadores, no se imprimen):

- MSI PRO MP161 E2U.
- HP (modelo desconocido).
- Raspberry Pi.
- KVM.
- Distribución DC.
- 2× PEC11R.
- 2 pulsadores.
- Tira SK6812 WWA.
- Insertos térmicos M3 y tornillos M3 (aprox. 12 para el bisel, unos 16 para unir carcasa y base, 4 para la bandeja, 8 para las pletinas).
- Pasadores de acero Ø3 × 16.
- 4 pies de goma Ø12.

### 3.3 Uniones y montaje

1. **Carcasa en 4 trozos.** Los planos de corte se calculan solos según la cama (`nx_cortes`, `ny_cortes`). Junto a cada corte hay una costilla interior de 8 mm pegada a la pared, con agujeros Ø3,2 para **pasadores de alineación de Ø3 × 16 mm**. Los trozos se pegan (adhesivo para PETG o ABS/ASA) y quedan alineados por los pasadores.
2. **Base en 4 trozos**, unida por dentro con 4 pletinas atornilladas a torretas con inserto M3. La base se atornilla desde abajo, con tornillos avellanados, a orejetas con inserto M3 de la carcasa. Las orejetas frontales son columnas hasta el techo, detrás del carril LED.
3. **Bisel en 4 trozos**, cada uno con 3 tornillos M3 avellanados propios a insertos de la carcasa. No necesita uniones entre trozos.
4. **Bandeja de servicio:** la Pi (separadores M2.5 con el patrón de 58 × 49 mm) y la distribución DC van montadas en la bandeja, que se quita desde abajo con 4 tornillos M3 sin abrir la carcasa.
5. **Encoders:** atornillados con su tuerca M7 desde fuera, en un refuerzo de 2 mm bajo la pendiente, con un hueco anti-giro cuya posición está **PENDIENTE**. Los pomos llevan agujero en D de 6 mm.

---

## 4. Cotas: con fuente y PENDIENTES

| Elemento | Valor en el modelo | Estado | Fuente o nota |
|---|---|---|---|
| MSI MP161 E2U, contorno | 362,26 × 233,84 × 18,8 | **Con fuente** | Página de especificaciones de MSI (§2.1) |
| MSI, área activa | 344,16 × 193,59 | **Con fuente** | Ídem |
| MSI, desplazamiento del área activa y posición de los conectores | Centrada; ranuras entre el 20 % y el 80 % | **PENDIENTE** | Medir el monitor |
| Waveshare 12,3" | 301,2 × 123,35 × 12,4; activa 293,10 × 110,20 | **Con fuente** | https://www.waveshare.com/wiki/12.3inch_1920x720_LCD (ver `pantallas.md`) |
| Waveshare 11,6" (H) | 279,50 × 177,09 × 21,20; activa 256,32 × 144,18 | **Con fuente** | Plano de Waveshare (ver `pantallas.md`) |
| Overlay Obeytouch | 382 × 235 × 7,9 | **Con fuente** | Web de Obeytouch (§2.3) |
| HP, preset `desktop_mini_ref` | 177,04 × 174,75 × 34,29 (ancho × fondo × alto) | **Con fuente, pero solo como REFERENCIA**: son las medidas del chasis del HP EliteDesk 800 G3 Desktop Mini, **no** del equipo de Miguel | Hoja de especificaciones de HP (doc. c05371240). La URL original de support.hp.com ahora da 404; se consultó una copia del mismo documento en https://server-shop.ua/assets/images/resources/18163/hp-elitedesk-800-g3-desktop-mini-business-pc-35-w-65-w-specifications-hp-customer-support.pdf |
| HP real | — | **PENDIENTE** | Si es un SFF de unos 2017, **no cabe** en esta cuña: habría que rediseñar o dejarlo fuera (ver `datos-pendientes-hp.md`) |
| HP, ventana I/O trasera | 169 × 36,3 mm | **PENDIENTE** | Depende de la trasera real |
| Raspberry Pi | Placa 85 × 56; agujeros 58 × 49 a 3,5 mm del borde, Ø2,7 | **Con fuente** | https://datasheets.raspberrypi.com/rpi4/raspberry-pi-4-mechanical-drawing.pdf |
| Raspberry Pi, altura con conectores | 20 | **PENDIENTE** | Según el modelo que tenga Miguel |
| KVM (TESmart HKS201-P23-V2) | 140 × 90 × 30 | **PENDIENTE** | El fabricante no publica medidas. Alternativa con medidas publicadas: ATEN CS692, 82,4 × 66,5 × 25,2 (ver `conmutacion-video-usb.md`) |
| Distribución DC | 110 × 60 × 30 | **PENDIENTE** | Placa aún sin elegir (ver `alimentacion-preliminar.md`) |
| PEC11R | Casquillo M7 × 0,75 (agujero de 7,4); eje de 6 mm | **Con fuente** | https://www.bourns.com/docs/product-datasheets/pec11r.pdf |
| PEC11R, cuerpo bajo panel y anti-giro | 13 × 13 × 9 | **PENDIENTE** | Comprobar con la hoja de datos o la pieza |
| Pulsadores y vástago de tapa | Hueco Ø15,6; vástago Ø3,8 | **PENDIENTE** | Pulsador sin elegir |
| Insertos M3 | Agujero Ø4,0 × 5,7 | **PENDIENTE** | Según el fabricante del inserto |
| Tira LED | 10,4 mm de ancho | **PENDIENTE** | Tira SK6812 WWA sin elegir |
| Huecos de los prolongadores de panel (USB, HDMI, RJ45, DC, audio) | Orientativos | **PENDIENTE** | Ajustar a los prolongadores comprados |
| Paredes, suelo, inclinación, marcos, radios | 3 / 4 / 30° / 14 / 5 | Decisión de diseño | Modificables en `params.scad` |

---

## 5. Comprobaciones de interferencias (simulación)

**Tipo de comprobación:** programática, por muestreo de puntos (9³ por caja) sobre las **cajas envolventes (AABB) de los marcadores**. No son modelos reales de los componentes, así que conectores, cables, radiadores y flujo de aire **no** están evaluados.

`hardware/cad/comprobar_interferencias.py` lanza OpenSCAD en modo `vista="check"`, lee los parámetros y cajas que este imprime con `echo`, y comprueba dos cosas:

1. Que cada componente esté dentro del volumen interior libre, respetando:
   - las paredes y el techo inclinado (en el sistema de coordenadas de la pendiente);
   - la tina de la pantalla y las torretas del bisel;
   - las costillas de unión junto a los cortes;
   - las orejetas;
   - el carril LED.
2. Que no haya solapes por pares entre componentes, encoders y pulsadores, estos últimos transformados desde la pendiente.

Resultados del 2026-10-18 (con 0 mm de margen; "holgura mínima" es el mayor margen probado, de 1, 2, 3, 5, 8 o 10 mm, que sigue sin colisión):

| Preset | HP | Pi | KVM | Distribución DC | Solapes | Resultado |
|---|---|---|---|---|---|---|
| **msi_15_6** | OK, ≥ 3 mm (limita una orejeta) | OK, ≥ 5 mm | OK, ≥ 3 mm | OK, ≥ 5 mm | Ninguno (8 cajas) | **Sin interferencias** |
| waveshare_12_3 | OK, ≥ 3 mm (limita la tina) | OK, ≥ 3 mm | OK, ≥ 3 mm | OK, ≥ 5 mm | Ninguno | **Sin interferencias** |
| waveshare_11_6 | **Interfiere con la tina de la pantalla** | OK | OK | OK | Ninguno | **Interferencia**: el 11,6" mide 21,2 mm de grueso y en esta cuña más baja la tina baja hasta el HP. Se arreglaría con más `lomo_base` o más inclinación (no hecho) |

Por el camino, la comprobación ya detectó y obligó a corregir varios choques reales del diseño: Pi y distribución contra las orejetas, KVM contra la costilla trasera, HP contra la tina con el primer fondo, y orejetas que tapaban la ventana I/O del HP.

**Comprobación de piezas frente a la cama** (`comprobar_stl.py`, 2026-10-18): las 19 piezas caben en 256 × 256 × 256 mm con 10 mm de margen y todas son **mallas cerradas**, es decir, cada arista la comparten exactamente 2 caras. La pieza más alta es la carcasa trasera, de 150,9 mm.

Holguras que conviene revisar con piezas reales:

- Entre el HP y la tina de la pantalla: en el preset del MSI, unos 3–5 mm.
- Los conectores traseros del HP quedan unos 14 mm por dentro de la superficie exterior: hay que confirmar que los cables entran por la ventana.

---

## 6. Archivos

```
hardware/cad/
  params.scad                  Parámetros documentados en español (presets de pantalla y HP, cuña, mandos, luz, bahías, impresión)
  lib.scad                     Perfil de la cuña, sistema de coordenadas de la pendiente, torretas, posiciones de orejetas y tornillos
  carcasa.scad                 Carcasa superior: cuna y repisa de pantalla, consola de mandos, canal de luz, rejillas,
                               cortes traseros, orejetas, costillas y pasadores
  piezas.scad                  Bisel, base, bandeja de servicio, guía de luz frontal, pomo, anillo de luz, tapa de botón y pletina
  componentes.scad             Marcadores de MSI, HP, Pi, KVM, distribución DC, encoders y tira LED; colores de render
  ensamblaje.scad              Vistas: montado | explosionado | interior | check
  partes.scad                  División en piezas imprimibles según la cama
  render.sh                    Genera los PNG en assets/renders/
  exportar.sh                  Exporta todos los STL (en paralelo)
  comprobar_interferencias.py  Comprobación de interferencias (admite -D 'pantalla="..."')
  comprobar_stl.py             Comprobación de cama y malla de los STL
  stl_a_step_freecad.py        Conversión STL → STEP con FreeCAD (STEP facetado)
  export/stl/PROVISIONAL_*.stl (19)
  export/step/PROVISIONAL_*.step (19, facetados)
assets/renders/*.png (7, 1600×1000)
```

Cómo regenerarlo todo:

```bash
cd hardware/cad
./exportar.sh
python3 comprobar_stl.py
python3 comprobar_interferencias.py
./render.sh
freecadcmd stl_a_step_freecad.py
```

Herramientas usadas: OpenSCAD 2021.01, con `xvfb-run` para trabajar sin pantalla, y FreeCAD (freecadcmd).

**Sobre el STEP:** se han generado archivos STEP en `export/step/` a partir de los STL. Son **mallas facetadas convertidas a sólido, no B-rep paramétricos**: valen para visualizar o colocar las piezas en otro CAD, no para editar cotas. La comprobación de OpenCASCADE da como **no válidos** los STEP de 3 de los 4 trozos de carcasa (`carcasa_x0_y1`, `x1_y0`, `x1_y1`), aunque los STL de origen son mallas cerradas. **La referencia de geometría son el código OpenSCAD y los STL.** Un STEP B-rep de verdad exigiría rehacer el modelo en CadQuery, FreeCAD Part u Onshape, previsto para una iteración posterior.

---

## 7. Pendiente antes de fabricar (lista no exhaustiva)

1. **Identificar el HP real** (modelo, medidas y trasera) y sustituir el preset de referencia. Si es SFF, replantear la arquitectura.
2. **Medir el MSI de Miguel:** posición de los conectores, marco inferior y superior, desplazamiento del área activa y holgura del soporte plegado.
3. Decidir **con o sin overlay táctil**. Si se usa el overlay IR, rediseñar el bisel para que no tape los emisores.
4. Medidas reales del **KVM** (TESmart o ATEN), de la **distribución DC** y de los **prolongadores de panel**. Ajustar los huecos traseros.
5. Elegir **pulsadores** e insertos; confirmar el anti-giro y el cuerpo del PEC11R.
6. **Térmica:** el HP Desktop Mini toma y expulsa aire por sus propias rejillas, que están **PENDIENTES** para el modelo real. Hay que orientar sus entradas y salidas hacia las rejillas de la carcasa y medir temperaturas en el banco de pruebas. Puede hacer falta un ventilador.
7. **Recorrido de cables** (HDMI y USB-C del monitor, KVM, Pi, tira LED) y alivio de tensión: no está modelado.
8. **Rigidez:** el hueco de la pantalla deja la pendiente casi sin material entre los laterales. Revisar si flexa una vez impresa y quizá añadir nervios bajo la repisa.
9. Juntas visibles de los cortes en la pendiente y en el lomo: decidir el acabado (masilla y pintura, o cortes alineados con ranuras decorativas).
10. Pies de goma, burlete del bisel, tolerancias de impresión con la impresora real y calibración de los insertos.
11. Seguridad eléctrica: la v0 **no diseña ningún circuito de red**. Toda la alimentación es por fuentes externas homologadas (ver `alimentacion-preliminar.md`). Batería: solo como estudio futuro.
12. Hacer y revisar una **impresión de prueba a escala o de una sola esquina** antes de imprimir el conjunto.

> **Recordatorio: NO APTO PARA FABRICACIÓN.** Diseño v0 provisional; todas las comprobaciones son simulaciones geométricas.
