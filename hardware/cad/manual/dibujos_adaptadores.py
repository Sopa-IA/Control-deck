#!/usr/bin/env python3
"""Figuras de cota de los cuatro adaptadores. No pasan por OpenSCAD."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

OUT = Path(__file__).resolve().parents[3] / "docs" / "manual_montaje" / "img"
W, H = 1400, 620
TINTA = (28, 26, 24)
PAPEL = (247, 242, 232)
AMBAR = (196, 98, 20)
GRIS = (90, 84, 76)
LINEA = (40, 36, 32)


def fuente(px):
    for ruta in ("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
                 "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"):
        if Path(ruta).exists() and px >= 28:
            return ImageFont.truetype(
                ruta.replace("DejaVuSans.ttf", "DejaVuSans-Bold.ttf") if px >= 36 else ruta, px)
    return ImageFont.load_default()


def nueva():
    im = Image.new("RGB", (W, H), PAPEL)
    return im, ImageDraw.Draw(im)


def titulo(d, texto):
    d.text((36, 28), texto, fill=TINTA, font=fuente(36))


def cota(d, x0, y0, x1, y1, texto, vertical=False):
    d.line((x0, y0, x1, y1), fill=AMBAR, width=3)
    if vertical:
        d.text((x0 + 10, (y0 + y1) / 2 - 16), texto, fill=AMBAR, font=fuente(28))
    else:
        d.text(((x0 + x1) / 2 - 40, y0 - 36), texto, fill=AMBAR, font=fuente(28))


def guardar(im, nombre):
    OUT.mkdir(parents=True, exist_ok=True)
    im.save(OUT / f"{nombre}.png")


def s5_0():
    im, d = nueva()
    titulo(d, "Prueba, por fuera. VGA a la izquierda. Si no cae, no montes.")
    x, y, w, h = 80, 140, 1240, 360
    d.rectangle((x, y, x + w, y + h), outline=LINEA, width=4)
    huecos = [
        (40, 200, 250, 110, "VGA"),
        (320, 190, 120, 80, "HDMI"),
        (470, 280, 120, 130, "USB 3"),
        (620, 360, 160, 250, "RJ45 + USB"),
        (820, 370, 130, 270, "audio"),
        (990, 160, 90, 90, "DC"),
        (1000, 400, 90, 80, "pines"),
    ]
    for hx, hy, hw, hh, nombre in huecos:
        d.rectangle((x + hx, y + h - hy - hh, x + hx + hw, y + h - hy), outline=AMBAR, width=4)
        d.text((x + hx + 8, y + h - hy - hh + 8), nombre, fill=TINTA, font=fuente(26))
    d.text((80, 540), "Ventana ya impresa 159,75 × 45,45 mm. No se corta. Escala: el ancho, no la regla.", fill=GRIS, font=fuente(26))
    guardar(im, "s5_0")


def s6_5():
    im, d = nueva()
    titulo(d, "Lateral izquierdo. Solo se corta hacia el frente.")
    d.rectangle((180, 160, 1180, 420), outline=LINEA, width=4)
    d.rectangle((520, 230, 1100, 380), outline=GRIS, width=3)
    d.rectangle((220, 230, 1100, 380), outline=AMBAR, width=5)
    d.text((560, 280), "ventana impresa  62 × 18", fill=GRIS, font=fuente(26))
    d.text((250, 190), "corte nuevo", fill=AMBAR, font=fuente(28))
    cota(d, 220, 450, 520, 450, "32 mm")
    cota(d, 220, 500, 1100, 500, "94 mm")
    cota(d, 1140, 230, 1140, 380, "18 mm", vertical=True)
    d.text((180, 540), "El borde de atrás no se toca: a 0,9 mm está el pulsador. No subas ni bajes.", fill=GRIS, font=fuente(26))
    guardar(im, "s6_5")


def s6_6():
    im, d = nueva()
    titulo(d, "Marco. Cara plana abajo. Insertos desde arriba.")
    d.rectangle((200, 120, 1180, 500), outline=LINEA, width=4)
    d.rectangle((280, 250, 1120, 470), outline=AMBAR, width=5)
    d.text((560, 330), "hueco  92 × 14", fill=TINTA, font=fuente(28))
    d.line((460, 180, 460, 230), fill=AMBAR, width=4)
    d.line((900, 180, 900, 230), fill=AMBAR, width=4)
    d.ellipse((440, 160, 480, 200), outline=AMBAR, width=4)
    d.ellipse((880, 160, 920, 200), outline=AMBAR, width=4)
    cota(d, 460, 80, 900, 80, "60 mm")
    d.text((200, 540), "Canal de 1,3 mm para la pestaña. Dos insertos M3 de 4×5. No es la carcasa.", fill=GRIS, font=fuente(26))
    guardar(im, "s6_6")


def s6_7():
    im, d = nueva()
    titulo(d, "Primero la pestaña al marco. Después, cola a la pared.")
    d.rectangle((120, 180, 1280, 460), outline=LINEA, width=4)
    d.text((160, 210), "1  Taladra la pestaña si hace falta. No taladres la carcasa.", fill=TINTA, font=fuente(30))
    d.text((160, 270), "2  Dos M3×6 avellanados, desde la cara que se pega.", fill=TINTA, font=fuente(30))
    d.text((160, 330), "3  Cola en esa cara. El resalte de 2 mm centra el corte.", fill=TINTA, font=fuente(30))
    d.text((160, 390), "4  Reborde de atrás: 0,4 mm. No tapa el pulsador.", fill=TINTA, font=fuente(30))
    guardar(im, "s6_7")


def s9_1():
    im, d = nueva()
    titulo(d, "Trasera, desde fuera. Rectángulo de los cables de la Pi.")
    d.rectangle((160, 200, 1220, 460), outline=AMBAR, width=5)
    d.text((420, 300), "150 × 40 mm", fill=TINTA, font=fuente(36))
    d.text((180, 150), "tu izquierda  ·  unos 70 mm más allá del DC viejo", fill=GRIS, font=fuente(26))
    d.text((700, 470), "tu derecha  ·  unos 3 mm más allá del audio viejo", fill=GRIS, font=fuente(26))
    d.text((160, 540), "No llegues a la costura (unos 10 mm a tu derecha). Abajo, la orejeta queda 3 mm bajo el corte.", fill=GRIS, font=fuente(24))
    guardar(im, "s9_1")


def s9_2():
    im, d = nueva()
    titulo(d, "Placa por dentro. Hueco ancho a tu izquierda, mirando desde fuera.")
    d.rectangle((140, 140, 1260, 480), outline=LINEA, width=4)
    d.rectangle((220, 200, 620, 400), outline=AMBAR, width=5)
    d.rectangle((700, 210, 920, 390), outline=AMBAR, width=5)
    d.text((300, 280), "cables USB", fill=TINTA, font=fuente(30))
    d.text((740, 280), "red", fill=TINTA, font=fuente(30))
    d.text((980, 250), "macizo:", fill=GRIS, font=fuente(28))
    d.text((980, 300), "tapa los", fill=GRIS, font=fuente(28))
    d.text((980, 350), "agujeros viejos", fill=GRIS, font=fuente(28))
    d.text((140, 530), "Reborde estrecho (2,2 mm) hacia la costura. Muesca de abajo: libra la orejeta. Sin tornillo.", fill=GRIS, font=fuente(24))
    guardar(im, "s9_2")


def s9_3():
    im, d = nueva()
    titulo(d, "Segundo rectángulo. 22 mm por encima del de la Pi.")
    d.rectangle((360, 80, 1040, 500), outline=AMBAR, width=5)
    d.text((560, 260), "74 × 60 mm", fill=TINTA, font=fuente(36))
    d.text((360, 520), "Cubre los agujeritos, la OLED y PRG. No toques el corte de abajo.", fill=GRIS, font=fuente(26))
    guardar(im, "s9_3")


def s9_4():
    im, d = nueva()
    titulo(d, "Cara de fuera abajo, en la cama. Al montar, esa cara queda fuera.")
    d.rectangle((160, 80, 1240, 520), outline=LINEA, width=4)
    d.rectangle((280, 300, 980, 420), outline=AMBAR, width=5)
    d.text((480, 340), "2×20   Pi", fill=TINTA, font=fuente(30))
    d.rectangle((420, 160, 900, 250), outline=AMBAR, width=5)
    d.text((520, 185), "2×15   Nano", fill=TINTA, font=fuente(30))
    d.rectangle((700, 80, 980, 150), outline=LINEA, width=3)
    d.text((760, 95), "OLED", fill=GRIS, font=fuente(26))
    d.rectangle((220, 80, 400, 160), outline=LINEA, width=3)
    d.text((270, 100), "PRG", fill=GRIS, font=fuente(26))
    d.text((160, 550), "Regletas por dentro, enchufes hacia fuera. No unas 5 V con 3,3 V. Sin tornillo.", fill=GRIS, font=fuente(24))
    guardar(im, "s9_4")


def main():
    s5_0(); s6_5(); s6_6(); s6_7(); s9_1(); s9_2(); s9_3(); s9_4()
    print("png", OUT)


if __name__ == "__main__":
    main()
