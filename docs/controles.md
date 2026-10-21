# Controles físicos e iluminación ámbar

> Documento: `docs/controles.md` · Fuentes comprobadas el **2026-10-18** · Lo no verificado figura como **pendiente de verificar**.
>
> **2026-10-20.** El prototipo no usa encoders. Usa potenciómetros y botones leídos por un **Arduino Nano** (antes, un Micro). La tira, cuando se identifique, va a un ESP8266 con WLED, no a un pin del Nano. Este archivo es el estudio de la fase 1; donde no coincida, mandan [`decisiones-prototipo.md`](decisiones-prototipo.md) y [`../software/arduino-controls/README.md`](../software/arduino-controls/README.md).

## 1. Inventario de controles (según el brief y los renders)

| Control | Cantidad | Función preliminar |
|---|---|---|
| Codificador rotatorio con pulsador | 2 | Configurables (volumen, brillo, desplazamiento, selección en Orbit OS…) |
| Botón de encendido | 1 | Encendido/apagado seguro del conjunto (lógica en `alimentacion-preliminar.md`) |
| Botón "cambiar sistema visible" | 1 | Ordena el cambio de puerto del KVM (ver `conmutacion-video-usb.md`) |
| LED de estado | 4 en el render (HP activo, Pi activa, disco, alimentación) | Pendiente de confirmar con Miguel |
| Iluminación ámbar ambiental | Tiras en la base y en los anillos de los mandos | Ver §5 |

## 2. Codificadores rotatorios con pulsador

| Referencia | Tipo | Pulsos / detents | Pulsador | Eje | Datos clave | Precio (fuente, 2026-10-18) |
|---|---|---|---|---|---|---|
| **Bourns PEC11R-4220F-S0024** | 12 mm, mecánico incremental, cuadratura de 2 bits | 24 pulsos / 24 detents | Sí, momentáneo | 20 mm, plano (F) | Contacto 10 mA a 5 V DC; **rebote ≤ 2,0 ms a 15 RPM**; vida de 30 000 ciclos de rotación y 20 000 del pulsador; filtro sugerido de **10 kΩ + 10 kΩ + 0,01 µF** por canal | **1,89 USD/ud.** (Mouser, cantidad 1, según el buscador; sin comprobación directa) |
| **ALPS Alpine EC11E15244G1** | 11 mm, mecánico incremental | 15 pulsos / 30 detents | Sí (recorrido de 0,5 mm) | 6 mm plano, 20 mm de largo | 10 mA a 5 V DC; vida de 15 000 ciclos | **3,39 GBP/ud.** (DigiKey UK, según el buscador); **4,55 GBP** (RS UK, según el buscador) |
| "EC11" genérico (clones) | 11 mm | Variable | Sí | Variable | Sin datasheet fiable del fabricante | No recomendado para el producto final |

Fuentes: Bourns https://www.bourns.com/docs/product-datasheets/pec11r.pdf · Mouser https://www.mouser.com/ProductDetail/Bourns/PEC11R-4220F-S0024 · ALPS https://tech.alpsalpine.com/e/products/detail/EC11E15244G1/ · DigiKey UK https://www.digikey.co.uk/en/products/detail/alps-alpine/EC11E15244G1/21721550 · RS https://uk.rs-online.com/web/p/mechanical-rotary-encoders/7295589

**Selección preliminar:** **Bourns PEC11R-4220F-S0024**. Es el que tiene datasheet más completo (rebote, vida útil, filtro recomendado), con 24 detents para un "clic" fino y pulsador integrado. Hay que comprobar con Miguel si ya tiene codificadores EC11 por casa: así se puede prototipar sin comprar.

### Pomos (knobs)
- El render muestra pomos metálicos con un anillo ámbar retroiluminado. Requisitos: compatibles con eje de 6 mm D (PEC11R F / EC11E) y con un anillo translúcido o un aro de luz bajo el pomo.
- Opciones: (a) pomo comercial de aluminio para eje de 6 mm más un difusor impreso en 3D con LED SK6812 debajo; (b) pomo totalmente impreso o mecanizado (Fase 4).
- **Modelos y precios concretos: pendientes de verificar.** No se ha encontrado una referencia con ficha técnica fiable en esta iteración.

## 3. Conexión a los GPIO de la Raspberry Pi

