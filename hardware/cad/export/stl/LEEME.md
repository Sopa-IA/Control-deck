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

Comprobado el 2026-10-20 sobre estos STL (cajas y mallas, no un montaje real): `comprobar_stl.py` (las 20 caben en la cama y son mallas cerradas) y `comprobar_interferencias.py` (sin interferencias entre 15 cajas; el I/O frontal y el pulsador del HP quedan con holgura mínima de 0 mm porque limitan contra la pared). Sigue sin ser una autorización de fabricación.
