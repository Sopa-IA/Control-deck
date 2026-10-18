# hp-agent

Agente que corre en el HP. Abre la conexión **hacia** orbitd, envía la telemetría (psutil) cada 2 s y ejecuta solo acciones de la lista blanca (`software/shared/actions.json`). Cada acción se traduce a una orden fija, sin shell.

```bash
python -m venv .venv && . .venv/bin/activate        # en Windows: .venv\Scripts\activate
pip install -e ../shared/python -e .
python -m hp_agent --once-telemetry                 # lectura local de prueba
set ORBIT_HP_TOKEN=...   (o export ORBIT_HP_TOKEN=...)
python -m hp_agent --hub ws://<ip-pi>:8765/ws       # DRY-RUN por defecto: no ejecuta nada
python -m hp_agent --hub ws://<ip-pi>:8765/ws --live   # ejecuta las órdenes de verdad
```

- **Token:** se toma de `ORBIT_HP_TOKEN` o del archivo local `%APPDATA%\orbit\hp-agent.toml` / `~/.config/orbit/hp-agent.toml` (copiar de `hp-agent.example.toml`). Nunca va en el repositorio.
- **Apagado y reinicio:** se programan con 60 s de margen (`shutdown /s /t 60`) y se pueden anular con `hp.shutdown_cancel`.
- **Pendiente en Windows:** volumen, silencio y reproducir/pausar no tienen orden nativa (habría que usar pycaw o nircmd). El agente responde `ok: false` explicando que está PENDIENTE.
- Sistema operativo y modelo del HP: **desconocidos**. No probado en el HP real.
