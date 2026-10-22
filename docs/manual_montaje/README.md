# Orbit Terminal — manual de montaje

Un subpaso, una acción, una figura. La pieza que se añade va en naranja y lo ya montado en gris. El número marca el agujero. La silueta del tornillo, a escala 1:1, está en el PDF.

Los tornillos están elegidos a partir del espesor del CAD y **no se han probado** en el plástico, salvo el M3 de los pasadores: con ese Miguel ya cerró la carcasa. El largo ×16 de ese tornillo llena el agujero y no es una medida del tornillo que él usó.

Fecha del CAD: 2026-10-22. No es un montaje probado.

## Lista de la compra

La cantidad incluye un 10 % de repuesto, redondeado hacia arriba. El recuento de cada paso suma la cantidad **sin** repuesto.

| Tornillo | En el aparato | Compras | Para qué | Estado |
|---|---:|---:|---|---|
| M3×16 cilíndrico, Phillips PH1, rosca hasta la cabeza | 21 | 24 | 9 pasadores, 8 pletinas, 4 de la bandeja | Elegido, sin probar. En los pasadores Miguel ya cerró con un M3; este largo llena el agujero de 16 mm. |
| Tuerca M3 DIN 934 | 12 | 14 | 8 pletinas y 4 de la bandeja | Elegida, sin probar. |
| M3×10 avellanado DIN 965, Phillips PH1 | 3 | 4 | 3 orejetas de la carcasa nueva | Elegido, sin probar. La guía es Ø2,5. |
| Autorroscante para plástico Ø4,5×10, avellanado, Phillips PH2 | 26 | 29 | 10 orejetas ya impresas, 4 del soporte del disco, 12 del bisel | Elegido, sin probar. El paso impreso es Ø3,4: se abre a Ø4,6 antes de meterlo. |
| M3×6 cilíndrico, Phillips PH1 (tornillo de placa base) | 4 | 5 | Placa HP, en sus cuatro separadores | Elegido, sin probar. El agujero impreso es Ø4. |
| M3×10 cilíndrico, Phillips PH1 | 18 | 20 | 16 presillas de placas y 2 de la tapa | Elegido, sin probar. Guía Ø2,5. |
| Arandela ancha M3 Ø9, DIN 9021 | 18 | 20 | 16 presillas de placas y 2 bridas del step-down | Elegida, sin probar. |
| M3×8 cilíndrico, Phillips PH1 | 4 | 5 | Step-down: 2 que lo atraviesan y 2 que lo pisan | Elegido, sin probar. |
| Prisionero M3×16 DIN 916 (Allen 1,5 mm) | 2 | 3 | Los dos pomos | Elegido, sin probar. |
| 6-32 UNC × 1/4" (6,4 mm), Phillips PH2 | 4 | 5 | Disco Toshiba de 3,5", por debajo | Tornillo de disco. Elegido, sin probar. No es M3. |

Herramienta: destornillador Phillips PH1 (todos los M3 de cabeza cruciforme), Phillips PH2 (los Ø4,5 y los 6-32), llave Allen de 1,5 mm, broca de Ø3,4 mm y broca de Ø4,6 mm.

## Piezas

| Pieza | STL | Qué hacer |
|---|---|---|
| Base, 4 trozos | PROVISIONAL_base_x0_y0 … x1_y1 | Ya impresa. No reimprimir. Plana, sin soportes. |
| Carcasas izquierda y delantera derecha | PROVISIONAL_carcasa_x0_y0, x0_y1, x1_y0 | Ya impresas. No reimprimir. |
| Carcasa trasera derecha | PROVISIONAL_carcasa_x1_y1 | Imprimir. Boca del corte delantero en la cama. Con soportes. |
| Pletinas ×4 | PROVISIONAL_pletina_empalme_x4 | Imprimir planas, sin soportes. |
| Soporte de disco 3,5" | PROVISIONAL_soporte_disco | Imprimir con el plato abajo. |
| Bandeja | PROVISIONAL_bandeja_servicio | Imprimir con el ala abajo. Cabe en la A1. |
| Placa I/O | PROVISIONAL_placa_io_hp | Imprimir con la pestaña abajo. |
| Marco de prueba de la placa | PRUEBA_placa_io_hp | Opcional. Se sujeta por fuera. No se monta. |
| Tapa de la Pi | PROVISIONAL_tapa_pi | Imprimir plana. |
| Biseles ×4 | PROVISIONAL_bisel_x0_y0 … x1_y1 | Si ya están impresos, no reimprimir. Se taladran en el 10.2. |
| Guías ×2 | PROVISIONAL_guia_luz_frontal_0 y _1 | Imprimir boca abajo, PETG translúcido. |
| Anillos ×2 | PROVISIONAL_anillo_luz_x2 | Imprimir como salen, PETG translúcido. |
| Pomos ×2 | PROVISIONAL_pomo_x2 | Imprimir de tapa abajo. |
| Carros, retenedor, soporte de Arduino | sus STL provisionales | No imprimir y no montar. |

