# STL PROVISIONALES · ORBIT TERMINAL

**NO APTOS PARA FABRICACIÓN.** Regenerados el 2026-10-20 con `hardware/cad/exportar.sh` y OpenSCAD 2021.01, a partir del `params.scad` de esa fecha. Configuración vigente:

- preset `msi_15_6`;
- HP `iris_mitx_desnuda` (placa del HP Slimline 260-a110ns desmontada);
- disco **HDD 3,5"** (`usar_hdd_35 = true`): el modelo usa SFF-8301 (101,6 × 147 × 26,1 mm), no la medición a ojo de Miguel (~150 × 100 × 25 mm, 2026-10-20);
- patas del soporte del disco a 14 mm (con 8 mm la plancha chocaba con las pletinas de empalme);
- sin KVM, mandos en columna, potenciómetro genérico de 24 mm y pulsador de 16 mm;
- impresora Bambu Lab A1 (256³), material recomendado PETG.

Hay cotas PENDIENTES. La referencia de estado es `docs/ESTADO-Y-TRASPASO.md`. `docs/diseno-mecanico.md` sigue describiendo en varios sitios el preset anterior de SSD 2,5".

Los archivos `*_x2` / `*_x4` indican cuántas copias imprimir. El prefijo `PROVISIONAL_` se mantiene.

Comprobado el 2026-10-20 sobre estos STL (cajas y mallas, no un montaje real): `comprobar_stl.py` (las 20 caben en la cama y son mallas cerradas) y `comprobar_interferencias.py` (sin interferencias entre 19 cajas; el I/O frontal y el pulsador del HP quedan con holgura mínima de 0 mm porque limitan contra la pared; la OLED queda en 1 mm por la misma razón). Sigue sin ser una autorización de fabricación.

Ese mismo día, más tarde, se regeneraron solo dos STL (OpenSCAD 2021.01), sin pasar `exportar.sh` (ese script borra los veinte):

| STL | Caja (mm) | Volumen | Qué cambió |
|---|---|---|---|
| `PROVISIONAL_soporte_arduino` | 26,00 × 70,00 × 19,10 | 9,58 cm³ | Asiento del Nano (antes 25,70 de ancho y 9,52 cm³, Micro) |
| `PROVISIONAL_carcasa_x1_y1` | 228,13 × 150,25 × 150,93 | 242,11 cm³ | Panel de prácticas en la trasera (antes 243,84 cm³). La caja no cambia |

`PROVISIONAL_bandeja_servicio` no se ha tocado: las torretas siguen en y = 63 y y = 125 y el canal en y = 143,5. El manual PDF y los STEP de `hardware/impresion/` no se han regenerado.

El 2026-10-21 por la tarde se regeneraron la bandeja, `carcasa_x1_y1` y los carros, y se añadieron el clip y la tapa. Sin `exportar.sh`. `PROVISIONAL_riel_placas` se ha quitado: era el riel de la bandeja v1.

| STL | Caja (mm) | Volumen | Qué es |
|---|---|---|---|
| `PROVISIONAL_bandeja_servicio` | 126,00 × 237,49 × 30,20 | 167,53 cm³ | Bandeja v2. Rejilla de la Pi, cajeado y guías Ø2,5 de los carros (antes 167,36) |
| `PROVISIONAL_carcasa_x1_y1` | 228,13 × 150,25 × 150,93 | 233,81 cm³ | Tapa de la Pi, rejilla y guías Ø2,5 en postes y orejetas (antes 233,65) |
| `PROVISIONAL_carro_nano` | 51,45 × 16,40 × 25,10 | 6,54 cm³ | Carro del Nano de prácticas, dos M3 |
| `PROVISIONAL_carro_esp` | 64,45 × 29,60 × 25,10 | 3,94 cm³ | Carro del ESP8266, dos M3 |
| `PROVISIONAL_carro_proto30x70` | 76,45 × 28,40 × 25,10 | 10,79 cm³ | Carro de una proto 30 × 70 (diseño, no medida) |
| `PROVISIONAL_retenedor_nano` | 29,40 × 51,20 × 10,40 | 1,38 cm³ | Clip del Nano de mandos |
| `PROVISIONAL_tapa_pi` | 94,00 × 54,00 × 2,40 | 9,70 cm³ | Tapa del techo, ranuras y agujeros de ventilador |

`comprobar_stl.py` el 2026-10-22: las 25 mallas caben y están cerradas. `comprobar_interferencias.py`: sin interferencias, con el par Nano+ESP y con el par Nano+proto. Ese día la bandeja y `carcasa_x1_y1` cambiaron los agujeros de inserto por guías Ø2,5. El resto de los STL no se regeneró.

El mismo día, después, se añadieron la placa I/O del HP y su prueba. Ninguna otra malla se volvió a exportar: `carcasa_x0_y1` sigue siendo la ya impresa.

