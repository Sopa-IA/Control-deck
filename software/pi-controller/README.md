# orbitd (pi-controller)

Hub de Orbit Terminal en la Raspberry Pi. Hace cuatro cosas:

- sirve la interfaz compilada (`software/interface/dist`);
- expone el WebSocket `/ws` (protocolo en `software/shared/PROTOCOLO.md`);
- lee los eventos serie del Arduino Micro;
- aplica la lista blanca de acciones.

```bash
python3 -m venv .venv && . .venv/bin/activate
pip install -e ../shared/python -e .
python -m orbitd --sim --static ../interface/dist          # todo simulado salvo la telemetría local
ORBIT_HP_TOKEN=$(cat ~/.config/orbit/hp.token) python -m orbitd --sim-controls   # HP real, controles simulados
python -m orbitd --serial /dev/ttyACM0                      # Arduino real
```

| Opción / variable | Uso |
|---|---|
| `--sim`, `--sim-hp`, `--sim-controls` | Simulación. Lo simulado se marca con `simulated: true` y la interfaz muestra **MODO SIMULACIÓN** |
| `--serial`, `ORBIT_SERIAL` | Puerto del Arduino |
| `ORBIT_HP_TOKEN` | Token que debe presentar hp-agent (si falta, orbitd rechaza al agente) |
| `ORBIT_UI_TOKEN` | Opcional: token para la interfaz |
| `--host` | `127.0.0.1` por defecto; fuera de localhost exige los dos tokens |
| `--state-dir` | Dónde se guarda `controls.json` (por defecto `~/.local/state/orbitd`) |

La telemetría de la Pi es **real**: se lee con psutil del equipo donde corre orbitd. Si ese equipo no es una Raspberry Pi, el campo `model` lo indica.

**Pendiente:**

- `pi.shutdown` no ejecuta nada, porque faltan los permisos de systemd/polkit.
- `pi.led_mode` no hace nada mientras no se identifique la tira LED.
- Falta el servicio systemd.
- Falta pasar a `wss://`.
