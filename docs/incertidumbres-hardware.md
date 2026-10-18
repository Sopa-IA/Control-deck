# Registro de incertidumbres de hardware

> Documento: `docs/incertidumbres-hardware.md` · Versión 2026-10-18 (HP v2: HP Slimline 260-a110ns desmontado; cambio automático de sistema visible)
> Escala: **Impacto** (A alto / M medio / B bajo) sobre el diseño · **Estado**: Abierta / En verificación / Cerrada.
> Cada incertidumbre indica qué la bloquea y cómo se cerrará. Las referencias "D-x.y" remiten a la fila x.y de `datos-pendientes-hp.md`.

| ID | Incertidumbre | Impacto | Qué bloquea | Cómo se cierra | Estado |
|---|---|---|---|---|---|
| U-01 | ~~Modelo exacto del HP~~ → **HP Slimline 260-a110ns**, placa "Iris-A6" (provisional) | A | — | Datos del propietario 2026-10-18 + fichas HP de modelos hermanos (`datos-pendientes-hp.md`) | **Cerrada** (nombre de placa PENDIENTE de serigrafía) |
| U-02 | ~~Salidas de vídeo del HP~~ → **HDMI + VGA**, sin DP ni USB-C | A | — | Datos del propietario; I/O trasero oficial de placas hermanas | **Cerrada** |
| U-03 | **Compatibilidad del táctil HID multitáctil con el KVM** | A | Toda la conmutación | Prueba en banco (Fase 3). Ningún fabricante la garantiza | Abierta |
| U-04 | **Comportamiento EDID/hotplug al conmutar** (sobre todo con el UGREEN CM664, sin emulación EDID declarada) | A | Experiencia de conmutación | Prueba en banco; KVM con emulación EDID (TESmart) | Abierta |
| U-05 | **Control del KVM desde la Pi** (protocolo IR del TESmart, mando con cable del UGREEN) | M | Botón "cambiar sistema" | Captura IR con receptor + `gpio-ir`; medición con polímetro | Abierta |
| U-06 | Proporción de la pantalla: barra 8:3 frente a 16:9 (el render no es técnicamente fiable) | A | Dimensiones de la cuña, CAD | Decisión del propietario (D-9.1) | Abierta |
| U-07 | Fuente del HP → **adaptador externo 65 W 19,5 V 3,33 A** al jack DC de la placa. Sigue abierto el **consumo real** | M | Térmica | Medidor de enchufe (H-12) | En verificación |
| U-08 | **Medidas de la placa desnuda**: anclajes, altura de componentes (≤ 41 mm admitidos), pila I/O, disipador y sentido del aire | A | CAD (separadores, ventana I/O, rejillas) | Medir tras desmontar (H-2…H-5) | Abierta |
| U-09 | Encendido del HP: **patillaje del cabezal del botón** (pulsador de Orbit en paralelo), WoL y After Power Loss | M | Botón de encendido del HP | Polímetro (H-6) y BIOS (H-11) | Abierta |
| U-10 | Modelo de Raspberry Pi disponible | M | Librería LED, fuente, térmica | D-7.1 | Abierta |
| U-11 | Soporte multitáctil en el SO del HP (el fabricante garantiza 10 puntos en Windows y Raspberry Pi OS, 1 punto en Ubuntu/Kali) | M | UX en el HP | Prueba con el SO real | Abierta |
| U-12 | **Selección de entrada de la MSI por DDC/CI** (VCP 0x60) desde la Pi | M | Modo B (opcional) del cambio de sistema | `ddcutil capabilities` en el banco (`conmutacion-video-usb.md` §V.5) | Abierta |
| U-13 | Térmica del conjunto cerrado (HP + Pi + KVM + pantalla) | A | Rejillas, ventilador | Medición de temperaturas en un prototipo abierto y luego cerrado | Abierta |
| U-14 | Consumo real de la tira SK6812 WWA elegida (el datasheet indica un encapsulado de "0,2 W") | B | Fuente de 5 V para LED | Medición con la tira real | Abierta |
| U-15 | Disponibilidad en la UE y dimensiones del TESmart HKS201-P23-V2 | M | Compra y CAD | Consulta a un distribuidor de la UE (lo hace el propietario) | Abierta |
| U-16 | **Modo A (base):** Sunshine en el HP (Windows 10 Home, Radeon R4: codificación por hardware sin verificar) + Moonlight en la Pi; superposición de Orbit sobre el visor. RDP descartado sin Windows Pro | A | Ver el HP en Orbit | Prueba en banco; latencia y fps **medidos**, nunca estimados | Abierta |
| U-17 | Precios en euros con IVA en España para la mayoría de componentes | M | Presupuesto definitivo | Revalidar antes de cada compra (fecha y fuente) | Abierta |
| U-19 | **Adaptador HDMI→USB-C (DP Alt) para la Pi** en el sentido correcto; el UGREEN de Miguel probablemente es del sentido contrario | M | Modo B | Modelo exacto + prueba en banco | Abierta |
| U-20 | **Térmica de la placa del HP en la carcasa de PETG** (disipador original, rejillas inferior/lateral/trasera) | A | Cierre del diseño | Medir temperaturas abierta/cerrada; PETG ~70–80 °C de reblandecimiento (ficha del filamento PENDIENTE) | Abierta |
| U-21 | Placa de I/O frontal del HP (USB 2.0, audio, lector SD) y cables SATA/antenas: medidas y longitudes | M | Ventana lateral, soporte del disco | Medir tras desmontar (H-7…H-9) | Abierta |
| U-18 | Seguridad eléctrica del conjunto (fuentes internas o externas, fusibles, aislamiento) | A | Diseño de alimentación | Usar solo fuentes comerciales certificadas; sin circuitos de red diseñados por el proyecto | Abierta (criterio fijado) |

## Riesgos principales y plan B

0. **HP v2:** U-03/U-04/U-05/U-15 (KVM y táctil) dejan de bloquear: no hay KVM ni pantalla táctil en el prototipo. El riesgo principal pasa a ser **U-16** (modo remoto) y, para la imagen directa, **U-12 + U-19**. Si el modo B no funciona, el modo A sigue siendo el plan base.
1. **U-03 (táctil a través del KVM) falla:** plan B 1, conectar el USB del táctil a un **conmutador USB** independiente sincronizado por la Pi; plan B 2, **opción C** (escritorio remoto del HP en la Pi).
2. **U-02 (el HP no tiene HDMI ni DP++):** adaptador activo DP→HDMI o VGA→HDMI (modelo y precio pendientes) o la pantalla Waveshare 11.6" (H) con entrada VGA.
3. **U-13 (térmica):** separar el compartimento del HP con su propio flujo de aire. Si no basta, ventilador de 5 V controlado por la Pi.
