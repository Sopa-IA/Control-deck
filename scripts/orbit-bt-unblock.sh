#!/bin/sh
# Cada arranque, después de bluetoothd y de systemd-rfkill.
# hci0 vuelve a salir con Soft blocked: la sesión orbit no tiene el escritorio.
set -u
if command -v rfkill >/dev/null 2>&1; then
  rfkill unblock bluetooth || true
fi
if ! command -v bluetoothctl >/dev/null 2>&1; then
  exit 0
fi
i=0
while [ "$i" -lt 5 ]; do
  if timeout 2 bluetoothctl power on; then
    exit 0
  fi
  i=$((i + 1))
  sleep 1
done
exit 0
