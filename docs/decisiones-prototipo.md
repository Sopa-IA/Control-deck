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
- **CAD v1** (`diseno-mecanico.md`) ya incorpora estas decisiones:
  - sin KVM (opcional);
  - 2 potenciómetros genéricos + 2 pulsadores de panel;
  - soporte del Arduino Micro con canal USB hacia la Pi;
  - puertos y teclas del canto derecho del MSI accesibles;
  - impresión en Bambu Lab A1 con PETG.

  Las medidas de potenciómetros, pulsadores y posiciones del canto siguen **PENDIENTES**.
- Impresora: **Bambu Lab A1** (256 × 256 × 256 mm, marco abierto) → **PETG** recomendado.
