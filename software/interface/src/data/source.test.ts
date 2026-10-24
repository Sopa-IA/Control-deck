import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import type { Message } from '@shared/ts/protocol';
import { chooseSource, defaultWsUrl } from './source';
import { SimDataSource, simTelemetry } from './simSource';

describe('elección de fuente', () => {
  it('prioridad: URL > guardada > entorno', () => {
    expect(chooseSource('?source=ws', 'sim', true)).toBe('ws');
    expect(chooseSource('', 'ws', true)).toBe('ws');
    expect(chooseSource('', null, true)).toBe('sim');
    expect(chooseSource('', null, false)).toBe('ws');
    expect(chooseSource('?source=otra', null, false)).toBe('ws');
  });
  it('URL del WebSocket según protocolo', () => {
    expect(defaultWsUrl({ protocol: 'http:', host: 'pi.local:8765' })).toBe('ws://pi.local:8765/ws');
    expect(defaultWsUrl({ protocol: 'https:', host: 'x' })).toBe('wss://x/ws');
  });
});

describe('simTelemetry', () => {
  it('el tiempo activo no es la época unix', () => {
    const ahora = Date.now();
    for (const host of ['hp', 'pi'] as const) {
      const u = simTelemetry(host, ahora).uptime_s ?? 0;
      expect(u).toBeGreaterThan(0);
      expect(u).toBeLessThan(86400);
    }
  });
});

describe('SimDataSource', () => {
  beforeEach(() => vi.useFakeTimers());
  afterEach(() => vi.useRealTimers());

  it('todo lo que emite va marcado como simulado', () => {
    const msgs: Message[] = [];
    const ds = new SimDataSource();
    ds.connect((m) => msgs.push(m), () => {});
    vi.advanceTimersByTime(10_000);
    ds.close();
    const tele = msgs.filter((m) => m.type === 'telemetry');
    const ctl = msgs.filter((m) => m.type === 'control_event');
    const st = msgs.filter((m) => m.type === 'state');
    expect(tele.length).toBeGreaterThan(4);
    expect(ctl.length).toBeGreaterThan(2);
    expect(tele.every((m) => (m.payload as { simulated: boolean }).simulated)).toBe(true);
    expect(ctl.every((m) => (m.payload as { simulated: boolean }).simulated)).toBe(true);
    expect(st.every((m) => (m.payload as { mode: string }).mode === 'sim')).toBe(true);
  });

  it('flujo de confirmación y lista blanca', async () => {
    const { makeMessage } = await import('@shared/ts/protocol');
    const msgs: Message[] = [];
    const ds = new SimDataSource({ animateControls: false });
    ds.connect((m) => msgs.push(m), () => {});
    ds.send(makeMessage('action_request', 'ui', { action: 'hp.borrar_todo' }));
    expect(msgs.at(-1)?.type).toBe('error');
    ds.send(makeMessage('action_request', 'ui', { action: 'hp.shutdown' }));
    const cr = msgs.at(-1) as Message<'confirm_required'>;
    expect(cr.type).toBe('confirm_required');
    ds.send(makeMessage('action_confirm', 'ui', { request_id: cr.payload.request_id, challenge: 'mal' }));
    expect(msgs.at(-1)?.type).toBe('error');
    ds.send(makeMessage('action_request', 'ui', { action: 'hp.shutdown' }));
    const cr2 = msgs.at(-1) as Message<'confirm_required'>;
    ds.send(makeMessage('action_confirm', 'ui', { request_id: cr2.payload.request_id, challenge: cr2.payload.challenge }));
    const res = msgs.at(-1) as Message<'action_result'>;
    expect(res.type).toBe('action_result');
    expect(res.payload.simulated).toBe(true);
    expect(res.payload.dry_run).toBe(true);
    ds.close();
  });
});
