import { ACTIONS } from '@shared/ts/protocol';
import { useOrbit } from '../data/OrbitContext';
import { Panel } from '../components/ui';
import { motivoFuera } from '../lib/equipo';
import { formatClock } from '../lib/format';
import { TIRA_LED_LISTA } from '../lib/hardwareListo';
import { useHpVolume } from '../lib/useHpVolume';

const LUCES = [
  { mode: 'off', label: 'Apagado' },
  { mode: 'ambar', label: 'Ámbar' },
  { mode: 'respirar', label: 'Respirar' },
  { mode: 'sistema', label: 'Según el sistema' },
] as const;

export function Herramientas() {
  const { state, requestAction } = useOrbit();
  const sinHp = motivoFuera(state, 'hp');
  const { vol, muted, onChange, onRelease } = useHpVolume((level) => requestAction('hp.volume_set', { level }));
  const acciones = Object.entries(ACTIONS).filter(([, s]) => Object.keys(s.params).length === 0);
  return (
    <div className="herramientas">
      <Panel title="Acciones">
        <div className="action-grid">
          {acciones.map(([k, s]) => {
            const porque = motivoFuera(state, s.target);
            return (
              <button key={k} className={`btn action ${s.destructive ? 'btn-danger' : ''}`} disabled={!!porque} title={porque ?? undefined} onClick={() => requestAction(k)}>
                <span>{s.label}</span>{s.confirm ? <small>Pide confirmación</small> : null}
              </button>
            );
          })}
        </div>
      </Panel>
      <Panel title="Volumen del HP">
        <div className="vol-row">
          <input type="range" min={0} max={100} value={vol} aria-label="Volumen del HP" disabled={!!sinHp}
            onChange={(e) => onChange(Number(e.target.value))} onPointerUp={onRelease} onKeyUp={onRelease} onBlur={onRelease} />
          <span className="vol-value">{muted ? `Silencio · ${vol}%` : `${vol}%`}</span>
          <button className="btn btn-primary" disabled={!!sinHp} title={sinHp ?? undefined} onClick={() => requestAction('hp.volume_set', { level: vol })}>Aplicar</button>
        </div>
        <p className="muted">{sinHp ?? 'Sale al soltar, y como mucho cada 200 ms mientras se mueve. Es el volumen de la salida de sonido del HP.'}</p>
        <h4>Luz ámbar</h4>
        <div className="row-actions">
          {LUCES.map((m) => (
            <button key={m.mode} className="btn" disabled={!TIRA_LED_LISTA} title={TIRA_LED_LISTA ? undefined : 'Falta conectar la tira de luz.'}
              onClick={() => requestAction('pi.led_mode', { mode: m.mode })}>{m.label}</button>
          ))}
        </div>
        {!TIRA_LED_LISTA && <p className="callout">Falta conectar la tira de luz. Estos botones no envían nada.</p>}
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
