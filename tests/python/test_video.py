"""Pruebas del cambio de sistema visible (orbitd.video): sin ddcutil ni visor reales."""
import asyncio
import sys
from pathlib import Path

from orbitd.video import VideoConfig, VideoSwitcher


def run(c):
    return asyncio.run(c)


def test_from_env_defaults_remoto():
    sw = VideoSwitcher(VideoConfig.from_env({}))
    assert sw.mode() == "remoto" and sw.visible == "pi"


def test_from_env_lee_orden_sin_shell():
    cfg = VideoConfig.from_env({"ORBIT_REMOTE_CMD": "moonlight stream 10.0.0.2 Desktop"})
    assert cfg.remote_cmd == ["moonlight", "stream", "10.0.0.2", "Desktop"]


def test_remoto_sin_visor_es_dry_run_y_alterna():
    sw = VideoSwitcher(VideoConfig())
    r = run(sw.switch())
    assert r["ok"] and r["dry_run"] and sw.visible == "hp" and sw.state()["mode"] == "remoto"
    r = run(sw.switch())
    assert r["ok"] and not r["dry_run"] and sw.visible == "pi"


def test_remoto_lanza_y_cierra_visor():
    sw = VideoSwitcher(VideoConfig(remote_cmd=[sys.executable, "-c", "import time; time.sleep(30)"]))

    async def go():
        r1 = await sw.switch("hp")
        proc = sw._viewer
        r2 = await sw.switch("pi")
        return r1, proc, r2
    r1, proc, r2 = run(go())
    assert r1["ok"] and not r1["dry_run"] and proc is not None
    assert proc.returncode is not None and r2["ok"] and sw.visible == "pi"


def test_ddc_requiere_valores_validos(monkeypatch):
    monkeypatch.setattr("orbitd.video.shutil.which", lambda _: "/usr/bin/ddcutil")
    assert VideoSwitcher(VideoConfig(ddc_enabled=True, ddc_value_hp="0x11", ddc_value_pi="1b")).mode() == "ddc"
    assert VideoSwitcher(VideoConfig(ddc_enabled=True, ddc_value_hp="11; rm -rf /", ddc_value_pi="1b")).mode() == "remoto"
    assert VideoSwitcher(VideoConfig(ddc_enabled=False, ddc_value_hp="11", ddc_value_pi="1b")).mode() == "remoto"


def test_ddc_falla_vuelve_a_remoto(monkeypatch):
    monkeypatch.setattr("orbitd.video.shutil.which", lambda _: "/usr/bin/ddcutil")
    sw = VideoSwitcher(VideoConfig(ddc_enabled=True, ddc_value_hp="11", ddc_value_pi="1b"))
    calls = []

    async def fake_ddc(target):
        calls.append(target)
        return False, "monitor sin DDC/CI"
    sw._ddc = fake_ddc
    r = run(sw.switch("hp"))
    assert r["ok"] and sw.state()["mode"] == "remoto" and "DDC/CI no disponible" in r["message"]
    assert calls == ["hp", "pi"]


def test_ddc_ok(monkeypatch):
    monkeypatch.setattr("orbitd.video.shutil.which", lambda _: "/usr/bin/ddcutil")
    sw = VideoSwitcher(VideoConfig(ddc_enabled=True, ddc_value_hp="11", ddc_value_pi="1b"))

    async def ok(target):
        return True, "ok"
    sw._ddc = ok
    r = run(sw.switch())
    assert r["ok"] and sw.state() == {"system": "hp", "mode": "ddc", "detail": r["message"]}


# ------------------------------------------------------------------ visor local
def test_from_env_captura():
    cfg = VideoConfig.from_env({"ORBIT_CAPTURE_DEVICE": "/dev/video0",
                                "ORBIT_CAPTURE_CMD": "mpv --profile=low-latency av://v4l2:{device}"})
    assert cfg.capture_device == "/dev/video0"
    assert cfg.capture_cmd == ["mpv", "--profile=low-latency", "av://v4l2:{device}"]
    sw = VideoSwitcher(cfg)
    assert sw.mode() == "captura"
    assert sw.capture_argv() == ["mpv", "--profile=low-latency", "av://v4l2:/dev/video0"]


