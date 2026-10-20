"""ORBIT TERMINAL · añade títulos, el aviso obligatorio y las etiquetas a los renders de Blender,
y compone la lámina «lo que tienes vs. dónde va».

Uso: python3 postproceso.py RAW_DIR SALIDA_DIR [DIR_FOTOS]
DIR_FOTOS (opcional): fotos de Miguel para la lámina 06 (no se suben al repo).
"""
import sys, os, json
from PIL import Image, ImageDraw, ImageFont, ImageOps, ImageFilter

RAW, OUT = sys.argv[1], sys.argv[2]
FOTOS = sys.argv[3] if len(sys.argv) > 3 else None
os.makedirs(OUT, exist_ok=True)
FD = "/usr/share/fonts/truetype/dejavu/"
def F(s, b=False, c=False): return ImageFont.truetype(FD + ("DejaVuSansCondensed" if c else "DejaVuSans") + ("-Bold" if b else "") + ".ttf", s)
AMB = (255, 160, 40); BL = (235, 235, 235); GR = (160, 160, 165)
AVISO = "Render del diseño CAD — no es una foto ni un prototipo fabricado"
CONFIG = "MSI PRO MP161 E2U 15,6\" · placa HP 260-a110ns (mini-ITX) · HDD 3,5\" · Raspberry Pi 4 · modo C (capturadora) · Arduino Micro (render desfasado: el CAD de 2026-10-20 es un Nano)"

def panel(d, xy, alpha_img, fill=(10, 10, 12, 190), r=10):
    d.rounded_rectangle(xy, r, fill=fill)
def rotulos(im, titulo, sub=None):
    im = im.convert("RGBA"); W, H = im.size; k = W/1920
    ov = Image.new("RGBA", im.size, (0, 0, 0, 0)); d = ImageDraw.Draw(ov)
    # título (arriba a la izquierda)
    ft, fs = F(int(30*k), True), F(int(19*k))
    tw = max(d.textlength(titulo, font=ft), d.textlength(sub or "", font=fs))
    panel(d, (int(28*k), int(26*k), int(28*k + tw + 44*k), int(26*k + (92 if sub else 62)*k)), ov)
    d.rectangle((int(28*k), int(26*k), int(33*k), int(26*k + (92 if sub else 62)*k)), fill=AMB + (255,))
    d.text((int(50*k), int(36*k)), titulo, font=ft, fill=BL + (255,))
    if sub: d.text((int(50*k), int(76*k)), sub, font=fs, fill=GR + (255,))
    # aviso obligatorio (esquina inferior izquierda) + configuración
    fa, fc = F(int(19*k), True), F(int(15*k))
    aw = max(d.textlength(AVISO, font=fa), d.textlength(CONFIG, font=fc))
    y0 = H - int(78*k)
    panel(d, (int(24*k), y0, int(24*k + aw + 36*k), H - int(20*k)), ov, fill=(8, 8, 10, 205))
    d.text((int(42*k), y0 + int(10*k)), AVISO, font=fa, fill=AMB + (255,))
    d.text((int(42*k), y0 + int(36*k)), CONFIG, font=fc, fill=GR + (255,))
    # firma (esquina inferior derecha)
    fsg = F(int(15*k), True); s = "ORBIT TERMINAL · diseño v3"
    d.text((W - int(30*k) - d.textlength(s, font=fsg), H - int(44*k)), s, font=fsg, fill=(200, 200, 200, 170))
    return Image.alpha_composite(im, ov).convert("RGB")

LUGAR = {"Disco Toshiba 3,5\"": ("arriba", 0.52), "Tira LED ámbar": ("abajo", 0.70)}
def etiquetas(im, anclas, numeros=False):
    im = im.convert("RGBA"); W, H = im.size; k = W/1920
    ov = Image.new("RGBA", im.size, (0, 0, 0, 0)); d = ImageDraw.Draw(ov)
    f = F(int(21*k), True); gap = 50*k
    def caja_txt(txt, cx, cy, ax, ay, lado):
        tw = d.textlength(txt, font=f)
        if lado == "i": bx0 = 40*k; bx1 = bx0 + tw + 28*k; pts = [(bx1, cy), (ax - 40*k if ax - 40*k > bx1 else bx1, cy), (ax, ay)]
        elif lado == "d": bx1 = W - 40*k; bx0 = bx1 - tw - 28*k; pts = [(bx0, cy), (ax + 40*k if ax + 40*k < bx0 else bx0, cy), (ax, ay)]
        else:
            bx0 = cx - tw/2 - 14*k; bx1 = cx + tw/2 + 14*k
            pts = [(cx, cy + (19*k if lado == "arriba" else -19*k)), (ax, ay)]
        d.line(pts, fill=AMB + (230,), width=max(2, int(2*k)))
        d.ellipse((ax - 7*k, ay - 7*k, ax + 7*k, ay + 7*k), fill=AMB + (255,), outline=(20, 20, 20, 255), width=max(1, int(2*k)))
        d.rounded_rectangle((bx0, cy - 19*k, bx1, cy + 19*k), int(8*k), fill=(10, 10, 12, 215), outline=AMB + (200,), width=max(1, int(2*k)))
        d.text((bx0 + 14*k, cy - 13*k), txt, font=f, fill=BL + (255,))
    lados = {"i": [], "d": []}
    for n, (u, v) in anclas.items():
        if n in LUGAR:
            modo, cx = LUGAR[n]
            caja_txt(n, cx*W, (0.165 if modo == "arriba" else 0.875)*H, u*W, v*H, modo)
        else: lados["i" if u < 0.5 else "d"].append((n, u*W, v*H))
    for lado, lista in lados.items():
        lista.sort(key=lambda t: t[2]); ys = []
        for (_, _, ay) in lista: ys.append(max(ay, (ys[-1] + gap) if ys else 0.17*H))
        exceso = ys[-1] - 0.80*H if ys else 0
        if exceso > 0: ys = [max(0.17*H, y - exceso) for y in ys]
        for i in range(1, len(ys)): ys[i] = max(ys[i], ys[i-1] + gap)
        for (n, ax, ay), cy in zip(lista, ys): caja_txt(n, 0, cy, ax, ay, lado)
    return Image.alpha_composite(im, ov).convert("RGB")

