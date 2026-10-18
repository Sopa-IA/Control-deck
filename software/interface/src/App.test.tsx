import { afterEach, describe, expect, it, vi } from 'vitest';
import { act, cleanup, render, screen } from '@testing-library/react';
import { OrbitProvider } from './data/OrbitContext';
import { Shell } from './App';

class FakeWebSocket {
  static OPEN = 1;
  readyState = 0;
  onopen: (() => void) | null = null;
  onmessage: ((e: { data: string }) => void) | null = null;
  onclose: (() => void) | null = null;
  constructor(public url: string) { setTimeout(() => this.onclose?.(), 0); }
  send() {}
  close() {}
}

afterEach(() => { cleanup(); vi.unstubAllGlobals(); vi.useRealTimers(); });

describe('App', () => {
  it('con el simulador muestra el distintivo MODO SIMULACIÓN', async () => {
    render(<OrbitProvider forceSource="sim" animate={false}><Shell /></OrbitProvider>);
    expect(await screen.findByText(/MODO SIMULACIÓN/)).toBeTruthy();
    expect(screen.getAllByText('SIM').length).toBeGreaterThan(0);
  });
  it('con backend real sin conexión: no inventa datos ni muestra SIMULACIÓN', async () => {
    vi.stubGlobal('WebSocket', FakeWebSocket);
    vi.useFakeTimers();
    render(<OrbitProvider forceSource="ws"><Shell /></OrbitProvider>);
    await act(async () => { vi.advanceTimersByTime(10); });
    expect(screen.queryByText(/MODO SIMULACIÓN/)).toBeNull();
    expect(screen.getByText('SIN CONEXIÓN CON ORBITD')).toBeTruthy();
    expect(screen.getAllByText('sin telemetría').length).toBe(2);
  });
});
