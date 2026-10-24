#!/usr/bin/env bash
# Anota el Nano de mandos y el de prácticas en arduino-puertos.json.
# La identidad es el basename de /dev/serial/by-path, no ttyUSB.
# Se lanza cuando las placas ya están enchufadas. No adivina cuál es cuál.
set -euo pipefail

PUERTOS="${ORBIT_ARDU_PUERTOS:-/var/lib/orbit/arduino-puertos.json}"
CARPETA="${ORBIT_SERIAL_BY_PATH:-/dev/serial/by-path}"

if [[ ! -d "$CARPETA" ]]; then
  echo "No está ${CARPETA}." >&2
  echo "Es normal si el Nano no está enchufado. Enchúfalo por USB, espera un segundo y vuelve a ejecutar:" >&2
  echo "  sudo bash scripts/detectar-nanos.sh" >&2
  exit 1
fi

mapfile -t NOMBRES < <(find "$CARPETA" -maxdepth 1 -type l -printf '%f\n' | LC_ALL=C sort)
if [[ "${#NOMBRES[@]}" -eq 0 ]]; then
  echo "La carpeta existe, pero no hay ningún enlace." >&2
  echo "Enchufa el Nano, espera un segundo y vuelve a lanzar este script." >&2
  exit 1
fi

echo "Puertos USB vistos. El nombre es el basename de by-path, no ttyUSB:"
i=1
for nombre in "${NOMBRES[@]}"; do
  printf '  %d) %s\n' "$i" "$nombre"
  i=$((i + 1))
done

if [[ ! -t 0 ]]; then
  echo "No hay una terminal interactiva. Entra por SSH y lánzalo sin redirigir la entrada." >&2
  exit 1
fi

DEF_MANDOS=""
DEF_PRACTICAS=""
if [[ -f "$PUERTOS" ]]; then
  eval "$(python3 - "$PUERTOS" <<'PY'
import json, shlex, sys
try:
    data = json.loads(open(sys.argv[1], encoding="utf-8").read())
except (OSError, json.JSONDecodeError):
    data = {}
if not isinstance(data, dict):
    data = {}
print(f"DEF_MANDOS={shlex.quote(str(data.get('mandos') or ''))}")
print(f"DEF_PRACTICAS={shlex.quote(str(data.get('practicas') or ''))}")
PY
)"
fi

elegir() {
  local rol="$1" defecto="$2" resp n
  local pista="${defecto:-vacío}"
  read -r -p "${rol} [${pista}]: " resp || true
  resp="${resp#"${resp%%[![:space:]]*}"}"
  resp="${resp%"${resp##*[![:space:]]}"}"
  if [[ -z "$resp" ]]; then
    printf '%s' "$defecto"
    return 0
  fi
  if [[ "$resp" =~ ^[0-9]+$ ]]; then
    if (( resp < 1 || resp > ${#NOMBRES[@]} )); then
      echo "Número fuera de la lista." >&2
      exit 1
    fi
    printf '%s' "${NOMBRES[$((resp - 1))]}"
    return 0
  fi
  for n in "${NOMBRES[@]}"; do
    if [[ "$n" == "$resp" ]]; then
      printf '%s' "$n"
      return 0
    fi
  done
  echo "Ese nombre no está en la lista. No se anota ttyUSB: hace falta el basename de by-path." >&2
  exit 1
}

mandos="$(elegir "Número o nombre del Nano de mandos" "$DEF_MANDOS")"
practicas="$(elegir "Número o nombre del Nano de prácticas" "$DEF_PRACTICAS")"

if [[ -n "$mandos" && "$mandos" == "$practicas" ]]; then
  echo "Los dos no pueden ser el mismo puerto. No se ha escrito nada." >&2
  exit 1
fi

dir="$(dirname "$PUERTOS")"
if [[ ! -d "$dir" ]]; then
  if [[ "$(id -u)" -ne 0 ]]; then
    echo "No existe ${dir}. Lánzalo con sudo." >&2
    exit 1
  fi
  install -d -m 755 "$dir"
fi
if [[ -e "$PUERTOS" && ! -w "$PUERTOS" && "$(id -u)" -ne 0 ]]; then
  echo "No puedo escribir ${PUERTOS}. Lánzalo con sudo." >&2
  exit 1
fi
if [[ ! -e "$PUERTOS" && ! -w "$dir" && "$(id -u)" -ne 0 ]]; then
  echo "No puedo crear ${PUERTOS}. Lánzalo con sudo." >&2
  exit 1
fi

python3 - "$PUERTOS" "$mandos" "$practicas" <<'PY'
import json, sys
path, mandos, practicas = sys.argv[1:]
with open(path, "w", encoding="utf-8") as fh:
    json.dump({"mandos": mandos, "practicas": practicas}, fh, indent=2, ensure_ascii=False)
    fh.write("\n")
PY
chmod 644 "$PUERTOS" || true
if [[ "$(id -u)" -eq 0 ]]; then
  owner="$(stat -c '%U' "$PUERTOS" 2>/dev/null || true)"
  if [[ -z "$owner" || "$owner" == root ]]; then
    owner="${SUDO_USER:-}"
  fi
  if [[ -n "$owner" && "$owner" != root ]]; then
    chown "$owner:$owner" "$PUERTOS" || true
  fi
fi

echo "Escrito ${PUERTOS}."
echo "  mandos:    ${mandos:-<vacío>}"
echo "  practicas: ${practicas:-<vacío>}"
if [[ -z "$practicas" ]]; then
  echo "Sin el de prácticas, Ardu Lab no sube a ninguna placa."
fi
echo "Reinicia orbitd cuando los dos estén enchufados en su puerto: sudo systemctl restart orbitd"
