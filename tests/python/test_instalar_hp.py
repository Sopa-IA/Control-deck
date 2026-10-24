"""El instalador de Windows es un .ps1: aquí se comprueba el texto y el lector del token."""
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts" / "instalar-hp.ps1"
TOKEN = "abcDEF_0123456789-orbit"


def _texto() -> str:
    return SCRIPT.read_text(encoding="utf-8-sig")


def _lector() -> str:
    text = _texto()
    marca = "$OrbitTokenPy = @'\n"
    i = text.index(marca) + len(marca)
    j = text.index("\n'@", i)
    return text[i:j]


def test_el_script_existe_y_es_utf8_con_bom():
    raw = SCRIPT.read_bytes()
    assert raw.startswith(b"\xef\xbb\xbf")


def test_una_linea_winget_zip_venv_y_tarea():
    t = _texto()
    assert "Python.Python.3.12" in t
    assert "https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe" in t
    assert "$Rama = 'cursor/bandeja-v2-modular-6d15'" in t
    assert "archive/refs/heads/$Rama.zip" in t
    assert r"C:\Orbit\Control-deck" in t
    assert r"software\shared\python" in t
    assert r"software\hp-agent" in t
    assert r".venv\Scripts\python.exe" in t
    assert r".venv\Scripts\pythonw.exe" in t
    assert "ws://10.0.0.2:8765/ws" in t
    assert "$PiUser = 'orbit'" in t
    assert "$PiHost = '10.0.0.2'" in t
    assert 'Path("/home/orbit/Control-deck/.env")' in t
    assert "OrbitHpAgent" in t
    assert "RestartOnFailure" in t
    assert "PT0S" in t
    assert "ExecutionTimeLimit" in t
    assert "[switch]$DryRun" in t
    assert "[switch]$Live" not in t
    assert "[switch]$Desinstalar" in t
    assert "$flag = 'false'" in t
    assert "EnVivo $enVivo" in t
    assert "-m hp_agent --live" in t
    assert "<Arguments>-m hp_agent</Arguments>" not in t
    assert "<Arguments>$(Esc $Argumentos)</Arguments>" in t
    assert "StrictHostKeyChecking=accept-new" in t
    assert "RedirectStandardOutput = $true" in t
    assert "instalar-hp.ps1 -Desinstalar" in t
    assert "pycaw>=20230615" in t
    assert "comtypes>=1.2" in t


def test_no_imprime_el_token():
    t = _texto()
    for prohibido in ("Write-Host $token", "Write-Host $leido", "Write-Host $raw", "echo $token", "Write-Output $token"):
        assert prohibido not in t
    # El valor solo se escribe al toml y se lee de la tubería de ssh.
    assert "WriteAllText($Path, $cuerpo" in t
    assert "StandardOutput.ReadToEnd()" in t


def test_lector_de_token_sin_mostrarlo_en_stderr(tmp_path: Path):
    envf = tmp_path / ".env"
    envf.write_text(
        'ORBIT_UI_TOKEN=otro-secreto\nORBIT_HP_TOKEN="abcDEF_0123456789-orbit"\n',
        encoding="utf-8",
    )
    proc = subprocess.run(
        [sys.executable, "-c", _lector()],
        env={**os.environ, "ORBIT_ENV_DIR": str(envf)},
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 0
    assert proc.stdout == TOKEN
    assert TOKEN not in proc.stderr
    assert "otro-secreto" not in proc.stdout


def test_lector_vacio_no_escribe_el_valor(tmp_path: Path):
    envf = tmp_path / ".env"
    envf.write_text("ORBIT_HP_TOKEN=\n# ORBIT_HP_TOKEN=no-esta-activo\n", encoding="utf-8")
    proc = subprocess.run(
        [sys.executable, "-c", _lector()],
        env={**os.environ, "ORBIT_ENV_DIR": str(envf)},
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 1
    assert proc.stdout == ""
    assert "sin-token" in proc.stderr
