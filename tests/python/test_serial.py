import asyncio
import threading
import time

from orbitd.__main__ import main
from orbitd.serial_events import NANO_RESET_WAIT_S, Hello, SerialReader, SimControls, parse_line


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


class _PuertoFalso:
    """Puerto serie de mentira: no abre hardware. Sirve para ver cuándo se escribe '?'."""

    def __init__(self):
        self.writes = []
        self.lines = [b"H orbit-controls 1 P2 B2\n"]

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        return False

    def write(self, data):
        self.writes.append((time.monotonic(), data))

    def readline(self):
        if self.lines:
            return self.lines.pop(0)
        time.sleep(0.02)
        return b""


def test_nano_no_escribe_durante_el_reinicio():
    """Abrir el puerto reinicia el Nano. El '?' sale después de la espera, y el saludo espontáneo no se tira."""
    loop = asyncio.new_event_loop()
    threading.Thread(target=loop.run_forever, daemon=True).start()
    puerto = _PuertoFalso()
    recibidas = []
    reader = SerialReader(
        "/dev/ttyUSB0", 115200, loop, recibidas.append, lambda *_: None,
        reset_wait_s=0.15, open_port=lambda *args: puerto,
    )
    t0 = time.monotonic()
    reader.start()
    limite = time.monotonic() + 2
    while time.monotonic() < limite and not puerto.writes:
        time.sleep(0.02)
    reader.stop()
    reader._thread.join(1)
    loop.call_soon_threadsafe(loop.stop)
    assert puerto.writes, "no se pidió el saludo"
    assert puerto.writes[0][1] == b"?\n"
    assert puerto.writes[0][0] - t0 >= 0.12
    assert any(ln.startswith("H orbit-controls") for ln in recibidas)


def test_espera_de_reinicio_por_defecto():
    loop = asyncio.new_event_loop()
    reader = SerialReader("/dev/ttyUSB0", 115200, loop, lambda _line: None, lambda *_: None)
    assert reader.reset_wait_s == NANO_RESET_WAIT_S == 2.0
    assert reader.port == "/dev/ttyUSB0"


def test_ayuda_documenta_ttyusb():
    import contextlib
    import io

    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        try:
            main(["--help"])
        except SystemExit as exc:
            assert exc.code == 0
    texto = buf.getvalue()
    assert "/dev/ttyUSB0" in texto
    assert "ttyACM0" not in texto


def test_sim_controls_no_buttons_by_default():
    s = SimControls(seed=2)
    assert s.pots == 2 and s.buttons == 2
    assert s.hello() == "H orbit-controls-sim 1 P2 B2"
    s._next_btn = 0
    assert not any(ln.startswith("B") for _ in range(50) for ln in s.step())
