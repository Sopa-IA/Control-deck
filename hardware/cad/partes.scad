// ORBIT TERMINAL · PIEZAS IMPRIMIBLES (división para la cama) · PROVISIONAL
// ¡¡ NO APTO PARA FABRICACIÓN !!  Exportación:  ./exportar.sh
// Uso: openscad -D 'parte="carcasa"' -D 'ix=0' -D 'iy=0' -o x.stl partes.scad
include <piezas.scad>

parte = "carcasa";   // carcasa | base | bisel | bandeja | guia | pomo | anillo | grapa | soporte_arduino | soporte_disco | pletina | riel | tapa_pi | placa_io_hp | prueba_placa_io_hp | marco_io_frontal | placa_puertos_pi | panel_pines | boton_encendido | soporte_boton | prueba_boton
// OBSOLETO, no imprimir: carro_nano | carro_esp | carro_proto | retenedor_nano (bahía v2)
ix = 0; iy = 0;      // índice de trozo en la rejilla
k  = 0;              // tramo de guía de luz

module celda(i, j, nx, ny, x0, x1, y0, y1, z0 = -50, z1 = 400) {
    xa = i == 0 ? x0 - 50 : x0 + (x1 - x0) * i / nx;
    xb = i == nx - 1 ? x1 + 50 : x0 + (x1 - x0) * (i + 1) / nx;
    ya = j == 0 ? y0 - 50 : y0 + (y1 - y0) * j / ny;
    yb = j == ny - 1 ? y1 + 50 : y0 + (y1 - y0) * (j + 1) / ny;
    translate([xa, ya, z0]) cube([xb - xa, yb - ya, z1 - z0]);
}

// Bisel: rejilla en coordenadas locales (impreso plano, cara vista abajo)
bis_x0 = aloj_x0 - bisel_sol; bis_x1 = aloj_x0 + aloj_w + bisel_sol;
bis_y0 = aloj_y0 - bisel_sol; bis_y1 = aloj_y0 + aloj_h + bisel_sol;
nbx = ceil((bis_x1 - bis_x0) / (cama_x - margen_cama));
nby = ceil((bis_y1 - bis_y0) / (cama_y - margen_cama));

if (parte == "carcasa")
    intersection() { carcasa_superior(); celda(ix, iy, nx_cortes, ny_cortes, 0, W, 0, D); }
else if (parte == "base")
    intersection() { base(); celda(ix, iy, nx_cortes, ny_cortes, 0, W, 0, D); }
else if (parte == "bisel")
    rotate([180, 0, 0]) intersection() { bisel_local(); celda(ix, iy, nbx, nby, bis_x0, bis_x1, bis_y0, bis_y1); }
else if (parte == "bandeja") bandeja_servicio();
else if (parte == "guia") let(t = tramo_guia(k))
    rotate([90, 0, 0]) guia_luz_frontal(t[0], t[1], k == 0 ? 3 : 0, k == n_guia - 1 ? 3 : 0);
else if (parte == "pomo")   rotate([180, 0, 0]) pomo();
else if (parte == "grapa") grapa_esquina();
else if (parte == "anillo") anillo_luz();
else if (parte == "soporte_arduino") translate([-ard_cx, -sop_ard_y0, -sop_ard_z0]) soporte_arduino();
// Riel boca abajo: el cajeado de las torretas queda abierto hacia arriba y no hay que puentearlo.
else if (parte == "riel")
    translate([1, riel_y1 - riel_y0 + 1, riel_h]) rotate([180, 0, 0])
        translate([-riel_x0a, -riel_y0, -suelo]) riel_placas();
// OBSOLETO. Carros de la bahía v2: la bandeja ya no tiene cajeado. No imprimir.
else if (parte == "carro_nano") translate([8, pr_w/2 + 4, 0]) carro_imprimible(pr_l, pr_w, pr_pcb_z, "bordes");
else if (parte == "carro_esp") translate([8, esp_w/2 + 4, 0]) carro_imprimible(esp_l, esp_w, esp_pcb_z, "columnas");
else if (parte == "carro_proto") translate([8, proto_w/2 + 4, 0]) carro_imprimible(proto_l, proto_w, proto_pcb_z, "bordes");
else if (parte == "retenedor_nano") translate([-(ard_cx - ard_w/2 - 6), -(ard_y - 4), -(ard_pcb_z + ard_pcb - 4.2)]) retenedor_nano();
else if (parte == "tapa_pi") translate([-tapa_x0 + tapa_sol + 2, -tapa_y0 + tapa_sol + 2, 0]) tapa_pi();
// Reborde en el origen de la cama. La esquina de la ventana queda a (labio, labio_inf).
else if (parte == "placa_io_hp")
    translate([io_placa_labio, io_placa_labio_inf, 0]) placa_io_hp();
else if (parte == "prueba_placa_io_hp") prueba_placa_io_hp();
// Marco frontal: cara de fuera en la cama. El faldón queda hacia arriba.
else if (parte == "marco_io_frontal") marco_io_frontal();
// Tapa de los agujeros viejos: reborde en la cama, tetones hacia arriba.
else if (parte == "placa_puertos_pi") placa_puertos_pi();
// Careta de pines: cara de fuera en la cama. Los ganchos quedan hacia arriba.
else if (parte == "panel_pines") panel_pines();
// Capuchón: pestaña en la cama, símbolo arriba. Soporte: suelo en la cama.
else if (parte == "boton_encendido") boton_encendido();
else if (parte == "soporte_boton") soporte_boton_impresion();
else if (parte == "prueba_boton") prueba_boton();
else if (parte == "pletina") pletina_empalme();
else if (parte == "soporte_disco") translate([-disco_x, -disco_y, -suelo - 2]) soporte_disco();
else if (parte == "info") {
    echo(str("INFO;nx;", nx_cortes, ";ny;", ny_cortes, ";nbx;", nbx, ";nby;", nby, ";ng;", n_guia));
    cube(1);
}