| STL | Caja (mm) | Volumen | Qué es |
|---|---|---|---|
| `PROVISIONAL_placa_io_hp` | 171,75 × 55,95 × 2,80 | 16,81 cm³ | Placa de la ventana trasera. Reborde 6 mm (4,5 abajo) y tetón de 1,4 mm. Huecos [PENDIENTE] [FOTO] |
| `PRUEBA_placa_io_hp` | 159,75 × 45,45 × 1,40 | 3,36 cm³ | Marco de la misma ventana, para ver qué hueco falla |

`comprobar_stl.py` con estas dos: 27 mallas, cerradas, dentro de la cama. `comprobar_interferencias.py` sigue sin interferencias (la placa no entra en el ensamblaje).

El mismo día, después, la bandeja pasa a huecos fijos. Se regeneró solo `PROVISIONAL_bandeja_servicio`. Los carros y el retenedor no se han vuelto a exportar y quedan obsoletos: no imprimirlos.

| STL | Caja (mm) | Volumen | Qué es |
|---|---|---|---|
| `PROVISIONAL_bandeja_servicio` | 126,00 × 237,49 × 20,60 | 181,71 cm³ | Huecos de la Pi, dos Nano, el ESP y el step-down. Canal de 13 mm. Guías de esquina Ø2,5 × 13 mm e inserto M2.5 en la Pi. Misma ala. Antes 181,89 cm³ |
| `PROVISIONAL_grapa_esquina` | 10,45 × 8,50 × 1,60 | 0,10 cm³ | Grapa de 1,6 mm. Imprimir 16. Pieza de día |
| `PROVISIONAL_pomo_x2` | 30,00 × 30,00 × 17,00 | 10,92 cm³ | Pomo con bolsillo radial para inserto M3 4×5. Imprimir 2. Pieza de día |

`comprobar_stl.py`: las 31 mallas siguen cerradas y dentro de la cama (el lado largo de la bandeja mide 237,49; con margen de 10 mm el límite es 246). La bandeja es un solo sólido (Volumes: 2, Simple: yes). `comprobar_interferencias.py`: salida 0, 23 cajas. Esa comprobación no suma los 11 mm de las torretas.

El 2026-10-23 no se ha vuelto a exportar la carcasa ya impresa ni la base: `PROVISIONAL_carcasa_x0_y1` y `PROVISIONAL_carcasa_x1_y1` siguen siendo las del 20 y el 22 de octubre. No hay que lanzar `exportar.sh` (borra los STL y regeneraría esas carcasas). Con `carcasa_futura = false` el modelo coincide con lo impreso. Los dos STL `FUTURO_` salen solo con `-D 'carcasa_futura=true'` y **no se imprimen ahora**.

| STL | Caja (mm) | Volumen | Qué es |
|---|---|---|---|
| `PROVISIONAL_placa_io_hp` | 171,75 × 55,95 × 2,80 | 15,71 cm³ | Placa de la ventana trasera. Huecos de la foto del 2026-10-23: VGA a la izquierda, DC a la derecha. Pieza de día. No se pierde ningún puerto de esa foto |
| `PRUEBA_placa_io_hp` | 159,75 × 45,45 × 1,40 | 3,52 cm³ | Misma ventana, para apoyar por fuera antes de montar. Pieza de día |
| `PROVISIONAL_marco_io_frontal` | 67,40 × 26,00 × 3,80 | 1,58 cm³ | Marco a presión en la ventana de 62 × 18. Cara de fuera abajo. Boca 59,8 × 15,8. Pieza de día. Se pierden los dos jacks frontales |
| `PROVISIONAL_placa_puertos_pi` | 85,00 × 39,00 × 3,80 | 6,94 cm³ | Tapa maciza de los agujeros viejos, por dentro. Reborde abajo. Pieza de día. La Pi se alcanza por la tapa del techo |
| `PROVISIONAL_panel_pines` | 80,00 × 78,00 × 4,60 | 9,19 cm³ | Careta por fuera. Rótulos abajo, ganchos arriba. Pieza de día. Pi 2×20 y Nano 2×12 |
| `FUTURO_carcasa_x0_y1_sin_adaptadores` | 228,1 × 150,2 × 150,9 | 212,0 cm³ | **No imprimir ahora.** Hueco frontal 94 × 18, sin marco. La impresa sigue en 213,7 cm³. Pieza de noche si se imprime |
| `FUTURO_carcasa_x1_y1_sin_adaptadores` | 228,1 × 150,2 × 150,9 | 232,8 cm³ | **No imprimir ahora.** Pasos de cable de la Pi y ranuras de regleta. La impresa sigue en 233,8 cm³. Pieza de noche si se imprime |

`comprobar_stl.py` el 2026-10-23: 36 mallas, cerradas, dentro de la cama. Las cuatro `PROVISIONAL_carcasa_*` y la base no han cambiado de archivo.
