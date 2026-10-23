"""Pruebas de integración de orbitd (servidor real en memoria) con interfaz y hp-agent simulados por el test."""
import asyncio
import json

import aiohttp
import pytest
from aiohttp.test_utils import TestServer

import orbit_protocol as P
from hp_agent.agent import run_once
from hp_agent.config import AgentConfig
from orbitd.hub import HUB_KEY, Config, build_app

TOKEN = "token-de-prueba-0123456789"


@pytest.fixture
async def server(tmp_path):
    cfg = Config(state_dir=tmp_path, hp_token=TOKEN, telemetry_period_s=30)
    srv = TestServer(build_app(cfg))
    await srv.start_server()
    yield srv
    await srv.close()


@pytest.fixture
async def sim_server(tmp_path):
    cfg = Config(state_dir=tmp_path, hp_token=TOKEN, sim_hp=True, telemetry_period_s=30)
    srv = TestServer(build_app(cfg))
    await srv.start_server()
    yield srv
    await srv.close()


async def connect(session, srv, role="ui", token=None):
    ws = await session.ws_connect(srv.make_url("/ws"))
    payload = {"role": role, "client": "test", "version": "0"}
    if token is not None:
        payload["token"] = token
    await ws.send_str(json.dumps(P.make("hello", "hp" if role == "hp-agent" else "ui", payload)))
    return ws


async def recv(ws, type_, timeout=3):
    while True:
        m = await ws.receive(timeout=timeout)
        if m.type != aiohttp.WSMsgType.TEXT:
            raise AssertionError(f"conexión cerrada esperando {type_}")
        msg = P.parse(m.data)
        if msg["type"] == type_:
            return msg


async def send(ws, type_, payload, src="ui"):
    m = P.make(type_, src, payload)
    await ws.send_str(json.dumps(m))
    return m


async def test_ui_handshake_state_mapping(server):
    async with aiohttp.ClientSession() as s:
        ws = await connect(s, server)
        w = await recv(ws, "welcome")
        assert w["payload"]["mode"] == "real"
        st = await recv(ws, "state")
        assert st["payload"]["hp"]["connected"] is False and st["payload"]["video_input"] == "pi"
        assert st["payload"]["visible"]["system"] == "pi" and st["payload"]["visible"]["mode"] == "remoto"
        mp = await recv(ws, "mapping")
        assert mp["payload"]["pots"]["P1"] == "hp.volume_set"
        tel = await recv(ws, "telemetry")
        assert tel["payload"]["host"] == "pi" and tel["payload"]["simulated"] is False


async def test_first_message_must_be_hello(server):
    async with aiohttp.ClientSession() as s:
        ws = await s.ws_connect(server.make_url("/ws"))
        await ws.send_str(json.dumps(P.make("ping", "ui", {"seq": 1})))
        err = await recv(ws, "error")
        assert err["payload"]["code"] == "auth_failed"


@pytest.mark.parametrize("token", [None, "", "malo"])
async def test_hp_agent_bad_token_rejected(server, token):
    async with aiohttp.ClientSession() as s:
        ws = await connect(s, server, role="hp-agent", token=token)
        err = await recv(ws, "error")
        assert err["payload"]["code"] == "auth_failed"
        m = await ws.receive(timeout=3)
        assert m.type in (aiohttp.WSMsgType.CLOSE, aiohttp.WSMsgType.CLOSED, aiohttp.WSMsgType.CLOSING)


async def test_not_whitelisted_and_bad_params(server):
    async with aiohttp.ClientSession() as s:
        ws = await connect(s, server)
        await recv(ws, "welcome")
        await send(ws, "action_request", {"action": "hp.exec_cmd", "params": {"cmd": "format c:"}})
        assert (await recv(ws, "error"))["payload"]["code"] == "not_allowed"
        await send(ws, "action_request", {"action": "hp.volume_set", "params": {"level": 500}})
        assert (await recv(ws, "error"))["payload"]["code"] == "bad_params"
        await send(ws, "action_request", {"action": "hp.ping"})
        assert (await recv(ws, "error"))["payload"]["code"] == "target_offline"


