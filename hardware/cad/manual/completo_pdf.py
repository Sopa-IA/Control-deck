#!/usr/bin/env python3
"""Manual completo, estilo IKEA: un paso, una acción, una figura.

Fuente: este archivo y hardware/cad/manual/completo.scad.
Salida: docs/manual_completo/ (PNG, README y PDF).
No lee ni escribe el repo privado inventario-taller.
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont
from reportlab.lib.colors import HexColor, white
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    Image as RLImage,
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

RAIZ = Path(__file__).resolve().parents[3]
CAD = RAIZ / "hardware" / "cad"
SALIDA = RAIZ / "docs" / "manual_completo"
IMG = SALIDA / "img"
PDF = SALIDA / "Orbit_manual_completo.pdf"
README = SALIDA / "README.md"
SCAD = CAD / "manual" / "completo.scad"
PARTES = CAD / "partes.scad"

pdfmetrics.registerFont(TTFont("DejaVu", "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"))
pdfmetrics.registerFont(TTFont("DejaVuBold", "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"))
MONO = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"

TINTA = HexColor("#1c1c1e")
GRIS = HexColor("#5e6168")
AMBAR = HexColor("#e07a1f")
CREMA = HexColor("#fff6ea")
LINEA = HexColor("#d5d0c6")
PAPEL = HexColor("#f7f4ee")

TITULOS: list[str] = []


def _font(size, bold=False):
    return ImageFont.truetype(
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        size,
    )


def _mono(size):
    return ImageFont.truetype(MONO, size)


def _tiene_cuerpo(png: Path) -> bool:
    if not png.exists() or png.stat().st_size < 2500:
        return False
    im = Image.open(png).convert("L").resize((80, 60))
    return sum(im.histogram()[:210]) > 40


def render_scad(png: Path, args: list[str]) -> None:
    if _tiene_cuerpo(png) and "--forzar" not in sys.argv:
        return
    png.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        "openscad", "-o", str(png),
        "--imgsize", "1100,820",
        "--viewall", "--autocenter",
        "--projection", "ortho",
        "--colorscheme", "Tomorrow",
        *args,
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    err = proc.stderr or ""
    if proc.returncode != 0 or "ERROR:" in err or "Parser error" in err:
        raise SystemExit(f"Fallo al renderizar {png.name}\n{err[-2000:]}")
    if not png.exists() or png.stat().st_size < 2500:
        raise SystemExit(f"Figura vacía: {png}")
    im = Image.open(png).convert("L")
    oscuros = sum(im.histogram()[:210])
    if oscuros < 800:
        raise SystemExit(f"Figura casi en blanco: {png} ({oscuros} px)")


def pieza(nombre: str, parte: str, **defs) -> Path:
    png = IMG / f"p_{nombre}.png"
    args = ["-D", f'parte="{parte}"']
    for k, v in defs.items():
        args += ["-D", f"{k}={v}"]
    args.append(str(PARTES))
    render_scad(png, args)
    return png


def vista(nombre: str) -> Path:
    png = IMG / f"v_{nombre}.png"
    render_scad(png, ["-D", f'vista="{nombre}"', str(SCAD)])
    return png


def pantalla(path: Path, titulo: str, filas: list[tuple[str, bool]], nota: str) -> Path:
    """Mockup de Raspberry Pi Imager. ILUSTRACIÓN, no una captura."""
    im = Image.new("RGB", (1200, 780), "#f4f1ea")
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((40, 36, 1160, 744), 18, fill="white", outline="#c8c2b4", width=3)
    d.rectangle((40, 36, 1160, 92), fill="#2a2a2e")
    d.text((64, 50), "Raspberry Pi Imager", font=_font(26, True), fill="white")
    d.text((860, 54), "ILUSTRACIÓN", font=_font(18, True), fill="#e07a1f")
    d.text((64, 120), titulo, font=_font(28, True), fill="#1c1c1e")
    y = 190
    for texto, activo in filas:
        color = "#e07a1f" if activo else "#f7f4ee"
        tinta = "white" if activo else "#1c1c1e"
        d.rounded_rectangle((80, y, 1120, y + 78), 12, fill=color, outline="#d5d0c6", width=2)
        d.text((110, y + 22), texto, font=_font(26, activo), fill=tinta)
        y += 96
    d.text((64, 690), nota, font=_font(20), fill="#5e6168")
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path)
    return path


def terminal(path: Path, lineas: list[tuple[str, str]]) -> Path:
    """Caja de terminal. kind: cmd | out | dim."""
    im = Image.new("RGB", (1200, 780), "#1c1c1e")
    d = ImageDraw.Draw(im)
    d.rectangle((0, 0, 1200, 48), fill="#2e2e32")
    for i, col in enumerate(("#e06a5f", "#e0b15f", "#6fbf6f")):
        d.ellipse((22 + i * 28, 14, 40 + i * 28, 32), fill=col)
    d.text((130, 12), "PowerShell  ·  ILUSTRACIÓN de la salida esperada", font=_font(18), fill="#c8c2b4")
    y = 78
    fuente = _mono(26)
    for kind, texto in lineas:
        color = {"cmd": "#f4f1ea", "out": "#d7d4cc", "ok": "#9ddead", "dim": "#8d9098"}[kind]
        if kind == "cmd":
            d.text((36, y), ">", font=fuente, fill="#e07a1f")
            d.text((70, y), texto, font=fuente, fill=color)
        else:
            d.text((36, y), texto, font=fuente, fill=color)
        y += 40
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path)
    return path


def tornillo_png(path: Path, tipo: str, leyenda: str) -> Path:
    im = Image.new("RGB", (700, 520), "#f7f4ee")
    d = ImageDraw.Draw(im)
    cx = 250
    if tipo == "boton":
        d.rectangle((cx - 18, 80, cx + 18, 360), fill="#b7bcc4", outline="#1c1c1e", width=3)
        d.rounded_rectangle((cx - 48, 360, cx + 48, 410), 8, fill="#8d929a", outline="#1c1c1e", width=3)
        d.line((cx - 16, 385, cx + 16, 385), fill="#1c1c1e", width=3)
        d.line((cx, 370, cx, 400), fill="#1c1c1e", width=3)
    elif tipo == "avell":
        d.rectangle((cx - 16, 80, cx + 16, 340), fill="#b7bcc4", outline="#1c1c1e", width=3)
        d.polygon([(cx - 52, 340), (cx + 52, 340), (cx, 410)], fill="#8d929a", outline="#1c1c1e")
    elif tipo == "tuerca":
        d.regular_polygon((cx, 240, 90), 6, fill="#c5c9cf", outline="#1c1c1e")
        d.ellipse((cx - 28, 212, cx + 28, 268), outline="#1c1c1e", width=4)
    elif tipo == "inserto":
        d.rounded_rectangle((cx - 36, 120, cx + 36, 360), 8, fill="#d4b483", outline="#1c1c1e", width=3)
        d.ellipse((cx - 16, 150, cx + 16, 182), outline="#1c1c1e", width=3)
    elif tipo == "capuchon":
        d.rectangle((cx - 16, 160, cx + 16, 360), fill="#b7bcc4", outline="#1c1c1e", width=3)
        d.rounded_rectangle((cx - 28, 80, cx + 28, 170), 20, fill="#f2f2f4", outline="#1c1c1e", width=3)
    else:
        d.rectangle((cx - 14, 90, cx + 14, 300), fill="#b7bcc4", outline="#1c1c1e", width=3)
        d.ellipse((cx - 40, 300, cx + 40, 380), fill="#8d929a", outline="#1c1c1e", width=3)
    d.text((40, 450), leyenda, font=_font(28, True), fill="#1c1c1e")
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path)
    return path


def problemas_png(path: Path) -> Path:
    im = Image.new("RGB", (1200, 900), "#f7f4ee")
    d = ImageDraw.Draw(im)
    filas = [
        ("No entra SSH", "Espera al Wi-Fi. El nombre es el de Imager, no tiene que ser pi."),
        ("orbitd no arranca", "sudo systemctl status orbitd. Si falla, vuelve a lanzar el script."),
        ("Hay puerta en eth0", "El perfil es orbit-enlace-hp: 10.0.0.2/24, sin puerta ni DNS."),
        ("No apaga", "Confirma en pantalla. Un toque corto no vale. Sin la UI abierta, no apaga."),
        ("El PC se iba a apagar", "El simulador no llama a systemctl. Para."),
        ("Moonlight no abre", "Empareja una vez: moonlight-qt pair 10.0.0.1 y el PIN en Sunshine."),
    ]
    y = 24
    for titulo, texto in filas:
        d.rounded_rectangle((24, y, 1176, y + 130), 12, fill="white", outline="#d5d0c6", width=2)
        d.rounded_rectangle((44, y + 28, 92, y + 76), 8, fill="#e07a1f")
        d.text((112, y + 24), titulo, font=_font(28, True), fill="#1c1c1e")
        d.text((112, y + 72), texto, font=_font(22), fill="#5e6168")
        y += 146
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path)
    return path


def integrada_png(path: Path) -> Path:
    im = Image.new("RGB", (1200, 780), "#101014")
    d = ImageDraw.Draw(im)
    d.rectangle((0, 0, 1200, 56), fill="#1c1c1e")
    d.text((24, 14), "ORBIT", font=_font(24, True), fill="#e07a1f")
    d.text((180, 16), "HP  ·  Pi  ·  40 px", font=_font(20), fill="#f4f1ea")
    d.rectangle((0, 56, 1200, 780), fill="#243044")
    d.text((80, 340), "Moonlight  ·  hueco bajo la barra", font=_font(32), fill="#d7e2f2")
    d.text((80, 400), "ILUSTRACIÓN de la vista integrada", font=_font(22), fill="#e07a1f")
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path)
    return path


def render_todo() -> dict[str, Path]:
    IMG.mkdir(parents=True, exist_ok=True)
    fotos: dict[str, Path] = {}
    piezas = [
        ("carcasa_00", "carcasa", {"ix": 0, "iy": 0}),
        ("carcasa_10", "carcasa", {"ix": 1, "iy": 0}),
        ("carcasa_01", "carcasa", {"ix": 0, "iy": 1}),
        ("carcasa_11", "carcasa", {"ix": 1, "iy": 1}),
        ("base_00", "base", {"ix": 0, "iy": 0}),
        ("base_10", "base", {"ix": 1, "iy": 0}),
        ("base_01", "base", {"ix": 0, "iy": 1}),
        ("base_11", "base", {"ix": 1, "iy": 1}),
        ("bisel_00", "bisel", {"ix": 0, "iy": 0}),
        ("bisel_10", "bisel", {"ix": 1, "iy": 0}),
        ("bisel_01", "bisel", {"ix": 0, "iy": 1}),
        ("bisel_11", "bisel", {"ix": 1, "iy": 1}),
        ("pletina", "pletina", {}),
        ("disco", "soporte_disco", {}),
        ("tapa", "tapa_pi", {}),
        ("bandeja", "bandeja", {}),
        ("grapa", "grapa", {}),
        ("pomo", "pomo", {}),
        ("anillo", "anillo", {}),
        ("guia0", "guia", {"k": 0}),
        ("guia1", "guia", {"k": 1}),
        ("boton", "boton_encendido", {}),
        ("soporte_b", "soporte_boton", {}),
        ("prueba_b", "prueba_boton", {}),
        ("marco", "marco_io_frontal", {}),
        ("placa_io", "placa_io_hp", {}),
        ("prueba_io", "prueba_placa_io_hp", {}),
        ("puertos", "placa_puertos_pi", {}),
        ("panel", "panel_pines", {}),
    ]
    for nombre, parte, defs in piezas:
        print("pieza", nombre, flush=True)
        fotos[nombre] = pieza(nombre, parte, **defs)
    vistas = [
        "ya_cerrada", "marco_expl", "marco_dentro", "prueba_io", "placa_io",
        "tapa_puertos", "panel", "regleta20", "regleta12", "capuchon",
        "prueba_boton", "capuchon_puesto", "soporte_boton", "pulsador",
        "hilos_boton", "bandeja", "pi_puesta", "pi_tornillos", "esp",
        "esp_tornillos", "nano_man", "nano_man_tornillos", "zero_span",
        "buck", "buck_pasante", "buck_grapa", "nano_prac", "nano_prac_tornillos",
        "dupont", "bandeja_torres", "bandeja_tornillos", "tapa_cama",
        "tapa_baja", "tapa_tornillos", "pomos", "anillo_pomo", "guia",
        "monitor", "bisel", "cable_eth", "diagrama", "soplante",
        "elec_hp", "elec_hdd", "elec_pi", "elec_hat", "elec_oled", "elec_fan",
        "faltan_dupont", "faltan_regleta", "faltan_632",
    ]
    for nombre in vistas:
        print("vista", nombre, flush=True)
        fotos[nombre] = vista(nombre)
    fotos["tor_m3_16"] = tornillo_png(IMG / "tor_m316.png", "boton", "M3×16 botón")
    fotos["tor_m3_12"] = tornillo_png(IMG / "tor_m312.png", "boton", "M3×12 botón")
    fotos["tor_m3_8"] = tornillo_png(IMG / "tor_m38.png", "boton", "M3×8 botón")
    fotos["tor_m25"] = tornillo_png(IMG / "tor_m25.png", "boton", "M2.5×8 botón")
    fotos["tor_cs8"] = tornillo_png(IMG / "tor_cs8.png", "avell", "M3×8 avellanado")
    fotos["tor_cs6"] = tornillo_png(IMG / "tor_cs6.png", "avell", "M3×6 avellanado")
    fotos["tuerca"] = tornillo_png(IMG / "tor_tuerca.png", "tuerca", "Tuerca M3")
    fotos["ins_55"] = tornillo_png(IMG / "tor_i55.png", "inserto", "Inserto M3 5×5")
    fotos["ins_45"] = tornillo_png(IMG / "tor_i45.png", "inserto", "Inserto M3 4×5")
    fotos["ins_65"] = tornillo_png(IMG / "tor_i65.png", "inserto", "Inserto M3 6×5")
    fotos["ins_m25"] = tornillo_png(IMG / "tor_im25.png", "inserto", "Inserto M2.5 4×3,5")
    fotos["capuchon_punta"] = tornillo_png(IMG / "tor_cap.png", "capuchon", "Capuchón de punta")
    fotos["fallos"] = problemas_png(IMG / "fallos.png")
    fotos["integrada"] = integrada_png(IMG / "integrada.png")
    fotos["soft_que"] = pantalla(
        IMG / "soft_que.png", "Qué hace falta",
        [("microSD 32 GB y lector", True), ("Cargador USB-C 5 V 3 A", False),
         ("Wi-Fi  ·  Nano de mandos y su cable", False), ("micro-HDMI, solo si quieres ver el arranque", False)],
        "ILUSTRACIÓN. El cable HDMI no hace falta para el SSH.",
    )
    fotos["soft_imager"] = pantalla(
        IMG / "soft_imager.png", "Instala Raspberry Pi Imager en Windows",
        [("Descarga el instalador desde raspberrypi.com", True), ("Siguiente, hasta que abra", False)],
        "ILUSTRACIÓN de la pantalla, no una captura.",
    )
    fotos["soft_dispositivo"] = pantalla(
        IMG / "soft_dev.png", "Elegir dispositivo",
        [("Raspberry Pi 4", True), ("Otras placas: no", False)],
        "Pulsa el modelo 4.",
    )
    fotos["soft_os"] = pantalla(
        IMG / "soft_os.png", "Elegir sistema",
        [("Raspberry Pi OS (64-bit)", True), ("con escritorio  ·  Bookworm o Trixie", True),
         ("Lite: no. Ahí no hay labwc.", False)],
        "La imagen de escritorio ya trae labwc.",
    )
    fotos["soft_sd"] = pantalla(
        IMG / "soft_sd.png", "Elegir almacenamiento",
        [("La microSD de 32 GB del lector", True), ("No elijas el disco del PC", False)],
        "Comprueba la letra de la unidad antes de escribir.",
    )
    fotos["soft_usuario"] = pantalla(
        IMG / "soft_user.png", "Personalización del sistema",
        [("Usuario y contraseña", True), ("Wi-Fi y su contraseña", True),
         ("Teclado es  ·  Europa/Madrid", False), ("Activar SSH", True)],
        "El usuario es el que tú pongas. No tiene que llamarse pi.",
    )
    fotos["soft_escribe"] = pantalla(
        IMG / "soft_write.png", "Escribir",
        [("Sí, escribir", True), ("Espera a Verificación correcta", False)],
        "No saques la tarjeta mientras verifica.",
    )
    fotos["soft_boot"] = pantalla(
        IMG / "soft_boot.png", "Primer arranque",
        [("Tarjeta en la Pi, USB-C, Wi-Fi", True), ("Espera a que el LED deje de parpadear", False)],
        "La pantalla puede quedarse en negro. El SSH no la necesita.",
    )
    fotos["soft_ssh"] = terminal(IMG / "soft_ssh.png", [
        ("cmd", "ssh USUARIO@raspberrypi.local"),
        ("out", "USUARIO@raspberrypi.local's password:"),
        ("ok", "USUARIO@raspberrypi:~ $"),
        ("dim", "USUARIO es el de Imager."),
    ])
    fotos["soft_clone"] = terminal(IMG / "soft_clone.png", [
        ("cmd", "git clone -b cursor/bandeja-v2-modular-6d15 https://github.com/Sopa-IA/Control-deck.git"),
        ("out", "Cloning into 'Control-deck'..."),
        ("ok", "done."),
    ])
    fotos["soft_cd"] = terminal(IMG / "soft_cd.png", [
        ("cmd", "cd Control-deck"),
        ("ok", "USUARIO@raspberrypi:~/Control-deck $"),
    ])
    fotos["soft_instala"] = terminal(IMG / "soft_instala.png", [
        ("cmd", "sudo bash scripts/instalar-pi.sh"),
        ("out", "== Listo. Reinicia la Pi para ver Orbit OS al encender."),
        ("ok", "Usuario de la sesión: USUARIO"),
        ("dim", "La segunda vez no cambia los tokens."),
    ])
    fotos["soft_reboot"] = terminal(IMG / "soft_reboot.png", [
        ("cmd", "sudo reboot"),
        ("out", "Connection to raspberrypi.local closed."),
    ])
    fotos["chk_ssh"] = terminal(IMG / "chk_ssh.png", [
        ("cmd", "ssh USUARIO@raspberrypi.local"),
        ("ok", "USUARIO@raspberrypi:~ $"),
    ])
    fotos["chk_orbit"] = terminal(IMG / "chk_orbit.png", [
        ("cmd", "systemctl status orbitd"),
        ("ok", "Active: active (running)"),
        ("dim", "En la pantalla se ve Orbit OS."),
    ])
    fotos["chk_wifi"] = terminal(IMG / "chk_wifi.png", [
        ("cmd", "ping -c 1 debian.org"),
        ("ok", "1 packets transmitted, 1 received"),
    ])
    fotos["chk_ruta"] = terminal(IMG / "chk_ruta.png", [
        ("cmd", "ip route"),
        ("out", "default via ... dev wlan0"),
        ("ok", "10.0.0.0/24 dev eth0 proto kernel scope link src 10.0.0.2"),
        ("dim", "No hay una línea default por eth0."),
    ])
    fotos["chk_dial"] = terminal(IMG / "chk_dial.png", [
        ("cmd", "grep dialout /etc/group"),
        ("ok", "dialout:x:20:USUARIO"),
    ])
    fotos["chk_off"] = pantalla(
        IMG / "chk_off.png", "Apagar Pi",
        [("Pide confirmación", True), ("Al confirmar, la Pi se apaga", False)],
        "No hay 60 segundos. Eso es solo del HP.",
    )
    fotos["chk_boton"] = pantalla(
        IMG / "chk_boton.png", "Botón de apagar en el Nano",
        [("Toque corto: no pasa nada", False), ("Mantener: sale la confirmación", True)],
        "Sin la pantalla de Orbit abierta, no se apaga.",
    )
    fotos["chk_moon"] = terminal(IMG / "chk_moon.png", [
        ("cmd", "moonlight-qt pair 10.0.0.1"),
        ("out", "PIN de cuatro cifras"),
        ("dim", "Se escribe una vez en Sunshine."),
    ])
    fotos["chk_kiosco"] = terminal(IMG / "chk_kiosco.png", [
        ("dim", "Ctrl+Alt+T sale del kiosco."),
        ("cmd", "rm /var/lib/orbit/kiosk-pausa"),
        ("ok", "Vuelve Orbit OS."),
    ])
    fotos["chk_sim"] = pantalla(
        IMG / "chk_sim.png", "Simulador en el PC",
        [("Apagar dice SIMULADO", True), ("Ese PC no se apaga", False)],
        "El simulador no llama a systemctl.",
    )
    fotos["soft_sun"] = pantalla(
        IMG / "soft_sun.png", "Sunshine en el HP",
        [("Instala Sunshine en Windows", True), ("Abre https://10.0.0.1:47990", False),
         ("Aplicación Desktop", False)],
        "ILUSTRACIÓN. El certificado de Sunshine hay que aceptarlo.",
    )
    fotos["soft_pin"] = pantalla(
        IMG / "soft_pin.png", "Emparejar",
        [("En la Pi: moonlight-qt pair 10.0.0.1", True), ("En Sunshine: el PIN de 4 cifras", True)],
        "Una sola vez.",
    )
    fotos["soft_hdmi"] = pantalla(
        IMG / "soft_hdmi.png", "Enchufe HDMI falso",
        [("Si Windows no ofrece 1920×1080", True), ("Pon un enchufe HDMI en el HP", False),
         ("1920×1040 se crea en Windows", False)],
        "Muchos enchufes anuncian 1920×1080.",
    )
    return fotos


def estilos():
    return {
        "h": ParagraphStyle("h", fontName="DejaVuBold", fontSize=22, leading=26, textColor=TINTA),
        "num": ParagraphStyle("num", fontName="DejaVuBold", fontSize=28, leading=32, textColor=AMBAR),
        "p": ParagraphStyle("p", fontName="DejaVu", fontSize=12, leading=16, textColor=TINTA),
        "s": ParagraphStyle("s", fontName="DejaVu", fontSize=9, leading=12, textColor=GRIS),
        "pie": ParagraphStyle("pie", fontName="DejaVuBold", fontSize=11, leading=14, textColor=TINTA),
        "port": ParagraphStyle("port", fontName="DejaVuBold", fontSize=26, leading=32, textColor=TINTA, alignment=TA_LEFT),
    }


def marca(canvas, doc):
    canvas.saveState()
    canvas.setFillColor(PAPEL)
    canvas.rect(0, 0, A4[0], A4[1], fill=1, stroke=0)
    canvas.setFillColor(AMBAR)
    canvas.rect(0, A4[1] - 8 * mm, A4[0], 8 * mm, fill=1, stroke=0)
    canvas.setFillColor(white)
    canvas.setFont("DejaVuBold", 9)
    canvas.drawString(14 * mm, A4[1] - 5.5 * mm, "ORBIT TERMINAL")
    canvas.setFillColor(TINTA)
    canvas.setFont("DejaVu", 8)
    canvas.drawRightString(A4[0] - 14 * mm, 8 * mm, str(canvas.getPageNumber()))
    canvas.restoreState()


def foto(path: Path, ancho=180, alto=115):
    return RLImage(str(path), width=ancho * mm, height=alto * mm, kind="proportional")


def portada(story, st, fotos):
    TITULOS.append("Portada")
    story.append(Spacer(1, 18 * mm))
    story.append(Paragraph("Orbit Terminal - Manual de montaje y software", st["port"]))
    story.append(Spacer(1, 4 * mm))
    story.append(Paragraph(
        "Un paso. Una acción. Una figura. Lo naranja es lo que pones. Lo gris ya está.",
        st["p"]))
    story.append(Spacer(1, 6 * mm))
    story.append(foto(fotos["ya_cerrada"], 180, 120))
    story.append(Spacer(1, 4 * mm))
    story.append(Paragraph(
        "La carcasa y la base ya están impresas y cerradas. No se cortan, no se taladran y no se liman. "
        "Este manual sustituye a docs/manual_montaje y a docs/manual-montaje.",
        st["s"]))
    story.append(PageBreak())


def inventario(story, st, fotos, titulo, celdas):
    for inicio in range(0, len(celdas), 6):
        trozo = celdas[inicio:inicio + 6]
        nombre = titulo if inicio == 0 else f"{titulo}, sigue"
        TITULOS.append(nombre)
        story.append(Paragraph(nombre, st["h"]))
        story.append(Spacer(1, 2 * mm))
        filas = []
        fila = []
        for rotulo, clave, nota in trozo:
            bloque = [
                foto(fotos[clave], 84, 52),
                Paragraph(rotulo, st["pie"]),
                Paragraph(nota, st["s"]),
            ]
            fila.append(bloque)
            if len(fila) == 2:
                filas.append(fila)
                fila = []
        if fila:
            fila.append("")
            filas.append(fila)
        tabla = Table(filas, colWidths=[90 * mm, 90 * mm])
        tabla.setStyle(TableStyle([
            ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ("LEFTPADDING", (0, 0), (-1, -1), 3),
            ("RIGHTPADDING", (0, 0), (-1, -1), 3),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ("BACKGROUND", (0, 0), (-1, -1), white),
            ("BOX", (0, 0), (-1, -1), 0.4, LINEA),
            ("INNERGRID", (0, 0), (-1, -1), 0.3, LINEA),
        ]))
        story.append(tabla)
        story.append(PageBreak())


def paso(story, st, n, titulo, texto, img, pie):
    TITULOS.append(f"{n}. {titulo}")
    story.append(Paragraph(str(n), st["num"]))
    story.append(Paragraph(titulo, st["h"]))
    story.append(Spacer(1, 2 * mm))
    story.append(Paragraph(texto, st["p"]))
    story.append(Spacer(1, 3 * mm))
    story.append(foto(img, 176, 112))
    story.append(Spacer(1, 3 * mm))
    story.append(Paragraph(pie, st["pie"]))
    story.append(PageBreak())


def construir(fotos):
    st = estilos()
    story = []
    portada(story, st, fotos)
    TITULOS.append("Cómo se lee")
    story.append(Paragraph("Cómo se lee", st["h"]))
    story.append(Spacer(1, 3 * mm))
    story.append(foto(fotos["grapa"], 120, 70))
    story.append(Paragraph(
        "El número en el círculo es el tornillo de ese paso. ×4 significa cuatro iguales. "
        "La flecha naranja marca el sentido. Las figuras salen del CAD del repo. "
        "Las pantallas del Imager y las cajas de terminal son ilustraciones, rotuladas así.",
        st["p"]))
    story.append(PageBreak())

    inventario(story, st, fotos, "Piezas ya impresas", [
        ("Carcasa delante-izquierda", "carcasa_00", "Ya impresa. No se corta."),
        ("Carcasa delante-derecha", "carcasa_10", "Ya impresa. No se corta."),
        ("Carcasa detrás-izquierda", "carcasa_01", "Ya impresa. Ventana del HP y botón."),
        ("Carcasa detrás-derecha", "carcasa_11", "Ya impresa. Postes de la tapa."),
        ("Base, trozo 1", "base_00", "Ya impresa. No se taladra."),
        ("Base, trozo 2", "base_10", "Ya impresa."),
        ("Base, trozo 3", "base_01", "Ya impresa."),
        ("Base, trozo 4", "base_11", "Ya impresa."),
        ("Bisel 1", "bisel_00", "Marco de la pantalla."),
        ("Bisel 2", "bisel_10", "Marco de la pantalla."),
        ("Bisel 3", "bisel_01", "Marco de la pantalla."),
        ("Bisel 4", "bisel_11", "Marco de la pantalla."),
        ("Pletina de empalme", "pletina", "Ya en la base cerrada."),
        ("Soporte del disco", "disco", "Para el Toshiba 3,5."),
        ("Capuchón de punta", "capuchon_punta", "Ya cubre los M3 de las pletinas. No se imprime."),
    ])
    inventario(story, st, fotos, "Piezas que se imprimen ahora", [
        ("Tapa de la Pi v2", "tapa", "NUEVA. Chaflán abajo. La de 94×54 no vale."),
        ("Bandeja v3", "bandeja", "Con ventanas en los cantos largos. La v2 no se usa."),
        ("Grapa ×16", "grapa", "14 en el aparato y 2 de más. Va bajo la cabeza."),
        ("Pomo ×2", "pomo", "Tapa abajo."),
        ("Anillo de luz ×2", "anillo", "PETG translúcido."),
        ("Guía de luz 1", "guia0", "Boca abajo. PETG translúcido."),
        ("Guía de luz 2", "guia1", "Boca abajo. PETG translúcido."),
        ("Capuchón de encendido", "boton", "07. Pestaña abajo, símbolo arriba."),
        ("Soporte del botón", "soporte_b", "Suelo abajo. Se pega por dentro."),
        ("Prueba del botón", "prueba_b", "Plana. No se monta."),
        ("Marco frontal", "marco", "Cara de fuera abajo. Entra en 62×18."),
        ("Prueba de la placa I/O", "prueba_io", "08a. Primero, por fuera."),
        ("Placa I/O del HP", "placa_io", "Pestaña abajo. Por dentro."),
        ("Tapa de agujeros viejos", "puertos", "Reborde abajo. Por dentro."),
        ("Careta de pines", "panel", "Rótulos abajo, ganchos arriba."),
    ])
    inventario(story, st, fotos, "Electrónica", [
        ("HP Slimline, placa mini-ITX", "elec_hp", "Marcador del CAD. Conectores a la ventana trasera."),
        ("Toshiba 3,5", "elec_hdd", "Cotas SFF-8301. Rosca 6-32."),
        ("Raspberry Pi 4", "elec_pi", "USB y RJ45 hacia atrás. El cuadrado es la micro-SD."),
        ("HAT VHF", "elec_hat", "Marcador. No está medido. No tapa la fijación."),
        ("Nano de mandos", "nano_man", "Arriba a la derecha. USB hacia arriba."),
        ("Nano de pruebas", "nano_prac", "Abajo a la derecha. USB hacia delante."),
        ("ESP8266", "esp", "Abajo a la izquierda. USB hacia la Pi."),
        ("LM2596 43×21 a 5 V", "buck", "FALTA: comprar. El ZERO/SPAN no lo sustituye."),
        ("OLED 0,96", "elec_oled", "Marcador. Va en la ventana OLED."),
        ("Ventilador del disipador HP", "elec_fan", "Va con la placa. El sentido de aire sigue pendiente."),
    ])
    # ESP real geometry is the tray step; inventory cell above used the fan by mistake.
    # Fix: the ESP inventory picture is v_esp, already rendered.
    inventario(story, st, fotos, "Tornillos de los kits", [
        ("M3×16 botón ×17", "tor_m3_16", "JINZEYOU. Ya en pasadores y pletinas. Kit: 20."),
        ("Tuerca M3 ×8", "tuerca", "Bajo las pletinas. Kit: 100."),
        ("M3×8 avellanado ×29", "tor_cs8", "wugongshan. Orejetas, disco y bisel. Kit: 40."),
        ("M3×6 avellanado ×4", "tor_cs6", "Placa HP. Kit: 40."),
        ("M3×8 botón ×10", "tor_m3_8", "4 bandeja + 4 LM2596 + 2 tapa. Kit: 30."),
        ("M3×12 botón ×14", "tor_m3_12", "12 grapas de ESP y Nanos + 2 pomos. Kit: 30."),
        ("M2.5×8 botón ×4", "tor_m25", "Los cuatro agujeros de la Pi. Kit: 40."),
        ("Inserto M3 5×5 ×26", "ins_55", "Orejetas, bisel y disco. Kit: 30."),
        ("Inserto M3 4×5 ×6", "ins_45", "4 HP + 2 pomos. Kit: 30."),
        ("Inserto M3 6×5 ×4", "ins_65", "Torretas de la bandeja. Kit: 30."),
        ("Inserto M2.5 4×3,5 ×4", "ins_m25", "Postes de la Pi. Kit: 40."),
        ("Capuchón de punta", "capuchon_punta", "Ya en los M3 que asoman bajo las pletinas."),
    ])
    inventario(story, st, fotos, "FALTA: comprar", [
        ("Dupont hembra acodado 90°", "faltan_dupont", "Uno por pin. El recto no cabe en 13 mm."),
        ("LM2596 43×21 mm a 5 V", "buck", "El de la bandeja. No es el ZERO/SPAN."),
        ("Regleta macho 2×20", "faltan_regleta", "Paso 2,54 mm. Pines de al menos 11 mm."),
        ("Regleta macho 2×12", "regleta12", "Paso 2,54 mm. Pines de al menos 11 mm."),
        ("6-32 UNC × 1/4 pulgada ×4", "faltan_632", "Phillips PH2. Valen los originales del HP, si siguen ahí."),
        ("Soporte de soplante", "soplante", "PENDIENTE. No hay pieza. No se imprime."),
    ])

    # The ESP cell in Electrónica pointed at the fan. Patch is too late for that
    # page; the assembly step shows the real ESP. Leave a dedicated picture in step 1 area.

    n = 0

    def p(titulo, texto, clave, pie):
        nonlocal n
        n += 1
        paso(story, st, n, titulo, texto, fotos[clave], pie)

    p("La carcasa ya está cerrada",
      "Mírala. No la abras para cortar, taladrar o limar.",
      "ya_cerrada", "Nada que apretar.")
    p("Imprime el marco frontal",
      "Cara de fuera contra la cama. Faldón hacia arriba. Sin soportes.",
      "marco", "1 marco.")
    p("Mete el marco en la ventana",
      "Desde fuera, en el hueco de 62 × 18, hasta que el reborde apoye.",
      "marco_expl", "Sin tornillo. Los dos jacks frontales se quedan detrás.")
    p("El marco ya asienta",
      "La boca deja ver los USB. No limes la ventana.",
      "marco_dentro", "Si un nervio aprieta, lija el nervio, no la carcasa.")
    p("Imprime la prueba de la placa I/O",
      "Plana, sin soportes. Es el paso 08a.",
      "prueba_io", "1 prueba. No se pega.")
    p("Apoya la prueba por fuera",
      "El hueco grande de la izquierda cae sobre el VGA azul.",
      "prueba_io", "Si cae en otro conector, la placa está al revés.")
    p("Imprime la placa I/O",
      "Pestaña abajo. Sin soportes.",
      "placa_io", "1 placa.")
    p("Mete la placa por dentro",
      "Empuja hasta que el tetón asiente. No lleva tornillo.",
      "placa_io", "Si se sale, una gota de cola en el reborde interior.")
    p("Imprime la tapa de agujeros viejos",
      "Reborde abajo, tetones arriba.",
      "puertos", "1 tapa. Esos agujeros no son la Pi.")
    p("Mete la tapa por dentro",
      "Un tetón en cada agujero. La cara de fuera queda lisa.",
      "tapa_puertos", "Sin tornillo.")
    p("Imprime la careta de pines",
      "Rótulos abajo, ganchos arriba.",
      "panel", "1 careta.")
    p("Engancha la careta",
      "Por fuera. Los ganchos entran en OLED y en PRG.",
      "panel", "Sin tornillo. No limes el grabado.")
    p("Mete la regleta 2×20",
      "Por dentro, en la fila de la Pi. El plástico se queda dentro.",
      "regleta20", "FALTA: comprar, paso 2,54 mm, pines de al menos 11 mm.")
    p("Mete la regleta 2×12",
      "Por dentro, en la fila del Nano.",
      "regleta12", "FALTA: comprar, la misma medida.")
    p("Imprime el capuchón",
      "Pestaña en la cama, símbolo arriba.",
      "capuchon", "1 capuchón.")
    p("Prueba el capuchón",
      "El vástago entra en el Ø12,2 y sale solo. La pestaña no pasa.",
      "prueba_boton", "1 prueba, que no se monta. Si rasca, lija el vástago.")
    p("Mete el capuchón",
      "Desde dentro. El símbolo queda fuera.",
      "capuchon_puesto", "Sin tornillo.")
    p("Imprime el soporte",
      "Suelo en la cama.",
      "soporte_b", "1 soporte.")
    p("Pega el soporte",
      "Por dentro. La guía entra en el Ø3,1, 14 mm sobre el pulsador.",
      "soporte_boton", "Cola en la cara plana. No pegues el capuchón.")
    p("Mete el pulsador y el LED",
      "El pulsador, vástago hacia el capuchón. El LED, cúpula hacia la guía.",
      "pulsador", "Táctil 12×12×7,3 mm. LED de 3 mm.")
    p("Dos hilos al cabezal",
      "En paralelo al botón original del HP. Mide antes qué patillas se unen.",
      "hilos_boton", "El mapa del cabezal no está medido.")
    p("Imprime la bandeja v3",
      "Ala abajo. Es pieza de noche. La de paredes cerradas no se usa.",
      "bandeja", "1 bandeja. Ventanas de 13 mm en los cantos largos.")
    p("Pon la Pi",
      "Arriba a la izquierda. USB y RJ45 hacia atrás. El cuadrado es la micro-SD.",
      "pi_puesta", "1 Raspberry Pi 4. El HAT no se atornilla en este paso.")
    p("Cuatro M2.5×8",
      "En los insertos de la propia placa. Los postes de fuera son el plan B: uno u otro.",
      "pi_tornillos", "×4 M2.5×8 botón. ×4 inserto M2.5 4×3,5.")
    p("Pon el ESP8266",
      "Abajo a la izquierda. El USB mira hacia la Pi.",
      "esp", "1 ESP8266.")
    p("Cuatro grapas en el ESP",
      "La lengüeta cae sobre la esquina de la placa. M3×12 desde arriba.",
      "esp_tornillos", "×4 M3×12 botón. ×4 grapas.")
    p("Pon el Nano de mandos",
      "Arriba a la derecha. USB hacia arriba, hacia atrás.",
      "nano_man", "1 Nano. Este no se programa desde Ardu Lab.")
    p("Cuatro grapas en mandos",
      "Igual que el ESP.",
      "nano_man_tornillos", "×4 M3×12 botón. ×4 grapas.")
    p("Ese módulo no es un step-down",
      "El ZERO/SPAN de 4–20 mA no se conecta. Sácalo del hueco.",
      "zero_span", "No lleva tornillo. No lo alimentes.")
    p("Pon el LM2596",
      "Centro derecha, en el hueco de 43 × 21.",
      "buck", "FALTA: comprar, 43×21 mm, salida 5 V.")
    p("Dos M3×8 atraviesan el módulo",
      "Por los agujeros del propio LM2596.",
      "buck_pasante", "×2 M3×8 botón.")
    p("Dos grapas en el step-down",
      "En los otros dos postes. También M3×8.",
      "buck_grapa", "×2 M3×8 botón. ×2 grapas.")
    p("Pon el Nano de pruebas",
      "Abajo a la derecha. USB hacia delante.",
      "nano_prac", "1 Nano. Este es el de Ardu Lab.")
    p("Cuatro grapas en pruebas",
      "La lengüeta sobre la placa.",
      "nano_prac_tornillos", "×4 M3×12 botón. ×4 grapas. Quedan 2 grapas de más.")
    p("Saca los cables por las ventanas",
      "Dupont hembra a 90°. El hilo sale de lado, hacia los puentes.",
      "dupont", "FALTA: un Dupont acodado por pin. El recto no cabe.")
    p("Apoya la bandeja",
      "El ala cae en las cuatro torretas.",
      "bandeja_torres", "No taladres la base.")
    p("Cuatro M3×8 a la base",
      "Desde arriba, al inserto de cada torreta.",
      "bandeja_tornillos", "×4 M3×8 botón. ×4 inserto M3 6×5.")
    p("Imprime la tapa v2",
      "Plana. Cara del chaflán contra la cama. Tetón hacia arriba.",
      "tapa_cama", "1 tapa. La ya impresa, de 94×54, no se usa.")
    p("Baja la tapa",
      "Desde el techo. El tetón entra en el hueco de 72 × 42 y la centra.",
      "tapa_baja", "Holgura 0,3 mm por lado. La carcasa no se toca.")
    p("Dos M3×8 en los postes",
      "A la derecha. Los agujeros no se han movido.",
      "tapa_tornillos", "×2 M3×8 botón. Se abre quitando estos dos.")
    p("Imprime pomos y anillos",
      "Pomo con la tapa abajo. Anillo en PETG translúcido.",
      "pomos", "×2 pomos. ×2 anillos.")
    p("Mete anillo y pomo",
      "El anillo bajo el pomo. Un M3×12 al inserto del eje.",
      "anillo_pomo", "×2 M3×12 botón. ×2 inserto M3 4×5.")
    p("Mete las guías de luz",
      "En el canal frontal. PETG translúcido, impresas boca abajo.",
      "guia", "×2 guías.")
    p("Mete el monitor",
      "En la tina, conectores hacia la derecha.",
      "monitor", "La pantalla MSI. Su USB-C es aparte.")
    p("Pon los cuatro biseles",
      "Tapan el marco. Tres tornillos avellanados cada uno, a los insertos.",
      "bisel", "×12 M3×8 avellanado. ×12 inserto M3 5×5.")
    p("Cable de red",
      "Pi eth0 en 10.0.0.2. HP en 10.0.0.1. Sin puerta de enlace y sin DNS en ese cable.",
      "cable_eth", "1 cable Ethernet. El Wi-Fi no se toca.")
    p("Así se cablea",
      "Pi, los dos Nano, el ESP, el OLED y el LM2596. El ZERO/SPAN queda fuera.",
      "diagrama", "El recorrido fino de cada hilo no está medido.")
    p("La placa HP",
      "Conectores hacia la ventana trasera. Cuatro M3×6 avellanados.",
      "elec_hp", "×4 M3×6 avellanado. ×4 inserto M3 4×5. Si ya está puesta, sigue.")
    p("El disco Toshiba",
      "Sobre su soporte. Cuatro tornillos 6-32.",
      "elec_hdd", "FALTA: 4× 6-32 UNC × 1/4 pulgada, o los originales del HP.")
    p("Soporte de soplante",
      "No hay pieza. El ventilador de extracción queda pendiente. No imprimas un soporte.",
      "soplante", "PENDIENTE. Los agujeros de la tapa, de 30 y 40 mm, siguen vacíos.")

    p("Qué necesitas",
      "microSD de 32 GB, lector, cargador USB-C de 5 V y 3 A, Wi-Fi, el Nano de mandos y su cable. El micro-HDMI es opcional.",
      "soft_que", "Nada de la carcasa en este paso.")
    p("Instala Imager",
      "En Windows, desde raspberrypi.com.",
      "soft_imager", "ILUSTRACIÓN.")
    p("Elige la Raspberry Pi 4",
      "En Elegir dispositivo.",
      "soft_dispositivo", "ILUSTRACIÓN.")
    p("Elige el sistema con escritorio",
      "Raspberry Pi OS de 64 bits, con escritorio. Bookworm o Trixie.",
      "soft_os", "Lite no trae el escritorio. ILUSTRACIÓN.")
    p("Elige la microSD",
      "La de 32 GB. No el disco del PC.",
      "soft_sd", "ILUSTRACIÓN.")
    p("Pon usuario, Wi-Fi y SSH",
      "Usuario, contraseña, Wi-Fi, teclado es, zona Europa/Madrid, y activa SSH.",
      "soft_usuario", "El usuario no tiene que llamarse pi. ILUSTRACIÓN.")
    p("Escribe la tarjeta",
      "Espera a que la verificación diga que está bien.",
      "soft_escribe", "ILUSTRACIÓN.")
    p("Primer arranque",
      "Tarjeta en la Pi, alimenta con el USB-C y espera al Wi-Fi.",
      "soft_boot", "ILUSTRACIÓN.")
    p("Entra por SSH",
      "Desde PowerShell: ssh USUARIO@raspberrypi.local",
      "soft_ssh", "USUARIO es el de Imager.")
    p("Clona la rama",
      "git clone -b cursor/bandeja-v2-modular-6d15 https://github.com/Sopa-IA/Control-deck.git",
      "soft_clone", "La rama del PR #9, aún sin fusionar.")
    p("Entra en la carpeta",
      "cd Control-deck",
      "soft_cd", "Nada más.")
    p("Lanza el instalador",
      "sudo bash scripts/instalar-pi.sh",
      "soft_instala", "Con internet. Se puede repetir. La segunda vez no cambia los tokens.")
    p("Reinicia",
      "sudo reboot",
      "soft_reboot", "Al volver, lo primero es Orbit OS.")
    p("SSH otra vez",
      "Entra con el mismo usuario.",
      "chk_ssh", "1. El SSH responde.")
    p("orbitd está activo",
      "systemctl status orbitd dice active. En la pantalla se ve Orbit OS.",
      "chk_orbit", "2. Servicio y pantalla.")
    p("El Wi-Fi tiene internet",
      "Un ping sale.",
      "chk_wifi", "3. Internet por Wi-Fi.")
    p("eth0 no tiene puerta",
      "ip route no muestra default por eth0. eth0 es 10.0.0.2/24.",
      "chk_ruta", "4. El cable interno no rompe el Wi-Fi.")
    p("Estás en dialout",
      "grep dialout /etc/group incluye tu usuario.",
      "chk_dial", "5. Así el Nano y el ESP se ven por el USB.")
    p("Apagar pide confirmación",
      "En Orbit OS, Apagar pregunta y, al confirmar, la Pi se apaga.",
      "chk_off", "6. Sin los 60 segundos del HP.")
    p("El botón corto no apaga",
      "Un toque no hace nada. Mantenerlo abre la misma confirmación.",
      "chk_boton", "7. Sin la pantalla abierta, no se apaga.")
    p("Empareja Moonlight una vez",
      "moonlight-qt pair 10.0.0.1 y el PIN en Sunshine.",
      "chk_moon", "8. Solo la primera vez.")
    p("Salir y volver al kiosco",
      "Ctrl+Alt+T sale. rm /var/lib/orbit/kiosk-pausa vuelve.",
      "chk_kiosco", "9. SSH sigue valiendo sin salir.")
    p("El simulador no apaga el PC",
      "En el ordenador de desarrollo, Apagar dice SIMULADO.",
      "chk_sim", "10. Ese PC sigue encendido.")
    p("Instala Sunshine",
      "En el HP. Crea la aplicación Desktop.",
      "soft_sun", "ILUSTRACIÓN.")
    p("Empareja con el PIN",
      "El PIN de cuatro cifras se escribe en Sunshine.",
      "soft_pin", "La Pi en 10.0.0.2, el HP en 10.0.0.1.")
    p("Vista integrada",
      "Barra de 40 px y Moonlight en el hueco. La completa es la alternativa.",
      "integrada", "ILUSTRACIÓN. 1920×1040 a 60 fps con la barra cerrada.")
    p("Enchufe HDMI falso",
      "Si Windows sin monitor no ofrece 1920×1080, pon un enchufe HDMI en el HP.",
      "soft_hdmi", "Para 1920×1040, crea esa resolución en Windows.")

    TITULOS.append("Si algo no cuadra")
    story.append(Paragraph("Si algo no cuadra", st["h"]))
    story.append(Spacer(1, 3 * mm))
    story.append(foto(fotos["fallos"], 176, 120))
    story.append(Paragraph(
        "No cortes la carcasa para arreglar un paso. Si un tetón no entra, lija el tetón.",
        st["p"]))
    # última página: sin PageBreak final de más. El paso() ya parte. Este bloque es la última.

    doc = SimpleDocTemplate(
        str(PDF), pagesize=A4,
        leftMargin=14 * mm, rightMargin=14 * mm,
        topMargin=14 * mm, bottomMargin=14 * mm,
        title="Orbit Terminal - Manual de montaje y software",
        author="Orbit Terminal",
    )
    doc.build(story, onFirstPage=marca, onLaterPages=marca)
    return n


def escribir_readme(npasos: int, paginas: int):
    lineas = [
        "# Orbit Terminal - Manual de montaje y software",
        "",
        "Este es el manual vigente. Sustituye a `docs/manual_montaje/` y a `docs/manual-montaje/`.",
        "",
        "La fuente es `hardware/cad/manual/completo_pdf.py` y `hardware/cad/manual/completo.scad`.",
        "Para regenerarlo, desde la raíz del repo:",
        "",
        "```",
        "python3 hardware/cad/manual/completo_pdf.py",
        "```",
        "",
        f"PDF: `docs/manual_completo/Orbit_manual_completo.pdf`. Páginas: {paginas}. Pasos numerados: {npasos}.",
        "",
        "Cada paso numerado tiene su figura. Lo naranja es lo que se pone en ese paso. "
        "Las pantallas de Imager y las cajas de terminal son ilustraciones, rotuladas en la propia figura.",
        "",
        "La carcasa y la base ya están impresas y cerradas. No se cortan, no se taladran y no se liman. "
        "La tapa de la Pi es la v2. La bandeja es la v3, con ventanas. "
        "El soporte de un ventilador soplante no existe: queda pendiente.",
        "",
        "## Páginas",
        "",
    ]
    for i, titulo in enumerate(TITULOS, start=1):
        lineas.append(f"{i}. {titulo}")
    lineas.append("")
    README.write_text("\n".join(lineas), encoding="utf-8")


def main():
    fotos = render_todo()
    # La ficha del ESP en el inventario de electrónica usa su geometría real.
    fotos["elec_esp"] = fotos["esp"]
    npasos = construir(fotos)
    # Páginas = entradas de TITULOS, porque cada una hace un salto salvo que
    # la última no añade PageBreak. construir añade PageBreak en cada paso,
    # y la última sección no. SimpleDocTemplate cuenta las páginas reales.
    from pypdf import PdfReader
    reader = PdfReader(str(PDF))
    paginas = len(reader.pages)
    texto = "\n".join(page.extract_text() or "" for page in reader.pages)
    for muestra in ("está", "Piñón", "microSD", "confirmación", "Europa/Madrid"):
        pass
    necesarias = ["está", "confirmación", "Europa/Madrid", "Chaflán", "gráfica"]
    # Chaflán y gráfica may be in images not text. Check text that is in paragraphs.
    plano = " ".join(texto.split())
    for palabra in ("montaje y software", "confirmación", "raspberrypi.local", "ZERO", "PENDIENTE", "está"):
        if palabra not in plano:
            raise SystemExit(f"El PDF no contiene «{palabra}»")
    for letra in "áéíóúñ":
        if letra not in texto:
            raise SystemExit(f"Falta la letra {letra} en el texto del PDF")
    for i, page in enumerate(reader.pages, start=1):
        if len(page.images) < 1:
            raise SystemExit(f"La página {i} no tiene figura")
    escribir_readme(npasos, paginas)
    print(f"PASOS {npasos}")
    print(f"PAGINAS {paginas}")
    print(f"PDF {PDF}")
    for i, titulo in enumerate(TITULOS, start=1):
        print(f"TITULO {i}. {titulo}")


if __name__ == "__main__":
    sys.exit(main() or 0)
