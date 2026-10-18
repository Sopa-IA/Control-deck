# Conmutación de vídeo entre HP y Raspberry Pi

> Documento: `docs/conmutacion-video-usb.md` · Versión **HP v2, 2026-10-18** · Lo no verificado figura como **PENDIENTE de verificar**.
> **§V (plan vigente) prevalece** sobre las secciones 0–7, que son el estudio original de la fase 1 (KVM y pantallas táctiles) y se conservan como histórico.

## V. Plan vigente: la Pi lo controla todo, cambio automático desde Orbit OS

**Requisito de Miguel:** el cambio entre la Pi y el HP es **automático, desde Orbit OS**. Miguel **nunca** toca el menú OSD de la MSI. El HP y la Pi funcionan **a la vez y de forma independiente** (el HP con su Windows 10 Home); cambiar de sistema visible no reinicia ni apaga nada.

### V.1 Datos de partida (verificados o pendientes)

| Equipo | Vídeo | Fuente |
|---|---|---|
| HP Slimline 260-a110ns (placa Iris-A6) | **HDMI + VGA**; sin DisplayPort ni USB-C | Datos del propietario 2026-10-18; I/O trasero oficial de placas hermanas (`datos-pendientes-hp.md`) |
| Raspberry Pi 4/5 | micro-HDMI (×2); su USB-C es **solo alimentación** (no da vídeo DP Alt) | Documentación oficial de Raspberry Pi. Modelo exacto de la Pi de Miguel: PENDIENTE |
| MSI PRO MP161 E2U | 1 × Mini-HDMI + 2 × USB-C (DP Alt Mode; una USB-C puede alimentarla con PD) | Manual MSI (ver `pantallas.md`). **Si se le da vídeo por HDMI, necesita alimentación USB-C PD** (> 15 W según el manual) |

### V.2 Modo A — BASE (funciona seguro, sin adaptador)

- La **MSI muestra siempre la Pi**: cable micro-HDMI (Pi) → Mini-HDMI (MSI), y la MSI alimentada por un cargador USB-C PD certificado en una de sus USB-C. La entrada se deja fija y no se vuelve a tocar.
- El HP **no necesita cable de vídeo** en este modo. Ojo: Windows sin monitor conectado puede no generar escritorio a la resolución deseada para Sunshine; puede hacer falta un **emulador HDMI ("dummy plug")** en el HDMI del HP (compra) o un controlador de pantalla virtual. PENDIENTE de probar.
- "Ver el HP" = Orbit OS abre en la Pi un **visor del escritorio del HP por el Ethernet interno** (cable de red corto HP ↔ Pi, ver V.6):
  - **Sunshine en el HP + Moonlight en la Pi** (recomendado). Ambos son libres; Moonlight tiene cliente para Raspberry Pi OS.
  - **RDP: NO disponible tal cual**, porque **Windows 10 Home no incluye servidor de Escritorio remoto** (solo Pro/Enterprise). Requeriría actualizar a Pro (compra: decisión de Miguel).
  - **VNC** (servidor VNC en Windows, cliente en la Pi): alternativa de respaldo, sin aceleración de vídeo.
- A pantalla completa o en ventana, **con las superposiciones de Orbit encima** (indicadores, volumen, menú). Cómo se superponen en Raspberry Pi OS (compositor Wayland/labwc, ventana del visor + interfaz Orbit en Chromium) está **PENDIENTE de prototipar**.
- **Teclado y ratón:** en modo A están en la Pi y el visor los reenvía al HP; no hace falta conmutador USB.
- **Limitaciones honestas:** no se ve la BIOS ni el arranque del HP (solo el escritorio una vez iniciado Windows y Sunshine); el rendimiento depende del HP: **la codificación por hardware de Sunshine con la Radeon R4 (A6-7310) no está verificada**; si no está disponible, Sunshine codifica por software en una CPU de 15 W. **No se dan cifras de latencia ni de fps**: se medirán en la Fase 3.
- Audio: Moonlight transmite el audio del HP a la Pi (sale por la MSI si la Pi le manda audio por HDMI). PENDIENTE de probar.

