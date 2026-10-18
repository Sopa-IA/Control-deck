# arduino-controls · Arduino Micro (ATmega32U4)

Este firmware lee los potenciómetros y botones de la consola y los envía a orbitd por USB serie (115200 baudios). El formato está en `software/shared/PROTOCOLO.md` §7. Los encoders se han sustituido por potenciómetros.

## Mapa de pines (por defecto; se cambia en `orbit_controls/config.h`)

| Señal | Pin del Arduino Micro | Conexión |
|---|---|---|
| P1 (volumen HP) | A0 | Cursor del potenciómetro; extremos a 5 V y GND |
| P2 (desplazar / foco) | A1 | Ídem |
| P3 (brillo LED, pendiente) | A2 | Ídem |
| B1 (menú de apagado) | D2 | Pulsador a GND (pull-up interno) |
| B2 (cambiar sistema: guía OSD) | D3 | Pulsador a GND |
| B3 (seleccionar) | D5 | Pulsador a GND |
| B4 (volver) | D7 | Pulsador a GND |
| Reservado para datos de la tira LED | D6 | **PENDIENTE**: tira sin identificar |

Notas sobre los pines:

- D2 y D3 son también SDA y SCL (I²C). Si más adelante hace falta I²C, hay que mover los botones a otros pines.
- Libres para ampliar: A3–A5, D4/A6, D8/A7, D9/A8, D10/A9, D12/A11.

La función de cada control se asigna en orbitd y en la interfaz (sección **Controles**). El Arduino solo informa de lo que lee.

## Configuración (`config.h`)

| Parámetro | Valor por defecto |
|---|---|
| `NUM_POTS` / `POT_PINS` | 3 / `{A0, A1, A2}` |
| `NUM_BUTTONS` / `BUTTON_PINS` | 4 / `{2, 3, 5, 7}` |
| `POT_EMA_SHIFT` | 3 (media exponencial con α = 1/8) |
| `POT_HYSTERESIS` | 4 cuentas de 1023 |
| `POT_SAMPLE_MS` | 5 ms |
| `DEBOUNCE_MS` | 20 ms |
| `LONG_PRESS_MS` | 800 ms |
| `ENABLE_HID_VOLUME` | 0 |

Con `ENABLE_HID_VOLUME 1`, P1 envía las teclas multimedia de volumen +/− y hace falta la librería **HID-Project** (NicoHood). Va desactivado por defecto porque el HID actúa sobre el ordenador al que está enchufado el Arduino: en el prototipo es la Pi, no el HP.

## Compilar y subir

```bash
arduino-cli core install arduino:avr
arduino-cli compile --fqbn arduino:avr:micro software/arduino-controls/orbit_controls
arduino-cli upload  --fqbn arduino:avr:micro -p /dev/ttyACM0 software/arduino-controls/orbit_controls
arduino-cli monitor -p /dev/ttyACM0 -c baudrate=115200    # escribe ? para recibir el saludo
```

**Estado:** compila sin avisos con `arduino-cli` 1.x para `arduino:avr:micro` (5340 bytes, el 18 % de la flash; con `ENABLE_HID_VOLUME 1`, 6680 bytes). **No se ha probado en una placa real.** Faltan por elegir y comprobar los valores de los potenciómetros, el cableado y la caja.
