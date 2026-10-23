# Datos del HP y datos pendientes

> Documento: `docs/datos-pendientes-hp.md` · Versión 2026-10-18 (HP v3: primeras medidas reales tras abrir el HP)
> **El HP está identificado: HP Slimline 260-a110ns** (torre estrecha, no un Desktop Mini). Por decisión de Miguel **se desmonta de su caja**: en Orbit van su placa base, el disipador/ventilador, la RAM, el disco y el I/O frontal. El adaptador de corriente es **externo** y queda fuera.
> Fuentes: **"datos del propietario 2026-10-18"** (lo que Miguel ha comprobado en su equipo) y documentación **oficial de HP de modelos hermanos** de la serie 260-a1xx, consultada el 2026-10-18. **No se ha encontrado la ficha oficial específica del 260-a110ns** en support.hp.com (varias fichas de la serie dan hoy 404). Lo no verificable figura como **PENDIENTE de medir tras desmontar**.

## A. HP Slimline 260-a110ns: ficha consolidada

| Dato | Valor | Fuente | Contraste |
|---|---|---|---|
| Procesador | AMD A6-7310 (4 núcleos / 4 hilos, 2,0–2,4 GHz), gráfica Radeon R4 integrada | Datos del propietario 2026-10-18 | Coincide con tiendas (P/N Y4K46EA)¹. TDP 15 W (cTDP 12 W) según fichas HP de los 260-a010z / 260-a020 (c05150901, c05112353; vistas por buscador, hoy 404) |
| Placa base | HP **"Iris-A6"** (identificador provisional) | Datos del propietario 2026-10-18 | HP publica las placas hermanas **Iris-E2** (SSID 81B3) e **Iris-A8** de la misma serie: **Mini ITX 17,0 × 17,0 cm**² ³. HP Community: la placa Iris (SSID 81B3, p/n 844844-606) **no tiene ranura PCIe gráfica**⁴. Nombre exacto: PENDIENTE (serigrafía) |
| Formato y anclajes | Mini-ITX 170 × 170 mm, **medido por Miguel (17 × 17 cm)**. Agujeros: **patrón estándar mini-ITX; coincide visualmente con los 4 tornillos de la foto, no medido** (ver §A2) | HP (hermanas)²; medida del propietario 2026-10-18; estándar mini-ITX⁹ | Cotas exactas de los agujeros: no medidas (Miguel indicó tomarlas de la especificación) |
| RAM | 8 GB DDR3L-1600; 2 ranuras DIMM; máximo 16 GB | Datos del propietario 2026-10-18 | Iris-E2: 2 ranuras DDR3L UDIMM de 240 contactos, canal simple, máx. 16 GB²; tiendas: 1 × 8 GB¹ |
| Almacenamiento | HDD SATA de 1 TB (posible cambio a SSD SATA) | Datos del propietario 2026-10-18 | Tiendas: 1 TB 7200 rpm¹. Listas de piezas HP: HDD de 1 TB de clase 3,5" (Seagate/WD/Toshiba)⁵ → formato 3,5": **PENDIENTE de confirmar al desmontar**. Iris-E2 tiene además 1 M.2 key A (para Wi-Fi, no para disco)² |
| Óptico | Grabadora DVD (slim, bandeja 9,5 mm según piezas HP⁵) | Datos del propietario 2026-10-18 | **Se retira** |
| Red | Gigabit Ethernet; Wi-Fi Realtek RTL8723BE 802.11n + Bluetooth 4.0 | Datos del propietario 2026-10-18 | Iris-E2: LAN Realtek RTL8161² |
| Vídeo | **1 × HDMI + 1 × VGA** (sin DisplayPort ni USB-C) | Datos del propietario 2026-10-18 | I/O trasero oficial de Iris-E2 / Geneva-C: VGA + HDMI² ⁶ |
| USB | 2 × USB 3.0 + 4 × USB 2.0 | Datos del propietario 2026-10-18 | I/O trasero oficial de Iris-E2: 2 × USB 3.0 + 2 × USB 2.0² → **en el frontal quedarían 2 × USB 2.0** (deducción; PENDIENTE) |
| Audio / otros | Entrada y salida de audio analógico; lector de tarjetas SD | Datos del propietario 2026-10-18 | I/O trasero Iris-E2: line-in, line-out, micro². Lector SD y jacks frontales en la placa de I/O frontal: PENDIENTE |
| Alimentación | **Adaptador EXTERNO 65 W, 19,5 V 3,33 A** | Datos del propietario 2026-10-18 | HP 260-a111na (Iris-E2) y 260-a129 (Iris-A8): adaptador externo 65 W, 100–240 V, 19,5 V 3,3 A³ ⁷. **La entrada DC está en el I/O trasero de la placa**². Piezas HP: adaptador 65 W "Barbera" (849650-00x)⁵. Diámetro del conector / pin central: PENDIENTE |
| Sistema operativo | Windows 10 Home 64 bits | Datos del propietario 2026-10-18 | Tiendas¹. **Home no incluye servidor RDP** (afecta al modo remoto, ver `conmutacion-video-usb.md`) |
| Caja original (ya no se usa) | Torre estrecha, ~4,4 kg | Tiendas: 307 × 100 × 275 mm, 4,4 kg¹; HP 260-a103nc (misma serie, placa Geneva-C): 4,40 kg⁶ | Las medidas de la caja dejan de importar al desmontarla |
| Jumpers | Borrado de CMOS y de contraseña en la placa | HP Iris-E2: CMOS patillas 1-3 (mover a 2-3); contraseña 1-6 (quitar 5-6)² | PENDIENTE en Iris-A6 |

