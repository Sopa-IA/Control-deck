# Perfiles de NetworkManager que no deben pelearse con orbit-enlace-hp.
# El listado `nmcli connection show` no acepta connection.interface-name
# (ese campo solo vale al mostrar un perfil). Preguntarlo ahí imprime
# "invalid field" y el bucle no llega a leer nada.

desactivar_autoconnect_eth0() {
  local propio="$1" name iface
  [[ -n "$propio" ]] || return 0
  command -v nmcli >/dev/null 2>&1 || return 0
  while IFS= read -r name || [[ -n "${name:-}" ]]; do
    name="${name//\\:/:}"
    [[ -z "$name" || "$name" == "$propio" ]] && continue
    iface="$(nmcli -g connection.interface-name connection show "$name" 2>/dev/null || true)"
    [[ "$iface" == "eth0" ]] || continue
    nmcli connection modify "$name" connection.autoconnect no || true
  done < <(nmcli -t -f NAME connection show 2>/dev/null || true)
}
