"""Lo que ya funciona en la Pi y el HP no se renombra ni se apaga.

Estas pruebas leen el instalador y el código. No arrancan la Pi ni el HP.
"""
from __future__ import annotations

import json
from pathlib import Path

import orbit_protocol as P

ROOT = Path(__file__).resolve().parents[2]


def _texto(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def _sin_comentarios(texto: str) -> str:
    return "\n".join(linea.split("#", 1)[0] for linea in texto.splitlines())


def test_la_sesion_orbit_el_kiosco_y_el_escritorio_siguen():
    inst = _texto("scripts/instalar-pi.sh")
    sesion = _texto("scripts/orbit-sesion.sh")
    escritorio = _texto("scripts/orbit-escritorio.sh")
    assert "/usr/share/wayland-sessions/orbit.desktop" in inst
    assert "Name=Orbit OS" in inst
    assert "Exec=/usr/local/bin/orbit-sesion" in inst
    assert "-C /etc/orbit/labwc" in sesion
    assert "/usr/local/bin/orbit-escritorio" in inst
    assert "rpd-labwc" in escritorio or "LXDE-pi-labwc" in escritorio
    video = _texto("software/pi-controller/orbitd/video.py")
    assert 'key="C-A-t"' in video
    assert "orbit-atajo pausa" in video
    assert "touch /run/orbit/kiosk-pausa" in inst
    assert "/run/orbit/kiosk-pausa" in inst
    assert "rm -f /var/lib/orbit/kiosk-pausa" in inst
    assert "Para volver: rm /run/orbit/kiosk-pausa" in inst


def test_el_wifi_y_eth0_no_se_tocan():
    inst = _sin_comentarios(_texto("scripts/instalar-pi.sh"))
    nm = _sin_comentarios(_texto("scripts/orbit-nm.sh"))
    for src in (inst, nm):
        for prohibido in ("connection reload", "con reload", "connection delete", "connection modify", "netplan apply"):
            assert prohibido not in src
    perfil = inst.split("orbit-enlace-hp.nmconnection <<'EOF'", 1)[1].split("\nEOF", 1)[0]
    assert "id=orbit-enlace-hp" in perfil or "orbit-enlace-hp" in perfil
    assert "address1=10.0.0.2/24" in perfil
    assert "never-default=true" in perfil
    assert "MOVISTAR" not in inst
    assert "wlan0" not in perfil


def test_el_teclado_bluetooth_sigue_reconectando():
    bt = _texto("scripts/orbit-bluetooth.sh")
    auto = _texto("scripts/orbit-bt-autoconnect.sh")
    inst = _texto("scripts/instalar-pi.sh")
    assert "orbit-bt-unblock.service" in bt
    assert "orbit-bt-autoconnect.service" in bt
    assert "bluetoothctl" in auto
    assert "source \"$(dirname \"$0\")/orbit-bluetooth.sh\"" in inst
    assert "desbloquear_bluetooth" in inst


def test_el_nano_de_mandos_sigue_en_by_path_y_ttyUSB0_es_solo_reserva():
    detectar = _texto("scripts/detectar-nanos.sh")
    main = _texto("software/pi-controller/orbitd/__main__.py")
    ardu = _texto("software/pi-controller/orbitd/ardu_lab.py")
    assert "/dev/serial/by-path" in detectar
    assert "ttyUSB" in detectar and "no se usa" in detectar.lower() or "no ttyUSB" in detectar or "no se anota ttyUSB" in detectar
    assert "/var/lib/orbit/arduino-puertos.json" in _texto("scripts/instalar-pi.sh") or "arduino-puertos.json" in detectar
    assert "/dev/ttyUSB0" in main
    assert "arduino:avr:nano" in ardu
    assert "def mandos_link" in ardu


def test_moonlight_sigue_por_srvcert_y_las_dos_vistas():
    video = _texto("software/pi-controller/orbitd/video.py")
    assert "srvcert" in video
    assert '"integrado"' in video and '"completa"' in video
    assert "10.0.0.1" in _texto("software/shared/marco.json") or "hp_host" in _texto("software/shared/marco.json")


def test_hp_agent_sigue_en_vivo_con_la_misma_tarea():
    ps1 = _texto("scripts/instalar-hp.ps1")
    assert "$Tarea = 'OrbitHpAgent'" in ps1
    assert "$enVivo = -not $DryRun" in ps1
    assert "if ($enVivo) { $argumentos = '-m hp_agent --live' }" in ps1
    assert "Name -ne '.venv'" in ps1


def test_el_planeta_sigue_con_el_interruptor():
    cfg = _texto("software/interface/src/sections/Configuracion.tsx")
    motion = _texto("software/interface/src/components/planetMotion.ts")
    assert "Quieta" in cfg and "Activada" in cfg
    assert "orbit.planetMotion" in motion
    assert "shouldAnimate" in motion


def test_el_protocolo_viejo_sigue_entrando_y_las_claves_no_se_renombran():
    viejo = {
        "host": "hp", "simulated": False, "cpu_pct": 3, "mem_pct": 20,
        "disk_pct": 40, "uptime_s": 120, "temp_c": None,
    }
    P.make("telemetry", "hp", viejo)
    nuevo = dict(viejo, net_up_kbps=1.5, net_down_kbps=2.5, volume_pct=40, volume_muted=False)
    msg = P.make("telemetry", "hp", nuevo)
    for clave in ("host", "simulated", "cpu_pct", "mem_pct", "disk_pct", "uptime_s", "temp_c", "net_up_kbps", "net_down_kbps"):
        assert clave in msg["payload"]
    acciones = json.loads((ROOT / "software/shared/actions.json").read_text(encoding="utf-8"))["actions"]
    for nombre in ("hp.lock_screen", "hp.shutdown", "hp.volume_set", "hp.volume_mute", "pi.switch_visible"):
        assert nombre in acciones
