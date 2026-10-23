#!/usr/bin/env bash
# Conecta aparatos Bluetooth de confianza. BlueZ no lo hace solo en la sesión orbit:
# el journal no muestra intentos y el teclado, dormido, responde Page Timeout.
# Los 3 primeros minutos, cada 10 s. Luego cada 30 s mientras no haya un teclado
# conectado. Pasada media hora, cada 2 min, para no insistir.
# Trusted; si BlueZ no acepta ese filtro (visto en la 5.82), Paired.

bt_log() {
  printf '%s\n' "orbit-bt-autoconnect: $*"
}

btctl_timeout() {
  local seg="$1" cmd
  shift
  cmd="${ORBIT_BTCTL:-bluetoothctl}"
  if command -v timeout >/dev/null 2>&1; then
    timeout "$seg" "$cmd" "$@"
  else
    "$cmd" "$@"
  fi
}

es_teclado() {
  printf '%s\n' "$1" | grep -Eq 'input-keyboard|00001124|Human Interface Device'
}

# Segundos hasta la próxima pasada. edad: segundos desde el arranque del servicio.
espera_segundos() {
  local edad="$1" conectado="$2"
  if [[ "$conectado" -eq 1 ]]; then
    printf '%s\n' "${ORBIT_BT_WATCH_EVERY:-60}"
    return 0
  fi
  if [[ "$edad" -lt "${ORBIT_BT_FAST_SECS:-180}" ]]; then
    printf '%s\n' "${ORBIT_BT_FAST_EVERY:-10}"
  elif [[ "$edad" -lt "${ORBIT_BT_SLOW_AFTER:-1800}" ]]; then
    printf '%s\n' "${ORBIT_BT_EVERY:-30}"
  else
    printf '%s\n' "${ORBIT_BT_SLOW_EVERY:-120}"
  fi
}

listar_macs() {
  local out rc=0
  out=$(btctl_timeout 8 devices Trusted 2>&1) || rc=$?
  if [[ "$rc" -eq 124 ]]; then
    bt_log "devices Trusted no respondió"
    return 0
  fi
  if [[ "$rc" -ne 0 ]] || printf '%s\n' "$out" | grep -Eq 'Too many arguments|Invalid argument|Usage:'; then
    rc=0
    out=$(btctl_timeout 8 devices Paired 2>&1) || rc=$?
    if [[ "$rc" -ne 0 ]] || printf '%s\n' "$out" | grep -Eq 'Too many arguments|Invalid argument|Usage:'; then
      out=$(btctl_timeout 8 devices 2>&1 || true)
    fi
  fi
  printf '%s\n' "$out" | awk '/^Device / { print $2 }'
}

ronda_autoconnect() {
  local macs mac info hay_teclado=0 salida src=0
  bt_teclado_conectado=0
  macs=$(listar_macs)
  if [[ -z "${macs//[$' \n']/}" ]]; then
    bt_log "ningún aparato Trusted ni Paired"
    return 0
  fi
  local -a lista=() infos=()
  while read -r mac; do
    [[ -n "$mac" ]] || continue
    info=$(btctl_timeout 8 info "$mac" 2>&1 || true)
    lista+=("$mac")
    infos+=("$info")
    if es_teclado "$info"; then
      hay_teclado=1
    fi
  done <<< "$macs"
  local i
  for i in "${!lista[@]}"; do
    mac="${lista[$i]}"
    info="${infos[$i]}"
    if printf '%s\n' "$info" | grep -q 'Connected: yes'; then
      if es_teclado "$info" || [[ "$hay_teclado" -eq 0 ]]; then
        bt_teclado_conectado=1
      fi
      continue
    fi
    bt_log "connect $mac"
    src=0
    salida=$(btctl_timeout 12 connect "$mac" 2>&1) || src=$?
    if [[ "$src" -eq 0 ]]; then
      bt_log "connect $mac: ${salida:-ok}"
    else
      bt_log "connect $mac falló (${src}): ${salida:-sin respuesta}"
    fi
  done
}

bucle_autoconnect() {
  local rondas=0 edad espera inicio
  inicio=${SECONDS:-0}
  bt_teclado_conectado=0
  while true; do
    ronda_autoconnect
    rondas=$((rondas + 1))
    if [[ -n "${ORBIT_BT_ROUNDS:-}" && "$rondas" -ge "$ORBIT_BT_ROUNDS" ]]; then
      return 0
    fi
    edad=$(( ${SECONDS:-0} - inicio ))
    espera=$(espera_segundos "$edad" "${bt_teclado_conectado:-0}")
    if [[ -z "${ORBIT_BT_NO_SLEEP:-}" ]]; then
      sleep "$espera"
    fi
  done
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  bucle_autoconnect
fi
