# Pantallas táctiles HDMI — investigación Fase 1

> Proyecto: ORBIT TERMINAL · Documento: `docs/pantallas.md` · Fecha de comprobación de todas las fuentes: **2026-10-18**
> Regla: ninguna cifra sin fuente. Lo que no se ha podido verificar figura como **pendiente de verificar**.
> Los precios son de catálogo en la fecha indicada, **sin envío** y, salvo indicación, **sin impuestos de importación**. Cambian con frecuencia: revalidar antes de comprar.

## 1. Requisitos derivados del concepto

| Requisito | Motivo |
|---|---|
| Entrada de vídeo **HDMI** | Es la única interfaz que pueden compartir el HP y la Raspberry Pi a través de un conmutador KVM. Las pantallas DSI (p. ej. Raspberry Pi Touch Display 2) solo funcionan con la Pi y quedan descartadas. |
| Táctil por **USB HID** sin controladores | Para que el táctil viaje por el KVM y funcione tanto en Windows como en Linux sin instalar nada. |
| Diagonal 10–12,3" | Brief del propietario. |
| Alimentación de baja tensión (5 V o 12 V) | Se integrará en un chasis con fuentes comerciales certificadas. |
| Planos mecánicos (PDF/STEP) | Imprescindibles para el CAD paramétrico de la carcasa. |

### Observación importante sobre la proporción
Los renders de referencia rotulan "Pantalla táctil 12,3" panorámica", pero la pantalla dibujada tiene una proporción visual cercana a 16:10. Los paneles comerciales de 12,3" con HDMI son tipo **barra 1920×720 (8:3)**, con un área visible de unos 293 × 110 mm (ver tabla). Con uno de ellos el dispositivo será **más bajo y alargado** que en el render. Si se prefieren las proporciones del render, la alternativa real es un panel de **11,6" 1920×1080 (16:9)**. **Miguel tiene que decidirlo** (ver `informe-fase1.md`).

## 2. Candidatas

### 2.1 Waveshare 12.3inch 1920x720 LCD (In-Cell), SKU 28481
| Campo | Dato | Fuente |
|---|---|---|
| Fabricante / modelo | Waveshare "12.3inch 1920x720 LCD", SKU 28481 | https://www.waveshare.com/12.3inch-1920x720-lcd.htm |
| Resolución | 1920×720, IPS, 60 Hz | https://www.waveshare.com/wiki/12.3inch_1920x720_LCD |
| Dimensiones exteriores | 301,2 × 123,35 × 12,4 mm | wiki (tabla "Specification") |
| Área activa | 293,10 × 110,20 mm | wiki |
| Brillo | 300 cd/m², contraste 1200:1 | wiki |
| Vídeo | HDMI y USB-C (DP Alt Mode en el host) | wiki |
| Táctil | Capacitivo in-cell de 10 puntos, puerto USB-C (se conecta al host como USB) | página de producto + wiki |
| Sin controladores | Windows 11/10/8.1/8/7: 10 puntos, sin controladores. Raspberry Pi OS: 10 puntos, sin controladores. Ubuntu/Kali: 1 punto según el fabricante | página de producto |
| Alimentación | 5 V por conector DC; consumo **máx. 5 W**; recomienda adaptador de 5 V 3 A | wiki |
| Extras | Menú OSD; **brillo por DDC/CI**; jack de 3,5 mm | wiki |
| Planos | Sección "Dimensions / 3D Diagram" de la wiki | wiki |
| Precio | **109,99 USD** (1–9 uds.) en waveshare.com; **115,79 € sin IVA** en Kiwi Electronics (8 uds. en stock) | waveshare.com; https://www.kiwi-electronics.com/en/12-3inch-capacitive-touch-display-1920x720-20597 |
| Disponibilidad | En stock en Kiwi Electronics (NL) en la fecha de comprobación | idem |