R = lambda n: Image.open(os.path.join(RAW, n + ".png"))
lam = [
    ("01_frontal_3-4", "hero", "Vista frontal 3/4", "La MSI en la cuña con la interfaz Orbit (inicio) · pomos y botones a la derecha · tira LED ámbar"),
    ("02_perfil_lateral", "lateral", "Perfil lateral (lado izquierdo)", "Inclinación de 30° · I/O frontal del HP y pulsador de encendido en el lateral"),
    ("03_trasera_3-4", "trasera", "Trasera 3/4", "Ventana I/O del HP (DC, VGA, HDMI, USB, RJ45, audio) · pasacables encima · panel de conectores"),
    ("04_explosionado", "explosionado", "Vista explosionada", "Bisel · MSI · carcasa · mandos · componentes · soportes · base · bandeja de servicio · guía LED"),
    ("05_interior_cenital", "interior", "Interior visto desde arriba", "Sin carcasa, monitor ni mandos exteriores · la caja translúcida es la reserva de la capturadora"),
    ("07_detalle_mandos", "detalle", "Detalle de la consola de mandos", "Pomos con anillo de luz ámbar · pulsadores de 16 mm · textura de capas del PETG"),
]
for nombre, raw, t, s in lam:
    p = os.path.join(RAW, raw + ".png")
    if not os.path.exists(p): print("falta", p); continue
    im = R(raw)
    if raw == "interior":
        an = json.load(open(os.path.join(RAW, "anclas_interior.json")))
        im = etiquetas(im, an)
    rotulos(im, t, s).save(os.path.join(OUT, nombre + ".png"), optimize=True)
    print("ok", nombre)

# ---------------------------------------------------------------- 06: lo que tienes vs. dónde va
def recorte(foto, caja):
    im = ImageOps.exif_transpose(Image.open(foto)); W, H = im.size
    return im.crop((int(caja[0]*W), int(caja[1]*H), int(caja[2]*W), int(caja[3]*H)))
