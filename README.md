# Orbit Terminal

> **Repositorio `Sopa-IA/Control-deck` · producto *Orbit Terminal*.** El repositorio se llama *Control-deck*; el producto y el software se llaman *Orbit Terminal* / *Orbit OS*.

Orbit Terminal es un terminal de sobremesa en forma de cuña que reúne dos mundos en una sola pantalla: un **HP** reutilizado como sistema principal y una **Raspberry Pi** que ejecuta *Orbit OS*. Tiene consola de mandos física (potenciómetros y botones) y luces ámbar.

**Estado: prototipo.** El software funciona en **simulación** y con tests automáticos. **No se ha probado aún con el HP, la Pi, el Arduino ni el monitor reales.** La carcasa **no está lista para fabricar.**

> **Para retomar el proyecto sin contexto** (Miguel u otro agente): [`docs/ESTADO-Y-TRASPASO.md`](docs/ESTADO-Y-TRASPASO.md). Ahí están el mapa del repo, lo que Miguel ya tiene, cada STL con su caja medida, los modos de vídeo y los comandos para comprobar el CAD.
>
> **Manual de montaje** (prototipo, estilo IKEA, 21 páginas, dibujos del CAD): [`docs/manual-montaje/MANUAL_MONTAJE_ORBIT.pdf`](docs/manual-montaje/MANUAL_MONTAJE_ORBIT.pdf). No autoriza a fabricar. Lo que se imprime después de la base está en [`hardware/impresion/siguientes/README.md`](hardware/impresion/siguientes/README.md).

![Inicio](assets/screenshots/inicio_1920x1080.png)

## Decisiones del prototipo

Detalle en [`docs/decisiones-prototipo.md`](docs/decisiones-prototipo.md).

- **Solo piezas que Miguel ya tiene.**
- **Pantalla:** MSI PRO MP161 E2U 15,6", 1920×1080, **no táctil**. Se usa con ratón y controles; la interfaz sigue preparada para táctil.
- **HP:** HP Slimline 260-a110ns **desmontado**; su placa mini-ITX va dentro de la cuña (adaptador externo de 19,5 V fuera, DVD retirado). El CAD usa el **HDD Toshiba 3,5"** real (`usar_hdd_35 = true`, cotas SFF-8301). El SSD 2,5" queda como opción del mismo parámetro.
- **Vídeo:** la MSI va solo a la Pi (micro-HDMI a mini-HDMI). El HP se ve con Moonlight contra Sunshine en `10.0.0.1`. La vista por defecto es integrada (barra de Orbit OS y Moonlight sin bordes en el hueco). La pantalla completa es la alternativa. Pasos en [`docs/instalacion-pi.md`](docs/instalacion-pi.md). Sin probar en la Pi.
- **Controles:** potenciómetros y botones leídos por un **Arduino Nano** (clon ATmega328P, mini-USB). Sustituye al Micro: el Nano no tiene USB nativo y no puede hacer de teclado HID.
- **Placa de prácticas:** un segundo Nano, independiente, con pines y una OLED 0,96" en la trasera. Miguel tiene 4 OLED; Orbit usa una. El Uno de la foto no se monta: se había pensado para la capturadora, y esa vía no se usa. Detalle en [`software/arduino-pruebas/README.md`](software/arduino-pruebas/README.md).
- **ESP8266 NodeMCU** en su hueco de la bandeja, previsto para la tira LED con WLED. La tira sigue sin identificar.
- **Raspberry Pi 4** con HAT VHF (OLED y antena SMA). Medidas del HAT: pendientes. Si el HAT no deja pasar el GPIO, el conector de la Pi en el panel queda sin cablear.

## Estructura

