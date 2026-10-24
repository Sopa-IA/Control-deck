# Alimentación: enfoque preliminar

> Documento: `docs/alimentacion-preliminar.md` · Fuentes comprobadas el **2026-10-18**
> **Principios de seguridad (no negociables):**
> 1. El proyecto **no diseña ningún circuito conectado a la red eléctrica (230 V AC)**. Solo se usan **fuentes comerciales certificadas** (marcado CE, con el modelo identificado) tal como las entrega el fabricante.
> 2. Dentro del chasis solo circula **baja tensión continua** (≤ 20 V DC según las fuentes elegidas).
> 3. **La batería queda fuera de la Fase 1**: solo como estudio futuro (ver §5).
> 4. Ningún consumo se inventa: los valores proceden de datasheets o documentación del fabricante, o figuran como **pendiente**. En la Fase 3 se sustituirán por **mediciones**.

## 0. Plan vigente (HP v2, 2026-10-18)

```
Regleta comercial certificada (fuera de Orbit)
 ├─ Adaptador original HP 65 W, 19,5 V 3,33 A (externo, certificado) ─► jack DC del I/O trasero de la placa HP
 ├─ Fuente USB-C certificada para la Raspberry Pi (oficial: 5,1 V 3 A Pi 4 / 5,1 V 5 A Pi 5) ─► USB-C de la Pi
 └─ Cargador USB-C PD certificado (> 15 W según el manual MSI) ─► USB-C 2 de la MSI (obligatorio si recibe vídeo por HDMI)
     (alternativa: un único cargador USB-C PD multipuerto certificado para Pi + MSI, si Miguel tiene uno y
      reparte potencia suficiente por puerto: PENDIENTE de comprobar su etiqueta)
Nano de mandos ◄─ USB de la Pi (serie, siempre conectado)
ESP8266 ◄─ otro USB de la Pi (corriente; WLED se graba una vez)
Nano de prácticas ◄─ prolongador al panel trasero; si no hay portátil, puente a un USB de la Pi
Adaptador HDMI→USB-C ◄─ USB, si lo necesita (PENDIENTE)
```
El teclado y el ratón son Bluetooth, emparejados con la Pi: no ocupan un USB.
- **2026-10-20.** La Pi es una Pi 4 (Miguel). Tiene cuatro USB de tipo A. El reparto de arriba es **DISEÑO**, el presupuesto de corriente no se ha medido y no se supone un hub. La tira LED no se alimenta del pin de 3,3 V del ESP. Dentro de la cuña sigue sin haber red eléctrica.
- **Dentro de Orbit no hay red eléctrica**: el adaptador del HP queda fuera y su cable DC entra directamente en la placa por la ventana I/O trasera (datos del propietario 2026-10-18; HP: adaptador externo 19,5 V 3,3 A y entrada DC en el I/O trasero de las placas hermanas Iris-E2/Iris-A8, ver `datos-pendientes-hp.md`).
- **No hace falta distribución DC interna** (la caja "Distribución DC" del CAD v1 se desactiva: `usar_distribucion = false`). Cada equipo usa su fuente certificada.
- La placa del HP alimenta ella misma su disco SATA y su ventilador (cables originales). Un SSD de 2,5" consume menos que el HDD de 3,5" (valor real: ficha del SSD elegido, PENDIENTE).
- Consumo real del HP: **PENDIENTE de medir** con un medidor de enchufe (no se usa el 65 W del adaptador como consumo).
- Encendido del HP: pulsador de panel de Orbit (lateral izquierdo) **en paralelo** con el del cabezal original (contacto seco, sin tensión de red). Encendido desde la Pi: Wake-on-LAN si la BIOS lo permite (H-11) o, más adelante, un optoacoplador en paralelo con el pulsador (patillaje PENDIENTE, H-6).

> Las secciones 1–5 son el estudio de la fase 1 y siguen valiendo como principios; donde no coincidan, prevalece §0.

## 1. Arquitectura propuesta (preliminar)

### Variante 1: fuentes externas originales (recomendada para el prototipo)
```
Red 230 V ─┬─ Adaptador original del HP (certificado) ────────► HP (conector original)
           ├─ Fuente oficial de la Raspberry Pi (USB-C 5,1 V) ─► Pi
           └─ Fuente certificada de 5 V o 12 V para pantalla + LED + KVM ─► Raíl interno DC
```
- Se reutiliza el adaptador original del HP (ya certificado y adecuado a su "smart pin", si lo tuviera).
- La entrada de corriente del chasis puede ser una **regleta comercial certificada** externa. El chasis solo recibe los conectores DC de baja tensión de cada adaptador por pasamuros.
- Ventaja: cero diseño de red y cada equipo con la fuente para la que fue certificado. Inconveniente: varios adaptadores externos.

### Variante 2: una fuente DC única + convertidores DC-DC (evaluar en la Fase 3)
```
Red 230 V ─ Fuente certificada única (p. ej. 19–20 V o 12 V, potencia pendiente) ─► Raíl principal DC
   ├─ HP (solo si su tensión coincide y el conector o "smart pin" lo permiten)
   ├─ Convertidor DC-DC comercial → 5,1 V / 5 A → Pi 5 (USB-C sin PD; verificar comportamiento)
   └─ Convertidor DC-DC comercial → 5 V → pantalla, LED y KVM
```
- Solo viable cuando se conozcan la tensión y el conector del HP (U-07). Los convertidores DC-DC serían módulos comerciales con datasheet, no diseño propio. **Pendiente de evaluar.**
- Riesgo: la Pi 5 negocia 5 A por USB-PD. Con una fuente sin PD limita el USB a 600 mA (documentación oficial). Pendiente de comprobar el método oficial para indicar una fuente de 5 A sin PD (`usb_max_current_enable`, mencionado en la documentación oficial).

