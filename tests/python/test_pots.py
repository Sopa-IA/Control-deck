import json

from orbitd.hub import Config, Hub
from orbitd.pots import PotGate, normalize_mapping


def test_ruido_pequeno_no_dispara_y_el_mismo_nivel_no_se_repite():
    gate = PotGate()
    shown = None
    for raw in (70, 72, 68, 71, 69, 70, 66, 74):
        decision = gate.feed("P1", raw)
        if decision.show is not None:
            shown = decision.show
        assert decision.act is False
    assert shown is not None
    moved = [gate.feed("P1", 400) for _ in range(3)]
    assert moved[0].act is False and moved[1].act is False
    assert moved[-1].act is True
    assert moved[-1].level == round(400 * 100 / 1023)
    assert gate.feed("P1", 400).act is False
    assert gate.feed("P1", 405).act is False


def test_una_entrada_flotante_no_publica_ni_actua():
    gate = PotGate()
    saltos = [0, 800, 100, 900, 50, 700, 20, 850, 10, 780, 40, 820, 30, 900, 15]
    for raw in saltos:
        decision = gate.feed("P1", raw)
        assert decision.act is False
        assert decision.show is None


def test_la_asignacion_de_fabrica_pasa_a_ninguna_y_no_se_deshace(tmp_path):
    path = tmp_path / "controls.json"
    path.write_text(json.dumps({
        "version": 1,
        "pots": {"P1": "hp.volume_set", "P2": "ui.scroll"},
        "buttons": {"B1": "ui.power_menu", "B2": "pi.switch_visible"},
    }), encoding="utf-8")
    hub = Hub(Config(state_dir=tmp_path, hp_token="token-de-prueba-0123456789"))
    assert hub.mapping["pots"] == {"P1": "none", "P2": "none"}
    assert hub.mapping["buttons"]["B2"] == "pi.switch_visible"
    saved = json.loads(path.read_text(encoding="utf-8"))
    assert saved["version"] == 2
    hub.mapping["pots"]["P1"] = "hp.volume_set"
    hub.mapping["version"] = 2
    hub._save_mapping()
    otra = Hub(Config(state_dir=tmp_path, hp_token="token-de-prueba-0123456789"))
    assert otra.mapping["pots"]["P1"] == "hp.volume_set"
    assert otra.mapping["pots"]["P2"] == "none"


def test_un_pot_ya_elegido_no_se_apaga_en_la_migracion():
    mapping, changed = normalize_mapping({
        "version": 1,
        "pots": {"P1": "ui.brightness", "P2": "ui.scroll"},
        "buttons": {"B1": "ui.power_menu"},
    })
    assert changed is True
    assert mapping["pots"]["P1"] == "ui.brightness"
    assert mapping["pots"]["P2"] == "none"
    assert mapping["version"] == 2
    otra, changed2 = normalize_mapping(mapping)
    assert changed2 is False
    assert otra["pots"]["P1"] == "ui.brightness"
