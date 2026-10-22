#!/usr/bin/env python3
"""Escribe docs/manual_montaje/README.md y Orbit_manual_montaje.pdf.

Las figuras tienen que existir ya (render_manual.py). No inventa cotas:
el texto repite el CAD de esta rama y marca [PENDIENTE] lo no medido.
"""
from __future__ import annotations

import html
from pathlib import Path

from PIL import Image as PILImage
from reportlab.lib.colors import Color, white
from reportlab.lib.enums import TA_JUSTIFY
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    CondPageBreak,
    Image,
    ListFlowable,
    ListItem,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

RAIZ = Path(__file__).resolve().parents[3]
DOCS = RAIZ / "docs" / "manual_montaje"
IMG = DOCS / "img"
PDF = DOCS / "Orbit_manual_montaje.pdf"

AMBAR = Color(0.93, 0.46, 0.08)
TINTA = Color(0.12, 0.12, 0.13)
GRIS = Color(0.35, 0.36, 0.38)
FILA = Color(0.93, 0.93, 0.92)

pdfmetrics.registerFont(TTFont("DejaVu", "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"))
pdfmetrics.registerFont(TTFont("DejaVuBold", "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"))

BLOQUES: list = []


def h1(t):
    BLOQUES.append(("h1", t))


def h2(t):
    BLOQUES.append(("h2", t))


def p(t):
    BLOQUES.append(("p", t))


def bullets(xs):
    BLOQUES.append(("ul", xs))


def warn(t):
    BLOQUES.append(("warn", t))


def img(nombre, pie):
    BLOQUES.append(("img", nombre, pie))


def tabla(cab, filas):
    BLOQUES.append(("table", cab, filas))


