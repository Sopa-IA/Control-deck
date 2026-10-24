// Traduce eventos de control (potenciómetros/botones) a órdenes de la interfaz según la asignación.
// Las funciones hp.* / pi.* las ejecuta orbitd; aquí solo se resuelven las ui.*.
import type { ControlEventPayload, MappingPayload } from '@shared/ts/protocol';
import { potToPct } from './format';

export type UiCommand =
  | { cmd: 'next_section' } | { cmd: 'back' } | { cmd: 'select' } | { cmd: 'power_menu' } | { cmd: 'switch_help' }
  | { cmd: 'brightness'; pct: number } | { cmd: 'scroll'; delta: number } | { cmd: 'led_brightness'; pct: number };

export function functionFor(ev: ControlEventPayload, mapping: MappingPayload | null): string {
  if (!mapping) return 'none';
  return (ev.kind === 'pot' ? mapping.pots[ev.control] : mapping.buttons[ev.control]) ?? 'none';
}

/** prevValue: lectura anterior del mismo potenciómetro (para ui.scroll, que es relativo). */
export function route(ev: ControlEventPayload, mapping: MappingPayload | null, prevValue?: number): UiCommand | null {
  const fn = functionFor(ev, mapping);
  if (ev.kind === 'button') {
    if (ev.event !== 'press') return null;
    switch (fn) {
      case 'ui.next_section': return { cmd: 'next_section' };
      case 'ui.back': return { cmd: 'back' };
      case 'ui.select': return { cmd: 'select' };
      case 'ui.power_menu': return { cmd: 'power_menu' };
      case 'ui.show_switch_help': return { cmd: 'switch_help' };
      default: return null;
    }
  }
  if (ev.value === undefined) return null;
  switch (fn) {
    case 'ui.brightness': return { cmd: 'brightness', pct: Math.max(20, potToPct(ev.value)) };
    case 'ui.led_brightness': return null;
    case 'ui.scroll': {
      if (prevValue === undefined) return null;
      const step = 96; // ~10 posiciones en todo el recorrido
      const delta = Math.trunc(ev.value / step) - Math.trunc(prevValue / step);
      return delta === 0 ? null : { cmd: 'scroll', delta };
    }
    default: return null;
  }
}
