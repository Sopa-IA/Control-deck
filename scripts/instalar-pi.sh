#!/usr/bin/env bash
# Instala Orbit OS en una Raspberry Pi para que, al encender, lo primero sea Orbit OS.
# Idempotente: se puede ejecutar otra vez. Hay que lanzarlo con sudo, con Wi-Fi e internet.
# No toca la puerta de enlace del Wi-Fi. eth0 queda en 10.0.0.2/24, sin puerta ni DNS.
set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Hay que ejecutarlo con sudo: sudo bash scripts/instalar-pi.sh" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODEL=""
if [[ -r /proc/device-tree/model ]]; then
  MODEL="$(tr -d '\0' < /proc/device-tree/model)"
fi
# Sin device-tree (contenedor de prueba) se puede inyectar el modelo. En la Pi no hace falta.
if [[ -z "$MODEL" && -n "${ORBIT_DEVICE_MODEL:-}" ]]; then
  MODEL="$ORBIT_DEVICE_MODEL"
fi
if [[ "$MODEL" != Raspberry\ Pi* && "${ORBIT_INSTALL_ANY:-}" != 1 ]]; then
  echo "Este instalador es para una Raspberry Pi. Detectado: ${MODEL:-nada}." >&2
  exit 1
fi

ORBIT_USER="${SUDO_USER:-}"
if [[ -z "$ORBIT_USER" || "$ORBIT_USER" == root ]]; then
  ORBIT_USER="$(getent passwd | awk -F: '$3>=1000 && $3<65534 {print $1; exit}')"
fi
if [[ -z "$ORBIT_USER" ]]; then
  echo "No hay un usuario de escritorio. Créalo en Raspberry Pi Imager." >&2
  exit 1
fi
ORBIT_HOME="$(getent passwd "$ORBIT_USER" | cut -d: -f6)"
ORBIT_UID="$(id -u "$ORBIT_USER")"
LABWC_RC="$ORBIT_HOME/.config/labwc/rc.xml"

log() { printf '== %s\n' "$*"; }

as_user() {
  if command -v runuser >/dev/null 2>&1; then
    runuser -u "$ORBIT_USER" -- "$@"
  else
    sudo -u "$ORBIT_USER" -H "$@"
  fi
}

apt_optional() {
  local pkg="$1"
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    return 0
  fi
  if ! apt-cache show "$pkg" >/dev/null 2>&1; then
    log "Opcional y ausente en este sistema: $pkg"
    return 0
  fi
  if apt-get install -y "$pkg"; then
    log "Instalado (opcional): $pkg"
  else
    log "Opcional y ausente en este sistema: $pkg"
  fi
}

moonlight_distro() {
  # La Pi 64-bit se anuncia como debian. Moonlight publica el paquete de la Pi en el canal raspbian.
  local id like
  if [[ "$MODEL" == Raspberry\ Pi* || -f /etc/rpi-issue ]]; then
    printf '%s\n' raspbian
    return
  fi
  id="$(sed -n 's/^ID=//p' /etc/os-release | head -n1 | tr -d '"')"
  like="$(sed -n 's/^ID_LIKE=//p' /etc/os-release | head -n1 | tr -d '"')"
  if [[ "$id" == raspbian || "$like" == *raspbian* ]]; then
    printf '%s\n' raspbian
  else
    printf '%s\n' debian
  fi
}

install_moonlight() {
  local distro="$1" codename
  codename="$(lsb_release -cs)"
  log "Moonlight Qt, canal ${distro}/${codename}"
  # https://github.com/moonlight-stream/moonlight-docs/wiki/Installing-Moonlight-Qt-on-Raspberry-Pi-4
  curl -1sLf 'https://dl.cloudsmith.io/public/moonlight-game-streaming/moonlight-qt/setup.deb.sh' \
    | distro="$distro" codename="$codename" bash
  apt-get update
  apt-get install -y moonlight-qt
}

systemd_up() { [[ -d /run/systemd/system ]]; }

export DEBIAN_FRONTEND=noninteractive
log "Paquetes"
apt-get update
apt-get install -y \
  python3 python3-venv python3-pip \
  nodejs npm \
  curl ca-certificates gnupg lsb-release \
  network-manager sudo \
  unclutter x11-xserver-utils \
  xdg-utils
