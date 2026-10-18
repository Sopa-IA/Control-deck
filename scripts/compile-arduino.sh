#!/usr/bin/env bash
# Compila el firmware del Arduino Micro (requiere arduino-cli y el core arduino:avr).
set -euo pipefail
cd "$(dirname "$0")/.."
ACLI=${ARDUINO_CLI:-arduino-cli}
"$ACLI" compile --fqbn arduino:avr:micro --warnings all software/arduino-controls/orbit_controls
