# Créditos y licencias de los modelos 3D del render

Renders de `assets/renders/prototipo/` (Blender 4.2.3 LTS + Cycles, binario oficial de blender.org;
el paquete de Debian no trae OpenImageDenoise). Comprobado el 2026-10-18.

| Pieza | Origen | Licencia | ¿En el repo? | Exactitud |
|---|---|---|---|---|
| Carcasa, base, bisel, bandeja, soportes, guía de luz, pomos, anillos | CAD propio (`hardware/cad`, exportado con `partes_render.scad`) | La del repo (Apache-2.0) | Sí (fuente .scad) | Exacta respecto al CAD v3 (es la misma geometría) |
| Monitor MSI PRO MP161 E2U | Modelado a partir de las cotas publicadas por MSI (362,26 × 233,84 × 18,8 mm, área activa 344,16 × 193,59 mm) — https://www.msi.com/Portable-Monitor/PRO-MP161-E2U/Specification | Modelo propio | Sí (en el CAD) | Envolvente exacta; posición del área activa supuesta centrada; sin detalle de botones/puertos |
| Raspberry Pi 4 Model B | Innerscene 3D Parts Library, «Raspberry Pi 4 Model B layout» (reconstrucción a partir del plano mecánico oficial) — https://www.innerscene.com/tools/library/3d-parts/raspberry-pi-4-model-b-layout-821bd96d | CC0 1.0 (dominio público), según la ficha | **No** (se descarga con `descargar_modelos.sh`; SHA-256 7d36accf13f76f7c056214cc64c6a2bbdd35a56c83b0cd0aa9c83f81c1186450) | Contorno, agujeros y ejes de los puertos según el plano oficial; profundidades y componentes pequeños nominales |
| Placa HP 260-a110ns (mini-ITX) | Modelo propio en `escena_blender.py` | Apache-2.0 (repo) | Sí (script) | 170 × 170 mm y 35 mm de alto [MEDIDO]; disposición (DIMM junto al borde delantero, disipador en el centro, orden del I/O) según las fotos de Miguel [FOTO]; posiciones exactas y SMD **aproximados/ilustrativos** |
| HDD 3,5" | Modelo propio con las cotas de SFF-8301 (101,6 × 147 × 26,1 mm) | Apache-2.0 (repo) | Sí (script) | Envolvente exacta al estándar; detalles (agujeros, conectores) aproximados; etiqueta genérica sin marca |
| Arduino Micro | Modelo propio con las medidas oficiales (48 × 17,7 mm, 2 × 17 pines a 2,54 mm, filas a 15,24 mm) — https://store.arduino.cc/products/arduino-micro. **2026-10-20:** el CAD vigente es un Nano; este modelo y los renders no se han rehecho | Apache-2.0 (repo) | Sí (script) | PCB y pines según medidas oficiales; componentes aproximados |
| Potenciómetros (24 mm, eje 6 mm) y pulsadores de 16 mm | Marcadores genéricos del CAD (`datos_pot`, `datos_boton` en params.scad) | Apache-2.0 (repo) | Sí | Genéricos de catálogo: el modelo concreto de Miguel está [PENDIENTE] |
| Interfaz en pantalla | `assets/screenshots/inicio_1920x1080.png` (captura real de Orbit OS en modo simulación) | Apache-2.0 (repo) | Sí | Exacta |

## Modelos buscados y descartados
- **Raspberry Pi Ltd** no publica un STEP de la Pi 4 (solo el plano mecánico en PDF:
  https://pip.raspberrypi.com/categories/545-raspberry-pi-4-model-b). Se usa la reconstrucción CC0.
- **Arduino Micro**: la web oficial ofrece esquemas, Eagle, Fritzing y plano de tamaño, pero no STEP. Los STEP
  de terceros (Printables, GrabCAD) necesitan cuenta o no aclaran la licencia, así que no se usan.
- **Potenciómetro/pulsador**: los modelos de KiCad (CC BY-SA 4.0 con excepción) son de otros formatos
  (trimmers, 9 mm), no del de 24 mm del diseño. Se mantiene el marcador genérico.
- **HDD 3,5"**: se modeló directamente a SFF-8301, sin licencias de terceros.

Las fotos de Miguel solo se usan como referencia de la disposición. No se suben al repo, que es público.