**Pros:** es la más fina y la que menos consume (5 V, 5 W): puede compartir el raíl de 5 V con la Pi. Su brillo es regulable por software (DDC/CI), así que un mando físico podría ajustarlo. Es la más barata de las de 12,3".
**Contras:** 300 cd/m², la mitad que el modelo de 600 cd/m². Al ser in-cell, el cristal no tiene marco ancho con el que apoyarla en el bisel. Su diagonal "12,3" solo da 110 mm de altura útil, lo que queda justo para un escritorio Windows. Con USB-C solo hay vídeo si el host ofrece DP Alt Mode, cosa que no está confirmada en el HP: hay que planificar HDMI.

### 2.2 Waveshare 12.3inch HDMI LCD (600 cd/m², optical bonding)
| Campo | Dato | Fuente |
|---|---|---|
| Modelo | Waveshare "12.3inch HDMI LCD" | https://www.waveshare.com/12.3inch-hdmi-lcd.htm |
| Resolución | 1920×720 IPS | idem |
| Dimensiones exteriores | Cristal 322,63 × 142,11 mm; espesor 13,20 mm (10,40 mm sin la placa) | plano PDF: https://files.waveshare.com/wiki/12.3inch%20HDMI%20LCD/12.3inch%20HDMI%20LCD.pdf |
| Área activa | 292,63 × 110,11 mm (área visible del cristal) | idem |
| Fijaciones | Agujeros a 110,00 mm en vertical y 96,00 + 196,50 mm en horizontal (ver plano) | idem |
| Vídeo | HDMI | página de producto |
| Táctil | Capacitivo de 10 puntos por USB; cristal templado de 6H con optical bonding | página de producto |
| Sin controladores | Windows 11…7: 10 puntos, sin controladores; Raspberry Pi OS: 10 puntos; Ubuntu/Kali: 1 punto | página de producto |
| Alimentación | **12 V, 1,25 A de corriente de trabajo** (FAQ del fabricante) | https://www.waveshare.com/wiki/12.3inch_HDMI_LCD |
| Brillo | 600 cd/m²; −20…70 °C | página de producto |
| Precio | **169,99 USD** en waveshare.com; **138 € con IVA** (112,20 € sin IVA) en elecom.sk según el buscador, sin comprobación directa | waveshare.com; https://www.elecom.sk/12-3inch-capacitive-touch-screen-lcd--1920--720--hdmi--ips--toughened-glass-panel/ |
| Disponibilidad | RobotShop (EE. UU.): "re-stocking soon" | https://www.robotshop.com/products/123inch-capacitive-touch-screen-lcd-1920720-hdmi-ips-toughened-glass-us-plug |

**Pros:** el cristal frontal ancho (15 mm de borde) facilita la integración "premium", porque el cristal queda enrasado con la carcasa. Brillo alto. Plano mecánico detallado disponible.
**Contras:** necesita 12 V (~15 W según el fabricante), el modelo más caro, y su placa trasera aumenta el espesor.

### 2.3 Wisecoco 12.3" 1920×720 (monitor tipo barra)
| Campo | Dato | Fuente |
|---|---|---|
| Modelo | Wisecoco 12.3 Inch Touchscreen Monitor 1920x720 (varias referencias de Amazon: B0D3Q2RQ6S, B0DP74XJY6, B0GHFQSB56) | https://www.amazon.com/dp/B0D3Q2RQ6S |
| Resolución | 1920×720, 60 Hz, E-IPS, 500 cd/m² (según el manual) | https://manuals.plus/ae/1005008202904825 |
| Dimensiones / área activa | **pendiente de verificar** (el fabricante no publica un plano) | — |
| Vídeo | Mini-HDMI o USB-C con DP Alt Mode | manual |
| Táctil | Multitáctil por USB-C. El fabricante indica que **hay que calibrar el táctil en el primer uso** | manual + ficha de Amazon |
| Compatibilidad | Windows; táctil no disponible en macOS. Linux: **pendiente de verificar** | ficha de Amazon |
| Alimentación | 5 V/2 A por USB-C (recomendado) | manual |
| Precio | **119,99 USD** (Amazon US, referencia B0D3Q2RQ6S, según el buscador; sin comprobación directa) | ficha de Amazon |

**Pros:** formato de monitor con carcasa (existe una versión de aluminio CNC) y alimentación de 5 V.
**Contras:** documentación técnica escasa, sin planos ni datos de Linux, y la necesidad de calibrar el táctil. No es buena opción para un diseño paramétrico serio.