## Paso 1. Une la base

Las cuatro piezas ya están impresas. Torretas hacia arriba. No las reimprimas.

### 1.1 Coloca las cuatro piezas

![1.1](img/s1_1.png)

**NECESITAS:** Nada. Este paso no lleva tornillo.

Pon las cuatro piezas en cruz, con las torretas hacia arriba. Aún no las atornilles.

### 1.2 Pletina delantera

![1.2](img/s1_2.png)

**NECESITAS:** 2× M3×16 cilíndrico, Phillips PH1, rosca hasta la cabeza  ·  2× Tuerca M3 DIN 934

Pon la pletina sobre las dos torretas del cruce delantero. Tornillo desde arriba. Tuerca debajo. Aprieta hasta que no se mueva.

### 1.3 Pletina trasera del mismo corte

![1.3](img/s1_3.png)

**NECESITAS:** 2× M3×16 cilíndrico, Phillips PH1, rosca hasta la cabeza  ·  2× Tuerca M3 DIN 934

Haz lo mismo en el cruce de atrás. Tornillo desde arriba. Tuerca debajo.

### 1.4 Pletina izquierda

![1.4](img/s1_4.png)

**NECESITAS:** 2× M3×16 cilíndrico, Phillips PH1, rosca hasta la cabeza  ·  2× Tuerca M3 DIN 934

Pon la pletina del corte largo, en el lado izquierdo. Tornillo desde arriba. Tuerca debajo.

### 1.5 Pletina derecha

![1.5](img/s1_5.png)

**NECESITAS:** 2× M3×16 cilíndrico, Phillips PH1, rosca hasta la cabeza  ·  2× Tuerca M3 DIN 934

Cierra el último cruce, a la derecha. Tornillo desde arriba. Tuerca debajo.

Tornillos usados en este paso: 8× M3×16 cilíndrico, Phillips PH1, rosca hasta la cabeza, 8× Tuerca M3 DIN 934.

## Paso 2. Une la carcasa

Si la carcasa ya está unida con M3, salta al paso 3.1.

### 2.1 Par izquierdo

![2.1](img/s2_1.png)

**NECESITAS:** 2× M3×16 cilíndrico, Phillips PH1, rosca hasta la cabeza

Junta las dos piezas de la izquierda. Mete un tornillo en cada agujero del corte. Aprieta hasta que las caras se toquen.

### 2.2 Par derecho

![2.2](img/s2_2.png)

**NECESITAS:** 2× M3×16 cilíndrico, Phillips PH1, rosca hasta la cabeza

Junta las dos piezas de la derecha. Dos tornillos, igual que antes.

### 2.3 Las dos piezas de atrás

![2.3](img/s2_3.png)

**NECESITAS:** 5× M3×16 cilíndrico, Phillips PH1, rosca hasta la cabeza

Junta las dos piezas traseras. Cinco tornillos en los cinco agujeros del corte. Aprieta en cruz.

Tornillos usados en este paso: 9× M3×16 cilíndrico, Phillips PH1, rosca hasta la cabeza.

## Paso 3. Carcasa sobre la base

El tornillo de la orejeta entra siempre desde abajo.

### 3.1 Abre diez pasos

