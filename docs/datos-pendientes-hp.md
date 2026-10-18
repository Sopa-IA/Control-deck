# Datos pendientes que debe aportar el propietario

> Documento: `docs/datos-pendientes-hp.md` · Versión 2026-10-18
> Sin estos datos no se puede cerrar el diseño mecánico, eléctrico ni el del conmutador. El software y los diseños preliminares avanzan en paralelo con valores marcados como **pendiente**.
> Formato de respuesta sugerido: copiar la tabla, rellenar la columna "Valor" y adjuntar fotos.

## 0. Primero: ¿qué es exactamente el "HP Mini"?

La marca "HP Mini" se ha usado para productos muy distintos. Dos ejemplos documentados, **que se citan solo para ilustrar la variabilidad y no como suposición**:
- **HP Mini 110** (portátil netbook de 10,1"): procesador Intel Atom, salida **VGA**, USB 2.0 y RJ-45 (https://h10032.www1.hp.com/ctg/Manual/c02616279.pdf).
- **HP EliteDesk 800 G3 Desktop Mini** (sobremesa compacto): **2× DisplayPort 1.2** más un puerto opcional (DP, HDMI, VGA, serie o USB-C); fuente externa de 19,5 V y 65 W; 177,04 × 34,29 × 174,75 mm (https://support.hp.com/ee-en/document/c05371240).

Las consecuencias son muy distintas: un netbook trae pantalla y batería propias y solo VGA, mientras que un Desktop Mini puede no tener HDMI nativo. **Esta es la primera pregunta para Miguel.**

## 1. HP: identificación

| # | Dato | Cómo obtenerlo | Por qué importa | Valor |
|---|---|---|---|---|
| 1.1 | **Foto de la etiqueta inferior o trasera** (modelo, número de producto "P/N", número de serie) | Foto nítida | Con el P/N se localizan las QuickSpecs y la guía de servicio oficiales de HP: dimensiones, puertos y fuente exactos | |
| 1.2 | Nombre comercial completo (p. ej. "EliteDesk 800 G2 Mini", "ProDesk 400 G4 Mini", "t620", "Mini 110") | Etiqueta, BIOS o `msinfo32` | Lo mismo que el punto anterior | |
| 1.3 | ¿Es un portátil/netbook o un sobremesa compacto? | Observación | Cambia por completo la arquitectura (pantalla propia, batería) | |
| 1.4 | ¿Funciona actualmente? ¿Arranca? | Prueba | Riesgo del proyecto | |

## 2. HP: rendimiento y almacenamiento

| # | Dato | Cómo obtenerlo | Por qué importa | Valor |
|---|---|---|---|---|
| 2.1 | CPU exacta | Windows: Configuración → Sistema → Información; Linux: `lscpu` | Rendimiento, TDP y calor dentro del chasis | |
| 2.2 | RAM instalada y número de ranuras | `msinfo32` / `sudo dmidecode -t memory` | Capacidad para el uso previsto; posible ampliación | |
| 2.3 | Almacenamiento (tipo SATA/M.2/eMMC y capacidad) | Administrador de discos / `lsblk` | Papel de "almacenamiento principal" | |
| 2.4 | GPU integrada | Administrador de dispositivos / `lspci` | Si admite el modo 1920×720 y qué salidas tiene | |

## 3. HP: puertos (con fotos de todos los lados)

| # | Dato | Por qué importa | Valor |
|---|---|---|---|
| 3.1 | Salidas de vídeo: tipo y número (HDMI, DisplayPort, ¿con logo DP++?, VGA, USB-C con logo DP) | **Determina el KVM y si hace falta un adaptador** DP→HDMI (pasivo si es DP++, activo si no) o VGA→HDMI | |
| 3.2 | USB: número y tipo (2.0/3.x, A/C), delanteros y traseros | Conexión al KVM y otros periféricos | |
| 3.3 | Ethernet RJ-45 (¿Gigabit?) | **Enlace preferente con la Pi** | |
| 3.4 | Wi-Fi/Bluetooth integrados | Alternativa de red | |
| 3.5 | Audio (jack) | Integración de altavoces o jack frontal | |
| 3.6 | Botón de encendido: posición y si se podría prolongar | Botón de encendido del chasis | |

## 4. HP: alimentación

| # | Dato | Cómo obtenerlo | Por qué importa | Valor |
|---|---|---|---|---|
| 4.1 | **Foto de la etiqueta del adaptador de corriente**: tensión de salida (V), corriente (A), potencia (W), marca y modelo, y certificaciones (CE…) | Foto | Dimensionar la alimentación; decidir si se reutiliza el adaptador original (preferente) | |
| 4.2 | Conector de alimentación (diámetro y tipo, p. ej. punta "smart pin" de HP) | Foto o calibre | Algunos HP verifican el adaptador por el pin central | |
| 4.3 | ¿Fuente interna o externa? | Observación | Seguridad eléctrica y diseño del chasis | |
| 4.4 | Consumo real en reposo y en carga (si se tiene un medidor de enchufe) | Medidor | Térmica y elección de fuentes. **Nunca se usará un valor no medido.** | |

## 5. HP: mecánica (medir con calibre)

| # | Dato | Por qué importa | Valor |
|---|---|---|---|
| 5.1 | Ancho × fondo × alto en mm (máximos, incluidos pies y salientes) | Volumen interior del chasis | |
| 5.2 | Posición de puertos, rejillas de entrada y salida de aire y botón (croquis acotado o foto con regla) | Flujo de aire y accesos en la carcasa | |
| 5.3 | ¿Tiene agujeros VESA o roscas de montaje? Distancia y métrica | Fijación interior | |
| 5.4 | Peso (g) | Estabilidad de la cuña | |
| 5.5 | ¿Se aceptaría quitarle la carcasa original? | Ahorra volumen, pero afecta a la seguridad y la garantía | |

## 6. HP: BIOS/UEFI y sistema operativo

| # | Dato | Por qué importa | Valor |
|---|---|---|---|
| 6.1 | Versión de BIOS | Opciones disponibles | |
| 6.2 | ¿Existe "After Power Loss" / "Power On after AC loss" (On/Off/Previous)? | Encendido automático al dar corriente al chasis | |
| 6.3 | ¿Existe **Wake-on-LAN** (S3/S4/S5)? | **Encendido del HP desde la Pi por red** sin tocar la placa | |
| 6.4 | ¿Existe encendido por USB o por teclado? | Alternativa de encendido | |
| 6.5 | Sistema operativo instalado y edición (p. ej. Windows 10 Home/Pro, Ubuntu 24.04) | Agente de Orbit, escritorio remoto (opción C) y táctil multipunto | |
| 6.6 | ¿Se puede reinstalar o cambiar el SO? | Margen de diseño | |
| 6.7 | ¿Cuenta de administrador disponible? | Instalar el agente y el firewall | |

## 7. Raspberry Pi

| # | Dato | Por qué importa | Valor |
|---|---|---|---|
| 7.1 | Modelo exacto (serigrafía de la placa o `cat /proc/device-tree/model`) y RAM | Elección de librerías (LED en Pi 5), consumo y fuente | |
| 7.2 | ¿Tiene fuente oficial? ¿Cuál? | Requisitos oficiales de 5,1 V / 2,5–5 A según el modelo | |
| 7.3 | Tarjeta microSD o SSD disponible y capacidad | Sistema de la Pi | |
| 7.4 | Disipador, ventilador o caja actuales | Térmica | |

## 8. Otros componentes que pueda tener ya

| # | Dato | Por qué importa | Valor |
|---|---|---|---|
| 8.1 | ¿Tiene alguna pantalla táctil? Marca, modelo, diagonal, resolución, conectores y alimentación | **Prioridad: reutilizar antes que comprar** | |
| 8.2 | ¿Tiene un conmutador KVM o HDMI? Modelo | Ídem | |
| 8.3 | ¿Tiene codificadores rotatorios, pulsadores, tiras LED o fuentes de 5 V/12 V? | Ídem | |
| 8.4 | ¿Tiene impresora 3D? Modelo, volumen de impresión y materiales (PLA/PETG/ASA) | **Tamaño máximo de cada pieza** de la carcasa | |
| 8.5 | ¿Tiene acceso a corte láser, CNC o plegado de aluminio? | Materiales del chasis | |
| 8.6 | ¿Tiene herramientas (soldador, polímetro, calibre)? | Qué montajes son realistas en casa | |

## 9. Preferencias de diseño (decisiones del propietario)

| # | Pregunta | Valor |
|---|---|---|
| 9.1 | Pantalla: ¿**barra de 12,3" 1920×720** (más baja que el render) o **11,6" 1920×1080** (proporción del render)? | |
| 9.2 | Presupuesto máximo orientativo para las compras del prototipo | |
| 9.3 | ¿El HP será el sistema visible por defecto al encender? | |
| 9.4 | Uso principal del HP (ofimática, desarrollo, multimedia…) | |
| 9.5 | ¿Se quiere batería en el futuro? (en la Fase 1 queda solo como estudio) | |
