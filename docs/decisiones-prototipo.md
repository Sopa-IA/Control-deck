# Decisiones del prototipo (2026-10-18)

Acordadas con Miguel. **Prevalecen sobre las recomendaciones de la fase 1** cuando no coinciden.

| Tema | Fase 1 (estudio) | Prototipo (decidido) |
|---|---|---|
| Piezas | Lista de compra orientativa | **Solo piezas que Miguel ya tiene** |
| Pantalla | Waveshare 12,3" In-Cell (táctil) | **MSI PRO MP161 E2U 15,6"**, 1920×1080, **no táctil**. Se usa ratón y controles; la interfaz se mantiene preparada para táctil |
| Compartir vídeo | KVM TESmart HKS201-P23-V2 | **La Pi lo controla todo y el cambio es automático; Miguel nunca toca el OSD** (requisito n.º 1). Cada sistema corre independiente. La MSI va solo a la Pi. La imagen del HP llega por un cable de red directo (HP 10.0.0.1, Pi 10.0.0.2), con Sunshine en el HP y Moonlight en la Pi. El teclado y el ratón son Bluetooth, emparejados con la Pi. El KVM queda como opción futura |
| HP | "HP Mini" sin identificar | **HP Slimline 260-a110ns desmontado**: placa mini-ITX (Iris-A6), disipador, RAM, disco e I/O frontal dentro de Orbit; adaptador externo 19,5 V 65 W fuera; **DVD retirado**. El 2026-10-18 se recomendaba un SSD 2,5". **Desde el 2026-10-20 el CAD usa el HDD Toshiba 3,5" real** (`usar_hdd_35 = true`, cotas SFF-8301). El SSD sigue como opción del mismo parámetro |
| Alimentación | Fuentes externas o DC única | Adaptador HP externo al jack DC de la placa; Pi y MSI con fuentes USB-C certificadas (o un cargador PD multipuerto certificado). Sin red eléctrica dentro |
| Controles | Encoders Bourns PEC11R en GPIO de la Pi | **Potenciómetros + botones** leídos por un **Arduino Nano** (ATmega328P, mini-USB). El 2026-10-18 se eligió un Micro; el 2026-10-20 Miguel cambia a Nano. El Nano no tiene USB nativo: no hay volumen HID |
| LEDs | SK6812 WWA | **Tira existente de tipo desconocido**: pendiente de identificar |
| Raspberry Pi | Pi 5 2 GB si se compra | **Pi 4**, confirmada por Miguel el 2026-10-20, con un HAT VHF (OLED y antena SMA). Medidas del HAT **PENDIENTES**. El dibujo mecánico del CAD ya era el de la Pi 4 |

Consecuencias:

- **Cambiar lo que se ve** = acción `pi.switch_visible` de orbitd (botón B2 por defecto y botón en la sección Sistemas). Abre Moonlight contra Sunshine, o lo cierra. No se prometen latencias ni fps: se medirán. Pasos en `instalacion-pi.md`.
- (Antes: orbitd no sabía qué entrada mostraba el MSI y el botón abría una guía del OSD. **Sustituido** por Moonlight.)
- El volumen del HP lo aplica hp-agent a través de orbitd. El HID del Arduino iría a la Pi, que es donde está enchufado, y por eso está desactivado.
- **CAD v1** (`diseno-mecanico.md`) ya incorpora estas decisiones:
  - sin KVM (opcional);
  - 2 potenciómetros genéricos + 2 pulsadores de panel;
  - soporte del Arduino con canal USB hacia la Pi (desde el 2026-10-20 es un Nano; el canal y las torretas de la bandeja impresa no se mueven);
  - puertos y teclas del canto derecho del MSI accesibles;
  - impresión en Bambu Lab A1 con PLA+ negro mate. Las guías y los anillos de luz siguen en translúcido.

  Las medidas de potenciómetros, pulsadores y posiciones del canto siguen **PENDIENTES**.