![3.1](img/s3_1.png)

**NECESITAS:** 1× broca de Ø4,6 mm

Con la broca de Ø4,6, abre los diez agujeros Ø3,4 de la base. Desde abajo. Para en cuanto salgas del suelo. No agrandes la orejeta.

### 3.2 Baja la carcasa

![3.2](img/s3_2.png)

**NECESITAS:** Nada. Este paso no lleva tornillo.

Apoya la carcasa sobre la base. Cada orejeta cae sobre su agujero.

### 3.3 Tres orejetas de la pieza nueva

![3.3](img/s3_3.png)

**NECESITAS:** 3× M3×10 avellanado DIN 965, Phillips PH1

Atornilla las tres orejetas de la carcasa nueva, la de atrás a la derecha. Desde abajo. Para cuando la cabeza entre en el avellanado.

### 3.4 Cuatro orejetas del frente

![3.4](img/s3_4.png)

**NECESITAS:** 4× Autorroscante para plástico Ø4,5×10, avellanado, Phillips PH2

Atornilla las cuatro del frente. Desde abajo. El tornillo es el de Ø4,5.

### 3.5 Tres orejetas de la izquierda

![3.5](img/s3_5.png)

**NECESITAS:** 3× Autorroscante para plástico Ø4,5×10, avellanado, Phillips PH2

Atornilla las tres del lateral izquierdo. Desde abajo.

### 3.6 Orejeta trasera que queda

![3.6](img/s3_6.png)

**NECESITAS:** 1× Autorroscante para plástico Ø4,5×10, avellanado, Phillips PH2

Atornilla la orejeta trasera de la pieza izquierda. Desde abajo.

### 3.7 Dos orejetas de la derecha

![3.7](img/s3_7.png)

**NECESITAS:** 2× Autorroscante para plástico Ø4,5×10, avellanado, Phillips PH2

Atornilla las dos del lateral derecho. Desde abajo.

Tornillos usados en este paso: 3× M3×10 avellanado DIN 965, Phillips PH1, 10× Autorroscante para plástico Ø4,5×10, avellanado, Phillips PH2.

## Paso 4. Disco y placa HP

La carcasa sigue puesta. En el dibujo no está, para que se vea el interior.

### 4.1 Abre los cuatro pasos del disco

![4.1](img/s4_1.png)

**NECESITAS:** 1× broca de Ø4,6 mm

Desde abajo, abre a Ø4,6 los cuatro agujeros del soporte del disco. Para al salir del suelo.

### 4.2 Soporte del disco

![4.2](img/s4_2.png)

**NECESITAS:** 4× Autorroscante para plástico Ø4,5×10, avellanado, Phillips PH2

Apoya el soporte en sus cuatro postes. Atornilla desde abajo con los Ø4,5. La cabeza entra en el avellanado.

### 4.3 Disco Toshiba

![4.3](img/s4_3.png)

**NECESITAS:** 4× 6-32 UNC × 1/4" (6,4 mm), Phillips PH2

Apoya el disco en el soporte, conectores hacia la ventana trasera. Los cuatro tornillos entran desde abajo, por el coliso, a la rosca del disco.

### 4.4 Placa HP

![4.4](img/s4_4.png)

**NECESITAS:** 4× M3×6 cilíndrico, Phillips PH1 (tornillo de placa base)

Apoya la placa en los cuatro separadores. Los conectores miran a la ventana trasera. Atornilla los cuatro M3×6.

Tornillos usados en este paso: 4× Autorroscante para plástico Ø4,5×10, avellanado, Phillips PH2, 4× 6-32 UNC × 1/4" (6,4 mm), Phillips PH2, 4× M3×6 cilíndrico, Phillips PH1 (tornillo de placa base).

## Paso 5. Placa de conectores traseros

La ventana ya está cortada. No la toques.

### 5.1 Mete la placa por dentro

![5.1](img/s5_1.png)

**NECESITAS:** Nada. Este paso no lleva tornillo.

Entra con la placa desde dentro de la carcasa. La pestaña queda hacia ti. Empuja hasta que asiente en la ventana. No lleva tornillo.