if ! dpkg -s chromium >/dev/null 2>&1 && ! dpkg -s chromium-browser >/dev/null 2>&1; then
  apt-get install -y chromium || apt-get install -y chromium-browser
fi
# labwc está en el archivo de Raspberry Pi OS (Bookworm y Trixie) y en Debian Trixie.
# No está en Debian Bookworm. La imagen de escritorio de la Pi ya lo trae.
if ! dpkg -s labwc >/dev/null 2>&1; then
  if apt-cache show labwc >/dev/null 2>&1; then
    apt-get install -y labwc
  else
    log "labwc no está en este repositorio. En la imagen de escritorio de la Pi ya viene. Sin él no hay kiosco Wayland."
  fi
fi
apt_optional wlrctl
apt_optional wmctrl
# Fondo negro al entrar en la sesión, si el paquete está. Sin él el kiosco igual arranca.
apt_optional swaybg
if ! command -v lxterminal >/dev/null && ! command -v x-terminal-emulator >/dev/null; then
  apt_optional lxterminal
fi

if ! dpkg -s moonlight-qt >/dev/null 2>&1; then
  DISTRO="$(moonlight_distro)"
  if ! install_moonlight "$DISTRO"; then
    rm -f /etc/apt/sources.list.d/*moonlight*
    apt-get update
    if [[ "$DISTRO" != debian ]]; then
      log "El canal ${DISTRO} no ha dejado moonlight-qt. Se prueba debian."
      install_moonlight debian
    else
      exit 1
    fi
  fi
fi

log "arduino-cli y el core AVR, para Ardu Lab sin internet después"
if ! command -v arduino-cli >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/usr/local/bin sh
fi
if ! as_user arduino-cli core list | grep -q 'arduino:avr'; then
  as_user arduino-cli core update-index
  as_user arduino-cli core install arduino:avr
fi

log "Python de orbitd"
as_user python3 -m venv "$ROOT/.venv"
as_user "$ROOT/.venv/bin/pip" install -U pip
as_user "$ROOT/.venv/bin/pip" install -e "$ROOT/software/shared/python" -e "$ROOT/software/pi-controller"

log "Interfaz"
as_user npm --prefix "$ROOT/software/interface" ci
as_user npm --prefix "$ROOT/software/interface" run build

log "Token"
# Sin --force: una segunda pasada no cambia los tokens que Miguel ya copió al HP.
as_user bash "$ROOT/scripts/gen-token.sh"
chown "$ORBIT_USER:$ORBIT_USER" "$ROOT/.env"
chmod 600 "$ROOT/.env"

install -d -m 755 /etc/orbit /var/lib/orbit /usr/local/bin
chown "$ORBIT_USER:$ORBIT_USER" /var/lib/orbit
if [[ "$MODEL" == Raspberry\ Pi* ]]; then POWER_LIVE=1; else POWER_LIVE=0; fi
python3 - "$ROOT/.env" "$LABWC_RC" "$POWER_LIVE" <<'PY'
import sys
from pathlib import Path
env = {}
for line in Path(sys.argv[1]).read_text(encoding="utf-8").splitlines():
    if not line or line.startswith("#") or "=" not in line:
        continue
    key, value = line.split("=", 1)
    env[key] = value.strip().strip('"').strip("'")
text = "\n".join([
    f"ORBIT_HP_TOKEN={env.get('ORBIT_HP_TOKEN', '')}",
    f"ORBIT_UI_TOKEN={env.get('ORBIT_UI_TOKEN', '')}",
    "ORBIT_HOST=0.0.0.0",
    "ORBIT_PORT=8765",
    "ORBIT_MOONLIGHT_BIN=moonlight-qt",
    "ORBIT_HP_HOST=10.0.0.1",
    "ORBIT_MOONLIGHT_APP=Desktop",
    f"ORBIT_LABWC_RC={sys.argv[2]}",
    "ORBIT_FOCUS_CMD=/usr/local/bin/orbit-al-frente",
    "ORBIT_SERIAL=",
    "ORBIT_SERIAL_RESET_WAIT=2",
    "ORBIT_ARDU_PUERTOS=/var/lib/orbit/arduino-puertos.json",
    "ORBIT_ARDU_CLI=arduino-cli",
    "ORBIT_ARDU_FQBN=arduino:avr:nano:cpu=atmega328old",
    f"ORBIT_POWER_LIVE={sys.argv[3]}",
    f"ORBIT_POWER_ALLOW_EXEC={sys.argv[3]}",
    "",
])
Path("/etc/orbit/orbitd.env").write_text(text, encoding="utf-8")
PY
chmod 600 /etc/orbit/orbitd.env

PUERTOS=/var/lib/orbit/arduino-puertos.json
if [[ ! -d /dev/serial/by-path ]]; then
  log "No está /dev/serial/by-path. El Nano no está enchufado: no es un fallo. Cuando lo enchufes: sudo bash scripts/detectar-nanos.sh"
fi
if [[ ! -f "$PUERTOS" ]]; then
  python3 - "$PUERTOS" <<'PY'
import json, sys
from pathlib import Path
carpeta = Path("/dev/serial/by-path")
nombres = sorted(x.name for x in carpeta.iterdir() if x.is_symlink()) if carpeta.is_dir() else []
# Un solo enlace no se confunde con otro. Con dos placas no se adivina cuál es cuál.
mandos = nombres[0] if len(nombres) == 1 else ""
Path(sys.argv[1]).write_text(json.dumps({"mandos": mandos, "practicas": ""}, indent=2) + "\n", encoding="utf-8")
PY
  chown "$ORBIT_USER:$ORBIT_USER" "$PUERTOS"
  chmod 644 "$PUERTOS"
fi

# dialout es el grupo del serie (Nano CH340 y ESP). gpio solo existe en Raspberry Pi OS.
if ! getent group dialout >/dev/null; then
  groupadd --system dialout
fi
usermod -aG dialout "$ORBIT_USER"
EXTRA_GROUPS="dialout"
for g in video render input gpio; do
  if getent group "$g" >/dev/null; then
    usermod -aG "$g" "$ORBIT_USER"
    EXTRA_GROUPS="${EXTRA_GROUPS} ${g}"
  else
    log "El grupo ${g} no existe. No se crea: en la Pi, gpio lo trae el sistema."
  fi
done
cat > /etc/udev/rules.d/90-orbit-serial.rules <<'EOF'
# Nano (CH340, ttyUSB) y placas CDC (ttyACM, a veces el ESP) para el grupo dialout.
SUBSYSTEM=="tty", KERNEL=="ttyUSB[0-9]*", GROUP="dialout", MODE="0660"
SUBSYSTEM=="tty", KERNEL=="ttyACM[0-9]*", GROUP="dialout", MODE="0660"
EOF
chmod 644 /etc/udev/rules.d/90-orbit-serial.rules

log "Permiso mínimo para apagar y reiniciar"
# Solo estas dos órdenes, sin contraseña. No se añade un sudo general.
cat > /etc/sudoers.d/orbit-power <<EOF
# Orbit OS: el usuario de orbitd solo puede apagar o reiniciar, y solo con sudo -n.
${ORBIT_USER} ALL=(root) NOPASSWD: /usr/bin/systemctl poweroff, /usr/bin/systemctl reboot
EOF
chmod 440 /etc/sudoers.d/orbit-power
visudo -cf /etc/sudoers.d/orbit-power

log "Servicio orbitd"
cat > /etc/systemd/system/orbitd.service <<EOF
[Unit]
Description=Orbit OS (orbitd)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$ORBIT_USER
Group=$ORBIT_USER
SupplementaryGroups=$EXTRA_GROUPS
WorkingDirectory=$ROOT
EnvironmentFile=/etc/orbit/orbitd.env
Environment=XDG_RUNTIME_DIR=/run/user/$ORBIT_UID
Environment=WAYLAND_DISPLAY=wayland-0
Environment=DISPLAY=:0
ExecStart=$ROOT/.venv/bin/python -m orbitd --static $ROOT/software/interface/dist --host 0.0.0.0 --port 8765
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF
if systemd_up; then
  systemctl daemon-reload
  systemctl enable orbitd.service
else
  log "systemd no es pid 1. La unidad queda habilitada para cuando la Pi arranque."
  install -d /etc/systemd/system/multi-user.target.wants
  ln -sfn /etc/systemd/system/orbitd.service /etc/systemd/system/multi-user.target.wants/orbitd.service
fi

log "Kiosco"
cat > /usr/local/bin/orbit-kiosk <<'EOF'
#!/bin/bash
# Chromium a pantalla completa contra orbitd. Sin avisos de sesión y sin salvapantallas.
set -u
URL="${ORBIT_KIOSK_URL:-http://127.0.0.1:8765/}"
if [[ -f /var/lib/orbit/kiosk-pausa ]]; then
  exit 0
fi
for _ in $(seq 1 90); do
  curl -fsS -o /dev/null "$URL" && break
  sleep 1
done
if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
  xset s off -dpms s noblank || true
  command -v unclutter >/dev/null && unclutter -idle 1 -root &
fi
BIN=""
command -v chromium >/dev/null && BIN="$(command -v chromium)"
if [[ -z "$BIN" ]]; then BIN="$(command -v chromium-browser || true)"; fi
if [[ -z "$BIN" ]]; then
  echo "No está Chromium" >&2
  exit 1
fi
UD="${HOME}/.config/orbit-kiosk"
mkdir -p "$UD/Default"
python3 - <<'PY'
import json, os
from pathlib import Path
p = Path(os.environ["HOME"]) / ".config/orbit-kiosk/Default/Preferences"
data = {}
if p.exists():
    try:
        data = json.loads(p.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        data = {}
prof = data.setdefault("profile", {})
prof["exited_cleanly"] = True
prof["exit_type"] = "Normal"
data.setdefault("translate", {})["enabled"] = False
p.write_text(json.dumps(data), encoding="utf-8")
PY
# Una sola vez --disable-features. Translate ya va en la lista: no se repite el nombre.
FEATURES="Translate,TranslateUI"
exec "$BIN" \
  --user-data-dir="$UD" \
  --kiosk \
  --start-fullscreen \
  --noerrdialogs \
  --disable-infobars \
  --disable-session-crashed-bubble \
  --hide-crash-restore-bubble \
  --disable-features="$FEATURES" \
  --lang=es \
  --check-for-update-interval=31536000 \
  --overscroll-history-navigation=0 \
  --no-first-run \
  --disable-translate \
  --autoplay-policy=no-user-gesture-required \
  --password-store=basic \
  --disable-pinch \
  --ozone-platform-hint=auto \
  "$URL"
EOF

cat > /usr/local/bin/orbit-kiosk-bucle <<'EOF'
#!/bin/bash
while true; do
  if [[ -f /var/lib/orbit/kiosk-pausa ]]; then
    sleep 2
    continue
  fi
  /usr/local/bin/orbit-kiosk || true
  sleep 2
done
EOF

cat > /usr/local/bin/orbit-atajo <<'EOF'
#!/bin/bash
# Atajos del compositor. layout alterna integrada/completa. pausa deja el kiosco para mantenimiento.
set -u
case "${1:-}" in
  layout)
    curl -fsS -X POST "http://127.0.0.1:8765/api/local/layout" -H 'content-type: application/json' -d '{}' >/dev/null || true
    ;;
  pausa)
    touch /var/lib/orbit/kiosk-pausa
    pkill -f '/.config/orbit-kiosk' || true
    if command -v lxterminal >/dev/null; then lxterminal &
    elif command -v x-terminal-emulator >/dev/null; then x-terminal-emulator &
    fi
    ;;
  *)
    echo "Uso: orbit-atajo layout|pausa" >&2
    exit 1
    ;;
esac
EOF

cat > /usr/local/bin/orbit-al-frente <<'EOF'
#!/bin/bash
# Trae Chromium (Orbit OS) delante cuando se cierra Moonlight.
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
if [[ -S "$XDG_RUNTIME_DIR/wayland-0" ]]; then
  export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
  if command -v wlrctl >/dev/null; then
    wlrctl toplevel focus app_id:chromium && exit 0
    wlrctl toplevel focus app_id:chromium-browser && exit 0
  fi
fi
export DISPLAY="${DISPLAY:-:0}"
if command -v wmctrl >/dev/null; then
  wmctrl -a "Orbit Terminal" && exit 0
fi
exit 0
EOF
chmod 755 /usr/local/bin/orbit-kiosk /usr/local/bin/orbit-kiosk-bucle /usr/local/bin/orbit-atajo /usr/local/bin/orbit-al-frente

log "Chromium sin burbuja de traducir"
escribir_politica_chromium() {
  local dir="$1"
  install -d -m 755 "$dir"
  cat > "$dir/orbit.json" <<'EOF'
{
  "TranslateEnabled": false
}
EOF
  chmod 644 "$dir/orbit.json"
}
escribir_politica_chromium /etc/chromium/policies/managed
escribir_politica_chromium /etc/chromium-browser/policies/managed

log "Sesión gráfica"
install -d -m 755 -o "$ORBIT_USER" -g "$ORBIT_USER" "$ORBIT_HOME/.config/labwc"
as_user env ORBIT_LABWC_RC="$LABWC_RC" "$ROOT/.venv/bin/python" -c 'import os; from pathlib import Path; from orbitd.video import write_labwc_rc; write_labwc_rc(Path(os.environ["ORBIT_LABWC_RC"]), "integrado", False)'
cat > "$ORBIT_HOME/.config/labwc/autostart" <<'EOF'
#!/bin/sh
# Negro ya, para que el escritorio no se quede a la vista mientras orbitd arranca.
command -v swaybg >/dev/null 2>&1 && swaybg -c '#000000' >/dev/null 2>&1 &
/usr/local/bin/orbit-kiosk-bucle >/tmp/orbit-kiosk.log 2>&1 &
EOF
chown "$ORBIT_USER:$ORBIT_USER" "$ORBIT_HOME/.config/labwc/autostart" "$LABWC_RC" 2>/dev/null || true
chmod 755 "$ORBIT_HOME/.config/labwc/autostart"

if command -v wayfire >/dev/null; then
  install -d -m 755 -o "$ORBIT_USER" -g "$ORBIT_USER" "$ORBIT_HOME/.config"
  WF="$ORBIT_HOME/.config/wayfire.ini"
  if [[ ! -f "$WF" ]]; then
    cat > "$WF" <<'EOF'
[autostart]
orbit = /usr/local/bin/orbit-kiosk-bucle
[idle]
dpms_timeout = 0
screensaver_timeout = 0
EOF
    chown "$ORBIT_USER:$ORBIT_USER" "$WF"
  elif ! grep -q 'orbit-kiosk-bucle' "$WF"; then
    printf '\n[autostart]\norbit = /usr/local/bin/orbit-kiosk-bucle\n[idle]\ndpms_timeout = 0\nscreensaver_timeout = 0\n' >> "$WF"
  fi
fi

# LXDE-pi es el nombre de la sesión de Raspberry Pi OS, no el usuario de Imager.
X11_AUTO="$ORBIT_HOME/.config/lxsession/LXDE-pi/autostart"
if [[ ! -x "$(command -v labwc || true)" && ! -x "$(command -v wayfire || true)" ]] || [[ -d /etc/xdg/lxsession/LXDE-pi ]]; then
  install -d -m 755 -o "$ORBIT_USER" -g "$ORBIT_USER" "$(dirname "$X11_AUTO")"
  touch "$X11_AUTO"
  grep -q 'orbit-kiosk-bucle' "$X11_AUTO" || printf '\n@xset s off\n@xset -dpms\n@xset s noblank\n@unclutter -idle 1\n@/usr/local/bin/orbit-kiosk-bucle\n' >> "$X11_AUTO"
  chown -R "$ORBIT_USER:$ORBIT_USER" "$ORBIT_HOME/.config/lxsession"
fi

install -d -m 755 /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/orbit-autologin.conf <<EOF
[Seat:*]
autologin-user=$ORBIT_USER
autologin-user-timeout=0
EOF
chmod 644 /etc/lightdm/lightdm.conf.d/orbit-autologin.conf
if [[ -f /etc/lightdm/lightdm.conf ]] && grep -q '^#\?autologin-user=' /etc/lightdm/lightdm.conf; then
  sed -i -e "s/^#\\?autologin-user=.*/autologin-user=${ORBIT_USER}/" /etc/lightdm/lightdm.conf
