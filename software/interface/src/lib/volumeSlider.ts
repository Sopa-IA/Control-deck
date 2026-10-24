/** El deslizador no manda un hp.volume_set por cada píxel. */

export const VOLUME_SEND_MS = 200;

export interface VolumeSendState {
  lastAt: number;
  lastSent: number | null;
  pending: number | null;
}

export function planVolumeSend(
  state: VolumeSendState,
  level: number,
  now: number,
  release: boolean,
  period = VOLUME_SEND_MS,
): { state: VolumeSendState; send: number | null; waitMs: number | null } {
  if (release || state.lastSent === null || now - state.lastAt >= period) {
    if (state.lastSent === level) {
      return { state: { ...state, pending: null }, send: null, waitMs: null };
    }
    return { state: { lastAt: now, lastSent: level, pending: null }, send: level, waitMs: null };
  }
  if (state.lastSent === level) {
    return { state: { ...state, pending: null }, send: null, waitMs: null };
  }
  return { state: { ...state, pending: level }, send: null, waitMs: Math.max(0, period - (now - state.lastAt)) };
}