Tornillos usados en este paso: ninguno.

## Paso 6. Frente izquierdo del HP

La ventana, el pulsador y el LED ya están cortados. No los agrandes.

### 6.1 Placa frontal

![6.1](img/s6_1.png)

**NECESITAS:** Nada. Este paso no lleva tornillo.

Mete la placa frontal por la ventana del lateral izquierdo, desde fuera, hasta que los conectores asomen.

**PENDIENTE DE MEDIR.** La placa de verdad no está medida. El dibujo usa 16×70×26 mm. Si la tuya no entra, para: no limes la carcasa impresa.

### 6.2 Pulsador

![6.2](img/s6_2.png)

**NECESITAS:** Nada. Este paso no lleva tornillo.

Mete el pulsador en el agujero redondo, desde fuera, y fija su tuerca por dentro.

**PENDIENTE DE MEDIR.** El agujero es Ø12,2 mm, de diseño. El pulsador real no está medido.

### 6.3 LED

![6.3](img/s6_3.png)

**NECESITAS:** Nada. Este paso no lleva tornillo.

Mete el LED en el agujero de encima del pulsador.

**PENDIENTE DE MEDIR.** El agujero es Ø3,1 mm. El LED real no está medido.

Tornillos usados en este paso: ninguno.

## Paso 7. Bandeja de placas

Primero las placas, en el banco. La bandeja se atornilla a la base al final.

### 7.1 Raspberry Pi

![7.1](img/s7_1.png)

**NECESITAS:** 4× M3×10 cilíndrico, Phillips PH1  ·  4× Arandela ancha M3 Ø9, DIN 9021

Pon la Pi en su hueco, con USB y RJ45 hacia atrás. La arandela pisa la esquina. El tornillo entra en el poste, fuera de la placa. Aprieta hasta que la arandela apoye.

### 7.2 ESP8266

![7.2](img/s7_2.png)

**NECESITAS:** 4× M3×10 cilíndrico, Phillips PH1  ·  4× Arandela ancha M3 Ø9, DIN 9021

Pon el ESP en su hueco, pines hacia abajo y USB hacia atrás. Cuatro tornillos con arandela, en las esquinas.

**PENDIENTE DE MEDIR.** El hueco es 58×31 mm, sacado de una foto. Mide la PCB. Si no entra, no la fuerces.

### 7.3 Nano de prácticas

![7.3](img/s7_3.png)

**NECESITAS:** 4× M3×10 cilíndrico, Phillips PH1  ·  4× Arandela ancha M3 Ø9, DIN 9021

Pon el Nano de prácticas, pines hacia abajo y mini-USB hacia delante. Cuatro tornillos con arandela.

### 7.4 Step-down

![7.4](img/s7_4.png)

**NECESITAS:** 4× M3×8 cilíndrico, Phillips PH1  ·  2× Arandela ancha M3 Ø9, DIN 9021

Pon el módulo en su hueco. Los tornillos 1 y 2 lo atraviesan. Los 3 y 4 lo pisan con arandela, por fuera de la placa.

**PENDIENTE DE MEDIR.** El hueco es un módulo típico de 43×21 mm, con agujeros a 3,5 mm de la esquina. Mide el tuyo antes de apretar.

### 7.5 Nano de mandos

![7.5](img/s7_5.png)

**NECESITAS:** 4× M3×10 cilíndrico, Phillips PH1  ·  4× Arandela ancha M3 Ø9, DIN 9021

Pon el Nano de mandos, pines hacia abajo y mini-USB hacia atrás. Cuatro tornillos con arandela.

### 7.6 Abre las cuatro torretas

![7.6](img/s7_6.png)

**NECESITAS:** 1× broca de Ø3,4 mm

Con la broca de Ø3,4, abre el techo de las cuatro torretas de la base. Para en cuanto la broca caiga.

### 7.7 Atornilla la bandeja

![7.7](img/s7_7.png)

**NECESITAS:** 4× M3×16 cilíndrico, Phillips PH1, rosca hasta la cabeza  ·  4× Tuerca M3 DIN 934

