import { describe, expect, it } from 'vitest';
import schema from '@shared/schemas/protocol.schema.json';
import controlsDefault from '@shared/controls.default.json';
import { ACTIONS, CONTROL_FUNCTIONS, MESSAGE_TYPES, canAssign, isAllowedAction, isMessage, makeMessage } from '@shared/ts/protocol';

describe('protocolo compartido', () => {
  it('los tipos TS coinciden con el esquema JSON', () => {
    expect([...MESSAGE_TYPES].sort()).toEqual([...(schema.properties.type.enum as string[])].sort());
  });
  it('lista blanca coherente', () => {
    for (const [name, spec] of Object.entries(ACTIONS)) {
      expect(name.split('.')[0]).toBe(spec.target);
      if (spec.destructive) expect(spec.confirm).toBe(true);
    }
    expect(isAllowedAction('hp.shutdown')).toBe(true);
    expect(isAllowedAction('hp.exec')).toBe(false);
    expect(isAllowedAction('__proto__')).toBe(false);
  });
  it('asignación por defecto válida', () => {
    expect(Object.keys(controlsDefault.pots)).toEqual(['P1', 'P2']);
    expect(Object.keys(controlsDefault.buttons)).toEqual(['B1', 'B2']);
    for (const [, fn] of Object.entries(controlsDefault.pots)) expect(canAssign(fn, 'pot')).toBe(true);
    for (const [, fn] of Object.entries(controlsDefault.buttons)) expect(canAssign(fn, 'button')).toBe(true);
    expect(canAssign('ui.select', 'pot')).toBe(false);
    expect(Object.keys(CONTROL_FUNCTIONS)).not.toContain('$comment');
  });
  it('makeMessage produce sobres válidos', () => {
    const m = makeMessage('ping', 'ui', { seq: 1 }, 'abc');
    expect(isMessage(m)).toBe(true);
    expect(m.reply_to).toBe('abc');
    expect(isMessage({ v: 1, type: 'nope', id: 'a', ts: 1, payload: {} })).toBe(false);
    expect(isMessage(null)).toBe(false);
  });
});
