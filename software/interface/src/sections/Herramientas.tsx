import { ACTIONS } from '@shared/ts/protocol';
import { useOrbit } from '../data/OrbitContext';
import { Panel } from '../components/ui';
import { formatClock } from '../lib/format';
import { useHpVolume } from '../lib/useHpVolume';

export function Herramientas() {
  const { state, requestAction } = useOrbit();
  const { vol, muted, onChange, onRelease } = useHpVolume((level) => requestAction('hp.volume_set', { level }));
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
          <input type="range" min={0} max={100} value={vol} aria-label="Volumen del HP"
            onChange={(e) => onChange(Number(e.target.value))} onPointerUp={onRelease} onKeyUp={onRelease} onBlur={onRelease} />
          <span className="vol-value">{muted ? `Silencio · ${vol}%` : `${vol}%`}</span>
          <button className="btn btn-primary" onClick={() => requestAction('hp.volume_set', { level: vol })}>Aplicar</button>
        </div>
        <p className="muted">Sale al soltar, y como mucho cada 200 ms mientras se mueve. Es el volumen de la salida por defecto del HP. Silenciar HP está en la lista de arriba.</p>
        <h4>LEDs ámbar</h4>
        <div className="row-actions">
          {['off', 'ambar', 'respirar', 'sistema'].map((m) => <button key={m} className="btn" onClick={() => requestAction('pi.led_mode', { mode: m })}>{m}</button>)}
        </div>
        <p className="muted">Tira LED sin identificar: el modo se registra pero no se envía a ningún hardware.</p>
      </Panel>
      <Panel title="Registro" className="span-2">
        <ul className="log">
          {state.log.length === 0 && <li className="muted">Sin actividad.</li>}
          {state.log.map((e, i) => <li key={i} className={`lv-${e.level}`}><span className="muted">{formatClock(new Date(e.ts), true)}</span> {e.text}{e.count && e.count > 1 ? ` ×${e.count}` : ''}</li>)}
        </ul>
      </Panel>
    </div>
  );
}