Apoya el ala en las cuatro torretas. Tornillo desde arriba. Tuerca debajo. Aprieta en cruz.

Tornillos usados en este paso: 16× M3×10 cilíndrico, Phillips PH1, 18× Arandela ancha M3 Ø9, DIN 9021, 4× M3×8 cilíndrico, Phillips PH1, 4× M3×16 cilíndrico, Phillips PH1, rosca hasta la cabeza, 4× Tuerca M3 DIN 934.

## Paso 8. Tapa de la Pi

Dos tornillos. No hace falta ventilador.

### 8.1 Cierra la tapa

![8.1](img/s8_1.png)

**NECESITAS:** 2× M3×10 cilíndrico, Phillips PH1

Apoya la tapa en el techo. Atornilla los dos tornillos del canto derecho.

Tornillos usados en este paso: 2× M3×10 cilíndrico, Phillips PH1.

## Paso 9. Pantalla del Nano de prácticas

Va por dentro de la ventana del panel. No hay tornillo.

### 9.1 Acerca el OLED a la ventana

![9.1](img/s9_1.png)

**NECESITAS:** Nada. Este paso no lleva tornillo.

Pon el módulo por dentro, centrado en la ventana. No lo atornilles: el CAD no tiene tornillo para él.

**PENDIENTE DE MEDIR.** El módulo del dibujo mide 33,5 mm de ancho. La ventana, 24×14 mm, es de diseño. Mide el OLED antes de pegarlo o de calzarlo.

Tornillos usados en este paso: ninguno.

## Paso 10. Pantalla y mandos

El monitor entra en la tina. El bisel lo sujeta. Quitar esos tornillos lo suelta.

### 10.1 Mete el monitor

![10.1](img/s10_1.png)

**NECESITAS:** Nada. Este paso no lleva tornillo.

Mete el monitor en la tina, con los conectores hacia la derecha.

### 10.2 Abre los biseles

![10.2](img/s10_2.png)

**NECESITAS:** 1× broca de Ø4,6 mm

En el banco, abre a Ø4,6 los doce agujeros de los cuatro biseles. No taladres la carcasa.

### 10.3 Coloca los cuatro biseles

![10.3](img/s10_3.png)

**NECESITAS:** Nada. Este paso no lleva tornillo.

Apoya los cuatro biseles sobre el marco. La muesca del canto derecho deja libres las teclas del monitor.

### 10.4 Atornilla el bisel

![10.4](img/s10_4.png)

**NECESITAS:** 12× Autorroscante para plástico Ø4,5×10, avellanado, Phillips PH2

Atornilla los doce, desde fuera. Ve saltando de un canto a otro.

### 10.5 Guías de luz

![10.5](img/s10_5.png)

**NECESITAS:** Nada. Este paso no lleva tornillo.

Encaja las dos guías en el canal delantero. Sin tornillo.

### 10.6 Anillos

![10.6](img/s10_6.png)

**NECESITAS:** Nada. Este paso no lleva tornillo.

Mete un anillo desde dentro, bajo cada sitio de pomo. Sin tornillo.

### 10.7 Pomos

![10.7](img/s10_7.png)

**NECESITAS:** 2× Prisionero M3×16 DIN 916 (Allen 1,5 mm)

Encaja cada pomo. Aprieta el prisionero contra el eje. Si el eje no entra, para y mira el anexo.

### 10.8 Pulsadores del panel

![10.8](img/s10_8.png)

**NECESITAS:** Nada. Este paso no lleva tornillo.

Mete los dos pulsadores desde fuera y cierra su tuerca por dentro.

Tornillos usados en este paso: 12× Autorroscante para plástico Ø4,5×10, avellanado, Phillips PH2, 2× Prisionero M3×16 DIN 916 (Allen 1,5 mm).

## Paso 11. Cables que ya están decididos

Lo gris del dibujo no se cablea. No hay red dentro de Orbit.

### 11.1 Jack del HP

![11.1](img/s11_1.png)

**NECESITAS:** Nada. Este paso no lleva tornillo.

Deja el adaptador de 19,5 V fuera. Enchufa solo su jack al conector trasero de la placa.

