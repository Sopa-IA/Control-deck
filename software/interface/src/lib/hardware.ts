// Inventario del prototipo. Estado honesto por pieza: el segundo Nano y la OLED no constan como piezas que Miguel ya tenga.
export type Estado = 'implementado' | 'simulacion' | 'pendiente' | 'humano' | 'futuro';

export interface Pieza { id: string; nombre: string; detalle: string; estado: Estado; nota: string }

export const ESTADO_LABEL: Record<Estado, string> = {
  implementado: 'Implementado', simulacion: 'Simulación', pendiente: 'Pendiente de validar', humano: 'Requiere intervención humana', futuro: 'Opción futura',
};

export const INVENTARIO: Pieza[] = [
  { id: 'msi', nombre: 'MSI PRO MP161 E2U', detalle: '15,6" IPS 1920×1080 60 Hz · Mini-HDMI 2.0b + 2× USB-C · NO táctil', estado: 'pendiente', nota: 'Pantalla compartida: HP en una entrada, Pi en la otra; cambio por OSD.' },
  { id: 'hp', nombre: 'HP (sistema principal)', detalle: 'Modelo y SO desconocidos (≈2017)', estado: 'humano', nota: 'Identificar modelo; instalar hp-agent con su token.' },
  { id: 'pi', nombre: 'Raspberry Pi 4 + HAT VHF', detalle: 'Pi 4 confirmada el 2026-10-20. HAT con OLED y antena SMA; medidas del HAT sin tomar', estado: 'humano', nota: 'orbitd + Chromium kiosco siguen sin instalar. El HAT puede tapar el GPIO: paso de pines [pendiente].' },
  { id: 'arduino', nombre: 'Arduino Nano (mandos)', detalle: 'ATmega328P, clon, mini-USB, CH340 probable. /dev/ttyUSB0. Sin HID', estado: 'pendiente', nota: 'Firmware compilado para arduino:avr:nano. No probado en la placa. Se reinicia al abrir el puerto.' },
  { id: 'nano-pruebas', nombre: 'Segundo Nano (prácticas)', detalle: 'Independiente del de mandos. OLED I2C en A4/A5', estado: 'humano', nota: 'El Uno de la foto no cabe bien en la bandeja. Que haya ya otro Nano no consta: pendiente de confirmar.' },
  { id: 'uno', nombre: 'Arduino Uno', detalle: 'El de la foto. No se monta', estado: 'futuro', nota: '68,6 × 53,4 mm de catálogo no dejan sitio al ESP, a la capturadora y al cable USB.' },
  { id: 'esp', nombre: 'ESP8266 NodeMCU', detalle: 'Módulo ESP-12, micro-USB. Delante a la izquierda de la bandeja', estado: 'humano', nota: 'Previsto para WLED. La tira sigue sin identificar. Medidas de esta placa pendientes.' },
  { id: 'oled', nombre: 'OLED 0,96" SSD1306', detalle: '128×64 I2C. No está entre las piezas de la foto', estado: 'futuro', nota: 'Referencia de envolvente: Waveshare 0.96inch OLED (B), 33,0 × 33,5 mm. Medir el módulo real.' },
  { id: 'pots', nombre: 'Potenciómetros', detalle: '2 × lineales 10 kΩ (configurable)', estado: 'pendiente', nota: 'Sustituyen a los encoders; A0 y A1. Huecos del CAD aún genéricos.' },
  { id: 'botones', nombre: 'Botones', detalle: '2 × pulsador a GND (configurable)', estado: 'pendiente', nota: 'D2 y D3 con pull-up interno.' },
  { id: 'led', nombre: 'Tira LED ámbar', detalle: 'Tipo desconocido', estado: 'humano', nota: 'Identificar (¿direccionable? ¿5/12 V?).' },
  { id: 'kvm', nombre: 'KVM HDMI+USB', detalle: 'TESmart HKS201-P23-V2 (estudio fase 1)', estado: 'futuro', nota: 'No se usa en el prototipo.' },
  { id: 'touch', nombre: 'Marco táctil IR 15,6"', detalle: 'p.ej. Obeytouch OB156AP (61 USD)', estado: 'futuro', nota: 'Prototipo con ratón + controles.' },
];
