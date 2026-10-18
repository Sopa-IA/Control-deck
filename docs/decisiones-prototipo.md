# Decisiones del prototipo (2026-10-18)

Acordadas con Miguel. **Prevalecen sobre las recomendaciones de la fase 1** cuando no coinciden.

| Tema | Fase 1 (estudio) | Prototipo (decidido) |
|---|---|---|
| Piezas | Lista de compra orientativa | **Solo piezas que Miguel ya tiene** |
| Pantalla | Waveshare 12,3" In-Cell (táctil) | **MSI PRO MP161 E2U 15,6"**, 1920×1080, **no táctil**. Se usa ratón y controles; la interfaz se mantiene preparada para táctil |
| Compartir vídeo | KVM TESmart HKS201-P23-V2 | **Cambio automático desde Orbit OS; Miguel nunca toca el OSD.** **Modo A (base):** la MSI muestra siempre la Pi y el escritorio del HP se ve en un visor (Sunshine + Moonlight) por el Ethernet interno. **Modo B (opcional, sin verificar):** HP por HDMI → Mini-HDMI, Pi → adaptador HDMI→USB-C (DP Alt) → USB-C, y la Pi cambia la entrada por DDC/CI (`ddcutil`). El KVM queda como opción futura |
| HP | "HP Mini" sin identificar | **HP Slimline 260-a110ns desmontado**: placa mini-ITX (Iris-A6), disipador, RAM, disco e I/O frontal dentro de Orbit; adaptador externo 19,5 V 65 W fuera; **DVD retirado**; **SSD 2,5" recomendado** (HDD 3,5" como opción) |
| Alimentación | Fuentes externas o DC única | Adaptador HP externo al jack DC de la placa; Pi y MSI con fuentes USB-C certificadas (o un cargador PD multipuerto certificado). Sin red eléctrica dentro |
| Controles | Encoders Bourns PEC11R en GPIO de la Pi | **Potenciómetros + botones** leídos por un **Arduino Micro** (ATmega32U4, USB nativo) |
| LEDs | SK6812 WWA | **Tira existente de tipo desconocido**: pendiente de identificar |
| Raspberry Pi | Pi 5 2 GB si se compra | **La que tenga Miguel**; modelo desconocido |

Consecuencias:

- **Cambiar sistema visible** = acción `pi.switch_visible` de orbitd (botón B2 por defecto y botón en la sección Sistemas). orbitd usa el modo disponible: DDC/CI si está configurado y funciona; si no, el modo remoto. No se prometen latencias: se medirán. Detalle en `conmutacion-video-usb.md` §V.
- (Antes: orbitd no sabía qué entrada mostraba el MSI y el botón abría una guía del OSD. **Sustituido** por lo anterior.)
- El volumen del HP lo aplica hp-agent a través de orbitd. El HID del Arduino iría a la Pi, que es donde está enchufado, y por eso está desactivado.
- **CAD v1** (`diseno-mecanico.md`) ya incorpora estas decisiones:
  - sin KVM (opcional);
  - 2 potenciómetros genéricos + 2 pulsadores de panel;
  - soporte del Arduino Micro con canal USB hacia la Pi;
  - puertos y teclas del canto derecho del MSI accesibles;
  - impresión en Bambu Lab A1 con PETG.

  Las medidas de potenciómetros, pulsadores y posiciones del canto siguen **PENDIENTES**.
- **CAD HP v2** (`diseno-mecanico.md` §0b): módulo de placa mini-ITX desnuda en la cuña (separadores, ventana I/O, disipador, soporte de SSD/HDD, I/O frontal y pulsador del HP en el lateral izquierdo, hueco para el adaptador HDMI→USB-C). La envolvente no cambia.
- **Seguridad del desmontaje:** ver `datos-pendientes-hp.md` §B.
- Impresora: **Bambu Lab A1** (256 × 256 × 256 mm, marco abierto) → **PETG** recomendado.
