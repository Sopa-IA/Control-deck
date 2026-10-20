# Elección de Raspberry Pi para el papel de sistema auxiliar

> Documento: `docs/raspberry-pi.md` · Fuentes comprobadas el **2026-10-18** · Lo no verificado figura como **pendiente de verificar**.
>
> **2026-10-20.** Miguel confirma que la placa es una **Raspberry Pi 4** con un **HAT VHF** (trae OLED y una antena SMA plegable; dice que la carcasa cierra con holgura). Las medidas del HAT no se han tomado y no se inventan. Si el HAT no deja pasar el cabezal de 40 pines, el conector GPIO del panel trasero no se puede cablear: **PENDIENTE**. El estudio de abajo comparaba modelos por si había que comprar una; esa compra ya no está en el plan.

## 1. Qué tiene que hacer la Pi en Orbit Terminal

- Ejecutar **Orbit OS Interface** a pantalla completa (interfaz web en modo kiosco, ver `informe-fase1.md`).
- Leer 2 codificadores, 2 pulsadores de codificador, el botón de encendido y el de cambio de sistema; controlar los LED SK6812 y, si se elige TESmart, emitir IR hacia el KVM.
- Mantener el enlace autenticado con el HP por **Ethernet cableado** (preferente) y gestionar los apagados seguros.
- Funcionar de forma autónoma con el HP apagado (monitorización, automatización y, opcionalmente, Wake-on-LAN del HP).

De ahí se deducen los requisitos: **40 pines GPIO**, **Ethernet integrado** (deseable), una salida **HDMI**, RAM suficiente para un navegador en modo kiosco y consumo y calor manejables dentro de una carcasa cerrada.

## 2. Comparativa

| Modelo | CPU / RAM | Vídeo | Ethernet | GPIO | Alimentación oficial (PSU recomendada) | Consumo típico en placa | Precio oficial (2026-10-18) |
|---|---|---|---|---|---|---|---|
| **Pi 5** | BCM2712 · 1/2/4/8/16 GB | 2× micro-HDMI (hasta 4Kp60) | Sí (Gigabit), **PoE+** con HAT | 40 pines | **5,1 V / 5,0 A, USB-C** (fuente oficial de 27 W); con fuente de 3 A limita el USB a 600 mA | 800 mA (bare-board activo) | 1 GB **45 USD** · 2 GB **77,50 USD** · 4 GB **110 USD** · 8 GB **175 USD** · 16 GB **305 USD** |
| **Pi 4B** | BCM2711 · 1/2/3/4/8 GB | 2× micro-HDMI (hasta 4Kp60) | Sí (Gigabit), PoE con HAT | 40 pines | **5,1 V / 3,0 A, USB-C** | 600 mA (bare-board activo) | 1 GB **35 USD** · 2 GB **67,50 USD** · 3 GB **83,75 USD** · 4 GB **100 USD** · 8 GB **165 USD** |
| **Pi 3B+** | BCM2837B0 · 1 GB | 1× HDMI de tamaño completo | Sí (sobre USB 2.0), PoE con HAT | 40 pines | **5,1 V / 2,5 A, micro-USB** | 500 mA (bare-board activo) | **35 USD** (precio de lanzamiento; sigue en catálogo en 2026) |
| **Zero 2 W** | RP3A0 (4× A53 a 1 GHz) · **512 MB** | mini-HDMI | **No** (solo Wi-Fi de 2,4 GHz) | 40 pines sin soldar (versión WH con cabecera) | **5,1 V / 2 A, micro-USB** | 350 mA (bare-board activo) | **15 USD** (escasez reportada en oct. 2026) |
| **CM4 / CM5** | Igual que Pi 4 / Pi 5 | Según la placa base | Según la placa base | Según la placa base | Según la placa base | — | Depende de la configuración. Subidas del 1-abr-2026: +11,25 a +100 USD según la RAM |

Fuentes:
- Fuentes de alimentación y consumos: https://github.com/raspberrypi/documentation/blob/master/documentation/asciidoc/computers/raspberry-pi/power-supplies.adoc (fuente de la página oficial https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#power-supply)
- Puertos de vídeo y alimentación de la Pi 5/4/3B+: guía de producto oficial de 2026 https://pip-assets.raspberrypi.com/categories/1358-product-guides/documents/RP-009951-MM-1-Raspberry%20Pi%20SBC%20product%20guide.pdf
- Zero 2 W: https://github.com/raspberrypi/documentation/blob/master/documentation/asciidoc/computers/zero/zero-models.adoc
- Precios: subida del 1-oct-2026 (2 GB Pi 4 → 67,50 USD; Pi 5 → 77,50 USD) https://www.raspberrypi.com/news/price-increases-for-2gb-raspberry-pi-4-and-raspberry-pi-5/ · subida del 1-abr-2026 (4/8/16 GB, CM4/CM5, Pi 4 de 3 GB a 83,75 USD) https://www.cnx-software.com/2026/04/01/raspberry-pi-4-3gb-launched-for-83-75-further-price-increases-announced-across-the-board-for-4gb-ram-hardware/ · Zero 2 W a 15 USD y Pi 3B+ a 35 USD: https://www.raspberrypi.com/products/ y https://www.raspberrypi.com/news/raspberry-pi-3-model-bplus-sale-now-35/
- Los precios son **máximos oficiales en USD sin impuestos**. El precio en euros en un revendedor autorizado español está **pendiente de verificar**.

