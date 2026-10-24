"""La tira de luz no finge un cambio si no está conectada."""
from orbitd.hub import Config, Hub


def test_la_tira_no_cambia_nada(tmp_path):
    hub = Hub(Config(state_dir=tmp_path))
    r = hub._pi_action("pi.led_mode", {"label": "Modo de LEDs"})
    assert r["ok"] is False
    assert "PENDIENTE" not in r["message"]
    assert "no está conectada" in r["message"]


def test_recargar_la_interfaz_responde(tmp_path):
    hub = Hub(Config(state_dir=tmp_path))
    r = hub._pi_action("pi.restart_ui", {"label": "Recargar interfaz"})
    assert r["ok"] is True and "Orbit OS" in r["message"]
