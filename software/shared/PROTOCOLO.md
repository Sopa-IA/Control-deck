# Protocolo Orbit Terminal v1

Estado: **borrador implementado en v0**, validado solo con tests y simulación. No se ha probado aún entre el HP y la Pi reales.

## 1. Topología

```
 [Interfaz web (Chromium kiosco en la Pi)] ──ws://127.0.0.1:8765/ws──┐
                                                                     │
 [Arduino Nano de mandos] ──USB-serie CH340 (115200)──> [orbitd · Raspberry Pi] <───┘
                                                ▲
                                                │ ws:// (LAN o cable directo) + token
                                                │   → recomendado wss:// / mTLS (pendiente)
                                         [hp-agent · HP]
```

- **orbitd** (en la Pi) es el *hub*. Sirve la interfaz estática, acepta WebSockets de la interfaz (`role: ui`) y del agente del HP (`role: hp-agent`), lee el Arduino por serie, aplica la **lista blanca** y reenvía acciones.
- **hp-agent** abre la conexión **hacia** orbitd (sale del HP), así que el HP no expone ningún puerto.
- El vídeo **no** pasa por este protocolo. El cambio de «sistema visible» lo hace **orbitd** con la acción `pi.switch_visible` (botón B2 por defecto); Miguel nunca toca el menú OSD del MSI. La MSI va solo a la Pi. La imagen del HP llega por un cable de red directo (HP 10.0.0.1, Pi 10.0.0.2): Sunshine en el HP y Moonlight en la Pi. El teclado y el ratón son Bluetooth, emparejados con la Pi. orbitd lanza la orden fija de `ORBIT_REMOTE_CMD` (configuración local, nunca desde la interfaz) y la cierra al volver a Orbit OS. Ver `docs/instalacion-pi.md`.
  - Cambiar la entrada de la MSI con `ddcutil` está en el código y apagado (`ORBIT_VIDEO_DDC`). Los manuales de la MSI no documentan DDC/CI.
  - El estado `state` lleva `visible: {system: "hp"|"pi", mode: "remoto"|"ddc"|"captura", detail}`. El instalador deja `mode` en `remoto`.

## 2. Sobre común

Todos los mensajes son objetos JSON de texto de 16 KiB como máximo. El esquema completo está en `schemas/protocol.schema.json` (JSON Schema 2020-12).

```json
{ "v": 1, "type": "telemetry", "id": "a1b2c3", "ts": 1792316005597, "src": "hp",
  "reply_to": "opcional", "payload": { ... } }
```

| Campo | Significado |
|---|---|
| `v` | Versión del protocolo (siempre 1) |
| `type` | Tipo de mensaje (tabla siguiente) |
| `id` | Identificador único del emisor (≤ 64) |
| `ts` | ms desde época Unix (UTC) en el emisor |
| `src` | `ui`, `pi` u `hp` |
| `reply_to` | `id` del mensaje al que responde |

| Tipo | Dirección | Uso |
|---|---|---|
| `hello` | cliente → orbitd | Primer mensaje obligatorio: rol, cliente, versión y token |
| `welcome` | orbitd → cliente | Sesión aceptada: `heartbeat_s` y `mode` (`sim`, `real` o `mixto`) |
| `error` | cualquiera | `auth_failed`, `bad_message`, `not_allowed`, `bad_params`, `target_offline`, `confirm_expired`, `rate_limited` o `internal` |
| `ping` / `pong` | orbitd ↔ cliente | Latido |
| `state` | orbitd → ui | Estado de nodos (hp, pi, arduino): `connected`, `simulated`, `last_seen` |
| `telemetry` | hp → orbitd → ui; orbitd → ui (pi) | CPU, RAM, disco, temperatura, uptime, red. Volumen (`volume_pct`, `volume_muted`) opcional. **`simulated` es obligatorio**. Un agente viejo, sin esas claves, sigue valiendo |
| `control_event` | orbitd → ui | Potenciómetro (`value` de 0 a 1023) o botón (`press`, `release` o `long`), con `simulated` |
| `action_request` | ui → orbitd | Petición de acción de la lista blanca |
| `confirm_required` | orbitd → ui | La acción es destructiva y requiere confirmación con un desafío |
| `action_confirm` | ui → orbitd | Devuelve el desafío dentro del plazo |
| `action` | orbitd → hp | Acción ya validada que se reenvía al agente |
| `action_result` | hp → orbitd → ui | Resultado con `ok`, `dry_run` y `message` |
| `mapping` / `mapping_set` | orbitd ↔ ui | Asignación de controles a funciones |

## 3. Autenticación

- **hp-agent:** el `hello` lleva un `token` que orbitd compara en tiempo constante con `ORBIT_HP_TOKEN`. Si no coincide, responde `error/auth_failed` y cierra. Un token vacío nunca es válido. El token se genera en local (`scripts/gen-token.sh`) y se guarda en variables de entorno o en un archivo de configuración **fuera del repositorio** (`.env` y `config.local.*` están en `.gitignore`).
- **ui:** por defecto orbitd solo escucha en `127.0.0.1`, porque la interfaz corre en la propia Pi. Si se define `ORBIT_UI_TOKEN`, la interfaz también debe presentarlo. Para exponer orbitd en la LAN hay que definir **los dos tokens**; si no, orbitd se niega a arrancar escuchando en `0.0.0.0`.
- **Cifrado:** en v0 se usa `ws://` en claro. El canal HP↔Pi debe pasar a `wss://`, con TLS mutuo o al menos certificado fijado, antes de usarlo fuera de un cable directo (**pendiente**).
- Con el primer mensaje que no sea `hello`, o con un `hello` inválido, se cierra la conexión.

