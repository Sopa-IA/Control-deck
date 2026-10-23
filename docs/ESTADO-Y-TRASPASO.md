# Estado y traspaso · Orbit Terminal

Fecha de este documento: **2026-10-20**. Actualizado el **2026-10-23** con los adaptadores de la carcasa ya impresa (no se corta), las dos carcasas futuras (no se imprimen ahora) y la bandeja v3 (ventanas para los Dupont). Sirve para que Miguel, u otro agente, retome el proyecto **sin el historial del chat**.

**Nada de lo que hay aquí está listo para fabricar.** Los STL de la carcasa llevan el prefijo `PROVISIONAL_`. Las comprobaciones geométricas son cajas envolventes y mallas, no un montaje real. El software corre en simulación: no se ha probado con el HP, la Pi, el Arduino ni el monitor, salvo lo que este documento marca como verificado físicamente (la plantilla de agujeros).

La licencia del repositorio es la de Miguel: **Apache-2.0** (`LICENSE`). No se cambia.

---

## 1. Qué es y requisito n.º 1

**Orbit Terminal** es un terminal de sobremesa en forma de cuña. El repositorio se llama `Sopa-IA/Control-deck`; el producto y el software se llaman Orbit Terminal / Orbit OS.

Dentro de la cuña conviven:

- una **Raspberry Pi** que ejecuta Orbit OS y es la que manda;
- la placa de un **HP Slimline 260-a110ns** sacado de su caja, que sigue corriendo **Windows 10 Home** por su cuenta;
- un **monitor MSI** compartido;
- un **Arduino Nano** (clon, mini-USB) que lee potenciómetros y botones;
- un **ESP8266** previsto para la tira LED, y un **segundo Nano** de prácticas con pines y una OLED en la trasera (el segundo Nano no consta en la foto: **PENDIENTE** de tenerlo);
- luces ámbar.

**Requisito n.º 1.** La Pi controla todo. El cambio entre lo que se ve de la Pi y lo que se ve del HP es **automático desde Orbit OS** (acción `pi.switch_visible`, botón B2 por defecto y botón de la sección Sistemas). Miguel **no** cambia la entrada a mano en el menú del monitor. El HP no se apaga ni se convierte en un esclavo: Windows sigue independiente.

Desde el 2026-10-22 el montaje que instala `scripts/instalar-pi.sh` es solo Moonlight: la MSI va a la Pi y el HP se ve por el Ethernet interno. La vista por defecto es integrada. Ver [`instalacion-pi.md`](instalacion-pi.md). No está probado en hardware.

El 2026-10-23 la carcasa ya está impresa (los cuatro trozos). **No se corta, no se taladra y no se lima.** Los adaptadores entran en los huecos que ya hay. Aparte, hay dos STL `FUTURO_carcasa_*_sin_adaptadores`: **no imprimir ahora**.

La bandeja de huecos también está impresa y **no sirve**: las paredes largas llegan hasta la PCB y encierran los pines macho. No se corta. Hay que imprimir la v3 (`PROVISIONAL_bandeja_servicio`, 126,00 × 237,49 × 20,60 mm, 173,2 cm³, pieza de noche, unas 14 h sin laminar). La malla vieja queda en `OBSOLETA_bandeja_huecos_v2_ya_impresa` (181,71 cm³). Las placas no se mueven. Los tornillos son los mismos. Un Dupont hembra recto (~14,5 mm) no entra en los 13 mm bajo la PCB, y subir la placa 7,5 mm chocaría con la tina en el ESP (4,8 mm en la esquina delantera). **FALTA: comprar** Dupont hembra acodado a 90°, uno por pin (30 por cada Nano; los del ESP, al contarlos), y un step-down LM2596 de 43 × 21 mm a 5 V. En ese hueco hay ahora un convertidor ZERO/SPAN de 4–20 mA. El reborde de ese hueco acaba a ras de la PCB y no encierra un borne de arriba.

Adaptadores para ahora (piezas de día, sin tornillo nuevo):

- I/O frontal de `carcasa_x0_y1`: la ventana sigue en 62 × 18 mm. `PROVISIONAL_marco_io_frontal` (67,4 × 26,0 × 3,8 mm, 1,58 cm³) entra a presión desde fuera. Quedan a mano los dos USB y, si asoma, el lector SD. Se pierden los dos jacks de audio del frontal (el audio sigue en la placa trasera). Si el lector no cabe en la boca de 59,8 × 15,8 mm, se pierde también.
- Placa del HP: la ventana de 159,75 × 45,45 no se toca. `io_huecos` sale de la foto del 2026-10-23, escalada a ese ancho (la regla está delante y no se usa). Mirando la trasera: VGA a la izquierda y jack DC a la derecha, ±2 mm. Antes de montar, `PRUEBA_placa_io_hp` tiene que caer sobre el VGA azul. No se pierde ningún puerto de esa foto.
- Trasera de `carcasa_x1_y1`: los agujeros impresos son el panel genérico, no la Pi. `PROVISIONAL_placa_puertos_pi` (85,0 × 39,0 × 3,8 mm, 6,94 cm³) los tapa por dentro, con un tetón en cada uno. Los cuatro USB y el RJ45 de la Pi se alcanzan por la tapa del techo: la cara del conector acaba en y = 255,5 y la pared interior está en y = 297,5. Por esa trasera, esos puertos se pierden. Un alargador USB o RJ45 sería FALTA y esta tapa no lo usa.
- Panel de pines: los Ø1,6 se quedan. `PROVISIONAL_panel_pines` (80,0 × 78,0 × 4,6 mm, 9,19 cm³) va por fuera y se engancha en las ventanas de OLED y de PRG. Quedan a mano los 40 pines de la Pi y los 24 del Nano (D2–D13 y A0–A7, GND, RST, 5 V, 3,3 V). Se pierden D0, D1 y cualquier pin de una regleta 2×15 sin agujero. **FALTA: comprar** regleta macho 2×20 y regleta macho 2×12, pines de al menos 11 mm, y cables Dupont hembra-hembra. El CSV de electrónica no se ha podido leer.

Carcasa futura, no imprimir ahora (si algún día se imprime, es pieza de noche):

- `FUTURO_carcasa_x0_y1_sin_adaptadores`: ventana frontal de 94 × 18 mm (y = 171,5 a 265,5, z = 74 a 92). Caben jacks, USB y lector. No hace falta marco.
- `FUTURO_carcasa_x1_y1_sin_adaptadores`: dos pasos de cable alineados con la Pi, y ranuras de regleta Pi 2×20 y Nano 2×15 en lugar de los Ø1,6. No hace falta tapa ni careta.

En `consumo.md` (repo del inventario, no este): el M3×6 avellanado sigue en 4 de 40 y el inserto M3 4×5 sigue en 6 de 30. Los adaptadores no gastan tornillo. La bandeja v3 tampoco: mismos M3×12, M3×8 y grapas. Anota como compra los Dupont acodados a 90° y el LM2596 de 43 × 21 mm a 5 V.

