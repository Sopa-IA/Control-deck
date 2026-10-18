# Registro de incertidumbres de hardware

> Documento: `docs/incertidumbres-hardware.md` · Versión 2026-10-18
> Escala: **Impacto** (A alto / M medio / B bajo) sobre el diseño · **Estado**: Abierta / En verificación / Cerrada.
> Cada incertidumbre indica qué la bloquea y cómo se cerrará. Las referencias "D-x.y" remiten a la fila x.y de `datos-pendientes-hp.md`.

| ID | Incertidumbre | Impacto | Qué bloquea | Cómo se cierra | Estado |
|---|---|---|---|---|---|
| U-01 | **Modelo exacto del "HP Mini"** (netbook o Desktop Mini, generación) | A | Chasis, KVM, alimentación y térmica | Foto de la etiqueta y P/N → QuickSpecs oficiales (D-1.1) | Abierta |
| U-02 | **Salidas de vídeo del HP** (HDMI / DP / DP++ / VGA / USB-C con DP) | A | Elección del KVM y del adaptador | Fotos de los puertos (D-3.1) | Abierta |
| U-03 | **Compatibilidad del táctil HID multitáctil con el KVM** | A | Toda la conmutación | Prueba en banco (Fase 3). Ningún fabricante la garantiza | Abierta |
| U-04 | **Comportamiento EDID/hotplug al conmutar** (sobre todo con el UGREEN CM664, sin emulación EDID declarada) | A | Experiencia de conmutación | Prueba en banco; KVM con emulación EDID (TESmart) | Abierta |
| U-05 | **Control del KVM desde la Pi** (protocolo IR del TESmart, mando con cable del UGREEN) | M | Botón "cambiar sistema" | Captura IR con receptor + `gpio-ir`; medición con polímetro | Abierta |
| U-06 | Proporción de la pantalla: barra 8:3 frente a 16:9 (el render no es técnicamente fiable) | A | Dimensiones de la cuña, CAD | Decisión del propietario (D-9.1) | Abierta |
| U-07 | **Fuente y consumo reales del HP** | A | Alimentación y térmica | Etiqueta del adaptador + medición (D-4.x) | Abierta |
| U-08 | **Dimensiones del HP y posición de sus rejillas** | A | CAD de la carcasa y flujo de aire | Calibre y fotos (D-5.x) | Abierta |
| U-09 | Encendido remoto del HP (WoL, After Power Loss, acceso al botón) | M | Botón de encendido único | Comprobar la BIOS (D-6.2/6.3) | Abierta |
| U-10 | Modelo de Raspberry Pi disponible | M | Librería LED, fuente, térmica | D-7.1 | Abierta |
| U-11 | Soporte multitáctil en el SO del HP (el fabricante garantiza 10 puntos en Windows y Raspberry Pi OS, 1 punto en Ubuntu/Kali) | M | UX en el HP | Prueba con el SO real | Abierta |
| U-12 | Selección de entrada de la pantalla por DDC/CI (VCP 0x60) | B | Opción B de conmutación | `ddcutil` en el banco | Abierta |
| U-13 | Térmica del conjunto cerrado (HP + Pi + KVM + pantalla) | A | Rejillas, ventilador | Medición de temperaturas en un prototipo abierto y luego cerrado | Abierta |
| U-14 | Consumo real de la tira SK6812 WWA elegida (el datasheet indica un encapsulado de "0,2 W") | B | Fuente de 5 V para LED | Medición con la tira real | Abierta |
| U-15 | Disponibilidad en la UE y dimensiones del TESmart HKS201-P23-V2 | M | Compra y CAD | Consulta a un distribuidor de la UE (lo hace el propietario) | Abierta |
| U-16 | Escritorio remoto del HP desde la Pi (opción C): edición del SO y rendimiento | B | Modo complementario | Prueba en la Fase 3 | Abierta |
| U-17 | Precios en euros con IVA en España para la mayoría de componentes | M | Presupuesto definitivo | Revalidar antes de cada compra (fecha y fuente) | Abierta |
| U-18 | Seguridad eléctrica del conjunto (fuentes internas o externas, fusibles, aislamiento) | A | Diseño de alimentación | Usar solo fuentes comerciales certificadas; sin circuitos de red diseñados por el proyecto | Abierta (criterio fijado) |

## Riesgos principales y plan B

1. **U-03 (táctil a través del KVM) falla:** plan B 1, conectar el USB del táctil a un **conmutador USB** independiente sincronizado por la Pi; plan B 2, **opción C** (escritorio remoto del HP en la Pi).
2. **U-02 (el HP no tiene HDMI ni DP++):** adaptador activo DP→HDMI o VGA→HDMI (modelo y precio pendientes) o la pantalla Waveshare 11.6" (H) con entrada VGA.
3. **U-13 (térmica):** separar el compartimento del HP con su propio flujo de aire. Si no basta, ventilador de 5 V controlado por la Pi.