def test_captura_rechaza_dispositivos_no_v4l2():
    for dev in ["/dev/sda", "/dev/video0; rm -rf /", "../dev/video0", "/dev/v4l/by-id/../../sda", "video0"]:
        sw = VideoSwitcher(VideoConfig(capture_device=dev, capture_cmd=["true"]))
        assert sw.mode() == "remoto", dev
    assert VideoSwitcher(VideoConfig(capture_device="/dev/v4l/by-id/usb-MACROSILICON_USB_Video-video-index0",
                                     capture_cmd=["true"])).mode() == "captura"
    # sin orden de visor no hay modo captura
    assert VideoSwitcher(VideoConfig(capture_device="/dev/video0")).mode() == "remoto"


def test_captura_lanza_y_cierra_visor(monkeypatch):
    monkeypatch.setattr("orbitd.video.os.path.exists", lambda p: p == "/dev/video0")
    sw = VideoSwitcher(VideoConfig(capture_device="/dev/video0",
                                   capture_cmd=[sys.executable, "-c", "import time, sys; time.sleep(30)", "{device}"]))

    async def go():
        r1 = await sw.switch("hp")
        proc = sw._viewer
        st = sw.state()
        r2 = await sw.switch("pi")
        return r1, proc, st, r2
    r1, proc, st, r2 = run(go())
    assert r1["ok"] and not r1["dry_run"] and proc is not None
    assert st["system"] == "hp" and st["mode"] == "captura" and "/dev/video0" in st["detail"]
    assert proc.returncode is not None and r2["ok"] and sw.visible == "pi" and sw.state()["mode"] == "captura"


def test_captura_sin_dispositivo_vuelve_a_remoto(monkeypatch):
    monkeypatch.setattr("orbitd.video.os.path.exists", lambda p: False)
    sw = VideoSwitcher(VideoConfig(capture_device="/dev/video0", capture_cmd=["visor-inexistente", "{device}"]))
    r = run(sw.switch("hp"))
    assert r["ok"] and r["dry_run"] and sw.state()["mode"] == "remoto"
    assert "Captura no disponible (no existe /dev/video0)" in r["message"]


def test_captura_visor_inexistente_vuelve_a_remoto(monkeypatch):
    monkeypatch.setattr("orbitd.video.os.path.exists", lambda p: True)
    sw = VideoSwitcher(VideoConfig(capture_device="/dev/video0",
                                   capture_cmd=["/nonexistent/visor-orbit", "{device}"]))
    r = run(sw.switch("hp"))
    assert r["ok"] and sw.state()["mode"] == "remoto" and "Captura no disponible" in r["message"]
    assert sw._viewer is None


def test_hueco_integrado_y_barra():
    from orbitd.video import marco_hole
    assert marco_hole(False) == (0, 40, 1920, 1040)
    assert marco_hole(True) == (48, 40, 1872, 1040)


def test_argv_integrado_1080p60_y_completa():
    sw = VideoSwitcher(VideoConfig(moonlight_bin="moonlight-qt", hp_host="10.0.0.1", moonlight_app="Desktop"))
    argv = sw.stream_argv()
    assert argv[:4] == ["moonlight-qt", "stream", "10.0.0.1", "Desktop"]
    assert argv[argv.index("--fps") + 1] == "60"
    assert "--absolute-mouse" in argv and "--no-game-optimization" in argv
    assert argv[argv.index("--display-mode") + 1] == "windowed"
    assert argv[argv.index("--resolution") + 1] == "1920x1040"
    sw.layout = "completa"
    completa = sw.stream_argv()
    assert completa[completa.index("--display-mode") + 1] == "fullscreen"
    assert "--1080" in completa and "--resolution" not in completa
    assert completa[completa.index("--fps") + 1] == "60"


def test_sin_emparejar_no_abre_moonlight(monkeypatch, tmp_path):
    monkeypatch.setenv("ORBIT_MOONLIGHT_CONFIG", str(tmp_path / "no.conf"))
    sw = VideoSwitcher(VideoConfig(moonlight_bin="moonlight-qt", hp_host="10.0.0.1"))
    r = run(sw.switch("hp"))
    assert r["ok"] and r["dry_run"] and sw.visible == "pi" and sw._viewer is None
    assert "emparejado" in r["message"]
    assert sw.state()["pairing"] == "pendiente" and sw.state()["layout"] == "integrado"


