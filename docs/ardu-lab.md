# Ardu Lab

La sección se llama **Ardu Lab**. Sirve para escribir un programa del Nano de prácticas y subirlo desde Orbit OS, sin el Arduino IDE.

Moonlight no entra aquí. El Nano de mandos, el de los botones, no se programa desde esta pantalla: queda bloqueado.

Nada de esto se ha probado en una placa ni en la Pi.

## Antes de subir

1. Abre Orbit OS en la Pi.
2. En la barra de la izquierda entra en **Ardu Lab**. El nombre se lee así, con esas mayúsculas.
3. Si ves la franja amarilla **SIMULADO**, no estás grabando ninguna placa.
4. Desenchufa los dos Nano.
5. Enchufa solo el Nano de prácticas en el puerto USB de la Pi que va a ser el suyo. No lo cambies de sitio después.
6. Por SSH: `ls -l /dev/serial/by-path`. Si la carpeta no existe, el Nano no está enchufado.
7. Copia el nombre del enlace, el basename. No copies `ttyUSB0` ni `ttyUSB1`: ese número cambia.
8. Edita `/var/lib/orbit/arduino-puertos.json` y pon ese nombre en `practicas`. O, con la placa enchufada, `sudo bash scripts/detectar-nanos.sh` pregunta el número y escribe el archivo.
9. Desenchufa el de prácticas.
10. Enchufa solo el Nano de mandos en el otro puerto USB, el que va a ser el suyo.
11. Vuelve a mirar `ls -l /dev/serial/by-path` y copia ese basename en `mandos`.
12. El archivo queda así, con los nombres reales en vez de los de ejemplo: `{ "mandos": "platform-usb-mandos", "practicas": "platform-usb-practicas" }`.
13. Enchufa las dos placas otra vez, cada una en su puerto.
14. Reinicia el servicio: `sudo systemctl restart orbitd`.
15. El botón físico Cambiar sistema vuelve a llegar, porque orbitd abre el puerto de `mandos`.
16. En Ardu Lab, Puertos dice que el de prácticas está listo y el de mandos está bloqueado.
17. Si los dos nombres apuntan al mismo aparato, Subir se niega. No busques otro `ttyUSB`.

## Escribir, verificar y ver el monitor

18. Elige una pestaña: `Blink`, `AnalogReadSerial` o `monitor_pines`.
19. `monitor_pines` es el ejemplo del repo, el de la OLED y los pines del panel trasero.
20. Escribe en el editor. A los pocos segundos se guarda solo en la Pi.
21. **Nuevo** abre `Sketch2`, `Sketch3`, y así.
22. Pulsa **Verificar**.
23. La salida de `arduino-cli` sale debajo. Si hay un error, queda marcado en esa línea.
24. El clon CH340 usa el bootloader viejo: `arduino:avr:nano:cpu=atmega328old`.
25. Pulsa **Subir**. Solo va al Nano de prácticas.
26. Si el monitor estaba abierto, se cierra para poder subir. El Nano se reinicia.
27. Elige los baudios. `AnalogReadSerial` va a 9600. `monitor_pines` va a 115200. `Blink` no escribe por el serie.
28. Pulsa **Abrir monitor**. Abrir el puerto reinicia el Nano.
29. Las líneas con números (un valor suelto, o `A0 512`) se dibujan en el gráfico.
30. Pulsa **Cerrar monitor** al terminar.
31. El panel de pines es el del panel trasero, visto desde fuera: arriba D2…D13, abajo A0…A7, GND, RST, 5V y 3V3. A4 es SDA y A5 es SCL.

## Sin internet y en el simulador

32. `scripts/instalar-pi.sh` instala `arduino-cli` y el core `arduino:avr` mientras hay internet.
33. Después, Verificar y Subir no necesitan red. `Wire.h` viene en ese core. Estos ejemplos no piden más librerías.
34. En el navegador, sin la Pi, la misma pantalla lleva la franja **SIMULADO**. No llama a `arduino-cli` y no sube.
35. El gráfico de esa franja también es simulado. No sale de una placa.

## Qué no hace

36. No sube al Nano de mandos, ni a un `ttyUSB` elegido a mano.
37. No se ha probado el core, el bootloader viejo, el CH340 ni el monitor en el hardware de Miguel.
