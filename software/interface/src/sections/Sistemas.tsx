import { useOrbit } from '../data/OrbitContext';
import { Panel, SimTag, StatusDot } from '../components/ui';
import { ago, formatMb, formatPct, formatTemp, formatUptime, videoModeLabel } from '../lib/format';
import { SystemCard } from './Inicio';

function Detail({ host }: { host: 'hp' | 'pi' }) {
  const { state, requestAction } = useOrbit();
  const t = state.telemetry[host];
  const n = state.nodes[host];
  const sim = !!(t?.simulated || n?.simulated);
  const rows: [string, string][] = [
    ['Equipo', t?.hostname ?? '—'], ['Modelo', t?.model ?? 'PENDIENTE'], ['Sistema', t?.os ?? '—'],
    ['CPU', formatPct(t?.cpu_pct)], ['Memoria', `${formatPct(t?.mem_pct)} · ${formatMb(t?.mem_used_mb, t?.mem_total_mb)}`],
    ['Disco', formatPct(t?.disk_pct)], ['Temperatura', formatTemp(t?.temp_c)], ['Tiempo activo', formatUptime(t?.uptime_s)],
    ['Red', t?.net_down_kbps !== undefined ? `↓ ${t.net_down_kbps} kb/s · ↑ ${t.net_up_kbps ?? 0} kb/s` : '—'],
    ['Último dato', t ? ago(t.ts) : 'nunca'],
  ];
  return (
    <Panel title={<>{host === 'hp' ? 'HP · sistema principal' : 'Raspberry Pi · Orbit OS'} <SimTag show={sim} /></>}
      right={<span className="muted"><StatusDot ok={n?.connected} sim={sim} /> {n?.detail ?? 'sin estado'}</span>}>
      <dl className="kv">{rows.map(([k, v]) => <div key={k}><dt>{k}</dt><dd>{v}</dd></div>)}</dl>
      <div className="row-actions">
        {host === 'hp' ? (<>
          <button className="btn" onClick={() => requestAction('hp.ping')}>Comprobar</button>
          <button className="btn" onClick={() => requestAction('hp.lock_screen')}>Bloquear sesión</button>
          <button className="btn btn-danger" onClick={() => requestAction('hp.shutdown')}>Apagar (60 s)</button>
        </>) : (<>
          <button className="btn" onClick={() => requestAction('pi.ping')}>Comprobar</button>
          <button className="btn" onClick={() => requestAction('pi.restart_ui')}>Recargar interfaz</button>
          <button className="btn btn-danger" onClick={() => requestAction('pi.shutdown')}>Apagar Pi</button>
        </>)}
      </div>
    </Panel>
  );
}

export function Sistemas({ openOsd }: { openOsd: () => void }) {
  const { state, requestAction } = useOrbit();
  const visible = state.visible;
  return (
    <div className="sistemas">
      <div className="col"><SystemCard host="hp" /><Detail host="hp" /></div>
      <div className="col"><SystemCard host="pi" /><Detail host="pi" /></div>
      <Panel title="Pantalla compartida" className="span-2">
        <p>Orbit OS cambia de sistema por ti; nunca hace falta tocar el menú del <b>MSI PRO MP161 E2U</b>.
          Modo <b>remoto</b> (base): el escritorio del HP se ve en un visor de la Pi por el Ethernet interno.
          Modo <b>capturadora</b> (recomendado): el HDMI del HP entra en una capturadora USB de la Pi y Orbit OS muestra su imagen (latencia sin medir).
          Modo <b>DDC/CI</b> (poco probable): la Pi cambia la entrada del monitor (sin documentar en los manuales de la MSI; sin verificar).</p>
        <p>Visible ahora: <b>{visible ? (visible.system === 'hp' ? 'HP' : 'Raspberry Pi (Orbit OS)') : 'desconocido'}</b>
          {visible ? <> · modo <b>{videoModeLabel(visible.mode)}</b></> : null}
          {visible?.detail ? <span className="muted"> · {visible.detail}</span> : null}</p>
        <div className="row-actions">
          <button className="btn btn-primary" onClick={() => requestAction('pi.switch_visible')}>Cambiar sistema visible</button>
          <button className="btn" onClick={openOsd}>Cómo funciona</button>
        </div>
      </Panel>
    </div>
  );
}