### Otras diferencias relevantes
| Aspecto | Pi 5 | Pi 4B | Pi 3B+ | Zero 2 W |
|---|---|---|---|---|
| Botón de encendido | **Integrado**, más el conector **J2** para un botón externo NA (mismo comportamiento) | No (se usa `gpio-shutdown` + GPIO3) | No | No |
| Consumo apagada | ~1–1,4 W por defecto; **~0,01 W** con `POWER_OFF_ON_HALT=1` | 0,023 A de corriente en halt (tabla oficial) | — | 0,055 A en halt (Zero original; Zero 2 W no figura en la tabla) |
| LED WS2812/SK6812 | `rpi_ws281x` **no compatible**; hay que usar el controlador PIO de Adafruit | `rpi_ws281x` | `rpi_ws281x` | `rpi_ws281x` |
| Térmica | Limitación entre 80 y 85 °C (todos los modelos); para la Pi 5 se recomienda el Active Cooler | Ídem | Límite blando a 60 °C por defecto | Ídem |
| USB para periféricos | 1,6 A con fuente de 5 A | 1,2 A | 1,2 A | Limitado por la fuente |

Fuentes: botón y J2 https://github.com/raspberrypi/documentation/blob/master/documentation/asciidoc/computers/raspberry-pi/power-button.adoc · consumo apagada y tabla de corrientes: power-supplies.adoc (anterior) · térmica: https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#frequency-management-and-thermal-control · LED en Pi 5: https://github.com/adafruit/Adafruit_Blinka_Raspberry_Pi5_Neopixel

## 3. Evaluación para este papel

- **Zero 2 W:** descartada como opción principal. **No tiene Ethernet** (el enlace con el HP tendría que ir por Wi-Fi o por un adaptador USB), solo 512 MB de RAM, que es poco para un navegador en modo kiosco, y su disponibilidad es irregular.
- **CM4/CM5:** descartadas para el prototipo. Necesitan una placa base (diseñarla o comprarla), lo que añade coste y complejidad. Podrían reconsiderarse en una versión futura si se diseña un PCB propio.
- **Pi 3B+:** **válida si Miguel ya la tiene**. Tiene Ethernet y GPIO, pero con 1 GB de RAM la interfaz web debe ser ligera. Requiere 5,1 V / 2,5 A. El rendimiento del navegador en modo kiosco está **pendiente de medir**.
- **Pi 4B:** **muy adecuada si ya la tiene**. Gigabit, 2–8 GB, 3 A y librerías LED maduras.
- **Pi 5:** **la mejor si hay que comprar**. Es la más potente para la UI, trae botón de encendido con conector J2 (encaja con el botón del chasis), consume ~0,01 W apagada con la configuración documentada y admite PoE+ con HAT. A cambio: fuente de 5 A (27 W), controlador LED distinto y más calor, que habrá que gestionar en la carcasa.

## 4. Recomendación

1. **Prioridad absoluta: usar la Raspberry Pi que Miguel ya tenga** (3B+, 4B o 5). El software se escribirá para funcionar en las tres (detección de modelo y controlador LED intercambiable).
2. **Si hay que comprar: Raspberry Pi 5 de 2 GB (77,50 USD de precio máximo oficial)** con su fuente oficial de 27 W. La de 1 GB (45 USD) podría bastar, pero el uso de RAM de Chromium en modo kiosco con la interfaz real no está medido: decidirlo tras la Fase 2.
3. **No se recomienda** la Zero 2 W ni las CM4/CM5 para el prototipo.

## 5. Requisitos oficiales de alimentación (resumen para `alimentacion-preliminar.md`)

| Modelo | Tensión | Corriente recomendada de la fuente | Conector | Fuente oficial recomendada |
|---|---|---|---|---|
| Pi 5 | 5,1 V | 5,0 A | USB-C | 27 W USB-C Power Supply |
| Pi 4B | 5,1 V | 3,0 A | USB-C | 3A USB-C Supply for Raspberry Pi 4 |
| Pi 3B+ | 5,1 V | 2,5 A | micro-USB | 2.5A micro USB supply |
| Zero 2 W | 5,1 V | 2 A | micro-USB | — |

- "**Ningún modelo de Raspberry Pi admite USB-PPS**" (documentación oficial).
- Con fuentes USB-PD multipuerto de terceros, conectar otro dispositivo provoca una renegociación que **puede arrancar la Pi si está apagada** (documentación oficial). Es relevante si se usa un cargador compartido.
- Todos los modelos desde la B+ (salvo la gama Zero) detectan tensiones por debajo de **4,63 V (±5 %)** y lo registran en el log del kernel. El software de Orbit vigilará este indicador como telemetría de salud.
- Precio en euros de las fuentes oficiales: **pendiente de verificar**.
