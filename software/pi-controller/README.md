# orbitd (pi-controller)

Hub de Orbit Terminal en la Raspberry Pi. Hace cuatro cosas:

- sirve la interfaz compilada (`software/interface/dist`);
- expone el WebSocket `/ws` (protocolo en `software/shared/PROTOCOLO.md`);
- lee los eventos serie del Arduino Nano de mandos (CH340, `/dev/ttyUSB*`);
- aplica la lista blanca de acciones.

```bash
python3 -m venv .venv && . .venv/bin/activate
pip install -e ../shared/python -e .
python -m orbitd --sim --static ../interface/dist          # todo simulado salvo la telemetría local
ORBIT_HP_TOKEN=$(cat ~/.config/orbit/hp.token) python -m orbitd --sim-controls   # HP real, controles simulados
python -m orbitd --serial /dev/ttyUSB0                      # Nano de mandos (confirmar con /dev/serial/by-id)
```

| Opción / variable | Uso |
|---|---|
| `--sim`, `--sim-hp`, `--sim-controls` | Simulación. Lo simulado se marca con `simulated: true` y la interfaz muestra **MODO SIMULACIÓN** |
| `--serial`, `ORBIT_SERIAL` | Puerto del Nano de mandos. Ejemplo `/dev/ttyUSB0` |
| `--serial-reset-wait`, `ORBIT_SERIAL_RESET_WAIT` | Segundos de espera tras abrir el puerto, antes de escribir `?`. Por defecto 2. No medidos en el clon |
| `ORBIT_HP_TOKEN` | Token que debe presentar hp-agent (si falta, orbitd rechaza al agente) |
| `ORBIT_UI_TOKEN` | Opcional: token para la interfaz |
| `--host` | `127.0.0.1` por defecto; fuera de localhost exige los dos tokens |
| `--state-dir` | Dónde se guarda `controls.json` (por defecto `~/.local/state/orbitd`) |
| `ORBIT_REMOTE_CMD` | Modo A (remoto): orden del visor del escritorio del HP, sin shell (p. ej. Moonlight) |
| `ORBIT_CAPTURE_DEVICE`, `ORBIT_CAPTURE_CMD` | Modo C (capturadora HDMI→USB): dispositivo V4L2 (`/dev/videoN` o `/dev/v4l/by-id/…`) y visor sin shell; `{device}` se sustituye |
| `ORBIT_VIDEO_DDC`, `ORBIT_DDC_HP`, `ORBIT_DDC_PI`, `ORBIT_DDC_BUS` | Modo B (DDC/CI, poco probable con la MSI) |

La telemetría de la Pi es **real**: se lee con psutil del equipo donde corre orbitd. Si ese equipo no es una Raspberry Pi, el campo `model` lo indica.

**Pendiente:**

- `pi.shutdown` no ejecuta nada, porque faltan los permisos de systemd/polkit.
- `pi.led_mode` no envía nada. La tira sigue sin identificar y, cuando se sepa, la llevará el ESP8266 con WLED, no el Nano de mandos.
- Falta el servicio systemd.
- Falta pasar a `wss://`.
