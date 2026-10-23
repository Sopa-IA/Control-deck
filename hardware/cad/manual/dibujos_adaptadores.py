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
    titulo(d, "Marco, por fuera. La ventana de 62 × 18 no se toca.")
    d.rectangle((220, 150, 1180, 470), outline=LINEA, width=4)
    d.rectangle((300, 210, 1100, 410), outline=AMBAR, width=6)
    d.text((520, 280), "boca  ~60 × 16", fill=TINTA, font=fuente(32))
    d.text((340, 430), "USB", fill=AMBAR, font=fuente(28))
    d.text((980, 430), "SD", fill=AMBAR, font=fuente(28))
    cota(d, 300, 520, 1100, 520, "62 mm, el hueco impreso")
    cota(d, 1140, 210, 1140, 410, "18 mm", vertical=True)
    d.text((220, 560), "Se pierden los dos jacks. Si el lector no asoma, se pierde también. No limes la carcasa.", fill=GRIS, font=fuente(24))
    guardar(im, "s6_5")


def s9_1():
    im, d = nueva()
    titulo(d, "Tapa maciza, por dentro. Un tetón en cada agujero viejo.")
    d.rectangle((160, 150, 1240, 470), outline=LINEA, width=4)
    d.text((430, 270), "sin ranuras", fill=TINTA, font=fuente(36))
    d.text((160, 500), "Audio, USB, HDMI, RJ45 y DC quedan ciegos. La Pi se alcanza por la tapa del techo.", fill=GRIS, font=fuente(26))
    d.text((160, 545), "No se corta la trasera. Sin tornillo.", fill=GRIS, font=fuente(26))
    guardar(im, "s9_1")


def s9_2():
    im, d = nueva()
    titulo(d, "Careta por fuera. Rótulos abajo, en la cama. Ganchos hacia arriba.")
    d.rectangle((180, 70, 1220, 530), outline=LINEA, width=4)
    d.rectangle((280, 360, 980, 400), outline=AMBAR, width=5)
    d.rectangle((280, 410, 980, 450), outline=AMBAR, width=5)
    d.text((500, 365), "2×20   PI", fill=TINTA, font=fuente(28))
    d.rectangle((340, 250, 820, 290), outline=AMBAR, width=5)
    d.rectangle((340, 200, 820, 240), outline=AMBAR, width=5)
    d.text((460, 205), "2×12   NANO", fill=TINTA, font=fuente(28))
    d.text((430, 310), "NO UNIR", fill=AMBAR, font=fuente(28))
    d.rectangle((700, 90, 1040, 170), outline=LINEA, width=3)
    d.text((800, 110), "OLED", fill=GRIS, font=fuente(26))
    d.rectangle((240, 100, 420, 170), outline=LINEA, width=3)
    d.text((280, 115), "PRG", fill=GRIS, font=fuente(26))
    d.text((180, 555), "Pines macho desde dentro. Se pierden D0, D1 y el resto de una 2×15. Sin tornillo.", fill=GRIS, font=fuente(24))
    guardar(im, "s9_2")


def main():
    s5_0(); s6_5(); s9_1(); s9_2()
    print("png", OUT)


if __name__ == "__main__":
    main()
