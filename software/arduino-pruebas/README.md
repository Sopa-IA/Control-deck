# arduino-pruebas · Nano de prácticas

Placa **aparte** del Nano de los mandos. El firmware de los mandos sigue en [`../arduino-controls/`](../arduino-controls/) y no se toca desde aquí. Este directorio es un ejemplo para que Miguel lo sustituya por sus propios programas.

**No se ha probado en una placa ni en una pantalla.** Compila; eso es todo lo que se ha comprobado.

## Qué placa y por qué no el Uno

Miguel prefiere el Arduino Uno de la foto. La placa de catálogo **sí cabe sola** en el hueco libre de la bandeja, y **no cabe bien** junto al ESP8266, la reserva de la capturadora (modo C) y un cable USB.

Caja libre, calculada el 2026-10-20 con `params.scad` (no es una medida de la bandeja impresa):

| Límite | Valor | De dónde sale |
|---|---|---|
| X | 322,26 a 405,26 mm (ancho 83,00) | Borde de la bandeja (`serv_x`) hasta el borde izquierdo del soporte de mandos (`ard_cx - sop_ard_w/2`) |
| Y | 53,00 a 128,49 mm (fondo 75,49) | Borde delantero de la bandeja (`serv_y`) hasta el frente de la reserva de la capturadora (`cap_y`) |

