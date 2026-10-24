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


def _codigo_sin_comentarios(texto: str) -> str:
    lineas = []
    for linea in texto.splitlines():
        lineas.append(linea.split("#", 1)[0])
    return "\n".join(lineas)


def test_el_instalador_no_toca_perfiles_wifi():
    inst = _codigo_sin_comentarios(INSTALADOR.read_text(encoding="utf-8"))
    nm = _codigo_sin_comentarios((ROOT / "scripts/orbit-nm.sh").read_text(encoding="utf-8"))
    for src in (inst, nm):
        for prohibido in (
            "connection reload",
            "con reload",
            "connection modify",
            "con mod ",
            "connection delete",
            "connection load",
            "connection up",
            "netplan apply",
            "netplan generate",
            "cloud-init",
            "rfkill unblock wifi",
            "rfkill block",
        ):
            assert prohibido not in src
    bloque = inst.split("apt-get install -y \\", 1)[1].split("if ! dpkg -s network-manager", 1)[0]
    assert "network-manager" not in bloque
    assert "dpkg -s network-manager" in inst
    perfil = inst.split("orbit-enlace-hp.nmconnection <<'EOF'", 1)[1].split("\nEOF", 1)[0]
    assert "address1=10.0.0.2/24" in perfil
    assert perfil.count("never-default=true") == 2
    assert "ignore-auto-dns=true" in perfil
    assert not any(linea.startswith(("gateway", "dns=")) for linea in perfil.splitlines())
    assert "method=manual" in perfil
    assert "method=disabled" in perfil
    assert "autoconnect-priority=100" in perfil
    assert "desactivar_autoconnect_eth0" not in inst
    assert "avisar_red" in inst
    assert "avisar_si_cambio_la_red" in inst


def test_avisa_si_wlan0_no_esta_conectado_y_no_edita_perfiles(tmp_path: Path):
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    calls = tmp_path / "calls"
    (bin_dir / "nmcli").write_text(
        f"""#!/bin/bash
printf '%s\\n' "$*" >> {calls}
printf '%s\\n' 'eth0:connected' 'wlan0:disconnected' 'lo:unmanaged'
""",
        encoding="utf-8",
    )
    (bin_dir / "nmcli").chmod(0o755)
    (bin_dir / "ip").write_text(
        f"""#!/bin/bash
printf '%s\\n' "$*" >> {calls}
if [[ "$1" == "-4" && "$3" == "default" ]]; then
  printf '%s\\n' 'default via 192.0.2.1 dev wlan0'
fi
""",
        encoding="utf-8",
    )
    (bin_dir / "ip").chmod(0o755)
    env = os.environ.copy()
    env["PATH"] = f"{bin_dir}{os.pathsep}{env.get('PATH', '')}"
    proc = subprocess.run(
        ["bash", "-c", "source scripts/orbit-nm.sh\navisar_red\n"],
        cwd=ROOT, env=env, capture_output=True, text=True, check=False,
    )
    assert proc.returncode == 0, proc.stderr
    assert "wlan0 no está conectado" in proc.stdout
    assert "dev eth0" not in proc.stdout
    texto = calls.read_text(encoding="utf-8")
    assert "device status" in texto
    for prohibido in ("modify", "reload", "delete", "load", " up"):
        assert prohibido not in texto

    (bin_dir / "nmcli").write_text(
        f"""#!/bin/bash
printf '%s\\n' "$*" >> {calls}
printf '%s\\n' 'wlan0:connected'
""",
        encoding="utf-8",
    )
    (bin_dir / "ip").write_text(
        """#!/bin/bash
if [[ "$1" == "-4" ]]; then
  printf '%s\\n' 'default via 192.0.2.1 dev eth0 proto static'
fi
""",
        encoding="utf-8",
    )
    calls.write_text("", encoding="utf-8")
    proc = subprocess.run(
        ["bash", "-c", "source scripts/orbit-nm.sh\navisar_red\n"],
        cwd=ROOT, env=env, capture_output=True, text=True, check=False,
    )
    assert proc.returncode == 0, proc.stderr
    assert "wlan0 no está conectado" not in proc.stdout
    assert "sale por eth0" in proc.stdout


