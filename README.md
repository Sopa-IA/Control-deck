# Orbit Terminal

> **Repositorio `Sopa-IA/Control-deck` · producto *Orbit Terminal*.** El repositorio se llama *Control-deck*; el producto y el software se llaman *Orbit Terminal* / *Orbit OS*.

Orbit Terminal es un terminal de sobremesa en forma de cuña que reúne dos mundos en una sola pantalla: un **HP** reutilizado como sistema principal y una **Raspberry Pi** que ejecuta *Orbit OS*. Tiene consola de mandos física (potenciómetros y botones) y luces ámbar.

**Estado: prototipo v0.** El software funciona en **simulación** y con tests automáticos. **No se ha probado aún con el HP, la Pi, el Arduino ni el monitor reales.**

![Inicio](assets/screenshots/inicio_1920x1080.png)

## Decisiones del prototipo

Detalle en [`docs/decisiones-prototipo.md`](docs/decisiones-prototipo.md).

- **Solo piezas que Miguel ya tiene.**
- **Pantalla:** MSI PRO MP161 E2U 15,6", 1920×1080, **no táctil**. Se usa con ratón y controles; la interfaz sigue preparada para táctil.
- **HP:** HP Slimline 260-a110ns **desmontado**; su placa mini-ITX va dentro de la cuña (adaptador externo de 19,5 V fuera, DVD retirado, SSD 2,5" recomendado).
- **Vídeo: la Pi lo controla todo y el cambio HP ↔ Pi es automático desde Orbit OS** (Miguel nunca toca el OSD de la MSI). La MSI muestra siempre la Pi y el HP sigue funcionando por su cuenta con su Windows. **Modo C (recomendado, imagen real del HP):** el HDMI del HP entra en una **capturadora HDMI→USB** conectada a la Pi y Orbit OS muestra su imagen (latencia y fps sin medir; teclado y ratón al HP aparte). **Modo A (recomendado, sin compras):** el escritorio del HP se ve en un visor (Sunshine en el HP + Moonlight en la Pi) por el Ethernet interno. **Modo B (poco probable):** Pi → adaptador HDMI→USB-C → USB-C y cambio de entrada por DDC/CI, que los manuales de la MSI no documentan. El botón "Cambiar sistema visible" usa el modo disponible.
- **Controles:** potenciómetros y botones leídos por un **Arduino Micro**, que sustituye a los encoders.
- **Pendientes de identificar:** el modelo de Raspberry Pi y el tipo de tira LED.

## Estructura

```
README.md
docs/                        Investigación fase 1, diseño mecánico v0, decisiones del prototipo
hardware/cad/                CAD paramétrico OpenSCAD (v1 + HP v3), STL PROVISIONALES, scripts de comprobación
assets/renders/              Renders del diseño v1
assets/screenshots/          Capturas de la interfaz
software/interface/          Orbit OS Interface (React + TypeScript + Vite)
software/pi-controller/      orbitd: hub WebSocket, servidor de la interfaz y lector del Arduino (Python)
software/hp-agent/           Agente de telemetría y acciones de lista blanca para el HP (Python)
software/shared/             Protocolo v1: PROTOCOLO.md, esquema JSON, actions.json, tipos TS y paquete Python
software/arduino-controls/   Firmware del Arduino Micro (potenciómetros y botones)
tests/python/                pytest (protocolo, orbitd, hp-agent, serie)
scripts/                     Instalación, tests, simulación, capturas, token, compilación Arduino
.github/workflows/ci.yml     Lint + tests (ruff, pytest, tsc, vitest, build)
```

## Puesta en marcha (desarrollo)

Requisitos: Python ≥ 3.9 (probado con 3.13), Node.js 20 y npm. Opcionales: `arduino-cli` para el firmware y Chrome/Chromium para las capturas.

```bash
./scripts/setup-dev.sh              # crea .venv e instala los paquetes Python y las dependencias de la interfaz
. .venv/bin/activate
./scripts/test-all.sh               # ruff + pytest + tsc + vitest
./scripts/dev-sim.sh                # compila la interfaz y arranca orbitd simulado en http://127.0.0.1:8765/
```

Solo la interfaz, con el simulador del navegador: `cd software/interface && npm run dev` (http://localhost:5173).

### Con los equipos reales (pendiente de validar)

1. **Token:** `./scripts/gen-token.sh` lo guarda en `.env` (ignorado por git). Hay que copiarlo al HP por un canal seguro.
2. **Raspberry Pi:**
   ```bash
   set -a; . ./.env; set +a
   python -m orbitd --host 0.0.0.0 --serial /dev/ttyACM0 --static software/interface/dist
   ```
   Fuera de localhost exige `ORBIT_HP_TOKEN` y `ORBIT_UI_TOKEN`. Después se abre Chromium en modo kiosco en `http://127.0.0.1:8765/`.
3. **HP:**
   ```bash
   pip install -e software/shared/python -e software/hp-agent
   ORBIT_HP_TOKEN=... python -m hp_agent --hub ws://<ip-pi>:8765/ws
   ```
   Arranca en **dry-run**; con `--live` ejecuta las órdenes de verdad.
4. **Arduino Micro:** `./scripts/compile-arduino.sh` y luego `arduino-cli upload` (ver [`software/arduino-controls/README.md`](software/arduino-controls/README.md)).

Las capturas se regeneran con orbitd en marcha y `node scripts/screenshots.mjs` (usa `/usr/bin/google-chrome`, o la ruta que indique `CHROME_PATH`).

## Estado

| Componente | Estado | Notas |
|---|---|---|
| Protocolo v1: sobre JSON, esquema, autenticación por token, latido, lista blanca, apagado con confirmación | **Implementado** | Probado con pytest y vitest; ver [`software/shared/PROTOCOLO.md`](software/shared/PROTOCOLO.md) |
| orbitd: hub WebSocket, interfaz estática, lectura serie, mapeo de controles | **Implementado** | Probado en local (tests de integración con servidor real) |
| Telemetría de la Pi (psutil) | **Implementado** | Lee el equipo donde corre orbitd; si no es una Pi, lo indica |
| HP y controles en orbitd `--sim` | **Simulación** | Marcados con `simulated: true` y distintivo **MODO SIMULACIÓN** |
| Interfaz Orbit OS (6 secciones, 1920×1080 y 1920×720) | **Implementado** | Con simulador y con orbitd en modo simulación |
| hp-agent: telemetría y acciones en dry-run | **Implementado** | Probado contra orbitd en local, en este entorno Linux; **no en el HP** |
| hp-agent `--live` en Windows: bloquear, apagar o reiniciar con 60 s, cancelar | **Pendiente de validar** | Órdenes fijas sin shell; no ejecutadas nunca de verdad |
| hp-agent en Windows: volumen, silencio, reproducir/pausar | **Pendiente** | No hay orden nativa (habría que usar pycaw o nircmd) |
| Firmware del Arduino Micro | **Pendiente de validar** | Compila con arduino-cli (18 % de la flash); sin probar en placa |
| Apagado de la Pi (`pi.shutdown`) | **Pendiente** | Requiere permisos de systemd/polkit; ahora solo se registra |
| Modos de la tira LED | **Requiere intervención humana** | Identificar la tira (tipo y tensión) |
| Cambio automático de sistema visible (`pi.switch_visible`, botón B2) | **Implementado (sin hardware)** | orbitd elige el modo disponible: **B DDC/CI** (si está configurado; poco probable con la MSI), **C captura** (capturadora HDMI→USB en la Pi: `ORBIT_CAPTURE_DEVICE` + visor fijo `ORBIT_CAPTURE_CMD`, sin shell) o **A remoto** (visor del escritorio del HP por Ethernet interno, p. ej. Moonlight + Sunshine; `ORBIT_REMOTE_CMD`). Si uno falla pasa al siguiente. Probado con tests unitarios y de integración (dispositivo simulado); **sin verificar** con la MSI, la capturadora, el adaptador ni Sunshine. No se dan latencias ni fps. Ver [`docs/conmutacion-video-usb.md`](docs/conmutacion-video-usb.md) §V |
| HP: **HP Slimline 260-a110ns** (A6-7310, 8 GB, HDMI + VGA, adaptador externo 19,5 V 65 W) | **Identificado y abierto** | **Medido por Miguel:** placa 17 × 17 cm, altura máxima 35 mm. Agujeros: patrón estándar mini-ITX (coincide visualmente con la foto, no medido). Sin escudo I/O. Faltan posición de conectores traseros, botón de encendido, antenas y BIOS: **requieren intervención humana** (`docs/datos-pendientes-hp.md` §A2, con nota de seguridad) |
| Modelo de la Pi y su conexión a la MSI (ya da imagen), capturadora (comprarla o no: decisión de Miguel), adaptador HDMI→USB-C y soporte DDC/CI de la MSI | **Requiere intervención humana** | Ver `docs/conmutacion-video-usb.md` §V.5 |
| Cifrado del enlace HP↔Pi (`wss://` / mTLS) | **Pendiente** | v0 usa `ws://` con token: solo en red de confianza o cable directo |
| Servicios systemd (Pi), servicio o arranque automático (HP), Chromium en kiosco | **Pendiente** | — |
| CAD v1 + HP v3 (cuña 456 × 300 × 154 mm, 20 STL para Bambu Lab A1 en PETG) | **Pendiente de validar** | **HP v2/v3:** placa mini-ITX desnuda del HP (separadores en patrón estándar mini-ITX, ventana I/O libre sin escudo, altura real de 35 mm, soporte de SSD 2,5" con opción HDD 3,5", I/O frontal y pulsador del HP en el lateral izquierdo, hueco del adaptador HDMI→USB-C y **reserva para la capturadora**); placa I/O impresa pendiente de medir los conectores. Sin KVM, 2 potenciómetros + 2 pulsadores genéricos, soporte del Arduino Micro con canal USB, puertos y teclas OSD del canto derecho del MSI. Comprobación de interferencias y de STL correctas (en cajas envolventes); NO apto para fabricación |
| Medidas de potenciómetros, pulsadores y puertos/teclas del MSI | **Requiere intervención humana** | Medir las piezas de Miguel y ajustar `params.scad`/`lib.scad` |

## Tests (última ejecución local, 2026-10-18)

- `ruff check`: sin errores.
- `pytest`: **47 pasados**.
- `tsc`: sin errores.
- `vitest`: **27 pasados** en 6 archivos.
- `vite build`: correcto.
- `arduino-cli compile` (arduino:avr:micro): correcto.

## Documentación

**Fase 1:**
- [`docs/informe-fase1.md`](docs/informe-fase1.md)
- [`docs/pantallas.md`](docs/pantallas.md)
- [`docs/conmutacion-video-usb.md`](docs/conmutacion-video-usb.md)
- [`docs/controles.md`](docs/controles.md)
- [`docs/raspberry-pi.md`](docs/raspberry-pi.md)
- [`docs/alimentacion-preliminar.md`](docs/alimentacion-preliminar.md)
- [`docs/incertidumbres-hardware.md`](docs/incertidumbres-hardware.md)
- [`docs/datos-pendientes-hp.md`](docs/datos-pendientes-hp.md)

**Diseño y decisiones:**
- Decisiones del prototipo: [`docs/decisiones-prototipo.md`](docs/decisiones-prototipo.md) · Vídeo y cambio de sistema: [`docs/conmutacion-video-usb.md`](docs/conmutacion-video-usb.md) §V · HP y seguridad del desmontaje: [`docs/datos-pendientes-hp.md`](docs/datos-pendientes-hp.md)
- Diseño mecánico v1 + HP v3: [`docs/diseno-mecanico.md`](docs/diseno-mecanico.md) (CAD en `hardware/cad/`, renders en `assets/renders/`)

## Seguridad

- No se suben secretos. `.env`, `config.local.*`, `*.token`, `*.key` y `*.pem` están en `.gitignore`, y solo hay ejemplos (`.env.example`, `hp-agent.example.toml`).
- No se ejecuta texto arbitrario. Cada acción de la lista blanca se traduce a una orden fija.
- El software no diseña circuitos de red eléctrica. La batería queda como estudio futuro.

## Licencia

La que figura en el archivo `LICENSE` del repositorio (Apache-2.0, añadida por Miguel al crear `Sopa-IA/Control-deck`).