fi

if command -v raspi-config >/dev/null && [[ -e /etc/init.d/lightdm ]]; then
  log "Autologin al escritorio y sin apagado de pantalla"
  SUDO_USER="$ORBIT_USER" raspi-config nonint do_boot_behaviour B4
  SUDO_USER="$ORBIT_USER" raspi-config nonint do_blanking 1
elif command -v raspi-config >/dev/null; then
  log "raspi-config está, pero no hay lightdm. El autologin queda en lightdm.conf.d para el escritorio de la imagen."
fi
if systemd_up; then
  systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
else
  for t in sleep.target suspend.target hibernate.target hybrid-sleep.target; do
    ln -sfn /dev/null "/etc/systemd/system/${t}"
  done
fi

log "Arranque en silencio"
BOOT=""
if [[ -d /boot/firmware ]]; then BOOT=/boot/firmware
elif [[ -d /boot ]]; then BOOT=/boot
fi
if [[ -n "$BOOT" && -f "$BOOT/config.txt" ]]; then
  if grep -q '^disable_splash=' "$BOOT/config.txt"; then
    sed -i 's/^disable_splash=.*/disable_splash=1/' "$BOOT/config.txt"
  else
    printf '\ndisable_splash=1\n' >> "$BOOT/config.txt"
  fi
