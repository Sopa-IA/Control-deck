"""Ardu Lab: compilar y subir solo al Nano de prácticas.

La identidad de cada placa es el basename de ``/dev/serial/by-path`` (el puerto
USB físico). ``ttyUSB`` cambia de número si se enchufa otra placa y no se usa
para decidir. El Nano de mandos, el que orbitd tiene abierto, queda bloqueado.
"""
from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import threading
from collections import deque
from pathlib import Path

FQBN_OLD = "arduino:avr:nano:cpu=atmega328old"
BAUDS = (9600, 19200, 38400, 57600, 115200)
SKETCH_RE = re.compile(r"^[A-Za-z][A-Za-z0-9_]{0,31}$")
FQBN_RE = re.compile(r"^[A-Za-z0-9:.=,_-]{1,80}$")
ERROR_RE = re.compile(r":(\d+):(\d+):\s*(?:fatal\s+)?error:\s*(.+)$", re.IGNORECASE)
OUTPUT_MAX = 8000
SOURCE_MAX = 24000


def parse_errors(text: str) -> list[dict]:
    """Líneas de arduino-cli con ``archivo.ino:linea:columna: error:``."""
    found = []
    for line in text.splitlines():
        m = ERROR_RE.search(line.strip())
        if not m:
            continue
        found.append({"line": int(m.group(1)), "col": int(m.group(2)), "message": m.group(3).strip()[:240]})
    return found


def clip_output(text: str, limit: int = OUTPUT_MAX) -> str:
    if len(text) <= limit:
        return text
    errors = [ln for ln in text.splitlines() if "error:" in ln.lower()]
    head = "\n".join(errors)
    room = limit - len(head) - 8
    tail = text[-room:] if room > 0 else ""
    return f"{head}\n...\n{tail}"[:limit]


def _res(action: str, ok: bool, message: str, output: str = "", dry: bool = False) -> dict:
    out = {"action": action, "ok": ok, "dry_run": dry, "simulated": False, "message": message[:500]}
    if output:
        out["output"] = clip_output(output)
    return out


def _basename(value: object) -> str:
    if not isinstance(value, str):
        return ""
    name = Path(value.strip()).name
    if not name or name in {".", ".."} or "/" in name or len(name) > 200:
        return ""
    return name


def read_ports(path: Path) -> tuple[str, str]:
    """Devuelve (mandos, practicas), basenames de by-path. Vacío si no hay ficha."""
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, UnicodeError):
        return "", ""
    if not isinstance(data, dict):
        return "", ""
    return _basename(data.get("mandos")), _basename(data.get("practicas"))


def _realpath(path: str) -> str:
    try:
        return os.path.realpath(path)
    except OSError:
        return path


class PracticeMonitor:
    """Lee el serie del Nano de prácticas. Abrir el puerto lo reinicia (DTR)."""

    def __init__(self, opener=None):
        self._opener = opener
        self._ser = None
        self._stop = threading.Event()
        self._thread: threading.Thread | None = None
        self._lock = threading.Lock()
        self._lines: deque[str] = deque(maxlen=200)
        self.path = ""
        self.baud = 0

    def open(self, path: str, baud: int) -> None:
        self.close()
        if self._opener is not None:
            ser = self._opener(path, baud)
        else:
            import serial

            ser = serial.Serial(path, baud, timeout=0.2, exclusive=True)
        self._ser = ser
        self.path = path
        self.baud = baud
        self._stop = threading.Event()
        self._thread = threading.Thread(target=self._run, name="orbitd-ardu-monitor", daemon=True)
        self._thread.start()

    def _run(self) -> None:
        ser = self._ser
        while ser is not None and not self._stop.is_set():
            try:
                raw = ser.readline()
            except Exception:
                break
            if not raw:
                continue
            line = raw.decode("utf-8", "replace").rstrip("\r\n")
            if not line:
                continue
            with self._lock:
                self._lines.append(line[:240])

    def take(self) -> str:
        with self._lock:
            lines = list(self._lines)
            self._lines.clear()
        return "\n".join(lines)

    def close(self) -> None:
        self._stop.set()
        ser, self._ser = self._ser, None
        if ser is not None:
            try:
                ser.close()
            except Exception:
                pass
        self.path = ""
        self.baud = 0