### V.3 Modo B — OPCIONAL, imagen directa (sin verificar)

```
HP  HDMI ──── cable HDMI ↔ Mini-HDMI ───────────────► MSI Mini-HDMI
Pi  micro-HDMI ─► adaptador HDMI→USB-C (DP Alt) ────► MSI USB-C 1
Cargador USB-C PD certificado (> 15 W) ─────────────► MSI USB-C 2 (alimentación)
Pi ── ddcutil setvcp 60 <entrada> (DDC/CI por el HDMI de la Pi) ──► MSI
```
- **Adaptador de la Pi:** tiene que ser **activo y de este sentido: entrada HDMI → salida USB-C DP Alt Mode**. Son raros; la mayoría de los que se venden son del sentido contrario (USB-C → HDMI) y **no sirven**. Miguel tiene uno de **UGREEN, sin verificar y probablemente del sentido contrario**: comprobar el modelo exacto en su etiqueta antes de probarlo. Algunos adaptadores HDMI→USB-C necesitan alimentación USB propia: PENDIENTE.
- **Cambio de entrada:** orbitd ejecuta `ddcutil setvcp 60 <valor>` (VCP 0x60 "Input Source", estándar MCCS). **Que la MSI MP161 E2U admita DDC/CI y el cambio de entrada no está verificado**; los valores de cada entrada se leen con `ddcutil capabilities` y se configuran en `ORBIT_DDC_HP` / `ORBIT_DDC_PI`. Si la MSI pone la otra entrada, la Pi deja de verse: DDC/CI sigue funcionando por el cable de la Pi aunque la entrada no esté activa **solo si el monitor lo admite** (PENDIENTE; es la prueba clave).
- **Teclado y ratón** en modo B: los del HP deben ir al HP (o un conmutador USB). PENDIENTE de decidir; en modo A no hace falta.
- **Si DDC/CI falla**, orbitd intenta devolver la MSI a la Pi y **vuelve automáticamente al modo A**. El menú OSD **no** forma parte del flujo normal (solo como recuperación manual de emergencia en el banco de pruebas).
- **Alternativa de hardware a valorar (compra):** un conmutador HDMI 2→1 delante de la Mini-HDMI (HP y Pi por HDMI; la USB-C de la MSI solo para alimentación). Elimina el adaptador raro, pero la Pi solo podría manejarlo si el conmutador tiene un control documentado (IR, serie). PENDIENTE; no se compra nada sin decisión de Miguel.

### V.4 Botón y acción "Cambiar sistema visible" (implementado en orbitd)

- Acción de la lista blanca **`pi.switch_visible`** (sin parámetros; alterna HP ↔ Pi). La función de control homónima se asigna por defecto al **botón B2** (`controls.default.json`). La interfaz (sección Sistemas) tiene el mismo botón y muestra qué sistema está visible y en qué modo.
- orbitd elige el modo disponible (`software/pi-controller/orbitd/video.py`):
  1. **ddc** si `ORBIT_VIDEO_DDC=1`, `ddcutil` está instalado y `ORBIT_DDC_HP`/`ORBIT_DDC_PI` son valores hexadecimales válidos;
  2. si no, o si ddcutil falla, **remoto**: abre la orden fija del visor `ORBIT_REMOTE_CMD` (p. ej. `moonlight stream <ip-del-HP> Desktop`; la escribe el instalador, nunca la interfaz, y se ejecuta sin shell) y la cierra al volver a Orbit OS. Sin orden configurada, el cambio se registra como *dry-run* y la interfaz muestra el panel del HP.
- El estado `state` lleva `visible: {system, mode, detail}`. Probado con pruebas unitarias (sin ddcutil ni visor reales).