def contenido():
    h1("Manual de montaje del Orbit Terminal")
    p("Provisional, 22 de octubre de 2026. Sale del CAD de esta rama "
      "(hardware/cad/). La pieza de cada paso va en naranja y el resto en gris. "
      "No es una foto del montaje y no certifica que esté probado.")
    p("Lo no medido lleva [PENDIENTE]. Lo que es decisión de diseño y no una "
      "cota de calibre lleva [DISEÑO]. Miguel atornilla el plástico directamente: "
      "no usa insertos térmicos ni pegamento en la carcasa.")
    warn("Un M3 autorroscante muerde una guía de unos Ø2,5 mm. No muerde un "
         "agujero de Ø4 (el del inserto de las piezas ya impresas) ni un paso "
         "libre de Ø3,4, ni un taladro pasante de Ø3,2. Donde el STL tiene uno "
         "de esos tres, el agarre queda [PENDIENTE]. No se fuerza el tornillo.")
    p("Regenerar las figuras, desde la raíz del repo: "
      "python3 hardware/cad/manual/render_manual.py y después "
      "python3 hardware/cad/manual/escribir_manual.py. OpenSCAD 2021, vista "
      "previa, sin --render: en el render CGAL el color del paso no llega al PNG. "
      "El PDF antiguo docs/manual-montaje/ no se ha regenerado y no vale para este montaje.")
    img("00_conjunto", "Carcasa en naranja y base en gris, ya unidas en el modelo. "
        "Bisel, mandos y placas van en los pasos siguientes: meterlos en esta "
        "misma vista vacía el árbol CSG de OpenSCAD.")

    h1("0. Piezas, tornillos y electrónica")
    h2("Impresas en la Bambu Lab A1")
    p("Cama 256 × 256 × 256 mm. Margen de comprobación 10 mm (cabe hasta 246). "
      "PETG. Relleno orientativo 15–20 %. No hay tiempos ni gramos: no se ha laminado. "
      "La orientación es la de hardware/impresion/siguientes/README.md y, en la base, "
      "la de ESTADO-Y-TRASPASO.md.")
    tabla(
        ["STL", "Ud.", "Cama y soportes", "Estado"],
        [
            ["PROVISIONAL_base_x0_y0", "1", "Cara plana abajo. Sin soportes.", "Ya impresa. No reimprimir."],
            ["PROVISIONAL_base_x0_y1", "1", "Igual.", "Ya impresa. Separadores C y F."],
            ["PROVISIONAL_base_x1_y0", "1", "Igual.", "Ya impresa."],
            ["PROVISIONAL_base_x1_y1", "1", "Igual.", "Ya impresa. Hueco de la bandeja."],
            ["PROVISIONAL_pletina_empalme_x4", "4", "Cara plana. Sin soportes. El STL es una.", "Imprimir 4."],
            ["PROVISIONAL_carcasa_x0_y0", "1", "Corte trasero sobre la cama, ~150 mm. Soportes sí, solo desde la cama.", "Ya impresa. Agujeros Ø4."],
            ["PROVISIONAL_carcasa_x0_y1", "1", "Corte delantero sobre la cama. Soportes sí.", "Ya impresa. No reimprimir: lleva la ventana I/O."],
            ["PROVISIONAL_carcasa_x1_y0", "1", "Corte trasero sobre la cama. Soportes sí.", "Ya impresa. El STEP tiene 12 triángulos cruzados; se imprime el STL."],
            ["PROVISIONAL_carcasa_x1_y1", "1", "Corte delantero sobre la cama, ~150 mm. El hueco de la tapa queda arriba. Soportes sí.", "Imprimir este STL (233,81 cm³), no uno anterior."],
            ["PROVISIONAL_soporte_disco", "1", "Boca abajo, bandeja contra la cama. Soportes solo en la cama.", "El de 2,5 pulgadas salió pequeño. Este es el de 3,5."],
            ["PROVISIONAL_placa_io_hp", "1", "Reborde abajo. Sin soportes.", "Huecos [PENDIENTE] [FOTO]."],
            ["PRUEBA_placa_io_hp", "1", "Plana. Se apoya por fuera, no se monta.", "Prueba de la ventana."],
            ["PRUEBA_plantilla_pivotes_HP", "1", "Barras abajo. Sin soportes. No se monta.", "Diámetro del pivote [PENDIENTE]."],
            ["PROVISIONAL_bandeja_servicio", "1", "Plancha abajo. Puentes de ~6 mm. Las ranuras de la Pi no piden soporte.", "Sustituye a la v1. 126,00 × 237,49 × 25,10."],
            ["PROVISIONAL_tapa_pi", "1", "Plana. Sin soportes.", "94 × 54 × 2,4 mm."],
            ["PROVISIONAL_bisel_x0_y0", "1", "Tal cual: cara vista abajo. Sin soportes.", "Agujeros de inserto. Si ya está impreso, no reimprimir."],
            ["PROVISIONAL_bisel_x0_y1", "1", "Igual.", "Igual."],
            ["PROVISIONAL_bisel_x1_y0", "1", "Igual.", "Igual."],
            ["PROVISIONAL_bisel_x1_y1", "1", "Igual.", "Igual. Conviene probar uno antes por la ventana."],
            ["PROVISIONAL_guia_luz_frontal_0", "1", "Boca abajo. Sin soportes. PETG translúcido.", "Canal 10,4 mm. Tira [PENDIENTE]."],
            ["PROVISIONAL_guia_luz_frontal_1", "1", "Igual.", "Igual."],
            ["PROVISIONAL_anillo_luz_x2", "2", "Tal cual. Sin soportes. Translúcido.", "Entran por dentro."],
            ["PROVISIONAL_pomo_x2", "2", "Tapa abajo. Sin soportes.", "Eje de 6 mm [PENDIENTE] de medir."],
        ],
    )
    warn("No imprimir, y no montar: PROVISIONAL_carro_nano, PROVISIONAL_carro_esp, "
         "PROVISIONAL_carro_proto30x70, PROVISIONAL_retenedor_nano y "
         "PROVISIONAL_soporte_arduino. La bandeja de huecos no tiene dónde van. "
         "El soporte del Nano es de la bandeja v1.")
    img("00_piezas", "Piezas sueltas del CAD, en naranja. La placa gris del centro "
        "es PRUEBA_placa_io_hp: se apoya en la ventana y no se deja montada. "
        "La bandeja, la tapa, el soporte del disco, la placa I/O, una guía, "
        "un anillo, un pomo y una pletina.")

    h2("Tornillería de todo el aparato")
    p("La huella (Phillips, Pozidriv o Allen) no está en el CAD. Se usa la del "
      "tornillo que se compre. Herramienta: el destornillador de esa huella. "
      "En autorroscante, parar cuando la cabeza asienta. Seguir girando pasa la guía del PETG.")
    tabla(
        ["Unión", "Ud.", "Tornillo", "Agujero que hay", "¿Muerde?"],
        [
            ["Pletinas de la base", "8", "M3 cilíndrico. Largo [PENDIENTE]. Si fuera inserto, candidato no probado M3×8.", "Torreta Ø8 × 5 mm. Ø4 desde abajo y paso Ø3,4 desde arriba. Pletina 3 mm.", "No. [PENDIENTE]"],
            ["Carcasa, taladros de pasador", "9", "M3, sin pegamento. Candidato no probado: M3×16 cilíndrico. Si no muerde, tuerca.", "Ø3,2 pasante, 16 mm (8 mm por costilla). Pensado para un pasador Ø3, no para rosca.", "No es guía. [PENDIENTE]"],
            ["Orejetas de carcasa_x1_y1", "3", "M3×10 avellanado, desde abajo.", "Guía Ø2,5 × 9 mm. La base ya trae el avellanado (paso Ø3,4, hasta Ø6,6).", "Sí, autorroscante. Sin probar en pieza."],
            ["Orejetas de las otras tres carcasas", "10", "M3 avellanado, desde abajo. Largo [PENDIENTE].", "Ø4 × 5,7 mm (inserto). Esas carcasas ya están impresas.", "No. [PENDIENTE]"],
            ["Bandeja a la base", "4", "M3. El largo no se ha vuelto a elegir.", "Paso Ø3,4 en el ala de 2 mm. Torreta de la base, 5 mm, agujero Ø4.", "No. [PENDIENTE]"],
            ["Separadores de la placa HP", "4", "Pivote o M3. Diámetro [PENDIENTE].", "Cilindro Ø9, alto 6,35 mm. Ø4 abierto por arriba.", "No. La plantilla no se monta."],
            ["Soporte del disco a la base", "4", "M3 avellanado, desde abajo. Largo [PENDIENTE].", "Ø4 en el poste. Avellanado en la base.", "No. [PENDIENTE]"],
            ["Toshiba 3,5 a su soporte", "los del disco", "SFF-8301 indica rosca 6-32. No usar M3 en esa rosca.", "Colisos en el soporte, a 3,18 mm del lateral.", "[PENDIENTE] mirar el tornillo que trae."],
            ["Esquinas de Pi, ESP y dos Nano", "16", "M3×10 cilíndrico + arandela ancha Ø9 (DIN 9021).", "Guía Ø2,5 × 10 mm. Poste Ø7,6.", "Sí. La cabeza sola no llega a la PCB."],
            ["Step-down, agujeros del módulo", "2", "M3×8. Atraviesa la PCB de 1,6 mm.", "Guía Ø2,5 × 7 mm, desde z = 7 hasta z = 0.", "Sí. Posición de los agujeros [PENDIENTE]."],
            ["Step-down, las otras dos esquinas", "2", "M3×8 + arandela Ø9.", "Guía Ø2,5 × 8 mm.", "Sí."],
            ["Tapa de la Pi", "2", "M3×10 cilíndrico.", "Tapa Ø3,4 y 2,4 mm. Poste Ø10 con guía Ø2,5 × 9 mm.", "Sí."],
            ["Biseles", "12", "M3 avellanado. Largo [PENDIENTE].", "Bisel Ø3,4, avellanado hasta Ø6,4. Carcasa Ø4 × 5,7.", "No. [PENDIENTE]"],
            ["Pomos", "2", "M3 prisionero, uno por pomo.", "Agujero radial Ø2,5 en el pomo.", "Sí, en el propio pomo."],
            ["Placa I/O, guías, anillos, OLED", "0", "Sin tornillo en el CAD.", "La OLED, cómo se sujeta: [PENDIENTE].", "—"],
        ],
    )
    p("Las tres orejetas con guía Ø2,5 están en (325, 292,492), (420, 292,492) "
      "y (448,26, 205). Las otras diez conservan el Ø4. En total hay 13 orejetas. "
      "Los 9 taladros de pasador son 5 en el corte X (x = 228,13) y 4 en el corte Y "
      "(y = 150,246). Esos dos números salen de pos_pasadores_x() y pos_pasadores_y() "
      "en esta rama.")

    h2("Electrónica que entra en la caja")
    bullets([
        "Placa HP Slimline 260-a110ns, desmontada de su torre, con disipador, ventilador y RAM. 170 × 170 mm, medido. Lo más alto sobre la placa: 35 mm, medido.",
        "Adaptador HP externo de 65 W, 19,5 V y 3,33 A. Se queda fuera, sin abrir. El diámetro del barril es [PENDIENTE]. Dentro de Orbit no hay red.",
        "Disco Toshiba de 3,5 pulgadas. El modelo usa SFF-8301 (101,6 × 147 × 26,1), no la medición a ojo de ~150 × 100 × 25.",
        "Placa frontal original del HP (USB, audio y SD), el pulsador y el LED de 3 mm. Todo [PENDIENTE] de medir. El paso 6 no se cierra sin esas cotas.",
        "Raspberry Pi 4 y HAT VHF. El HAT no está modelado: medidas [PENDIENTE]. La Pi va con su fuente USB-C, no con la del HP.",
        "Arduino Nano de mandos (clon, ATmega328P, mini-USB, CH340 probable) y otro Nano de prácticas.",
        "ESP8266 NodeMCU. La foto da 58 × 31 mm [PENDIENTE]. Lleva la tira con WLED.",
        "Step-down. El hueco es el de un módulo típico de 43 × 21 mm, agujeros a 3,5 mm de la esquina. El aparato de Miguel es [PENDIENTE]. No se cablea en este manual.",
        "OLED de 0,96 pulgadas, SSD1306, dirección 0x3C (confirmar: también existe 0x3D).",
        "Monitor MSI PRO MP161 E2U (362,26 × 233,84 × 18,8) y su fuente USB-C, de más de 15 W. No sale del step-down.",
        "Dos potenciómetros de panel y dos pulsadores. Modelo [PENDIENTE]. Eje de 6 mm [ACORDADO, PENDIENTE de medir].",
        "Tira LED del frente. Tipo y tensión [PENDIENTE]. Cuatro pies de goma: el CAD reserva un cajeado de Ø12,4 × 1 mm. El pie concreto es [PENDIENTE].",
        "No hay hueco para la capturadora ni para una protoboard de 30 × 70. Dónde va el dongle es [PENDIENTE].",
    ])

    h1("1. Base de cuatro trozos y pletinas")
    p("Piezas: las cuatro bases y cuatro pletinas. La base ya está impresa. "
      "Se apoya con la cara de los pies hacia la mesa. Los separadores del HP "
      "(C y F en x0_y1, H y J en x0_y0) quedan hacia arriba.")
    img("01_base_explosion", "Los cuatro trozos, separados. Van en naranja. "
        "Las pletinas, en gris, quedan en el hueco de cada junta.")
    p("Cada pletina es de 30 × 10 × 3 mm, con dos pasos Ø3,4 separados 18 mm. "
      "Hay dos a caballo del corte X (x = 228,13) y dos a caballo del corte Y "
      "(y = 150,246). Se apoyan en las torretas de Ø8 × 5 mm.")
    img("01_pletinas", "Pletinas en naranja, levantadas 11 mm para verlas. La base, en gris.")
    img("01_zoom_pletina", "Una pletina sobre las dos torretas de una junta del corte X. "
        "Los agujeros de la pletina caen en el eje de las torretas.")
    p("Tornillos: 8 M3 de cabeza cilíndrica, dos por pletina, desde arriba. "
      "Largo [PENDIENTE]. La torreta tiene 5 mm y la pletina 3 mm. El agujero de "
      "la torreta es Ø4 por abajo y Ø3,4 por arriba: un autorroscante no rosca ahí.")
    warn("No dar por cerrada esta junta. Hace falta una solución que agarre en Ø4 "
         "o en Ø3,4 (tuerca, otro tornillo, o reimprimir las torretas con guía Ø2,5). "
         "Reimprimir la base no entra en este manual: ya está hecha. [PENDIENTE]")
    p("Herramienta: destornillador de la huella del M3. Orden: presentar las cuatro "
      "pletinas, enroscar los ocho tornillos solo hasta que cojan, y apretar en cruz "
      "(una pletina de un corte, luego la del otro, y volver). Dentro de cada pletina, "
      "alternar los dos tornillos. No apretar una junta del todo antes de tener las "
      "cuatro presentadas: la base se abre. Tres pletinas quedan debajo del soporte "
      "del disco: las dos del corte Y y la trasera del corte X (y ≈ 186). Van puestas "
      "antes del soporte, o tiene que poderse llegar a ellas.")

    h1("2. Carcasa de cuatro trozos, con M3 en los Ø3,2")
    p("Piezas: carcasa_x0_y0, x0_y1, x1_y0 y x1_y1. Las tres primeras ya están "
      "impresas. x1_y1 es el STL de 233,81 cm³, con guías Ø2,5 en sus postes y "
      "en sus tres orejetas. Sin pegamento.")
    img("02_carcasa_explosion", "Los cuatro trozos. En naranja, el trasero izquierdo "
        "(x0_y1). Los otros tres, en gris. El corte delantero de x0_y1 y de x1_y1 "
        "es el que va contra la cama al imprimir.")
    p("Miguel une la carcasa con tornillos M3 metidos por los agujeros de los "
      "pasadores. El CAD los dibujó como alojamiento de un pasador Ø3: son Ø3,2 "
      "y pasan las dos costillas (16 mm, 8 mm a cada lado). Un M3 (Ø3,0) entra "
      "con holgura. No es una guía de Ø2,5.")
    img("02_zoom_pasador", "Corte X, junto a la trasera, con los dos trozos separados. "
        "En naranja, x0_y1. Se ven los medios cilindros del taladro Ø3,2 en la costilla.")
    p("Son 9 tornillos: 5 en el plano x = 228,13 y 4 en el plano y = 150,246. "
      "Candidato, no probado: M3×16 de cabeza cilíndrica. Si la rosca no muerde "
      "el PETG, el mismo tornillo con tuerca al otro lado de la costilla: el "
      "taladro es pasante. [PENDIENTE] cuál de las dos agarra.")
    p("Herramienta: destornillador, y una llave de tuerca M3 si hace falta la tuerca. "
      "Orden: encarar los cuatro trozos, meter los 9 tornillos sin apretar, empezar "
      "por los más cercanos al cruce de los dos cortes y seguir hacia las esquinas. "
      "Apretar en ese mismo orden, poco a poco. Si se cierra una esquina primero, "
      "el cruce no junta. Aviso: no echar pegamento para «ayudar». No agrandar el Ø3,2.")

    h1("3. Carcasa a la base, por las orejetas")
    p("La carcasa ya unida baja sobre la base. Trece orejetas. El tornillo entra "
      "desde abajo: la base trae el paso Ø3,4 y el avellanado hasta Ø6,6, para que "
      "la cabeza no salga del suelo.")
    img("03_carcasa_base", "Carcasa en naranja, levantada. Base en gris. "
        "Así se presenta antes de los trece tornillos.")
    img("03_zoom_orejeta_auto", "Orejeta trasera de x1_y1, en (420, 292,492). "
        "La carcasa está levantada, en naranja. Esta guía es Ø2,5 × 9 mm. "
        "Tornillo: M3×10 avellanado. Las otras dos iguales están en "
        "(325, 292,492) y (448,26, 205).")
    img("03_zoom_orejeta_inserto", "Orejeta junto a la ventana del HP, en (197, 292,492), "
        "sobre la carcasa ya impresa. El agujero es Ø4 × 5,7, no una guía. "
        "Un M3×10 aquí no rosca. [PENDIENTE]")
    p("Herramienta: destornillador, con la caja de canto o boca abajo para llegar "
      "al avellanado. Orden: los trece tornillos presentados, luego apriete cruzado "
      "(delante, detrás, izquierda, derecha) para que la carcasa no se vaya a un lado. "
      "Los tres de x1_y1 se aprietan hasta asentar la cabeza y se paran. Los otros "
      "diez no se fuerzan: el Ø4 no agarra.")
    warn("No reimprimir x0_y0, x0_y1 ni x1_y0 para cambiar esos diez agujeros. "
         "Cómo se cierra esa unión queda [PENDIENTE]. Los tres de x1_y1 sí siguen "
         "el autorroscante.")

    h1("4. Placa HP, separadores y disco Toshiba")
    p("Piezas: la placa mini-ITX, el soporte del disco y el Toshiba. Los cuatro "
      "separadores ya van en la base (Ø9 × 6,35 mm). C está en (23,35, 284,33), "
      "F en (180,83, 261,47), H en (23,35, 129,39) y J en (180,83, 129,39). "
      "El patrón es el mini-ITX de catálogo: cuadra con la foto y no se ha medido "
      "con calibre. Miguel prefiere pivotes. La plantilla PRUEBA_plantilla_pivotes_HP "
      "trae diámetros 3,8 / 3,6 / 3,4 / 3,2 y no se monta. Hasta que uno gane, "
      "el agujero impreso sigue siendo Ø4 abierto por arriba. [PENDIENTE]")
    img("04_hp_disco", "Base en gris. Soporte del disco en naranja, a la derecha de la placa. "
        "La placa verde es el marcador: RAM, disipador y pila de conectores son "
        "ilustrativos, salvo el alto de 35 mm y el tamaño 170 × 170, que están medidos.")
    img("04_zoom_separador", "Separador C. El cilindro impreso y el agujero de arriba. "
        "El hexágono es el marcador del tornillo, no una pieza del STL.")
    p("Tornillos de la placa: 4. Métrica [PENDIENTE] (pivote o M3). No roscan en Ø4. "
      "Tornillos del soporte a la base: 4 M3 avellanados desde abajo, a postes con "
      "Ø4. Largo [PENDIENTE], mismo problema de agarre. Tornillos del Toshiba al "
      "soporte: los del propio disco. La norma del hueco dice rosca 6-32. "
      "[PENDIENTE] contar los que trae y no meter un M3 en una rosca 6-32.")
    p("Herramienta: destornillador, y la llave de los 6-32 si el disco los usa. "
      "Orden: soporte del disco (los cuatro de abajo, solo presentados), disco en "
      "los colisos, tornillos del disco, luego la placa sobre los cuatro separadores. "
      "Apretar los separadores en cruz. El ventilador del disipador HP no sopla a la Pi.")
    warn("La carcasa, si ya está atornillada, deja como paso grande la abertura de "
         "la pantalla: el bisel y el MSI van en el paso 10. La placa mide 170 × 170 mm. "
         "No se ha comprobado si entra por ahí y se desliza hasta los separadores. "
         "Si no entra, este paso va antes de bajar la carcasa. [PENDIENTE]")

    h1("5. Placa I/O trasera del HP")
    p("Pieza: PROVISIONAL_placa_io_hp. Entra por dentro de la ventana ya impresa "
      "de carcasa_x0_y1 (159,75 × 45,45 mm). No se atornilla: la pared tiene 3 mm "
      "y una guía de 8 mm no cabe. El reborde (6 mm arriba y a los lados, 4,5 mm "
      "abajo) apoya en la cara interior. El tetón, 0,4 mm más pequeño que la ventana "
      "por lado, la centra. Chapa de 1,4 mm. Abajo, hasta el suelo, hay unos 5,2 mm.")
    img("05_placa_io", "Placa en naranja, separada hacia atrás para verla. "
        "La carcasa x0_y1, en gris. En el montaje el reborde queda dentro y el "
        "tetón entra en la ventana. No va empujada desde fuera.")
    p("Antes, PRUEBA_placa_io_hp: se apoya por fuera, con el hueco de la esquina "
      "en el extremo inferior izquierdo de quien mira la trasera, y se anota qué "
      "conector no entra. Los huecos (DC, VGA, HDMI, dos USB 3, RJ45 sobre dos USB 2, "
      "audio y la cabecera) son de la foto del 22 de octubre de 2026, con ~1 mm por "
      "lado. [PENDIENTE] [FOTO]. La lista para medir está en docs/datos-pendientes-hp.md, H-4.")
    p("Tornillos: ninguno. Herramienta: ninguna. Orden: la prueba, corregir la "
      "tabla io_huecos si un conector no entra, y solo entonces la placa definitiva, "
      "desde dentro, hasta que el reborde toque la pared. Aviso: no limar la ventana "
      "impresa. No cortar el pasacables de encima (40 × 16 mm, 12 mm sobre la ventana). "
      "El jack DC de 19,5 V asoma por esta placa. El barril, [PENDIENTE].")

    h1("6. Placa frontal del HP, pulsador y LED")
    warn("[PENDIENTE de medidas]. Este paso no se puede cerrar. La ventana, el "
         "agujero del pulsador y el del LED ya están cortados en carcasa_x0_y1, "
         "que no se reimprime. No se agrandan.")
    p("En el CAD, la placa frontal es un marcador de 16 × 70 × 26 mm en el lateral "
      "izquierdo, detrás de la tina. El pulsador es Ø12 y 22 mm de fondo. El LED "
      "es un agujero de Ø3,1, 14 mm por encima del centro del pulsador. Ninguna de "
      "esas cotas está medida. El patillaje del botón original, para ponerlo en "
      "paralelo, tampoco. [PENDIENTE]")
    img("06_io_frontal", "Lateral izquierdo de x0_y1. La ventana rectangular y el "
        "agujero redondo son los del CAD. La placa, el pulsador y el LED de verdad "
        "no están medidos: no hay tornillo ni orden de apriete que copiar.")
    p("Tornillos: no hay ninguno en el modelo. Herramienta: ninguna hasta tener "
      "la placa delante. Cuando se mida, se anota cómo se sujeta (pestañas originales, "
      "tornillo o brida) y se añade a este paso. Aviso: no cablear el pulsador a "
      "ciegas. Es un contacto seco en paralelo al cabezal del HP, y el pinout se "
      "mira con el polímetro.")

    h1("7. Bandeja de huecos")
    p("Pieza: PROVISIONAL_bandeja_servicio. Plancha abajo al imprimir. Entra por "
      "el hueco de la base, ala de 2 mm hacia abajo. Contorno 126,00 × 237,49 mm, "
      "alto 25,10 mm (de z = −2 a z = 23,1). Cabe en la A1: el lado largo queda "
      "8,5 mm dentro del margen de 246.")
    img("07_bandeja", "Bandeja en naranja, 40 mm por encima de la base gris, "
        "con las placas del marcador.")
    img("07_bandeja_planta", "Planta. Pi al fondo (USB y RJ45 hacia atrás). "
        "A la izquierda, el ESP. A la derecha, de delante a atrás: Nano de prácticas, "
        "step-down y Nano de mandos.")
    p("La Pi no se mueve: esquina en (330, 167,5), 56 × 85 mm, USB y RJ45 hacia +Y, "
      "a 12 mm del suelo, sobre postes Ø6 con agujero Ø2,7. Por ese agujero no entra "
      "un M3. La pisada son las cuatro arandelas, no esos postes. La rejilla bajo el "
      "SoC se deja libre: las paredes de la Pi llegan a ras de la PCB (z = 13,5) y "
      "no tapan la rejilla. El HAT no está dibujado. [PENDIENTE]")
    img("07_zoom_hueco", "Hueco del ESP, en naranja. Pines hacia abajo: el apoyo "
        "es un escalón de 2 mm en los cantos cortos. El centro baja hasta el suelo. "
        "El canto del USB está partido.")
    tabla(
        ["Placa", "Esquina −X −Y", "USB", "Tornillos"],
        [
            ["Pi 4", "330, 167,5", "+Y", "4 × M3×10 + arandela Ø9. Guías en (328,0, 165,2), (388,0, 165,2), (327,8, 254,2), (388,6, 254,2)."],
            ["ESP8266", "346, 86", "+Y", "4 × M3×10 + Ø9. (344,5, 83), (378,5, 83), (344,5, 147), (378,5, 147). PCB 31 × 58 [PENDIENTE]."],
            ["Nano prácticas", "399, 66", "−Y", "4 × M3×10 + Ø9. (397,5, 63), (418,5, 63), (397,5, 114), (418,5, 114)."],
            ["Step-down", "399, 124", "—", "2 × M3×8 por los agujeros del módulo y 2 × M3×8 + Ø9 en (421,5, 121) y (397,5, 166)."],
            ["Nano mandos", "400, 222", "+Y", "4 × M3×10 + Ø9. (398,5, 219), (419,5, 219), (398,5, 270), (419,5, 270)."],
        ],
    )
    p("A la base: 4 M3 por el ala, en (318,26, 49), (436,26, 49), (318,26, 278,492) "
      "y (436,26, 278,492). Paso Ø3,4. La torreta de la base es Ø4. Largo y agarre "
      "[PENDIENTE]. Son los mismos cuatro de la base ya impresa, no unos nuevos elegidos ahora.")
    p("Herramienta: destornillador y las arandelas Ø9. Orden, en cada placa: los "
      "cuatro (o dos) tornillos hasta que la arandela roce la esquina, en cruz, y "
      "luego asentar. No arquear la PCB. La arandela tiene que pisar el borde; la "
      "cabeza sola no llega. Los de la Pi delanteros quedan a ~1,2 mm de los postes Ø6: "
      "no montar la arandela cruzada contra el poste.")
    warn("El escalón de 2 mm supone que los pines empiezan a 2,4 mm del canto. "
         "[PENDIENTE] medirlo: si el pin está más adentro, el escalón lo pisa. "
         "La clavija de mandos del marcador sale unos 15 mm del suelo de la bandeja. "
         "La de prácticas acaba en y = 54. Largos reales [PENDIENTE]. "
         "El step-down de 43 × 21 es una cifra típica, no el módulo de Miguel. "
         "No hay sexto hueco: ni protoboard ni capturadora.")
    p("Los cables van por los siete puentes (barra a 4,2 mm del suelo, luz de unos "
      "4 mm): entre prácticas y el step-down, en el corredor del ESP, y tres en el "
      "canto derecho. No apoyarlos sobre el puente: pasan por debajo.")

    h1("8. Tapa de la Pi y abertura de x1_y1")
    p("Pieza: PROVISIONAL_tapa_pi (94 × 54 × 2,4 mm). Cubre el hueco del techo de "
      "carcasa_x1_y1, encima de los USB y el RJ45. Dos tornillos M3×10 de cabeza "
      "cilíndrica, en x = 404, a las guías Ø2,5 de los postes Ø10. El paso de la "
      "tapa es Ø3,4: la rosca está en el poste, no en la tapa.")
    img("08_tapa", "Tapa en naranja, levantada. Carcasa x1_y1 en gris. "
        "Se ven las ranuras, la muesca del dedo y los dos agujeros de los M3×10.")
    p("Herramienta: destornillador. Orden: la tapa en su asiento (la muesca hacia "
      "delante), los dos tornillos presentados, y apretar los dos a la vez hasta "
      "asentar. No seguir. Los agujeros de Ø3,2 de la tapa son para un ventilador "
      "opcional de 30 × 30 o 40 × 40: no hace falta ponerlo, y no tapan las ranuras "
      "si no se monta. Aviso: el ventilador del HP no alimenta este hueco. "
      "Para llegar a los USB de la Pi se quita esta tapa.")

    h1("9. Panel de pines y OLED")
    p("El panel no es una pieza aparte: está en la trasera de carcasa_x1_y1 "
      "(x desde 250, z desde 68, 74 × 72 mm). La OLED va por dentro, detrás de la "
      "ventana de 24 × 14 mm. Esas dos cotas son [DISEÑO], a partir del área visible "
      "de una ficha de 0,96 pulgadas. La profundidad del marcador es 12 mm. [PENDIENTE] "
      "la PCB real y cómo se sujeta: el CAD no trae tornillo.")
    img("09_panel", "Trasera de x1_y1. La OLED del marcador, en naranja, separada "
        "hacia dentro. En el plástico se leen OLED, PRG, ARD 5V, PI 3V3 y NO UNIR. "
        "La retícula es el paso de 2,54 mm.")
    p("Tornillos: ninguno en este paso. Herramienta: ninguna para el plástico. "
      "El cableado está en el paso 11. Aviso: no unir ARD 5V con PI 3V3. "
      "No cablear el cabezal de 40 pines de la Pi hasta saber el HAT: el HAT ocupa "
      "ese cabezal, y GPIO2/GPIO3 son el I2C de la Pi. [PENDIENTE]")

    h1("10. Biseles, pantalla, guías, anillos y pomos")
    p("El MSI se apoya en la tina. Lo sujeta el bisel, en cuatro trozos, cara vista "
      "abajo al imprimir. Doce tornillos M3 avellanados (tres por trozo) a agujeros "
      "Ø4 × 5,7 de la carcasa. El paso del bisel es Ø3,4, avellanado hasta Ø6,4. "
      "Largo [PENDIENTE]: en Ø4 el M3 no rosca. El bisel se puede quitar y el monitor sale.")
    img("10_bisel", "Bisel en cuatro trozos, separados de la pendiente. "
        "El trozo delantero izquierdo, en naranja. La carcasa, en gris. "
        "El dibujo de la pantalla es el marcador, no la interfaz real.")
    p("El área activa se supone centrada. [PENDIENTE] La muesca del bisel cae sobre "
      "las teclas del canto derecho del MSI (encendido, arriba, abajo). Conviene "
      "imprimir un trozo, apoyar el monitor y mirar si la ventana enseña toda la "
      "imagen antes de imprimir los otros tres.")
    img("10_mandos", "Pomos y anillos separados de la consola, y las dos guías "
        "del frente adelantadas. Carcasa en gris.")
    p("Guías: dos, PROVISIONAL_guia_luz_frontal_0 y _1. Sin tornillos. Entran en "
      "el canal del frente. PETG translúcido, impresas boca abajo. El canal del "
      "modelo mide 10,4 mm para una tira de 10 mm. La tira sigue sin identificar. [PENDIENTE]")
    p("Anillos: dos, PROVISIONAL_anillo_luz_x2. Sin tornillos. Entran por dentro "
      "de la ranura anular, con tres puentes. Translúcido.")
    p("Pomos: dos, Ø30. Un M3 prisionero por pomo, en el agujero radial Ø2,5. "
      "Eje de 6 mm, liso o en D: [ACORDADO, PENDIENTE de medir]. Si el eje es "
      "estriado, este pomo no vale y se usa uno comercial. Los dos pulsadores de "
      "panel traen su propio actuador. Modelo [PENDIENTE]. No hay tapa impresa.")
    p("Herramienta: destornillador. Para el prisionero, el mismo, en el lateral del pomo. "
      "Orden: monitor en la tina, con los puertos (USB-C y Mini-HDMI) hacia el canto "
      "derecho; los doce tornillos del bisel presentados; apriete en cruz, sin forzar "
      "los Ø4; guías de luz de izquierda a derecha; anillos por dentro; pomos, y el "
      "prisionero cuando el eje esté dentro, sin aplastar el eje. Aviso: no apretar "
      "el bisel contra el cristal. Si el M3 no agarra en Ø4, parar. [PENDIENTE]")

    h1("11. Cableado y comprobación")
    p("El dibujo solo tiene hilo donde el firmware o el CAD dan la unión por sabida. "
      "Lo gris no se cablea: falta el dato. No es el recorrido por dentro de la caja.")
    img("11_cableado", "Diagrama generado con OpenSCAD. Naranja: alimentación del HP "
        "y la OLED. Azul: los Nano. Verde: la Pi y la placa. Gris: step-down y MSI, sin hilo.")
    h2("Alimentación")
    bullets([
        "El adaptador de 19,5 V entra por el jack DC de la placa HP y se queda fuera. No se abre y no se mete la red en la caja.",
        "La Pi y el MSI llevan cada uno su fuente USB-C. La del MSI tiene que dar más de 15 W. No salen del step-down.",
        "El step-down está en su hueco y no se conecta aquí. Entrada, salida y masa: [PENDIENTE] hasta tener el módulo.",
    ])
    h2("USB del Nano de mandos a la Pi")
    bullets([
        "Mini-USB del Nano de mandos a un USB de la Pi. Cuál de los cuatro es [PENDIENTE].",
        "Serie a 115200. El CH340 sale como /dev/ttyUSB (ejemplo /dev/ttyUSB0), no como ttyACM0. En la Pi se mira /dev/serial/by-id. Aún no se ha leído en la placa de Miguel. [PENDIENTE]",
        "Abrir el puerto reinicia el Nano. orbitd espera 2,0 s antes de escribir «?» . Ese tiempo es [DISEÑO].",
        "P1 al A0 y P2 al A1 (el cursor; los extremos del potenciómetro a 5 V y a GND). B1 al D2 y B2 al D3, los dos a GND, con pull-up interno. D0 y D1 son el UART. D6 queda libre: la tira no va en este Nano. No hay HID.",
    ])
    h2("I2C de la OLED")
    bullets([
        "La controla el Nano de prácticas. SDA en A4, SCL en A5, dirección 0x3C.",
        "VCC a 5 V solo si el módulo lo admite. Si no, a 3,3 V. En un clon CH340 el pin de 3,3 V puede no existir o dar poca corriente. [PENDIENTE]",
        "GND con GND. Muchos módulos ya traen las pull-up. Confirmarlo.",
        "1 kΩ en serie en cada señal que salga al panel (pines, RST, TX, RX, SDA, SCL). No en 5 V, 3,3 V ni GND. A 5 V, un corto detrás de 1 kΩ queda en 5 mA: es un límite de corriente, no un desplazador de nivel.",
        "El mapa pin a pin está en software/arduino-pruebas/README.md. No unir la fila de 5 V del Nano con la de 3,3 V de la Pi.",
    ])
    h2("Tira LED y WLED")
    bullets([
        "La tira la lleva el ESP8266 con WLED, no un pin del Nano de mandos.",
        "Dato por defecto: GPIO2, rotulado D4 en la mayoría de NodeMCU. GPIO2 tiene que estar en alto al arrancar. A veces hace falta una pull-up de 3,3–4,7 kΩ a 3,3 V. [PENDIENTE] si este módulo la necesita.",
        "La masa de la tira va con la del ESP. No alimentar la tira desde el regulador de 3,3 V del módulo.",
        "Tipo y tensión de la tira: [PENDIENTE]. Si es direccionable de 5 V, el dato a 3,3 V puede quedarse corto. El desplazador de nivel es [PENDIENTE].",
    ])
    h2("Comprobación final")
    bullets([
        "Ningún tornillo de un agujero Ø4 o Ø3,2 se ha dado por apretado. Esas uniones siguen [PENDIENTE].",
        "Los autorroscantes de Ø2,5 (huecos, tapa, tres orejetas de x1_y1, prisioneros) asientan y no siguen girando.",
        "La placa I/O entra por dentro. La prueba de fuera ya se ha mirado, o el paso 5 sigue abierto.",
        "El paso 6 sigue marcado [PENDIENTE de medidas] hasta calar la placa frontal, el pulsador y el LED.",
        "ARD 5V y PI 3V3 no están unidos. El cabezal de 40 pines de la Pi no está cableado.",
        "La tira no sale del regulador de 3,3 V del ESP. El step-down no alimenta nada todavía.",
        "No hay 230 V dentro. El adaptador HP y las dos fuentes USB-C están fuera.",
        "Al abrir el serie del Nano de mandos, se espera el reinicio antes de pedir el saludo.",
    ])
    p("Esto no es un montaje hecho. Amplía este mismo archivo cuando una cota deje de ser [PENDIENTE].")


