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
        <h2 id="osd-title">Cambiar el sistema visible</h2>
        <p>En el prototipo no hay KVM: el monitor <b>MSI PRO MP161 E2U</b> tiene el HP en una entrada y la Raspberry Pi en la otra.</p>
        <ol className="steps">
          <li>Pulsa el botón de menú del monitor (OSD).</li>
          <li>Entra en <b>Fuente de entrada</b> (Input Source).</li>
          <li>Elige <b>Mini-HDMI</b> o <b>USB-C</b> según qué equipo esté en cada una.</li>
        </ol>
        <p className="muted">Nombres exactos del menú OSD y asignación de entradas: PENDIENTE de comprobar en el monitor real. La conmutación automática (DDC/CI o KVM) es una opción futura.</p>
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
