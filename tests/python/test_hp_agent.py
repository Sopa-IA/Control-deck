import subprocess


from hp_agent import actions, config


def test_commands_windows_and_linux():
    assert actions.command_for("hp.shutdown", {}, "Windows", {}) == ["shutdown", "/s", "/t", "60"]
    assert actions.command_for("hp.shutdown", {}, "Linux", {}) == ["shutdown", "-h", "+1"]
    assert actions.command_for("hp.shutdown_cancel", {}, "Windows", {}) == ["shutdown", "/a"]
    assert actions.command_for("hp.volume_set", {"level": 30}, "Linux", {})[-1] == "30%"
    assert actions.command_for("hp.volume_set", {"level": 30}, "Windows", {}) is None  # PENDIENTE


def test_dry_run_never_executes(monkeypatch):
    def boom(*a, **k):
        raise AssertionError("no debe ejecutar nada en dry-run")
    monkeypatch.setattr(subprocess, "run", boom)
    monkeypatch.setattr(subprocess, "Popen", boom)
    for act, params in [("hp.shutdown", {}), ("hp.lock_screen", {}), ("hp.restart", {})]:
        r = actions.run_action(act, params, live=False, apps={}, system="Windows")
        assert r["ok"] and r["dry_run"] and r["message"].startswith("DRY-RUN")


def test_rejects_unlisted_and_unknown_app():
    r = actions.run_action("hp.format_disk", {}, live=True, apps={})
    assert not r["ok"] and "no permitida" in r["message"]
    r = actions.run_action("hp.open_app", {"app": "calc"}, live=True, apps={})
    assert not r["ok"] and "no configurada" in r["message"]
    r = actions.run_action("pi.shutdown", {}, live=True, apps={})
    assert not r["ok"]


def test_live_uses_argument_list(monkeypatch):
    seen = {}

    def fake_run(cmd, shell, **k):
        seen["cmd"], seen["shell"] = cmd, shell
        return subprocess.CompletedProcess(cmd, 0, "", "")
    monkeypatch.setattr(subprocess, "run", fake_run)
    r = actions.run_action("hp.shutdown", {}, live=True, apps={}, system="Linux")
    assert r["ok"] and not r["dry_run"] and seen == {"cmd": ["shutdown", "-h", "+1"], "shell": False}


def test_temperatura_ausente_no_rompe_la_telemetria(monkeypatch):
    import hp_agent.agent as agent

    def boom(*_a, **_k):
        raise NotImplementedError("sensors_temperatures")

    monkeypatch.setattr(agent.psutil, "sensors_temperatures", boom)
    data = agent.telemetry()
    assert data["temp_c"] is None
    assert data["host"] == "hp"
    assert isinstance(data["cpu_pct"], float)
    assert data["disk_pct"] >= 0


def test_modelo_pendiente_si_windows_no_tiene_registro(monkeypatch):
    import hp_agent.agent as agent

    monkeypatch.setattr(agent.platform, "system", lambda: "Windows")
    # En Linux no existe winreg: el agente no puede morir por eso.
    assert agent.machine_model() == "HP (modelo PENDIENTE)"


def test_config_live_desde_el_toml(tmp_path):
    f = tmp_path / "a.toml"
    f.write_text('hub_url = "ws://10.0.0.2:8765/ws"\ntoken = "t"\nlive = true\n', encoding="utf-8")
    assert config.load(f, env={}).live is True
    f.write_text('token = "t"\nlive = false\n', encoding="utf-8")
    assert config.load(f, env={}).live is False
    f.write_text('token = "t"\nlive = "si"\n', encoding="utf-8")
    assert config.load(f, env={}).live is True
    f.write_text('token = "t"\n', encoding="utf-8")
    assert config.load(f, env={}).live is False


def test_cli_live_solo_enciende(tmp_path, monkeypatch):
    import logging

    f = tmp_path / "a.toml"
    f.write_text('token = "token-de-prueba-cli-0123456789"\nlive = false\n', encoding="utf-8")
    visto = {}

    async def falso(cfg):
        visto["live"] = cfg.live

    monkeypatch.setattr("hp_agent.__main__.run_forever", falso)
    from hp_agent.__main__ import _Redact, main

    try:
        main(["--config", str(f)])
        assert visto["live"] is False
        main(["--config", str(f), "--live"])
        assert visto["live"] is True
    finally:
        raiz = logging.getLogger()
        raiz.filters = [flt for flt in raiz.filters if not isinstance(flt, _Redact)]


