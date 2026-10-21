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

### 02 · `PROVISIONAL_bandeja_servicio` · provisional

Si ya se imprimió con la base como pieza opcional, se salta.

Bandeja que entra por debajo en el hueco de la base. Lleva la Raspberry Pi (separadores M2.5, patrón 58 × 49), las torretas del soporte del Arduino (y = 63 y y = 125) y el canal del cable USB (boca en y = 143,5, ancho 10 mm). Va en el hueco de la derecha (bases x1), atornillada desde abajo con 4 M3.

**2026-10-20: esta pieza ya está impresa** (Miguel). El STL del repo **no se ha regenerado**: torretas, canal y contorno siguen donde estaban. El 2026-10-21 el ESP y el Nano de prácticas dejan de ir con velcro: se atornillan, con sus carros, a las dos torretas DC que esta bandeja ya trae a la izquierda del canal (x = 401,26; y = 146,492 y y = 194,492). No hay taladros nuevos. El canal se diseñó para un micro-USB; el Nano de mandos lleva mini-USB y queda unos 3 mm más lejos de la boca. Si el tapón del cable mini-USB pasa por los 10 mm es **PENDIENTE**.

- STL: [`hardware/cad/export/stl/PROVISIONAL_bandeja_servicio.stl`](../../cad/export/stl/PROVISIONAL_bandeja_servicio.stl)
- STEP: [`STEP/02_PROVISIONAL_bandeja_servicio.step`](STEP/02_PROVISIONAL_bandeja_servicio.step)
- Medidas: 141,0 × 237,5 × 14,0. Volumen 154,1 cm³.
- Cama: tal cual (plancha abajo). Soportes: no hacen falta (voladizo 1,3 cm²).
- La STL tiene 2 torretas sueltas (8 × 8 × 4 mm, en x ≈ 299-307) fuera de la bandeja y flotando a 4 mm de la cama: son de la «distribución DC», que no se usa. En Bambu Studio: Dividir en objetos y eliminar las 2 pequeñas. El CAD no se ha corregido en este cambio.
- Depende del modelo de la Pi (sin confirmar; el CAD dibuja una Pi 4).
- Comprueba que entra por el hueco de abajo, que los 4 agujeros de la Pi coinciden y que los 4 agujeros M3 del ala caen en las torretas de la base.

### 03 · `PROVISIONAL_carcasa_x0_y1` (detrás-izquierda) · provisional

Trozo trasero izquierdo de la cuña: ventana I/O del HP, pasacables, I/O frontal en el lateral izquierdo, pulsador y LED. Es la primera de la carcasa porque es la que más depende del HP. Se imprime después de probar la pared I/O de la base; si la ventana no cuadra, se corrige antes.

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

- STL: [`hardware/cad/export/stl/PROVISIONAL_carcasa_x1_y1.stl`](../../cad/export/stl/PROVISIONAL_carcasa_x1_y1.stl) · **regenerado el 2026-10-20** (OpenSCAD 2021.01)
- STEP: [`STEP/06_PROVISIONAL_carcasa_x1_y1.step`](STEP/06_PROVISIONAL_carcasa_x1_y1.step) · origen **malla**, **desfasado**: no se ha vuelto a generar y no incluye el panel de prácticas
- Medidas del STL nuevo: 228,13 × 150,25 × 150,93. Volumen 242,11 cm³ (antes 243,84: los huecos del panel).
- Cama: cara del corte delantero sobre la cama, 150 mm de alto: 304 cm² de apoyo, 70 cm² de voladizo. Soportes: sí.
- Los huecos del panel son orientativos (prolongadores no elegidos).
- Comprueba la holgura del potenciómetro, los huecos del panel y la rejilla sobre la Pi.

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

### 15 · `PROVISIONAL_soporte_arduino` · provisional · ya pasado a imprimir

