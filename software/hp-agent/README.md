# hp-agent

Agente que corre en el HP. Abre la conexión **hacia** orbitd, envía la telemetría (psutil) cada 2 s y ejecuta solo acciones de la lista blanca (`software/shared/actions.json`). Cada acción se traduce a una orden fija, sin shell.

En el HP de Miguel no se instala a mano. En PowerShell como administrador, la línea de [`docs/instalacion-hp.md`](../../docs/instalacion-hp.md). Deja el agente en `C:\Orbit\Control-deck`, la tarea oculta `OrbitHpAgent` con `pythonw.exe -m hp_agent --live`, y el token en `%APPDATA%\orbit\hp-agent.toml` con `live = true`. `-DryRun` en esa línea deja solo la telemetría (`live = false`, sin `--live`). Un `python -m hp_agent` a mano, sin `--live` y sin `live = true` en el toml, sigue en seco.

A mano, para probar en otro equipo:

```bash
python -m venv .venv && . .venv/bin/activate        # en Windows: .venv\Scripts\activate
pip install -e ../shared/python -e .
python -m hp_agent --once-telemetry                 # lectura local de prueba
python -m hp_agent --hub ws://10.0.0.2:8765/ws    # DRY-RUN si el toml no dice live = true
python -m hp_agent --hub ws://10.0.0.2:8765/ws --live   # ejecuta las órdenes de verdad
```

- **Token:** se toma de `ORBIT_HP_TOKEN` o del archivo local `%APPDATA%\orbit\hp-agent.toml` / `~/.config/orbit/hp-agent.toml` (copiar de `hp-agent.example.toml`). El instalador lo lee por ssh del `.env` de la Pi y no lo imprime. Nunca va en el repositorio. En Windows el registro `%LOCALAPPDATA%\orbit\hp-agent.log` tampoco lo guarda: si apareciera en un mensaje, se sustituye.
- **Apagado y reinicio:** se programan con 60 s de margen (`shutdown /s /t 60`) y se pueden anular con `hp.shutdown_cancel`.
- **Red:** `net_down_kbps` y `net_up_kbps` van siempre, en kb/s, con la misma cuenta que la Pi (bytes de diferencia × 8 / 1000 / segundos). Se suman el Wi-Fi y el Ethernet. Quedan fuera el loopback y Virtual Display Driver. El primer muestreo sale a 0 hasta que hay un segundo.
- **Temperatura:** en Windows `psutil` no da sensores. `instalar-hp.ps1` deja LibreHardwareMonitor 0.9.6 (MPL-2.0, release oficial, SHA256 fijo) en `C:\Orbit\LibreHardwareMonitor`, tarea oculta `OrbitLibreHardwareMonitor`, con permisos de administrador, minimizado a la bandeja. hp-agent lee la CPU en `http://127.0.0.1:8085/data.json`. Si no responde, prueba WMI `root/LibreHardwareMonitor` y luego `MSAcpi_ThermalZoneTemperature`. Sin un valor entre 5 y 115 °C (5–100 en ACPI), `temp_c` queda vacío y la tarjeta sigue en raya. El resto de la telemetría no se corta.
- **Volumen en Windows:** `hp.volume_set` y `hp.volume_mute` usan pycaw sobre la salida por defecto. La telemetría puede llevar `volume_pct` y `volume_muted` (opcionales).
- **Reproducir o pausar:** en Windows pulsa la tecla de medios del sistema. En seco no la pulsa. En Linux sigue siendo `playerctl play-pause`.
- El modelo, en Windows, se lee del registro (`SystemProductName`). Si no se puede leer, la tarjeta dice HP.
