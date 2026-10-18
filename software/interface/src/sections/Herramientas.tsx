import { useState } from 'react';
import { ACTIONS } from '@shared/ts/protocol';
import { useOrbit } from '../data/OrbitContext';
import { Panel } from '../components/ui';
import { formatClock } from '../lib/format';

export function Herramientas() {
  const { state, requestAction } = useOrbit();
  const [vol, setVol] = useState(50);
  const simple = Object.entries(ACTIONS).filter(([, s]) => Object.keys(s.params).length === 0);
  return (
    <div className="herramientas">
      <Panel title="Acciones permitidas (lista blanca)">
        <div className="action-grid">
          {simple.map(([k, s]) => (
            <button key={k} className={`btn action ${s.destructive ? 'btn-danger' : ''}`} onClick={() => requestAction(k)}>
              <span>{s.label}</span><small>{k}{s.confirm ? ' · confirma' : ''}</small>
            </button>
          ))}
        </div>
      </Panel>
      <Panel title="Volumen del HP">
        <div className="vol-row">
          <input type="range" min={0} max={100} value={vol} onChange={(e) => setVol(Number(e.target.value))} aria-label="Volumen" />
          <span className="vol-value">{vol}%</span>
          <button className="btn btn-primary" onClick={() => requestAction('hp.volume_set', { level: vol })}>Aplicar</button>
        </div>
        <p className="muted">En Windows el volumen está PENDIENTE en hp-agent (sin orden nativa).</p>
        <h4>LEDs ámbar</h4>
        <div className="row-actions">
          {['off', 'ambar', 'respirar', 'sistema'].map((m) => <button key={m} className="btn" onClick={() => requestAction('pi.led_mode', { mode: m })}>{m}</button>)}
        </div>
        <p className="muted">Tira LED sin identificar: el modo se registra pero no se envía a ningún hardware.</p>
      </Panel>
      <Panel title="Registro" className="span-2">
        <ul className="log">
          {state.log.length === 0 && <li className="muted">Sin actividad.</li>}
          {state.log.map((e, i) => <li key={i} className={`lv-${e.level}`}><span className="muted">{formatClock(new Date(e.ts), true)}</span> {e.text}</li>)}
        </ul>
      </Panel>
    </div>
  );
}