El asiento anterior era el del Micro (48 × 17,7). El de ahora es el del Nano de catálogo (45 × 18). Los tornillos siguen a 70 mm, en las torretas de la bandeja impresa (x = 418,26; y = 63 y y = 125). Si el soporte del Micro llegó a salir de la impresora, no vale para el Nano: se imprime este. **El 2026-10-21 este STL no se ha modificado.** Miguel ya lo tiene para imprimir. No es un carro de la bahía: el cable de mandos sigue en el canal.

- STL: [`hardware/cad/export/stl/PROVISIONAL_soporte_arduino.stl`](../../cad/export/stl/PROVISIONAL_soporte_arduino.stl) · **regenerado el 2026-10-20**
- STEP: [`STEP/15_PROVISIONAL_soporte_arduino.step`](STEP/15_PROVISIONAL_soporte_arduino.step) · origen sólido (CSG), **desfasado**: sigue siendo el del Micro
- Medidas del STL nuevo: 26,00 × 70,00 × 19,10. Volumen 9,58 cm³ (antes 25,70 × 70,00 × 19,10 y 9,52 cm³).
- Cama: tal cual. El voladizo del STL anterior no se ha vuelto a calcular.
- Comprueba que el Nano entra y que el mini-USB sale por la ranura de 14 mm. El enchufe real del clon no se ha medido.

### 16 · `PROVISIONAL_riel_placas` · provisional · nuevo el 2026-10-21

Riel de la bahía. Se apoya en las dos torretas DC de la izquierda de la canaleta (Ø8, agujero Ø4 de unos 4 mm). No va a las torretas del soporte de mandos ni a los 4 M3 del ala.

- STL: [`hardware/cad/export/stl/PROVISIONAL_riel_placas.stl`](../../cad/export/stl/PROVISIONAL_riel_placas.stl)
- STEP: no se ha generado.
- Medidas: 13,00 × 143,49 × 6,00. Volumen 7,85 cm³.
- Cama: el STL ya está boca abajo (mortises contra la cama, cajeado de las torretas abierto hacia arriba). Soportes: no hacen falta para ese cajeado.
- Hace falta un inserto M3 más corto que 5,7 mm en cada torreta, y otro bajo cada mortise que se vaya a usar (el fondo útil ahí es de unos 3,3 mm). **PENDIENTE** de probar en la bandeja impresa.
- Comprueba que el cajeado Ø8,4 entra en la torreta sin forzar y que el riel no tapa el canal.

### 17 · `PROVISIONAL_carro_nano` · provisional

Carro del segundo Nano. Puesto delantero, y = 76. El mini-USB mira a la izquierda.

- STL: [`hardware/cad/export/stl/PROVISIONAL_carro_nano.stl`](../../cad/export/stl/PROVISIONAL_carro_nano.stl)
- Medidas: 54,25 × 20,00 × 8,65. Volumen 2,73 cm³.
- Cama: la cama del carro abajo. El tetón de 2 mm queda en el aire: soporte solo ahí.
- A la vez que el carro del ESP o el de la proto. No a la vez que un carro en y = 90.

### 18 · `PROVISIONAL_carro_esp` · provisional

Carro del ESP8266. Puesto trasero, y = 105. No a la vez que el de la proto: es el mismo puesto.

- STL: [`hardware/cad/export/stl/PROVISIONAL_carro_esp.stl`](../../cad/export/stl/PROVISIONAL_carro_esp.stl)
- Medidas: 57,55 × 27,40 × 8,65. Volumen 3,81 cm³.
- Misma orientación que el 17. La placa de la foto no se ha medido: si es un clon largo tipo LoLin V3, este carro se queda corto.

### 19 · `PROVISIONAL_carro_proto30x70` · provisional

Carro de una protoboard de 30 × 70 mm. Esa medida es de diseño, no de una placa medida. Mismo puesto que el ESP.

- STL: [`hardware/cad/export/stl/PROVISIONAL_carro_proto30x70.stl`](../../cad/export/stl/PROVISIONAL_carro_proto30x70.stl)
- Medidas: 79,25 × 32,00 × 8,65. Volumen 6,14 cm³.
- Misma orientación que el 17. Hasta el borde izquierdo de la bandeja quedan 2,3 mm. **PENDIENTE** con la placa real.