### V.5 Pruebas pendientes (Fase 3, banco)

1. `ddcutil detect` / `ddcutil capabilities` contra la MSI por el HDMI de la Pi: ¿DDC/CI? ¿VCP 0x60 escribible? ¿valores de Mini-HDMI y USB-C?
2. ¿Sigue respondiendo la MSI por DDC/CI cuando su entrada activa es la otra?
3. Adaptador HDMI→USB-C: modelo exacto del UGREEN de Miguel y sentido; imagen de la Pi en la USB-C de la MSI.
4. Sunshine en el HP (Windows 10 Home, Radeon R4): ¿codificación por hardware? Moonlight en la Pi: estabilidad, uso de CPU, **latencia y fps medidos** (no se estiman).
5. Superposición de la interfaz Orbit sobre la ventana de Moonlight en el compositor de la Pi.

### V.6 Cableado y huecos en el CAD (HP v2)

Los cables ilustrativos de los renders muestran el cableado del **modo B** (el más exigente en espacio).

- **Modo A:** micro-HDMI de la Pi → Mini-HDMI de la MSI por dentro (sin pasar por el pasacables).
- **Modo B — HDMI del HP:** sale por la ventana I/O trasera y vuelve a entrar por el **pasacables trasero** (40 × 16 mm) hacia la Mini-HDMI de la MSI. Por el mismo pasacables entra el cable del **cargador USB-C PD** de la MSI (USB-C 2).
- **Modo B — adaptador HDMI→USB-C de la Pi:** **hueco reservado de 72 × 32 × 16 mm** en la bandeja de servicio, delante de la Pi (medidas reales PENDIENTES); cable corto micro-HDMI → adaptador y USB-C → MSI USB-C 1.
- **Ethernet interno HP ↔ Pi:** cable de red corto. El RJ45 del HP está en su I/O trasero (mirando hacia fuera), así que el latiguillo sale por la ventana y entra por el pasacables o va al RJ45 de la Pi por detrás. Con enlace directo, la Pi sale a Internet por Wi-Fi (o se añade un conmutador de red pequeño: compra, PENDIENTE). Direccionamiento IP fijo/enlace local: PENDIENTE de configurar.

---

## 0. Aclaración fundamental

**Conmutar la entrada de vídeo NO es cambiar de sistema operativo.** El HP y la Raspberry Pi son dos ordenadores independientes que funcionan **a la vez**, cada uno con su sistema operativo. El botón "cambiar sistema visible" solo decide **qué ordenador ve el usuario en la pantalla y cuál recibe el táctil**. El otro sigue encendido, ejecutando sus tareas y comunicándose por la red local. Nada se reinicia, nada "arranca" otro sistema y no hay dual-boot.

## 1. Qué hay que conmutar

