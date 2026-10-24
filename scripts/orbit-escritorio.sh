#!/usr/bin/env bash
# Vuelve al escritorio de Raspberry Pi en el próximo arranque.
# No fusiona el kiosco: la sesión pasa a ser rpd-labwc o LXDE-pi-labwc.
set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Hay que ejecutarlo con sudo: sudo orbit-escritorio" >&2
  exit 1
fi

usuario="${1:-${SUDO_USER:-}}"
if [[ -z "$usuario" || "$usuario" == root ]]; then
  usuario="$(getent passwd | awk -F: '$3>=1000 && $3<65534 {print $1; exit}')"
fi
if [[ -z "$usuario" ]]; then
  echo "No hay un usuario de escritorio." >&2
  exit 1
fi
ORBIT_HOME="$(getent passwd "$usuario" | cut -d: -f6)"
export ORBIT_HOME

dir="$(cd "$(dirname "$0")" && pwd)"
nombre="$("$dir/orbit-lightdm.sh" escritorio "$usuario")"
echo "Sesión gráfica: ${nombre}"
echo "Reinicia para ver el escritorio de Raspberry Pi: sudo reboot"
echo "Para volver a Orbit OS: sudo bash scripts/instalar-pi.sh y otra vez sudo reboot"