def test_el_aviso_de_perfiles_ignora_solo_el_de_eth0(tmp_path: Path):
    red = tmp_path / "system-connections"
    netplan = tmp_path / "netplan"
    red.mkdir()
    netplan.mkdir()
    (red / "preconfigured.nmconnection").write_text("wifi\n", encoding="utf-8")
    (netplan / "50-cloud-init.yaml").write_text("wifis: {}\n", encoding="utf-8")
    script = f"""
set -euo pipefail
source scripts/orbit-nm.sh
antes_nm="$(nombres_en {red})"
antes_np="$(nombres_en {netplan})"
install -D /dev/null {red}/orbit-enlace-hp.nmconnection
avisar_si_cambio_la_red "$antes_nm" "$antes_np" {red} {netplan}
rm {netplan}/50-cloud-init.yaml
avisar_si_cambio_la_red "$antes_nm" "$antes_np" {red} {netplan}
"""
    proc = subprocess.run(
        ["bash", "-c", script],
        cwd=ROOT, capture_output=True, text=True, check=False,
    )
    assert proc.returncode == 0, proc.stderr
    assert "system-connections" not in proc.stdout
    assert proc.stdout.count("ha cambiado /etc/netplan") == 1


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


def _trozo(marca: str) -> str:
    text = INSTALADOR.read_text(encoding="utf-8")
    return text.split(marca, 1)[1].split("\nEOF", 1)[0]


def test_pausa_del_kiosco_no_sobrevive_al_reinicio(tmp_path: Path):
    pausa = "/run/orbit/kiosk-pausa"
    vieja = "/var/lib/orbit/kiosk-pausa"
    kiosk = _trozo("cat > /usr/local/bin/orbit-kiosk <<'EOF'")
    bucle = _trozo("cat > /usr/local/bin/orbit-kiosk-bucle <<'EOF'")
    atajo = _trozo("cat > /usr/local/bin/orbit-atajo <<'EOF'")
    inst = INSTALADOR.read_text(encoding="utf-8")
    assert f"[[ -f {pausa} ]]" in kiosk
    assert vieja not in kiosk
    assert f"rm -f {vieja}" in bucle
    assert f"[[ -f {pausa} ]]" in bucle
    assert f"touch {pausa}" in atajo
    assert vieja not in atajo
    assert "d /run/orbit 0755 ${ORBIT_USER} ${ORBIT_GROUP} -" in inst
    assert f"r {vieja} - - - -" in inst
    assert f"rm -f {vieja}" in inst
    assert "Para volver: rm /run/orbit/kiosk-pausa" in inst
    doc = (ROOT / "docs/instalacion-pi.md").read_text(encoding="utf-8")
    assert doc.count("`rm /run/orbit/kiosk-pausa`") == 2
    assert vieja not in doc
    manual = (ROOT / "hardware/cad/manual/completo_pdf.py").read_text(encoding="utf-8")
    assert manual.count("rm /run/orbit/kiosk-pausa") == 2
    assert vieja not in manual
    for nombre in ("orbit-kiosk", "orbit-kiosk-bucle", "orbit-atajo"):
        proc = subprocess.run(["bash", "-n"], input=_trozo(f"cat > /usr/local/bin/{nombre} <<'EOF'"), text=True, check=False)
        assert proc.returncode == 0, nombre

    run = tmp_path / "run"
    marca = run / "kiosk-pausa"
    resto = tmp_path / "vieja"
    log = tmp_path / "log"
    falso = tmp_path / "orbit-kiosk"
    falso.write_text(f"#!/bin/bash\necho arranco >> {log}\nexit 0\n", encoding="utf-8")
    falso.chmod(0o755)
    vivo = (
        bucle
        .replace(vieja, str(resto))
        .replace(pausa, str(marca))
        .replace("/usr/local/bin/orbit-kiosk", str(falso))
        .replace("sleep 2", "sleep 0.05")
    )
    # La marca vieja se borra y no impide abrir Chromium.
    resto.write_text("pausado", encoding="utf-8")
    viejo = subprocess.run(["timeout", "0.3", "bash", "-c", vivo], check=False)
    assert viejo.returncode == 124
    assert not resto.exists()
    assert "arranco" in log.read_text(encoding="utf-8")

    # La pausa de esta sesión sí lo deja parado, y sigue sin la marca vieja.
    log.write_text("", encoding="utf-8")
    resto.write_text("pausado", encoding="utf-8")
    marca.parent.mkdir(parents=True)
    marca.write_text("esta-sesion", encoding="utf-8")
    parado = subprocess.run(["timeout", "0.3", "bash", "-c", vivo], check=False)
    assert parado.returncode == 124
    assert not resto.exists()
    assert marca.is_file()
    assert log.read_text(encoding="utf-8") == ""

    # Un reinicio vacía /run: sin esa marca, el kiosco vuelve.
    marca.unlink()
    libre = subprocess.run(["timeout", "0.35", "bash", "-c", vivo], check=False)
    assert libre.returncode == 124
    assert "arranco" in log.read_text(encoding="utf-8")

    destino = tmp_path / "marca"
    destino.parent.mkdir(parents=True, exist_ok=True)
    orden = atajo.replace(pausa, str(destino)).replace(
        "pkill -f '/.config/orbit-kiosk' || true", "true",
    )
    proc = subprocess.run(
        ["bash", "-c", orden, "orbit-atajo", "pausa"],
        env={**os.environ, "PATH": "/usr/bin:/bin"},
        check=False,
    )
    assert proc.returncode == 0, proc.stderr
    assert destino.is_file()

    con_marca = kiosk.replace(pausa, str(destino))
    sale = subprocess.run(["bash", "-c", con_marca], check=False, timeout=5)
    assert sale.returncode == 0


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


