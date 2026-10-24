# Cambios

## 1.0.0 — 2026-10-24

Orbit OS deja de presentarse como prototipo. La versión de la interfaz, de orbitd, de hp-agent y de orbit-protocol pasa a 1.0.0. El protocolo sigue siendo el v1: no se renombran acciones ni claves.

- Cada botón de la interfaz hace algo en la Pi o en el HP, o queda deshabilitado con un texto si falta hardware.
- Reproducir o pausar en el HP pulsa la tecla de medios de Windows. En seco no la pulsa.
- La tira LED no está identificada: sus botones quedan apagados y no se envía nada a una placa.
- Los potenciómetros y los pulsadores físicos no están cableados: la asignación queda deshabilitada y no mandan acciones.
- Recargar la interfaz vuelve a cargar Orbit OS en la Pi.
- Apagar y reiniciar siguen pidiendo confirmación. El registro agrupa la misma línea y no enseña órdenes internas.
- La red del HP sigue en kb/s, igual que la de la Pi. La temperatura de la CPU sigue saliendo de LibreHardwareMonitor 0.9.6.