def test_emparejado_abre_y_el_boton_cierra(monkeypatch, tmp_path):
    conf = tmp_path / "Moonlight.conf"
    conf.write_text("[hosts]\n1\\manualAddress=10.0.0.1\n1\\pairState=1\nsize=1\n", encoding="utf-8")
    monkeypatch.setenv("ORBIT_MOONLIGHT_CONFIG", str(conf))
    sw = VideoSwitcher(VideoConfig(moonlight_bin=sys.executable, hp_host="10.0.0.1", moonlight_app="Desktop"))
    # El binario de prueba no se llama moonlight: la orden fija evita el emparejamiento.
    sw.cfg.moonlight_bin = ""
    sw.cfg.remote_cmd = [sys.executable, "-c", "import time; time.sleep(30)"]

    async def go():
        r1 = await sw.switch("hp")
        proc = sw._viewer
        r2 = await sw.switch("pi")
        return r1, proc, r2
    r1, proc, r2 = run(go())
    assert r1["ok"] and not r1["dry_run"] and proc is not None and proc.returncode is not None
    assert r2["ok"] and sw.visible == "pi" and "Orbit OS" in r2["message"]


def test_al_cerrar_moonlight_vuelve_a_orbit(monkeypatch, tmp_path):
    conf = tmp_path / "Moonlight.conf"
    conf.write_text("[hosts]\n1\\manualAddress=10.0.0.1\n1\\pairState=1\nsize=1\n", encoding="utf-8")
    monkeypatch.setenv("ORBIT_MOONLIGHT_CONFIG", str(conf))
    assert VideoSwitcher(VideoConfig(moonlight_bin="moonlight-qt", hp_host="10.0.0.1")).is_paired()
    sw = VideoSwitcher(VideoConfig(remote_cmd=[sys.executable, "-c", ""], hp_host="10.0.0.1"))

    async def go():
        r = await sw.switch("hp")
        if sw._watch is not None:
            await asyncio.wait_for(sw._watch, 2)
        return r
    r = run(go())
    assert r["ok"] and sw.visible == "pi"
    assert "Orbit OS" in sw.detail


def test_regla_labwc_posicion_y_sin_bordes(tmp_path):
    from orbitd.video import labwc_rc_text, write_labwc_rc
    text = labwc_rc_text("integrado", False)
    assert 'identifier="*moonlight*"' in text
    assert "<serverDecoration>no</serverDecoration>" in text
    assert 'name="MoveTo" x="0" y="40"' in text
    assert 'name="ResizeTo" width="1920" height="1040"' in text
    assert 'name="ToggleAlwaysOnTop"' in text
    assert 'key="C-A-S-x"' in text
    assert "orbit-atajo layout" in text
    completa = labwc_rc_text("completa", False)
    assert "MoveTo" not in completa
    path = tmp_path / "rc.xml"
    path.write_text("<labwc_config></labwc_config>", encoding="utf-8")
    write_labwc_rc(path, "integrado", True)
    written = path.read_text(encoding="utf-8")
    assert 'width="1872"' in written and 'x="48"' in written
    assert (tmp_path / "rc.xml.orbit-bak").exists()


def test_parser_emparejamiento():
    from orbitd.video import conf_paired_with
    assert conf_paired_with("1\\manualAddress=10.0.0.1\n1\\pairState=1\n", "10.0.0.1")
    assert not conf_paired_with("1\\manualAddress=10.0.0.1\n1\\pairState=0\n", "10.0.0.1")
    assert not conf_paired_with("1\\manualAddress=10.0.0.9\n1\\pairState=1\n", "10.0.0.1")
    assert conf_paired_with("1\\manualaddress=10.0.0.1\n1\\srvcert=@ByteArray(CERT)\n", "10.0.0.1")