### 2.4 Waveshare 11.6inch HDMI LCD (H), 1920×1080
| Campo | Dato | Fuente |
|---|---|---|
| Modelo | Waveshare "11.6inch HDMI LCD (H)" (versión sin carcasa y versión "with case") | https://www.waveshare.com/11.6inch-hdmi-lcd-h.htm |
| Resolución | 1920×1080 IPS (16:9) | idem |
| Dimensiones exteriores (sin carcasa) | Cristal 279,50 × 177,09 mm; espesor 21,20 mm (17,88 mm de referencia) | plano: https://files.waveshare.com/wiki/11.6inch_HDMI_LCD_H/11.6inch_HDMI_LCD_H.pdf |
| Área activa | 256,32 × 144,18 mm | idem |
| Dimensiones (con carcasa) | 284,65 × 182,25 × 29,50 mm | https://www.robotshop.com/products/waveshare-116inch-capacitive-touch-screen-lcd-with-case-1920x1080-hdmi-ips |
| Vídeo | HDMI. La versión con carcasa también admite **VGA** (requiere cable específico) | https://www.waveshare.com/wiki/11.6inch_HDMI_LCD_(H) |
| Táctil | Capacitivo de 10 puntos por USB (micro-USB) | wiki |
| Sin controladores | Windows 11…7: 10 puntos. En la Pi, el manual de la versión con carcasa indica táctil de 1 punto | wiki + https://manualspro.net/382293-waveshare-116-inch-hdmi-capacitive-touch-screen-lcd-user-manual |
| Alimentación | Adaptador de 12 V 1 A; **en funcionamiento normal ~12 V 0,5 A** + ~5 V 80 mA del USB táctil | wiki (FAQ) |
| Planos | STEP, DXF y PDF en la wiki | wiki |
| Precio | **162,99 USD** en waveshare.com | página de producto |

**Pros:** su proporción es la más cercana al render. Con 1080 px de altura útil es la más cómoda para un escritorio Windows/Linux. Hay planos STEP. La versión con carcasa añade entrada VGA, útil si el HP solo tuviera VGA.
**Contras:** 11,6" en lugar de 12,3". Es la más gruesa (~21 mm) y la más pesada de las alternativas sin carcasa.

### 2.5 Waveshare 10.1inch HDMI LCD (B) (with case), 1280×800
| Campo | Dato | Fuente |
|---|---|---|
| Modelo | Waveshare "10.1inch HDMI LCD (B) (with case)", SKU 11769/11750 | https://www.waveshare.com/10.1inch-hdmi-lcd-b-with-case.htm |
| Resolución | 1280×800 IPS | idem |
| Dimensiones | Plano PDF del panel y de la carcasa (STEP/DXF/PDF) en la wiki; **cifras pendientes de transcribir** | https://www.waveshare.com/wiki/10.1inch_HDMI_LCD_(B)_(with_case) |
| Vídeo / táctil | HDMI / USB, capacitivo de 10 puntos | página de producto |
| Sin controladores | Windows 11…7: 10 puntos; Raspberry Pi OS: 10 puntos | página de producto |
| Alimentación | 5 V: **~750 mA con la retroiluminación encendida**, ~300 mA apagada | wiki (FAQ) |
| Precio | **110,99 USD** en waveshare.com; **125,00 € con IVA** en Welectron (DE) según el buscador | waveshare.com; https://www.welectron.com/Waveshare-101inch-HDMI-LCD-B-with-case_1 |

**Pros:** bajo consumo (5 V) y buena compatibilidad.
**Contras:** resolución baja para un escritorio y una diagonal más pequeña de lo pedido.

