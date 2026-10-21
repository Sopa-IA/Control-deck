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
| `PROVISIONAL_bandeja_servicio` | 126,00 × 237,49 × 30,20 | 167,36 cm³ | Bandeja v2. Rejilla de la Pi y cajeado de los carros |
| `PROVISIONAL_carcasa_x1_y1` | 228,13 × 150,25 × 150,93 | 233,65 cm³ | Tapa de la Pi y rejilla trasera más baja (antes 242,11 cm³) |
| `PROVISIONAL_carro_nano` | 51,45 × 16,40 × 25,10 | 6,54 cm³ | Carro del Nano de prácticas, dos M3 |
| `PROVISIONAL_carro_esp` | 64,45 × 29,60 × 25,10 | 3,94 cm³ | Carro del ESP8266, dos M3 |
| `PROVISIONAL_carro_proto30x70` | 76,45 × 28,40 × 25,10 | 10,79 cm³ | Carro de una proto 30 × 70 (diseño, no medida) |
| `PROVISIONAL_retenedor_nano` | 29,40 × 51,20 × 10,40 | 1,38 cm³ | Clip del Nano de mandos |
| `PROVISIONAL_tapa_pi` | 94,00 × 54,00 × 2,40 | 9,70 cm³ | Tapa del techo, ranuras y agujeros de ventilador |

`comprobar_stl.py` el 2026-10-21: las 25 mallas caben y están cerradas. `comprobar_interferencias.py`: sin interferencias, con el par Nano+ESP y con el par Nano+proto.
