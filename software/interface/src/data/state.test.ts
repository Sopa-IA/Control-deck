import { describe, expect, it } from 'vitest';
import { makeMessage } from '@shared/ts/protocol';
import { initialState, isSimulated, reduce, simulatedParts } from './state';

const realNode = { connected: true, simulated: false, last_seen: 1 };

describe('reductor de estado', () => {
  it('aplica state, telemetry, control_event, mapping y errores', () => {
    let s = initialState('ws');
    s = reduce(s, { kind: 'message', msg: makeMessage('state', 'pi', { mode: 'real', hp: realNode, pi: realNode, arduino: realNode }) });
    expect(s.mode).toBe('real');
    s = reduce(s, { kind: 'message', now: 5, msg: makeMessage('telemetry', 'pi', { host: 'hp', simulated: false, cpu_pct: 10, mem_pct: 20 }) });
    expect(s.telemetry.hp?.cpu_pct).toBe(10);
    expect(s.telemetry.hp?.ts).toBe(5);
    s = reduce(s, { kind: 'message', msg: makeMessage('control_event', 'pi', { control: 'P1', kind: 'pot', value: 700, simulated: false }) });
    expect(s.controls.P1.value).toBe(700);
    s = reduce(s, { kind: 'message', msg: makeMessage('mapping', 'pi', { pots: { P1: 'hp.volume_set' }, buttons: {} }) });
    expect(s.mapping?.pots.P1).toBe('hp.volume_set');
    s = reduce(s, { kind: 'message', msg: makeMessage('error', 'pi', { code: 'not_allowed', message: 'x' }) });
    expect(s.log[0].level).toBe('error');
    s = reduce(s, { kind: 'message', msg: makeMessage('action_result', 'pi', { action: 'hp.ping', ok: true, dry_run: true, message: 'm' }) });
    expect(s.log[0].text).toContain('DRY-RUN');
  });

  it('confirmación pendiente se guarda y se limpia', () => {
    let s = initialState('ws');
    s = reduce(s, { kind: 'message', msg: makeMessage('confirm_required', 'pi', { request_id: 'r', action: 'hp.shutdown', challenge: 'abcdefgh12', expires_in_s: 15 }) });
    expect(s.pendingConfirm?.request_id).toBe('r');
    s = reduce(s, { kind: 'clear_confirm' });
    expect(s.pendingConfirm).toBeNull();
  });

  it('el registro agrupa la misma línea y no la repite', () => {
    let s = initialState('ws');
    const line = { action: 'hp.volume_set', ok: false, dry_run: false, message: 'hp.volume_set: sin implementación real en Windows (PENDIENTE)' };
    for (let i = 0; i < 12; i++) {
      s = reduce(s, { kind: 'message', now: i, msg: makeMessage('action_result', 'pi', line) });
    }
    expect(s.log).toHaveLength(1);
    expect(s.log[0].count).toBe(12);
    s = reduce(s, { kind: 'message', msg: makeMessage('action_result', 'pi', { ...line, message: 'volumen al 40%, con sonido' }) });
    expect(s.log).toHaveLength(2);
    expect(s.log[0].text).toContain('volumen al 40%');
  });

  it('el registro está acotado', () => {
    let s = initialState('ws');
    for (let i = 0; i < 100; i++) s = reduce(s, { kind: 'log', entry: { ts: i, level: 'info', text: `${i}` } });
    expect(s.log.length).toBe(60);
    expect(s.log[0].text).toBe('99');
  });
});

describe('isSimulated: nunca presentar lo simulado como real', () => {
  const base = () => reduce(initialState('ws'), { kind: 'message', msg: makeMessage('state', 'pi', { mode: 'real', hp: realNode, pi: realNode, arduino: realNode }) });

  it('backend real sin nada simulado -> sin distintivo', () => {
    const s = reduce(base(), { kind: 'message', msg: makeMessage('telemetry', 'pi', { host: 'pi', simulated: false, cpu_pct: 1, mem_pct: 1 }) });
    expect(isSimulated(s)).toBe(false);
    expect(simulatedParts(s)).toEqual([]);
  });
  it('fuente simulador -> distintivo siempre', () => {
    expect(isSimulated(initialState('sim'))).toBe(true);
  });
  it('modo mixto o sim declarado por orbitd -> distintivo', () => {
    const s = reduce(base(), { kind: 'message', msg: makeMessage('welcome', 'pi', { session: 's', server_time: 1, heartbeat_s: 5, mode: 'mixto' }) });
    expect(isSimulated(s)).toBe(true);
  });
  it('una sola telemetría o control simulado basta', () => {
    const t = reduce(base(), { kind: 'message', msg: makeMessage('telemetry', 'pi', { host: 'hp', simulated: true, cpu_pct: 1, mem_pct: 1 }) });
    expect(isSimulated(t)).toBe(true);
    expect(simulatedParts(t)).toContain('HP');
    const c = reduce(base(), { kind: 'message', msg: makeMessage('control_event', 'pi', { control: 'B1', kind: 'button', event: 'press', simulated: true }) });
    expect(isSimulated(c)).toBe(true);
    expect(simulatedParts(c)).toContain('controles');
  });
});