def lamina6(con_fotos, salida):
    an = json.load(open(os.path.join(RAW, "anclas_interior.json")))
    piezas = [  # (número, nombre, dónde va, ancla, foto, recorte)
        (1, "Monitor MSI PRO MP161 E2U", "En la cuña inclinada, bajo el bisel (se quita para verlo)", None, "69baf98ea28064096ff854352b30811ad563b5ae1662ac08de12d4eee8cda97f.jpg", (0.0, 0.6, 0.62, 0.98)),
        (2, "Placa del HP 260-a110ns", "Al fondo a la izquierda, I/O contra la trasera", "Placa del HP (mini-ITX 17 × 17 cm)", "9c6366137bdd97e6f8dcba6051c2b5f96307da70de61d3a996748920ab074ac5.jpg", (0.1, 0.3, 0.92, 0.9)),
        (3, "Disco Toshiba 3,5\"", "En el centro, sobre su soporte impreso", "Disco Toshiba 3,5\"", "445eb1a9ca9bba16a6567872ba13fe2be4732beb90ad6b4891e7ec6720dc9a85.jpg", (0.69, 0.51, 1.0, 0.79)),
        (4, "Raspberry Pi (¿Pi 4?)", "Atrás a la derecha, en la bandeja de servicio", "Raspberry Pi 4", "445eb1a9ca9bba16a6567872ba13fe2be4732beb90ad6b4891e7ec6720dc9a85.jpg", (0.33, 0.42, 0.55, 0.53)),
        (5, "Capturadora HDMI→USB", "Delante de la Pi (hueco reservado; aún no comprada)", "Capturadora HDMI→USB (hueco)", None, None),
        (6, "Arduino Micro", "Bajo la consola, en su soporte", "Arduino Micro", None, None),
        (7, "2 potenciómetros + 2 botones", "Consola de mandos (lado derecho)", "Potenciómetros (2) y botones (2)", None, None),
        (8, "Tira LED ámbar", "Canal frontal, detrás de la guía de luz", "Tira LED ámbar", None, None),
    ]
    W, H = 2560, 1440
    lam6 = Image.new("RGB", (W, H), (14, 14, 16)); d = ImageDraw.Draw(lam6)
    # render interior a la derecha
    ri = R("interior"); rw = 1640; rh = int(ri.height*rw/ri.width)
    ri = ri.resize((rw, rh), Image.LANCZOS); rx, ry = W - rw - 40, 170
    # recorte: centrar en la zona útil
    lam6.paste(ri, (rx, ry))
    col_w = rx - 100
    fila_h = (H - 230 - 100) // 4
    for i, (n, nombre, donde, ancla, foto, caja) in enumerate(piezas):
        c, f_ = i // 4, i % 4
        cw = (col_w - 20)//2
        x0 = 60 + c*(cw + 20); y0 = 180 + f_*fila_h; x1 = x0 + cw; y1 = y0 + fila_h - 18
        d.rounded_rectangle((x0, y0, x1, y1), 12, fill=(24, 24, 27), outline=(55, 55, 60), width=2)
        th = y1 - y0 - 110
        if con_fotos and foto and FOTOS and os.path.exists(os.path.join(FOTOS, foto)):
            im = recorte(os.path.join(FOTOS, foto), caja); im = ImageOps.fit(im, (cw - 24, th), Image.LANCZOS)
            lam6.paste(im, (x0 + 12, y0 + 12))
            d.rounded_rectangle((x0 + 16, y0 + 16, x0 + 170, y0 + 44), 6, fill=(0, 0, 0))
            d.text((x0 + 24, y0 + 20), "foto de Miguel", font=F(16, True), fill=(255, 255, 255))
        elif ancla or n == 1:
            # versión pública: ampliación del propio render (sin fotos personales)
            fuente = R("hero") if n == 1 else R("interior")
            if n == 1: zc = (0.30, 0.18, 0.78, 0.72)
            else:
                u, v = an[ancla]; zc = (u - 0.09, v - 0.11, u + 0.09, v + 0.11)
            fw_, fh_ = fuente.size
            im = fuente.crop((int(zc[0]*fw_), int(zc[1]*fh_), int(zc[2]*fw_), int(zc[3]*fh_)))
            im = ImageOps.fit(im, (cw - 24, th), Image.LANCZOS); lam6.paste(im, (x0 + 12, y0 + 12))
            d.rounded_rectangle((x0 + 16, y0 + 16, x0 + 110, y0 + 44), 6, fill=(0, 0, 0))
            d.text((x0 + 24, y0 + 20), "render", font=F(16, True), fill=AMB)
        else:
            d.rounded_rectangle((x0 + 12, y0 + 12, x1 - 12, y0 + 12 + th), 8, fill=(18, 18, 20), outline=(45, 45, 50))
            d.text((x0 + 30, y0 + th//2 - 4), "sin foto todavía", font=F(20), fill=(110, 110, 115))
        d.ellipse((x0 + 14, y1 - 92, x0 + 56, y1 - 50), fill=AMB); d.text((x0 + 35, y1 - 71), str(n), font=F(24, True), fill=(15, 15, 15), anchor="mm")
        d.text((x0 + 68, y1 - 92), nombre, font=F(21, True, True), fill=BL)
        # texto "dónde va" en 1-2 líneas
        fw = F(17, False, True); pal = donde.split(); lin = [""]
        for p in pal:
            if d.textlength(lin[-1] + " " + p, font=fw) > cw - 80: lin.append(p)
            else: lin[-1] = (lin[-1] + " " + p).strip()
        for j, l in enumerate(lin[:2]): d.text((x0 + 68, y1 - 62 + j*21), l, font=fw, fill=GR)
        # marcador numerado sobre el render
        if ancla and ancla in an:
            u, v = an[ancla]; px, py = rx + u*rw, ry + v*rh
            d.ellipse((px - 22, py - 22, px + 22, py + 22), fill=AMB, outline=(15, 15, 15), width=3)
            d.text((px, py), str(n), font=F(24, True), fill=(15, 15, 15), anchor="mm")
    d.text((rx + 20, ry + rh + 16), "1 · El monitor va encima, en la cuña (ver vistas 01 y 04).", font=F(20), fill=GR)
    sub = ("Izquierda: tus piezas (fotos tuyas) · Derecha: render del diseño CAD con cada pieza en su sitio" if con_fotos
           else "Izquierda: cada pieza ampliada del render · Derecha: render del diseño CAD con cada pieza en su sitio")
    rotulos(lam6, "Lo que tienes vs. dónde va", sub).save(salida, optimize=True)
    print("ok", salida)
if os.path.exists(os.path.join(RAW, "interior.png")):
    lamina6(False, os.path.join(OUT, "06_lo-que-tienes-vs-donde-va.png"))
    if FOTOS:   # versión con fotos personales: NO va al repo (público); se guarda aparte
        lamina6(True, os.environ.get("ORBIT_LAMINA_FOTOS", "/workspace/orbit-renders-privado/06_lo-que-tienes-vs-donde-va_con-fotos.png"))