class ArduLab:
    def __init__(self, ports_file: Path, sketch_dir: Path, by_path: Path, cli: str = "arduino-cli",
                 fqbn: str = FQBN_OLD, serial_fallback: str | None = None, opener=None, runner=None):
        self.ports_file = ports_file
        self.sketch_dir = sketch_dir
        self.by_path = by_path
        self.cli = cli or "arduino-cli"
        self.fqbn = fqbn if FQBN_RE.fullmatch(fqbn or "") else FQBN_OLD
        self.serial_fallback = serial_fallback or ""
        self.monitor = PracticeMonitor(opener)
        self._runner = runner
        self._lock = threading.Lock()

    def mandos_link(self) -> str:
        mandos, _ = read_ports(self.ports_file)
        if not mandos:
            return ""
        link = self.by_path / mandos
        return str(link) if link.exists() else ""

    def _blocked_reals(self, extra: list[str] | None = None) -> set[str]:
        blocked = set()
        mandos, _ = read_ports(self.ports_file)
        if mandos:
            link = self.by_path / mandos
            if link.exists():
                blocked.add(_realpath(str(link)))
        for item in [self.serial_fallback, *(extra or [])]:
            if item:
                blocked.add(_realpath(item))
        return {b for b in blocked if b}

    def choose_practicas(self, extra: list[str] | None = None) -> tuple[str, str]:
        """Ruta by-path del Nano de prácticas, o ('', motivo) si hay que negarse."""
        mandos, practicas = read_ports(self.ports_file)
        if not practicas:
            return "", ("Falta el puerto del Nano de prácticas en arduino-puertos.json. "
                        "Hay que anotar el basename de /dev/serial/by-path. No se toca ninguna placa.")
        if mandos and practicas == mandos:
            return "", "Ese puerto es el del Nano de mandos. Queda bloqueado."
        link = self.by_path / practicas
        if not link.exists():
            return "", f"El Nano de prácticas no está en el puerto {practicas}. No se toca ninguna placa."
        real = _realpath(str(link))
        if real in self._blocked_reals(extra):
            return "", "Ese puerto es el del Nano de mandos (orbitd). Queda bloqueado."
        return str(link), ""

    def ports_result(self) -> dict:
        mandos, practicas = read_ports(self.ports_file)
        blocked = self._blocked_reals()
        rows = []
        if self.by_path.is_dir():
            for link in sorted(self.by_path.iterdir()):
                if not link.is_symlink() and not link.exists():
                    continue
                name = link.name
                real = _realpath(str(link)) if link.exists() else ""
                is_mandos = name == mandos or (real and real in blocked and name != practicas)
                if name == mandos or (real and real in blocked and name != practicas):
                    role, deny = "mandos", True
                elif name == practicas:
                    role, deny = "practicas", real in blocked
                else:
                    role, deny = "otro", real in blocked
                if is_mandos:
                    role, deny = "mandos", True
                rows.append({"role": role, "by_path": name, "device": real, "blocked": deny, "present": bool(real)})
        known = {row["by_path"] for row in rows}
        if practicas and practicas not in known:
            rows.append({"role": "practicas", "by_path": practicas, "device": "", "blocked": False, "present": False})
        if mandos and mandos not in known:
            rows.append({"role": "mandos", "by_path": mandos, "device": "", "blocked": True, "present": False})
        ready = any(r["role"] == "practicas" and r["present"] and not r["blocked"] for r in rows)
        if not self.by_path.is_dir() and not rows:
            message = "No existe /dev/serial/by-path. Enchufa las placas por USB. No se usa ttyUSB para identificarlas."
        elif ready:
            message = "El Nano de prácticas está en su puerto. El de mandos sigue bloqueado."
        elif not practicas:
            message = "Puertos vistos. Falta anotar el de prácticas en arduino-puertos.json. El de mandos no se programa."
        else:
            message = "El Nano de prácticas no está en el puerto guardado. El de mandos sigue bloqueado."
        payload = json.dumps({"ports": rows, "practicas": "listo" if ready else "no"}, ensure_ascii=False)
        return _res("pi.ardu_ports", True, message, payload)

    def _sketch_path(self, name: str) -> Path:
        if not SKETCH_RE.fullmatch(name):
            raise ValueError("nombre de sketch no válido")
        root = self.sketch_dir.resolve()
        dest = (root / name).resolve()
        if dest.parent != root:
            raise ValueError("ruta de sketch no válida")
        return dest

    def sketch_result(self, op: str, name: str, source: str) -> dict:
        action = "pi.ardu_sketch"
        try:
            if op == "lista":
                names = self._list_names()
                return _res(action, True, "Sketches guardados en la Pi.", json.dumps({"sketches": names}))
            folder = self._sketch_path(name)
        except ValueError:
            return _res(action, False, "El nombre del sketch no vale. Usa letras, cifras y _.", dry=True)
        if op == "leer":
            ino = folder / f"{name}.ino"
            if not ino.is_file():
                return _res(action, True, "No hay copia guardada de este sketch.", "")
            text = ino.read_text(encoding="utf-8", errors="replace")[:SOURCE_MAX]
            return _res(action, True, f"Sketch {name} leído.", text)
        if op == "guardar":
            if "\x00" in source:
                return _res(action, False, "El sketch tiene un carácter nulo. No se ha guardado.", dry=True)
            if len(source) > SOURCE_MAX:
                return _res(action, False, "El sketch pasa de 24000 caracteres. No se ha guardado.", dry=True)
            folder.mkdir(parents=True, exist_ok=True)
            dest = folder / f"{name}.ino"
            tmp = dest.with_suffix(".ino.tmp")
            tmp.write_text(source, encoding="utf-8")
            tmp.replace(dest)
            return _res(action, True, f"Sketch {name} guardado en la Pi.")
        return _res(action, False, "Operación de sketch desconocida.", dry=True)

    def _list_names(self) -> list[str]:
        if not self.sketch_dir.is_dir():
            return []
        names = []
        for folder in sorted(self.sketch_dir.iterdir()):
            if folder.is_dir() and SKETCH_RE.fullmatch(folder.name) and (folder / f"{folder.name}.ino").is_file():
                names.append(folder.name)
        return names

    def _cli_ready(self) -> str:
        if self._runner is not None:
            return ""
        path = Path(self.cli)
        if path.is_file() or shutil.which(self.cli):
            return ""
        return "arduino-cli no está instalado. Con internet, vuelve a ejecutar scripts/instalar-pi.sh. No se ha compilado."

    def _run(self, args: list[str]) -> tuple[int, str]:
        if self._runner is not None:
            return self._runner(args)
        proc = subprocess.run([self.cli, *args], capture_output=True, text=True, timeout=180, check=False)
        return proc.returncode, (proc.stdout or "") + (proc.stderr or "")

    def compile_result(self, name: str) -> dict:
        action = "pi.ardu_compile"
        missing = self._cli_ready()
        if missing:
            return _res(action, False, missing, dry=True)
        try:
            folder = self._sketch_path(name)
        except ValueError:
            return _res(action, False, "El nombre del sketch no vale.", dry=True)
        ino = folder / f"{name}.ino"
        if not ino.is_file():
            return _res(action, False, f"No está guardado {name}. Pulsa Verificar otra vez.", dry=True)
        code, text = self._run(["compile", "--fqbn", self.fqbn, str(folder)])
        if code == 0:
            return _res(action, True, f"Compilado {name} para {self.fqbn}. No se ha subido.", text or "compilado")
        diags = parse_errors(text)
        where = f" Error en la línea {diags[0]['line']}." if diags else ""
        return _res(action, False, f"No compila {name}.{where}", text or "arduino-cli no ha escrito salida")

    def upload_result(self, name: str, extra: list[str] | None = None) -> dict:
        action = "pi.ardu_upload"
        path, why = self.choose_practicas(extra)
        if not path:
            return _res(action, False, why, dry=True)
        self.monitor.close()
        compiled = self.compile_result(name)
        if not compiled["ok"]:
            compiled["action"] = action
            compiled["message"] = ("No se ha subido: " + compiled["message"])[:500]
            return compiled
        code, text = self._run(["upload", "-p", path, "--fqbn", self.fqbn, str(self._sketch_path(name))])
        log = (compiled.get("output") or "") + "\n" + text
        if code == 0:
            base = Path(path).name
            return _res(action, True, f"Subido {name} al Nano de prácticas ({base}). El de mandos no se ha tocado.", log)
        return _res(action, False, f"La compilación ha ido bien y la subida ha fallado. El puerto sigue siendo {Path(path).name}.", log)

    def monitor_result(self, op: str, baud: int, extra: list[str] | None = None) -> dict:
        action = "pi.ardu_monitor"
        if op == "cerrar":
            self.monitor.close()
            return _res(action, True, "Monitor serie cerrado.")
        if op == "leer":
            if not self.monitor.path:
                return _res(action, False, "El monitor no está abierto.", dry=True)
            return _res(action, True, f"Monitor a {self.monitor.baud} baudios.", self.monitor.take())
        if op != "abrir":
            return _res(action, False, "Operación de monitor desconocida.", dry=True)
        if baud not in BAUDS:
            return _res(action, False, "Esos baudios no están permitidos.", dry=True)
        path, why = self.choose_practicas(extra)
        if not path:
            return _res(action, False, why, dry=True)
        try:
            self.monitor.open(path, baud)
        except Exception as exc:
            self.monitor.close()
            return _res(action, False, f"No se ha podido abrir el serie del Nano de prácticas: {exc}"[:500], dry=True)
        return _res(action, True, f"Monitor del Nano de prácticas a {baud} baudios. Abrir el puerto lo reinicia.")