def esc(s):
    return html.escape(s, quote=False).replace("\n", "<br/>")


def markdown():
    lineas = [
        "# Manual de montaje del Orbit Terminal",
        "",
        "Copia legible del PDF `Orbit_manual_montaje.pdf`. "
        "Figuras en `img/`, regeneradas con `hardware/cad/manual/render_manual.py`.",
        "",
    ]
    for b in BLOQUES:
        k = b[0]
        if k == "h1":
            lineas += ["", f"## {b[1]}", ""]
        elif k == "h2":
            lineas += ["", f"### {b[1]}", ""]
        elif k == "p":
            lineas += [b[1], ""]
        elif k == "warn":
            lineas += [f"**Aviso.** {b[1]}", ""]
        elif k == "ul":
            lineas += [*(f"- {x}" for x in b[1]), ""]
        elif k == "img":
            lineas += [f"![{b[2]}](img/{b[1]}.png)", "", f"*{b[2]}*", ""]
        elif k == "table":
            cab, filas = b[1], b[2]
            lineas.append("| " + " | ".join(cab) + " |")
            lineas.append("| " + " | ".join("---" for _ in cab) + " |")
            for f in filas:
                lineas.append("| " + " | ".join(c.replace("|", "/") for c in f) + " |")
            lineas.append("")
    # El primer h1 del PDF se repite como título markdown de arriba.
    texto = "\n".join(lineas)
    texto = texto.replace("## Manual de montaje del Orbit Terminal\n", "", 1)
    (DOCS / "README.md").write_text(texto.strip() + "\n", encoding="utf-8")