async def test_full_flow_with_hp_agent_and_safe_shutdown(server):
    async with aiohttp.ClientSession() as s:
        hp = await connect(s, server, role="hp-agent", token=TOKEN)
        await recv(hp, "welcome")
        ui = await connect(s, server)
        await recv(ui, "welcome")
        st = await recv(ui, "state")
        assert st["payload"]["hp"]["connected"] and not st["payload"]["hp"]["simulated"]

        # telemetría HP -> interfaz
        await send(hp, "telemetry", {"host": "hp", "simulated": False, "cpu_pct": 12.5, "mem_pct": 30}, src="hp")
        tel = await recv(ui, "telemetry")
        while tel["payload"]["host"] != "hp":
            tel = await recv(ui, "telemetry")
        assert tel["payload"]["cpu_pct"] == 12.5

        # acción destructiva: requiere confirmación
        await send(ui, "action_request", {"action": "hp.shutdown"})
        cr = await recv(ui, "confirm_required")
        rid, ch = cr["payload"]["request_id"], cr["payload"]["challenge"]
        await send(ui, "action_confirm", {"request_id": rid, "challenge": "0" * 16})
        assert (await recv(ui, "error"))["payload"]["code"] == "confirm_expired"
        # desafío de un solo uso: hay que pedir otro
        await send(ui, "action_request", {"action": "hp.shutdown"})
        cr = await recv(ui, "confirm_required")
        await send(ui, "action_confirm", {"request_id": cr["payload"]["request_id"], "challenge": cr["payload"]["challenge"]})
        fwd = await recv(hp, "action")
        assert fwd["payload"]["action"] == "hp.shutdown"
        res = P.make("action_result", "hp", {"action": "hp.shutdown", "ok": True, "dry_run": True, "message": "DRY-RUN"}, fwd["id"])
        await hp.send_str(json.dumps(res))
        r = await recv(ui, "action_result")
        assert r["payload"]["dry_run"] is True and r["payload"]["action"] == "hp.shutdown"
        assert rid != cr["payload"]["request_id"] and ch


async def test_switch_visible_modo_remoto_sin_visor(server):
    # Sin ORBIT_REMOTE_CMD ni DDC/CI: el cambio se registra (dry_run) y el estado indica HP visible en modo remoto.
    async with aiohttp.ClientSession() as s:
        ws = await connect(s, server)
        await recv(ws, "welcome")
        await recv(ws, "state")
        await send(ws, "action_request", {"action": "pi.switch_visible"})
        st = await recv(ws, "state")
        assert st["payload"]["visible"]["system"] == "hp" and st["payload"]["visible"]["mode"] == "remoto"
        r = await recv(ws, "action_result")
        assert r["payload"]["ok"] is True and r["payload"]["dry_run"] is True


async def test_sim_hp_results_are_flagged(sim_server):
    async with aiohttp.ClientSession() as s:
        ui = await connect(s, sim_server)
        w = await recv(ui, "welcome")
        assert w["payload"]["mode"] == "mixto"
        st = await recv(ui, "state")
        assert st["payload"]["hp"]["simulated"] is True
        tel = await recv(ui, "telemetry")
        while tel["payload"]["host"] != "hp":
            tel = await recv(ui, "telemetry")
        assert tel["payload"]["simulated"] is True
        await send(ui, "action_request", {"action": "hp.lock_screen"})
        r = await recv(ui, "action_result")
        assert r["payload"]["simulated"] is True and r["payload"]["message"].startswith("SIMULADO")


