"""Ardu Lab no sube al Nano de mandos y no identifica las placas por ttyUSB."""
import json
import os

import pytest

from orbitd.ardu_lab import ArduLab, FQBN_OLD, parse_errors


class DummySerial:
    def __init__(self, chunks):
        self.chunks = list(chunks)
        self.closed = False

    def readline(self):
        if self.closed:
            return b""
        if self.chunks:
            return self.chunks.pop(0)
        return b""

    def close(self):
        self.closed = True


def _tree(tmp):
    mandos = tmp / "nodo-mandos"
    practicas = tmp / "nodo-practicas"
    mandos.write_text("m")
    practicas.write_text("p")
    by = tmp / "by-path"
    by.mkdir()
    (by / "usb-mandos").symlink_to(mandos)
    (by / "usb-practicas").symlink_to(practicas)
    return by


def _lab(tmp, by, mandos="usb-mandos", practicas="usb-practicas", runner=None, opener=None, serial=""):
    cfg = tmp / "arduino-puertos.json"
    cfg.write_text(json.dumps({"mandos": mandos, "practicas": practicas}), encoding="utf-8")
    return ArduLab(cfg, tmp / "sketches", by, cli="/no/existe/arduino-cli", fqbn=FQBN_OLD,
                   serial_fallback=serial, opener=opener, runner=runner)


def test_parse_errors_marca_la_linea():
    text = "/tmp/Blink/Blink.ino:4:1: error: expected ';' before '}' token\n"
    assert parse_errors(text) == [{"line": 4, "col": 1, "message": "expected ';' before '}' token"}]


def test_puertos_marcan_mandos_bloqueado(tmp_path):
    by = _tree(tmp_path)
    lab = _lab(tmp_path, by)
    res = lab.ports_result()
    rows = {r["by_path"]: r for r in json.loads(res["output"])["ports"]}
    assert rows["usb-mandos"]["role"] == "mandos" and rows["usb-mandos"]["blocked"] is True
    assert rows["usb-practicas"]["role"] == "practicas" and rows["usb-practicas"]["blocked"] is False
    assert "ttyUSB" not in res["message"]


def test_no_sube_si_practicas_es_el_de_mandos(tmp_path):
    by = _tree(tmp_path)
    called = []
    lab = _lab(tmp_path, by, practicas="usb-mandos", runner=lambda args: called.append(args) or (0, "ok"))
    res = lab.upload_result("Blink")
    assert res["ok"] is False and res["dry_run"] is True
    assert "bloqueado" in res["message"]
    assert called == []


def test_no_sube_si_los_dos_enlaces_son_el_mismo_dispositivo(tmp_path):
    nodo = tmp_path / "unico"
    nodo.write_text("x")
    by = tmp_path / "by-path"
    by.mkdir()
    (by / "usb-mandos").symlink_to(nodo)
    (by / "usb-practicas").symlink_to(nodo)
    called = []
    lab = _lab(tmp_path, by, runner=lambda args: called.append(args) or (0, "ok"))
    res = lab.upload_result("Blink")
    assert res["ok"] is False and called == []
    assert "mandos" in res["message"]


def test_no_sube_al_puerto_que_orbitd_ya_tiene_abierto(tmp_path):
    by = _tree(tmp_path)
    practicas = os.path.realpath(by / "usb-practicas")
    called = []
    lab = _lab(tmp_path, by, serial=practicas, runner=lambda args: called.append(args) or (0, "ok"))
    res = lab.upload_result("Blink", extra=[practicas])
    assert res["ok"] is False and called == []


def test_compila_con_el_bootloader_viejo_y_sube_solo_a_practicas(tmp_path):
    by = _tree(tmp_path)
    calls = []

    def runner(args):
        calls.append(args)
        if args[0] == "compile":
            return 0, "Sketch uses 1000 bytes"
        return 0, "New upload port"

    lab = _lab(tmp_path, by, runner=runner)
    assert lab.sketch_result("guardar", "Blink", "void setup(){}\nvoid loop(){}\n")["ok"]
    res = lab.upload_result("Blink")
    assert res["ok"] is True
    assert calls[0][:3] == ["compile", "--fqbn", FQBN_OLD]
    assert calls[1][0] == "upload" and calls[1][1] == "-p"
    assert calls[1][2].endswith("usb-practicas")
    assert "usb-mandos" not in calls[1][2]
    assert "mandos no se ha tocado" in res["message"]


