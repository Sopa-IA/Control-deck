#!/usr/bin/env bash
# Quita el bloqueo de software del Bluetooth y lo repite en cada arranque.
# La sesión orbit no lanza el panel del escritorio, que es quien lo desbloqueaba.
# Sin rfkill, sin bluez o sin adaptador, no falla y no crea archivos.
# Se puede repetir.

poner_clave() {
  local f="$1" clave="$2" valor="$3" linea
  linea="${clave}=${valor}"
  if grep -Fxq "$linea" "$f"; then
    return 0
  fi
  if grep -Eq "^[[:space:]]*#?[[:space:]]*${clave}[[:space:]]*=" "$f"; then
    sed -i -E "s|^[[:space:]]*#?[[:space:]]*${clave}[[:space:]]*=.*|${linea}|" "$f"
    return 0
  fi
  if grep -q '^\[Policy\]' "$f"; then
    sed -i "/^\[Policy\]/a ${linea}" "$f"
    return 0
  fi
  printf '\n[Policy]\n%s\n' "$linea" >> "$f"
}

# AutoEnable enciende el adaptador al arrancar bluetoothd.
# ReconnectAttempts e intervalos son los de BlueZ: unos dos minutos
# de reintentos para un aparato marcado con trust.
poner_politica() {
  local f="$1" dir
  dir="$(dirname "$f")"
  [[ -d "$dir" ]] || return 0
  if [[ ! -f "$f" ]]; then
    cat > "$f" <<'EOF'
[Policy]
AutoEnable=true
ReconnectAttempts=7
ReconnectIntervals=1, 2, 4, 8, 16, 32, 64
EOF
    chmod 644 "$f"
    return 0
  fi
  poner_clave "$f" AutoEnable true
  poner_clave "$f" ReconnectAttempts 7
  poner_clave "$f" ReconnectIntervals "1, 2, 4, 8, 16, 32, 64"
}

desbloquear_bluetooth() {
  local conf unit bin origen rfkill sys estado wants hay
  conf="${ORBIT_BT_CONF:-/etc/bluetooth/main.conf}"
  unit="${ORBIT_BT_UNIT:-/etc/systemd/system/orbit-bt-unblock.service}"
  bin="${ORBIT_BT_BIN:-/usr/local/bin/orbit-bt-unblock}"
  origen="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/orbit-bt-unblock.sh"
  hay=0
  if [[ -v ORBIT_RFKILL ]]; then
    rfkill="$ORBIT_RFKILL"
  else
    rfkill="$(command -v rfkill || true)"
  fi
  [[ -n "$rfkill" && -x "$rfkill" ]] && hay=1
  [[ -d "$(dirname "$conf")" ]] && hay=1
  if [[ -v ORBIT_BLUETOOTHCTL ]]; then
    [[ -n "$ORBIT_BLUETOOTHCTL" ]] && hay=1
  elif command -v bluetoothctl >/dev/null 2>&1; then
    hay=1
  fi
  if [[ "$hay" -eq 0 ]]; then
    printf '== No hay Bluetooth. No se cambia nada.\n'
    return 0
  fi

  if [[ -n "$rfkill" && -x "$rfkill" ]]; then
    "$rfkill" unblock bluetooth || true
    install -d -m 755 "$(dirname "$bin")" "$(dirname "$unit")"
    install -m 755 "$origen" "$bin"
    if [[ "$unit" == /etc/systemd/system/orbit-bt-unblock.service ]]; then
      rm -f /etc/systemd/system/orbit-bluetooth.service
      rm -f /etc/systemd/system/multi-user.target.wants/orbit-bluetooth.service
    fi
    cat > "$unit" <<EOF
[Unit]
Description=Desbloquear el Bluetooth de Orbit en cada arranque
After=bluetooth.service systemd-rfkill.service
Wants=bluetooth.service

[Service]
Type=oneshot
ExecStart=${bin}
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    chmod 644 "$unit"
  fi

  poner_politica "$conf"

  sys=""
  if [[ -n "${ORBIT_SYSTEMCTL:-}" ]]; then
    sys="$ORBIT_SYSTEMCTL"
  elif [[ -d /run/systemd/system ]] && command -v systemctl >/dev/null 2>&1; then
    sys="systemctl"
  fi
  if [[ -n "$sys" ]]; then
    estado="$("$sys" show -p LoadState --value bluetooth.service 2>/dev/null || true)"
    if [[ "$estado" == loaded ]]; then
      "$sys" enable bluetooth.service || true
      "$sys" start bluetooth.service || true
    fi
    if [[ -f "$unit" ]]; then
      "$sys" daemon-reload || true
      "$sys" enable orbit-bt-unblock.service || true
      "$sys" start orbit-bt-unblock.service || true
    fi
  elif [[ -f "$unit" ]]; then
    wants="${ORBIT_SYSTEMD_WANTS:-/etc/systemd/system/multi-user.target.wants}"
    install -d -m 755 "$wants"
    ln -sfn "$unit" "$wants/orbit-bt-unblock.service"
  fi
  printf '== Bluetooth desbloqueado en cada arranque (orbit-bt-unblock).\n'
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  desbloquear_bluetooth
fi
