import { useState } from 'react';
import { CONTROL_FUNCTIONS, canAssign } from '@shared/ts/protocol';
import { useOrbit } from '../data/OrbitContext';
import { usePlanetMotion } from '../components/Planet';
import { Panel } from '../components/ui';
import { etiquetaConexion } from '../lib/equipo';
import { MANDOS_CABLEADOS, TIRA_LED_LISTA } from '../lib/hardwareListo';
import { ORBIT_VERSION } from '../version';

export function Configuracion({ brightness, setBrightness }: { brightness: number; setBrightness: (n: number) => void }) {
  const { state, setSource, setMapping, wsUrl, setWsUrl } = useOrbit();
  const [url, setUrl] = useState(wsUrl);
  const [token, setToken] = useState(sessionStorage.getItem('orbit.uiToken') ?? '');
  const [motion, setMotion] = usePlanetMotion();
  return (
    <div className="config">
      <Panel title="Fuente de datos">
        <div className="seg">
          <button className={`btn ${state.source === 'ws' ? 'btn-primary' : ''}`} onClick={() => setSource('ws')}>Equipo real</button>
          <button className={`btn ${state.source === 'sim' ? 'btn-primary' : ''}`} onClick={() => setSource('sim')}>Simulador</button>
        </div>
        <p className="muted">Estado: {etiquetaConexion(state.conn)}{state.connDetail ? ` · ${state.connDetail}` : ''}. En el simulador, o si algún dato llega marcado como simulado, se muestra MODO SIMULACIÓN.</p>
        <label className="field"><span>Dirección</span><input value={url} onChange={(e) => setUrl(e.target.value)} /></label>
        <label className="field"><span>Clave de esta sesión</span><input type="password" value={token} onChange={(e) => setToken(e.target.value)} autoComplete="off" /></label>
        <button className="btn btn-primary" onClick={() => { sessionStorage.setItem('orbit.uiToken', token); setWsUrl(url); setSource('ws'); }}>Conectar</button>
      </Panel>
      <Panel title="Potenciómetros">
        <p className="muted">{MANDOS_CABLEADOS ? 'Se guarda también desde Controles.' : 'Falta cablear los potenciómetros. Hasta entonces esta lista no se puede cambiar.'}</p>
        {Object.keys(state.mapping?.pots ?? {}).sort().map((id) => (
          <label key={id} className="field"><span>{id}</span>
            <select value={state.mapping?.pots[id] ?? 'none'} disabled={!MANDOS_CABLEADOS} onChange={(e) => {
              if (!state.mapping || !MANDOS_CABLEADOS) return;
              setMapping({ ...state.mapping, version: Math.max(2, state.mapping.version ?? 2), pots: { ...state.mapping.pots, [id]: e.target.value } });
            }}>
              {Object.entries(CONTROL_FUNCTIONS).filter(([k]) => canAssign(k, 'pot')).map(([k, v]) => <option key={k} value={k} disabled={!TIRA_LED_LISTA && k === 'ui.led_brightness'}>{v.label}</option>)}
            </select>
          </label>
        ))}
      </Panel>
      <Panel title="Pantalla">
        <label className="field"><span>Brillo de la interfaz: {brightness}%</span>
          <input type="range" min={20} max={100} value={brightness} onChange={(e) => setBrightness(Number(e.target.value))} />
        </label>
        <p className="muted">Atenuación por software. El brillo real del MSI se ajusta en su OSD.</p>
        <span className="field"><span>Animación del planeta</span></span>
        <div className="seg">
          <button type="button" className={`btn ${motion ? 'btn-primary' : ''}`} onClick={() => setMotion(true)}>Activada</button>
          <button type="button" className={`btn ${motion ? '' : 'btn-primary'}`} onClick={() => setMotion(false)}>Quieta</button>
        </div>
        <p className="muted">En Inicio el planeta gira despacio. Viene activada. Si el sistema pide menos movimiento, se queda quieto aunque aquí esté activada. También se para con Moonlight o si la página no se ve.</p>
        <dl className="kv">
          <div><dt>Ventana</dt><dd>{window.innerWidth} × {window.innerHeight}</dd></div>
          <div><dt>Monitor</dt><dd>MSI PRO MP161 E2U · 1920×1080 · no táctil</dd></div>
          <div><dt>Entrada</dt><dd>Ratón. Los potenciómetros y los pulsadores faltan por cablear.</dd></div>
        </dl>
      </Panel>
      <Panel title="Acerca de" className="span-2">
        <p>Orbit OS {ORBIT_VERSION} · <b>Orbit Terminal</b>.</p>
      </Panel>
    </div>
  );
}
