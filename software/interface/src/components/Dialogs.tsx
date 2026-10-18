import { ACTIONS } from '@shared/ts/protocol';
import { useEffect, useState } from 'react';
import { useOrbit } from '../data/OrbitContext';

export function ConfirmDialog() {
  const { state, confirm, cancelConfirm, simulated } = useOrbit();
  const p = state.pendingConfirm;
  const [left, setLeft] = useState(0);
  useEffect(() => {
    if (!p) return;
    const end = Date.now() + p.expires_in_s * 1000;
    setLeft(p.expires_in_s);
    const t = setInterval(() => {
      const s = Math.max(0, Math.ceil((end - Date.now()) / 1000));
      setLeft(s);
      if (s === 0) cancelConfirm();
    }, 250);
    return () => clearInterval(t);
  }, [p, cancelConfirm]);
  if (!p) return null;
  const label = ACTIONS[p.action]?.label ?? p.action;
  return (
    <div className="modal-back" role="dialog" aria-modal="true" aria-labelledby="cf-title">
      <div className="modal">
        <h2 id="cf-title">Confirmar: {label}</h2>
        <p>Acción protegida. {simulated ? 'Estás en MODO SIMULACIÓN: no se ejecutará nada real.' : 'El sistema se apagará con 60 s de margen y se podrá cancelar.'}</p>
        <p className="muted">La confirmación caduca en {left} s.</p>
        <div className="modal-actions">
          <button className="btn" onClick={cancelConfirm}>Cancelar</button>
          <button className="btn btn-danger" onClick={confirm} autoFocus>Confirmar</button>
        </div>
      </div>
    </div>
  );
}

export function OsdHelp({ onClose }: { onClose: () => void }) {
  return (
    <div className="modal-back" role="dialog" aria-modal="true" aria-labelledby="osd-title" onClick={onClose}>
      <div className="modal" onClick={(e) => e.stopPropagation()}>
        <h2 id="osd-title">Cómo cambia Orbit de sistema</h2>
        <p>El botón <b>Cambiar sistema visible</b> (B2 por defecto) lo hace todo desde Orbit OS; no hace falta tocar el menú del monitor.</p>
        <ol className="steps">
          <li><b>Modo remoto</b> (base, siempre disponible): la pantalla muestra siempre la Pi y el escritorio del HP aparece en un visor (p. ej. Moonlight con Sunshine en el HP) por el cable Ethernet interno.</li>
          <li><b>Modo capturadora</b> (recomendado junto al remoto): el HDMI del HP entra en una capturadora HDMI→USB conectada a la Pi y Orbit OS muestra su imagen a pantalla completa. La pantalla sigue siempre en la Pi; teclado y ratón van al HP por separado. Si la capturadora no está, Orbit vuelve solo al modo remoto.</li>
          <li><b>Modo DDC/CI</b> (opcional, poco probable): si está configurado y el monitor lo acepta, la Pi cambia la entrada del MSI (HP por Mini-HDMI, Pi por USB-C con adaptador HDMI→USB-C). Los manuales del MSI no documentan DDC/CI. Si falla, Orbit pasa a la capturadora o al modo remoto.</li>
        </ol>
        <p className="muted">PENDIENTE de verificar: soporte DDC/CI del MSI MP161 E2U, adaptador HDMI→USB-C (DP Alt), latencia y fps de la capturadora (sin medir) y rendimiento del visor remoto en el HP (AMD A6-7310).</p>
        <div className="modal-actions"><button className="btn btn-primary" onClick={onClose} autoFocus>Entendido</button></div>
      </div>
    </div>
  );
}

export function PowerMenu({ onClose }: { onClose: () => void }) {
  const { requestAction } = useOrbit();
  const go = (a: string) => { requestAction(a); onClose(); };
  return (
    <div className="modal-back" role="dialog" aria-modal="true" aria-labelledby="pw-title" onClick={onClose}>
      <div className="modal" onClick={(e) => e.stopPropagation()}>
        <h2 id="pw-title">Apagado seguro</h2>
        <div className="grid-2">
          <button className="btn btn-danger big" onClick={() => go('hp.shutdown')}>Apagar HP</button>
          <button className="btn big" onClick={() => go('hp.restart')}>Reiniciar HP</button>
          <button className="btn big" onClick={() => go('hp.shutdown_cancel')}>Cancelar apagado HP</button>
          <button className="btn btn-danger big" onClick={() => go('pi.shutdown')}>Apagar Raspberry Pi</button>
        </div>
        <p className="muted">Cada acción pide confirmación y orbitd la valida contra la lista blanca.</p>
        <div className="modal-actions"><button className="btn" onClick={onClose}>Cerrar</button></div>
      </div>
    </div>
  );
}
