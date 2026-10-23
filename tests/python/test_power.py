"""Apagado de la Pi: orden fija, y el simulador o un PC no llegan a systemctl."""
import subprocess

from orbitd.power import argv_for, default_runner, power_allowed, read_device_model, run_power


def test_argv_es_fijo():
    assert argv_for("pi.shutdown") == ["sudo", "-n", "/usr/bin/systemctl", "poweroff"]
    assert argv_for("pi.restart") == ["sudo", "-n", "/usr/bin/systemctl", "reboot"]
    assert argv_for("hp.shutdown") is None


def test_solo_en_una_pi_y_fuera_de_simulacion():
    pi = "Raspberry Pi 4 Model B Rev 1.5"
    assert power_allowed(sim=False, power_live=True, model=pi) is True
    assert power_allowed(sim=True, power_live=True, model=pi) is False
    assert power_allowed(sim=False, power_live=False, model=pi) is False
    assert power_allowed(sim=False, power_live=True, model="QEMU") is False
    assert power_allowed(sim=False, power_live=True, model="") is False


def test_modelo_vacio_si_no_hay_device_tree(tmp_path):
    assert read_device_model(tmp_path / "no-esta") == ""
    p = tmp_path / "model"
    p.write_bytes(b"Raspberry Pi 4 Model B\x00\xff")
    assert read_device_model(p) == "Raspberry Pi 4 Model B"


def test_sim_y_pc_no_llaman_al_runner():
    calls = []

    def runner(argv):
        calls.append(argv)
        return 0

    sim = run_power("pi.shutdown", live=False, sim=True, runner=runner)
    assert sim["dry_run"] is True and sim["simulated"] is True and "SIMULADO" in sim["message"]
    dev = run_power("pi.restart", live=False, sim=False, runner=runner)
    assert dev["dry_run"] is True and calls == []


def test_en_vivo_usa_la_orden_fija():
    calls = []
    r = run_power("pi.shutdown", live=True, sim=False, runner=lambda argv: calls.append(list(argv)) or 0)
    assert r["ok"] is True and r["dry_run"] is False
    assert calls == [["sudo", "-n", "/usr/bin/systemctl", "poweroff"]]
    malo = run_power("pi.restart", live=True, sim=False, runner=lambda argv: 1)
    assert malo["ok"] is False and "sudoers" in malo["message"]


def test_sin_permiso_de_ejecucion_no_hay_subprocess(monkeypatch):
    def boom(*_a, **_k):
        raise AssertionError("systemctl no debe ejecutarse")

    monkeypatch.setattr(subprocess, "run", boom)
    monkeypatch.delenv("ORBIT_POWER_ALLOW_EXEC", raising=False)
    r = run_power("pi.shutdown", live=True, sim=False)
    assert r["dry_run"] is True and r["ok"] is True
    monkeypatch.setenv("ORBIT_POWER_ALLOW_EXEC", "1")
    monkeypatch.setattr(subprocess, "run", lambda argv, check=False: subprocess.CompletedProcess(argv, 0))
    ok = default_runner(["sudo", "-n", "/usr/bin/systemctl", "poweroff"])
    assert ok == 0
