#!/usr/bin/env bash
# Fija la sesión de LightDM. No arranca el compositor.
#   orbit-lightdm.sh orbit USUARIO
#   orbit-lightdm.sh escritorio [USUARIO]
# La de escritorio es rpd-labwc si ese archivo existe; si no, LXDE-pi-labwc.
# Pruebas: ORBIT_LIGHTDM_CONF, ORBIT_LIGHTDM_DROPIN, ORBIT_WAYLAND_SESSIONS,
# ORBIT_ACCOUNT_FILE (vacío = no tocar), ORBIT_DMRC (vacío = no tocar).
set -euo pipefail

modo="${1:-}"
usuario="${2:-}"

CONF="${ORBIT_LIGHTDM_CONF:-/etc/lightdm/lightdm.conf}"
DROPIN="${ORBIT_LIGHTDM_DROPIN:-/etc/lightdm/lightdm.conf.d/zz-orbit.conf}"
SESSIONS="${ORBIT_WAYLAND_SESSIONS:-/usr/share/wayland-sessions}"

sesion_de_escritorio() {
  if [[ -f "${SESSIONS}/rpd-labwc.desktop" ]]; then
    printf '%s\n' rpd-labwc
    return
  fi
  if [[ -f "${SESSIONS}/LXDE-pi-labwc.desktop" ]]; then
    printf '%s\n' LXDE-pi-labwc
    return
  fi
  printf '%s\n' LXDE-pi-labwc
}

case "$modo" in
  orbit)
    if [[ -z "$usuario" ]]; then
      echo "Falta el usuario: orbit-lightdm.sh orbit USUARIO" >&2
      exit 1
    fi
    nombre=orbit
    ;;
  escritorio)
    nombre="$(sesion_de_escritorio)"
    ;;
  *)
    echo "Uso: orbit-lightdm.sh orbit USUARIO | escritorio [USUARIO]" >&2
    exit 1
    ;;
esac

fijar_clave() {
  local file="$1" key="$2" value="$3"
  [[ -f "$file" ]] || return 0
  if grep -qE "^#?${key}=" "$file"; then
    sed -i -e "s/^#\\?${key}=.*/${key}=${value}/" "$file"
  fi
}

poner_sesion_usuario() {
  local file="$1" key="$2" value="$3"
  [[ -n "$file" && -f "$file" ]] || return 0
  if grep -q "^${key}=" "$file"; then
    sed -i -e "s/^${key}=.*/${key}=${value}/" "$file"
  else
    printf '%s=%s\n' "$key" "$value" >> "$file"
  fi
}

install -d -m 755 "$(dirname "$DROPIN")"
if [[ "$modo" == orbit ]]; then
  cat > "$DROPIN" <<EOF
[Seat:*]
autologin-user=${usuario}
autologin-user-timeout=0
user-session=orbit
autologin-session=orbit
EOF
  fijar_clave "$CONF" autologin-user "$usuario"
else
  # El autologin-user queda en lightdm.conf. Este archivo solo cambia la sesión.
  cat > "$DROPIN" <<EOF
[Seat:*]
user-session=${nombre}
autologin-session=${nombre}
EOF
fi
chmod 644 "$DROPIN"
fijar_clave "$CONF" user-session "$nombre"
fijar_clave "$CONF" autologin-session "$nombre"

if [[ -n "${ORBIT_ACCOUNT_FILE+x}" ]]; then
  cuenta="$ORBIT_ACCOUNT_FILE"
elif [[ -n "$usuario" && -f "/var/lib/AccountsService/users/${usuario}" ]]; then
  cuenta="/var/lib/AccountsService/users/${usuario}"
else
  cuenta=""
fi
poner_sesion_usuario "$cuenta" XSession "$nombre"
poner_sesion_usuario "$cuenta" Session "$nombre"

if [[ -n "${ORBIT_DMRC+x}" ]]; then
  dmrc="$ORBIT_DMRC"
elif [[ -n "${ORBIT_HOME:-}" && -f "${ORBIT_HOME}/.dmrc" ]]; then
  dmrc="${ORBIT_HOME}/.dmrc"
else
  dmrc=""
fi
poner_sesion_usuario "$dmrc" Session "$nombre"

printf '%s\n' "$nombre"