Orden que usa `software/pi-controller/orbitd/video.py`: si el modo B está configurado y responde, ese; si no, el modo C si la capturadora está configurada; si no, el modo A. Si uno falla, prueba el siguiente. No hay cifras de latencia ni de fps: no se han medido.

---

## 2. Mapa del repositorio

| Ruta | Para qué |
|---|---|
| `README.md` | Entrada corta. Este documento es el estado largo. |
| `LICENSE` | Apache-2.0, de Miguel. No modificarla. |
| `docs/ESTADO-Y-TRASPASO.md` | Este archivo. |
| `docs/decisiones-prototipo.md` | Decisiones del 2026-10-18. El disco ya no es el SSD recomendado: ver la nota del 2026-10-20 en esa tabla. |
| `docs/diseno-mecanico.md` | Diseño v1 + HP v3. **Varios párrafos siguen hablando del SSD 2,5".** La geometría vigente está en `params.scad`, no en ese texto. |
| `docs/conmutacion-video-usb.md` | Vídeo y cambio de sistema (modos A, B y C). El montaje de la Pi es el de `instalacion-pi.md`. |
| `docs/instalacion-pi.md` | Arranque directo a Orbit OS, kiosco, Moonlight y el marco integrado. |
| `docs/ardu-lab.md` | Programar el Nano de prácticas desde Orbit OS. El de mandos queda bloqueado. |
| `docs/datos-pendientes-hp.md` | Ficha del HP, fuentes y lista H-1…H-12. Parte de H-2 y H-8 ha avanzado; el archivo no se ha reescrito entero. |
| `docs/informe-fase1.md`, `pantallas.md`, `controles.md`, `raspberry-pi.md`, `alimentacion-preliminar.md`, `incertidumbres-hardware.md` | Investigación de la fase 1. Prevalecen las decisiones del prototipo cuando no coinciden. |
| `hardware/cad/params.scad` | Todas las cotas, con etiqueta de origen. |
| `hardware/cad/piezas.scad` | Bisel, base, bandeja, soportes, guía de luz, anillo, pomo, pletina. |
| `hardware/cad/carcasa.scad`, `lib.scad`, `componentes.scad`, `ensamblaje.scad`, `partes.scad` | Carcasa, utilidades, marcadores, ensamblaje y corte para la cama. |
| `hardware/cad/exportar.sh` | Borra `export/stl/*.stl` y los regenera en paralelo. |
| `hardware/cad/render.sh` | Renders técnicos de OpenSCAD (no los fotorrealistas). |
| `hardware/cad/comprobar_interferencias.py` | Cajas envolventes. No es un choque de mallas. |
| `hardware/cad/comprobar_stl.py` | Cama 256³, margen 10 mm, malla cerrada y volumen. |
| `hardware/cad/stl_a_step_freecad.py` | STEP facetado opcional de `export/step/`. Esos archivos siguen fuera del repo (ver `export/step/LEEME.md`). Los STEP que sí están versionados viven en `hardware/impresion/`. |
| `hardware/cad/export/stl/` | 20 STL `PROVISIONAL_*` + `LEEME.md`. No hay copias numeradas en `impresion/`. |
| `hardware/impresion/base/` | Guía de la base (`LEEME.txt`), vistas, pared trasera de prueba, dos scripts y `STEP/` de esas piezas. |
| `hardware/impresion/siguientes/` | Orden de lo que se imprime después de la base, STEP AP214 y vistas. Los STL siguen en `export/stl/`. |
| `hardware/impresion/plantillas/` | Plantilla de agujeros mini-ITX (verificada) y plantilla de pivotes (sin resultado) + `vista_pivotes.png`. |
| `docs/manual-montaje/MANUAL_MONTAJE_ORBIT.pdf` | Manual de montaje, 21 páginas, dibujos del CAD. Prototipo. |
| `hardware/render/` | Pipeline fotorrealista: `escena_blender.py`, `postproceso.py`, `exportar_partes.sh`, `render_fotorrealista.sh`, `descargar_modelos.sh`, `convertir_step.py`, `etiqueta_hdd.py`, `partes_render.scad`, `CREDITOS-MODELOS.md`. |
| `assets/renders/` | Renders antiguos del diseño (antes de los fotorrealistas). |
| `assets/renders/prototipo/` | Láminas del PR #5. `06_lo-que-tienes-vs-donde-va_con-fotos.png` es la única imagen con recortes de fotos de Miguel, y él autorizó publicarla. El resto no son fotos. |
| `assets/screenshots/` | Capturas de la interfaz en simulación. |
| `software/interface/` | Orbit OS: React + TypeScript + Vite. Secciones: Inicio, Sistemas, Hardware, Controles, Herramientas, Configuración. |
| `software/pi-controller/orbitd/` | Hub de la Pi: `__main__.py` (CLI), `hub.py` (WebSocket y acciones), `serial_events.py` (Arduino), `telemetry.py` (psutil local), `video.py` (modos A/B/C). |
| `software/hp-agent/` | Agente del HP: `agent.py`, `actions.py` (órdenes fijas, sin shell), `config.py`. Por defecto dry-run. |
| `software/shared/` | Protocolo v1: `PROTOCOLO.md`, `actions.json`, `controls.default.json`, `schemas/protocol.schema.json`, `ts/protocol.ts`, `python/orbit_protocol`. |
| `software/arduino-controls/` | Firmware del Nano de mandos. Pines por defecto: P1 A0, P2 A1, B1 D2, B2 D3. Sin HID. |
| `software/arduino-pruebas/` | Ejemplo del Nano de prácticas: OLED I2C y mapa del panel trasero. No habla con orbitd. |
| `scripts/setup-dev.sh` | Crea `.venv` e instala Python y npm. |
| `scripts/test-all.sh` | ruff + pytest + tsc + vitest. |
| `scripts/dev-sim.sh` | Compila la interfaz y arranca orbitd simulado en `http://127.0.0.1:8765/`. |
| `scripts/gen-token.sh` | Token local en `.env` (gitignorado). |
| `scripts/compile-arduino.sh` | Compila el firmware si hay `arduino-cli`. |
| `scripts/screenshots.mjs` | Capturas; hace falta orbitd y Chrome. |
| `tests/python/` | pytest: `test_protocol.py`, `test_serial.py`, `test_hub.py`, `test_hp_agent.py`, `test_video.py`. |
| `.github/workflows/ci.yml` | Dos jobs: Python (ruff + pytest, 3.12) e interfaz (npm ci, tsc, vitest, build, Node 20). En el PR #5 también apareció CodeQL; no está en este workflow. |

`.env`, `*.env` (salvo `*.env.example`), `config.local.*`, `secrets/`, `*.token`, `*.pem` y `*.key` están en `.gitignore`. El token de los tests es el fixture que ya existía (`token-de-prueba-0123456789`).

Asignación por defecto (`controls.default.json`): P1 `hp.volume_set`, P2 `ui.scroll`, B1 `ui.power_menu`, B2 `pi.switch_visible`. El volumen HID no es posible: el Nano es un ATmega328P, sin USB nativo. `ENABLE_HID_VOLUME 1` no compila. El volumen del HP lo aplica hp-agent.