def test_el_log_no_repite_el_token():
    import logging

    from hp_agent.__main__ import _Redact

    registro = logging.getLogger("test.hp.redact")
    registro.addFilter(_Redact("secreto-largo-de-prueba"))
    registro.setLevel(logging.INFO)
    encontrado = []

    class _Coge(logging.Handler):
        def emit(self, record):
            encontrado.append(record.getMessage())

    registro.addHandler(_Coge())
    try:
        registro.info("conectado token %s", "secreto-largo-de-prueba")
    finally:
        registro.handlers.clear()
        registro.filters.clear()
    assert encontrado == ["conectado token ***"]


class _Contadores:
    def __init__(self, sent, recv):
        self.bytes_sent = sent
        self.bytes_recv = recv


def _fija_red(monkeypatch, muestras, tiempos):
    import hp_agent.agent as agent

    agent._last_net = None
    cursor = {"i": 0}

    def falso(*, pernic=False):
        i = min(cursor["i"], len(muestras) - 1)
        cursor["i"] += 1
        return muestras[i]

    reloj = {"i": 0}

    def ahora():
        i = min(reloj["i"], len(tiempos) - 1)
        reloj["i"] += 1
        return tiempos[i]

    monkeypatch.setattr(agent.psutil, "net_io_counters", falso)
    monkeypatch.setattr(agent.time, "monotonic", ahora)
    return agent


def test_la_red_suma_wifi_y_ethernet_y_omite_loopback_y_virtual(monkeypatch):
    import orbit_protocol as P

    # Wi-Fi RTL8723BE (internet) y Ethernet hacia la Pi. El virtual y el loopback no entran.
    cero = {
        "Wi-Fi": _Contadores(0, 0),
        "Ethernet": _Contadores(0, 0),
        "Loopback Pseudo-Interface 1": _Contadores(10**12, 10**12),
        "Virtual Display Driver": _Contadores(10**12, 10**12),
        "VirtualDisplayDriver": _Contadores(10**12, 10**12),
    }
    luego = {
        "Wi-Fi": _Contadores(1000, 2000),
        "Ethernet": _Contadores(3000, 5000),
        "Loopback Pseudo-Interface 1": _Contadores(10**12 + 9_000_000, 10**12),
        "Virtual Display Driver": _Contadores(10**12 + 8_000_000, 10**12),
        "VirtualDisplayDriver": _Contadores(10**12 + 7_000_000, 10**12),
    }
    agent = _fija_red(monkeypatch, [cero, luego], [100.0, 102.0])
    primera = agent.telemetry()
    assert primera["net_up_kbps"] == 0.0
    assert primera["net_down_kbps"] == 0.0
    segunda = agent.telemetry()
    # 4000 B enviados y 7000 B recibidos en 2 s → kb/s como en la Pi (× 8 / 1000 / dt).
    assert segunda["net_up_kbps"] == 16.0
    assert segunda["net_down_kbps"] == 28.0
    P.make("telemetry", "hp", segunda)


def test_si_no_hay_contadores_por_interfaz_usa_el_total(monkeypatch):
    import hp_agent.agent as agent

    agent._last_net = None
    muestras = [_Contadores(0, 0), _Contadores(125_000, 250_000)]
    i = {"n": 0}

    def falso(*, pernic=False):
        if pernic:
            raise NotImplementedError("pernic")
        v = muestras[min(i["n"], 1)]
        i["n"] += 1
        return v

    tiempos = iter([10.0, 11.0])
    monkeypatch.setattr(agent.psutil, "net_io_counters", falso)
    monkeypatch.setattr(agent.time, "monotonic", lambda: next(tiempos))
    assert agent.telemetry()["net_down_kbps"] == 0.0
    dato = agent.telemetry()
    # 125000 B y 250000 B en 1 s → kb/s como en la Pi (× 8 / 1000).
    assert dato["net_up_kbps"] == 1000.0
    assert dato["net_down_kbps"] == 2000.0


def test_un_contador_que_retrocede_no_sale_negativo(monkeypatch):
    agent = _fija_red(
        monkeypatch,
        [{"Ethernet": _Contadores(5_000, 9_000)}, {"Ethernet": _Contadores(100, 50)}],
        [1.0, 3.0],
    )
    assert agent._net_kbps() == (0.0, 0.0)
    assert agent._net_kbps() == (0.0, 0.0)


def test_config_env_overrides_file(tmp_path):
    f = tmp_path / "a.toml"
    f.write_text('hub_url = "ws://x:1/ws"\ntoken = "archivo"\n[apps]\nnav = ["firefox"]\n', encoding="utf-8")
    c = config.load(f, env={})
    assert c.hub_url == "ws://x:1/ws" and c.token == "archivo" and c.apps == {"nav": ["firefox"]}
    c = config.load(f, env={"ORBIT_HP_TOKEN": "entorno", "ORBIT_HUB_URL": "ws://y:2/ws"})
    assert c.token == "entorno" and c.hub_url == "ws://y:2/ws"
    assert config.load(tmp_path / "no.toml", env={}).token is None
