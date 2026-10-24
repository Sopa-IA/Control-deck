import { describe, expect, it } from 'vitest';
import { functionFor, route } from './controlRouter';

const mapping = { pots: { P1: 'hp.volume_set', P2: 'ui.scroll', P3: 'ui.brightness' }, buttons: { B1: 'ui.power_menu', B2: 'ui.show_switch_help', B3: 'ui.select', B4: 'ui.next_section' } };

describe('controlRouter', () => {
  it('botones solo actúan al pulsar', () => {
    expect(route({ control: 'B1', kind: 'button', event: 'press', simulated: false }, mapping)).toEqual({ cmd: 'power_menu' });
    expect(route({ control: 'B1', kind: 'button', event: 'release', simulated: false }, mapping)).toBeNull();
    expect(route({ control: 'B2', kind: 'button', event: 'press', simulated: false }, mapping)).toEqual({ cmd: 'switch_help' });
    expect(route({ control: 'B4', kind: 'button', event: 'press', simulated: false }, mapping)).toEqual({ cmd: 'next_section' });
    expect(route({ control: 'B9', kind: 'button', event: 'press', simulated: false }, mapping)).toBeNull();
  });
  it('funciones hp.* no se resuelven en la interfaz', () => {
    expect(functionFor({ control: 'P1', kind: 'pot', value: 3, simulated: false }, mapping)).toBe('hp.volume_set');
    expect(route({ control: 'P1', kind: 'pot', value: 3, simulated: false }, mapping)).toBeNull();
  });
  it('brillo con mínimo del 20 %', () => {
    expect(route({ control: 'P3', kind: 'pot', value: 1023, simulated: false }, mapping)).toEqual({ cmd: 'brightness', pct: 100 });
    expect(route({ control: 'P3', kind: 'pot', value: 0, simulated: false }, mapping)).toEqual({ cmd: 'brightness', pct: 20 });
  });
  it('scroll relativo por escalones', () => {
    expect(route({ control: 'P2', kind: 'pot', value: 500, simulated: false }, mapping)).toBeNull();
    expect(route({ control: 'P2', kind: 'pot', value: 300, simulated: false }, mapping, 290)).toBeNull();
    expect(route({ control: 'P2', kind: 'pot', value: 400, simulated: false }, mapping, 200)).toEqual({ cmd: 'scroll', delta: 2 });
    expect(route({ control: 'P2', kind: 'pot', value: 10, simulated: false }, mapping, 200)).toEqual({ cmd: 'scroll', delta: -2 });
  });
  it('apagar la Pi no se dispara con un toque en la interfaz', () => {
    const apagar = { pots: {}, buttons: { B1: 'pi.shutdown', B2: 'pi.restart' } };
    expect(route({ control: 'B1', kind: 'button', event: 'press', simulated: false }, apagar)).toBeNull();
    expect(route({ control: 'B1', kind: 'button', event: 'long', simulated: false }, apagar)).toBeNull();
    expect(route({ control: 'B2', kind: 'button', event: 'press', simulated: false }, apagar)).toBeNull();
  });
  it('sin asignación no hace nada', () => {
    expect(route({ control: 'P1', kind: 'pot', value: 3, simulated: false }, null)).toBeNull();
  });
  it('el brillo de la tira no hace nada mientras no está conectada', () => {
    const leds = { pots: { P1: 'ui.led_brightness' }, buttons: {} };
    expect(route({ control: 'P1', kind: 'pot', value: 400, simulated: false }, leds)).toBeNull();
  });
});
