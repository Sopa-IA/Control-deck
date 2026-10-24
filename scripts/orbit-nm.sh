# eth0 de Orbit y avisos de red. No edita, no borra y no recarga otros perfiles.
# En Raspberry Pi OS con cloud-init, el Wi-Fi de Imager está en /etc/netplan.
# Recargar o modificar NetworkManager regenera Netplan y vacía esos YAML.
# Los ficheros a mano en system-connections se quedan. netplan apply no los devuelve.

nombres_en() {
  local dir="$1" f base
  [[ -d "$dir" ]] || return 0
  for f in "$dir"/*; do
    [[ -e "$f" ]] || continue
    base="${f##*/}"
    printf '%s\n' "$base"
  done | sort
}

filtrar_perfil_propio() {
  local texto="${1-}"
  [[ -n "$texto" ]] || return 0
  printf '%s\n' "$texto" | grep -vx 'orbit-enlace-hp.nmconnection' || true
}

avisar_si_cambio_la_red() {
  local antes_nm="$1" antes_np="$2" ahora_nm ahora_np a b
  local dir_nm="${3:-/etc/NetworkManager/system-connections}"
  local dir_np="${4:-/etc/netplan}"
  ahora_nm="$(nombres_en "$dir_nm")"
  ahora_np="$(nombres_en "$dir_np")"
  a="$(filtrar_perfil_propio "$antes_nm")"
  b="$(filtrar_perfil_propio "$ahora_nm")"
  if [[ "$a" != "$b" ]]; then
    echo "AVISO: ha cambiado system-connections, aparte de orbit-enlace-hp. No se ha querido tocar el Wi-Fi."
  fi
  if [[ "$antes_np" != "$ahora_np" ]]; then
    echo "AVISO: ha cambiado /etc/netplan. El instalador no escribe ahí. No apliques netplan: puede vaciar esos YAML."
  fi
  return 0
}

avisar_red() {
  local st ruta
  st=""
  if command -v nmcli >/dev/null 2>&1; then
    st="$(nmcli -t -f DEVICE,STATE device status 2>/dev/null | awk -F: '$1=="wlan0" { print $2; exit }' || true)"
  fi
  case "$st" in
    connected|conectado) ;;
    *)
      echo "AVISO: wlan0 no está conectado. Este instalador no borra ni modifica perfiles Wi-Fi."
      echo "No apliques netplan: en esta Raspberry Pi OS puede vaciar /etc/netplan y no devuelve el Wi-Fi."
      ;;
  esac
  ruta=""
  if command -v ip >/dev/null 2>&1; then
    ruta="$(ip -4 route show default 2>/dev/null || true)"
  fi
  if [[ "$ruta" == *" dev eth0"* ]]; then
    echo "AVISO: la ruta por defecto sale por eth0. El perfil orbit-enlace-hp no lleva puerta ni DNS."
  fi
  return 0
}
