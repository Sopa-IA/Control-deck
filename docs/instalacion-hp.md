# Instalar hp-agent en el HP

Un paso por línea. El HP es Windows 10 Home 22H2, sin Python. El cable interno es el HP en `10.0.0.1` y la Pi en `10.0.0.2`. Ese cable no lleva internet: para bajar Python y el agente hace falta el Wi-Fi u otra red.

Por defecto la tarea arranca en vivo: `pythonw.exe -m hp_agent --live`, y el toml queda en `live = true`. Orbit muestra la telemetría, y Bloquear, Reiniciar y Apagar (60 s) se ejecutan ya. `-DryRun` deja solo la telemetría, por si algún día se quiere mirar sin tocar el equipo. Apagar y reiniciar, en vivo, esperan 60 s y se pueden anular.

El token no se escribe en pantalla ni en el registro. ssh pide la contraseña de la Pi y la escribe Miguel.

## Una línea

1. En el HP, abre PowerShell como administrador: clic derecho, Ejecutar como administrador.
2. Pega esta línea y pulsa Enter.

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $u='https://raw.githubusercontent.com/Sopa-IA/Control-deck/cursor/bandeja-v2-modular-6d15/scripts/instalar-hp.ps1'; $p=Join-Path $env:TEMP 'instalar-hp.ps1'; Invoke-WebRequest -UseBasicParsing -Uri $u -OutFile $p; powershell -NoProfile -ExecutionPolicy Bypass -File $p
```

3. Cuando ssh pregunte la contraseña, escribe la de la Pi (usuario `orbit`, equipo `10.0.0.2`). No se muestra el token.
4. Al terminar, en Orbit OS, Sistemas, la tarjeta del HP tiene que decir **hp-agent conectado**. La CPU y la memoria se rellenan. La temperatura puede seguir en raya: Windows no da esos sensores a psutil.
5. Bloquear está en la tarjeta del HP. Reiniciar y Apagar están en el menú de apagado (Apagar también en la tarjeta). En vivo se ejecutan. Apagar y Reiniciar esperan 60 s. Cancelar es el botón Cancelar apagado HP, o `shutdown /a`.

La línea se puede repetir. Sin `-DryRun` deja otra vez el modo real. No cambia el token de la Pi.

## Qué hace

6. Si no hay Python 3.12, lo instala con winget (`Python.Python.3.12`). Si winget no está o no lo deja, baja el instalador oficial `python-3.12.10-amd64.exe` y lo ejecuta en silencio.
7. Baja el zip de la rama `cursor/bandeja-v2-modular-6d15` a `C:\Orbit\Control-deck`. No hace falta git.
8. Crea `C:\Orbit\Control-deck\.venv` e instala `software/shared/python`, `software/hp-agent`, `pycaw` y `comtypes`. pycaw es el volumen de la salida por defecto. No cambia el token ni la tarea.
9. Por ssh, como `orbit@10.0.0.2`, lee `ORBIT_HP_TOKEN` del `.env` de la raíz del clon. En la Pi ese archivo es `/home/orbit/Control-deck/.env`: lo escribe `scripts/gen-token.sh` y `scripts/instalar-pi.sh` no lo regenera si ya existe. `/etc/orbit/orbitd.env` tiene una copia, pero es de root y el usuario `orbit` no la lee.
10. Escribe `%APPDATA%\orbit\hp-agent.toml` con `hub_url = "ws://10.0.0.2:8765/ws"` y `live = true`. Con `-DryRun`, `live = false`. El archivo no se enseña.
11. Crea la tarea oculta `OrbitHpAgent`. Arranca al iniciar sesión, con `pythonw.exe -m hp_agent --live`, sin ventana. Con `-DryRun` los argumentos son `-m hp_agent`, sin `--live`. Si el proceso se cae, el Programador de tareas lo relanza al minuto, hasta 999 veces, y no tiene límite de horas. La arranca ya.

## Solo mirar

12. La misma línea del paso 2, y al final `-DryRun`:

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $u='https://raw.githubusercontent.com/Sopa-IA/Control-deck/cursor/bandeja-v2-modular-6d15/scripts/instalar-hp.ps1'; $p=Join-Path $env:TEMP 'instalar-hp.ps1'; Invoke-WebRequest -UseBasicParsing -Uri $u -OutFile $p; powershell -NoProfile -ExecutionPolicy Bypass -File $p -DryRun
```

13. En vivo, Bloquear llama a `rundll32.exe user32.dll,LockWorkStation`. Apagar es `shutdown /s /t 60`. Reiniciar es `shutdown /r /t 60`. Anular es `shutdown /a`. El volumen y el silencio usan el mezclador de Windows (pycaw), sobre la salida por defecto. Reproducir/pausar sigue pendiente. La Pi tiene que actualizarse antes que el HP: si no, orbitd rechaza la telemetría nueva.
14. Para volver al modo real, otra vez la línea del paso 2, sin `-DryRun`.

## Comprobar

15. `schtasks /Query /TN OrbitHpAgent /FO LIST /V` muestra la tarea. En los argumentos tiene que aparecer `-m hp_agent --live` (sin `--live` solo si se usó `-DryRun`). Está oculta en la vista simple del Programador.
16. El registro es `%LOCALAPPDATA%\orbit\hp-agent.log`. No contiene el token. Tiene que aparecer una línea de conectado a `ws://10.0.0.2:8765/ws` y `LIVE`. Con `-DryRun`, esa línea dice `DRY-RUN`.
17. En Sistemas, la tarjeta del HP dice hp-agent conectado. Si sigue en «hp-agent no conectado», el log dice si orbitd rechazó la sesión o si no hay cable hasta `10.0.0.2`.

## Desinstalar

18. En PowerShell como administrador:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Orbit\instalar-hp.ps1 -Desinstalar
```

19. Quita la tarea, `C:\Orbit\Control-deck` y `%APPDATA%\orbit\hp-agent.toml`. Python 3.12 se queda.