### 11.2 USB de mandos

![11.2](img/s11_2.png)

**NECESITAS:** Nada. Este paso no lleva tornillo.

Conecta el mini-USB del Nano de mandos a un USB de la Pi.

### 11.3 I2C del OLED

![11.3](img/s11_3.png)

**NECESITAS:** Nada. Este paso no lleva tornillo.

Une SDA del OLED al A4 y SCL al A5 del Nano de prácticas. Una resistencia de 1 kΩ en cada señal.

### 11.4 Dato de la tira

![11.4](img/s11_4.png)

**NECESITAS:** Nada. Este paso no lleva tornillo.

Une el dato de la tira al GPIO2 del ESP. La masa de la tira, a la masa del ESP. No alimentes la tira desde el pin de 3,3 V.

### 11.5 Repasa

![11.5](img/s11_5.png)

**NECESITAS:** Nada. Este paso no lleva tornillo.

Comprueba las cuatro uniones naranjas. No añadas los cables grises.

Tornillos usados en este paso: ninguno.

## Anexo

### Por qué este tornillo

El largo de un cilíndrico se mide bajo la cabeza. El del avellanado incluye la cabeza. Nada de esto se ha apretado en una pieza impresa, salvo el M3 de los pasadores.

| Unión | Qué atraviesa | Tornillo |
|---|---|---|
| Pasador | Agujero Ø3,2 × 16 mm, las dos costillas | M3×16 cilíndrico. La cabeza se queda fuera. |
| Pletina | Pletina 3 mm + torreta 5 mm + suelo 4 mm = 12 mm | M3×16. Salen unos 4 mm bajo la base, para la tuerca. |
| Bandeja | Ala 2 mm + torreta 5 mm + suelo 4 mm = 11 mm | M3×16. Antes se abre el techo macizo, de unos 3 mm. Salen unos 5 mm para la tuerca. |
| Orejeta de la carcasa nueva | Suelo 4 mm + guía Ø2,5 de 9 mm | M3×10 avellanado. La punta no llega al fondo. |
| Orejeta ya impresa, bisel y soporte del disco | Paso Ø3,4 y, detrás, agujero ciego Ø4 | Ø4,5×10 avellanado, después de abrir el paso a Ø4,6. El ×10 no hace tope en el Ø4. |
| Placa HP | PCB 1,6 mm + agujero de 6,2 mm en el separador | M3×6 de placa base. No llega al fondo. El agujero es Ø4. |
| Disco | Rosca 6-32 del Toshiba, chapa de 2 mm | 6-32 × 6,4 mm. No es un M3. |
| Placas de la bandeja | Guía Ø2,5 de 10 mm y arandela de 0,8 mm | M3×10. Entran unos 9 mm. La arandela pisa la esquina, el tornillo no atraviesa la PCB. |
| Step-down, tornillo pasante | Guía de 7 mm | M3×8. |
| Step-down, brida | Guía de 8 mm y arandela | M3×8. |
| Tapa | Tapa 2,4 mm + guía de 9 mm | M3×10. Entran unos 8 mm. |
| Pomo | De la piel al eje hay 12 mm | Prisionero M3×16. Un ×12 solo rozaría el eje. |

### Por qué se taladra

Un autorroscante de Ø4,5 no pasa por el agujero impreso de Ø3,4. Por eso el paso 3.1, el 4.1 y el 10.2 lo abren a Ø4,6, y solo el paso: el agujero Ø4 de la orejeta, del soporte o de la carcasa se queda como está, que es donde el Ø4,5 muerde.

La tuerca no cabe en esos agujeros: son ciegos y de Ø4. Si el Ø4,5 gira en vacío, para. No lo cambies por un M4. La otra salida es abrir ese agujero de lado a lado y poner una tuerca M3, y eso es otro taladro, no el de este manual.

Las torretas de la bandeja no tienen el paso de Ø3,4 que sí tienen las de las pletinas. El techo, de unos 3 mm, está macizo. El 7.6 lo abre con Ø3,4 para que el M3×16 llegue a la tuerca. Un M3 no muerde el Ø4 que hay debajo: por eso lleva tuerca y no autorroscante.