## 2. Tabla de consumidores (solo con valores documentados)

| Consumidor | Tensión | Valor documentado | Tipo de dato | Fuente |
|---|---|---|---|---|
| HP Slimline 260-a110ns | 19,5 V DC | Adaptador de 65 W (19,5 V 3,33 A); **consumo real pendiente** | Capacidad del adaptador, no consumo | Datos del propietario 2026-10-18; HP (modelos hermanos) |
| MSI PRO MP161 E2U | USB-C PD 5–15 V | Requiere > 15 W por USB-C cuando no la alimenta la fuente de vídeo | Fabricante | Manual MSI (ver `pantallas.md`) |
| Raspberry Pi 5 | 5,1 V | Fuente recomendada de 5,0 A; 800 mA bare-board activo; USB para periféricos de hasta 1,6 A | Recomendación / típico | power-supplies.adoc (oficial)¹ |
| Raspberry Pi 4B | 5,1 V | Fuente de 3,0 A; 600 mA bare-board; 1,25 A máx. en estrés (tabla oficial) | Recomendación / medido por el fabricante | ¹ |
| Raspberry Pi 3B+ | 5,1 V | Fuente de 2,5 A; 500 mA bare-board | Recomendación / típico | ¹ |
| Pi 5 apagada | 5,1 V | ~1–1,4 W por defecto; ~0,01 W con `POWER_OFF_ON_HALT=1` | Fabricante | ¹ |
| Pantalla Waveshare 12.3" In-Cell (28481) | 5 V | **Máx. 5 W**; adaptador recomendado de 5 V 3 A | Máximo | https://www.waveshare.com/wiki/12.3inch_1920x720_LCD |
| Pantalla Waveshare 12.3" HDMI LCD 600 nit | 12 V | **1,25 A** de corriente de trabajo | Fabricante | https://www.waveshare.com/wiki/12.3inch_HDMI_LCD |
| Pantalla Waveshare 11.6" (H) | 12 V (+5 V del USB táctil) | ~0,5 A a 12 V en uso normal (adaptador de 1 A) + ~80 mA a 5 V | Fabricante | https://www.waveshare.com/wiki/11.6inch_HDMI_LCD_(H) |
| Pantalla Waveshare 10.1" (B) | 5 V | ~750 mA con la retroiluminación encendida, ~300 mA apagada | Fabricante | https://www.waveshare.com/wiki/10.1inch_HDMI_LCD_(B)_(with_case) |
| Pantalla Elecrow DIS85101D | 5 V | Máx. 5,29 W | Máximo | datasheet de Elecrow |
| KVM ATEN CS692 | 5 V (bus) | 0,72 W típico sin carga | Fabricante | https://www.aten.com/us/en/products/kvm/cable-kvm-switches/cs692/ |
| KVM TESmart HKS201-P23-V2 | 12 V DC | **pendiente** (no publicado en la ficha) | — | https://www.tesmart.com/products/hks201-p23-v2 |
| KVM UGREEN CM664 | USB-C | **pendiente** | — | manual de UGREEN |
| Tira SK6812 WWA (N LED) | 5 V | Encapsulado de "0,2 W" por LED → cota preliminar de N × 0,2 W | Fabricante (cota) | datasheet SK6812WWA |
| Codificadores PEC11R (×2) | 3,3 V (lógica) | Contacto de 10 mA a 5 V DC (valor nominal); la corriente real la fija el pull-up (~0,33 mA con 10 kΩ a 3,3 V, por ley de Ohm) | Cálculo | datasheet de Bourns |
| Ventilador (si hiciera falta) | 5 V | El ventilador de la caja oficial de la Pi consume ~60 mA a 5 V (300 mW) | Fabricante | ¹ |

¹ https://github.com/raspberrypi/documentation/blob/master/documentation/asciidoc/computers/raspberry-pi/power-supplies.adoc

**No se suma un total** porque el término dominante (el HP) es desconocido. El presupuesto de potencia se cerrará cuando se cierre U-07.

## 3. Secuencia de encendido y apagado (lógica preliminar)

1. **Encendido:** al pulsar el botón del chasis, la Pi (siempre alimentada o despertada por GPIO3/J2) arranca. Después enciende el HP por **Wake-on-LAN** (si la BIOS lo permite, U-09) o, como alternativa, con un optoacoplador en paralelo con el botón del HP (solo si se valida el acceso sin modificar la red eléctrica).
2. **Apagado seguro:** con una pulsación larga, la Pi pide al agente del HP un apagado ordenado (mensaje autenticado), espera la confirmación o la pérdida de latido con un tiempo de espera configurable, y después se apaga ella.
3. **Corte de corriente:** sin batería no hay apagado limpio posible. Se documenta como limitación y la BIOS "After Power Loss" decidirá el comportamiento al volver la corriente.

## 4. Protecciones previstas (solo en baja tensión)
- Fusible o polifusible en cada raíl DC interno, dimensionado cuando se conozcan los consumos (pendiente).
- Conectores con polaridad indicada y cables de sección adecuada a la corriente (cálculo en la Fase 3).
- Condensador de entrada en la tira LED (valor según la tira elegida).
- Separación física entre los adaptadores externos y la electrónica interna.

## 5. Batería (solo estudio futuro)
- No forma parte de la Fase 1 ni del prototipo. Requeriría un SAI/power bank comercial certificado compatible con la tensión del HP o un BMS comercial. El proyecto **no diseñará** cargadores ni BMS propios.
- Abrir este estudio solo cuando estén cerrados U-07 (fuente del HP) y U-13 (térmica).
