# Orbit Terminal · siguientes impresiones (después de la base)

**20/10/2026. Prototipo. Ninguna pieza está lista para fabricar.** Sirven para comprobar medidas y encajes. Nada de esto se ha impreso ni montado todavía, salvo lo que se indica.

Origen de la lista: repo `Sopa-IA/Control-deck`, rama `main`, commit `3978879` (PR #6). Impresora: Bambu Lab A1 (cama 256 × 256). PETG, relleno 15-20 %.

Los STL **no se duplican** en esta carpeta. Cada pieza apunta al STL que ya está en el repo. Los STEP numerados están en [`STEP/`](STEP/).

## Qué hay, y dónde está en el repo

| En el paquete de origen | En el repo |
|---|---|
| `STL/01_` … `15_` | No se copian. Rutas de abajo, todas desde la raíz del repo |
| `STEP_SolidWorks/` | [`STEP/`](STEP/) (AP214, FreeCAD 1.0, 2026-10-20) |
| `BASE_ya_impresa/` (STL) | Los STL de la base ya están en `hardware/cad/export/stl/` y `hardware/impresion/base/`. No hay que reimprimirlos |
| `BASE_ya_impresa/` (STEP) | [`../base/STEP/`](../base/STEP/) |
| `SCAD_fuente/` | No es una copia. La referencia es [`hardware/cad/`](../../cad/) |
| `MANUAL_MONTAJE_ORBIT.pdf` | [`docs/manual-montaje/MANUAL_MONTAJE_ORBIT.pdf`](../../../docs/manual-montaje/MANUAL_MONTAJE_ORBIT.pdf) (21 páginas, estilo IKEA: inventario, tornillería, 16 pasos y pendientes). Dibujos generados del CAD, no fotos |
| Vistas | [`vista_siguientes_conjunto.png`](vista_siguientes_conjunto.png) (en naranja lo que toca imprimir ahora) y [`vista_01_plantilla_pivotes.png`](vista_01_plantilla_pivotes.png). La misma vista de pivotes está también en `hardware/impresion/plantillas/vista_pivotes.png` |

Prefijos: `PRUEBA_` = pieza solo para probar un ajuste. `PROVISIONAL_` = pieza del diseño que depende de medidas sin verificar. Lo que termina en `_x2` se imprime 2 veces.

Datos de cada pieza: medidas = caja del STL tal como viene (ancho × fondo × alto, mm). Volumen = volumen del sólido en cm³. No es el consumo del slicer: no se ha laminado nada, así que no hay tiempos ni gramos. «Voladizo» = superficie que cuelga más de 45°, calculada sobre la malla; es orientativa, el slicer manda.

## Orden y piezas

### 01 · `PRUEBA_plantilla_pivotes_HP` · prueba, pendiente de resultado

Pivotes en vez de tornillos, uno por agujero de la placa HP. Diámetros: **C 3,8 / F 3,6 / H 3,4 / J 3,2 mm**. Sirve para elegir el diámetro antes de cambiar los separadores de la base. No se monta: se apoya la placa encima.

- STL: [`hardware/impresion/plantillas/PRUEBA_plantilla_pivotes_HP.stl`](../plantillas/PRUEBA_plantilla_pivotes_HP.stl)
- SCAD: [`hardware/impresion/plantillas/plantilla_pivotes.scad`](../plantillas/plantilla_pivotes.scad)
- STEP: [`STEP/01_PRUEBA_plantilla_pivotes_HP.step`](STEP/01_PRUEBA_plantilla_pivotes_HP.step)
- Medidas: 164,5 × 161,9 × 7,6. Volumen 8,4 cm³.
- Cama: tal cual viene (barras abajo, pivotes hacia arriba). Soportes: no (voladizo 0).
- Comprueba qué pivote entra justo, sin holgura ni forzar. Hasta entonces la base sigue con insertos M3. **Aún no hay resultado.**

### 02 · `PROVISIONAL_bandeja_servicio` · provisional · reimprimir (bandeja v2)

La bandeja v1 ya está impresa. Esta la sustituye. El hueco de la base y los 4 M3 no se mueven (centros x = 318,26 y 436,26; y = 49 y 278,492). La base no se reimprime.

La Pi queda en la mitad izquierda, con los USB y el RJ45 hacia la trasera. La cuna del Nano de mandos va en la plancha (el soporte suelto de la v1 no encaja). Delante de la Pi hay un riel para dos carros. Una canaleta en x = 420 sube el mini-USB hasta los USB de la Pi sin salir de la bandeja.

- STL: [`hardware/cad/export/stl/PROVISIONAL_bandeja_servicio.stl`](../../cad/export/stl/PROVISIONAL_bandeja_servicio.stl) · regenerado el 2026-10-22
- STEP: [`STEP/02_PROVISIONAL_bandeja_servicio.step`](STEP/02_PROVISIONAL_bandeja_servicio.step) · **desfasado**, sigue siendo la v1
- Medidas: 126,00 × 237,49 × 30,20. Volumen 167,53 cm³.
- Cama: plancha abajo. La cuna llega a 30 mm: revisar soportes en el laminador. Las ranuras bajo la Pi no piden soporte. Ya no trae las dos torretas sueltas de la distribución DC.
- Cada puesto de carro (y = 90 y y = 124) lleva un cajeado y dos guías Ø2,5 × 5,2 mm. El carro trae paso libre Ø3,4. Tornillo M3×10 de cabeza cilíndrica, dos por carro. No lleva insertos. Los 4 M3 del ala, a la base, no cambian.
- Comprueba que entra por el hueco, que los 4 M3 caen en las torretas de la base y que los cuatro separadores de la Pi coinciden con la placa girada.

### 03 · `PROVISIONAL_carcasa_x0_y1` (detrás-izquierda) · provisional

Trozo trasero izquierdo de la cuña: ventana I/O del HP, pasacables, I/O frontal en el lateral izquierdo, pulsador y LED. **Ya está impresa. No se reimprime.** La placa I/O entra por esa ventana desde dentro.

- STL: [`hardware/cad/export/stl/PROVISIONAL_carcasa_x0_y1.stl`](../../cad/export/stl/PROVISIONAL_carcasa_x0_y1.stl)
- STEP: [`STEP/03_PROVISIONAL_carcasa_x0_y1.step`](STEP/03_PROVISIONAL_carcasa_x0_y1.step) · origen **malla**
- Medidas: 228,1 × 150,2 × 150,9. Volumen 213,7 cm³ (la más grande de este grupo).
- Cama: no como viene (tocaría la cama con 1 cm²). Cara del corte delantero (la que se une con 04) sobre la cama. Queda de 150 mm de alto: 221 cm² de apoyo y 73 cm² de voladizo. Soportes: sí (en árbol, mejor solo desde la cama).
- Depende de la posición real de los conectores del HP, del I/O frontal y del pulsador (pendiente).
- Comprueba los puertos del HP frente a la ventana, las orejetas sobre los agujeros avellanados de la base y cómo se ve la cara de corte (es la que se pega).

### 04 · `PROVISIONAL_carcasa_x0_y0` (delante-izquierda) · provisional

Trozo delantero izquierdo: frente con el carril de la luz y parte de la pendiente de la pantalla.

- STL: [`hardware/cad/export/stl/PROVISIONAL_carcasa_x0_y0.stl`](../../cad/export/stl/PROVISIONAL_carcasa_x0_y0.stl)
- STEP: [`STEP/04_PROVISIONAL_carcasa_x0_y0.step`](STEP/04_PROVISIONAL_carcasa_x0_y0.step) · origen **malla**
- Medidas: 228,1 × 150,2 × 95,4. Volumen 104,7 cm³.
- Cama: cara del corte trasero (la que se une con 03) sobre la cama, 150 mm de alto: 17 cm² de apoyo, 69 cm² de voladizo. Alternativa con menos voladizo (46 cm²): cara del corte lateral (la que toca 05) sobre la cama, pero queda de 228 mm de alto. Soportes: sí.
- Comprueba la unión con 03 (pasadores Ø3 × 16) y con la base.

### 05 · `PROVISIONAL_carcasa_x1_y0` (delante-derecha) · provisional

Trozo delantero derecho: frente, un potenciómetro y los 2 pulsadores.

- STL: [`hardware/cad/export/stl/PROVISIONAL_carcasa_x1_y0.stl`](../../cad/export/stl/PROVISIONAL_carcasa_x1_y0.stl)
- STEP: [`STEP/05_PROVISIONAL_carcasa_x1_y0.step`](STEP/05_PROVISIONAL_carcasa_x1_y0.step) · origen **malla, con defecto**
- Medidas: 228,1 × 150,2 × 95,4. Volumen 115,5 cm³.
- Cama: cara del corte trasero sobre la cama, 150 mm de alto: 17 cm² de apoyo, 60 cm² de voladizo (alternativa: corte lateral abajo, 228 mm de alto, 36 cm²). Soportes: sí.
- Depende del tamaño real de potenciómetros y pulsadores (CAD genérico 24 / 16 mm).
- Comprueba que el potenciómetro y los pulsadores entran en sus agujeros.
- **12 triángulos cruzados.** FreeCAD marca este STEP como no válido: en la STL hay 12 triángulos que se cruzan en el plano x ≈ 406,3 mm (y ≈ 138-143, z ≈ 88-91), junto al potenciómetro delantero. La caja y el volumen coinciden con la STL. Si SolidWorks se queja, usar «Diagnóstico de importación». El CAD no se ha tocado para corregirlo.

### 06 · `PROVISIONAL_carcasa_x1_y1` (detrás-derecha) · provisional

Trozo trasero derecho: el otro potenciómetro, rejilla sobre la Pi, el panel de conectores de Orbit (audio, 2 USB-A, 2 USB-C, 2 HDMI, RJ45, DC) y, desde el 2026-10-20, el panel de prácticas (pines del Nano, previsión de GPIO de la Pi, ventana OLED y hueco USB rotulado PRG).

- STL: [`hardware/cad/export/stl/PROVISIONAL_carcasa_x1_y1.stl`](../../cad/export/stl/PROVISIONAL_carcasa_x1_y1.stl) · **regenerado el 2026-10-22** (guías autorroscantes). Si había una copia anterior en la cola de impresión, no vale.
- STEP: [`STEP/06_PROVISIONAL_carcasa_x1_y1.step`](STEP/06_PROVISIONAL_carcasa_x1_y1.step) · origen **malla**, **desfasado**: no incluye la tapa ni el panel
- Medidas: 228,13 × 150,25 × 150,93. Volumen 233,81 cm³ (antes 233,65, con agujeros de inserto).
- Cama: cara del corte delantero sobre la cama, 150 mm de alto. Soportes: sí. El hueco de la tapa está en el lomo, que queda arriba en esa orientación.
- La tapa es otra pieza (`PROVISIONAL_tapa_pi`, 94,00 × 54,00 × 2,40, 9,70 cm³). Sus dos agujeros siguen siendo paso libre Ø3,4. En la carcasa, cada poste Ø10 lleva una guía Ø2,5 × 9 mm: tornillo M3×10 de cabeza cilíndrica. Las tres orejetas de esta pieza llevan la misma guía y un M3×10 avellanado desde la base. Las otras tres carcasas no se regeneran.
- La tapa trae ranuras de salida. El panel de pines y la OLED no se han cortado. La rejilla de la pared trasera sigue alineada con la Pi y baja hasta z ≈ 90.
- Comprueba que el hueco cae sobre los USB de la Pi y que se puede pasar una clavija USB-A con la tapa quitada.

### 07 a 10 · biseles · provisional

Marco de la pantalla en 4 trozos. Sujeta el monitor MSI en su cuna. Cada trozo lleva 3 tornillos M3 avellanados a insertos de la carcasa.

| Nº | STL | STEP |
|---|---|---|
| 07 `x0_y0` | [`PROVISIONAL_bisel_x0_y0.stl`](../../cad/export/stl/PROVISIONAL_bisel_x0_y0.stl) | [`07_…step`](STEP/07_PROVISIONAL_bisel_x0_y0.step) |
| 08 `x0_y1` | [`PROVISIONAL_bisel_x0_y1.stl`](../../cad/export/stl/PROVISIONAL_bisel_x0_y1.stl) | [`08_…step`](STEP/08_PROVISIONAL_bisel_x0_y1.step) |
| 09 `x1_y0` | [`PROVISIONAL_bisel_x1_y0.stl`](../../cad/export/stl/PROVISIONAL_bisel_x1_y0.stl) | [`09_…step`](STEP/09_PROVISIONAL_bisel_x1_y0.step) |
| 10 `x1_y1` | [`PROVISIONAL_bisel_x1_y1.stl`](../../cad/export/stl/PROVISIONAL_bisel_x1_y1.stl) | [`10_…step`](STEP/10_PROVISIONAL_bisel_x1_y1.step) |

Los cuatro STEP son de origen **malla**. Medidas: 190,8 × 126,6 × 3,6 cada uno. Volumen 24,9 cm³ (el `x1_y1`, 22,8). Cama: tal cual (ya vienen con la cara vista abajo). Soportes: no (voladizo 0). Depende de la posición del área activa del MSI (el CAD la supone centrada) y de las teclas OSD del canto derecho. Comprueba que la ventana enseña toda la imagen y que la muesca cae sobre las teclas. Conviene imprimir antes uno solo para ver la ventana.

### 11 y 12 · guías de luz · provisional

Los 2 tramos de la tira de luz del frente, con el carril para la tira LED. Mejor en PETG translúcido.

- STL: [`PROVISIONAL_guia_luz_frontal_0.stl`](../../cad/export/stl/PROVISIONAL_guia_luz_frontal_0.stl) y [`PROVISIONAL_guia_luz_frontal_1.stl`](../../cad/export/stl/PROVISIONAL_guia_luz_frontal_1.stl)
- STEP: [`11_…step`](STEP/11_PROVISIONAL_guia_luz_frontal_0.step) y [`12_…step`](STEP/12_PROVISIONAL_guia_luz_frontal_1.step) · origen sólido (CSG)
- Medidas: 201,1 × 9,0 × 7,0 cada uno. Volumen 9,8 cm³.
- Cama: darle la vuelta (boca abajo): pasa de 8,8 a 0,8 cm² de voladizo. Soportes: no.
- El canal es de 10,4 mm, pensado para una tira de 10 mm. El tipo de tira sigue sin identificar.
- Comprueba que la tira entra en el canal y que los 2 tramos encajan en el frente.

### 13 · `PROVISIONAL_anillo_luz_x2` · provisional (imprimir 2)

Anillo de luz bajo cada pomo (PETG translúcido). Entra por dentro del panel.

- STL: [`hardware/cad/export/stl/PROVISIONAL_anillo_luz_x2.stl`](../../cad/export/stl/PROVISIONAL_anillo_luz_x2.stl)
- STEP: [`STEP/13_PROVISIONAL_anillo_luz_x2.step`](STEP/13_PROVISIONAL_anillo_luz_x2.step) · origen sólido (CSG)
- Medidas: 41,0 × 41,0 × 5,6. Volumen 1,8 cm³.
- Cama: tal cual. Soportes: no (voladizo 0).
- Comprueba que entra en la ranura anular del panel.

### 14 · `PROVISIONAL_pomo_x2` · provisional (imprimir 2) · ya lanzado antes

Ya se imprimió o estaba en cola. Se repite solo si no encaja. Pomo Ø30 moleteado para eje de 6 mm, con prisionero M3 lateral.

- STL: [`hardware/cad/export/stl/PROVISIONAL_pomo_x2.stl`](../../cad/export/stl/PROVISIONAL_pomo_x2.stl)
- STEP: [`STEP/14_PROVISIONAL_pomo_x2.step`](STEP/14_PROVISIONAL_pomo_x2.step) · origen sólido (CSG)
- Medidas: 30,0 × 30,0 × 17,0. Volumen 11,0 cm³.
- Cama: tal cual (tapa abajo). Soportes: no (voladizo 0,3 cm²).
- Comprueba el eje de 6 mm (liso o en D) y el prisionero. Sin resultado comunicado.

### 15 · `PROVISIONAL_soporte_arduino` · de la bandeja v1 · no montar en la v2

Pieza de la bandeja ya impresa (tornillos en y = 63 y y = 125). El STL no se ha vuelto a exportar (26,00 × 70,00 × 19,10, 9,58 cm³). La bandeja v2 lleva la cuna en la plancha y no tiene esas torretas: este soporte no se atornilla ahí.

### 16 · `PROVISIONAL_retenedor_nano` · provisional

Clip del Nano de mandos. Engancha los rebordes de la cuna, pisa las cuatro esquinas de la PCB y lleva un tope sobre el mini-USB. No tapa los pines.

- STL: [`hardware/cad/export/stl/PROVISIONAL_retenedor_nano.stl`](../../cad/export/stl/PROVISIONAL_retenedor_nano.stl)
- Medidas: 29,40 × 51,20 × 10,40. Volumen 1,38 cm³.
- Cama: tal cual (la cara baja ya está en z = 0).
- El riel suelto `PROVISIONAL_riel_placas` ya no está en el directorio. No imprimirlo si queda una copia antigua.

### 17 · `PROVISIONAL_carro_nano` · provisional

Carro del Nano de prácticas. Puesto y = 90. El mini-USB mira a +X. Pines hacia abajo, uñas en las esquinas y pestaña sobre el conector. La zapata entra en el cajeado y se aprieta con dos M3.

- STL: [`hardware/cad/export/stl/PROVISIONAL_carro_nano.stl`](../../cad/export/stl/PROVISIONAL_carro_nano.stl)
- Medidas: 51,45 × 16,40 × 25,10. Volumen 6,54 cm³.
- Cama: la base del carro abajo. Va a la vez que el del ESP o el de la proto, no con los dos.

### 18 · `PROVISIONAL_carro_esp` · provisional

Carro del ESP8266 de la tira. Puesto y = 124. Cuatro columnas en los agujeros de esquina. No a la vez que la proto.

- STL: [`hardware/cad/export/stl/PROVISIONAL_carro_esp.stl`](../../cad/export/stl/PROVISIONAL_carro_esp.stl)
- Medidas: 64,45 × 29,60 × 25,10. Volumen 3,94 cm³. Dos M3, los mismos agujeros que la proto.
- La placa de la foto se estima en 58 × 31 mm. **PENDIENTE** de medir: si es otra, las columnas no coinciden.

### 19 · `PROVISIONAL_carro_proto30x70` · provisional

Carro de una protoboard de 30 × 70 mm. Medida de diseño, no de una placa medida. Mismo puesto que el ESP.

- STL: [`hardware/cad/export/stl/PROVISIONAL_carro_proto30x70.stl`](../../cad/export/stl/PROVISIONAL_carro_proto30x70.stl)
- Medidas: 76,45 × 28,40 × 25,10. Volumen 10,79 cm³. Se cambia por el ESP soltando los dos M3 del puesto y = 124.
- El extremo de 70 mm queda a unos 3 mm del retenedor del Nano de mandos. **PENDIENTE** medir la placa.

### 20 · `PROVISIONAL_tapa_pi` · provisional

Tapa del hueco del techo, encima de los USB y el RJ45. Dos tornillos M3×10 a las guías Ø2,5 de `carcasa_x1_y1`. El paso de la tapa sigue en Ø3,4.

- STL: [`hardware/cad/export/stl/PROVISIONAL_tapa_pi.stl`](../../cad/export/stl/PROVISIONAL_tapa_pi.stl)
- Medidas: 94,00 × 54,00 × 2,40. Volumen 9,70 cm³.
- Cama: plana. El hueco que tapa mide 72 × 42 mm. Lleva ranuras de salida y agujeros para un ventilador opcional de 30 × 30 o 40 × 40.

### Placa I/O del HP · `PROVISIONAL_placa_io_hp` y `PRUEBA_placa_io_hp` · provisional

Cierra el hueco de la ventana de la pieza 03, que ya está impresa. Entra por dentro: reborde de 6 mm (4,5 mm abajo, porque hasta el suelo hay 5,2 mm) y tetón 0,4 mm más pequeño que la ventana por lado. Chapa 1,4 mm, pila 2,8 mm. Sin tornillo. Cama: reborde abajo, sin soportes.

Los huecos son una estimación de la foto del 2026-10-22, marcados [PENDIENTE] en `io_huecos`. La prueba es el marco de la ventana (159,75 × 45,45). Se apoya por fuera, con el hueco de la esquina en el extremo inferior izquierdo, y se mira qué conector no entra.

- STL: [`hardware/cad/export/stl/PROVISIONAL_placa_io_hp.stl`](../../cad/export/stl/PROVISIONAL_placa_io_hp.stl) · 171,75 × 55,95 × 2,80 mm · 16,81 cm³
- Prueba: [`hardware/cad/export/stl/PRUEBA_placa_io_hp.stl`](../../cad/export/stl/PRUEBA_placa_io_hp.stl) · 159,75 × 45,45 × 1,40 mm · 3,36 cm³
- Qué medir, y contra qué borde: `docs/datos-pendientes-hp.md`, H-4.

## Lo que no existe en el repo

- Marco o soporte del monitor aparte: el MSI va en una cuna dentro de la carcasa y lo sujeta el bisel (07-10).
- Soporte de la Pi aparte: va en la bandeja (02).
- Panel de control aparte: los agujeros de los mandos están en la carcasa (05 y 06).
- Tapa de los USB de la Pi: `PROVISIONAL_tapa_pi` (pieza 20). La bandeja (02) sigue siendo la tapa de servicio de abajo.
- Escudo metálico de I/O del HP: no hay. La pieza impresa es `PROVISIONAL_placa_io_hp`; la ventana sigue en la carcasa (03), ya impresa.
- Todo cabe en la cama de 256 mm con las divisiones que ya trae el CAD.

## STEP para SolidWorks

Hechos con FreeCAD 1.0 (sin interfaz), esquema AP214. La tabla de la comprobación está en [`STEP/COMPROBACION_STEP.txt`](STEP/COMPROBACION_STEP.txt): cada STEP se reabrió, se miró si el sólido es válido y se comparó su caja con la de la STL (diferencia máxima 0,001 mm) y el volumen (diferencia ≤ 0,01 cm³). En este cambio no se ha vuelto a pasar FreeCAD: solo se ha comprobado que los 23 archivos siguen siendo texto AP214 generado por FreeCAD.

Dos orígenes, y no se editan igual:

- **Sólido de verdad** (desde el código OpenSCAD, importador CSG): 01 plantilla de pivotes, 02 bandeja, 11-12 guías, 13 anillo, 14 pomo, 15 soporte Arduino. En la base: plantilla de agujeros, pletina y soporte del disco ([`../base/STEP/`](../base/STEP/)). Caras planas y agujeros como cilindros reales. Las esquinas redondeadas salen facetadas (OpenSCAD las hace con polígonos). La bandeja trae 3 cuerpos (los 2 de más son las torretas sueltas).
- **STEP de malla: se editan peor en SolidWorks.** Son 03-06 (carcasa) y 07-10 (bisel). En la base: las 4 bases y la pared I/O. El importador no pudo con esas piezas y salen de la STL: triángulos unidos en caras planas grandes, pero los agujeros y las curvas son polígonos. Se pueden medir, cortar y añadir operaciones. No se puede cambiar un diámetro de agujero como si fuera un cilindro.
- **`05_PROVISIONAL_carcasa_x1_y0.step` es un STEP de malla con defecto.** FreeCAD lo marca como no válido por **12 triángulos cruzados** en la STL, en el plano x ≈ 406,3 mm (y ≈ 138-143, z ≈ 88-91), junto al potenciómetro delantero. La caja y el volumen coinciden con la STL. Si SolidWorks se queja, usar «Diagnóstico de importación».

Para cambiar medidas de verdad, la referencia es `hardware/cad/params.scad`, no estos STEP. El 2026-10-22 se regeneraron la bandeja v2 y `carcasa_x1_y1`: las guías de los carros, de los postes de la tapa y de las orejetas de esa pieza pasan a Ø2,5 (`fijacion = "autorroscante"`). Los carros, la tapa, las otras tres carcasas, la base, el soporte y los biseles no se han vuelto a exportar. Los STEP y el manual PDF tampoco. Ese mismo día se añadieron `PROVISIONAL_placa_io_hp` y `PRUEBA_placa_io_hp`; `carcasa_x0_y1` no se ha vuelto a generar.

Ejemplo para regenerar una pieza (no ejecutado aquí):

```bash
openscad -o carcasa.stl -D 'parte="carcasa"' -D ix=0 -D iy=1 hardware/cad/partes.scad
```

Todas: `hardware/cad/exportar.sh`. Plantillas: `hardware/impresion/plantillas/*.scad`. Pared: `hardware/impresion/base/prueba_pared_trasera_io.scad` (hace `include` de `../../cad/piezas.scad`).

## Tamaño en git

No hay `.gitattributes` en el repo: ningún filtro toca estos archivos. El STEP más grande es `06_PROVISIONAL_carcasa_x1_y1.step` (3,6 MB). La carpeta `siguientes` pesa unos 15 MB y el conjunto de STEP más el PDF, unos 23 MB. GitHub avisa a partir de 50 MB por archivo y rechaza a partir de 100 MB, así que no hace falta Git LFS. Los STEP son texto ASCII con finales LF (líneas de 72 caracteres). En este entorno `core.autocrlf` no está activo.
