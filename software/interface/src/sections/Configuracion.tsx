import { useState } from 'react';
import { useOrbit } from '../data/OrbitContext';
import { Panel } from '../components/ui';

export function Configuracion({ brightness, setBrightness }: { brightness: number; setBrightness: (n: number) => void }) {
  const { state, setSource, wsUrl, setWsUrl } = useOrbit();
  const [url, setUrl] = useState(wsUrl);
  const [token, setToken] = useState(sessionStorage.getItem('orbit.uiToken') ?? '');
  return (
    <div className="config">
      <Panel title="Fuente de datos">
        <div className="seg">
          <button className={`btn ${state.source === 'ws' ? 'btn-primary' : ''}`} onClick={() => setSource('ws')}>Backend real (orbitd)</button>
          <button className={`btn ${state.source === 'sim' ? 'btn-primary' : ''}`} onClick={() => setSource('sim')}>Simulador</button>
        </div>
        <p className="muted">Estado: {state.conn}{state.connDetail ? ` · ${state.connDetail}` : ''}. Con el simulador, o si orbitd declara datos simulados, se muestra MODO SIMULACIÓN.</p>
        <label className="field"><span>URL de orbitd</span><input value={url} onChange={(e) => setUrl(e.target.value)} /></label>
        <label className="field"><span>Token de interfaz (opcional; solo en esta sesión)</span><input type="password" value={token} onChange={(e) => setToken(e.target.value)} autoComplete="off" /></label>
        <button className="btn btn-primary" onClick={() => { sessionStorage.setItem('orbit.uiToken', token); setWsUrl(url); setSource('ws'); }}>Conectar</button>
      </Panel>
      <Panel title="Pantalla">
        <label className="field"><span>Brillo de la interfaz: {brightness}%</span>
          <input type="range" min={20} max={100} value={brightness} onChange={(e) => setBrightness(Number(e.target.value))} />
        </label>
        <p className="muted">Atenuación por software. El brillo real del MSI se ajusta en su OSD.</p>
        <dl className="kv">
          <div><dt>Ventana</dt><dd>{window.innerWidth} × {window.innerHeight}</dd></div>
          <div><dt>Monitor</dt><dd>MSI PRO MP161 E2U · 1920×1080 · no táctil</dd></div>
          <div><dt>Entrada</dt><dd>ratón + potenciómetros/botones (interfaz preparada para táctil)</dd></div>
        </dl>
      </Panel>
      <Panel title="Acerca de" className="span-2">
        <p>Orbit OS Interface v0.1.0 · producto <b>Orbit Terminal</b> · repositorio <b>Sopa-IA/Control-deck</b>. Prototipo: no apto para uso en producción.</p>
      </Panel>
    </div>
  );
}
