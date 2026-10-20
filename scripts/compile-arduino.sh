#!/usr/bin/env bash
# Compila el firmware del Nano de mandos y el ejemplo del Nano de prácticas.
# Requiere arduino-cli y el core arduino:avr.
# FQBN por defecto: arduino:avr:nano (bootloader nuevo, Optiboot).
# Los clones CH340 suelen traer el bootloader viejo: misma fuente, otro FQBN
# (cpu=atmega328old). Se compilan los dos. El baudios de subida lo elige el
# core; el sketch sigue hablando a 115200.
set -euo pipefail
cd "$(dirname "$0")/.."
ACLI=${ARDUINO_CLI:-arduino-cli}
FQBN=${ARDUINO_FQBN:-arduino:avr:nano}
OLD=arduino:avr:nano:cpu=atmega328old
"$ACLI" compile --fqbn "$FQBN" --warnings all software/arduino-controls/orbit_controls
"$ACLI" compile --fqbn "$OLD" --warnings all software/arduino-controls/orbit_controls
"$ACLI" compile --fqbn "$FQBN" --warnings all software/arduino-pruebas/monitor_pines
"$ACLI" compile --fqbn "$OLD" --warnings all software/arduino-pruebas/monitor_pines