## Lo que no existe en el repo

- Marco o soporte del monitor aparte: el MSI va en una cuna dentro de la carcasa y lo sujeta el bisel (07-10).
- Soporte de la Pi aparte: va en la bandeja (02).
- Panel de control aparte: los agujeros de los mandos están en la carcasa (05 y 06).
- Tapas: no hay. La bandeja (02) es la tapa de servicio de abajo.
- Placa I/O (escudo) del HP: no hay; la ventana está en la carcasa (03).
- Todo cabe en la cama de 256 mm con las divisiones que ya trae el CAD.

## STEP para SolidWorks

Hechos con FreeCAD 1.0 (sin interfaz), esquema AP214. La tabla de la comprobación está en [`STEP/COMPROBACION_STEP.txt`](STEP/COMPROBACION_STEP.txt): cada STEP se reabrió, se miró si el sólido es válido y se comparó su caja con la de la STL (diferencia máxima 0,001 mm) y el volumen (diferencia ≤ 0,01 cm³). En este cambio no se ha vuelto a pasar FreeCAD: solo se ha comprobado que los 23 archivos siguen siendo texto AP214 generado por FreeCAD.

Dos orígenes, y no se editan igual:

- **Sólido de verdad** (desde el código OpenSCAD, importador CSG): 01 plantilla de pivotes, 02 bandeja, 11-12 guías, 13 anillo, 14 pomo, 15 soporte Arduino. En la base: plantilla de agujeros, pletina y soporte del disco ([`../base/STEP/`](../base/STEP/)). Caras planas y agujeros como cilindros reales. Las esquinas redondeadas salen facetadas (OpenSCAD las hace con polígonos). La bandeja trae 3 cuerpos (los 2 de más son las torretas sueltas).
- **STEP de malla: se editan peor en SolidWorks.** Son 03-06 (carcasa) y 07-10 (bisel). En la base: las 4 bases y la pared I/O. El importador no pudo con esas piezas y salen de la STL: triángulos unidos en caras planas grandes, pero los agujeros y las curvas son polígonos. Se pueden medir, cortar y añadir operaciones. No se puede cambiar un diámetro de agujero como si fuera un cilindro.
- **`05_PROVISIONAL_carcasa_x1_y0.step` es un STEP de malla con defecto.** FreeCAD lo marca como no válido por **12 triángulos cruzados** en la STL, en el plano x ≈ 406,3 mm (y ≈ 138-143, z ≈ 88-91), junto al potenciómetro delantero. La caja y el volumen coinciden con la STL. Si SolidWorks se queja, usar «Diagnóstico de importación».

Para cambiar medidas de verdad, la referencia es `hardware/cad/params.scad`, no estos STEP. El 2026-10-20 se regeneraron `PROVISIONAL_soporte_arduino.stl` y `PROVISIONAL_carcasa_x1_y1.stl`. El 2026-10-21 se añadieron el riel y los tres carros; el soporte no se volvió a exportar. Los STEP 06 y 15, el manual PDF y el resto de STL anteriores no se han regenerado.

Ejemplo para regenerar una pieza (no ejecutado aquí):

```bash
openscad -o carcasa.stl -D 'parte="carcasa"' -D ix=0 -D iy=1 hardware/cad/partes.scad
```

Todas: `hardware/cad/exportar.sh`. Plantillas: `hardware/impresion/plantillas/*.scad`. Pared: `hardware/impresion/base/prueba_pared_trasera_io.scad` (hace `include` de `../../cad/piezas.scad`).

## Tamaño en git

No hay `.gitattributes` en el repo: ningún filtro toca estos archivos. El STEP más grande es `06_PROVISIONAL_carcasa_x1_y1.step` (3,6 MB). La carpeta `siguientes` pesa unos 15 MB y el conjunto de STEP más el PDF, unos 23 MB. GitHub avisa a partir de 50 MB por archivo y rechaza a partir de 100 MB, así que no hace falta Git LFS. Los STEP son texto ASCII con finales LF (líneas de 72 caracteres). En este entorno `core.autocrlf` no está activo.