### 3.1 Esquema eléctrico preliminar (por codificador)
```
 3V3 ──┬── R 10k ──┬── GPIO_A        (canal A)
       │           └── C 10 nF ── GND
       ├── R 10k ──┬── GPIO_B        (canal B)
       │           └── C 10 nF ── GND
 Común del codificador (C) ── GND
 Pulsador: un terminal a GPIO_SW (pull-up interno o externo), el otro a GND
```
- Los valores siguen el "Suggested Filter Circuit" del datasheet del PEC11R (10 kΩ / 0,01 µF). La red RC se pone entre el contacto y el GPIO, con el pull-up a **3,3 V, nunca a 5 V**: los GPIO de la Pi son de 3,3 V y no toleran 5 V (https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#gpio).
- Los GPIO tienen pull-up internos de 50–65 kΩ (BCM2835/6/7) y de 33–73 kΩ (BCM2711) (misma fuente). Los pull-up externos de 10 kΩ dan flancos más limpios con cables largos.

### 3.2 Opción software A: overlay del kernel `rotary-encoder` (recomendada)
```
# /boot/firmware/config.txt  (pines de ejemplo, asignación definitiva pendiente)
dtoverlay=rotary-encoder,pin_a=17,pin_b=27,relative_axis=1
dtoverlay=rotary-encoder,pin_a=22,pin_b=23,relative_axis=1
dtoverlay=gpio-key,gpio=24,keycode=28,label="enc1_push"
dtoverlay=gpio-key,gpio=25,keycode=57,label="enc2_push"
```
- Parámetros documentados: `pin_a`, `pin_b`, `relative_axis`, `linux_axis`, `steps-per-period`, `encoding` (https://github.com/raspberrypi/linux/blob/rpi-6.12.y/arch/arm/boot/dts/overlays/README). El overlay activa **pull-up internos** en ambos pines (`brcm,pull = <2 2>` en `rotary-encoder-overlay.dts`). Admite varias instancias.
- `gpio-key` convierte un GPIO en una tecla `gpio-keys` con `keycode`, `gpio_pull` y `active_low` (misma fuente).
- Ventajas: la decodificación se hace en el kernel, aparece como `/dev/input/event*`, el servicio Orbit lo lee con `python-evdev` y la UI no depende de los GPIO.
- Los códigos de tecla del ejemplo son marcadores de posición. La asignación final la hace el servicio `orbitd`, no el kernel.

### 3.3 Opción software B: `gpiozero`
- `RotaryEncoder(a, b, bounce_time=None, max_steps=16, threshold_steps=(0,0), wrap=False)` con los callbacks `when_rotated`, `when_rotated_clockwise` y `when_rotated_counter_clockwise`; `Button(pin, bounce_time=…)` para el pulsador (https://gpiozero.readthedocs.io/en/stable/api_input.html).
- Útil para prototipar rápido en Python. gpiozero viene instalado por defecto en Raspberry Pi OS (documentación oficial de GPIO, enlace anterior).

### 3.4 Botón de apagado o encendido de la Pi
- El overlay `gpio-shutdown` genera `KEY_POWER` y systemd-logind inicia el apagado. Tras el apagado, **la Pi vuelve a arrancar si GPIO3 pasa a nivel bajo** (configuración por defecto, botón entre GPIO3 y GND) (README de overlays). GPIO3 también es SDA de I2C: hay que reservarlo si se usa esta función.
- La lógica del botón de encendido **del conjunto** (Pi + HP) se define en `alimentacion-preliminar.md` y en el protocolo.

### 3.5 Asignación preliminar de GPIO (borrador, pendiente de validar contra el modelo de Pi)

| Función | GPIO (BCM) | Nota |
|---|---|---|
| Codificador 1 A/B | 17 / 27 | |
| Codificador 2 A/B | 22 / 23 | |
| Pulsador codificador 1 / 2 | 24 / 25 | |
| Botón "cambiar sistema" | 5 | |
| Botón de encendido | 3 | Permite despertar la Pi (gpio-shutdown) |
| Datos de LED SK6812 | 18 (PWM/PCM) o 10 (SPI MOSI) | Según la librería; ver §5 |
| Emisor IR para el KVM | 12 | `gpio-ir-tx`, si se elige TESmart |
| Optoacoplador del botón de encendido del HP | 6 | Solo si se valida el acceso al botón del HP |

## 4. Cómo llegan los eventos de los mandos al HP

### Opción 1: por la red local (recomendada)
1. `orbitd` (servicio en la Pi) lee los eventos de `/dev/input`.
2. Según el **sistema visible** y la configuración, ejecuta la acción en local (Pi) o la envía como mensaje autenticado al agente del HP (`orbit-agent`) a través del enlace LAN.
3. El agente del HP traduce el mensaje en una acción **autorizada previamente** (volumen, brillo, atajo de teclado mediante la API del SO), según una lista blanca local.
- Ventajas: un único punto de lectura, configuración centralizada y la posibilidad de usar los mandos aunque el HP no esté visible.
- Inconvenientes: hace falta el agente del HP y el SO de destino debe permitir inyectar entrada. Añade latencia de red, que habrá que medir (no se dan cifras sin medir).

### Opción 2: microcontrolador USB HID (RP2040/RP2350) en el hub USB del KVM
- Una **Raspberry Pi Pico** (precio oficial desde 4 USD; Pico 2 a 5 USD: https://www.raspberrypi.com/products/raspberry-pi-pico-2/) se presenta como teclado o dispositivo multimedia HID (TinyUSB, incluido en el SDK: https://www.raspberrypi.com/documentation/pico-sdk/third_party.html).
- Conectada al hub del KVM, **sigue automáticamente al sistema visible** sin necesidad de un agente en el HP: funciona incluso en la BIOS o sin red.
- Inconvenientes: los mandos dejan de ser útiles para el sistema no visible, la Pi necesitaría otra vía para leerlos y aumenta el riesgo de interferir con la emulación HID del KVM.
- **Propuesta:** opción 1 como base y opción 2 como **modo de respaldo** evaluado en la Fase 3.

## 5. Iluminación ámbar

### 5.1 Opciones de LED
| Opción | Datos | Fuente |
|---|---|---|
| **SK6812 WWA** (blanco frío + blanco cálido + **ámbar**) direccionable | Ámbar de **1800–2000 K**, blanco cálido de 2700–3000 K y blanco frío de 6000–7000 K; VDD de 3,5–5,5 V (5,2 V típico); encapsulado 5050 de "0,2 W"; **VIH mín. 3,4 V** | https://cdn-shop.adafruit.com/product-files/6509/P6509+SK6812WWA+LED+datasheet.pdf |
| SK6812 / WS2812B RGB direccionable | Ámbar por mezcla RGB; menos fiel al tono "ámbar cálido" | https://www.pololu.com/file/download/sk6812_datasheet.pdf?file_id=0J1233 |
| Tira no direccionable blanco cálido o ámbar a 5 V o 12 V + MOSFET con PWM | Más sencilla; un único tono | Modelo concreto pendiente |

**Selección preliminar:** **SK6812 WWA**. El canal ámbar nativo reproduce el tono de los renders sin mezclar RGB, el blanco cálido sirve para iluminar y es direccionable, con lo que se pueden hacer animaciones e indicar el sistema activo. Precio y proveedor de la tira: **pendiente de verificar**.

### 5.2 Alimentación de los LED
- 5 V desde un raíl dedicado (ver `alimentacion-preliminar.md`), **no desde el pin de 5 V de la Pi** para tiras de más de unos pocos LED.
- Potencia: el datasheet indica un encapsulado de "0,2 W". Como cota superior preliminar, **N LED × 0,2 W**. Habrá que medirlo con la tira real, y el firmware limitará el brillo máximo.
- Buenas prácticas: condensador electrolítico en la entrada de la tira y resistencia en serie en la línea de datos. Los valores se fijarán con la tira elegida (pendiente).

### 5.3 Adaptación de nivel 3,3 V → 5 V
- El VIH mínimo de 3,4 V del SK6812 WWA es **superior** a la salida de 3,3 V de un GPIO de la Pi (VOH ≥ 3,0 V en BCM2835/6/7; ≥ 2,6 V en BCM2711, según la documentación oficial de GPIO). **Hace falta un adaptador de nivel.**
- Referencia: **74AHCT125** (Adafruit 1787, 1,50 USD, "out of stock" según el buscador: https://www.adafruit.com/product/1787). Cableado: VCC a 5 V, /OE a GND, GPIO → A, Y → DIN (guía de Adafruit: https://learn.adafruit.com/neopixels-on-raspberry-pi/raspberry-pi-wiring).

### 5.4 Software de los LED según el modelo de Pi
- Pi 3B+/4B: librería `rpi_ws281x` / Adafruit NeoPixel.
- **Pi 5: `rpi_ws281x` no es compatible.** Hay que usar el controlador basado en PIO `Adafruit-Blinka-Raspberry-Pi5-Neopixel`, que requiere `/dev/pio0` (https://github.com/adafruit/Adafruit_Blinka_Raspberry_Pi5_Neopixel; incidencia https://github.com/adafruit/Adafruit_Blinka/issues/747). También se puede usar SPI.
- Ambos casos quedarán aislados tras una interfaz `LedDriver` en `orbitd`, con implementación simulada para las pruebas.