## 4. Latido

orbitd envía `ping {seq}` cada **5 s** y el cliente responde `pong {seq}`. Si pasan **15 s** sin recibir nada, orbitd cierra la conexión y marca el nodo como `connected: false`. hp-agent reconecta con espera exponencial (de 1 s a 30 s).

## 5. Lista blanca de acciones

Está definida **una sola vez** en `actions.json`, y la leen la interfaz, orbitd y hp-agent. Reglas:

1. Se rechaza (`not_allowed`) cualquier acción que no figure en la lista, o cuyo prefijo (`hp.` o `pi.`) no coincida con su `target`.
2. Los parámetros se validan con el mini-esquema de cada acción (`bad_params`), sin propiedades adicionales.
3. **Nunca se ejecuta texto arbitrario.** hp-agent traduce cada acción a una orden fija (lista de argumentos, sin shell). `hp.open_app` solo acepta un identificador que exista en la lista de aplicaciones de la configuración local del agente.
4. Un `python -m hp_agent` a mano arranca en **dry-run por defecto**: registra lo que haría y responde `dry_run: true`. Para ejecutar de verdad hace falta `--live`, o `live = true` en el toml. La tarea que deja `scripts/instalar-hp.ps1` en el HP lleva `--live` y `live = true`. `-DryRun` en ese instalador deja solo la telemetría.
5. Límite de frecuencia: `hp.volume_set` se agrupa a un máximo de 10 por segundo; el resto de acciones, a 5 por segundo por conexión (`rate_limited`). Un potenciómetro no repite el mismo nivel. Por defecto P1 y P2 están en `none`. Un cambio menor del 3 %, o una entrada que salta al azar, no dispara la acción.

## 6. Apagado seguro (acciones con `confirm: true`)

```
ui ──action_request{hp.shutdown}──> orbitd
ui <──confirm_required{request_id, challenge, expires_in_s:15}── orbitd
ui ──action_confirm{request_id, challenge}──> orbitd   (en ≤ 15 s; el usuario confirma en un diálogo)
orbitd ──action{hp.shutdown}──> hp-agent
hp-agent: programa el apagado con 60 s de margen (Windows: shutdown /s /t 60; Linux: shutdown -h +1)
ui <──action_result{ok, dry_run, "Apagado programado en 60 s; hp.shutdown_cancel para anular"}──
```

- Un desafío caducado o incorrecto da `confirm_expired`, y el desafío se descarta tras un solo uso.
- `hp.shutdown_cancel` anula el apagado (Windows: `shutdown /a`; Linux: `shutdown -c`).
- `pi.shutdown` y `pi.restart` usan el mismo diálogo. Tras confirmar, orbitd ejecuta solo `sudo -n /usr/bin/systemctl poweroff` o `sudo -n /usr/bin/systemctl reboot`. El instalador deja esa pareja en `/etc/sudoers.d/orbit-power`, para el usuario del servicio, y nada más. La Pi se apaga o reinicia en el acto: no hay 60 s de margen.
- En simulación (`--sim`) o si el equipo no es una Raspberry Pi, esas dos acciones responden y no llaman a systemctl.
- Un botón del Nano asignado a `pi.shutdown` o `pi.restart` no actúa con un toque corto. Mantenerlo pulsado abre el mismo diálogo. Si no hay una interfaz conectada, no se apaga.

## 7. Arduino → orbitd (serie)

El Nano de mandos habla por el UART del ATmega328P. Un CH340 lo presenta en Linux como `/dev/ttyUSB*` (ejemplo `/dev/ttyUSB0`; con el ESP enchufado el número puede cambiar: usar `/dev/serial/by-id`, **PENDIENTE** de leerlo en la Pi). No es el puerto CDC `/dev/ttyACM*` del antiguo Micro. 115200 baudios, líneas ASCII terminadas en `\n`.

Abrir el puerto reinicia la placa (DTR → RESET). orbitd espera 2 s (**DISEÑO**, no medidos en este clon) antes de escribir `?`. El saludo espontáneo del arranque se lee igual.

El Nano de prácticas y su OLED **no** usan este protocolo. Su ejemplo imprime `monitor-pines 1`, que orbitd ignora. No hay que enchufarlo en el puerto de `--serial`.

| Línea | Significado |
|---|---|
| `H orbit-controls 1 P2 B2` | Saludo: firmware, versión y cuántos potenciómetros y botones hay (por defecto 2 y 2; configurable en `config.h`). Se envía al arrancar y al recibir `?` |
| `P1 512` | Potenciómetro 1, valor filtrado de 0 a 1023 (solo se envía si cambia más que la histéresis) |
| `B2 1` / `B2 0` | Botón 2 pulsado / soltado (con antirrebote) |
| `B2 L` | Pulsación larga (≥ 800 ms) |

orbitd convierte cada línea en un `control_event`. Las líneas mal formadas se ignoran y quedan registradas.
