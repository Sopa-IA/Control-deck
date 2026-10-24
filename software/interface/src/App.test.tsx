import { afterEach, describe, expect, it, vi } from 'vitest';
import { act, cleanup, fireEvent, render, screen, within } from '@testing-library/react';
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
    expect(screen.getByRole('button', { name: /Ardu Lab/ })).toBeTruthy();
    expect(screen.getAllByText('SIM').length).toBeGreaterThan(0);
    expect(screen.getByText('v1.0.0')).toBeTruthy();
    expect(screen.queryByText(/prototipo/i)).toBeNull();
    fireEvent.click(within(screen.getByRole('navigation')).getByRole('button', { name: /Herramientas/ }));
    expect((screen.getByRole('button', { name: 'Apagado' }) as HTMLButtonElement).disabled).toBe(true);
    expect(screen.getByText(/Falta conectar la tira de luz/)).toBeTruthy();
    fireEvent.click(within(screen.getByRole('navigation')).getByRole('button', { name: /Controles/ }));
    const listas = screen.getAllByRole('combobox') as HTMLSelectElement[];
    expect(listas.length).toBeGreaterThan(0);
    expect(listas.every((nodo) => nodo.disabled)).toBe(true);
    expect(screen.getByText(/Falta cablear los potenciómetros/)).toBeTruthy();
  });
  it('con backend real sin conexión: no inventa datos ni muestra SIMULACIÓN', async () => {
    vi.stubGlobal('WebSocket', FakeWebSocket);
    vi.useFakeTimers();
    render(<OrbitProvider forceSource="ws"><Shell /></OrbitProvider>);
    await act(async () => { vi.advanceTimersByTime(10); });
    expect(screen.queryByText(/MODO SIMULACIÓN/)).toBeNull();
    expect(screen.getByText('Sin conexión con el equipo')).toBeTruthy();
    expect(screen.getAllByText('sin telemetría').length).toBe(2);
  });
});