---

## 3. Lo que Miguel ya tiene

Sin compras. La capturadora del modo C **no** está en esta lista: es una referencia vista en Amazon, no un aparato que tenga.

| Pieza | Qué se sabe | Etiqueta |
|---|---|---|
| HP Slimline 260-a110ns, sacado de la caja | Placa de la familia Iris. Nombre "Iris-A6" es provisional (datos del propietario, 2026-10-18). AMD A6-7310, 8 GB DDR3L, Windows 10 Home. | Datos del propietario 2026-10-18. La ficha oficial de este P/N no se encontró; las hermanas Iris-E2 / Iris-A8 están en `docs/datos-pendientes-hp.md`. |
| Placa | 17 × 17 cm, mini-ITX. | **VERIFICADA** por Miguel, 2026-10-18 (instrumento no indicado). En el CAD: `mitx = 170`. |
| Altura máxima sobre la placa | 35 mm (disipador con ventilador). | **VERIFICADA** por Miguel, 2026-10-18. `hp_comp_h = 35`. |
| Agujeros C, F, H, J | Patrón estándar mini-ITX. | **DE FUENTE** (estándar mini-ITX / plano comercial citado en `params.scad`). **VERIFICADA FÍSICAMENTE** el 2026-10-19: Miguel imprimió `PRUEBA_plantilla_agujeros_HP.stl` y los cuatro agujeros cuadraron con su placa. No es una medida de calibre. |
| Escudo I/O | No hay. Los conectores asoman por la chapa de la caja. | **FOTO** 2026-10-18, no es una medida. |
| Puertos que indica el propietario | 2× USB 3, 4× USB 2, HDMI, VGA, RJ45, audio, lector SD. | Datos del propietario 2026-10-18. El I/O trasero de la hermana Iris-E2 es 2× USB 3 + 2× USB 2, así que 2× USB 2 en el frontal es una **deducción PENDIENTE**, no una medida. Posición de cada conector: **PENDIENTE**. |
| Wi-Fi | Tarjeta M.2 con antenas, a sacar fuera de la caja original. | **FOTO**. Longitud de cables: **PENDIENTE** (H-9). |
| Alimentación | Adaptador original externo 65 W, 19,5 V. Queda **fuera** de la cuña, sin modificar. | Datos del propietario. El diámetro del jack es **PENDIENTE**. Dentro de la cuña no hay red eléctrica. |
| DVD | Se retira. No se modela. | Decisión. |
| HDD Toshiba 3,5", marca de fecha MAR-2017 | El disco real. Miguel lo midió a ojo el 2026-10-20: ~150 × 100 × 25 mm. | Esa medición es **a ojo**. El CAD **no la usa**. Usa SFF-8301: 101,6 × 147 × 26,1 mm (**DE FUENTE**). |
| Raspberry Pi 4 + HAT VHF | Miguel lo confirma el 2026-10-20. El HAT trae OLED y antena SMA plegable; dice que la carcasa cierra con holgura. Ya da imagen en la MSI; no se sabe por qué entrada. | Placa: **DE FUENTE** (dibujo mecánico de la Pi 4, 85 × 56, agujeros 58 × 49) y dato de Miguel. Altura de la Pi y todo el HAT: **PENDIENTE**. `pi_h = 20` no incluye el HAT. Si el HAT no deja pasar el GPIO, el conector del panel no se cablea. |
| Arduino Nano (mandos) | Clon ATmega328P, mini-USB, CH340 probable (dato de Miguel, chip no leído). Lee potenciómetros y botones. | PCB 18 × 45 mm: **DE FUENTE** ([tienda oficial](https://store.arduino.cc/products/arduino-nano)). La placa de la foto no se ha medido. Alturas: **PENDIENTE**. |
| Arduino Uno | El de la foto. No se monta. | 68,6 × 53,4 mm: **DE FUENTE** ([Uno Rev3](https://store.arduino.cc/products/arduino-uno-rev3)). Cabe solo en el hueco delantero y no cabe bien con el ESP y un cable USB-B. |
| Segundo Nano (prácticas) | Independiente del de mandos. Pines y OLED en la trasera. | Misma cota de catálogo. **PENDIENTE**: la foto no muestra un segundo Nano. Miguel acepta uno si el Uno no cabe. No es una compra hecha. |
| ESP8266 de la tira | Hueco fijo de la bandeja, x = 346, y = 86, USB hacia +Y. Previsto para WLED. La proto 30 × 70 ya no tiene puesto. | La placa de la foto se estima en 58 × 31 mm [PENDIENTE]. No se usa el DEVKIT 1.0 (25,4 × 48,3) como cota. |
| OLED 0,96" SSD1306 | Ventana en la trasera, junto al panel de pines. La controla el Nano de prácticas. | Referencia **DE FUENTE**: [Waveshare 0.96inch OLED (B)](https://www.waveshare.com/0.96inch-oled-b.htm), PCB 33,0 × 33,5, área visible 21,70 × 11,20, 128×64, amarillo/azul. La ficha dice tensión 3,3 V y la [wiki](https://www.waveshare.com/wiki/0.96inch_OLED_(B)) dice 3,3 V/5 V. El módulo no está elegido ni medido. |
| MSI Pro MP161 E2U | 15,6", 1920×1080, no táctil. Mini-HDMI y 2 USB-C con DP Alt. | Envolvente 362,26 × 233,84 × 18,8 mm y área activa 344,16 × 193,59 mm: **DE FUENTE** (ficha MSI; el manual da 232,92 mm de alto y el CAD usa el mayor). Posición del área activa y de los puertos del canto: **PENDIENTE** (el área se supone centrada). |
| Potenciómetros y pulsadores | Los suyos. El CAD usa marcadores genéricos de 24 mm y 16 mm. Eje de 6 mm acordado. | **PENDIENTE** de medir. `eje_pot_d` está marcado acordado y sin medir. |
| Tira LED | La suya. Tipo y tensión desconocidos. | **PENDIENTE**. |
| Adaptador Mini-HDMI → HDMI | Lo tiene. En el modo C iría de la Pi a la Mini-HDMI de la MSI. | Existencia: dato del propietario. Modelo: **PENDIENTE**. |
| Adaptador UGREEN | Modelo y sentido sin confirmar. Probablemente USB-C → HDMI, que es el sentido contrario al que haría falta para el modo B. | **PENDIENTE**. |
| Impresora | Bambu Lab A1, volumen 256 × 256 × 256 mm, marco abierto. Material del diseño: PETG. | Volumen: **DE FUENTE** (ficha Bambu Lab). |

La capturadora de referencia (marca SUOFEIXIANG, texto "4K30 entrada / 1080p", 14,69 € vistos el 2026-10-18, sin URL) **no se ha comprado**. La reserva nominal sigue siendo 72 × 30 × 20 mm. En la bandeja con huecos fijos el nido se ha quitado (caía sobre el Nano de mandos). Dónde va el aparato es [PENDIENTE]. No es la medida de un aparato.

---

## 4. Cotas vigentes en `params.scad`

Unidades: milímetros. Ejes: X ancho, Y fondo (frente en 0), Z altura.

| Cota | Valor | Etiqueta en el CAD |
|---|---|---|
| Envolvente W × D × H | 456,3 × 300,5 × 153,9 (sin pies; +4 mm con pies) | Calculada. La imprimió `comprobar_interferencias.py` el 2026-10-20. |
| Inclinación, suelo, pared, pies | 30°, 4, 3, 4 | DISEÑO |
| Cama y margen | 256³, margen 10 | FUENTE (A1) y DISEÑO |
| Placa HP | 170 × 170, componentes 35, PCB 1,6 | MEDIDO / MEDIDO / PENDIENTE (PCB típico) |
| Separador HP | 6,35 | FUENTE estándar ATX |
| Agujero de inserto en el separador | Ø4, profundidad `inserto_l + 0,5` = 6,2, abierto por arriba | `inserto_d` y `inserto_l` (5,7) son **PENDIENTE** |
| Paso M3 | Ø3,4 (`tornillo_d`) | DISEÑO. También en la cara superior de las torretas de empalme |
| Ventana I/O | 158,75 × 44,45 | FUENTE estándar ATX. Posición lateral `hp_io_x0 = 5,6`: **PENDIENTE** |
| Disco en el modelo | 101,6 × 147 × 26,1 | FUENTE SFF-8301. No es la medición a ojo |
| Patas del soporte / agujero lateral | 14 mm / 3,18 mm del lateral | DISEÑO (para librar las pletinas) / FUENTE SFF-8301 A5 |
| Pi 4 | 85 × 56, agujeros 58 × 49, alto 20 | FUENTE del dibujo Pi 4. Modelo confirmado por Miguel el 2026-10-20. El alto no incluye el HAT. HAT: PENDIENTE |
| Nano de mandos | 45 × 18 | FUENTE tienda oficial. Alturas y el mini-USB del clon: PENDIENTE |
| Soporte del Nano | ancho 26, largo 70, y0 = 59 | El largo y el y0 están congelados a la bandeja impresa (torretas en y = 63 y y = 125). El ancho sí sigue a la placa |
| Canal USB de la bandeja | boca y = 143,5, ancho 10 | DISEÑO congelado. No se recalcula con el Nano. Si pasa un mini-USB: PENDIENTE |
| Riel de placas | Tramo delantero 7,1 × 71,8 × 6 desde (397,26, 58). Anclaje 13,0 × 71,7 × 6 desde (395,46, 129,8) | DISEÑO. Atornillado a (401,26, 146,492) y (401,26, 194,492). Esas cotas salen de `psu_*` y no se mueven |
| Puestos de carro | y = 76, 90 y 105 | DISEÑO. A la vez solo el 76 y el 105. El 90 va solo |
| ESP8266 (marcador) | 25,4 × 48,3, alto 11 sobre el carro, puesto y = 105, USB hacia −X | FUENTE de la envolvente. Alto y enchufe (10 mm) DISEÑO. No es la placa de la foto |
| Nano de prácticas (marcador) | 18 × 45, alto 11 sobre el carro, puesto y = 76, mini-USB hacia −X | Misma cota de catálogo. Enchufe 12 mm DISEÑO |
| Proto 30 × 70 | Carro aparte, mismo puesto que el ESP | DISEÑO. No es una placa medida. Al borde de la bandeja le quedan 2,3 mm: PENDIENTE |
| Panel de prácticas | x = 250, z = 68, 74 × 72 | DISEÑO, en la cara trasera de `carcasa_x1_y1` |
| OLED (marcador) | 33,5 × 12 × 33,0; ventana 24 × 14 | FUENTE de la PCB Waveshare; profundidad y ventana DISEÑO |
| Potenciómetro / pulsador | genérico 24 mm / 16 mm | PENDIENTE |
| Adaptador de vídeo (hueco) | 72 × 32 × 16, `usar_adaptador_video = true` | PENDIENTE. El hueco se conserva aunque el modo B sea poco probable |
| Capturadora (reserva) | Nominal 72 × 30 × 20; el nido de la bandeja v2 es 26 × 32 × 14 | DISEÑO. El aparato no está medido. El hueco del adaptador de vídeo se quitó de la bandeja |
| KVM | `usar_kvm = false` | DISEÑO |

Agujeros HP en coordenadas de la carcasa, los que imprimió `comprobar_base_hdd.py` el 2026-10-20: C (23,35, 284,332), F (180,83, 261,472), H (23,35, 129,392), J (180,83, 129,392). C y F caen en `base_x0_y1`; H y J en `base_x0_y0`. Las bases de la derecha no llevan separadores del HP.

---

## 5. Piezas y STL

Cajas medidas el 2026-10-20 con el mismo criterio que `comprobar_stl.py` (vértices del ASCII STL). Volumen en cm³ del sólido. **No autoriza a fabricar.**

Orientación y soportes: solo donde un archivo del repo lo dice. Si no está escrito, la celda dice «no documentado».

### Carcasa (`hardware/cad/export/stl/`)

| STL | Caja X×Y×Z (mm) | Vol. | Qué es | Impresión | Estado |
|---|---|---|---|---|---|
| `PROVISIONAL_base_x0_y0` | 228,13 × 150,13 × 10,35 | 134,18 | Delante-izquierda: separadores H y J, ranuras, una pata del disco | Cara plana en la cama, sin soportes (`hardware/impresion/base/LEEME.txt`) | La base completa está en impresión desde el 2026-10-20. Sin resultado |
| `PROVISIONAL_base_x0_y1` | 228,13 × 150,13 × 10,35 | 113,28 | Detrás-izquierda: separadores C y F, ranuras, una pata del disco | Igual | Igual |
| `PROVISIONAL_base_x1_y0` | 228,13 × 150,13 × 8,99 | 92,83 | Delante-derecha: hueco delantero de la bandeja, una pata del disco | Igual | Igual |
| `PROVISIONAL_base_x1_y1` | 228,13 × 150,13 × 8,99 | 81,02 | Detrás-derecha: hueco de la bandeja (Pi), una pata del disco | Igual | Igual |
| `PROVISIONAL_pletina_empalme_x4` | 30,00 × 10,00 × 3,00 | 0,84 | Una pletina. Hay que imprimir 4 | Cara plana, sin soportes (misma guía) | No consta impresión de este STL |
| `PROVISIONAL_soporte_disco` | 111,60 × 147,00 × 17,99 | 18,64 | Bandeja del HDD 3,5" (patas 14 mm, colisos a 3,18 mm del lateral) | Única pieza de la guía que pide soportes: boca abajo, bandeja contra la cama, soportes solo en la cama | El soporte **2,5"** (SSD) se imprimió y salió pequeño. Este STL 3,5" no consta como impreso |
| `PROVISIONAL_bandeja_servicio` | 126,00 × 237,49 × 20,60 | 173,2 | Bandeja v3. Ventanas de 13 mm en los cantos largos (Nano 40 mm, ESP 53 mm). Misma ala, misma Pi, mismos 4 M3 | Plancha abajo, pieza de noche, unas 14 h sin laminar. No cortar la carcasa | Sustituye a la v2 ya impresa |
| `OBSOLETA_bandeja_huecos_v2_ya_impresa` | 126,00 × 237,49 × 20,60 | 181,71 | La bandeja de paredes cerradas que Miguel ya imprimió | No reimprimir y no cortar | Obsoleta: encierra los pines |
| `PROVISIONAL_carcasa_x0_y0` | 228,13 × 150,25 × 95,36 | 104,65 | Delante-izquierda | `diseno-mecanico.md` recomienda la cara de corte sobre la cama. Soportes: no documentado | No probada |
| `PROVISIONAL_carcasa_x0_y1` | 228,13 × 150,25 × 150,93 | 213,68 | Detrás-izquierda: ventana I/O del HP, pasacables, I/O frontal, pulsador y LED | Igual | No probada. Volumen 213,68 cm³ |
| `PROVISIONAL_carcasa_x1_y0` | 228,13 × 150,25 × 95,36 | 115,54 | Delante-derecha | Igual | No probada |
| `PROVISIONAL_carcasa_x1_y1` | 228,13 × 150,25 × 150,93 | 233,81 | Detrás-derecha. Guías Ø2,5 en los postes de la tapa y en sus tres orejetas (antes 233,65). Rejilla de la Pi desde z ≈ 90. Panel de pines y OLED siguen | Igual | No probada. Hay que imprimir este STL, no el de 233,65 ni los anteriores |
| `PROVISIONAL_bisel_x0_y0` | 190,83 × 126,62 × 3,60 | 24,89 | Trozo de bisel | Plano, cara vista abajo (`diseno-mecanico.md`). Soportes: no documentado | No probado |
| `PROVISIONAL_bisel_x0_y1` | 190,83 × 126,62 × 3,60 | 24,89 | Trozo de bisel | Igual | No probado |
| `PROVISIONAL_bisel_x1_y0` | 190,83 × 126,62 × 3,60 | 24,89 | Trozo de bisel | Igual | No probado |
| `PROVISIONAL_bisel_x1_y1` | 190,83 × 126,62 × 3,60 | 22,81 | Trozo de bisel (menos volumen: huecos de mandos) | Igual | No probado |
| `PROVISIONAL_guia_luz_frontal_0` | 201,13 × 9,00 × 6,95 | 9,82 | Tramo de guía de luz frontal | No documentado | No probada |
| `PROVISIONAL_guia_luz_frontal_1` | 201,13 × 9,00 × 6,95 | 9,82 | El otro tramo | No documentado | No probada |
| `PROVISIONAL_anillo_luz_x2` | 41,00 × 41,00 × 5,60 | 1,82 | Un anillo. Imprimir 2 | No documentado | No probado |
| `PROVISIONAL_pomo_x2` | 30,00 × 30,00 × 17,00 | 11,02 | Un pomo. Imprimir 2 | No documentado | Impreso o en impresión. Sin resultado comunicado |
| `PROVISIONAL_soporte_arduino` | 26,00 × 70,00 × 19,10 | 9,58 | Soporte de la bandeja v1. El STL no se ha vuelto a exportar. En la bandeja v2 no tiene torretas: no se monta | — | Ya impreso o en impresión para la v1. No vale en la v2 |
| `PROVISIONAL_carro_nano` | 51,45 × 16,40 × 25,10 | 6,54 | **Obsoleto.** Carro de la bahía v2. La bandeja ya no tiene cajeado | — | No imprimir |
| `PROVISIONAL_carro_esp` | 64,45 × 29,60 × 25,10 | 3,94 | **Obsoleto.** Carro del ESP de la bahía v2 | — | No imprimir |
| `PROVISIONAL_carro_proto30x70` | 76,45 × 28,40 × 25,10 | 10,79 | **Obsoleto.** Carro de la proto. Esa placa ya no tiene puesto | — | No imprimir |
| `PROVISIONAL_retenedor_nano` | 29,40 × 51,20 × 10,40 | 1,38 | **Obsoleto.** Clip de la cuna. El Nano de mandos va en su hueco, con cuatro M3 | — | No imprimir |
| `PROVISIONAL_tapa_pi` | 92,00 × 46,79 × 4,60 | 12,43 | Placa dentro del lomo plano (y 248,50–295,29). Tetón 71,4 × 41,4 × 2,2 en el hueco 72 × 42. Dos M3, ranuras y agujeros de ventilador. La de 94 × 54 ya impresa no se usa | Plana, chaflán abajo | Regenerada el 2026-10-23. La carcasa no se toca |

`comprobar_stl.py` (2026-10-21, bandeja v2): las 25 mallas caben en 256³ con 10 mm de margen y están cerradas. El script imprime el volumen con un decimal. Las cifras de dos decimales de la bandeja, los carros, el clip, la tapa y `carcasa_x1_y1` salen de los vértices de esta pasada. `PROVISIONAL_riel_placas` ya no está.

### Pruebas (`hardware/impresion/`)

| STL | Caja X×Y×Z | Vol. | Qué es | Impresión | Estado |
|---|---|---|---|---|---|
| `base/PRUEBA_pared_trasera_IO_HP.stl` | 228,13 × 92,01 × 15,00 | 47,92 | Recorte de la pared trasera de `carcasa_x0_y1` (ventana I/O + pasacables) | Cara exterior abajo, sin soportes (guía de la base) | No probada |
| `plantillas/PRUEBA_plantilla_agujeros_HP.stl` | 170,00 × 170,00 × 4,60 | 9,20 | Barras finas con agujeros C, F, H, J a Ø3,0 | Geometría plana (el STL está en XY). Soportes: no documentado | **VERIFICADA FÍSICAMENTE** el 2026-10-19: los 4 agujeros cuadran con la placa |
| `plantillas/PRUEBA_plantilla_pivotes_HP.stl` | 164,48 × 161,94 × 7,60 | 8,38 | Los mismos centros, con pivotes Ø3,8 (C), 3,6 (F), 3,4 (H) y 3,2 (J) en lugar de tornillos. Miguel prefiere esta vía | Geometría plana con pivotes hacia arriba. Soportes: no documentado | Pendiente de resultado |

`prueba_pared_trasera_io.scad` hace `include <../../cad/piezas.scad>`. OpenSCAD 2021.01 lo compiló el 2026-10-20 (salida 0, 155095 bytes). Ese STL nuevo **no** es idéntico al del paquete (misma talla, distinta teselación). En el repo se queda el STL del paquete.

Vistas de la base: `vista_base.png` y `vista_base_planta.png`. Montada, la guía dice 456,3 × 300,5 mm.

La orientación de carcasa, bisel, guías, anillo, pomo y soporte del Arduino que antes figuraba como no documentada está ahora en `hardware/impresion/siguientes/README.md`. El CAD no ha cambiado.

---

## 6. Después de la base: impresiones, STEP y manual

Añadido el 2026-10-20, encima del `main` `3978879`, sin tocar `hardware/cad/` ni regenerar STL. Sigue siendo un **prototipo**. Ninguna de estas piezas está lista para fabricar ni consta como montada.

Guía de impresión: [`hardware/impresion/siguientes/README.md`](../hardware/impresion/siguientes/README.md). Vista del conjunto: `hardware/impresion/siguientes/vista_siguientes_conjunto.png`.

Orden recomendado, con el STL real (no hay copia numerada):

Los STL de las piezas 02 a 15 están en `hardware/cad/export/stl/`. Los STEP 01 a 15 están en `hardware/impresion/siguientes/STEP/`, con el mismo nombre de pieza y el prefijo de orden.

| Nº | Pieza | STL | STEP | Notas de estado |
|---|---|---|---|---|
| 01 | Plantilla de pivotes C 3,8 / F 3,6 / H 3,4 / J 3,2 | `hardware/impresion/plantillas/PRUEBA_plantilla_pivotes_HP.stl` | `01_PRUEBA_plantilla_pivotes_HP.step` | **Pendiente de resultado.** Hasta entonces la base sigue con insertos M3 |
| 02 | Bandeja de servicio v3 | `PROVISIONAL_bandeja_servicio.stl` (126,00 × 237,49 × 20,60, 173,2 cm³) | `02_…step` **desfasado** (sigue siendo la v1) | Pieza de noche, unas 14 h. La v2 impresa es `OBSOLETA_bandeja_huecos_v2_ya_impresa` y no se usa. El STEP no se ha regenerado |
| 03 | Carcasa detrás-izquierda | `PROVISIONAL_carcasa_x0_y1.stl` | `03_PROVISIONAL_carcasa_x0_y1.step` (malla) | No impresa. Después de probar la pared I/O |
| 04 | Carcasa delante-izquierda | `PROVISIONAL_carcasa_x0_y0.stl` | `04_PROVISIONAL_carcasa_x0_y0.step` (malla) | No impresa |
| 05 | Carcasa delante-derecha | `PROVISIONAL_carcasa_x1_y0.stl` | `05_PROVISIONAL_carcasa_x1_y0.step` (malla, **no válido**) | No impresa. 12 triángulos cruzados en x ≈ 406,3 |
| 06 | Carcasa detrás-derecha | `PROVISIONAL_carcasa_x1_y1.stl` (233,81 cm³: guías autorroscantes) | `06_…step` (malla, **desfasado**) | Imprimir este STL. Las otras tres carcasas no cambian. El STEP no incluye la tapa |
| 07-10 | Bisel, cuatro trozos | `PROVISIONAL_bisel_x0_y0.stl`, `x0_y1`, `x1_y0`, `x1_y1` | `07_` a `10_` (malla) | No impresos |
| 11-12 | Guías de luz | `PROVISIONAL_guia_luz_frontal_0.stl` y `_1.stl` | `11_` y `12_` (sólido) | No impresas |
| 13 | Anillo de luz (imprimir 2) | `PROVISIONAL_anillo_luz_x2.stl` | `13_PROVISIONAL_anillo_luz_x2.step` (sólido) | No impreso |
| 14 | Pomo (imprimir 2) | `PROVISIONAL_pomo_x2.stl` | `14_…step` **desfasado** | Regenerado: inserto M3 4×5 y M3×12 de botón. Pieza de día. El STEP no se ha regenerado |
| 15 | Soporte del Nano (v1) | `PROVISIONAL_soporte_arduino.stl` (26,00 × 70,00 × 19,10, 9,58 cm³) | `15_…step` (sólido, **desfasado**) | No se monta en la bandeja v2. Sirve solo si se sigue con la bandeja ya impresa |
| 16 | Retenedor del Nano de mandos | `PROVISIONAL_retenedor_nano.stl` (29,40 × 51,20 × 10,40, 1,38 cm³) | No hay STEP | Clip de la cuna v2. El riel suelto ya no está |
| 17 | Carro Nano de prácticas | `PROVISIONAL_carro_nano.stl` (51,45 × 16,40 × 25,10, 6,54 cm³) | No hay STEP | Puesto y = 90. Dos M3 al cajeado. Pines abajo |
| 18 | Carro ESP8266 | `PROVISIONAL_carro_esp.stl` (64,45 × 29,60 × 25,10, 3,94 cm³) | No hay STEP | Puesto y = 124. Dos M3. No a la vez que el 19 |
| 19 | Carro proto 30 × 70 | `PROVISIONAL_carro_proto30x70.stl` (76,45 × 28,40 × 25,10, 10,79 cm³) | No hay STEP | Mismos tornillos que el 18 |
| 20 | Tapa de la Pi | `PROVISIONAL_tapa_pi.stl` (92,00 × 46,79 × 4,60, 12,43 cm³) | No hay STEP | Dos M3×8 de botón en los postes ya impresos. La tapa de 94 × 54 no se usa |

Los STEP de la base (4 bases, pletina, soporte del disco, pared I/O y plantilla de agujeros) están en `hardware/impresion/base/STEP/` y no hay que reimprimirlos.

**STEP de malla se editan peor en SolidWorks.** Carcasas, biseles, las cuatro bases y la pared I/O salen de la STL: sirven para medir, cortar y añadir operaciones, y los agujeros no son cilindros editables. Los de origen CSG (pivotes, bandeja, guías, anillo, pomo, soporte del Arduino, plantilla de agujeros, pletina y soporte del disco) sí traen cilindros. `05_PROVISIONAL_carcasa_x1_y0` tiene 12 triángulos cruzados; FreeCAD lo marca no válido. La tabla completa, hecha con FreeCAD 1.0 el 2026-10-20, está en `hardware/impresion/siguientes/STEP/COMPROBACION_STEP.txt`. Aquí no se ha reejecutado FreeCAD (no está instalado): solo se ha visto que los 23 STEP son AP214 de FreeCAD.

**Manual vigente:** [`docs/manual_montaje/Orbit_manual_montaje.pdf`](manual_montaje/Orbit_manual_montaje.pdf), generado desde el CAD de esta rama. Va por subpasos, con la pieza de cada kit en cada unión. La fuente del inventario es el repo `inventario-taller` (`tornilleria/inventario.csv`); este cambio no escribe ahí. Incluye el botón de encendido provisional y el corte de los pines bajo la PCB: 51 subpasos, 31 páginas. `carcasa_x0_y1` no se regenera. Las figuras las regenera `hardware/cad/manual/render_manual.py` y el PDF `hardware/cad/manual/escribir_manual.py`. Sigue siendo provisional: los tornillos están elegidos y no probados en el plástico, salvo el M3 con el que ya se cerró la carcasa. El PDF antiguo [`docs/manual-montaje/MANUAL_MONTAJE_ORBIT.pdf`](manual-montaje/MANUAL_MONTAJE_ORBIT.pdf) (21 páginas) **no se ha regenerado** y no incluye el Nano, el panel ni la bandeja de huecos.

**Renders y capturas.** `hardware/render/escena_blender.py` sigue dibujando el Arduino Micro. No se ha vuelto a lanzar Blender. Las capturas de `assets/screenshots/` incluyen la vista integrada simulada (la zona del HP no es Windows).

**Tamaño.** No hay `.gitattributes`. El STEP mayor mide 3,6 MB (`06_PROVISIONAL_carcasa_x1_y1.step`). `hardware/impresion/siguientes/` pesa unos 15 MB. Por debajo del aviso de GitHub (50 MB por archivo) y del rechazo (100 MB). No hace falta Git LFS.

---

## 7. Modos de vídeo

| Modo | Qué hace | Estado |
|---|---|---|
| **A · remoto** | La MSI muestra la Pi. Ver el HP es abrir en la Pi un visor del escritorio (Sunshine en el HP + Moonlight en la Pi) por el Ethernet interno. Variable `ORBIT_REMOTE_CMD` (sin shell). Si no hay orden, el cambio se registra y la interfaz enseña su panel, sin lanzar nada. | **Base.** Implementado en `video.py` y cubierto por tests. **No** probado con Sunshine, Moonlight, el HP ni la MSI. Windows 10 Home no trae servidor RDP. |
| **B · DDC/CI** | La Pi cambiaría la entrada de la MSI (`ddcutil`, VCP 0x60). Haría falta el adaptador HDMI → USB-C en el sentido correcto. Variables: `ORBIT_VIDEO_DDC=1`, `ORBIT_DDC_HP`, `ORBIT_DDC_PI`, `ORBIT_DDC_BUS`. | Implementado y **apagado** por defecto. **Poco probable:** los manuales de la MSI no mencionan DDC/CI ni MCCS. El UGREEN no está identificado y probablemente va al revés. Valores VCP: PENDIENTE. |
| **C · capturadora** | HDMI del HP → capturadora UVC → USB de la Pi. La MSI sigue en la Pi. Variables: `ORBIT_CAPTURE_DEVICE` (`/dev/videoN` o `/dev/v4l/by-id|by-path/…`) y `ORBIT_CAPTURE_CMD` (sin shell; el texto `{device}` se sustituye). Teclado y ratón del HP van al HP, no a la capturadora. | **Recomendado** junto al A para tener imagen real del HP. Implementado y cubierto por tests con dispositivo simulado. **No** hay capturadora, y no se ha probado con hardware. |

Prioridad en código: B si está listo, si no C si está configurado, si no A.

---

## 8. Historial de decisiones

| PR | Qué se decidió y por qué |
|---|---|
| **#1** (merge `861db16`) | Entra el v0: investigación, CAD paramétrico y software **solo en simulación**. Nada probado en hardware. Se conserva la licencia Apache-2.0 de Miguel. |
| **#2** (merge `68be364`) | CAD v1: 2 potenciómetros + 2 botones con Arduino Micro, sin KVM, impresora Bambu Lab A1 y PETG. Las medidas de mandos son de catálogo genérico. El Micro lo sustituye el cambio de abajo; esta fila se queda como historia. |
| **#3** (merge `fc4837b`) | El HP Slimline se saca de la caja y entra la placa desnuda, sin cambiar la envolvente. El adaptador de 65 W se queda fuera y sin modificar. El cambio de sistema pasa a ser automático desde Orbit OS (entonces A y después B). |
| **#4** (merge `21cd5af`) | Medidas reales: placa 17 × 17 cm y 35 mm. El agujero F del v2 estaba alineado con C; el estándar lo desplaza 22,86 mm y el v3 lo corrige. Entra el modo C. El modo B pasa a poco probable porque los manuales de la MSI no documentan DDC/CI. |
| **#5** (merge `bf6d641`) | Renders del CAD v3, no fotos, con créditos de qué es exacto y qué es aproximado. En un commit aparte, la lámina con recortes de fotos: Miguel autorizó publicar esa imagen. |
| **#6** (merge `3978879`) | El disco del modelo pasa al Toshiba 3,5" porque es el que hay, no un SSD pendiente de comprar. Las patas suben a 14 mm: con 8 mm la plancha chocaba con las pletinas. Los colisos siguen SFF-8301 (3,18 mm al lateral), no la medición a ojo. Las torretas de empalme llevan paso Ø3,4 en la cara superior. El agujero del inserto de los separadores queda abierto por arriba: antes lo cerraba una tapa de 0,17 mm. Entran la guía de impresión de la base, la pared de prueba, la plantilla ya comprobada y la de pivotes (Miguel prefiere pivotes a tornillos; el diámetro ganador no se conoce). |
| **#7** (merge `05ac19f`) | Después de la base: STEP AP214 para SolidWorks, el orden de las 15 piezas siguientes (los STL no se duplican) y el manual de montaje de 21 páginas. La plantilla de pivotes sigue sin resultado. Los STEP de malla se editan peor; `05_carcasa_x1_y0` tiene 12 triángulos cruzados. |
| **Este cambio** | Nano de mandos en vez del Micro (sin HID; serie en `/dev/ttyUSB*`, espera de 2 s al abrir el puerto). ESP8266 para WLED y segundo Nano de prácticas, en carros de un riel atornillado a las dos torretas DC de la izquierda de la canaleta (el velcro del 2026-10-20 queda sustituido). El Uno no cabe bien (margen 4,2 mm en X y 6,9 mm en Y). Panel trasero con pines, 5 V, 3,3 V, GND, hueco USB y OLED 0,96" controlada por ese Nano. La bandeja no se regenera. El soporte del Nano de mandos se regeneró el 2026-10-20 (9,58 cm³) y **no se ha vuelto a tocar**: Miguel ya lo tiene para imprimir. `carcasa_x1_y1` sigue en 242,11 cm³. STEP 06 y 15, el PDF y los renders no. |

---

## 9. Restricciones

- No se compra nada sin autorización de Miguel. La capturadora es una propuesta, no un pedido.
- No se suben credenciales, tokens reales, `.env` ni fotos personales. La única excepción de imagen es la lámina autorizada del PR #5.
- No se añade telemetría de uso ni envío de datos fuera. La telemetría que ya existe es local: psutil en la máquina donde corre orbitd o hp-agent, para la propia interfaz.
- Nada va conectado a la red eléctrica dentro de la cuña. La fuente original del HP no se modifica y se queda fuera.
- No se inventan medidas, latencias, resultados de impresión ni compatibilidades. Lo no medido se marca PENDIENTE o DE FUENTE.
- La simulación se marca (`simulated: true`, distintivo **MODO SIMULACIÓN**).
- La licencia Apache-2.0 de Miguel se mantiene.
- No se declara nada listo para fabricación mientras falten las medidas pendientes y un montaje real.

---

## 10. Pendientes, en este orden

1. **Resultado de la impresión de la base** (en marcha el 2026-10-20) y de lo ya lanzado: `pomo_x2`. El soporte del Nano de mandos ya está pasado a imprimir; el STL no se ha vuelto a cambiar el 2026-10-21. Si llegó a salir el del Micro, no vale. El soporte 2,5" ya dio un resultado: salió pequeño. La bandeja de servicio ya está impresa y no se regenera. El riel y los tres carros son STL nuevos, sin imprimir.
2. **Diámetro de pivote** (C 3,8 / F 3,6 / H 3,4 / J 3,2) cuando Miguel pruebe `hardware/impresion/plantillas/PRUEBA_plantilla_pivotes_HP.stl`. Sigue **sin resultado**. Es la pieza 01 de `hardware/impresion/siguientes/README.md`.
3. **HAT VHF:** medidas, y si deja pasar el cabezal de 40 pines. La Pi es una Pi 4 (Miguel, 2026-10-20). Por qué entrada da imagen en la MSI sigue abierto.
4. **Posiciones de los puertos y teclas del canto del MSI.**
5. **Medidas de los potenciómetros y de los pulsadores** de Miguel (el eje de 6 mm está acordado y sin medir). Medir también el Nano clon, el ESP8266 de la foto y, cuando se elija, el módulo OLED. El segundo Nano no consta en la foto.
6. **Tipo y tensión de la tira LED.** De eso depende si WLED en el ESP necesita desplazador de nivel. GPIO2 (D4 en la mayoría de NodeMCU) es el dato por defecto de WLED y tiene que estar en alto al arrancar.
7. **Patillaje del botón de encendido del HP** (polímetro, H-6). No se inventa.
8. **BIOS:** Wake-on-LAN y «After Power Loss» (H-11).
9. **Instalar y arrancar en la Pi** (aún no hecho):

```bash
sudo apt install -y git nodejs npm python3-venv
git clone https://github.com/Sopa-IA/Control-deck
cd Control-deck
./scripts/setup-dev.sh
./scripts/dev-sim.sh
```

Eso deja orbitd en simulación. El hardware real sigue pendiente: token, `--serial` (ejemplo `/dev/ttyUSB0`; confirmar con `/dev/serial/by-id`), hp-agent y el visor del modo A o C.

También siguen abiertos: el calibre de cada conector trasero del HP (la placa usa la foto del 2026-10-23, ±2 mm; la prueba lo comprueba antes de pegar), los agujeros reales de la pestaña del I/O frontal (el marco trae dos a 60 mm y se taladra la chapa), antenas, cables SATA, diámetro del jack, `pi.shutdown`, volumen del HP en Windows, `wss://`, servicios de arranque, bootloader del clon (nuevo u `atmega328old`), cuánto tarda ese reinicio (los 2 s son diseño), si el tapón mini-USB pasa por el canal de 10 mm, el cuerpo real de las regletas (el modelo usa 5,1 × 8,5 mm de catálogo), la orientación de la OLED y el pin de 3,3 V del clon (puede no existir). Los cuatro USB de la Pi 4 quedan ocupados en el reparto de diseño; no se ha medido la corriente.

De la bandeja con huecos fijos (2026-10-22), sin probar en una pieza impresa: el módulo real del step-down (el CAD usa un LM2596 típico de 43 × 21 mm, agujeros a 3,5 mm de la esquina); el ESP de la foto (58 × 31); el tramo sin pines del canto corto (el apoyo es de 2,0 mm); el largo de las clavijas; el HAT; y dónde se guarda la capturadora. El riel suelto y los carros no se montan. La guía de los insertos cortos de las torretas DC era de esa bahía y ya no aplica a esta bandeja.

---

## 11. Cómo lo retoma un agente

Desde la raíz del repo. OpenSCAD de este entorno: **2021.01**. Esa versión no admite `-I`; los scripts de la base incluyen `piezas.scad` por ruta absoluta.

```bash
# Ver el ensamblaje (no exporta)
openscad hardware/cad/ensamblaje.scad

# Regenerar los 20 STL. Borra export/stl/*.stl antes de escribir
hardware/cad/exportar.sh

# Comprobaciones geométricas (cajas / mallas; no son un montaje)
python3 hardware/cad/comprobar_interferencias.py
python3 hardware/cad/comprobar_stl.py
python3 hardware/impresion/base/comprobar_base_hdd.py
python3 hardware/impresion/base/verificar_separadores.py

# Software
./scripts/setup-dev.sh
./scripts/test-all.sh          # ruff + pytest + tsc + vitest
./scripts/dev-sim.sh           # http://127.0.0.1:8765/
```

La pared de prueba, si hay que recompilarla:

```bash
openscad -o /tmp/pared.stl hardware/impresion/base/prueba_pared_trasera_io.scad
```

### Resultados reales del 2026-10-20 (este entorno)

| Comprobación | Resultado |
|---|---|
| `exportar.sh` | **No** se ha lanzado: borra todos los STL. El 2026-10-20 se regeneraron el soporte y `carcasa_x1_y1`. El 2026-10-21 solo el riel y los tres carros. La bandeja no. El soporte **no** se ha vuelto a exportar. |
| `comprobar_interferencias.py` | Salida 0 el 2026-10-21 con la bandeja v2, en `carro_conjunto = "nano_esp"` (23 cajas) y en `"nano_proto"` (22 cajas). Envolvente 456,3 × 300,5 × 153,9 mm. Clavijas USB-A de la Pi ≥ 5 mm a la pared. Carro del Nano de prácticas ≥ 1 mm a la tina. La clavija del RJ45 queda a ≥ 1 mm de una orejeta trasera de 11 mm de alto. **I/O frontal y pulsador del HP: holgura mínima ≥ 0 mm**. OLED ≥ 1 mm. El script los marca OK; 0 mm no es holgura de montaje. |
| `comprobar_stl.py` | Salida 0 el 2026-10-21. Las 24 caben y son mallas cerradas. |
| `comprobar_base_hdd.py` | Salida 0. Plancha a 2,0 mm del borde de la placa, pata más cercana a 1,0 mm, pila bajo la plancha con 0,6 mm frente a la cabeza 6-32 (cota de cabeza pendiente). |
| `verificar_separadores.py` | Salida 0. C y F abiertos en `base_x0_y1`; H y J abiertos en `base_x0_y0` (centro y r = 1,5 huecos en z = 10,27 y z = 7,35; r = 3,5 sólido). Las bases x1 no tienen esos separadores. |
| `pytest` | **50 passed** (0,64 s). Tres pruebas nuevas del reinicio del Nano y del puerto de ejemplo. |
| `vitest` | **27 passed**, 6 archivos (Vitest 2.1.9). |
| `ruff check software tests` | Sin avisos. |
| `tsc -b` y `vite build` | Salida 0. |
| `arduino-cli` 1.5.1, core `arduino:avr` 1.8.8 | Salida 0. Mandos: 2982 bytes (9 % de 30720) y 226 bytes de RAM (11 %). Ejemplo OLED: 5558 bytes (18 %) y 480 bytes de RAM (23 %). Los dos FQBN (`nano` y `nano:cpu=atmega328old`) dan las mismas cifras. Sin probar en placa. |

`docs/diseno-mecanico.md` aún cita cajas del soporte de SSD (110,5 × 69,8 × 12) y un volumen de bandeja antiguo. Esas cifras no son las de los STL de hoy.
