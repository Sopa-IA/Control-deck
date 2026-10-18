// Orbit Terminal · orbit_controls · CONFIGURACIÓN (Arduino Micro, ATmega32U4)
// Cambia aquí el número de potenciómetros y botones y sus pines.
#pragma once

// ---- Potenciómetros (lineales, 10 kΩ recomendados; extremos a 5 V y GND, cursor al pin analógico)
#define NUM_POTS 2
static const uint8_t POT_PINS[NUM_POTS] = {A0, A1};

// ---- Botones (pulsador entre el pin y GND; se usa INPUT_PULLUP: pulsado = LOW)
#define NUM_BUTTONS 2
static const uint8_t BUTTON_PINS[NUM_BUTTONS] = {2, 3};

// ---- Filtro de potenciómetros
#define POT_EMA_SHIFT 3      // media exponencial con alfa = 1/2^3 = 1/8
#define POT_HYSTERESIS 4     // solo se envía si cambia >= 4 cuentas (de 1023)
#define POT_SAMPLE_MS 5      // periodo de muestreo

// ---- Botones
#define DEBOUNCE_MS 20       // el estado debe ser estable 20 ms
#define LONG_PRESS_MS 800    // pulsación larga

// ---- Serie (USB CDC)
#define SERIAL_BAUD 115200
#define FW_NAME "orbit-controls"
#define FW_VERSION "1"

// ---- USB HID opcional (teclas multimedia de volumen) — requiere la librería "HID-Project" (NicoHood)
// OJO: el HID actúa sobre el ordenador al que está ENCHUFADO el Arduino. En el prototipo el Arduino va
// a la Raspberry Pi, así que el volumen HID cambiaría el de la Pi, NO el del HP. Por eso está desactivado:
// el volumen del HP lo gestiona orbitd -> hp-agent (hp.volume_set). Actívalo solo si el Arduino va al HP.
#define ENABLE_HID_VOLUME 0
#define HID_VOLUME_POT 0          // índice del potenciómetro que envía VOLUMEN +/- (0 = P1)
#define HID_VOLUME_STEP 20        // cuentas de potenciómetro por cada pulsación de volumen (~50 pasos)
