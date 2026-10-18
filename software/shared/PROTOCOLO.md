# Protocolo Orbit Terminal v1

Estado: **borrador implementado en v0**, validado solo con tests y simulación. No se ha probado aún entre el HP y la Pi reales.

## 1. Topología

```
 [Interfaz web (Chromium kiosco en la Pi)] ──ws://127.0.0.1:8765/ws──┐
                                                                     │
 [Arduino Micro] ──USB serie (115200)──> [orbitd · Raspberry Pi] <───┘
                                                ▲
                                                │ ws:// (LAN o cable directo) + token
                                                │   → recomendado wss:// / mTLS (pendiente)
                                         [hp-agent · HP]
```

- **orbitd** (en la Pi) es el *hub*. Sirve la interfaz estática, acepta WebSockets de la interfaz (`role: ui`) y del agente del HP (`role: hp-agent`), lee el Arduino por serie, aplica la **lista blanca** y reenvía acciones.
- **hp-agent** abre la conexión **hacia** orbitd (sale del HP), así que el HP no expone ningún puerto.
- El vídeo **no** pasa por este protocolo. El cambio de «sistema visible» lo hace **orbitd** con la acción `pi.switch_visible` (botón B2 por defecto); Miguel nunca toca el menú OSD del MSI. Hay dos modos (ver `docs/conmutacion-video-usb.md`):
  - **remoto** (modo A, base): la MSI muestra siempre la Pi; el escritorio del HP se abre en un visor de la Pi por el Ethernet interno (p. ej. Moonlight contra Sunshine en el HP). orbitd lanza la orden fija de `ORBIT_REMOTE_CMD` (configuración local, nunca desde la interfaz) y la cierra al volver a Orbit OS.
  - **ddc** (modo B, opcional): orbitd ejecuta `ddcutil setvcp 60 <valor>` con los valores de `ORBIT_DDC_HP` / `ORBIT_DDC_PI` (solo si `ORBIT_VIDEO_DDC=1`, ddcutil existe y los valores son hexadecimales válidos). Si ddcutil falla, vuelve solo al modo remoto. Soporte DDC/CI del MSI y adaptador HDMI→USB-C: **PENDIENTES de verificar**.
  - El estado `state` lleva `visible: {system: "hp"|"pi", mode: "remoto"|"ddc", detail}` y `video_input` (entrada física: `pi` en modo remoto).

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
| `telemetry` | hp → orbitd → ui; orbitd → ui (pi) | CPU, RAM, disco, temperatura, uptime. **`simulated` es obligatorio** |
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
4. hp-agent arranca en **dry-run por defecto**: registra lo que haría y responde `dry_run: true`. Para ejecutar de verdad hace falta `--live`.
5. Límite de frecuencia: `hp.volume_set` se agrupa a un máximo de 10 por segundo; el resto de acciones, a 5 por segundo por conexión (`rate_limited`).

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
- `pi.shutdown` sigue el mismo flujo. En v0, orbitd solo lo simula o registra; ejecutar `systemctl poweroff` requiere configurar permisos (**pendiente**).

## 7. Arduino → orbitd (serie)

Puerto USB CDC a 115200 baudios, con líneas ASCII terminadas en `\n`:

| Línea | Significado |
|---|---|
| `H orbit-controls 1 P2 B2` | Saludo: firmware, versión y cuántos potenciómetros y botones hay (por defecto 2 y 2; configurable en `config.h`). Se envía al arrancar y al recibir `?` |
| `P1 512` | Potenciómetro 1, valor filtrado de 0 a 1023 (solo se envía si cambia más que la histéresis) |
| `B2 1` / `B2 0` | Botón 2 pulsado / soltado (con antirrebote) |
| `B2 L` | Pulsación larga (≥ 800 ms) |

orbitd convierte cada línea en un `control_event`. Las líneas mal formadas se ignoran y quedan registradas.
