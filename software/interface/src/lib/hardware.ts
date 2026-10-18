// Inventario del prototipo (solo piezas que Miguel ya tiene). Estado honesto por pieza.
export type Estado = 'implementado' | 'simulacion' | 'pendiente' | 'humano' | 'futuro';

export interface Pieza { id: string; nombre: string; detalle: string; estado: Estado; nota: string }

export const ESTADO_LABEL: Record<Estado, string> = {
  implementado: 'Implementado', simulacion: 'Simulación', pendiente: 'Pendiente de validar', humano: 'Requiere intervención humana', futuro: 'Opción futura',
};

export const INVENTARIO: Pieza[] = [
  { id: 'msi', nombre: 'MSI PRO MP161 E2U', detalle: '15,6" IPS 1920×1080 60 Hz · Mini-HDMI 2.0b + 2× USB-C · NO táctil', estado: 'pendiente', nota: 'Pantalla compartida: HP en una entrada, Pi en la otra; cambio por OSD.' },
  { id: 'hp', nombre: 'HP (sistema principal)', detalle: 'Modelo y SO desconocidos (≈2017)', estado: 'humano', nota: 'Identificar modelo; instalar hp-agent con su token.' },
  { id: 'pi', nombre: 'Raspberry Pi (Orbit OS)', detalle: 'Modelo desconocido', estado: 'humano', nota: 'Identificar modelo; orbitd + Chromium kiosco.' },
  { id: 'arduino', nombre: 'Arduino Micro (ATmega32U4)', detalle: 'USB CDC serie · HID opcional', estado: 'pendiente', nota: 'Firmware escrito; sin probar en placa real.' },
  { id: 'pots', nombre: 'Potenciómetros', detalle: '2 × lineales 10 kΩ (configurable)', estado: 'pendiente', nota: 'Sustituyen a los encoders; A0 y A1. Huecos del CAD aún genéricos.' },
  { id: 'botones', nombre: 'Botones', detalle: '2 × pulsador a GND (configurable)', estado: 'pendiente', nota: 'D2 y D3 con pull-up interno.' },
  { id: 'led', nombre: 'Tira LED ámbar', detalle: 'Tipo desconocido', estado: 'humano', nota: 'Identificar (¿direccionable? ¿5/12 V?).' },
  { id: 'kvm', nombre: 'KVM HDMI+USB', detalle: 'TESmart HKS201-P23-V2 (estudio fase 1)', estado: 'futuro', nota: 'No se usa en el prototipo.' },
  { id: 'touch', nombre: 'Marco táctil IR 15,6"', detalle: 'p.ej. Obeytouch OB156AP (61 USD)', estado: 'futuro', nota: 'Prototipo con ratón + controles.' },
];
