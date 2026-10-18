# STL PROVISIONALES · ORBIT TERMINAL v1 + HP v3

**NO APTOS PARA FABRICACIÓN.** Generados el 2026-10-18 con `exportar.sh`. Configuración:

- preset `msi_15_6`, HP `iris_mitx_desnuda` (placa del HP Slimline 260-a110ns desmontada, SSD 2,5");
- sin KVM, mandos en columna, potenciómetro genérico de 24 mm y pulsador de 16 mm;
- impresora Bambu Lab A1 (256³), material recomendado PETG.

Hay cotas PENDIENTES; ver `docs/diseno-mecanico.md`.

Los archivos `*_x2` / `*_x4` indican cuántas copias imprimir. Cambios respecto a v0:

- nuevo: `PROVISIONAL_soporte_arduino`;
- HP v2: nuevo `PROVISIONAL_soporte_disco` (SSD 2,5"; con `usar_hdd_35=true` se regenera para el HDD 3,5"); cambian las bases (separadores mini-ITX, torretas del soporte, empalmes), la carcasa trasera izquierda (ventana I/O mini-ITX, pasacables 40 × 16, ventana lateral del I/O frontal, pulsador y LED del HP) y la bandeja de servicio (sin distribución DC);
- eliminado: `PROVISIONAL_tapa_boton_x2` (los pulsadores de panel traen actuador).
- HP v3 (2026-10-18): solo cambia `PROVISIONAL_base_x0_y1` (el separador del agujero F de la placa pasa a 33,02 mm del borde trasero, patrón estándar mini-ITX; antes 10,16 mm). La capturadora del modo C es solo una reserva de espacio en la bandeja (sin pieza nueva; se fija con velcro o brida). El resto de STL se regeneró y es idéntico en geometría.
