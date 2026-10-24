// Inventario de lo que hay en el equipo. El segundo Nano no consta en la foto. Miguel tiene 4 OLED de 0,96" y Orbit usa una.
export type Estado = 'implementado' | 'simulacion' | 'pendiente' | 'humano' | 'futuro';

export interface Pieza { id: string; nombre: string; detalle: string; estado: Estado; nota: string }

export const ESTADO_LABEL: Record<Estado, string> = {
  implementado: 'En uso',
  simulacion: 'Simulado',
  pendiente: 'Falta conectarlo',
  humano: 'Falta un dato',
  futuro: 'No se usa',
};

export const INVENTARIO: Pieza[] = [
  { id: 'msi', nombre: 'MSI PRO MP161 E2U', detalle: '15,6" · 1920×1080 · 60 Hz · no táctil', estado: 'implementado', nota: 'Va solo a la Pi, del micro-HDMI al mini-HDMI. El HP se ve con Moonlight.' },
  { id: 'hp', nombre: 'HP Slimline 260-a110ns', detalle: 'Windows 10 Home 22H2 · placa en la cuña', estado: 'implementado', nota: 'El agente envía CPU, memoria, disco, red y temperatura, y ejecuta las acciones del equipo.' },
  { id: 'pi', nombre: 'Raspberry Pi 4', detalle: 'Orbit OS · HAT VHF', estado: 'implementado', nota: 'El HAT no está medido. Si tapa los pines, el conector del panel se queda sin cable.' },
  { id: 'arduino', nombre: 'Arduino Nano de mandos', detalle: 'Clon con CH340, por USB', estado: 'implementado', nota: 'Está conectado. Los potenciómetros y los pulsadores, no.' },
  { id: 'nano-pruebas', nombre: 'Nano de prácticas', detalle: 'Independiente del de mandos. OLED en A4 y A5', estado: 'pendiente', nota: 'Falta conectarlo. Hasta entonces, Subir y el monitor están apagados.' },
  { id: 'uno', nombre: 'Arduino Uno', detalle: 'El de la foto', estado: 'futuro', nota: 'No se monta.' },
  { id: 'esp', nombre: 'ESP8266', detalle: 'Hueco de la bandeja, para la tira', estado: 'pendiente', nota: 'Falta identificar la tira y conectarla. Los botones de luz están apagados.' },
  { id: 'oled', nombre: 'OLED 0,96"', detalle: '128×64. Miguel tiene 4; Orbit usa una', estado: 'pendiente', nota: 'Falta conectarla al Nano de prácticas.' },
  { id: 'pots', nombre: 'Potenciómetros', detalle: 'Dos, previstos en A0 y A1', estado: 'pendiente', nota: 'Falta cablearlos. Hasta entonces no cambian el volumen ni nada más.' },
  { id: 'botones', nombre: 'Pulsadores', detalle: 'Dos, previstos en D2 y D3', estado: 'pendiente', nota: 'Falta cablearlos. Hasta entonces no hacen nada.' },
  { id: 'led', nombre: 'Tira de luz ámbar', detalle: 'Tipo y tensión sin identificar', estado: 'pendiente', nota: 'Falta conectarla. Los botones de luz no envían nada.' },
  { id: 'kvm', nombre: 'Conmutador HDMI', detalle: 'Estudiado al principio', estado: 'futuro', nota: 'No se usa. La imagen del HP llega por el cable de red.' },
  { id: 'touch', nombre: 'Marco táctil', detalle: '15,6"', estado: 'futuro', nota: 'No se usa. Se maneja con ratón.' },
];