### PENDIENTE de medir tras desmontar (lista de trabajo)

| # | Dato | Cómo | Para qué |
|---|---|---|---|
| H-1 | Serigrafía de la placa (nombre, p/n, SSID) | Foto | Confirmar "Iris-A6" |
| H-2 | Posición de los 4 agujeros y diámetro | Calibre, foto con regla | Separadores del CAD (`mitx_agujeros`, `mitx_ag_f`, `mitx_ag_borde`). **v3: patrón estándar mini-ITX; coincide visualmente con la foto, no medido** |
| H-3 | ~~Altura máxima de componentes sobre la PCB~~ | — | **Medido: 35 mm** (Miguel, 2026-10-18). `hp_comp_h = 35`; el CAD admite hasta 41 mm con 3 mm de holgura |
| H-4 | Pila de conectores traseros. **Escudo: no hay.** La foto del 2026-10-23, escalada al ancho impreso de 159,75 mm, pone el VGA a la izquierda y el jack DC a la derecha (±2 mm). La placa ya usa esa tabla. Sigue abierto el calibre: la prueba tiene que caer en el VGA azul antes de pegar | Calibre, si la prueba no cuadra | Confirmar o corregir `io_huecos` |
| H-5 | Disipador: tamaño del ventilador y sentido del aire (foto: ventilador de 3 hilos sobre el disipador) | Observación | Rejillas de entrada y salida |
| H-6 | **Cabezal del botón de encendido**: conector, patillas del pulsador y del LED | Polímetro (continuidad al pulsar el botón original) | Pulsador de Orbit en paralelo |
| H-7 | Placa de I/O frontal. La cara metálica, en la foto, mide unos 96 × 18 mm: dos jacks, dos USB y el lector. La ventana impresa se queda en 62 × 18. El marco entra a presión y deja una boca de 59,8 × 15,8 mm. Falta ver si el lector asoma entero; si no, se pierde y no se lima la carcasa | Probar el marco impreso contra la chapa | `PROVISIONAL_marco_io_frontal`. El STL futuro de 94 × 18 no se imprime ahora |
| H-8 | Formato real del HDD (3,5" o 2,5") y cables SATA (datos y alimentación: ¿conector propietario en placa?) | Observación | Soporte del disco; cables para el SSD |
| H-9 | Antenas Wi-Fi (tarjeta M.2 vista en la foto): longitud de los cables, o decidir Wi-Fi USB | Observación | Colocarlas lejos de metal (ver §A2) |
| H-10 | Conector DC: diámetro y si es "smart pin" | Calibre | Verificar que el adaptador original entra por la ventana trasera |
| H-11 | BIOS: Wake-on-LAN (S3/S4/S5) y "After Power Loss" | Menú de la BIOS (F10) | Encendido del HP desde la Pi / al dar corriente |
| H-12 | Consumo real (reposo y carga) | Medidor de enchufe en el adaptador | Térmica; nunca se usará un valor no medido |