### 2.6 Elecrow DIS85101D 10.1" 1280×800
| Campo | Dato | Fuente |
|---|---|---|
| Modelo | Elecrow DIS85101D | https://www.elecrow.com/elecrow-10-1-inch-display-ips-1280x800-acrylic-case-touch-screen-compatible.html |
| Resolución | 1280×800 IPS, 220 cd/m² típicos | datasheet: https://www.elecrow.com/download/product/DIS85101D/Datasheet_of_10.1inch_DIS85101D.pdf |
| Dimensiones (marco metálico) | 239,4 × 157,4 × 12,3 mm | datasheet |
| Área activa | 216,58 × 135,36 mm | datasheet |
| Vídeo / táctil | HDMI / micro-USB (táctil capacitivo) | datasheet |
| Compatibilidad | Raspbian, Ubuntu, Kali, Win10 IoT; Windows 7/8/10/11 como monitor | datasheet |
| Alimentación | 5,0 V, **potencia máx. 5,29 W** (micro-USB) | datasheet |
| Peso | 892 g | datasheet |
| Precio | **66,90 USD** en elecrow.com (la página muestra varios precios; posible oferta) | página de producto |

**Pros:** la más barata y con consumo documentado.
**Contras:** poco brillo y baja resolución. Su estética de "monitor de banco de pruebas" encaja mal con el concepto premium.

## 3. Tabla comparativa resumida

| # | Modelo | Diag. | Resolución | Área activa (mm) | Alim. | Precio (fuente, 2026-10-18) |
|---|---|---|---|---|---|---|
| 2.1 | Waveshare 12.3" In-Cell (28481) | 12,3" | 1920×720 | 293,10 × 110,20 | 5 V, máx. 5 W | 109,99 USD (waveshare.com) / 115,79 € sin IVA (Kiwi) |
| 2.2 | Waveshare 12.3" HDMI LCD 600 nit | 12,3" | 1920×720 | 292,63 × 110,11 | 12 V, 1,25 A | 169,99 USD (waveshare.com) |
| 2.3 | Wisecoco 12.3" | 12,3" | 1920×720 | pendiente | 5 V/2 A | 119,99 USD (Amazon US, sin comprobar) |
| 2.4 | Waveshare 11.6" (H) | 11,6" | 1920×1080 | 256,32 × 144,18 | 12 V, ~0,5 A | 162,99 USD (waveshare.com) |
| 2.5 | Waveshare 10.1" (B) con carcasa | 10,1" | 1280×800 | pendiente | 5 V, ~0,75 A | 110,99 USD (waveshare.com) |
| 2.6 | Elecrow DIS85101D | 10,1" | 1280×800 | 216,58 × 135,36 | 5 V, máx. 5,29 W | 66,90 USD (elecrow.com) |

Descartada: **Raspberry Pi Touch Display 2** (DSI). No se puede conectar al HP ni conmutar con un KVM HDMI.

## 4. Selección preliminar (ranking)

1. **Waveshare 12.3inch 1920x720 LCD In-Cell (SKU 28481)**: la recomendada si se mantiene el formato "12,3" panorámico". Es la que mejor cumple el brief al menor coste: 5 V con solo 5 W de máximo (simplifica la alimentación), 12,4 mm de espesor, táctil sin controladores en Windows y Raspberry Pi OS, brillo por DDC/CI y documentación con datos de EDID y dimensiones.
2. **Waveshare 11.6inch HDMI LCD (H)**: la recomendada si Miguel prefiere las proporciones del render o un escritorio más usable en el HP (1080 px de altura), y la opción de reserva si el HP solo tuviera VGA (versión con carcasa).
3. **Waveshare 12.3inch HDMI LCD (600 cd/m²)**: la opción "premium" de 12,3" si hace falta más brillo o un cristal con borde ancho para enrasar. Su contrapartida es 12 V y ~60 USD más.
4. **Wisecoco 12.3"**: solo si las anteriores no estuvieran disponibles; antes habría que medir dimensiones y probar Linux.
5. **Waveshare 10.1" (B)** y 6. **Elecrow DIS85101D**: alternativas económicas para el banco de pruebas, no para el producto final.

**Antes de comprar hay que verificar** (a cargo del propietario, sin compras por parte del agente):
- Que el HP tenga una salida compatible con HDMI (HDMI nativo o DisplayPort++ con adaptador pasivo). Ver `datos-pendientes-hp.md`.
- Que el táctil siga funcionando a través del KVM elegido. Ver `conmutacion-video-usb.md`.
- Qué táctil multipunto ofrece la versión de Linux que se instale en el HP (el fabricante solo garantiza 1 punto en Ubuntu en la mayoría de modelos).
