import { describe, expect, it } from 'vitest';
import { planVolumeSend, type VolumeSendState } from './volumeSlider';

const quiet = (): VolumeSendState => ({ lastAt: 0, lastSent: null, pending: null });

describe('deslizador de volumen', () => {
  it('el primer movimiento sale ya, y el mismo nivel no se repite', () => {
    const first = planVolumeSend(quiet(), 40, 1000, false);
    expect(first.send).toBe(40);
    const again = planVolumeSend(first.state, 40, 1100, false);
    expect(again.send).toBeNull();
    const release = planVolumeSend(first.state, 40, 1100, true);
    expect(release.send).toBeNull();
  });

  it('mientras se arrastra, como mucho uno cada 200 ms, y al soltar manda el último', () => {
    const first = planVolumeSend(quiet(), 10, 1000, false);
    const mid = planVolumeSend(first.state, 11, 1050, false);
    expect(mid.send).toBeNull();
    expect(mid.waitMs).toBe(150);
    const later = planVolumeSend(mid.state, 12, 1200, false);
    expect(later.send).toBe(12);
    const up = planVolumeSend(later.state, 13, 1250, true);
    expect(up.send).toBe(13);
  });
});
