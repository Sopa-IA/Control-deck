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
| `ORBIT_REMOTE_CMD` | Orden de Moonlight, sin shell. La MSI va solo a la Pi; el HP se ve por el cable directo (10.0.0.1 / 10.0.0.2) |
| `ORBIT_VIDEO_DDC`, `ORBIT_DDC_HP`, `ORBIT_DDC_PI`, `ORBIT_DDC_BUS` | Cambio de entrada de la MSI. Apagado: los manuales no documentan DDC/CI |
| `ORBIT_POWER_LIVE`, `ORBIT_POWER_ALLOW_EXEC` | Las escribe `scripts/instalar-pi.sh` con valor `1` solo si el equipo es una Raspberry Pi. Sin las dos, y sin un modelo `Raspberry Pi` en el device-tree, apagar y reiniciar no llaman a systemctl |

La telemetría de la Pi es **real**: se lee con psutil del equipo donde corre orbitd. Si ese equipo no es una Raspberry Pi, el campo `model` lo indica.

`pi.shutdown` y `pi.restart` piden confirmación en la interfaz. Si se confirman en la Pi, orbitd ejecuta `sudo -n /usr/bin/systemctl poweroff` o `reboot`. El sudoers lo instala `scripts/instalar-pi.sh` y no concede nada más. Con `--sim`, o en un PC, la respuesta dice que no se ha ejecutado. Un botón asignado a esas acciones solo abre el diálogo si se mantiene pulsado.

**Aún no:**

- `pi.led_mode` responde que la tira no está conectada y no envía nada. La interfaz deja esos botones apagados. Cuando se identifique, la llevará el ESP8266 con WLED, no el Nano de mandos.
- Falta pasar a `wss://`.
- Apagar y reiniciar, en la Pi y tras confirmar, llaman a systemctl. En el simulador y en un PC no.