def estilos():
    base = dict(fontName="DejaVu", textColor=TINTA, leading=13)
    return {
        "h1": ParagraphStyle("h1", fontName="DejaVuBold", fontSize=15, leading=18,
                             textColor=TINTA, spaceBefore=8, spaceAfter=6),
        "h2": ParagraphStyle("h2", fontName="DejaVuBold", fontSize=11.5, leading=14,
                             textColor=TINTA, spaceBefore=8, spaceAfter=3),
        "p": ParagraphStyle("p", fontSize=9, alignment=TA_JUSTIFY, spaceAfter=4, **base),
        "li": ParagraphStyle("li", fontSize=9, leading=12, fontName="DejaVu", textColor=TINTA),
        "pie": ParagraphStyle("pie", fontName="DejaVu", fontSize=8, leading=10,
                              textColor=GRIS, spaceBefore=1, spaceAfter=6),
        "aviso": ParagraphStyle("aviso", fontName="DejaVu", fontSize=8.5, leading=11,
                                textColor=TINTA),
        "th": ParagraphStyle("th", fontName="DejaVuBold", fontSize=7, leading=9, textColor=white),
        "td": ParagraphStyle("td", fontName="DejaVu", fontSize=7, leading=9, textColor=TINTA),
    }


class Paginas:
    def __init__(self):
        self.n = 0

    def pintar(self, canvas, doc):
        self.n += 1
        canvas.saveState()
        canvas.setFillColor(AMBAR)
        canvas.rect(0, A4[1] - 8 * mm, A4[0], 8 * mm, fill=1, stroke=0)
        canvas.setFillColor(white)
        canvas.setFont("DejaVu", 8)
        canvas.drawString(16 * mm, A4[1] - 5.4 * mm, "Orbit Terminal  ·  manual de montaje  ·  provisional")
        canvas.setFillColor(GRIS)
        canvas.setFont("DejaVu", 8)
        canvas.drawString(16 * mm, 8 * mm, "CAD de la rama  ·  2026-10-22  ·  no es un montaje probado")
        canvas.drawRightString(A4[0] - 16 * mm, 8 * mm, str(self.n))
        canvas.restoreState()


