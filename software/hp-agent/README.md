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
- **Temperatura:** en Windows `psutil.sensors_temperatures` no existe como dato (`NotImplementedError`). La telemetría sigue, con `temp_c` vacío. La tarjeta lo enseña como raya.
- **Pendiente en Windows:** volumen, silencio y reproducir/pausar no tienen orden nativa (habría que usar pycaw o nircmd). El agente responde `ok: false` explicando que está PENDIENTE.
- El modelo, en Windows, se lee del registro (`SystemProductName`). No probado aún en el HP real.
