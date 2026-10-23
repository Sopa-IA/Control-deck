"""Regresiones del instalador de la Pi, sin lanzarlo (pide root y una Pi)."""
from __future__ import annotations

import json
import os
import pty
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
INSTALADOR = ROOT / "scripts" / "instalar-pi.sh"


def _kiosk() -> str:
    text = INSTALADOR.read_text(encoding="utf-8")
    trozo = text.split("cat > /usr/local/bin/orbit-kiosk <<'EOF'", 1)[1]
    return trozo.split("\nEOF", 1)[0]


def test_nmcli_no_lista_interface_name_y_es_repetible(tmp_path: Path):
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    calls = tmp_path / "calls"
    fake = bin_dir / "nmcli"
    fake.write_text(
        f"""#!/bin/bash
set -euo pipefail
printf '%s\\n' "$*" >> {calls}
if [[ "$1" == "-t" ]]; then
  if [[ "$*" == *connection.interface-name* ]]; then
    echo "Error: invalid field 'connection.interface-name'; allowed fields: NAME,UUID,DEVICE" >&2
    exit 2
  fi
  printf '%s\\n' 'orbit-enlace-hp' 'Cable\\: salon' 'eth0-fija' 'wifi-casa'
  exit 0
fi
if [[ "$1" == "-g" ]]; then
  name="${{@: -1}}"
  case "$name" in
    orbit-enlace-hp|eth0-fija|Cable:\\ salon) printf '%s\\n' eth0 ;;
    *) printf '\\n' ;;
  esac
  exit 0
fi
if [[ "$1" == connection && "$2" == modify ]]; then
  printf 'MOD %s\\n' "$3" >> {calls}
  exit 0
fi
if [[ "$1" == connection && "$2" == reload ]]; then
  exit 0
fi
echo "nmcli inesperado: $*" >&2
exit 3
""",
        encoding="utf-8",
    )
    fake.chmod(0o755)
    env = os.environ.copy()
    env["PATH"] = f"{bin_dir}{os.pathsep}{env.get('PATH', '')}"
    proc = subprocess.run(
        [
            "bash", "-c",
            "source scripts/orbit-nm.sh\n"
            "desactivar_autoconnect_eth0 orbit-enlace-hp\n"
            "desactivar_autoconnect_eth0 orbit-enlace-hp\n",
        ],
        cwd=ROOT, env=env, capture_output=True, text=True, check=False,
    )
    assert proc.returncode == 0, proc.stderr
    assert "invalid field" not in proc.stderr
    assert proc.stderr.strip() == ""
    texto = calls.read_text(encoding="utf-8")
    listados = [ln for ln in texto.splitlines() if ln.startswith("-t ")]
    assert listados and all("interface-name" not in ln for ln in listados)
    assert any(ln.startswith("-g connection.interface-name connection show ") for ln in texto.splitlines())
    mods = [line for line in texto.splitlines() if line.startswith("MOD ")]
    assert mods.count("MOD eth0-fija") == 2
    assert mods.count("MOD Cable: salon") == 2
    assert not any("orbit-enlace-hp" in line for line in mods)
    assert not any("wifi-casa" in line for line in mods)
    assert "NAME,connection.interface-name" not in INSTALADOR.read_text(encoding="utf-8")


def test_kiosk_traduccion_un_solo_flag_y_lang_es():
    kiosk = _kiosk()
    assert kiosk.count("--disable-features=") == 1
    assert "Translate,TranslateUI" in kiosk
    assert "Translate,Translate," not in kiosk
    assert "--lang=es" in kiosk
    html = (ROOT / "software/interface/index.html").read_text(encoding="utf-8")
    assert 'lang="es"' in html
    inst = INSTALADOR.read_text(encoding="utf-8")
    assert '"TranslateEnabled": false' in inst
    assert "/etc/chromium/policies/managed" in inst


def test_detectar_nanos_sin_carpeta(tmp_path: Path):
    dest = tmp_path / "arduino-puertos.json"
    proc = subprocess.run(
        ["bash", str(ROOT / "scripts/detectar-nanos.sh")],
        cwd=ROOT,
        env={
            **os.environ,
            "ORBIT_SERIAL_BY_PATH": str(tmp_path / "no-esta"),
            "ORBIT_ARDU_PUERTOS": str(dest),
        },
        capture_output=True, text=True, check=False,
    )
    assert proc.returncode == 1
    assert "enchuf" in proc.stderr.lower()
    assert not dest.exists()


def test_detectar_nanos_escribe_los_dos(tmp_path: Path):
    carpeta = tmp_path / "by-path"
    carpeta.mkdir()
    (carpeta / "usb-mandos").symlink_to("/dev/null")
    (carpeta / "usb-practicas").symlink_to("/dev/null")
    dest = tmp_path / "orbit" / "arduino-puertos.json"
    dest.parent.mkdir()
    master, slave = pty.openpty()
    proc = subprocess.Popen(
        ["bash", str(ROOT / "scripts/detectar-nanos.sh")],
        cwd=ROOT,
        stdin=slave,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env={
            **os.environ,
            "ORBIT_SERIAL_BY_PATH": str(carpeta),
            "ORBIT_ARDU_PUERTOS": str(dest),
        },
    )
    os.close(slave)
    os.write(master, b"1\n2\n")
    try:
        _out, err = proc.communicate(timeout=5)
    finally:
        os.close(master)
    assert proc.returncode == 0, err.decode()
    data = json.loads(dest.read_text(encoding="utf-8"))
    # LC_ALL=C: usb-mandos queda el 1 y usb-practicas el 2.
    assert data == {"mandos": "usb-mandos", "practicas": "usb-practicas"}
