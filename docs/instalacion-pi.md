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

El script se puede repetir. La segunda vez no cambia los tokens de `.env`. No pone puerta de enlace ni DNS en eth0, para no romper el Wi-Fi. El usuario es el de Imager, el que ha lanzado `sudo`: no tiene que llamarse `pi`. `LXDE-pi` es el nombre de la sesión gráfica de Raspberry Pi OS, no un usuario.

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

## Apagar y reiniciar desde Orbit OS

36. En Sistemas, o en el menú de apagado, Apagar Pi y Reiniciar Pi piden confirmación en pantalla.
37. Al confirmar, la Pi se apaga o se reinicia en el acto. No hay 60 segundos para cancelar. Eso de los 60 segundos es solo del HP.
38. El script deja en `/etc/sudoers.d/orbit-power` dos órdenes y nada más: `systemctl poweroff` y `systemctl reboot`, sin contraseña, para el usuario de orbitd.
39. En el simulador del PC esas acciones no apagan la máquina.
40. Si asignas Apagar la Pi o Reiniciar la Pi a un botón del Nano, un toque corto no hace nada. Hay que mantenerlo pulsado: entonces sale el mismo diálogo. Sin la pantalla de Orbit OS abierta, no se apaga.

## Qué no hace esta instalación

41. No empareja Sunshine: el PIN lo escribe Miguel.
42. El kiosco con GPU, una sesión labwc de verdad y Moonlight contra el HP no se han probado en la Pi. El script sí se ha ejecutado dos veces, sin errores, en un Debian Bookworm arm64 con qemu-user. No es la imagen de Raspberry Pi OS: en esa imagen labwc ya viene, y en Debian Bookworm el script solo deja escrito que el paquete no está. La segunda pasada no cambió los tokens de `.env`. qemu-user no honra el setuid de `sudo`, así que la prueba se lanzó como root con el usuario de Imager en `SUDO_USER`. No se ha llamado a `systemctl poweroff` ni a `reboot`.
43. hp-agent puede conectar a `ws://10.0.0.2:8765/ws` con `ORBIT_HP_TOKEN` (está en `.env` de la Pi, no se sube a git). La interfaz del kiosco no pide token porque entra por localhost.
44. Para programar el Nano de prácticas desde Orbit OS, sigue `docs/ardu-lab.md`. Hay que anotar antes el puerto USB físico. El de mandos no se programa desde ahí.

## Primera vez que encienda la Pi

1. SSH entra con el usuario de Imager.
2. `systemctl status orbitd` está activo y la pantalla muestra Orbit OS.
3. El Wi-Fi sigue teniendo internet.
4. `ip route` no muestra una puerta por eth0. eth0 es `10.0.0.2/24`.
5. `grep dialout /etc/group` incluye al usuario de Imager.
6. Apagar desde Orbit OS pide confirmación y, tras ella, la Pi se apaga.
7. Un toque corto del botón de apagar no apaga. Mantenerlo abre la confirmación.
8. Moonlight aún hay que emparejarlo una vez.
9. Ctrl+Alt+T sale del kiosco. `rm /var/lib/orbit/kiosk-pausa` vuelve.
10. En el PC, el simulador no apaga ese PC.