def pdf():
    st = estilos()
    ancho = A4[0] - 32 * mm
    paginas = Paginas()
    doc = SimpleDocTemplate(
        str(PDF), pagesize=A4,
        leftMargin=16 * mm, rightMargin=16 * mm,
        topMargin=14 * mm, bottomMargin=14 * mm,
        title="Orbit Terminal — manual de montaje",
        author="Orbit Terminal",
    )
    flujo = []
    for b in BLOQUES:
        k = b[0]
        if k == "h1":
            flujo.append(CondPageBreak(28 * mm))
            flujo.append(Paragraph(esc(b[1]), st["h1"]))
        elif k == "h2":
            flujo.append(Paragraph(esc(b[1]), st["h2"]))
        elif k == "p":
            flujo.append(Paragraph(esc(b[1]), st["p"]))
        elif k == "warn":
            aviso = Paragraph("<b>Aviso. </b>" + esc(b[1]), st["aviso"])
            t = Table([[aviso]], colWidths=[ancho])
            t.setStyle(TableStyle([
                ("BACKGROUND", (0, 0), (-1, -1), Color(1, 0.95, 0.88)),
                ("BOX", (0, 0), (-1, -1), 0.4, AMBAR),
                ("LEFTPADDING", (0, 0), (-1, -1), 6),
                ("RIGHTPADDING", (0, 0), (-1, -1), 6),
                ("TOPPADDING", (0, 0), (-1, -1), 4),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ]))
            flujo += [t, Spacer(1, 3 * mm)]
        elif k == "ul":
            items = [ListItem(Paragraph(esc(x), st["li"]), leftIndent=8) for x in b[1]]
            flujo.append(ListFlowable(items, bulletType="bullet", start="•",
                                      leftIndent=12, bulletFontName="DejaVu",
                                      bulletFontSize=8, spaceAfter=3))
        elif k == "img":
            ruta = IMG / f"{b[1]}.png"
            with PILImage.open(ruta) as im:
                iw, ih = im.size
            w = ancho
            h = w * ih / iw
            if h > 105 * mm:
                h = 105 * mm
                w = h * iw / ih
            flujo.append(Image(str(ruta), width=w, height=h))
            flujo.append(Paragraph(esc(b[2]), st["pie"]))
        elif k == "table":
            cab, filas = b[1], b[2]
            n = len(cab)
            # La primera columna un poco más ancha si hay cinco.
            if n == 5:
                anchos = [32 * mm, 14 * mm, 46 * mm, 48 * mm, 38 * mm]
            elif n == 4:
                anchos = [48 * mm, 12 * mm, 62 * mm, 56 * mm]
            else:
                anchos = [ancho / n] * n
            datos = [[Paragraph(esc(c), st["th"]) for c in cab]]
            for f in filas:
                datos.append([Paragraph(esc(c), st["td"]) for c in f])
            t = Table(datos, colWidths=anchos, repeatRows=1)
            estilo = [
                ("BACKGROUND", (0, 0), (-1, 0), Color(0.22, 0.22, 0.24)),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("GRID", (0, 0), (-1, -1), 0.2, Color(0.8, 0.8, 0.8)),
                ("LEFTPADDING", (0, 0), (-1, -1), 2),
                ("RIGHTPADDING", (0, 0), (-1, -1), 2),
                ("TOPPADDING", (0, 0), (-1, -1), 2),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 2),
            ]
            for i in range(1, len(datos)):
                if i % 2 == 0:
                    estilo.append(("BACKGROUND", (0, i), (-1, i), FILA))
            t.setStyle(TableStyle(estilo))
            flujo += [t, Spacer(1, 3 * mm)]
    doc.build(flujo, onFirstPage=paginas.pintar, onLaterPages=paginas.pintar)
    return paginas.n


def main():
    DOCS.mkdir(parents=True, exist_ok=True)
    contenido()
    markdown()
    n = pdf()
    print(f"PDF {PDF} páginas {n}")


if __name__ == "__main__":
    main()
