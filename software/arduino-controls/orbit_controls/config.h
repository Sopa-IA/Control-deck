// Orbit Terminal · orbit_controls · CONFIGURACIÓN
// Placa: Arduino Nano (ATmega328P). El clon de Miguel lleva mini-USB y, según él,
// un conversor USB-serie probablemente CH340. No es un Micro (ese tiene USB nativo).
// Cambia aquí el número de potenciómetros y botones y sus pines.
#pragma once

// ---- Potenciómetros (lineales, 10 kΩ recomendados; extremos a 5 V y GND, cursor al pin analógico)
#define NUM_POTS 2
static const uint8_t POT_PINS[NUM_POTS] = {A0, A1};

// ---- Botones (pulsador entre el pin y GND; se usa INPUT_PULLUP: pulsado = LOW)
// D0 y D1 son el UART del USB-serie: no usarlos. En el Nano, SDA/SCL son A4/A5, no D2/D3.
#define NUM_BUTTONS 2
static const uint8_t BUTTON_PINS[NUM_BUTTONS] = {2, 3};

// ---- Filtro de potenciómetros
#define POT_EMA_SHIFT 3      // media exponencial con alfa = 1/2^3 = 1/8
#define POT_HYSTERESIS 4     // solo se envía si cambia >= 4 cuentas (de 1023)
#define POT_SAMPLE_MS 5      // periodo de muestreo

// ---- Botones
#define DEBOUNCE_MS 20       // el estado debe ser estable 20 ms
#define LONG_PRESS_MS 800    // pulsación larga

// ---- Serie (UART del ATmega328P, a 115200; el CH340 lo presenta como USB)
#define SERIAL_BAUD 115200
#define FW_NAME "orbit-controls"
#define FW_VERSION "1"

// ---- Volumen por USB HID: NO es posible en esta placa.
// El ATmega328P no tiene USB nativo. Un Nano no puede enviar teclas multimedia.
// El volumen del HP lo aplica orbitd -> hp-agent (hp.volume_set). La constante
// se queda a 0 para que un cambio accidental no compile: ver el #error del .ino.
#define ENABLE_HID_VOLUME 0

// D6 ya no se reserva para la tira LED. La tira, cuando se identifique, la lleva
// el ESP8266 con WLED (ver software/arduino-controls/README.md). D6 queda libre.