def test_compile_sin_cli_no_toca_ninguna_placa(tmp_path):
    by = _tree(tmp_path)
    lab = _lab(tmp_path, by, runner=None)
    lab.cli = "/no/existe/arduino-cli"
    lab.sketch_result("guardar", "Blink", "void setup(){}\nvoid loop(){}\n")
    res = lab.compile_result("Blink")
    assert res["ok"] is False and res["dry_run"] is True
    assert "arduino-cli" in res["message"]


def test_compile_devuelve_el_error_de_linea(tmp_path):
    by = _tree(tmp_path)

    def runner(args):
        return 1, "Blink.ino:2:3: error: 'led' was not declared in this scope\n"

    lab = _lab(tmp_path, by, runner=runner)
    lab.sketch_result("guardar", "Blink", "void setup(){ led }\n")
    res = lab.compile_result("Blink")
    assert res["ok"] is False and "línea 2" in res["message"]
    assert parse_errors(res["output"])[0]["line"] == 2


def test_el_nombre_no_sale_del_directorio(tmp_path):
    by = _tree(tmp_path)
    lab = _lab(tmp_path, by, runner=lambda args: (0, ""))
    res = lab.sketch_result("guardar", "../Blink", "void setup(){}")
    assert res["ok"] is False
    assert not (tmp_path / "Blink.ino").exists()


def test_monitor_abre_practicas_y_no_mandos(tmp_path):
    by = _tree(tmp_path)
    opened = []

    def opener(path, baud):
        opened.append((path, baud))
        return DummySerial([b"A0 512\n", b"A1 200\n"])

    lab = _lab(tmp_path, by, opener=opener)
    denied = lab.monitor_result("abrir", 9600, extra=[os.path.realpath(by / "usb-mandos")])
    assert denied["ok"] is True
    assert opened[0][0].endswith("usb-practicas") and opened[0][1] == 9600
    import time
    time.sleep(0.05)
    got = lab.monitor_result("leer", 9600)
    assert "A0 512" in got["output"]
    lab.monitor_result("cerrar", 9600)
    assert lab.monitor.path == ""


def test_monitor_no_abre_si_practicas_no_esta_configurado(tmp_path):
    by = _tree(tmp_path)
    opened = []
    lab = _lab(tmp_path, by, practicas="", opener=lambda path, baud: opened.append(path))
    res = lab.monitor_result("abrir", 115200)
    assert res["ok"] is False and opened == []
    assert "No se sube nada" in res["message"] or "prácticas" in res["message"]


def test_accion_de_subida_por_el_hub_rechaza_mandos(tmp_path):
    pytest.importorskip("aiohttp")
    import asyncio
    import aiohttp
    from aiohttp.test_utils import TestServer

    import orbit_protocol as P
    from orbitd.hub import Config, build_app

    by = _tree(tmp_path)
    cfg_file = tmp_path / "arduino-puertos.json"
    cfg_file.write_text(json.dumps({"mandos": "usb-mandos", "practicas": "usb-mandos"}), encoding="utf-8")
    cfg = Config(state_dir=tmp_path, hp_token="token-de-prueba-0123456789", telemetry_period_s=30,
                 ardu_ports_file=cfg_file, ardu_sketch_dir=tmp_path / "sketches", ardu_by_path=by,
                 ardu_cli="/no/existe/arduino-cli")

    async def scene():
        srv = TestServer(build_app(cfg))
        await srv.start_server()
        try:
            async with aiohttp.ClientSession() as s:
                ws = await s.ws_connect(srv.make_url("/ws"))
                await ws.send_str(json.dumps(P.make("hello", "ui", {"role": "ui", "client": "test", "version": "0"})))
                await ws.send_str(json.dumps(P.make("action_request", "ui", {
                    "action": "pi.ardu_upload", "params": {"sketch": "Blink"}})))
                while True:
                    raw = await ws.receive(timeout=3)
                    msg = P.parse(raw.data)
                    if msg["type"] == "action_result":
                        return msg
        finally:
            await srv.close()

    msg = asyncio.run(scene())
    assert msg["payload"]["ok"] is False
    assert "bloqueado" in msg["payload"]["message"]