El Uno Rev3 mide **68,6 × 53,4 mm** ([tienda oficial](https://store.arduino.cc/products/arduino-uno-rev3), **DE FUENTE**). Ese rectángulo entra en la caja. Al lado del ESP de referencia (25,4 × 48,3 mm, ver abajo) la única colocación lado a lado es el lado corto del ESP más el lado corto del Uno: 25,4 + 53,4 = 78,8 mm. Quedan **4,2 mm** en X para los dos huecos y **6,9 mm** en Y (75,49 − 68,6). Un cable USB-B no entra en 6,9 mm. El Uno **no se monta**. Sigue en el inventario como pieza que no va en la bandeja.

La placa de prácticas es un **segundo Nano** (misma cota de catálogo que el de mandos: PCB 18 × 45 mm, [tienda oficial](https://store.arduino.cc/products/arduino-nano)). En el CAD queda a la derecha del ESP (`pr_x = 359,66`), con el mini-USB hacia atrás. Hasta el soporte sobran 27,6 mm. El enchufe reservado (12 mm, **DISEÑO**, no medido) acaba en y = 123, y la capturadora empieza en y = 128,49.

**PENDIENTE:** la foto no enseña un segundo Nano. Hay un Nano (mandos) y un Uno. Miguel acepta otro Nano si el Uno no cabe. Comprarlo no está hecho: no se compra nada sin que él lo diga.

## Dónde va y cómo se sujeta

Sobre la bandeja ya impresa, con **velcro o brida**. No hay torretas nuevas: cambiarían una pieza ya hecha. Taladros opcionales, no van en el STL: dos Ø3,2 en el centro de los lados largos, a 4 mm del borde de la caja del marcador.

El ESP8266 va igual (velcro o brida), delante a la izquierda. En la foto el micro-USB mira al frente; en el CAD mira atrás, porque con el alto de diseño (13 mm) más adelante el marcador entra en la tina de la pantalla. Pegarlo como en la foto es **PENDIENTE** de probar con el cable real.

## Cómo programarlo

Dos caminos. Ninguno se ha probado en la Pi de Miguel.

1. **Desde la Pi**, con `arduino-cli` (o el IDE, si se instala). El sketch de ejemplo:

```bash
arduino-cli compile --fqbn arduino:avr:nano software/arduino-pruebas/monitor_pines
arduino-cli upload  --fqbn arduino:avr:nano -p /dev/ttyUSB1 software/arduino-pruebas/monitor_pines
```

Los clones CH340 suelen llevar el bootloader viejo. Misma fuente, otro FQBN:

```bash
arduino-cli compile --fqbn arduino:avr:nano:cpu=atmega328old software/arduino-pruebas/monitor_pines
```

`./scripts/compile-arduino.sh` compila los dos FQBN, el de mandos y este. El número del puerto **no** es fiable si el Nano de mandos y el ESP también están enchufados: usar `/dev/serial/by-id`. **PENDIENTE** de leer esos nombres en la Pi.

2. **Desde un portátil**, si se pone un prolongador USB. En la cara trasera hay un hueco rotulado **PRG**, de **14 × 8 mm** (**DISEÑO**). El recorte del conector de panel que se compre es **PENDIENTE**. El mini-USB del Nano de prácticas iría a ese conector. Cuando el portátil no está, ese mismo conector se puentea a un USB libre de la Pi para dar corriente.

### USB de la Pi 4

La Pi 4 tiene 2× USB 3.0 y 2× USB 2.0 ([documentación oficial](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html)). Reparto previsto (**DISEÑO**, sin medir el presupuesto de corriente):

| Puerto | Qué |
|---|---|
| 1 | Nano de mandos, siempre conectado (orbitd, serie) |
| 2 | ESP8266 (corriente y, una vez, grabar WLED; luego va por Wi-Fi) |
| 3 | Capturadora del modo C |
| 4 | Puente del conector PRG, cuando no hay portátil |

Son los cuatro. No queda uno de reserva. Un hub es opcional más adelante y **no se da por comprado**. La tira LED no se alimenta del regulador de 3,3 V del ESP.

## Pantalla OLED

**Quién la controla:** el Nano de prácticas, por I2C, SDA en A4 y SCL en A5, dirección `0x3C`.

**Qué muestra el ejemplo:** el estado de los pines, en vivo, para que Miguel vea lo que está programando. Lo puede borrar y poner otra cosa.

| Página | Texto |
|---|---|
| 0 | `ORBIT PINES` |
| 1 | `D ` y doce cifras: D2…D13, `0` si el pin está a LOW, `1` si no. Entrada con pull-up interno |
| 2 | `  23456789ABCD` (leyenda de esos pines: 10, 11, 12 y 13 salen como A, B, C y D) |
| 3–5 | `A0` `A1`, luego `A2` `A3`, luego `A6` `A7`, valores de 0 a 1023 |
| 6 | `A4/A5 = OLED` |
| 7 | `EJEMPLO` |

A4 y A5 no se leen: son el bus. A6 y A7 existen en el Nano (encapsulado TQFP); un Uno con DIP no los tiene. El sketch es de Nano. Se refresca cada 200 ms. Por serie imprime `monitor-pines 1`, que **no** coincide con el saludo de orbitd: este Nano no se enchufa como placa de mandos.

**Por qué no la lleva la Pi** (enseñar la IP y la temperatura era la otra opción):

1. La placa de prácticas existe para que Miguel cambie el programa. Si la pantalla la lleva la Pi, ese ensayo no se ve.
2. El HAT VHF ya trae una OLED. Esos HAT suelen usar el I2C de la Pi, a menudo en `0x3C`. Chocar de dirección es **PENDIENTE** hasta saber qué HAT es.
3. El HAT va encima del cabezal de 40 pines. Si no los deja pasar, la Pi no puede sacar GPIO ni I2C al panel. Eso también es **PENDIENTE**.

**Referencia de medidas, no el módulo comprado.** [Waveshare 0.96inch OLED (B)](https://www.waveshare.com/0.96inch-oled-b.htm), ficha consultada el 2026-10-20: PCB 33,0 × 33,5 mm, área visible 21,70 × 11,20 mm, SSD1306, 128×64, SPI o I2C, pines rectos. Esa ficha lo describe como un cuarto amarillo y tres cuartos azul, no como un panel blanco. La línea «Operating Voltage» de la misma ficha dice **3,3 V**. La [wiki](https://www.waveshare.com/wiki/0.96inch_OLED_(B)) dice «Operating Voltage: 3.3V/5V» y, en el ejemplo con Arduino Uno, VCC a 3,3 V/5 V. No se elige entre las dos: el módulo real no está elegido ni medido (**PENDIENTE**), y no se alimenta a 5 V hasta mirar el suyo.

La ventana de la carcasa es 24 × 14 mm y la profundidad del marcador es 12 mm: las dos son **DISEÑO**, a partir del área visible y de la PCB de esa ficha. Si la imagen sale en espejo, en `oledInit()` probar `0xA0` en vez de `0xA1`; si sale boca abajo, `0xC0` en vez de `0xC8`. No se ha visto en un panel. El sketch usa la dirección `0x3C`. Confirmarla en el módulo: en SSD1306 también existe `0x3D`.

Cableado previsto, sin probar: VCC del módulo al 5 V del Nano solo si el módulo lo admite; si no, al 3,3 V (en un clon CH340 ese pin puede no existir o dar poca corriente, **PENDIENTE**). GND con GND, SDA a A4, SCL a A5. Muchos módulos traen las pull-up del I2C. Confirmarlo.

## Panel de pines (cara trasera)

No había pines de la Pi sacados al exterior. El bloque trasero que ya existía son prolongadores de audio, USB, HDMI, RJ45 y DC; los modelos de esos conectores siguen **PENDIENTES**. Este panel es nuevo, en `carcasa_x1_y1`, a la derecha de la costilla del corte X (x = 228) y por encima de ese bloque.

| | |
|---|---|
| Origen | x = 250 mm, z = 68 mm |
| Tamaño | 74 × 72 mm (**DISEÑO**). Llega a z = 140; el filete superior es de 5 mm y H ≈ 154 |
| Huecos de pin | Ø1,6 mm, paso 2,54 mm (**DISEÑO**). Si entra un conector de verdad es **PENDIENTE** |
| Rótulos grabados | `OLED`, `PRG`, `ARD 5V`, `PI 3V3`, `NO UNIR`. Fuente Noto Sans, girados para leerse desde fuera |
| Marca | Cuadrado junto al pin 1 de la Pi |

El paso de 2,54 mm no da para el nombre de cada pin. El mapa de abajo es la etiqueta. Visto **desde fuera**, por detrás, de izquierda a derecha. La fila de arriba es la de mayor z.

### Nano de prácticas (2 × 12)

No es el orden serigrafiado de la placa: es el orden de este panel.

| Fila de arriba | D2 | D3 | D4 | D5 | D6 | D7 | D8 | D9 | D10 | D11 | D12 | D13 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Fila de abajo | A0 | A1 | A2 | A3 | A4 | A5 | A6 | A7 | GND | RST | 5V | 3V3 |

A4 es SDA y A5 es SCL (la OLED). 5V, 3V3 y GND están en esta fila. En un clon con CH340 el pin de 3,3 V puede no existir o dar poca corriente: **PENDIENTE** de mirar la placa.

### Pi (2 × 20)

Orden del [cabezal de 40 pines](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#gpio-and-the-40-pin-header). Pin 1 (3V3) = extremo izquierdo de la fila de arriba, con la marca cuadrada. Pin 2 (5V) = extremo izquierdo de la fila de abajo.

| Arriba | 1 3V3 | 3 GPIO2 | 5 GPIO3 | 7 GPIO4 | 9 GND | 11 GPIO17 | 13 GPIO27 | 15 GPIO22 | 17 3V3 | 19 GPIO10 |
|---|---|---|---|---|---|---|---|---|---|---|
| Abajo | 2 5V | 4 5V | 6 GND | 8 GPIO14 | 10 GPIO15 | 12 GPIO18 | 14 GND | 16 GPIO23 | 18 GPIO24 | 20 GND |

| Arriba | 21 GPIO9 | 23 GPIO11 | 25 GND | 27 ID_SD | 29 GPIO5 | 31 GPIO6 | 33 GPIO13 | 35 GPIO19 | 37 GPIO26 | 39 GND |
|---|---|---|---|---|---|---|---|---|---|---|
| Abajo | 22 GPIO25 | 24 GPIO8 | 26 GPIO7 | 28 ID_SC | 30 GND | 32 GPIO12 | 34 GND | 36 GPIO16 | 38 GPIO20 | 40 GPIO21 |

GPIO2 es SDA y GPIO3 es SCL en la Pi. **No se cablea este cabezal hasta saber el HAT.** El HAT VHF va en el de 40 pines de la placa. Si no deja pasar los GPIO, este conector se queda en el plástico: **PENDIENTE**. `pi_h = 20` no incluye el HAT y el HAT no está modelado. Medidas del HAT: no se inventan.

Los dos cabezales **no van unidos entre sí**. El grabado `NO UNIR` es eso.

## Protecciones

**DISEÑO**, sin montar:

- Una resistencia de **1 kΩ en serie** en cada señal que salga al panel (pines de E/S, RST, TX, RX, SDA, SCL). No en 5V, 3V3 ni GND.
- A 5 V, un corto detrás de 1 kΩ queda en 5 mA. Es un límite de corriente, **no** un desplazador de nivel.
- Los pines del Nano son de **5 V**. Los GPIO de la Pi son de **3,3 V y no toleran 5 V**. No conectar una salida de 5 V del Nano a un GPIO de la Pi. No alimentar un pin de la Pi desde el 5 V del Nano.
- Las alimentaciones rotuladas son para los módulos de ese cabezal, no para puentear un cabezal con el otro.

## Compilación (2026-10-20, este entorno)

`arduino-cli` 1.5.1, core `arduino:avr` 1.8.8. Los dos FQBN, salida 0:

| Sketch | Flash | RAM |
|---|---|---|
| `monitor_pines` | 5558 bytes (18 % de 30720) | 480 bytes (23 % de 2048) |

El core, en otras pasadas, ha avisado de un parámetro `tag` sin usar en `new.cpp`. No es de este sketch. **No se ha subido a una placa.**
