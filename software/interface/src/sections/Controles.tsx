import { useEffect, useState } from 'react';
import { CONTROL_FUNCTIONS, canAssign, type MappingPayload } from '@shared/ts/protocol';
import { useOrbit } from '../data/OrbitContext';
import { Dial, Panel, SimTag } from '../components/ui';
import { ago } from '../lib/format';
import { MANDOS_CABLEADOS, TIRA_LED_LISTA } from '../lib/hardwareListo';

const fnOptions = (kind: 'pot' | 'button') => Object.entries(CONTROL_FUNCTIONS).filter(([k]) => canAssign(k, kind));

export function Controles() {
  const { state, setMapping, injectControl } = useOrbit();
  const [draft, setDraft] = useState<MappingPayload | null>(state.mapping);
  useEffect(() => { setDraft(state.mapping); }, [state.mapping]);
  const potIds = Object.keys(draft?.pots ?? {}).sort();
  const btnIds = Object.keys(draft?.buttons ?? {}).sort();
  const dirty = JSON.stringify(draft) !== JSON.stringify(state.mapping);
  const set = (group: 'pots' | 'buttons', id: string, fn: string) => draft && setDraft({ ...draft, [group]: { ...draft[group], [id]: fn } });
  const events = Object.values(state.controls).sort((a, b) => b.ts - a.ts).slice(0, 8);

  return (
    <div className="controles">
      <Panel title="Potenciómetros" right={<span className="muted">A0 y A1 del Nano de mandos</span>}>
        {!MANDOS_CABLEADOS && <p className="callout">Falta cablear los potenciómetros. Hasta entonces no cambian nada.</p>}
        <div className="pot-grid">
          {potIds.map((id) => {
            const c = state.controls[id];
            return (
              <div key={id} className="pot-card">
                <div className="pot-head"><b>{id}</b><SimTag show={c?.simulated} /></div>
                <Dial value={MANDOS_CABLEADOS ? c?.value : undefined} label={id} />
                {!MANDOS_CABLEADOS && <p className="muted">Falta cablearlo.</p>}
                <label className="field"><span>Función</span>
                  <select value={draft?.pots[id] ?? 'none'} disabled={!MANDOS_CABLEADOS} onChange={(e) => set('pots', id, e.target.value)}>
                    {fnOptions('pot').map(([k, v]) => <option key={k} value={k} disabled={!TIRA_LED_LISTA && k === 'ui.led_brightness'}>{v.label}</option>)}
                  </select>
                </label>
              </div>
            );
          })}
        </div>
      </Panel>
      <Panel title="Pulsadores" right={<span className="muted">D2 y D3 · mantener 800 ms para apagar</span>}>
        {!MANDOS_CABLEADOS && <p className="callout">Falta cablear los pulsadores. Hasta entonces no hacen nada.</p>}
        <div className="btn-grid">
          {btnIds.map((id) => {
            const c = state.controls[id];
            const lit = c && c.event !== 'release' && Date.now() - c.ts < 1500;
            return (
              <div key={id} className="btnmap-card">
                <div className={`hw-button ${lit ? 'lit' : ''}`} aria-label={`${id} ${lit ? 'pulsado' : 'en reposo'}`}>{id}</div>
                {!MANDOS_CABLEADOS && <p className="muted">Falta cablearlo.</p>}
                <label className="field"><span>Función</span>
                  <select value={draft?.buttons[id] ?? 'none'} disabled={!MANDOS_CABLEADOS} onChange={(e) => set('buttons', id, e.target.value)}>
                    {fnOptions('button').map(([k, v]) => <option key={k} value={k}>{v.label}</option>)}
                  </select>
                </label>
                {injectControl && MANDOS_CABLEADOS && (
                  <button className="btn small" onClick={() => { injectControl({ control: id, kind: 'button', event: 'press' }); setTimeout(() => injectControl({ control: id, kind: 'button', event: 'release' }), 180); }}>Probar pulsación</button>
                )}
              </div>
            );
          })}
        </div>
        <div className="row-actions">
          <button className="btn btn-primary" disabled={!MANDOS_CABLEADOS || !dirty || !draft} onClick={() => draft && setMapping(draft)}>Guardar asignación</button>
          <button className="btn" disabled={!MANDOS_CABLEADOS || !dirty} onClick={() => setDraft(state.mapping)}>Descartar cambios</button>
        </div>
      </Panel>
      <Panel title="Últimos eventos" className="ev-panel">
        <ul className="ev-list">
          {events.length === 0 && <li className="muted">Sin eventos todavía.</li>}
          {events.map((e) => (
            <li key={e.control}><b>{e.control}</b> {e.kind === 'pot' ? `= ${e.value}` : e.event} <span className="muted">{ago(e.ts)}</span> <SimTag show={e.simulated} /></li>
          ))}
        </ul>
        <p className="muted small-note">Cuando estén cableados, elige la función aquí o en Configuración y guarda. Un cambio menor del 3 % no cuenta, una entrada que salta al azar no dispara acciones y el mismo nivel no se repite.</p>
      </Panel>
    </div>
  );
}