- **CAD HP v2** (`diseno-mecanico.md` §0b): módulo de placa mini-ITX desnuda en la cuña (separadores, ventana I/O, disipador, soporte de SSD/HDD, I/O frontal y pulsador del HP en el lateral izquierdo, hueco para el adaptador HDMI→USB-C). La envolvente no cambia.
- **CAD HP v3** (2026-10-18): altura real de la placa **35 mm** (medida por Miguel; límite 41 mm), patrón de agujeros **estándar mini-ITX** (coincide visualmente con la foto, no medido; corregido el agujero F) e I/O trasero **sin escudo** (ventana libre; placa I/O impresa pendiente de medidas). Ver `datos-pendientes-hp.md` §A2.
- **La Pi ya da imagen en la MSI** (2026-10-18). El 2026-10-20 Miguel confirma que es una **Pi 4** con HAT VHF. Las medidas del HAT siguen **PENDIENTES**. La Pi va a la Mini-HDMI de la MSI (con el adaptador Mini-HDMI → HDMI hembra de Miguel). La imagen del HP llega por el cable de red directo.
- **Seguridad del desmontaje:** ver `datos-pendientes-hp.md` §B.
- Impresora: **Bambu Lab A1** (256 × 256 × 256 mm, marco abierto) → **PLA+ negro mate**.

## 2026-10-20 · Nano, ESP8266, placa de prácticas y panel trasero

Miguel, ampliación del mismo encargo. El detalle de pines, protecciones y el sketch está en [`../software/arduino-pruebas/README.md`](../software/arduino-pruebas/README.md).

- **Mandos:** Nano clon (ATmega328P, mini-USB, CH340 probable). El soporte se reimprime: el asiento pasa de 48 × 17,7 a 45 × 18. Los tornillos no se mueven (torretas de la bandeja impresa en y = 63 y y = 125, x = 418,26). El canal USB sigue en y = 143,5 y 10 mm de ancho. La bandeja **no** se regenera.
- **ESP8266 NodeMCU** delante a la izquierda, sin torretas nuevas. Previsto para WLED. Tira sin identificar. La sujeción con velcro de este párrafo la sustituyen los carros del 2026-10-21.
- **Prácticas:** segundo Nano, no el Uno. El Uno (68,6 × 53,4, **DE FUENTE**) cabe solo en el hueco delantero y no cabe bien con el ESP y un cable USB-B (margen de 4,2 mm en X y 6,9 mm en Y). Que Miguel ya tenga ese segundo Nano es **PENDIENTE**.
- **Panel trasero** en `carcasa_x1_y1`: pines del Nano de prácticas, previsión de GPIO de la Pi (el HAT puede taparlos: **PENDIENTE**), 5 V, 3,3 V y GND en el mapa, rótulos de grupo, hueco USB de programación y ventana de una OLED 0,96" SSD1306. La OLED la lleva el Nano de prácticas (ejemplo «monitor de pines»), no la Pi.
- **Alimentación USB (DISEÑO, sin medir):** los USB de la Pi 4 quedan para el Nano de mandos, el ESP y el puente del conector de programación. No se supone un hub.

## 2026-10-21 · Bahía modular a la izquierda de la canaleta

Miguel aclara que la bahía va a los **dos tornillos de la izquierda de la canaleta**, no a los del soporte de mandos. Esos dos son las torretas DC que ya están en la bandeja impresa: (401,26, 146,492) y (401,26, 194,492). El riel y tres carros (Nano de prácticas, ESP8266, proto 30 × 70 de diseño) son STL nuevos. A la vez caben dos placas, en y = 76 y y = 105. El ESP y la proto comparten puesto.

El soporte `PROVISIONAL_soporte_arduino` **no se modifica**: Miguel ya lo tiene para imprimir, y el Nano de mandos no pasa a ser un carro (su cable sigue en el canal). La frase del 2026-10-20 que sujeta el ESP con velcro queda sustituida por estos carros. El inserto corto, el cajeado y el margen de 2,3 mm de la proto hasta el borde de la bandeja están **PENDIENTES** de probar. Detalle en [`diseno-mecanico.md`](diseno-mecanico.md).
