# Decisiones del prototipo (2026-10-18)

Acordadas con Miguel. **Prevalecen sobre las recomendaciones de la fase 1** cuando no coinciden.

| Tema | Fase 1 (estudio) | Prototipo (decidido) |
|---|---|---|
| Piezas | Lista de compra orientativa | **Solo piezas que Miguel ya tiene** |
| Pantalla | Waveshare 12,3" In-Cell (táctil) | **MSI PRO MP161 E2U 15,6"**, 1920×1080, **no táctil**. Se usa ratón y controles; la interfaz se mantiene preparada para táctil |
| Compartir vídeo | KVM TESmart HKS201-P23-V2 | **La Pi lo controla todo y el cambio es automático; Miguel nunca toca el OSD** (requisito n.º 1). Cada sistema corre independiente. La MSI muestra siempre la Pi. **Modo C (recomendado):** HDMI del HP → **capturadora HDMI→USB (UVC)** → USB de la Pi; Orbit OS muestra la imagen del HP a pantalla completa o en ventana. **Modo A (recomendado, sin hardware):** escritorio del HP en un visor (Sunshine + Moonlight) por el Ethernet interno. **Modo B (poco probable):** Pi → adaptador HDMI→USB-C (DP Alt) → USB-C y cambio de entrada por DDC/CI; los manuales de la MSI no documentan DDC/CI. El KVM queda como opción futura |
| HP | "HP Mini" sin identificar | **HP Slimline 260-a110ns desmontado**: placa mini-ITX (Iris-A6), disipador, RAM, disco e I/O frontal dentro de Orbit; adaptador externo 19,5 V 65 W fuera; **DVD retirado**. El 2026-10-18 se recomendaba un SSD 2,5". **Desde el 2026-10-20 el CAD usa el HDD Toshiba 3,5" real** (`usar_hdd_35 = true`, cotas SFF-8301). El SSD sigue como opción del mismo parámetro |
| Alimentación | Fuentes externas o DC única | Adaptador HP externo al jack DC de la placa; Pi y MSI con fuentes USB-C certificadas (o un cargador PD multipuerto certificado). Sin red eléctrica dentro |
| Controles | Encoders Bourns PEC11R en GPIO de la Pi | **Potenciómetros + botones** leídos por un **Arduino Nano** (ATmega328P, mini-USB). El 2026-10-18 se eligió un Micro; el 2026-10-20 Miguel cambia a Nano. El Nano no tiene USB nativo: no hay volumen HID |
| LEDs | SK6812 WWA | **Tira existente de tipo desconocido**: pendiente de identificar |
| Raspberry Pi | Pi 5 2 GB si se compra | **Pi 4**, confirmada por Miguel el 2026-10-20, con un HAT VHF (OLED y antena SMA). Medidas del HAT **PENDIENTES**. El dibujo mecánico del CAD ya era el de la Pi 4 |

Consecuencias:

- **Cambiar sistema visible** = acción `pi.switch_visible` de orbitd (botón B2 por defecto y botón en la sección Sistemas). orbitd usa el modo disponible: DDC/CI si está configurado y funciona; si no, la capturadora si está configurada y conectada; si no, el modo remoto. No se prometen latencias ni fps: se medirán. Detalle en `conmutacion-video-usb.md` §V.
- **Modo C (2026-10-18):** capturadora de referencia vista en Amazon.es el 2026-10-18: marca SUOFEIXIANG, "4K30 de entrada / 1080p", 14,69 € (precio visto en una captura de Miguel; sin URL). **Comprarla o no lo decide Miguel.** Con ella, el teclado y el ratón del HP van conectados al HP por separado (la capturadora solo lleva imagen y sonido HDMI). Latencia y fps: **sin medir**.
- (Antes: orbitd no sabía qué entrada mostraba el MSI y el botón abría una guía del OSD. **Sustituido** por lo anterior.)
- El volumen del HP lo aplica hp-agent a través de orbitd. El HID del Arduino iría a la Pi, que es donde está enchufado, y por eso está desactivado.
- **CAD v1** (`diseno-mecanico.md`) ya incorpora estas decisiones:
  - sin KVM (opcional);
  - 2 potenciómetros genéricos + 2 pulsadores de panel;
  - soporte del Arduino con canal USB hacia la Pi (desde el 2026-10-20 es un Nano; el canal y las torretas de la bandeja impresa no se mueven);
  - puertos y teclas del canto derecho del MSI accesibles;
  - impresión en Bambu Lab A1 con PETG.

  Las medidas de potenciómetros, pulsadores y posiciones del canto siguen **PENDIENTES**.
