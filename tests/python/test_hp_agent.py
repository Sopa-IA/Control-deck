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


def test_config_env_overrides_file(tmp_path):
    f = tmp_path / "a.toml"
    f.write_text('hub_url = "ws://x:1/ws"\ntoken = "archivo"\n[apps]\nnav = ["firefox"]\n', encoding="utf-8")
    c = config.load(f, env={})
    assert c.hub_url == "ws://x:1/ws" and c.token == "archivo" and c.apps == {"nav": ["firefox"]}
    c = config.load(f, env={"ORBIT_HP_TOKEN": "entorno", "ORBIT_HUB_URL": "ws://y:2/ws"})
    assert c.token == "entorno" and c.hub_url == "ws://y:2/ws"
    assert config.load(tmp_path / "no.toml", env={}).token is None