def _conf_moonlight_qt(cert="@ByteArray(CERT)"):
    """Fichero como lo escribe QSettings: [hosts] y claves en minúsculas, sin pairState."""
    return "\n".join([
        "[General]",
        "certificate=@ByteArray(CLIENTE)",
        "key=@ByteArray(CLAVE)",
        "width=1920",
        "",
        "[hosts]",
        "1\\\\hostname=Otro",
        "1\\\\manualaddress=192.168.1.50",
        "1\\\\localaddress=192.168.1.50",
        "1\\\\remoteaddress=",
        "1\\\\srvcert=@ByteArray()",
        "1\\\\apps\\\\1\\\\name=Desktop",
        "1\\\\apps\\\\size=1",
        "2\\\\hostname=HP",
        "2\\\\uuid=0123456789abcdef0123456789abcdef",
        "2\\\\localaddress=10.0.0.1",
        "2\\\\localport=47989",
        "2\\\\remoteaddress=",
        "2\\\\remoteport=47989",
        "2\\\\manualaddress=10.0.0.1",
        "2\\\\manualport=47989",
        "2\\\\ipv6address=",
        "2\\\\ipv6port=47989",
        f"2\\\\srvcert={cert}",
        "2\\\\customname=false",
        "2\\\\nvidiasw=false",
        "2\\\\apps\\\\1\\\\name=Desktop",
        "2\\\\apps\\\\1\\\\id=881448767",
        "2\\\\apps\\\\size=1",
        "size=2",
        "",
    ])


def test_conf_real_de_moonlight_qt():
    from orbitd.video import conf_paired_with, moonlight_config_paths
    texto = _conf_moonlight_qt()
    assert "pairState" not in texto and "manualAddress" not in texto
    assert "2\\\\manualaddress=10.0.0.1" in texto
    assert conf_paired_with(texto, "10.0.0.1")
    assert not conf_paired_with(texto, "192.168.1.50")
    assert not conf_paired_with(texto, "10.0.0.10")
    assert not conf_paired_with(_conf_moonlight_qt("@ByteArray()"), "10.0.0.1")
    assert not conf_paired_with(_conf_moonlight_qt("@ByteArray(%00)"), "10.0.0.1")
    assert not conf_paired_with(_conf_moonlight_qt('""'), "10.0.0.1")
    rutas = moonlight_config_paths(Path("/home/orbit"))
    assert rutas[0] == Path("/home/orbit/.config/Moonlight Game Streaming Project/Moonlight.conf")


def test_lee_moonlight_conf_del_usuario(monkeypatch, tmp_path):
    from orbitd.video import moonlight_paired
    monkeypatch.delenv("ORBIT_MOONLIGHT_CONFIG", raising=False)
    destino = tmp_path / ".config" / "Moonlight Game Streaming Project"
    destino.mkdir(parents=True)
    (destino / "Moonlight.conf").write_text(_conf_moonlight_qt(), encoding="utf-8")
    assert moonlight_paired("10.0.0.1", home=tmp_path)
    assert not moonlight_paired("10.0.0.9", home=tmp_path)
    sw = VideoSwitcher(VideoConfig(moonlight_bin="moonlight-qt", hp_host="10.0.0.1"))
    monkeypatch.setenv("ORBIT_MOONLIGHT_CONFIG", str(destino / "Moonlight.conf"))
    assert sw.is_paired()
    assert sw.state()["pairing"] == "hecho"


def test_ddc_falla_usa_captura(monkeypatch):
    monkeypatch.setattr("orbitd.video.shutil.which", lambda _: "/usr/bin/ddcutil")
    monkeypatch.setattr("orbitd.video.os.path.exists", lambda p: True)
    sw = VideoSwitcher(VideoConfig(ddc_enabled=True, ddc_value_hp="11", ddc_value_pi="1b",
                                   capture_device="/dev/video0",
                                   capture_cmd=[sys.executable, "-c", "import time; time.sleep(30)"]))
    assert sw.mode() == "ddc"

    async def fail(target):
        return False, "monitor sin DDC/CI"
    sw._ddc = fail

    async def go():
        r = await sw.switch("hp")
        await sw.close()
        return r
    r = run(go())
    assert r["ok"] and sw.state()["mode"] == "captura" and "DDC/CI no disponible" in r["message"]
