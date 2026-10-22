# Instalar Orbit OS en la Raspberry Pi

Un paso por línea. La Pi 4 arranca directo a Orbit OS, a pantalla completa, sin enseñar el escritorio de Raspberry. La vista del HP por defecto es la **integrada**: una barra de Orbit OS y, debajo, Moonlight sin bordes. La pantalla completa es la alternativa.

Moonlight es un programa aparte. No se puede meter dentro de la página web: el compositor coloca su ventana encima del marco.

Nada de esto se ha probado en la Pi ni en el HP.

## Grabar y ver Orbit OS

1. Abre Raspberry Pi Imager en el PC.
2. Elige Raspberry Pi OS de 64 bits **con escritorio** (Bookworm o Trixie, el actual, con labwc).
3. En las opciones de Imager pon el usuario, la contraseña y el Wi-Fi, y activa SSH.
4. Graba la microSD.
5. Enciende la Pi con esa tarjeta y espera a que tenga Wi-Fi. El cable al HP puede esperar.
6. Entra por SSH con el usuario que pusiste en Imager.
7. Clona la rama del PR #9, que aún no está fusionada: `git clone -b cursor/bandeja-v2-modular-6d15 https://github.com/Sopa-IA/Control-deck.git`.
8. Entra en la carpeta: `cd Control-deck`.
9. Ejecuta una vez, con internet: `sudo bash scripts/instalar-pi.sh`.
10. Si el script termina bien, reinicia: `sudo reboot`.
11. Al encender, lo primero que se ve es Orbit OS. El arcoíris y los textos de arranque quedan ocultos en la medida de lo posible.

El script se puede repetir. No pone puerta de enlace ni DNS en eth0, para no romper el Wi-Fi.

## Cable interno y emparejar

12. Conecta el Ethernet interno: la Pi queda en `10.0.0.2/24` y el HP en `10.0.0.1`, sin puerta de enlace por ese cable.
13. En el HP instala Sunshine y abre `https://10.0.0.1:47990` desde el navegador de la Pi. El certificado es el de Sunshine: hay que aceptarlo.
14. Comprueba que existe la aplicación `Desktop`. Si no está, créala como el escritorio de Windows.
15. En la Pi, fuera del kiosco, empareja: `moonlight-qt pair 10.0.0.1`.
16. Escribe en Sunshine el PIN de cuatro cifras que muestra Moonlight.
17. Hasta que ese emparejamiento no esté hecho, Cambiar sistema no abre el HP y Orbit OS lo dice en la pantalla.

## Resoluciones, para que no se vea borroso

18. La vista integrada pide un stream de **1920×1040 a 60 fps** (la MSI es 1920×1080 y la barra de Orbit OS mide 40 px).
19. En Windows, pon la pantalla del HP a 1920×1040 y 60 Hz antes de usar esa vista.
20. Si abres la barra lateral (48 px), el hueco pasa a **1872×1040** y Moonlight se vuelve a abrir a ese tamaño.
21. La pantalla completa pide **1920×1080 a 60 fps**. Para verla nítida, Windows tiene que estar a 1920×1080 y 60 Hz.
22. Moonlight pide el tamaño. Si Windows no coincide, la imagen se escala. Para que se vea nítida, las dos cifras tienen que ser las mismas.
23. Si Sunshine trae pantalla virtual, crea ahí esa resolución y selecciónala.
24. Si Windows sin monitor no ofrece 1920×1080, pon un **enchufe HDMI falso** en el HDMI del HP.
25. Muchos enchufes anuncian 1920×1080. Para 1920×1040, crea esa resolución en Windows y déjala elegida.

## Cómo se cambia de vista y cómo se vuelve

26. El botón físico del Nano asignado a Cambiar sistema (B2) abre Moonlight desde Orbit OS.
27. Con Moonlight abierto, el mismo botón lo cierra y devuelve Orbit OS al frente.
28. El botón «Pantalla completa» y **Ctrl+Alt+Mayús+X** cambian entre la vista integrada y la completa. Mayús es la tecla Shift.
29. **Ctrl+Alt+Mayús+Q** cierra Moonlight (atajo del propio programa) y se vuelve a Orbit OS.
30. En la vista integrada el ratón no queda capturado: pasa de la barra de Orbit a Windows. El teclado va a Windows cuando esa ventana tiene el foco.

## Salir del kiosco para mantenimiento

31. **Ctrl+Alt+T** pausa Chromium y abre una terminal.
32. Para volver al kiosco: `rm /var/lib/orbit/kiosk-pausa`.
33. **Ctrl+Alt+Q** cierra la sesión gráfica. Al reiniciar, el autologin vuelve a Orbit OS.
34. SSH sigue activo con el usuario y el Wi-Fi de Imager. No hace falta salir del kiosco para usarlo.
35. El servicio se llama `orbitd`. Pararlo: `sudo systemctl stop orbitd`. Arrancarlo: `sudo systemctl start orbitd`.

## Qué no hace esta instalación

36. No empareja Sunshine: el PIN lo escribe Miguel.
37. No se ha probado el kiosco, labwc, Moonlight ni el enchufe HDMI en el hardware.
38. hp-agent puede conectar a `ws://10.0.0.2:8765/ws` con `ORBIT_HP_TOKEN` (está en `.env` de la Pi, no se sube a git). La interfaz del kiosco no pide token porque entra por localhost.
39. Para programar el Nano de prácticas desde Orbit OS, sigue `docs/ardu-lab.md`. Hay que anotar antes el puerto USB físico. El de mandos no se programa desde ahí.
