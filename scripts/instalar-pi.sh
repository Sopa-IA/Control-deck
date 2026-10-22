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
MODEL="$(tr -d '\0' < /proc/device-tree/model 2>/dev/null || true)"
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

export DEBIAN_FRONTEND=noninteractive
log "Paquetes"
apt-get update
apt-get install -y \
  python3 python3-venv python3-pip \
  nodejs npm \
  curl ca-certificates lsb-release \
  network-manager \
  unclutter x11-xserver-utils \
  xdg-utils \
  || true
apt-get install -y chromium || apt-get install -y chromium-browser
apt-get install -y wlrctl || true
apt-get install -y wmctrl || true
if ! command -v lxterminal >/dev/null && ! command -v x-terminal-emulator >/dev/null; then
  apt-get install -y lxterminal || true
fi

if ! dpkg -s moonlight-qt >/dev/null 2>&1; then
  log "Moonlight Qt, repositorio oficial de moonlight-stream"
  # https://github.com/moonlight-stream/moonlight-docs/wiki/Installing-Moonlight-Qt-on-Raspberry-Pi-4
  curl -1sLf 'https://dl.cloudsmith.io/public/moonlight-game-streaming/moonlight-qt/setup.deb.sh' \
    | distro=raspbian codename="$(lsb_release -cs)" bash
  apt-get update
  apt-get install -y moonlight-qt
fi

log "arduino-cli y el core AVR, para Ardu Lab sin internet después"
if ! command -v arduino-cli >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/usr/local/bin sh
fi
if ! sudo -u "$ORBIT_USER" -H arduino-cli core list | grep -q 'arduino:avr'; then
  sudo -u "$ORBIT_USER" -H arduino-cli core update-index
  sudo -u "$ORBIT_USER" -H arduino-cli core install arduino:avr
fi

log "Python de orbitd"
sudo -u "$ORBIT_USER" python3 -m venv "$ROOT/.venv"
sudo -u "$ORBIT_USER" "$ROOT/.venv/bin/pip" install -U pip
sudo -u "$ORBIT_USER" "$ROOT/.venv/bin/pip" install -e "$ROOT/software/shared/python" -e "$ROOT/software/pi-controller"

log "Interfaz"
sudo -u "$ORBIT_USER" bash -c "cd '$ROOT/software/interface' && npm ci && npm run build"

log "Token"
sudo -u "$ORBIT_USER" bash "$ROOT/scripts/gen-token.sh"
chown "$ORBIT_USER:$ORBIT_USER" "$ROOT/.env"
chmod 600 "$ROOT/.env"

install -d -m 755 /etc/orbit /var/lib/orbit /usr/local/bin
chown "$ORBIT_USER:$ORBIT_USER" /var/lib/orbit
python3 - "$ROOT/.env" "$LABWC_RC" <<'PY'
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
    "",
])
Path("/etc/orbit/orbitd.env").write_text(text, encoding="utf-8")
PY
chmod 600 /etc/orbit/orbitd.env

PUERTOS=/var/lib/orbit/arduino-puertos.json
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

GROUPS=""
for g in dialout video render input gpio; do
  getent group "$g" >/dev/null && GROUPS="${GROUPS}${GROUPS:+ }${g}"
done

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
${GROUPS:+SupplementaryGroups=$GROUPS}
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
systemctl daemon-reload
systemctl enable orbitd.service

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
p.write_text(json.dumps(data), encoding="utf-8")
PY
exec "$BIN" \
  --user-data-dir="$UD" \
  --kiosk \
  --start-fullscreen \
  --noerrdialogs \
  --disable-infobars \
  --disable-session-crashed-bubble \
  --hide-crash-restore-bubble \
  --disable-features=Translate,TranslateUI \
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

log "Sesión gráfica"
install -d -m 755 -o "$ORBIT_USER" -g "$ORBIT_USER" "$ORBIT_HOME/.config/labwc"
sudo -u "$ORBIT_USER" env ORBIT_LABWC_RC="$LABWC_RC" "$ROOT/.venv/bin/python" -c 'import os; from pathlib import Path; from orbitd.video import write_labwc_rc; write_labwc_rc(Path(os.environ["ORBIT_LABWC_RC"]), "integrado", False)'
cat > "$ORBIT_HOME/.config/labwc/autostart" <<'EOF'
#!/bin/sh
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

X11_AUTO="$ORBIT_HOME/.config/lxsession/LXDE-pi/autostart"
if [[ ! -x "$(command -v labwc || true)" && ! -x "$(command -v wayfire || true)" ]] || [[ -d /etc/xdg/lxsession/LXDE-pi ]]; then
  install -d -m 755 -o "$ORBIT_USER" -g "$ORBIT_USER" "$(dirname "$X11_AUTO")"
  touch "$X11_AUTO"
  grep -q 'orbit-kiosk-bucle' "$X11_AUTO" || printf '\n@xset s off\n@xset -dpms\n@xset s noblank\n@unclutter -idle 1\n@/usr/local/bin/orbit-kiosk-bucle\n' >> "$X11_AUTO"
  chown -R "$ORBIT_USER:$ORBIT_USER" "$ORBIT_HOME/.config/lxsession"
fi

if command -v raspi-config >/dev/null; then
  log "Autologin al escritorio y sin apagado de pantalla"
  raspi-config nonint do_boot_behaviour B4 || true
  raspi-config nonint do_blanking 1 || true
fi
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target >/dev/null 2>&1 || true

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

log "IP fija en eth0"
if command -v nmcli >/dev/null; then
  CON="orbit-enlace-hp"
  if nmcli -t -f NAME con show | grep -qx "$CON"; then
    nmcli con mod "$CON" connection.interface-name eth0 connection.autoconnect yes \
      ipv4.method manual ipv4.addresses "10.0.0.2/24" ipv6.method disabled \
      ipv4.never-default yes ipv4.ignore-auto-dns yes || true
  else
    nmcli con add type ethernet ifname eth0 con-name "$CON" \
      ipv4.method manual ipv4.addresses "10.0.0.2/24" ipv6.method disabled \
      ipv4.never-default yes ipv4.ignore-auto-dns yes connection.autoconnect yes
  fi
  nmcli con mod "$CON" ipv4.gateway "" ipv4.dns "" || true
  while IFS=: read -r name iface; do
    [[ "$name" == "$CON" ]] && continue
    [[ "$iface" == "eth0" ]] || continue
    nmcli con mod "$name" connection.autoconnect no || true
  done < <(nmcli -t -f NAME,connection.interface-name con show)
  nmcli con up "$CON" || true
fi

log "Listo. Reinicia la Pi para ver Orbit OS al encender."
echo "Usuario de la sesión: $ORBIT_USER"
echo "Mantenimiento: SSH, o Ctrl+Alt+T (pausa el kiosco). Para volver: rm /var/lib/orbit/kiosk-pausa"
echo "Moonlight aún no está emparejado. Pasos en docs/instalacion-pi.md"
echo "Ardu Lab: anota el basename de /dev/serial/by-path en /var/lib/orbit/arduino-puertos.json"
echo "Sin eso no se abre el Nano de mandos y no se sube al de prácticas. docs/ardu-lab.md"
if [[ -d /dev/serial/by-path ]]; then
  ls -l /dev/serial/by-path || true
fi
