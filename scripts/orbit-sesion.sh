#!/bin/sh
# Sesión Wayland de Orbit. LightDM la lanza con el usuario de autologin.
# labwc sin --merge-config y con un directorio propio: no lee
# /etc/xdg/labwc/autostart, que es donde la Pi arranca pcmanfm y wf-panel-pi.
if [ -f /usr/bin/setup_env ]; then
  # shellcheck disable=SC1091
  . /usr/bin/setup_env
fi
if [ -x /usr/bin/raspi-config ]; then
  if raspi-config nonint is_pi >/dev/null 2>&1 && ! raspi-config nonint gpu_has_mmu >/dev/null 2>&1; then
    export WLR_RENDERER=pixman
  fi
fi
LABWC="$(command -v labwc || true)"
if [ -z "$LABWC" ]; then
  echo "No está labwc" >&2
  exit 1
fi
# Sin -m. -C sustituye ~/.config/labwc y /etc/xdg/labwc.
exec "$LABWC" -C /etc/orbit/labwc
