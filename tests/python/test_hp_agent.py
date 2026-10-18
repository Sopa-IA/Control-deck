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


def test_config_env_overrides_file(tmp_path):
    f = tmp_path / "a.toml"
    f.write_text('hub_url = "ws://x:1/ws"\ntoken = "archivo"\n[apps]\nnav = ["firefox"]\n', encoding="utf-8")
    c = config.load(f, env={})
    assert c.hub_url == "ws://x:1/ws" and c.token == "archivo" and c.apps == {"nav": ["firefox"]}
    c = config.load(f, env={"ORBIT_HP_TOKEN": "entorno", "ORBIT_HUB_URL": "ws://y:2/ws"})
    assert c.token == "entorno" and c.hub_url == "ws://y:2/ws"
    assert config.load(tmp_path / "no.toml", env={}).token is None
