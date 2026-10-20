# arduino-controls · Arduino Nano de mandos (ATmega328P)

Este firmware lee los potenciómetros y botones de la consola y los envía a orbitd por serie (115200 baudios). El formato está en [`../shared/PROTOCOLO.md`](../shared/PROTOCOLO.md) §7. Los encoders se han sustituido por potenciómetros.

La placa es un **Nano clon** (mini-USB; el conversor USB-serie es probablemente un CH340, dato de Miguel, chip no leído). No es el Arduino Micro de los documentos de la fase 1: el ATmega328P **no tiene USB nativo**.

Hay otro Nano, el de prácticas, con su propio sketch en [`../arduino-pruebas/`](../arduino-pruebas/). No comparte este firmware ni el puerto de orbitd.

## Mapa de pines (por defecto; se cambia en `orbit_controls/config.h`)

| Señal | Pin del Nano | Conexión |
|---|---|---|
| P1 (volumen HP) | A0 | Cursor del potenciómetro; extremos a 5 V y GND |
| P2 (desplazar / foco) | A1 | Ídem |
| B1 (menú de apagado) | D2 | Pulsador a GND (pull-up interno) |
| B2 (cambiar sistema visible, automático) | D3 | Pulsador a GND |

Notas:

- D0 y D1 son el UART del USB-serie. No se usan para mandos.
- En el Nano, SDA y SCL son A4 y A5, no D2 y D3. Los botones pueden quedarse en D2 y D3.
- D6 **ya no** se reserva para la tira LED. La tira, cuando se sepa cuál es, la lleva el ESP8266 con WLED (abajo). D6 queda libre.
- Libres en esta placa: A2–A7, D4–D13, con las salvedades de D0/D1.

La función de cada control se asigna en orbitd y en la interfaz (sección **Controles**). El Arduino solo informa de lo que lee.

## Volumen HID: no cabe en esta placa

`ENABLE_HID_VOLUME` está a 0. Si se pone a 1, el sketch **no compila** (`#error` en el `.ino`).

El ATmega32U4 del Micro podía enviar teclas multimedia USB. El ATmega328P no. Un Nano no puede hacer de teclado. El volumen del HP lo aplica orbitd hacia hp-agent (`hp.volume_set`). Aunque un HID fuera posible, el Arduino está enchufado a la Pi, no al HP: las teclas llegarían a la Pi.

## Serie y el reinicio al abrir el puerto

El CH340 presenta un puerto `/dev/ttyUSB*`, no `/dev/ttyACM*` (ese nombre es el del USB nativo del Micro). Ejemplo por defecto: `/dev/ttyUSB0`. Si el ESP8266 también está enchufado, el número puede ser otro. En la Pi hay que mirar `/dev/serial/by-id`. **PENDIENTE**: no se ha leído en la Pi de Miguel, y el comportamiento del CH340 de este clon no se ha probado.

Abrir el puerto pulsa DTR y el Nano se reinicia. Lo que orbitd escribiera durante el bootloader se pierde. Por eso espera `NANO_RESET_WAIT_S` (2,0 s, **DISEÑO**, no cronometrado en este clon) antes de enviar `?`. El saludo que el sketch manda solo al arrancar se lee igual. El `?` cubre el caso en que abrir el puerto no haya reiniciado la placa. Se cambia con `--serial-reset-wait` o `ORBIT_SERIAL_RESET_WAIT`.

## La tira LED va al ESP8266

Tipo y tensión de la tira: **PENDIENTE**. El plan es WLED en el NodeMCU (ESP-12, micro-USB), no un pin de este Nano.

Según la [guía de WLED](https://kno.wled.ge/basics/getting-started/), en ESP8266 el pin de datos por defecto es GPIO2, rotulado D4 en la mayoría de NodeMCU. GPIO2 tiene que estar en alto al arrancar; a veces hace falta una pull-up de 3,3–4,7 kΩ a 3,3 V. La masa de la tira va unida a la del ESP. **No** alimentar la tira desde el regulador de 3,3 V del módulo. Si la tira es direccionable de 5 V, el dato a 3,3 V puede quedarse corto (en WS2812 y SK6812 el VIH suele pedir más de 3,3 V): un desplazador de nivel es **PENDIENTE** hasta saber la tira.

El ESP se fija con velcro o brida en la bandeja ya impresa. No hay torretas nuevas en ese STL. Medidas de la placa de la foto: **PENDIENTE**. El marcador usa la envolvente de referencia del NodeMCU DEVKIT 1.0 (25,4 × 48,26 mm) y del Ai-Thinker NodeMCU-8266 V1.2 (25,4 × 48,3 mm ± 0,2). Un clon tipo LoLin V3 suele listarse más largo; si la placa es esa, el marcador se queda corto.

## Configuración (`config.h`)

| Parámetro | Valor por defecto |
|---|---|
| `NUM_POTS` / `POT_PINS` | 2 / `{A0, A1}` |
| `NUM_BUTTONS` / `BUTTON_PINS` | 2 / `{2, 3}` |
| `POT_EMA_SHIFT` | 3 (media exponencial con α = 1/8) |
| `POT_HYSTERESIS` | 4 cuentas de 1023 |
| `POT_SAMPLE_MS` | 5 ms |
| `DEBOUNCE_MS` | 20 ms |
| `LONG_PRESS_MS` | 800 ms |
| `ENABLE_HID_VOLUME` | 0 (ponerlo a 1 no compila) |
| `SERIAL_BAUD` | 115200 (el del sketch; el de la subida lo elige el core) |

## Compilar y subir

```bash
arduino-cli core install arduino:avr
./scripts/compile-arduino.sh
# bootloader nuevo (Optiboot):
arduino-cli upload --fqbn arduino:avr:nano -p /dev/ttyUSB0 software/arduino-controls/orbit_controls
# clones CH340, bootloader viejo (ATmegaBOOT):
arduino-cli upload --fqbn arduino:avr:nano:cpu=atmega328old -p /dev/ttyUSB0 software/arduino-controls/orbit_controls
arduino-cli monitor -p /dev/ttyUSB0 -c baudrate=115200    # escribe ? para recibir el saludo
```

**Estado (2026-10-20, este entorno):** `arduino-cli` 1.5.1 y core `arduino:avr` 1.8.8. Los dos FQBN salen igual: **2982 bytes (9 % de 30720)** y **226 bytes de RAM (11 % de 2048)**. **No se ha probado en la placa.** Faltan los valores de los potenciómetros, el cableado y saber qué bootloader trae el clon. El canal USB de la bandeja impresa mide 10 mm de ancho; si el tapón del cable mini-USB pasa es **PENDIENTE**.
