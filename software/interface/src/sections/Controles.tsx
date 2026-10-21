import { useEffect, useState } from 'react';
import { CONTROL_FUNCTIONS, canAssign, type MappingPayload } from '@shared/ts/protocol';
import { useOrbit } from '../data/OrbitContext';
import { Dial, Panel, SimTag } from '../components/ui';
import { ago } from '../lib/format';

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
      <Panel title="Potenciómetros" right={<span className="muted">Arduino Nano · A0–A1 · 0–1023</span>}>
        <div className="pot-grid">
          {potIds.map((id) => {
            const c = state.controls[id];
            return (
              <div key={id} className="pot-card">
                <div className="pot-head"><b>{id}</b><SimTag show={c?.simulated} /></div>
                <Dial value={c?.value} label={id} />
                <label className="field"><span>Función</span>
                  <select value={draft?.pots[id] ?? 'none'} onChange={(e) => set('pots', id, e.target.value)}>
                    {fnOptions('pot').map(([k, v]) => <option key={k} value={k}>{v.label}</option>)}
                  </select>
                </label>
              </div>
            );
          })}
        </div>
      </Panel>
      <Panel title="Botones" right={<span className="muted">D2 · D3 · pulsación larga ≥ 800 ms</span>}>
        <div className="btn-grid">
          {btnIds.map((id) => {
            const c = state.controls[id];
            const lit = c && c.event !== 'release' && Date.now() - c.ts < 1500;
            return (
              <div key={id} className="btnmap-card">
                <div className={`hw-button ${lit ? 'lit' : ''}`} aria-label={`${id} ${lit ? 'pulsado' : 'en reposo'}`}>{id}</div>
                <label className="field"><span>Función</span>
                  <select value={draft?.buttons[id] ?? 'none'} onChange={(e) => set('buttons', id, e.target.value)}>
                    {fnOptions('button').map(([k, v]) => <option key={k} value={k}>{v.label}</option>)}
                  </select>
                </label>
                {injectControl && (
                  <button className="btn small" onClick={() => { injectControl({ control: id, kind: 'button', event: 'press' }); setTimeout(() => injectControl({ control: id, kind: 'button', event: 'release' }), 180); }}>Simular pulsación</button>
                )}
              </div>
            );
          })}
        </div>
        <div className="row-actions">
          <button className="btn btn-primary" disabled={!dirty || !draft} onClick={() => draft && setMapping(draft)}>Guardar asignación</button>
          <button className="btn" disabled={!dirty} onClick={() => setDraft(state.mapping)}>Descartar cambios</button>
        </div>
      </Panel>
      <Panel title="Últimos eventos" className="ev-panel">
        <ul className="ev-list">
          {events.length === 0 && <li className="muted">Sin eventos todavía.</li>}
          {events.map((e) => (
            <li key={e.control}><b>{e.control}</b> {e.kind === 'pot' ? `= ${e.value}` : e.event} <span className="muted">{ago(e.ts)}</span> <SimTag show={e.simulated} /></li>
          ))}
        </ul>
        <p className="muted small-note">Los encoders se han sustituido por potenciómetros + botones leídos por un Arduino Nano. El Nano no tiene USB nativo: no hay volumen HID. El volumen del HP lo aplica orbitd a través de hp-agent.</p>
      </Panel>
    </div>
  );
}
