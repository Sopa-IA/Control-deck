import { useEffect, useRef, useState } from 'react';
import { useOrbit } from '../data/OrbitContext';
import { planVolumeSend, type VolumeSendState } from './volumeSlider';

/** Nivel que manda el HP, sin pisarlo mientras el dedo está en el deslizador. */
export function useHpVolume(request: (level: number) => void) {
  const { state } = useOrbit();
  const remote = state.telemetry.hp?.volume_pct;
  const muted = state.telemetry.hp?.volume_muted === true;
  const [vol, setVol] = useState(typeof remote === 'number' ? remote : 40);
  const drag = useRef(false);
  const volRef = useRef(vol);
  const sendState = useRef<VolumeSendState>({ lastAt: 0, lastSent: null, pending: null });
  const timer = useRef<number | null>(null);
  volRef.current = vol;

  useEffect(() => {
    if (!drag.current && typeof remote === 'number') {
      setVol(remote);
      volRef.current = remote;
      sendState.current = { ...sendState.current, lastSent: remote, pending: null };
    }
  }, [remote]);

  const emit = (level: number, now: number, release: boolean) => {
    const plan = planVolumeSend(sendState.current, level, now, release);
    sendState.current = plan.state;
    if (plan.send !== null) request(plan.send);
    return plan.waitMs;
  };

  const onChange = (level: number) => {
    drag.current = true;
    setVol(level);
    volRef.current = level;
    const wait = emit(level, Date.now(), false);
    if (wait !== null && timer.current === null) {
      timer.current = window.setTimeout(() => {
        timer.current = null;
        const pending = sendState.current.pending;
        if (pending !== null) emit(pending, Date.now(), true);
      }, wait);
    }
  };

  const onRelease = () => {
    drag.current = false;
    if (timer.current !== null) {
      window.clearTimeout(timer.current);
      timer.current = null;
    }
    emit(volRef.current, Date.now(), true);
  };

  return { vol, muted, onChange, onRelease };
}
