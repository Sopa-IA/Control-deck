"""Pruebas del cambio de sistema visible (orbitd.video): sin ddcutil ni visor reales."""
import asyncio
import sys

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


# ------------------------------------------------------------------ modo C: capturadora
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
