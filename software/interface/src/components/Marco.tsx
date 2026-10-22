import { useState } from 'react';
import marco from '@shared/marco.json';
import { useOrbit } from '../data/OrbitContext';
import { StatusDot, useNow } from './ui';
import { formatClock, formatPct } from '../lib/format';

const LEDS = ['off', 'ambar', 'respirar', 'sistema'] as const;

/** Marco de la vista integrada: barra de 40 px y hueco para la ventana nativa de Moonlight. */
export function Marco() {
  const { state, requestAction } = useOrbit();
  const now = useNow(1000);
  const [vol, setVol] = useState(40);
  const [led, setLed] = useState(0);
  const layout = state.visible?.layout ?? 'integrado';
  const sidebar = state.visible?.sidebar ?? 'cerrado';
  const side = sidebar === 'abierto' ? marco.sidebar_px : 0;
  const hole = state.visible?.hole ?? {
    x: side, y: marco.bar_px, w: marco.screen_w - side, h: marco.screen_h - marco.bar_px,
  };
  const unpaired = state.visible?.pairing !== 'hecho';
  const hp = state.telemetry.hp;
  const pi = state.telemetry.pi;
  const sim = state.source === 'sim' || !!(hp?.simulated || pi?.simulated || state.nodes.hp?.simulated);
  const volver = () => requestAction('pi.switch_visible');
  const vista = () => requestAction('pi.stream_layout', { layout: layout === 'integrado' ? 'completa' : 'integrado' });
  const barra = () => requestAction('pi.marco_sidebar', { sidebar: sidebar === 'abierto' ? 'cerrado' : 'abierto' });

  return (
    <div className="marco">
      <header className="marco-bar">
        <button className="marco-btn" onClick={barra}>{sidebar === 'abierto' ? 'Ocultar' : 'Barra'}</button>
        <b className="marco-clock">{formatClock(new Date(now), true)}</b>
        <span className="marco-stat"><StatusDot ok={state.nodes.hp?.connected} sim={sim} /> HP {formatPct(hp?.cpu_pct)} · {formatPct(hp?.mem_pct)}</span>
        <span className="marco-stat"><StatusDot ok={state.nodes.pi?.connected} sim={state.nodes.pi?.simulated} /> π {formatPct(pi?.cpu_pct)} · {formatPct(pi?.mem_pct)}</span>
        <label className="marco-vol">Vol
          <input type="range" min={0} max={100} value={vol} aria-label="Volumen del HP" onChange={(e) => {
            const level = Number(e.target.value);
            setVol(level);
            requestAction('hp.volume_set', { level });
          }} />
        </label>
        <button className="marco-btn" onClick={() => {
          const mode = LEDS[(led + 1) % LEDS.length];
          setLed((n) => n + 1);
          requestAction('pi.led_mode', { mode });
        }}>LED</button>
        <span className="marco-gap" />
        {sim && <span className="marco-simtag">SIM</span>}
        <button className="marco-btn" onClick={volver}>Orbit OS</button>
        <button className="marco-btn marco-btn-amber" onClick={vista}>{layout === 'integrado' ? 'Pantalla completa' : 'Vista integrada'}</button>
      </header>
      {sidebar === 'abierto' && (
        <aside className="marco-side">
          <button className="marco-btn" onClick={volver}>π</button>
          <button className="marco-btn" onClick={vista}>⛶</button>
          <button className="marco-btn" onClick={barra}>×</button>
        </aside>
      )}
      <div className="marco-hueco" style={{ left: hole.x, top: hole.y, width: hole.w, height: hole.h }}>
        <div className="marco-fake">
          <b>Zona del HP · SIMULADA</b>
          <p>Hueco {hole.w}×{hole.h} a {marco.fps} fps. Aquí va la ventana de Moonlight, sin bordes. No es una captura de Windows.</p>
          <p>Moonlight es una aplicación nativa y no cabe dentro de esta página: el compositor la coloca encima.</p>
          {unpaired && <p className="marco-warn">El emparejamiento de Moonlight con Sunshine en {marco.hp_host} aún no se ha hecho. Hasta entonces el escritorio del HP no se abre.</p>}
        </div>
      </div>
    </div>
  );
}