async def test_mapping_set_and_serial_to_volume(server):
    async with aiohttp.ClientSession() as s:
        hp = await connect(s, server, role="hp-agent", token=TOKEN)
        await recv(hp, "welcome")
        ui = await connect(s, server)
        await recv(ui, "welcome")
        await send(ui, "mapping_set", {"pots": {"P1": "ui.select"}, "buttons": {}})
        assert (await recv(ui, "error"))["payload"]["code"] == "bad_params"
        await send(ui, "mapping_set", {"pots": {"P1": "hp.volume_set"}, "buttons": {"B1": "hp.volume_mute"}})
        assert (await recv(ui, "mapping"))["payload"]["buttons"]["B1"] == "hp.volume_mute"
        hub = server.app[HUB_KEY]
        await hub.on_serial_line("P1 1023\n")
        ev = await recv(ui, "control_event")
        assert ev["payload"] == {"control": "P1", "kind": "pot", "value": 1023, "simulated": False}
        fwd = await recv(hp, "action")
        assert fwd["payload"] == {"action": "hp.volume_set", "params": {"level": 100}}
        await hub.on_serial_line("B1 1\n")
        fwd = await recv(hp, "action")
        assert fwd["payload"]["action"] == "hp.volume_mute"


async def test_real_hp_agent_client_dry_run(server):
    """hp-agent real (run_once) contra orbitd: hp.lock_screen vuelve en DRY-RUN."""
    cfg = AgentConfig(hub_url=str(server.make_url("/ws")), token=TOKEN, telemetry_period_s=0.2, live=False)
    agent = asyncio.ensure_future(run_once(cfg))
    try:
        async with aiohttp.ClientSession() as s:
            ui = await connect(s, server)
            await recv(ui, "welcome")
            for _ in range(50):
                if server.app[HUB_KEY].hp is not None:
                    break
                await asyncio.sleep(0.05)
            tel = await recv(ui, "telemetry")
            while tel["payload"]["host"] != "hp":
                tel = await recv(ui, "telemetry")
            assert tel["payload"]["simulated"] is False
            await send(ui, "action_request", {"action": "hp.lock_screen"})
            r = await recv(ui, "action_result")
            assert r["payload"]["ok"] and r["payload"]["dry_run"] and r["payload"]["message"].startswith("DRY-RUN")
    finally:
        agent.cancel()


async def test_ui_gets_last_pot_values_on_connect(server):
    await server.app[HUB_KEY].on_serial_line("P2 300")
    async with aiohttp.ClientSession() as s:
        ui = await connect(s, server)
        ev = await recv(ui, "control_event")
        assert ev["payload"]["control"] == "P2" and ev["payload"]["value"] == 300


async def test_switch_visible_modo_captura(tmp_path, monkeypatch):
    # Modo C configurado en local (dispositivo simulado por el test): el estado indica «captura»
    # y la entrada física de la MSI sigue siendo la Pi.
    import sys

    from orbitd.video import VideoConfig
    monkeypatch.setattr("orbitd.video.os.path.exists", lambda p: p == "/dev/video0")
    cfg = Config(state_dir=tmp_path, hp_token=TOKEN, telemetry_period_s=30,
                 video=VideoConfig(capture_device="/dev/video0",
                                   capture_cmd=[sys.executable, "-c", "import time; time.sleep(30)", "{device}"]))
    srv = TestServer(build_app(cfg))
    await srv.start_server()
    try:
        async with aiohttp.ClientSession() as s:
            ws = await connect(s, srv)
            await recv(ws, "welcome")
            await recv(ws, "state")
            await send(ws, "action_request", {"action": "pi.switch_visible"})
            st = await recv(ws, "state")
            assert st["payload"]["visible"]["system"] == "hp" and st["payload"]["visible"]["mode"] == "captura"
            assert st["payload"]["video_input"] == "pi"
            r = await recv(ws, "action_result")
            assert r["payload"]["ok"] is True and r["payload"]["dry_run"] is False
    finally:
        await srv.close()


def _power_cfg(tmp_path, **kw):
    calls = []

    def runner(argv):
        calls.append(list(argv))
        return 0

    cfg = Config(state_dir=tmp_path, hp_token=TOKEN, telemetry_period_s=30, power_runner=runner, **kw)
    return cfg, calls


