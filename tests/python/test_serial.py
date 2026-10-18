from orbitd.serial_events import Hello, SimControls, parse_line


def test_parse_pot_button_hello():
    assert parse_line("P1 512\n") == {"control": "P1", "kind": "pot", "value": 512, "simulated": False}
    assert parse_line("B2 1")["event"] == "press"
    assert parse_line("B2 0")["event"] == "release"
    assert parse_line("B12 L", simulated=True) == {"control": "B12", "kind": "button", "event": "long", "simulated": True}
    h = parse_line("H orbit-controls 1 P3 B4")
    assert isinstance(h, Hello) and h.pots == 3 and h.buttons == 4


def test_parse_rejects_garbage():
    for line in ["", "P0 5", "P1 2000", "P1 -1", "B1 2", "X1 1", "P1  5", "rm -rf /"]:
        assert parse_line(line) is None, line


def test_sim_controls_emit_valid_lines():
    s = SimControls(pots=3, buttons=4, seed=1, press_buttons=True)
    s._next_btn = 0
    lines = [s.hello()] + [ln for _ in range(50) for ln in s.step()]
    assert all(parse_line(ln) is not None for ln in lines)
    assert any(ln.startswith("B") for ln in lines) and any(ln.startswith("P") for ln in lines)


def test_sim_controls_no_buttons_by_default():
    s = SimControls(seed=2)
    assert s.pots == 2 and s.buttons == 2
    assert s.hello() == "H orbit-controls-sim 1 P2 B2"
    s._next_btn = 0
    assert not any(ln.startswith("B") for _ in range(50) for ln in s.step())