def _bash(script: str, env: dict[str, str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["bash", "-c", script],
        cwd=ROOT,
        env={**os.environ, **env},
        capture_output=True,
        text=True,
        check=False,
    )


def test_bluetooth_se_desbloquea_y_se_puede_repetir(tmp_path: Path):
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    calls = tmp_path / "calls"
    rfkill = bin_dir / "rfkill"
    rfkill.write_text(
        f"#!/bin/bash\nprintf '%s\\n' \"$*\" >> {calls}\nexit 0\n",
        encoding="utf-8",
    )
    rfkill.chmod(0o755)
    systemctl = bin_dir / "systemctl"
    systemctl.write_text(
        f"""#!/bin/bash
printf '%s\\n' "$*" >> {calls}
if [[ "$1" == show ]]; then
  printf '%s\\n' loaded
fi
exit 0
""",
        encoding="utf-8",
    )
    systemctl.chmod(0o755)
    conf_dir = tmp_path / "bluetooth"
    conf_dir.mkdir()
    conf = conf_dir / "main.conf"
    conf.write_text(
        "[General]\nName = BlueZ\n\n[Policy]\n#AutoEnable=false\nJustWorksRepairing = always\n",
        encoding="utf-8",
    )
    unit = tmp_path / "systemd" / "orbit-bt-unblock.service"
    boot = tmp_path / "bin" / "orbit-bt-unblock"
    env = {
        "ORBIT_BT_CONF": str(conf),
        "ORBIT_BT_UNIT": str(unit),
        "ORBIT_BT_BIN": str(boot),
        "ORBIT_RFKILL": str(rfkill),
        "ORBIT_SYSTEMCTL": str(systemctl),
        "ORBIT_BLUETOOTHCTL": "",
    }
    script = "source scripts/orbit-bluetooth.sh\ndesbloquear_bluetooth\ndesbloquear_bluetooth\n"
    proc = _bash(script, env)
    assert proc.returncode == 0, proc.stderr
    assert "invalid" not in proc.stderr.lower()
    texto = conf.read_text(encoding="utf-8")
    assert "Name = BlueZ" in texto
    assert "JustWorksRepairing = always" in texto
    assert "#AutoEnable" not in texto
    for linea in (
        "AutoEnable=true",
        "ReconnectAttempts=7",
        "ReconnectIntervals=1, 2, 4, 8, 16, 32, 64",
    ):
        assert texto.count(linea) == 1
    assert calls.read_text(encoding="utf-8").count("unblock bluetooth") == 2
    ordenes = calls.read_text(encoding="utf-8")
    assert ordenes.count("enable bluetooth.service") == 2
    assert ordenes.count("start bluetooth.service") == 2
    assert ordenes.count("enable orbit-bt-unblock.service") == 2
    assert ordenes.count("start orbit-bt-unblock.service") == 2
    unidad = unit.read_text(encoding="utf-8")
    assert "After=bluetooth.service systemd-rfkill.service" in unidad
    assert f"ExecStart={boot}" in unidad
    orden = boot.read_text(encoding="utf-8")
    assert "rfkill unblock bluetooth" in orden
    assert "bluetoothctl power on" in orden
    assert "orbit-bt-unblock.service" in (ROOT / "scripts" / "orbit-bluetooth.sh").read_text(encoding="utf-8")
    inst = INSTALADOR.read_text(encoding="utf-8")
    assert "desbloquear_bluetooth" in inst
    assert "orbit-bluetooth.sh" in inst

    otra = conf_dir / "sin-policy.conf"
    otra.write_text("[General]\nDiscoverableTimeout = 0\n", encoding="utf-8")
    env["ORBIT_BT_CONF"] = str(otra)
    proc = _bash("source scripts/orbit-bluetooth.sh\ndesbloquear_bluetooth\n", env)
    assert proc.returncode == 0, proc.stderr
    sin = otra.read_text(encoding="utf-8")
    assert "DiscoverableTimeout = 0" in sin
    assert sin.endswith(
        "[Policy]\n"
        "ReconnectIntervals=1, 2, 4, 8, 16, 32, 64\n"
        "ReconnectAttempts=7\n"
        "AutoEnable=true\n"
    )


def test_bluetooth_ausente_no_toca_nada(tmp_path: Path):
    destino = tmp_path / "no-existe" / "main.conf"
    unit = tmp_path / "no-existe" / "unit.service"
    proc = _bash(
        "source scripts/orbit-bluetooth.sh\ndesbloquear_bluetooth\n",
        {
            "ORBIT_BT_CONF": str(destino),
            "ORBIT_BT_UNIT": str(unit),
            "ORBIT_BT_BIN": str(tmp_path / "no-existe" / "orbit-bt-unblock"),
            "ORBIT_RFKILL": "",
            "ORBIT_BLUETOOTHCTL": "",
            "ORBIT_SYSTEMCTL": "",
        },
    )
    assert proc.returncode == 0, proc.stderr
    assert "No hay Bluetooth" in proc.stdout
    assert not destino.parent.exists()


def test_bluetooth_rfkill_falla_y_el_instalador_sigue(tmp_path: Path):
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    rfkill = bin_dir / "rfkill"
    rfkill.write_text("#!/bin/bash\nexit 1\n", encoding="utf-8")
    rfkill.chmod(0o755)
    systemctl = bin_dir / "systemctl"
    calls = tmp_path / "calls"
    systemctl.write_text(
        f"#!/bin/bash\nprintf '%s\\n' \"$*\" >> {calls}\nexit 0\n",
        encoding="utf-8",
    )
    systemctl.chmod(0o755)
    conf_dir = tmp_path / "bluetooth"
    conf_dir.mkdir()
    conf = conf_dir / "main.conf"
    conf.write_text("[Policy]\nAutoEnable=false\n#ReconnectAttempts=0\n", encoding="utf-8")
    unit = tmp_path / "orbit-bt-unblock.service"
    proc = _bash(
        "set -euo pipefail\nsource scripts/orbit-bluetooth.sh\ndesbloquear_bluetooth\n",
        {
            "ORBIT_BT_CONF": str(conf),
            "ORBIT_BT_UNIT": str(unit),
            "ORBIT_BT_BIN": str(tmp_path / "orbit-bt-unblock"),
            "ORBIT_RFKILL": str(rfkill),
            "ORBIT_SYSTEMCTL": str(systemctl),
            "ORBIT_BLUETOOTHCTL": "",
        },
    )
    assert proc.returncode == 0, proc.stderr
    texto = conf.read_text(encoding="utf-8")
    assert "AutoEnable=true" in texto
    assert "ReconnectAttempts=7" in texto
    assert "#ReconnectAttempts" not in texto
    assert texto.count("ReconnectAttempts=") == 1
    ordenes = calls.read_text(encoding="utf-8")
    assert "enable bluetooth.service" not in ordenes
    assert "enable orbit-bt-unblock.service" in ordenes
    assert "After=bluetooth.service systemd-rfkill.service" in unit.read_text(encoding="utf-8")


def _btctl(path: Path, calls: Path, mode: Path) -> None:
    path.write_text(
        f"""#!/bin/bash
printf '%s\\n' "$*" >> {calls}
cmd="$1"
arg="${{2:-}}"
if [[ "$cmd" == devices && "$arg" == Trusted ]]; then
  if [[ -f {mode} && "$(cat {mode})" == paired ]]; then
    echo "Too many arguments" >&2
    exit 1
  fi
  echo "Device 13:07:10:02:00:22 Teclado"
  exit 0
fi
if [[ "$cmd" == devices && "$arg" == Paired ]]; then
  echo "Device 13:07:10:02:00:22 Teclado"
  exit 0
fi
if [[ "$cmd" == info ]]; then
  if [[ -f {mode} && "$(cat {mode})" == connected ]]; then
    printf '%s\\n' "Connected: yes" "Icon: input-keyboard" "UUID: 00001124-0000-1000-8000-00805f9b34fb"
  else
    printf '%s\\n' "Connected: no" "Icon: input-keyboard" "UUID: 00001124-0000-1000-8000-00805f9b34fb"
  fi
  exit 0
fi
if [[ "$cmd" == connect ]]; then
  echo "Failed to connect: org.bluez.Error.Failed br-connection-create-socket"
  exit 1
fi
echo "cmd inesperada: $*" >&2
exit 3
""",
        encoding="utf-8",
    )
    path.chmod(0o755)


def test_autoconnect_intenta_trusted_y_se_calla_si_ya_esta(tmp_path: Path):
    calls = tmp_path / "calls"
    mode = tmp_path / "mode"
    btctl = tmp_path / "bluetoothctl"
    _btctl(btctl, calls, mode)
    env = {
        "ORBIT_BTCTL": str(btctl),
        "ORBIT_BT_ROUNDS": "1",
        "ORBIT_BT_NO_SLEEP": "1",
    }
    proc = _bash("source scripts/orbit-bt-autoconnect.sh\nbucle_autoconnect\n", env)
    assert proc.returncode == 0, proc.stderr
    texto = calls.read_text(encoding="utf-8")
    assert "devices Trusted" in texto
    assert "devices Paired" not in texto
    assert "connect 13:07:10:02:00:22" in texto
    assert "connect 13:07:10:02:00:22" in proc.stdout
    assert "br-connection-create-socket" in proc.stdout
    modo = _bash(
        "source scripts/orbit-bt-autoconnect.sh\n"
        "printf '%s\\n' \"$(espera_segundos 0 0)\" \"$(espera_segundos 200 0)\" "
        "\"$(espera_segundos 2000 0)\" \"$(espera_segundos 10 1)\"\n",
        {},
    )
    assert modo.returncode == 0, modo.stderr
    assert modo.stdout.split() == ["10", "30", "120", "60"]

    calls.write_text("", encoding="utf-8")
    mode.write_text("connected", encoding="utf-8")
    proc = _bash("source scripts/orbit-bt-autoconnect.sh\nbucle_autoconnect\n", env)
    assert proc.returncode == 0, proc.stderr
    texto = calls.read_text(encoding="utf-8")
    assert "devices Trusted" in texto
    assert "connect " not in texto
    assert "connect " not in proc.stdout


def test_autoconnect_si_trusted_no_existe_usa_paired(tmp_path: Path):
    calls = tmp_path / "calls"
    mode = tmp_path / "mode"
    mode.write_text("paired", encoding="utf-8")
    btctl = tmp_path / "bluetoothctl"
    _btctl(btctl, calls, mode)
    proc = _bash(
        "source scripts/orbit-bt-autoconnect.sh\nbucle_autoconnect\n",
        {"ORBIT_BTCTL": str(btctl), "ORBIT_BT_ROUNDS": "1", "ORBIT_BT_NO_SLEEP": "1"},
    )
    assert proc.returncode == 0, proc.stderr
    texto = calls.read_text(encoding="utf-8")
    assert "devices Trusted" in texto
    assert "devices Paired" in texto
    assert "connect 13:07:10:02:00:22" in texto


def test_autoconnect_servicio_e_input_conf(tmp_path: Path):
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    calls = tmp_path / "calls"
    rfkill = bin_dir / "rfkill"
    rfkill.write_text(f"#!/bin/bash\nprintf '%s\\n' \"$*\" >> {calls}\nexit 0\n", encoding="utf-8")
    rfkill.chmod(0o755)
    systemctl = bin_dir / "systemctl"
    systemctl.write_text(
        f"#!/bin/bash\nprintf '%s\\n' \"$*\" >> {calls}\nif [[ \"$1\" == show ]]; then printf '%s\\n' loaded; fi\nexit 0\n",
        encoding="utf-8",
    )
    systemctl.chmod(0o755)
    conf_dir = tmp_path / "bluetooth"
    conf_dir.mkdir()
    (conf_dir / "main.conf").write_text("[Policy]\nAutoEnable=true\n", encoding="utf-8")
    inp = conf_dir / "input.conf"
    inp.write_text("[General]\n#ClassicBondedOnly=true\nIdleTimeout=0\n", encoding="utf-8")
    unit_dir = tmp_path / "systemd"
    env = {
        "ORBIT_BT_CONF": str(conf_dir / "main.conf"),
        "ORBIT_BT_INPUT": str(inp),
        "ORBIT_BT_UNIT": str(unit_dir / "orbit-bt-unblock.service"),
        "ORBIT_BT_BIN": str(bin_dir / "orbit-bt-unblock"),
        "ORBIT_RFKILL": str(rfkill),
        "ORBIT_SYSTEMCTL": str(systemctl),
        "ORBIT_BLUETOOTHCTL": "",
    }
    proc = _bash(
        "source scripts/orbit-bluetooth.sh\ndesbloquear_bluetooth\ndesbloquear_bluetooth\n",
        env,
    )
    assert proc.returncode == 0, proc.stderr
    texto = inp.read_text(encoding="utf-8")
    assert texto.count("ClassicBondedOnly=false") == 1
    assert "#ClassicBondedOnly" not in texto
    assert "IdleTimeout=0" in texto
    assert "UserspaceHID" not in texto
    servicio = (unit_dir / "orbit-bt-autoconnect.service").read_text(encoding="utf-8")
    assert "After=bluetooth.service orbit-bt-unblock.service" in servicio
    assert "Type=simple" in servicio
    assert f"ExecStart={bin_dir / 'orbit-bt-autoconnect'}" in servicio
    script = (bin_dir / "orbit-bt-autoconnect").read_text(encoding="utf-8")
    assert "devices Trusted" in script
    assert "devices Paired" in script
    ordenes = calls.read_text(encoding="utf-8")
    assert ordenes.count("enable orbit-bt-autoconnect.service") == 2
    assert ordenes.count("start orbit-bt-autoconnect.service") == 2
    assert "orbit-bt-autoconnect" in INSTALADOR.read_text(encoding="utf-8")
    inst = (ROOT / "scripts" / "orbit-bluetooth.sh").read_text(encoding="utf-8")
    assert "orbit-bt-autoconnect.service" in inst
    assert "ClassicBondedOnly" in inst
    assert "UserspaceHID" in inst