async def _confirm(srv, action):
    async with aiohttp.ClientSession() as s:
        ui = await connect(s, srv)
        await recv(ui, "welcome")
        await send(ui, "action_request", {"action": action})
        cr = await recv(ui, "confirm_required")
        await send(ui, "action_confirm", {
            "request_id": cr["payload"]["request_id"], "challenge": cr["payload"]["challenge"],
        })
        return await recv(ui, "action_result")


async def test_pi_shutdown_en_simulacion_no_apaga(tmp_path):
    cfg, calls = _power_cfg(tmp_path, sim_hp=True, sim_controls=True, power_live=True,
                            device_model="Raspberry Pi 4 Model B Rev 1.5")
    srv = TestServer(build_app(cfg))
    await srv.start_server()
    try:
        r = await _confirm(srv, "pi.shutdown")
        assert r["payload"]["dry_run"] is True and r["payload"]["simulated"] is True
        assert "SIMULADO" in r["payload"]["message"]
        assert calls == []
    finally:
        await srv.close()


async def test_pi_restart_en_pc_no_llama_a_systemctl(tmp_path):
    cfg, calls = _power_cfg(tmp_path, power_live=True, device_model="QEMU")
    srv = TestServer(build_app(cfg))
    await srv.start_server()
    try:
        r = await _confirm(srv, "pi.restart")
        assert r["payload"]["dry_run"] is True and calls == []
    finally:
        await srv.close()


async def test_pi_shutdown_en_la_pi_usa_sudo_fijo(tmp_path):
    cfg, calls = _power_cfg(tmp_path, power_live=True, device_model="Raspberry Pi 4 Model B Rev 1.5")
    srv = TestServer(build_app(cfg))
    await srv.start_server()
    try:
        off = await _confirm(srv, "pi.shutdown")
        assert off["payload"]["ok"] is True and off["payload"]["dry_run"] is False
        assert calls == [["sudo", "-n", "/usr/bin/systemctl", "poweroff"]]
    finally:
        await srv.close()


async def test_boton_corto_no_apaga_y_mantener_pide_confirmacion(tmp_path):
    cfg, calls = _power_cfg(tmp_path, power_live=True, device_model="Raspberry Pi 4 Model B Rev 1.5")
    srv = TestServer(build_app(cfg))
    await srv.start_server()
    try:
        async with aiohttp.ClientSession() as s:
            ui = await connect(s, srv)
            await recv(ui, "welcome")
            await send(ui, "mapping_set", {"pots": {}, "buttons": {"B1": "pi.shutdown", "B2": "pi.restart"}})
            mp = await recv(ui, "mapping")
            while mp["payload"]["buttons"].get("B1") != "pi.shutdown":
                mp = await recv(ui, "mapping")
            hub = srv.app[HUB_KEY]
            await hub.on_serial_line("B1 1\n")
            ev = await recv(ui, "control_event")
            assert ev["payload"]["event"] == "press"
            assert hub.pending_confirm == {} and calls == []
            await hub.on_serial_line("B2 L\n")
            cr = await recv(ui, "confirm_required")
            assert cr["payload"]["action"] == "pi.restart" and calls == []
            await send(ui, "action_confirm", {
                "request_id": cr["payload"]["request_id"], "challenge": cr["payload"]["challenge"],
            })
            r = await recv(ui, "action_result")
            assert r["payload"]["action"] == "pi.restart" and r["payload"]["dry_run"] is False
            assert calls == [["sudo", "-n", "/usr/bin/systemctl", "reboot"]]
    finally:
        await srv.close()


async def test_mantener_sin_interfaz_no_apaga(tmp_path):
    cfg, calls = _power_cfg(tmp_path, power_live=True, device_model="Raspberry Pi 4 Model B Rev 1.5")
    srv = TestServer(build_app(cfg))
    await srv.start_server()
    try:
        hub = srv.app[HUB_KEY]
        hub.mapping = {"version": 1, "pots": {}, "buttons": {"B1": "pi.shutdown"}}
        await hub.on_serial_line("B1 L\n")
        assert calls == [] and hub.pending_confirm == {}
    finally:
        await srv.close()