- **CAD HP v2** (`diseno-mecanico.md` §0b): módulo de placa mini-ITX desnuda en la cuña (separadores, ventana I/O, disipador, soporte de SSD/HDD, I/O frontal y pulsador del HP en el lateral izquierdo, hueco para el adaptador HDMI→USB-C). La envolvente no cambia.
- **CAD HP v3** (2026-10-18): altura real de la placa **35 mm** (medida por Miguel; límite 41 mm), patrón de agujeros **estándar mini-ITX** (coincide visualmente con la foto, no medido; corregido el agujero F), I/O trasero **sin escudo** (ventana libre; placa I/O impresa pendiente de medidas) y **reserva de espacio para la capturadora** en la bandeja de servicio. Ver `datos-pendientes-hp.md` §A2.
- **La Pi ya da imagen en la MSI** (2026-10-18). El 2026-10-20 Miguel confirma que es una **Pi 4** con HAT VHF. Por qué entrada da imagen, y las medidas del HAT, siguen **PENDIENTES**. En el modo C la Pi va a la Mini-HDMI de la MSI (con el adaptador Mini-HDMI → HDMI hembra de Miguel) y el HDMI del HP va a la capturadora.
- **Seguridad del desmontaje:** ver `datos-pendientes-hp.md` §B.
- Impresora: **Bambu Lab A1** (256 × 256 × 256 mm, marco abierto) → **PETG** recomendado.

## 2026-10-20 · Nano, ESP8266, placa de prácticas y panel trasero

Miguel, ampliación del mismo encargo. El detalle de pines, protecciones y el sketch está en [`../software/arduino-pruebas/README.md`](../software/arduino-pruebas/README.md).

- **Mandos:** Nano clon (ATmega328P, mini-USB, CH340 probable). El soporte se reimprime: el asiento pasa de 48 × 17,7 a 45 × 18. Los tornillos no se mueven (torretas de la bandeja impresa en y = 63 y y = 125, x = 418,26). El canal USB sigue en y = 143,5 y 10 mm de ancho. La bandeja **no** se regenera.
- **ESP8266 NodeMCU** delante a la izquierda, velcro o brida, sin torretas nuevas. Previsto para WLED. Tira sin identificar.
- **Prácticas:** segundo Nano, no el Uno. El Uno (68,6 × 53,4, **DE FUENTE**) cabe solo en el hueco de delante de la capturadora y no cabe bien con el ESP y un cable USB-B (margen de 4,2 mm en X y 6,9 mm en Y). Que Miguel ya tenga ese segundo Nano es **PENDIENTE**.
- **Panel trasero** en `carcasa_x1_y1`: pines del Nano de prácticas, previsión de GPIO de la Pi (el HAT puede taparlos: **PENDIENTE**), 5 V, 3,3 V y GND en el mapa, rótulos de grupo, hueco USB de programación y ventana de una OLED 0,96" SSD1306. La OLED la lleva el Nano de prácticas (ejemplo «monitor de pines»), no la Pi.
- **Alimentación USB (DISEÑO, sin medir):** los cuatro USB de la Pi 4 quedan repartidos entre el Nano de mandos, el ESP, la capturadora y el puente del conector de programación. No sobra ninguno. No se supone un hub.
