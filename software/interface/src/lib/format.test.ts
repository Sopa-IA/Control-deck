import { describe, expect, it } from 'vitest';
import { ago, clamp, formatClock, formatDate, formatMb, formatPct, formatTemp, formatUptime, potToPct } from './format';

describe('format', () => {
  it('reloj y fecha en español', () => {
    const d = new Date(2026, 9, 18, 9, 5, 7);
    expect(formatClock(d)).toBe('09:05');
    expect(formatClock(d, true)).toBe('09:05:07');
    expect(formatDate(d)).toBe('Dom, 18 oct 2026');
  });
  it('tiempo activo', () => {
    expect(formatUptime(59)).toBe('0 min');
    expect(formatUptime(3 * 3600 + 120)).toBe('3 h 2 min');
    expect(formatUptime(2 * 86400 + 5 * 3600)).toBe('2 d 5 h');
    expect(formatUptime(undefined)).toBe('—');
    expect(formatUptime(-1)).toBe('—');
  });
  it('porcentajes, temperatura y memoria', () => {
    expect(formatPct(12.6)).toBe('13%');
    expect(formatPct(140)).toBe('100%');
    expect(formatPct(null)).toBe('—');
    expect(formatTemp(47.4)).toBe('47 °C');
    expect(formatTemp(undefined)).toBe('—');
    expect(formatMb(2048, 8192)).toBe('2.0 / 8.0 GB');
    expect(clamp(5, 0, 3)).toBe(3);
  });
  it('hace cuánto y potenciómetro', () => {
    expect(ago(null)).toBe('nunca');
    expect(ago(1000, 3000)).toBe('ahora');
    expect(ago(0 + 1, 30_001)).toBe('hace 30 s');
    expect(ago(1, 1 + 125_000)).toBe('hace 2 min');
    expect(potToPct(0)).toBe(0);
    expect(potToPct(1023)).toBe(100);
    expect(potToPct(512)).toBe(50);
  });
});