fi
if [[ -n "$BOOT" && -f "$BOOT/cmdline.txt" ]]; then
  if [[ ! -f "$BOOT/cmdline.txt.orbit-bak" ]]; then
    cp -a "$BOOT/cmdline.txt" "$BOOT/cmdline.txt.orbit-bak"
  fi
  line="$(tr -d '\n' < "$BOOT/cmdline.txt")"
  line="${line// splash/}"
  line="${line//console=tty1/console=tty3}"
  for word in quiet loglevel=3 logo.nologo vt.global_cursor_default=0 consoleblank=0; do
    if [[ " $line " != *" $word "* ]]; then
      line="$line $word"
    fi
  done
  printf '%s\n' "$line" > "$BOOT/cmdline.txt"
fi

log "IP fija en eth0, sin puerta de enlace y sin tocar el Wi-Fi"
install -d -m 755 /etc/NetworkManager/system-connections
cat > /etc/NetworkManager/system-connections/orbit-enlace-hp.nmconnection <<'EOF'
[connection]
id=orbit-enlace-hp
type=ethernet
interface-name=eth0
autoconnect=true

[ethernet]

[ipv4]
method=manual
address1=10.0.0.2/24
never-default=true
ignore-auto-dns=true

[ipv6]
method=disabled
EOF
chmod 600 /etc/NetworkManager/system-connections/orbit-enlace-hp.nmconnection
# shellcheck disable=SC1091
source "$(dirname "$0")/orbit-nm.sh"
if command -v nmcli >/dev/null && systemd_up && systemctl is-active --quiet NetworkManager; then
  nmcli connection reload || true
  desactivar_autoconnect_eth0 "orbit-enlace-hp"
  if ip link show eth0 >/dev/null 2>&1; then
    nmcli connection up orbit-enlace-hp || log "eth0 no ha levantado el perfil. El cable puede no estar; el perfil queda guardado."
  else
    log "No hay eth0 ahora. El perfil queda guardado y no pone puerta de enlace."
  fi
else
  log "NetworkManager no está en marcha. eth0 quedará en 10.0.0.2/24 al arrancar, sin puerta ni DNS."
fi

log "Listo. Reinicia la Pi para ver Orbit OS al encender."
echo "Usuario de la sesión: $ORBIT_USER"
echo "Mantenimiento: SSH, o Ctrl+Alt+T (pausa el kiosco). Para volver: rm /var/lib/orbit/kiosk-pausa"
echo "Moonlight aún no está emparejado. Pasos en docs/instalacion-pi.md"
echo "Ardu Lab no sube nada hasta anotar el basename de /dev/serial/by-path."
echo "Cuando los Nano estén enchufados: sudo bash scripts/detectar-nanos.sh"
echo "Eso escribe /var/lib/orbit/arduino-puertos.json. El de mandos no se programa. docs/ardu-lab.md"
if [[ -d /dev/serial/by-path ]]; then
  echo "Puertos vistos ahora:"
  ls -l /dev/serial/by-path || true
else
  echo "Ahora no está /dev/serial/by-path. Es normal: el Nano no estaba enchufado. El instalador sigue."
fi
