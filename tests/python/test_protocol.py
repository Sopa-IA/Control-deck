import json

import pytest

import orbit_protocol as P


def test_make_valid_envelope():
    m = P.make("ping", "pi", {"seq": 3})
    assert m["v"] == 1 and m["type"] == "ping" and m["src"] == "pi" and m["payload"] == {"seq": 3}
    assert P.parse(json.dumps(m)) == m


@pytest.mark.parametrize("bad", [
    "{no json", json.dumps({"v": 2, "type": "ping", "id": "a", "ts": 1, "src": "pi", "payload": {"seq": 1}}),
    json.dumps({"v": 1, "type": "rm", "id": "a", "ts": 1, "src": "pi", "payload": {}}),
    json.dumps({"v": 1, "type": "ping", "id": "a", "ts": 1, "src": "pi", "payload": {}}),
    json.dumps({"v": 1, "type": "ping", "id": "a", "ts": 1, "src": "pi", "payload": {"seq": 1}, "extra": 1}),
])
def test_parse_rejects_bad(bad):
    with pytest.raises(P.ProtocolError) as e:
        P.parse(bad)
    assert e.value.code == "bad_message"


def test_parse_rejects_oversize():
    with pytest.raises(P.ProtocolError):
        P.parse("x" * (P.MAX_MESSAGE_BYTES + 1))


def test_telemetry_requires_simulated_flag():
    with pytest.raises(P.ProtocolError):
        P.make("telemetry", "hp", {"host": "hp", "cpu_pct": 1, "mem_pct": 2})
    P.make("telemetry", "hp", {"host": "hp", "simulated": True, "cpu_pct": 1, "mem_pct": 2})


def test_whitelist():
    assert P.check_action("hp.volume_set", {"level": 40})["target"] == "hp"
    for action, params, code in [
        ("hp.exec", {}, "not_allowed"), ("hp.volume_set", {"level": 101}, "bad_params"),
        ("hp.volume_set", {}, "bad_params"), ("hp.ping", {"x": 1}, "bad_params"),
        ("hp.open_app", {"app": "../../cmd"}, "bad_params"), ("pi.led_mode", {"mode": "disco"}, "bad_params"),
    ]:
        with pytest.raises(P.ProtocolError) as e:
            P.check_action(action, params)
        assert e.value.code == code, action
    with pytest.raises(P.ProtocolError):
        P.check_action("pi.ping", {}, target="hp")


def test_destructive_actions_require_confirm():
    for name, spec in P.ACTIONS.items():
        assert name.split(".")[0] == spec["target"]
        if spec["destructive"]:
            assert spec["confirm"], name


def test_mapping_validation():
    m = P.load_default_mapping()
    assert set(m["pots"]) == {"P1", "P2"}
    assert set(m["buttons"]) == {"B1", "B2"}
    assert P.check_mapping(m) is m
    with pytest.raises(P.ProtocolError):
        P.check_mapping({"pots": {"P1": "ui.select"}, "buttons": {}})   # función de botón en pot
    with pytest.raises(P.ProtocolError):
        P.check_mapping({"pots": {}, "buttons": {"B1": "hp.shutdown"}})  # no es función asignable


def test_tokens_equal():
    assert P.tokens_equal("abc", "abc")
    assert not P.tokens_equal("abc", "abd")
    assert not P.tokens_equal("", "")
    assert not P.tokens_equal(None, "x")
