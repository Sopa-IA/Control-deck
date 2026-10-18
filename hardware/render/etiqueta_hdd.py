"""Etiqueta GENÉRICA para el HDD 3,5" del render (sin logotipos de marca)."""
import sys
from PIL import Image, ImageDraw, ImageFont
out = sys.argv[1] if len(sys.argv) > 1 else "/tmp/orbit-render/etiqueta_hdd.png"
W, H = 856, 1050
im = Image.new("RGB", (W, H), (232, 232, 228)); d = ImageDraw.Draw(im)
F = lambda s, b=False: ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans%s.ttf" % ("-Bold" if b else ""), s)
d.rectangle([0, 0, W, 120], fill=(30, 30, 32)); d.text((40, 30), "HDD 3,5\"  ·  1 TB  ·  SATA", font=F(48, True), fill=(240, 240, 240))
for i, t in enumerate(["Disco duro de 3,5\" (SFF-8301)", "101,6 × 147 × 26,1 mm", "Etiqueta ilustrativa del render", "(el disco real es un Toshiba de 2017)"]):
    d.text((40, 170 + i*60), t, font=F(36), fill=(40, 40, 40))
for i in range(60):
    x = 40 + i*12; d.rectangle([x, 470, x + (4 if i % 3 else 8), 590], fill=(20, 20, 20))
d.text((40, 620), "S/N 0000-ORBIT-PROTO", font=F(30), fill=(60, 60, 60))
d.rectangle([40, 700, W - 40, 1010], outline=(90, 90, 90), width=3)
d.text((70, 730), "No abrir. Garantía nula si se retira.", font=F(28), fill=(80, 80, 80))
im.save(out)