| Señal | Dirección | Notas |
|---|---|---|
| Vídeo HDMI | Host → pantalla | 1920×720 @ 60 Hz (pixel clock de 100,20 MHz según la EDID publicada por Waveshare para el modelo In-Cell 12,3": https://www.waveshare.com/wiki/12.3inch_1920x720_LCD), muy por debajo del límite de cualquier KVM HDMI 1.4/2.0. |
| Táctil USB HID | Pantalla → host | Es un dispositivo **HID multitáctil**. Debe pasar por un puerto USB **transparente** (hub) del KVM, no por los puertos de teclado/ratón con emulación. |
| Audio | Opcional | Fuera del alcance de la Fase 1. |

## 2. Opciones de arquitectura

### Opción A: KVM HDMI + USB comercial (recomendada para el prototipo)
Un KVM 2×1 conmuta a la vez el HDMI y un hub USB. La pantalla y su táctil se conectan a la salida del KVM.

### Opción B: pantalla con varias entradas + conmutador USB aparte
- Ninguna de las pantallas de 10–12,3" estudiadas tiene **dos entradas HDMI**. La Waveshare 11.6" (H) con carcasa tiene HDMI + VGA (https://www.waveshare.com/wiki/11.6inch_HDMI_LCD_(H)_(with_case)), y la 12,3" In-Cell tiene HDMI + USB-C con DP Alt Mode (https://www.waveshare.com/wiki/12.3inch_1920x720_LCD).
- La selección de entrada se hace en el menú OSD, con botones físicos. **No hay documentación** de que pueda cambiarse por DDC/CI (código VCP 0x60, "Input Source", del estándar MCCS). Solo consta el control de brillo por DDC/CI en el modelo In-Cell. → **pendiente de verificar** con `ddcutil` (https://www.ddcutil.com/) en el banco de pruebas.
- El táctil seguiría necesitando un conmutador USB aparte, sincronizado con la entrada de vídeo.
- **Conclusión:** solo sería viable si el HP dispusiera de USB-C con DP Alt Mode (dato desconocido). Con más piezas y sin control documentado, se descarta por ahora.

### Opción C: sin KVM, con el escritorio del HP por red (alternativa a estudiar)
La pantalla se conecta solo a la Pi, y la Pi muestra el escritorio del HP con un cliente de escritorio remoto (RDP/VNC) a través del enlace de red local.
- **Ventajas:** no hace falta ningún KVM ni problemas de EDID, el táctil siempre lo gestiona la Pi y el cambio es instantáneo.
- **Inconvenientes:** latencia y rendimiento limitados (vídeo y juegos), no se ven la BIOS ni el arranque del HP, y depende de que el SO del HP admita escritorio remoto (por ejemplo, el servidor RDP no viene en las ediciones Home de Windows; **pendiente de verificar** según el SO de Miguel).
- Puede servir como **modo complementario** (ver el HP desde la Pi sin conmutar), no como sustituto.

## 3. KVM compactos de 2 puertos: referencias reales

| Modelo | Vídeo | USB para el táctil | Control remoto / externo | EDID | Alimentación | Dimensiones | Precio (fuente, 2026-10-18) |
|---|---|---|---|---|---|---|---|
| **UGREEN CM664** (P/N 15707) | HDMI 2.0, hasta 4K@60 | Hub USB 3.0 (3×A + 1×C de salida, 2×USB-B de entrada). **Sin conmutación por teclas**, lo que sugiere que no hay emulación HID (pendiente de verificar con el táctil) | Botón + mando de sobremesa con cable (puerto Mini-USB, protocolo **no documentado**) | Emulación EDID **no indicada** en el manual: pendiente de verificar | USB-C | pendiente | **196,17 PLN** con IVA (ugreen.pl); "desde 41,22 €" en idealo.de según el buscador (sin comprobación directa) |
| **ATEN CS692** | HDMI, hasta 1920×1200@60 | El puerto USB 2.0 del ratón admite un hub **solo si se desactiva la emulación de ratón** | Selector remoto (cable de 1,8 m), teclas de acceso rápido, ratón | "Video DynaSync" (ATEN) para evitar problemas de vídeo en el arranque y al conmutar | Alimentado por bus, DC 5 V, 0,72 W típicos (ATEN) | 82,4 × 66,5 × 25,2 mm | **78,66 €** con IVA (LIFE Informàtica, ES) |
| **TESmart HKS201-P23-V2** | HDMI 2.0, hasta 4K@60 4:4:4 | Hub USB 3.0 compartido; puertos de teclado/ratón dedicados con modo de compatibilidad | Botón frontal, **mando IR**, teclas de acceso rápido, rueda del ratón | **Emulación EDID integrada** | DC 12 V | pendiente | **129,99 USD** (tesmart.com, tienda de EE. UU.) |

Fuentes: UGREEN https://www.manualslib.com/manual/3975344/Ugreen-Cm664.html y https://www.ugreen.pl/en/products/other-products/kvm/ugreen-cm664-hdmi-kvm-switch-2-in-1-black-158548 · ATEN https://www.aten.com/us/en/products/kvm/cable-kvm-switches/cs692/ y https://lifeinformatica.com/tienda/aten-cs692-at-2-pc-hdmi-usb-audio-kvm/ · TESmart https://www.tesmart.com/products/hks201-p23-v2

Descartado: **UGREEN "KVM Switch 2 PCs 4K@60Hz 5Gbps" (SKU 25960, 89,99 €)**. Una de sus entradas es USB-C con DP Alt Mode (https://eu.ugreen.com/products/kvm-switch-2pcs-4k60hz-5gbps), que la Pi no tiene, y no consta que el HP la tenga.

### Recomendación preliminar
- **Producto: TESmart HKS201-P23-V2.** Tiene **emulación EDID**, imprescindible para que ningún host "pierda" la pantalla al conmutar, y un **mando IR** que la Pi puede emular con un LED IR (§4.2) sin abrir el aparato. Su hub USB 3.0 está separado de los puertos de teclado/ratón. Pendiente: disponibilidad en la UE, dimensiones (para el chasis) y protocolo IR.
- **Banco de pruebas de bajo coste: UGREEN CM664.** Es barato y su USB no tiene teclas de acceso rápido. Hay que verificar el comportamiento EDID y de hotplug, y el control desde la Pi exige intervenir el mando con cable.
- **ATEN CS692:** solo si el táctil funciona con la emulación de ratón desactivada. Es el más compacto y el de menor consumo.

> Ningún fabricante garantiza explícitamente la compatibilidad con **pantallas táctiles HID multitáctiles**. Es el **riesgo técnico n.º 1** de la Fase 3 y hay que probarlo en el banco antes de cerrar el diseño de la carcasa.

## 4. Control del KVM desde la Raspberry Pi (botón "cambiar sistema visible")

El botón físico del chasis va a un GPIO de la Pi. La Pi decide y ordena el cambio al KVM. Así el software sabe siempre qué sistema está visible, y puede, por ejemplo, encender el ámbar del lado activo.

### 4.1 Emulación del pulsador (cualquier KVM con botón o mando con cable)
- Se conecta un **optoacoplador** (o un relé de señal) en paralelo con los contactos del pulsador del KVM o de su mando con cable, y la Pi lo activa con un pulso de unos 100–200 ms (**duración pendiente de verificar**).
- Hay que abrir el mando o el KVM e **identificar con el polímetro** los contactos y sus tensiones. No está documentado por el fabricante, anula la garantía y se hace bajo la responsabilidad del propietario.
- Para el CM664, el puerto Mini-USB del mando con cable usa un protocolo **no documentado**. Antes de decidir hay que medirlo en el banco: puede ser un simple contacto a masa o una señal más compleja.

### 4.2 Emulación del mando IR (TESmart)
- La Pi puede **recibir** códigos IR con `dtoverlay=gpio-ir` (decodificación en el kernel, configurable con `ir-keytable`) y **emitirlos** con `dtoverlay=gpio-ir-tx` (salida IR por GPIO). Ambos overlays están documentados en https://github.com/raspberrypi/linux/blob/rpi-6.12.y/arch/arm/boot/dts/overlays/README
- Procedimiento: (1) capturar los códigos del mando original con un receptor IR; (2) reproducirlos con un LED IR orientado al sensor del KVM, dentro del chasis. Es reversible y no hay que abrir nada.
- El protocolo y los códigos IR del HKS201 **no están publicados: pendiente de verificar** por captura.

### 4.3 Teclas de acceso rápido (ATEN, TESmart)
- Un microcontrolador USB HID (por ejemplo RP2040) conectado al puerto de teclado del KVM podría enviar la secuencia de teclas del fabricante. La secuencia exacta está en el manual de cada modelo: **pendiente de transcribir y verificar**. Es más complejo que §4.1/§4.2 y solo tiene sentido si la emulación IR fallara.

### 4.4 Puerto serie RS-232 / LAN
- En TESmart, el control RS-232/LAN solo aparece en modelos de 8 y 16 puertos (https://www.tesmart.com/products/hks801-p23), demasiado grandes. **No se ha encontrado ningún KVM compacto de 2 puertos con RS-232 documentado.**

### 4.5 Detección del estado
- El KVM no informa del puerto activo. Opciones: (a) que la Pi mantenga el estado lógico; (b) leer los LED del KVM con un fototransistor (pendiente de evaluar); (c) que la Pi compruebe si recibe eventos del táctil (si los recibe, es el host activo).

## 5. EDID y hotplug

| Problema | Efecto | Mitigación |
|---|---|---|
| El host inactivo deja de ver la pantalla (HPD cae) | Windows reorganiza ventanas o cambia de resolución; Linux/KMS puede apagar la salida | KVM con **emulación EDID** (TESmart). En la Pi, forzar el modo de vídeo. |
| La Pi arranca sin pantalla visible | Puede no activar la salida HDMI | Con KMS, el kernel admite `video=HDMI-A-1:1920x720@60D` (el sufijo `D` fuerza la salida, según https://www.kernel.org/doc/html/latest/fb/modedb.html). En el firmware antiguo existía `hdmi_force_hotplug=1` (https://www.raspberrypi.com/documentation/computers/legacy_config_txt.html). Waveshare documenta `hdmi_cvt 1920 720 60 6 0 0 0` para su modelo de 12,3" (https://www.waveshare.com/wiki/12.3inch_HDMI_LCD). **Pendiente de verificar** en Raspberry Pi OS actual. |
| Algunos PC no detectan la pantalla en caliente | Pantalla negra hasta reiniciar | Waveshare advierte que "some PCs do not support plug-and-play with HDMI devices… can be used normally after restarting" (wiki de 12,3"). Se mitiga con la emulación EDID. |
| Resolución no estándar (1920×720) | Algunos hosts antiguos pueden no ofrecerla | Depende de la GPU del HP: **pendiente**. |

## 6. Calibración y asignación del táctil por sistema

- **Windows:** con varios monitores, el táctil se asigna por defecto a la pantalla principal. Se corrige en "Calibrar la pantalla para entrada manuscrita o táctil" → "Configurar" (procedimiento en https://www.waveshare.com/wiki/12.3inch_HDMI_LCD). En Orbit Terminal la pantalla será la única, pero si el HP tuviera otro monitor habría que repetirlo.
- **Raspberry Pi OS (Wayland/labwc) y Linux en el HP:** el táctil llega como dispositivo libinput. Si se rota la pantalla, hay que aplicar una matriz de calibración (`CalibrationMatrix`, ejemplo en https://www.waveshare.com/wiki/12.3inch_1920x720_LCD para X11). En Wayland, la asignación del táctil a la salida depende del compositor: **pendiente de verificar** en labwc.
- **Multitáctil:** según el fabricante, 10 puntos en Windows y Raspberry Pi OS y 1 punto en Ubuntu/Kali (páginas de producto de Waveshare). Hay que probarlo en el SO real del HP.
- Cada host conserva su propia calibración, así que el KVM no necesita "recordar" nada.

## 7. Plan de verificación (Fase 3, banco de pruebas)

1. HP + Pi + KVM + pantalla elegida, sin carcasa.
2. Medir: tiempo hasta imagen estable tras conmutar (cronómetro o vídeo), táctil funcional en ambos hosts, número de puntos táctiles por SO, y comportamiento del host inactivo (¿pierde la resolución?).
3. Probar el control desde la Pi (IR o pulsador emulado) en 100 conmutaciones consecutivas sin fallos.
4. Registrar los resultados como **medidos** en `docs/pruebas/`, separados de las simulaciones.