### Fuentes (consultadas el 2026-10-18)
1. Tiendas (no oficiales): procomponentes.com y dominiovirtual.es, ficha HP 260-a110ns (Y4K46EA). Una de ellas cita una "ranura PCIe x16", probablemente errónea (ver 4).
2. HP, especificaciones de la placa **Iris-E2**: https://support.hp.com/gb-en/document/c05102388 (leído a través del buscador).
3. HP, especificaciones del **HP Slimline 260-a111na** (Iris-E2): https://support.hp.com/gb-en/document/c05341421
4. HP Community, placa Iris SSID 81B3 p/n 844844-606 sin ranura PCIe gráfica (foro de soporte de HP).
5. Listas de piezas HP (EMPR) de la serie 260-a1xx: adaptador 65 W 19,5 V, DVD slim de 9,5 mm, HDD de 1 TB.
6. HP, especificaciones del **HP Slimline 260-a103nc** (placa Geneva-C, Mini ITX 17 × 17 cm): https://support.hp.com/ro-en/document/c05245687 ; placa Geneva-C (I/O trasero con entrada DC, VGA, HDMI, 2 × USB 3.0, LAN, 2 × USB 2.0, audio): documento HP c05137943.
7. HP, especificaciones del **HP Slimline 260-a129** (Iris-A8, A8-7410): documento HP c05296965.
8. Página de descargas de BIOS del 260-a110ns: SSID 81B4 / 81B3 / 821D.
9. Patrón de agujeros mini-ITX (C, F, H, J): Intel, *Mini-ITX Addendum to the microATX Motherboard Interface Specification* (tabla 3, agujeros C, F, H, J); cotas 6,35 / 157,48 / 10,16 / 22,86 / 154,94 mm contrastadas con el plano de una placa mini-ITX comercial (ES France, FLEX-WIZARD-IMX8M-MINI: agujeros a 6,35 / 163,83 mm del lateral y 10,16 / 33,02 / 165,1 mm del borde) y el patrón ATX publicado (22,86 mm = 0,9"). Consultado el 2026-10-18.

## A2. Medidas y observaciones reales (2026-10-18, HP abierto)

**Medidas** (tomadas por Miguel, 2026-10-18; instrumento no indicado):

| Dato | Valor | En el CAD |
|---|---|---|
| Tamaño de la placa | **17 × 17 cm** (mini-ITX) | `mitx = 170` `[MEDIDO]` |
| Altura máxima sobre la placa | **35 mm** (lo más alto es el disipador con su ventilador) | `hp_comp_h = 35` `[MEDIDO]`. Límite del modelo: 41 mm con 3 mm de holgura a la tina de la pantalla; con 35 mm quedan **≈ 9 mm** (comprobación por muestreo: 41 mm → 3 mm, 44 mm → 0 mm, 45 mm → interfiere) |

**Agujeros de anclaje** (Miguel: "sácalos de las specs"): **patrón estándar mini-ITX; coincide visualmente con los 4 tornillos de la foto, no medido.** Cotas del estándar⁹, desde el agujero C (a 6,35 mm del lateral y 10,16 mm del borde trasero/I/O): F = +157,48 mm a lo largo del borde I/O y **+22,86 mm hacia dentro**; H = +154,94 mm hacia delante; J = +157,48 / +154,94 mm. Es decir, F queda a 33,02 mm del borde trasero, no a 10,16 mm: **el CAD v2 lo tenía mal (F alineado con C) y v3 lo corrige** (cambia solo el separador de la base `base_x0_y1`). En la foto, el tornillo trasero más próximo al borde está en el extremo del audio y el más retrasado en el extremo del jack DC, como en el estándar.

**Observaciones de la foto** (no son medidas):

- **I/O trasero sin escudo separado:** los conectores asoman por la chapa de la propia caja HP. Orden a lo largo del borde: jack DC, VGA, HDMI, 2 × USB, RJ45 + USB, audio. En Orbit (vista superior, I/O hacia la pared trasera) el audio queda a la izquierda y el jack DC a la derecha, así que el **HDMI queda en el lado de la Pi**.
- **2 zócalos DDR3L** paralelos al borde opuesto al I/O.
- **Tarjeta Wi-Fi M.2** con sus cables de antena.
- **Ventilador de CPU de 3 hilos**, cables SATA (datos y alimentación) y cables del panel frontal.
- El HP ya está abierto; la Pi ya da imagen en la MSI (tipo de conexión y modelo de Pi: **PENDIENTES**).

### Antenas Wi-Fi: dos opciones

1. **Conservar la tarjeta M.2 y sus antenas.** Las antenas originales van pegadas a la caja HP; al sacarla, hay que despegarlas sin tirar de los cables (soltar antes el conector de la tarjeta, que es un micro-coaxial frágil) y pegarlas por dentro de la carcasa de PLA+ negro mate, **lejos de chapas metálicas, del disipador y del cable HDMI**. El sitio natural es la pared trasera alta o el lomo superior, encima de la placa. La longitud de los cables decide el sitio: **PENDIENTE de medir (H-9)**. El PLA+ no bloquea la señal como la chapa.
2. **Quitar la tarjeta y usar un adaptador Wi-Fi USB** (la opción que Miguel ya contemplaba en su lista de mejoras). Se enchufa en un USB trasero o frontal y evita mover las antenas. Ocupa un USB.

Si el HP va solo por cable (Ethernet a la Pi) y no necesita Wi-Fi, se puede quitar la tarjeta sin más.

### I/O trasero sin escudo: consecuencias en la carcasa

- La ventana trasera de Orbit es una **abertura libre** del tamaño estándar (158,75 × 44,45 mm + 1 mm de holgura); **no asume ningún escudo I/O**. `carcasa_x0_y1` ya está impresa: la abertura no se modifica.
- La placa que cierra el hueco es `PROVISIONAL_placa_io_hp` (171,75 × 55,95 × 2,80 mm, 15,71 cm³ con los huecos del 2026-10-23). Entra **por dentro**. El reborde (6 mm arriba y a los lados, 4,5 mm abajo) apoya en la cara interior de la pared; abajo solo hay 5,2 mm hasta el suelo. Un tetón de 1,4 mm, 0,4 mm más pequeño que la ventana por lado, la centra. Chapa de 1,4 mm. No lleva tornillo. Se imprime con el reborde sobre la cama, sin soportes.
- Los huecos están en `io_huecos`: nombre, x desde el borde izquierdo de la ventana mirando la trasera, z desde el borde inferior, ancho y alto. Foto del **2026-10-23**, escala = ancho impreso 159,75 mm (la regla no se usa). Orden: VGA, HDMI, USB 3, RJ45 sobre USB 2, audio, DC arriba a la derecha, pines abajo a la derecha. ±2 mm. Una lectura anterior ponía el DC a la izquierda; esta foto no.
- `PRUEBA_placa_io_hp` (159,75 × 45,45 × 1,40 mm, 3,52 cm³) se apoya por fuera antes de pegar la placa. El hueco grande de la izquierda tiene que caer en el VGA azul. Si no, no se monta.
- Sin chapa, las carcasas de los conectores ya no tocan la masa de la caja metálica: en una carcasa de PLA+ eso no rompe nada, pero **no hay apantallamiento** (ver §B). La placa impresa tampoco es conductora.

**Qué medir (H-4).** Las dos referencias son la ventana ya impresa, mirando la trasera desde fuera: el **borde interior izquierdo** y el **borde interior inferior**. Para cada conector, cuatro cotas al canto de la carcasa metálica que tiene que atravesar la placa (no al hueco de la clavija): borde izquierdo → canto izquierdo, borde izquierdo → canto derecho, borde inferior → canto inferior, borde inferior → canto superior.

1. Jack DC de 19,5 V, y el diámetro del barril. En la foto del 2026-10-23 el agujero redondo está arriba a la derecha, junto a los pines, no a la izquierda.
2. VGA, la carcasa, a la izquierda de la ventana.
3. HDMI, el conector. Aparte: si la pestaña metálica de encima sale por la ventana o se queda detrás (ahora la placa la tapa).
4. Los dos USB 3 azules, como una sola carcasa apilada.
5. RJ45 encima de los dos USB 2, como una sola carcasa.
6. La chapita de los tres jacks de audio y, si se puede, el centro de cada jack.
7. Los pines de cabecera: hasta dónde llegan a la derecha y hacia arriba, y si deben quedar al aire.

Confirmar que por encima de los conectores solo se ve el disipador. El hueco más alto de la tabla (el DC, z = 42) deja unos 3 mm hasta el borde de la ventana (45,45 mm).
- El borde de la placa queda a 3 mm de la pared (3 mm de espesor): las clavijas deben entrar unos 5–6 mm por la ventana. Comprobar con las clavijas reales (HDMI, RJ45, jack DC).



- **Garantía:** el equipo es de ~2016; lo probable es que la garantía haya caducado (**PENDIENTE de confirmar**, p. ej. con el número de serie en HP). Desmontarlo puede anularla si aún estuviera vigente.
- **Desenchufar** el adaptador de la red **y** de la placa antes de tocar nada; pulsar el botón de encendido unos segundos con todo desconectado para descargar.
- **ESD:** pulsera antiestática conectada a tierra (o tocar una superficie metálica conectada a tierra con frecuencia); manipular la placa por los bordes y dejarla sobre su bolsa antiestática.
- **Fuente:** es un **adaptador externo certificado** y sigue siéndolo: no se abre, no se modifica, no entra en la carcasa. **Dentro de Orbit no hay red eléctrica** (solo 19,5 V DC y 5 V USB). El proyecto nunca diseña circuitos de red.
- **Masa de las piezas metálicas:** la placa HP no lleva escudo I/O propio (foto 2026-10-18); si se añade una placa I/O metálica, y cualquier chapa o soporte metálico deben quedar unidos a la masa de la placa (a través de los separadores/tornillos o con un cable de masa al agujero de anclaje con pad metalizado). La carcasa de PLA+ negro mate no es conductora: **no** se da por hecho ningún apantallamiento.
- **Pila CMOS:** se conserva en la placa; no cortocircuitarla.
- **Disco duro:** manipular sin golpes, apagado; mejor clonar a un SSD antes de manipularlo (copia de seguridad previa).
- **Térmica:** el PLA+ negro mate se reblandece a la temperatura de transición vítrea del filamento (**PENDIENTE de la ficha del filamento real**). Conservar el disipador y ventilador originales, no tapar las rejillas y medir temperaturas en un prototipo abierto antes de cerrarlo.
- **Cables de antena** Wi-Fi: no tirar de ellos; soltarlos del conector de la tarjeta con cuidado.

## C. Cuestionario original (fase 1) — histórico

> Las secciones siguientes son el cuestionario original. Las preguntas de identificación, CPU, RAM, puertos, fuente y SO **quedan respondidas** en §A; siguen abiertas las marcadas allí como PENDIENTE.

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