```
README.md
docs/ESTADO-Y-TRASPASO.md    Estado para retomar el proyecto (léelo primero)
docs/manual-montaje/         Manual de montaje (PDF, 21 páginas, prototipo)
docs/                        Investigación fase 1, diseño mecánico, decisiones del prototipo
hardware/cad/                CAD paramétrico OpenSCAD, STL PROVISIONALES, scripts de comprobación
hardware/impresion/          Base, siguientes impresiones (STEP), plantillas mini-ITX y scripts
hardware/render/             Pipeline de los renders fotorrealistas
assets/renders/              Renders (v1 y láminas del prototipo)
assets/screenshots/          Capturas de la interfaz
software/interface/          Orbit OS Interface (React + TypeScript + Vite)
software/pi-controller/      orbitd: hub WebSocket, servidor de la interfaz y lector del Arduino (Python)
software/hp-agent/           Agente de telemetría y acciones de lista blanca para el HP (Python)
software/shared/             Protocolo v1: PROTOCOLO.md, esquema JSON, actions.json, tipos TS y paquete Python
software/arduino-controls/   Firmware del Nano de mandos (potenciómetros y botones)
software/arduino-pruebas/    Ejemplo del Nano de prácticas (monitor de pines en la OLED)
tests/python/                pytest (protocolo, orbitd, hp-agent, serie, vídeo)
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
2. **Raspberry Pi:** en la Pi, con Wi-Fi, `sudo bash scripts/instalar-pi.sh` y reinicia. El detalle, el emparejamiento y cómo salir del kiosco están en [`docs/instalacion-pi.md`](docs/instalacion-pi.md).
3. **HP:**
   ```bash
   pip install -e software/shared/python -e software/hp-agent
   ORBIT_HP_TOKEN=... python -m hp_agent --hub ws://<ip-pi>:8765/ws
   ```
   Arranca en **dry-run**; con `--live` ejecuta las órdenes de verdad.
4. **Nano de mandos:** `./scripts/compile-arduino.sh` (también compila el ejemplo de prácticas) y luego `arduino-cli upload` con `arduino:avr:nano` o, en clones de bootloader viejo, `arduino:avr:nano:cpu=atmega328old`. Puerto de ejemplo `/dev/ttyUSB0`; si hay más de un USB-serie, `/dev/serial/by-id`. Ver [`software/arduino-controls/README.md`](software/arduino-controls/README.md) y [`software/arduino-pruebas/README.md`](software/arduino-pruebas/README.md).

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
| Firmware del Nano de mandos | **Pendiente de validar** | Compila con arduino-cli 1.5.1 para `arduino:avr:nano` y para `cpu=atmega328old` (2982 bytes, 9 % de la flash). Sin HID. Sin probar en placa |
| Ejemplo OLED del Nano de prácticas | **Pendiente de validar** | `monitor_pines`: 5558 bytes, 18 % de la flash, los dos FQBN. Sin probar en placa ni en pantalla |
| ESP8266 y tira LED (WLED) | **Requiere intervención humana** | La tira sigue sin identificar. D6 del Nano de mandos ya no se reserva |
| Apagado de la Pi (`pi.shutdown`) | **Pendiente** | Requiere permisos de systemd/polkit; ahora solo se registra |
| Modos de la tira LED | **Requiere intervención humana** | Identificar la tira (tipo y tensión) |
| Cambio automático de sistema visible (`pi.switch_visible`, botón B2) | **Implementado (sin hardware)** | orbitd elige el modo disponible: **B DDC/CI** (si está configurado; poco probable con la MSI), **C captura** (capturadora HDMI→USB en la Pi: `ORBIT_CAPTURE_DEVICE` + visor fijo `ORBIT_CAPTURE_CMD`, sin shell) o **A remoto** (visor del escritorio del HP por Ethernet interno, p. ej. Moonlight + Sunshine; `ORBIT_REMOTE_CMD`). Si uno falla pasa al siguiente. Probado con tests unitarios y de integración (dispositivo simulado); **sin verificar** con la MSI, la capturadora, el adaptador ni Sunshine. No se dan latencias ni fps. Ver [`docs/conmutacion-video-usb.md`](docs/conmutacion-video-usb.md) §V |
| HP: **HP Slimline 260-a110ns** (A6-7310, 8 GB, HDMI + VGA, adaptador externo 19,5 V 65 W) | **Identificado y abierto** | **Medido por Miguel:** placa 17 × 17 cm, altura máxima 35 mm. Agujeros: patrón estándar mini-ITX (coincide visualmente con la foto, no medido). Sin escudo I/O. Faltan posición de conectores traseros, botón de encendido, antenas y BIOS: **requieren intervención humana** (`docs/datos-pendientes-hp.md` §A2, con nota de seguridad) |
| Pi 4 confirmada (2026-10-20) con HAT VHF; conexión a la MSI, medidas del HAT y si deja pasar el GPIO | **Requiere intervención humana** | El HAT no está modelado. Ver `software/arduino-pruebas/README.md` |
| Capturadora (comprarla o no: decisión de Miguel), adaptador HDMI→USB-C y soporte DDC/CI de la MSI | **Requiere intervención humana** | Ver `docs/conmutacion-video-usb.md` §V.5 |
| Cifrado del enlace HP↔Pi (`wss://` / mTLS) | **Pendiente** | v0 usa `ws://` con token: solo en red de confianza o cable directo |
| Servicios systemd (Pi), servicio o arranque automático (HP), Chromium en kiosco | **Pendiente** | — |
| CAD (cuña 456,3 × 300,5 × 153,9 mm, 20 STL para Bambu Lab A1 en PETG) | **Pendiente de validar** | Disco vigente: **HDD 3,5"** (SFF-8301; la medición a ojo de ~150 × 100 × 25 mm no entra en el modelo). Separadores mini-ITX con agujero de inserto abierto por arriba; plantilla de agujeros **comprobada en la placa el 2026-10-19**. Base completa en impresión el 2026-10-20, sin resultado. Plantilla de pivotes (C 3,8 / F 3,6 / H 3,4 / J 3,2) **sin resultado**. STEP para SolidWorks en `hardware/impresion/`, sin regenerar el CAD. **NO apto para fabricación**. Detalle en [`docs/ESTADO-Y-TRASPASO.md`](docs/ESTADO-Y-TRASPASO.md) |
| Medidas de potenciómetros, pulsadores y puertos/teclas del MSI | **Requiere intervención humana** | Medir las piezas de Miguel y ajustar `params.scad`/`lib.scad` |

## Tests

Reejecutados el 2026-10-20 en este cambio (Nano, ESP y placa de prácticas):

- `ruff check software tests`: sin avisos.
- `pytest`: **50 pasados**.
- `vitest`: **27 pasados** en 6 archivos (Vitest 2.1.9).
- `tsc -b` y `vite build`: salida 0.
- `arduino-cli` 1.5.1, core `arduino:avr` 1.8.8: `orbit_controls` 2982 bytes (9 %) y `monitor_pines` 5558 bytes (18 %), cada uno en `arduino:avr:nano` y en `cpu=atmega328old`.
- `comprobar_interferencias.py`: sin interferencias, 19 cajas.
- `comprobar_stl.py`: las 20 caben y son mallas cerradas.

Nada de eso se ha probado en la placa, en la Pi ni impreso.

## Documentación

**Estado para retomar:** [`docs/ESTADO-Y-TRASPASO.md`](docs/ESTADO-Y-TRASPASO.md).

**Manual de montaje (prototipo, no listo para fabricar):** [`docs/manual-montaje/MANUAL_MONTAJE_ORBIT.pdf`](docs/manual-montaje/MANUAL_MONTAJE_ORBIT.pdf). Orden de impresión posterior a la base: [`hardware/impresion/siguientes/README.md`](hardware/impresion/siguientes/README.md).

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
