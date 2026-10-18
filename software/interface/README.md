# Orbit OS Interface v0

Interfaz web de Orbit Terminal, hecha con React, TypeScript y Vite. Tema negro mate con acentos ámbar. Está pensada para 1920×1080 (MSI PRO MP161 E2U) y también se adapta a 1920×720. Los controles son grandes para que sirva con pantalla táctil, aunque el monitor del prototipo no lo es y por ahora se usa con ratón y la consola de potenciómetros y botones.

```bash
npm ci
npm run dev          # http://localhost:5173 · usa el SIMULADOR del navegador por defecto
npm run build        # dist/ (lo sirve orbitd con --static)
npm test             # vitest
npm run lint         # comprobación de tipos (tsc)
```

## Fuentes de datos

- `?source=sim`: simulador dentro del navegador. **Todo** va marcado como simulado.
- `?source=ws`: backend real (orbitd en `ws://<host>/ws`; se puede cambiar con `?ws=ws://ip:8765/ws` o desde Configuración).
- Por defecto se usa el simulador en `npm run dev` y el backend real cuando la interfaz la sirve orbitd.

El distintivo **MODO SIMULACIÓN** aparece si la fuente es el simulador, si orbitd declara modo `sim` o `mixto`, o si cualquier nodo, telemetría o control llega con `simulated: true` (`src/data/state.ts → isSimulated`). Los valores simulados llevan además la etiqueta **SIM**. Si no hay conexión con orbitd, la interfaz muestra **SIN CONEXIÓN CON ORBITD** y deja los campos vacíos; nunca rellena datos inventados.

## Otros parámetros de URL

- `?s=inicio|sistemas|hardware|controles|herramientas|configuracion`: sección inicial.
- `?animate=0`: congela la animación de los potenciómetros simulados.

## Secciones

| Sección | Contenido |
|---|---|
| Inicio | Reloj, fecha, tarjetas del HP y la Pi, accesos rápidos y estado de conexión |
| Sistemas | Detalle y acciones de cada equipo, y guía para cambiar de entrada en el OSD del MSI |
| Hardware | Estado en vivo e inventario con estado honesto de cada pieza |
| Controles | Diales de los potenciómetros, botones y asignación de funciones (`mapping_set`) |
| Herramientas | Acciones de la lista blanca, volumen, modo de LEDs y registro |
| Configuración | Fuente de datos, URL y token de orbitd, y brillo |