El M3×6 de la placa HP es el tornillo de placa base. Si gira en vacío, el agujero del separador es Ø4, el del inserto que ya no se usa. No cabe un tornillo más gordo en el agujero de la PCB. No se ha elegido otra pieza.

### Si algo no entra

La placa HP se mete por la abertura de la pantalla, con la carcasa ya puesta. Si no pasa, haz el paso 4 antes del paso 3.

Tres pletinas quedan debajo del soporte del disco: las dos del corte largo y la trasera del corte corto. Van en el paso 1, antes del disco.

El corte corto delantero de la carcasa no lleva tornillo. Los cinco del paso 2.3 están todos en la mitad de atrás. Los de los pasos 2.1 y 2.2 unen cada par de delante con atrás.

Si el eje del potenciómetro está estriado, el pomo impreso no entra. Hace falta un pomo comercial para eje estriado. El eje de 6 mm está acordado y sin medir.

### Coordenadas que usa el dibujo

No hacen falta para montar. Están por si hay que reimprimir una pieza.

- Envolvente: 456,26 × 300,49 × 153,92 mm. Cortes en x = 228,13 e y = 150,25.
- Pasadores de atrás, en el corte x: cinco, todos con y mayor que 150.
- Pasadores laterales: dos en x = 7 y dos en x = 449, a z = 25 y z = 55.
- Orejetas con guía Ø2,5, las de la carcasa nueva: (325; 292,5), (420; 292,5) y (448,3; 205).
- Las otras diez orejetas conservan el agujero Ø4 de cuando se imprimieron.
- Hueco de la Pi: origen (330; 167,5), 56 × 85 mm, USB hacia +Y. Presillas en (328; 165,2), (388; 165,2), (327,8; 254,2) y (388,6; 254,2).
- ESP, de la foto: (346; 86), 31 × 58 mm. Nano de prácticas: (399; 66), 18 × 45. Step-down: (399; 124), 21 × 43. Nano de mandos: (400; 222), 18 × 45.
- Torretas de la bandeja: (318,3; 49), (436,3; 49), (318,3; 278,5) y (436,3; 278,5).

### Lo que sigue sin medir

Placa frontal del HP, pulsador y LED. Step-down real. ESP real. OLED real. HAT de la Pi. Tira de LED: tipo, ancho y tensión. Largo de los cables USB. Qué USB de la Pi usa el Nano de mandos. Eje del potenciómetro. Pies de goma. Diámetro del jack. Recorrido del step-down: no se ha dibujado ningún hilo.

Los huecos de la placa I/O salen de una foto del 2026-10-22, no de un calibre. La placa se imprime con esa tabla y se prueba con el marco `PRUEBA_placa_io_hp` antes de darla por buena.

### Cableado fino

Nano de mandos: P1 en A0, P2 en A1, con los extremos a 5 V y a masa. B1 en D2 y B2 en D3, a masa, con la resistencia interna. D0 y D1 son el serial. D6 se queda libre. 115200 baudios. El puerto de ejemplo es /dev/ttyUSB0. Abrir el puerto reinicia la placa; orbitd espera 2,0 s antes de escribir «?». Ese tiempo es de diseño. No hay HID.

OLED: SSD1306 en 0x3C. SDA en A4, SCL en A5. 5 V solo si el módulo lo admite. 1 kΩ en las señales que salen al panel, no en 5 V, 3,3 V ni masa. Rótulos de la carcasa: OLED, PRG, ARD 5V, PI 3V3, NO UNIR. No cablees el cabezal de 40 pines de la Pi: el HAT lo ocupa y sus medidas no están tomadas.

Tira: el dato sale de GPIO2, que es D4. GPIO2 tiene que estar alto al arrancar. La masa de la tira va con la del ESP. La alimentación de la tira no sale del regulador de 3,3 V del módulo. Tensión y tipo, sin medir.

La Pi y el monitor llevan su propia fuente USB-C. El monitor pide más de 15 W. El adaptador del HP, 65 W a 19,5 V, se queda fuera.

