# Decisiones del prototipo (2026-10-18)

Acordadas con Miguel. **Prevalecen sobre las recomendaciones de la fase 1** cuando no coinciden.

| Tema | Fase 1 (estudio) | Prototipo (decidido) |
|---|---|---|
| Piezas | Lista de compra orientativa | **Solo piezas que Miguel ya tiene** |
| Pantalla | Waveshare 12,3" In-Cell (táctil) | **MSI PRO MP161 E2U 15,6"**, 1920×1080, **no táctil**. Se usa ratón y controles; la interfaz se mantiene preparada para táctil |
| Compartir vídeo | KVM TESmart HKS201-P23-V2 | **Las dos entradas del MSI** (Mini-HDMI + USB-C), cambiadas desde el **OSD del monitor**. El KVM queda como opción futura |
| Controles | Encoders Bourns PEC11R en GPIO de la Pi | **Potenciómetros + botones** leídos por un **Arduino Micro** (ATmega32U4, USB nativo) |
| LEDs | SK6812 WWA | **Tira existente de tipo desconocido**: pendiente de identificar |
| Raspberry Pi | Pi 5 2 GB si se compra | **La que tenga Miguel**; modelo desconocido |

Consecuencias:

- orbitd no puede saber qué entrada muestra el MSI (`video_input: "desconocida"`). El botón "cambiar sistema" abre una guía del OSD.
- El volumen del HP lo aplica hp-agent a través de orbitd. El HID del Arduino iría a la Pi, que es donde está enchufado, y por eso está desactivado.
- El diseño mecánico v0 (`diseno-mecanico.md`) se hizo con encoders y con hueco para el KVM. Para la siguiente iteración del CAD hay que cambiar los huecos de los encoders por los de los potenciómetros (eje y casquillo según el modelo que tenga Miguel, **PENDIENTE**) y añadir el alojamiento del Arduino Micro.
