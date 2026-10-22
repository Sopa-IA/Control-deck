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
        <h2 id="osd-title">Cómo se ve el HP</h2>
        <p>La MSI muestra siempre la Pi. El botón <b>Cambiar sistema</b> (el B2 del Nano) abre Moonlight contra el HP en 10.0.0.1 y, si Moonlight ya está abierto, lo cierra y devuelve Orbit OS al frente.</p>
        <ol className="steps">
          <li><b>Vista integrada</b> (la de por defecto): la barra de Orbit OS se queda arriba y Moonlight entra, sin bordes, en el hueco de 1920×1040 a 60 fps. El ratón pasa de la barra a Windows porque Moonlight no captura el puntero. El teclado va a Windows cuando esa ventana tiene el foco.</li>
          <li><b>Pantalla completa</b>: el botón «Pantalla completa» o <b>Ctrl+Alt+Mayús+X</b> pasan a 1920×1080 a 60 fps. El mismo atajo vuelve a la vista integrada.</li>
          <li><b>Salir de Moonlight:</b> otra vez el botón B2, el botón «Orbit OS», o <b>Ctrl+Alt+Mayús+Q</b> (atajo del propio Moonlight).</li>
        </ol>
        <p className="callout">Si Moonlight y Sunshine aún no están emparejados, el escritorio del HP no se abre. Hay que emparejarlos una vez. Si Windows no tiene monitor, puede hacer falta un enchufe HDMI falso para que ofrezca 1920×1080; la vista integrada pide 1920×1040.</p>
        <p className="muted">Moonlight es una aplicación nativa: no se puede meter dentro de la página. La integración es colocar esa ventana encima del marco. Sin probar en la Pi ni en el HP.</p>
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
