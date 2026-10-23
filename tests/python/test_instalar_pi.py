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


def test_sesion_orbit_sin_mezclar_el_escritorio(tmp_path: Path):
    inst = INSTALADOR.read_text(encoding="utf-8")
    etc = inst.split("cat > /etc/orbit/labwc/autostart <<'EOF'", 1)[1].split("\nEOF", 1)[0]
    home = inst.split('cat > "$ORBIT_HOME/.config/labwc/autostart" <<\'EOF\'', 1)[1].split("\nEOF", 1)[0]
    assert "swaybg" in etc and "orbit-kiosk-bucle" in etc
    assert "wf-panel-pi" not in etc and "pcmanfm" not in etc
    assert "lxsession-xdg-autostart" not in etc
    assert "orbit-kiosk-bucle" not in home
    assert 'LABWC_RC="/etc/orbit/labwc/rc.xml"' in inst
    assert "/usr/share/wayland-sessions/orbit.desktop" in inst
    assert "Exec=/usr/local/bin/orbit-sesion" in inst
    sesion = (ROOT / "scripts/orbit-sesion.sh").read_text(encoding="utf-8")
    assert 'exec "$LABWC" -C /etc/orbit/labwc' in sesion
    assert "-m" not in sesion.split("exec", 1)[1]
    assert "orbit-atajo pausa" in (ROOT / "software/pi-controller/orbitd/video.py").read_text(encoding="utf-8")

    sesiones = tmp_path / "wayland-sessions"
    sesiones.mkdir()
    (sesiones / "rpd-labwc.desktop").write_text("[Desktop Entry]\nName=rpd\n", encoding="utf-8")
    conf = tmp_path / "lightdm.conf"
    conf.write_text(
        "[Seat:*]\n#autologin-user=\nautologin-user-timeout=0\n"
        "#user-session=rpd-labwc\n#autologin-session=rpd-labwc\n",
        encoding="utf-8",
    )
    dropin = tmp_path / "lightdm.conf.d" / "zz-orbit.conf"
    cuenta = tmp_path / "cuenta"
    cuenta.write_text("[User]\nXSession=rpd-labwc\n", encoding="utf-8")
    dmrc = tmp_path / "dmrc"
    dmrc.write_text("[Desktop]\nSession=rpd-labwc\n", encoding="utf-8")
    env = {
        **os.environ,
        "ORBIT_LIGHTDM_CONF": str(conf),
        "ORBIT_LIGHTDM_DROPIN": str(dropin),
        "ORBIT_WAYLAND_SESSIONS": str(sesiones),
        "ORBIT_ACCOUNT_FILE": str(cuenta),
        "ORBIT_DMRC": str(dmrc),
    }

    def lanzar(*args: str) -> str:
        proc = subprocess.run(
            ["bash", str(ROOT / "scripts/orbit-lightdm.sh"), *args],
            env=env, capture_output=True, text=True, check=False,
        )
        assert proc.returncode == 0, proc.stderr
        assert proc.stderr.strip() == ""
        return proc.stdout.strip()

    assert lanzar("orbit", "orbit") == "orbit"
    primera = dropin.read_text(encoding="utf-8")
    assert lanzar("orbit", "orbit") == "orbit"
    assert dropin.read_text(encoding="utf-8") == primera
    assert "user-session=orbit" in primera
    assert "autologin-session=orbit" in primera
    assert "autologin-user=orbit" in primera
    assert conf.read_text(encoding="utf-8").count("user-session=orbit") == 1
    assert "XSession=orbit" in cuenta.read_text(encoding="utf-8")
    assert "Session=orbit" in dmrc.read_text(encoding="utf-8")

    assert lanzar("escritorio", "orbit") == "rpd-labwc"
    escrito = dropin.read_text(encoding="utf-8")
    assert "user-session=rpd-labwc" in escrito
    assert "user-session=orbit" not in escrito
    assert "autologin-user=" in conf.read_text(encoding="utf-8")
    assert "XSession=rpd-labwc" in cuenta.read_text(encoding="utf-8")

    (sesiones / "rpd-labwc.desktop").unlink()
    (sesiones / "LXDE-pi-labwc.desktop").write_text("[Desktop Entry]\n", encoding="utf-8")
    assert lanzar("escritorio", "orbit") == "LXDE-pi-labwc"
    escritorio = (ROOT / "scripts/orbit-escritorio.sh").read_text(encoding="utf-8")
    assert "orbit-lightdm.sh" in escritorio
    assert "sudo reboot" in escritorio


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
