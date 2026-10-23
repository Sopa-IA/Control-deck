# ORBIT TERMINAL · Diseño mecánico v1 + HP v3 (Fase 3 preliminar)

> **⚠️ NO APTO PARA FABRICACIÓN.** Volumen de diseño industrial paramétrico para validar proporciones, distribución interna y la estrategia de impresión. Hay varias cotas **PENDIENTES** (posición de puertos y teclas del MSI, potenciómetros, pulsadores, insertos), las comprobaciones son **simulaciones geométricas sobre cajas envolventes**, no pruebas físicas, y los STL llevan el prefijo `PROVISIONAL_`.
>
> **2026-10-20:** el modelo vigente es `usar_hdd_35 = true` (HDD Toshiba 3,5", cotas SFF-8301 en `hardware/cad/params.scad`). Varios párrafos de este archivo siguen describiendo el preset anterior de SSD 2,5". Para el estado actual, leer [`ESTADO-Y-TRASPASO.md`](ESTADO-Y-TRASPASO.md).
>
> **2026-10-20, más tarde:** los mandos pasan de Arduino Micro a **Nano** (PCB de catálogo 18 × 45 mm). Entran un ESP8266, un segundo Nano de prácticas, un panel de pines en la trasera y una OLED 0,96". Las torretas y el canal USB de la bandeja impresa no se mueven. Los párrafos de abajo que dicen «Micro», «48 × 17,7» o «micro-USB del Arduino» describen el diseño anterior. La geometría vigente está en `params.scad`.
>
> **2026-10-21, bandeja v2:** Miguel reimprime la bandeja entera. La Pi gira (USB y RJ45 hacia +Y, en la mitad izquierda) y la bahía queda integrada en la plancha. La sección «Bahía modular» de más abajo describe el riel suelto de la bandeja v1: **no se imprime**. El STL `PROVISIONAL_riel_placas` se ha retirado.
>
> **2026-10-22, huecos fijos:** la bahía de carros, la cuna y el retenedor salen de la bandeja. Cada placa va en un bolsillo. La Pi, la rejilla, la tapa y `carcasa_x1_y1` no se mueven. Los párrafos de carros de «Bandeja v2» describen esa bahía: **no se imprimen**. Lo vigente está en «Huecos fijos».

## Bandeja v2 (2026-10-21)

La base ya está impresa. No se reimprime. El hueco y los 4 M3 siguen en x = 318,26 y 436,26, y = 49 y 278,492. El ala de la bandeja mide 126,00 × 237,49 mm, la misma envolvente que entra por ese hueco.

Foto de Miguel, desde arriba, con la trasera (+Y) en la parte de arriba: la Pi suelta está en la mitad izquierda, los dos USB y el RJ45 miran a +Y (hacia la rejilla), los micro-HDMI y el USB-C miran a +X, la micro-SD al frente (−Y) y la antena SMA del HAT apunta a +X, tumbada. Esa es la orientación del modelo. [FOTO]

La foto deja las clavijas casi en el borde trasero del hueco (y = 274,5). Detrás de ese borde la pared interior está a 23 mm (y = 297,5): una clavija recta no cabe. La placa se adelanta hasta dejar 42 mm entre la cara del conector y la pared (36 mm de clavija USB-A [DISEÑO] + 6 mm). El centro de la placa queda en x = 358, entre el HDD (acaba en x = 294,6) y la canaleta (x = 420).

| Qué | Dónde |
|---|---|
| Pi 4, PCB 56 × 85 | x = 330 a 386, y = 167,5 a 252,5. Separadores de 8 mm. Cara de los USB en y = 255,5. Las clavijas de 36 mm acaban en y = 291,5 |
| GPIO / lado del OLED del HAT | canto −X. El HAT no se modela: no está medido [PENDIENTE] |
| micro-HDMI y USB-C | canto +X, hacia el frente de ese canto. Reserva de clavija 26 mm, hasta x = 412. La canaleta empieza en x = 420. Un USB-C recto más largo que eso no cabe: hace falta un conector en ángulo [PENDIENTE de medir el cable] |
| micro-SD | canto −Y. Muesca en el suelo, 18 × 20 mm, delante de la placa. La posición exacta de la ranura en el plano es [PENDIENTE] |
| Nano de mandos | Cuna impresa en la bandeja, abajo a la derecha (eje x = 418,26, PCB y = 70 a 115). El soporte suelto ya impreso no encaja: la v2 no trae sus torretas |
| Nano de prácticas | Carro, puesto y = 90. USB hacia +X. Pines hacia abajo, hueco de 17,5 mm |
| ESP8266 de la tira, o proto 30 × 70 | El otro carro, puesto y = 124. No van los dos a la vez. El ESP es 58 × 31 mm [PENDIENTE], estimación de la foto, no un DEVKIT 1.0 |
| Capturadora | Nido 26 × 32 × 14 mm en x = 390, y = 220. La reserva de 72 mm no entra. El hueco del adaptador HDMI→USB-C se quita de la bandeja [PENDIENTE] |
| Cable del Nano de mandos | Canaleta en x = 420, desde y = 142, y giro a −X en y = 258 hasta el USB derecho de la Pi. No sale de la bandeja |

La rejilla de entrada de la base sigue bajo el HP (x = 47 a 157). La bandeja no la tapa. El ventilador que hay en el modelo es el del disipador del HP: un marcador de 50 × 50 × 10 mm sobre esa placa, en x = 75 a 125 e y = 202 a 252. Es ilustrativo; el sentido real sigue en H-5 [PENDIENTE]. El HDD (x = 193 a 294,6) queda entre ese ventilador y la Pi. Esas ranuras alimentan la zona del HP.

La Pi tiene su propio camino. El HAT tapa la cara de arriba, así que el aire entra por debajo y sale por detrás:

| Tramo | Dónde |
|---|---|
| Entrada | Ranuras en el suelo de la bandeja, bajo el SoC. Ocho columnas de 2,0 mm, paso 3,6 mm, de x = 343 a 370. Dos tramos en Y: 183 a 197 y 199 a 215, con un nervio de 2 mm. Atraviesan el ala y el suelo (6 mm). En la cama son agujeros verticales |
| SoC | 15 × 15 mm, x = 346 a 361, y = 189,25 a 204,25. [FUENTE] plano mecánico de la Pi 4, vía el modelo process1183 que lo cita. La RAM y el PMIC no están en ese plano: la banda los cubre alrededor del SoC. La cota del PMIC es [PENDIENTE] |
| Bajo la PCB | Separadores de 8 mm. El cuerpo de un ventilador de 10 mm no cabe ahí |
| Entre placas | Lo deja el separador del HAT. La altura del HAT no está medida [PENDIENTE] |
| Salida alta | Ranuras en `tapa_pi`, dentro del hueco de 72 × 42 mm. La rejilla trasera de `carcasa_x1_y1`, alineada en X con la Pi (x = 334 a 382), baja hasta z = H−64 (z ≈ 90) y sigue hasta z ≈ 140. Queda por encima de las clavijas (z ≈ 30) y no corta el panel de pines |
| Ventilador opcional | En la tapa, sin montarlo: cuatro agujeros Ø3,2 a 32 mm (ventilador 40 × 40) y otros cuatro a 24 mm (30 × 30). [DISEÑO] Patrón habitual; el ventilador no está elegido |

Los postes M2.5 (Ø6, ejes en x = 333,5 y 382,5, y = 171 y 229) quedan a más de 9 mm de las ranuras. La muesca de la micro-SD acaba en y = 171,5. Los pies de la base miden 1 mm: el aire de la rejilla entra por debajo del chasis, por esa holgura [PENDIENTE de ver si basta]. La base no se reimprime.

Tapa: hueco 72 × 42 mm en el lomo plano (x = 324 a 396, y = 252 a 294), solo en `carcasa_x1_y1`. Dos M3 en una oreja a la derecha del hueco, con paso libre Ø3,4 en la tapa y guía Ø2,5 × 9 mm en cada poste Ø10 (pared 3,75 mm). Tornillo M3×8 de cabeza de botón, JINZEYOU [DISEÑO]: la tapa mide 2,4 mm y entran unos 5,6 mm en la guía, sin llegar al fondo. Las tres orejetas de esta pieza que apoyan en la base (325, 292,5), (420, 292,5) y (448,3, 205) llevan la misma guía, de 9 mm, en un taco de 12 × 12 × 11 mm (pared 4,75 mm). El tornillo entra desde abajo por el paso ya impreso de la base: M3×8 avellanado wugongshan [DISEÑO]. Las otras tres carcasas, la base, el soporte y los biseles conservan el agujero de inserto con el que se imprimieron: ahora se les mete el inserto de latón, sin reimprimirlos. El panel de pines y la OLED no se cortan. Una orejeta trasera de la carcasa (x = 325, y = 292, 11 mm de alto) queda a 1 mm del sobremolde modelado del RJ45; el cuerpo de la clavija pasa por encima. Si el capuchón es gordo, se enchufa hacia arriba.

Retención de la placa, de la bahía v2 (sustituida por los huecos fijos). Los carros llevan cuatro uñas en las esquinas de la PCB y una pestaña sobre el conector, para que la placa no se levante al tirar del USB. Bajo la PCB hay 17,5 mm: cabe un Dupont hembra de 14,5 mm más el separador negro de 2,5 mm [DISEÑO]; los cables de Miguel no se han medido. El Nano de mandos usa otra pieza, `PROVISIONAL_retenedor_nano`: engancha unos rebordes de la cuna, pisa las cuatro esquinas y lleva un tope sobre el mini-USB. El ESP apoya en cuatro columnas (agujeros de esquina, a 3,5 mm [DISEÑO], no medidos).

Sujeción del carro a la bandeja. Cada puesto (y = 90 y y = 124, sin moverlos) lleva un cajeado de 6,4 × 14 mm en el riel y dos tornillos en diagonal, a 9 mm en Y y 1,6 mm en X: en (327,2, 85,5) y (328,8, 94,5) para el Nano, y en (327,2, 119,5) y (328,8, 128,5) para el ESP o la proto. La zapata del carro entra con 0,15 mm por lado [DISEÑO]. El carro sigue con paso libre Ø3,4. Miguel no usa insertos (`fijacion = "autorroscante"`): cada tornillo rosca en una guía Ø2,5. En esta plancha solo hay 6 mm de plástico (suelo 4 + ala 2), así que la guía mide 5,2 mm y deja 0,8 mm de piel; no llega a los 8 mm pedidos. El tornillo es un M3×10 de cabeza cilíndrica [DISEÑO]: 7 mm de paso en la zapata y unos 3 mm de rosca. Un M3×12 tocaría el fondo. La pared hasta el borde del suelo, en el agujero de x = 327,2, queda en 3,4 mm. El ESP y la proto comparten el puesto y = 124: se cambia uno por el otro soltando esos dos tornillos. Los cuatro M3 que atan la bandeja a la base no se tocan. Las uñas, la pestaña y los 17,5 mm bajo la PCB siguen igual. El agarre del autorroscante es [PENDIENTE] de probar.

La proto de 70 mm acaba en x = 401, a unos 3 mm del retenedor de mandos. [PENDIENTE] medir esa placa antes de imprimir el carro.

`comprobar_interferencias.py` (2026-10-21, bandeja v2): salida 0 con `nano_esp` (23 cajas) y con `nano_proto` (22 cajas). Las clavijas USB-A de la Pi quedan a ≥ 5 mm de la pared. El carro del Nano de prácticas, a ≥ 1 mm de la tina. `comprobar_stl.py`: todas las mallas del directorio caben en la cama y están cerradas. No es un montaje.

### Qué se imprime (bandeja v2)

OpenSCAD 2021.01. No se ha lanzado `exportar.sh`. Cajas al centésima, de los vértices.

| STL | Caja (mm) | Volumen | Nota |
|---|---|---|---|
| `PROVISIONAL_bandeja_servicio` | 126,00 × 237,49 × 30,20 | 167,53 cm³ | Sustituye a la bandeja ya impresa. Mismos 4 M3 a la base. Cuatro guías Ø2,5 para los carros (antes 167,36 cm³, con agujero de inserto) |
| `PROVISIONAL_carro_nano` | 51,45 × 16,40 × 25,10 | 6,54 cm³ | Cama abajo. Dos M3. La caja en X es más corta por el lado del riel; la PCB y el USB no se mueven |
| `PROVISIONAL_carro_esp` | 64,45 × 29,60 × 25,10 | 3,94 cm³ | Igual. Mismos dos agujeros que la proto |
| `PROVISIONAL_carro_proto30x70` | 76,45 × 28,40 × 25,10 | 10,79 cm³ | Igual. Placa de diseño. Mismo puesto y = 124 |
| `PROVISIONAL_retenedor_nano` | 29,40 × 51,20 × 10,40 | 1,38 cm³ | Clip del Nano de mandos. Sin cambios |
| `PROVISIONAL_tapa_pi` | 94,00 × 54,00 × 2,40 | 9,70 cm³ | Tapa del techo, dos M3, ranuras y agujeros de ventilador (antes 11,90 cm³) |
| `PROVISIONAL_carcasa_x1_y1` | 228,13 × 150,25 × 150,93 | 233,81 cm³ | Guías Ø2,5 en los dos postes de la tapa y en las tres orejetas de esta pieza (antes 233,65 cm³). Las otras tres carcasas no |

No se reimprime la base. No se imprime el riel suelto (el STL se ha quitado). El `PROVISIONAL_soporte_arduino` ya impreso no se monta en esta bandeja. La fila de `PROVISIONAL_bandeja_servicio` de la tabla es la exportación de la bahía de carros (30,20 mm, 167,53 cm³). La vigente está abajo.

## Huecos fijos (2026-10-22)

Miguel aprueba el concepto de un bolsillo por placa, con paredes bajas y un tornillo en cada esquina. La foto de referencia no está a escala y tiene tres columnas: aquí los huecos van a lo largo, en dos columnas. El contorno no cambia (ala 126,00 × 237,49 mm). Los 4 M3 a la base siguen en x = 318,26 y 436,26, y = 49 y 278,492, con paso libre Ø3,4. Roscan en la base ya impresa. La carcasa y `tapa_pi` no se han tocado: las paredes de los Nano y del ESP acaban en z = 18,6 y la tapa está en el techo.

La Pi no se mueve. Sigue en x = 330 a 386, y = 167,5 a 252,5, USB y RJ45 hacia +Y, a 12 mm del suelo sobre los cuatro postes Ø6 (agujero Ø2,7, paso del M2,5). La rejilla bajo el SoC y la muesca de la micro-SD siguen igual. Las paredes de la Pi llegan a ras de la PCB (z = 13,5), sin reborde sobre la rejilla. El canto +Y queda abierto. El canto +X solo lleva pared de y = 216 a 250, por detrás de los HDMI. El HAT sigue sin modelar [PENDIENTE].

| Hueco | Esquina −X −Y de la PCB | PCB | USB | Cara inferior |
|---|---|---|---|---|
| Pi 4 | 330, 167,5 | 56 × 85 [FUENTE] | +Y | z = 12, postes de 8 mm |
| ESP8266 | 346, 86 | 31 × 58 [PENDIENTE] [FOTO] | +Y | z = 17 (`pin_bajo_pcb` = 13 sobre el suelo) |
| Nano de prácticas | 399, 66 | 18 × 45 [FUENTE] | −Y | z = 17 |
| Step-down | 399, 124 | 21 × 43 [PENDIENTE] | — | z = 7 |
| Nano de mandos | 400, 222 | 18 × 45 [FUENTE] | +Y | z = 17 |

Holgura 0,5 mm por lado (`b3_holg`). Pared 2,2 mm. En las tres placas con pines macho hacia abajo, cada fila tiene un canal de `pin_fila_w` = 3,2 mm desde el canto largo, vaciado hasta el suelo. Desde la cara inferior de la PCB hasta ese suelo hay `pin_bajo_pcb` = 13 mm: 11,5 mm del pin más largo, separador incluido, más 1,5 mm de aire [PENDIENTE] de medir. El apoyo es un escalón de 2,0 mm en la banda central del canto corto, fuera del último pin (`pin_extremo` = 2,5 mm, el dibujo empieza a 2,4 mm). En el canto del mini-USB de los Nano ese escalón no llega a 1,6 mm y no se imprime: sujetan las grapas. El ESP sí lo lleva a los dos lados del conector. El canto del USB sigue partido 10 mm. El step-down no lleva regleta en el modelo: reborde de 2,2 mm y un hueco de 3 mm para las soldaduras [DISEÑO].

La columna derecha (x = 399) queda fuera de la tina. El ESP queda debajo de la pantalla: con la bandeja en las torretas, el borde delantero de su PCB tiene 4,8 mm hasta el suelo de la tina, y el módulo dibujado (3 mm, centrado) tiene 14 mm. Delante de y ≈ 85 y a la izquierda de x ≈ 380 el suelo se queda bajo: ahí la tina no deja pared alta.

Tornillos de los kits. Guía Ø2,5 en los postes de fuera, poste Ø7,6 (pared 2,55 mm). La Pi se atornilla por sus agujeros reales, con inserto M2.5. La grapa de 1,6 mm sustituye a la arandela Ø9, que no está en los kits. `fijacion` sigue en `autorroscante` solo para no cambiar un futuro export de `carcasa_x1_y1`.

| Sitio | Dónde (ejes) | Guía | Tornillo |
|---|---|---|---|
| Pi, agujeros reales | (333,5, 171), (382,5, 171), (333,5, 229), (382,5, 229) | Ø3,0 × 7 mm, ciego, desde la cara del poste. [sin probar] | Inserto M2.5 4×3,5 y M2.5×8 botón |
| Pi, plan B | (328,0, 165,2), (388,0, 165,2), (327,8, 254,2), (388,6, 254,2) | Ø2,5 × 13 mm | M3×12 botón + grapa. No entra en la cuenta |
| ESP, cuatro esquinas | (344,5, 83), (378,5, 83), (344,5, 147), (378,5, 147) | Ø2,5 × 13 mm, desde z = 18,6 | M3×12 botón + grapa 1,6 mm |
| Nano de prácticas | (397,5, 63), (418,5, 63), (397,5, 114), (418,5, 114) | Ø2,5 × 13 mm | M3×12 botón + grapa |
| Nano de mandos | (398,5, 219), (419,5, 219), (398,5, 270), (419,5, 270) | Ø2,5 × 13 mm | M3×12 botón + grapa |
| Buck, agujeros del módulo | (402,5, 127,5) y (416,5, 163,5), a 3,5 mm de la esquina [PENDIENTE] | Ø2,5 × 7 mm, desde la cara inferior (z = 7). No atraviesa el ala | M3×8 botón. Atraviesa la PCB (1,6 mm) y entran 6,4 mm |
| Buck, las otras dos esquinas | (421,5, 121) y (397,5, 166). Esta última va en el canto −X: por detrás chocaría con el HDMI | Ø2,5 × 8 mm, desde z = 8,6 | M3×8 botón + grapa |
| Bandeja a la base | (318,26, 49), (436,26, 49), (318,26, 278,492), (436,26, 278,492) | Inserto M3 6×5 en la torreta, agujero Ø4,0 | M3×8 botón. No es M3×16: el kit trae 20 y 17 ya están contados |

Los postes M2.5 de la Pi son la fijación: inserto M2.5 4×3,5 en un agujero Ø3,0 × 7 mm, y tornillo M2.5×8 de cabeza de botón. Los cuatro postes de fuera se quedan como plan B.

Canales. Las paredes de los bolsillos hacen de canal. Siete puentes (dos postes y una barra a 4,2 mm del suelo, luz de unos 4 mm) sujetan el cable: entre prácticas y buck (x = 402 y 409), en el corredor entre el ESP y la columna derecha (y = 100 y 132), y en el canto derecho (x = 423,5, y = 148, 198 y 238), por fuera del sobremolde HDMI (acaba en x = 412).

La proto 30 × 70 se queda sin puesto. La capturadora también: su nido (x = 390, y = 220) caía encima del Nano de mandos. `usar_nido_captura = false`. Dónde va el aparato es [PENDIENTE].

`PROVISIONAL_bandeja_servicio`: 126,00 × 237,49 × 20,60 mm, 181,71 cm³, un solo sólido, malla cerrada, z de −2 a 18,6. Cabe en la cama de la A1 (256 × 256, margen 10): el lado largo mide 237,49 y el límite con margen es 246. `comprobar_interferencias.py` (2026-10-22, tras bajar las tres PCB a 13 mm): salida 0, 23 cajas. Esa comprobación no suma los 11 mm de las torretas. Con la bandeja montada, el Nano de prácticas (USB de 4 mm, y = 66) queda a 12,6 mm del techo interior; el ESP, bajo la tina, tiene 4,8 mm en el borde delantero de la PCB y 14 mm en el módulo dibujado; el Nano de mandos queda a 117 mm del techo de x1_y1. La carcasa no se ha tocado. No es un montaje.

No se han regenerado la carcasa, la tapa, los carros ni el retenedor. Esos cuatro STL siguen en el directorio y quedan **obsoletos**: no imprimir `PROVISIONAL_carro_nano`, `PROVISIONAL_carro_esp`, `PROVISIONAL_carro_proto30x70` ni `PROVISIONAL_retenedor_nano`.

[PENDIENTE] de esta bandeja: el largo real de los pines macho (el canal usa 11,5 mm más 1,5 mm); cuántos milímetros del canto corto y del canto largo están libres de pines (el canal usa 3,2 mm y deja 2,5 mm en el extremo); el módulo real del step-down y si lleva pines (43 × 21 mm, agujeros a 3,5 mm de la esquina y Ø3 son cifras típicas); el ESP de la foto (58 × 31, y si el micro-USB va centrado); el largo real de las clavijas; el HAT; y dónde se guarda la capturadora. El agarre del M3 en la guía Ø2,5 y el del inserto en el Ø4,0 no se han probado.

Fecha: 2026-10-18 (UTC+1). Fuentes comprobadas el 2026-10-18 salvo que se indique otra cosa.

## Bahía modular de la bandeja v1 (2026-10-21, sustituida)

Esta sección describe el riel suelto de la bandeja que Miguel ya tiene impresa. **La bandeja v2 lo deja fuera.** No imprimir `PROVISIONAL_riel_placas`: el archivo se ha retirado del directorio de STL. Lo que se imprime ahora está en «Bandeja v2», arriba.

Miguel pidió una bahía atornillada a los **dos tornillos que quedan a la izquierda de la canaleta** en la bandeja v1. El soporte del Nano de mandos (`PROVISIONAL_soporte_arduino`) se imprimió para esa bandeja. En la v2 la cuna va en la propia plancha y ese soporte no tiene donde atornillar.

### Qué tornillos son

En la bandeja hay cuatro familias de agujero junto a esa zona. Los que cuadran con la foto (a la izquierda del canal, sobre la plancha) son las dos torretas de la distribución DC que caen dentro de la pieza:

| Torreta | X | Y |
|---|---|---|
| Delantera | 401,26 | 146,492 |
| Trasera | 401,26 | 194,492 |

Salen de `psu_x + psu_w - 6` y de `psu_y + 6` / `psu_y + psu_d - 6`. No se mueven: son los agujeros impresos. Van separadas 48 mm en Y. La pared izquierda del canal está en x = 411,66, así que estas torretas quedan 10 mm a su izquierda. Cada una es un cilindro Ø8 y 4 mm de alto, con un agujero Ø4 abierto por arriba. El agujero del modelo mide unos 4 mm de fondo (la torreta es de 4 mm y el inserto de catálogo del CAD, 5,7 mm, no cabe). No es una rosca M3: un tornillo solo no agarra. Hace falta un inserto M3 corto. **PENDIENTE** de probarlo en la pieza impresa.

No son estos otros:

- Las torretas del soporte de mandos están en el **eje** del canal (x = 418,26), en y = 63 y y = 125, por delante de la boca (y = 143,5). El cable del Nano de mandos tiene que seguir en ese canal, y el soporte ya está en impresión.
- Los 4 M3 del ala sujetan la bandeja a la base. Usarlos dejaría la bandeja suelta.
- Las grapas del canal no son agujeros de tornillo.
- Las otras dos torretas DC (x = 303,26) quedan fuera de la bandeja. El STL las trae flotando y la guía de impresión dice que se borren en el laminador.

### Qué se imprime

Cuatro STL nuevos. OpenSCAD 2021.01, sin pasar `exportar.sh` (ese script borra los veinte anteriores). Cajas medidas en los vértices, igual que `comprobar_stl.py`.

| STL | Caja (mm) | Volumen | Cómo va en la cama |
|---|---|---|---|
| `PROVISIONAL_riel_placas` | 13,00 × 143,49 × 6,00 | 7,85 cm³ | El STL ya está boca abajo: los mortises contra la cama y el cajeado de las torretas abierto hacia arriba. No hace falta puentear ese cajeado |
| `PROVISIONAL_carro_nano` | 54,25 × 20,00 × 8,65 | 2,73 cm³ | Cama del carro abajo. El tetón (2 mm) queda en el aire: soporte solo ahí |
| `PROVISIONAL_carro_esp` | 57,55 × 27,40 × 8,65 | 3,81 cm³ | Igual |
| `PROVISIONAL_carro_proto30x70` | 79,25 × 32,00 × 8,65 | 6,14 cm³ | Igual. La placa de 30 × 70 es **DISEÑO**, no una placa medida |

El riel tiene dos tramos. El delantero (y = 58 a 130) mide 7,1 mm de ancho y acaba 0,9 mm antes del soporte de mandos. El de anclaje (desde y = 129,8 hasta y = 201,492, delante de la Pi en y = 214,492) es el que abraza las dos torretas: cajeado Ø8,4 (0,2 mm de holgura radial, **DISEÑO**) y 1,6 mm de pared. Su cara derecha queda a 3,2 mm de la pared del canal. La cabeza del M3 apoya encima; no hay avellanado, porque un cajeado Ø6,2 dejaba un techo de medio milímetro.

Cada carro lleva la placa hacia −X (el enchufe se aleja del canal y de la capturadora), un tetón que entra en el mortise y un tornillo M3 a un inserto del riel. La cabeza apoya en la pestaña. Bajo cada mortise el agujero del inserto tiene unos 3,3 mm de fondo: el inserto de 5,7 mm tampoco cabe ahí. **PENDIENTE.**

### Cuántas placas caben

Hay tres puestos, en y = 76, 90 y 105. A la vez caben **dos**, en el 76 y en el 105. El del medio solo sirve si no hay otro carro.

| Montaje | Qué lleva | Holgura entre carros |
|---|---|---|
| `nano_esp` (el del ensamblaje) | Nano de prácticas en y = 76 y ESP en y = 105 | 5,3 mm |
| `nano_proto` | El mismo Nano y el carro de 30 × 70 en y = 105 | 3,0 mm |
| ESP + proto | No entra: los dos usan el puesto 105 | — |
| Los tres a la vez | No | — |

El Nano de mandos no es un carro. Sigue en su soporte, con el cable en el canal que ya existe.

La reserva de la capturadora y la del adaptador siguen escritas como 72 mm en `params.scad`. La caja que se comprueba acaba en x = 395,46 (donde empieza el riel): **67,2 mm** útiles. Un aparato de 72 mm ya chocaría con las torretas Ø8 impresas, que empiezan en x = 397,26. No se ha medido la capturadora.

El carro de 30 × 70, con su margen de 1 mm por lado, acaba en x = 324,86. El suelo de la bandeja empieza en x = 322,56. Quedan **2,3 mm**. **PENDIENTE** con la placa real: si es más ancha, o si el cable sale por ese lado, no cabe.

`comprobar_interferencias.py` (2026-10-21): sin interferencias, 23 cajas, en `nano_esp` y en `nano_proto`. El carro del Nano queda a ≥ 3 mm de la tina. El tramo de anclaje queda a ≥ 3 mm del canal. `comprobar_stl.py`: las 24 mallas caben en la cama y están cerradas. Nada de esto se ha montado.

## 0c. HP v3: primeras medidas reales y capturadora (2026-10-18)

| Cambio | Detalle | Origen |
|---|---|---|
| Tamaño de la placa | 170 × 170 mm confirmado | **Medido por Miguel** (17 × 17 cm) |
| Altura de componentes | `hp_comp_h` 38 → **35 mm** (disipador + ventilador, lo más alto). Holgura a la tina de la pantalla ≈ **9 mm** (límite del modelo: 41 mm con 3 mm) | **Medido por Miguel** |
| Agujeros de anclaje | **Patrón estándar mini-ITX; coincide visualmente con los 4 tornillos de la foto, no medido.** Corregido el agujero F: está **22,86 mm más adentro** que C (33,02 mm del borde I/O); v2 lo ponía alineado con C. Cambia solo `PROVISIONAL_base_x0_y1` | Estándar mini-ITX (`datos-pendientes-hp.md` §A2, fuente 9) |
| I/O trasero | La placa **no tiene escudo I/O**. La ventana ya impresa no se toca. `PROVISIONAL_placa_io_hp` (2026-10-23) entra por dentro. Mirando la trasera, la foto del 2026-10-23 pone el VGA a la izquierda y el jack DC a la derecha (antes se había leído al revés). ±2 mm. La prueba se apoya por fuera antes de pegar | Foto de Miguel |
| Disposición de la placa | Marcador ilustrativo según la foto: 2 DDR3L paralelos al borde delantero, Wi-Fi M.2, disipador central (la altura total = 35 mm) | Foto (ilustrativo) |
| Capturadora (modo C) | **Reserva de 72 × 30 × 20 mm** en la bandeja de servicio, delante del hueco del adaptador (`usar_capturadora`, `captura`). Sin pieza nueva: velcro o brida. Cables ilustrativos del modo C | Diseño; medidas reales PENDIENTES |
| Envolvente | Sin cambios: 456,3 × 300,5 × 153,9 mm | — |

Comprobación de interferencias v3: **sin interferencias** (15 cajas, sin solapes); capturadora con holgura ≥ 10 mm. STL: 20 piezas que caben en la A1 y son mallas cerradas. Renders regenerados: `01b`, `02`, `03`, `04`, `05`, `05b` (los demás no cambian).

## 0b. HP v2: HP Slimline 260-a110ns desmontado (2026-10-18)

El HP de Miguel es un **HP Slimline 260-a110ns** (torre estrecha de ~307 × 100 × 275 mm según tiendas): **la caja no cabe en la cuña**, así que, por decisión de Miguel, **se desmonta** y en Orbit va un **módulo de placa desnuda**. Datos y fuentes: `datos-pendientes-hp.md` (datos del propietario 2026-10-18 + fichas HP de las placas hermanas Iris-E2/Iris-A8, **Mini ITX 17 × 17 cm**, entrada DC en el I/O trasero). Nota de seguridad del desmontaje: `datos-pendientes-hp.md` §B.

| Elemento | Modelado en CAD (`hp_preset = "iris_mitx_desnuda"`, por defecto) | Estado |
|---|---|---|
| Placa mini-ITX 170 × 170 | En horizontal, atrás a la izquierda (`hp_x` = 17 mm, borde trasero a 3 mm de la pared), componentes hacia arriba | Formato: fuente HP (hermanas) |
| Separadores | 4 torretas impresas en la base, Ø9, **6,35 mm** (estándar ATX), con inserto M3, en el **patrón estándar mini-ITX** (C a 6,35 mm del lateral y 10,16 mm del borde I/O; F a +157,48 / +22,86 mm; H y J a +154,94 mm) | v3: patrón estándar, coincide visualmente con la foto, **no medido** (H-2) |
| Altura de componentes | v3: caja de **35 mm** sobre la PCB (medido). El modelo admite **hasta 41 mm con 3 mm de holgura** a la tina de la pantalla (43 mm con 1 mm; 45 mm interfiere) | **Medido** (H-3) |
| Ventana I/O trasera | Abertura estándar de escudo I/O **158,75 × 44,45 mm** (+1 mm de holgura) a ras de la placa. `carcasa_x0_y1` ya está impresa: la abertura no se toca. Huecos de la placa: foto del 2026-10-23, VGA a la izquierda y DC a la derecha, ±2 mm | v3: **sin escudo**. Placa regenerada; el calibre sigue abierto (H-4) |
| Flujo de aire | **Entrada:** ranuras de la base bajo la placa y ranuras bajas del lateral izquierdo (zona trasera, hasta z ≈ 60 mm). **Salida:** rejilla superior trasera sobre la placa (el aire caliente sube). Se conserva el disipador/ventilador original | Sentido real del ventilador: **PENDIENTE** (H-5); térmica: U-20 |
| Disco | **SSD 2,5"** (100,45 × 69,85 × 9,5, SFF-8201) en un **soporte impreso** nuevo (`PROVISIONAL_soporte_disco`), a la derecha de la placa, sobre 4 torretas; la plancha queda 3 mm por encima de las torretas de empalme. **Opción HDD 3,5"** (`usar_hdd_35 = true`, 101,6 × 147 × 26,1, SFF-8301) en el mismo sitio, también sin interferencias | Agujeros de los discos: **PENDIENTE** (colisos en el soporte) |
| DVD | **Retirado**; no se modela | — |
| Fuente | **No hay fuente dentro**: adaptador externo 65 W 19,5 V al jack DC de la placa (`usar_distribucion = false`: desaparece la caja de distribución DC de v1) | Datos del propietario + HP |
| I/O frontal del HP | Ventana impresa 62 × 18 mm en el lateral izquierdo. A cuchillo queda **94 × 18 mm**, solo hacia el frente. `PROVISIONAL_marco_io_frontal` tapa el corte y sujeta la pestaña. La carcasa no se reimprime | Alto y ancho de la cara metálica: foto 2026-10-23. Agujeros de la pestaña: **PENDIENTE** (H-7) |
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
- Tornillería: la cuenta vigente está en el manual (`docs/manual_montaje/`), contra los tres kits. No hay prisioneros ni arandelas Ø9. El disco pide 4× 6-32 UNC × 1/4\", que no están en los kits.
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
5. **Potenciómetros:** atornillados con su tuerca desde fuera. Panel de 3 mm + refuerzo automático (`refuerzo_pot`, 1,5 mm con el genérico de 24 mm y 0 mm con el de 16 mm) para dejar ≥ 4,5 mm de rosca libre. Hueco anti-giro ciego a `pot_antigiro_r` (**PENDIENTE**). Los pomos llevan agujero de 6 mm, plano en D opcional (`pomo_eje_D`) e inserto M3 4×5 radial con un M3×12 de cabeza de botón. Con eje estriado, si ese tornillo no frena, conviene un pomo comercial.
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
| HP real (HP Slimline 260-a110ns), placa mini-ITX desnuda | 170 × 170; separadores 6,35; patrón C-F-H-J estándar (157,48 / 154,94; F +22,86) | Formato: **medido** (17 × 17 cm, Miguel, 2026-10-18); patrón: estándar mini-ITX, coincide visualmente con la foto, **no medido**; separadores: estándar ATX | `datos-pendientes-hp.md` §A2 |
| Altura de componentes de la placa HP | 35 (máx. 41 con 3 mm de holgura) | **Medido** (Miguel, 2026-10-18) | H-3 |
| SSD 2,5" / HDD 3,5" (opción) | 100,45 × 69,85 × 9,5 / 101,6 × 147 × 26,1 | **Con fuente** (SFF-8201 / SFF-8301, formatos estándar) | `usar_hdd_35` |
| I/O frontal HP, pulsador Ø12 + LED 3 mm | Corte 94 × 18 (desde la ventana impresa de 62 × 18, solo hacia el frente). Marco 100,4 × 32 × 7,5 | Foto 2026-10-23. Agujeros de la pestaña sin medir | H-6, H-7 |
| Adaptador HDMI→USB-C (hueco, modo B) | 72 × 32 × 16 | **PENDIENTE** (modelo sin verificar) | `adap_video` |
| Capturadora HDMI→USB (reserva, modo C) | 72 × 30 × 20 | **Reserva de diseño**; medidas del aparato **PENDIENTES** | `captura` |
| HP, ventana I/O trasera | 159,75 × 45,45, sin agrandar. Placa 171,75 × 55,95 × 2,80 (15,71 cm³) y prueba 159,75 × 45,45 × 1,40 (3,52 cm³) | Abertura: estándar ATX. Huecos: foto 2026-10-23, ±2 mm (H-4) | `hp_io_*`, `io_huecos` |
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

Resultados del 2026-10-18 (configuración por defecto, HP v3):

| Elemento | Resultado | Holgura mínima (mayor margen probado sin colisión) |
|---|---|---|
| Placa HP + RAM/disipador (35 mm sobre la PCB, medido) | OK | ≥ 3 mm (limita una orejeta); tina: ≈ 9 mm (≥ 3 mm hasta 41 mm de componentes) |
| Placa HP, zona I/O trasera | OK | ≥ 1 mm a la pared trasera (intencionado: los conectores asoman por la ventana) |
| SSD 2,5" + soporte | OK | ≥ 5 mm (limita una torreta de empalme) |
| I/O frontal HP / pulsador HP (lateral izq.) | OK | 0 mm a la pared (van montados en ella) |
| Adaptador HDMI→USB-C (hueco) | OK | ≥ 10 mm |
| Capturadora HDMI→USB (reserva) | OK | ≥ 10 mm |
| Raspberry Pi | OK | ≥ 3 mm (limita el canal USB) |
| Arduino Micro + soporte | OK | ≥ 10 mm |
| Clavija micro-USB | OK | ≥ 10 mm |
| Clavija USB-A en la Pi | OK | ≥ 5 mm (limita la pared) |
| Potenciómetros (×2) | OK | 16,5 mm a la pared lateral; 57–86 mm sobre el suelo |
| Pulsadores (×2) | OK | ≥ 4,5 mm a la pared lateral; 36 mm sobre el suelo |
| Bandeja + ala frente a orejetas | OK | 0 solapes |
| Soporte del Arduino frente a la abertura de la bandeja | OK | — |
| Panel de conectores (x = 241–318 mm) | OK | Pi a partir de x = 328 |
| Solapes por pares (15 cajas) | Ninguno | — |
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

- Componentes de la placa HP frente a la tina: ≈ 9 mm con los 35 mm medidos (la caja envolvente ocupa toda la placa a 35 mm: conservador).
- Canal USB frente a la Pi: unos 3 mm.
- Pulsador exterior frente a la pared derecha: unos 4,5 mm.
- Conectores traseros del HP (sin escudo I/O): a ras por dentro de la pared de 3 mm; comprobar que las clavijas (HDMI, DC, RJ45, USB) entran hasta el fondo a través de 3 mm de PETG (PENDIENTE; si no, rebajar la pared alrededor de la ventana).

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

1. ~~Identificar el HP real~~ → HP Slimline 260-a110ns, desmontado (§0b). ~~Tamaño y altura~~ medidos (§0c). Falta: posición real de los agujeros (H-2), **calibre de cada conector trasero para corregir `io_huecos`** (H-4; la placa ya está modelada desde la foto), `io_frontal`, `boton_hp_*` (H-6, H-7) y antenas Wi-Fi (H-9).
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
6. **Vídeo:** modo C recomendado (capturadora en la bandeja: reserva de 72 × 30 × 20 mm, medidas reales **PENDIENTES**), modo A (visor remoto, sin cambios mecánicos) o modo B, poco probable (hueco de 72 × 32 × 16 mm para el adaptador).
7. Medidas reales de la **distribución DC** y de los **prolongadores de panel**. Ajustar los huecos traseros.
8. **Térmica:** con la placa desnuda, comprobar el sentido del ventilador del disipador, medir temperaturas abierta y cerrada y, si hace falta, añadir un ventilador de extracción en la rejilla trasera (alimentación y modelo PENDIENTES).
9. **Rigidez:** el hueco de la pantalla y ahora las aberturas del tramo de puertos debilitan la pendiente. Revisar si flexa una vez impresa y quizá añadir nervios.
10. Juntas visibles de los cortes: decidir el acabado.
11. Pies de goma, burlete del bisel, tolerancias con la **A1 y el PETG reales** y calibración de los insertos.
12. Seguridad eléctrica: **no se diseña ningún circuito de red**. Toda la alimentación es por fuentes externas homologadas. Batería: solo como estudio futuro.
13. **Impresión de prueba de una esquina** (por ejemplo la consola con un potenciómetro y un pulsador) antes de imprimir el conjunto.
14. Preset `waveshare_12_3`: sin mantener en v1 (interfiere).

> **Recordatorio: NO APTO PARA FABRICACIÓN.** Diseño v1 provisional; todas las comprobaciones son simulaciones geométricas.
