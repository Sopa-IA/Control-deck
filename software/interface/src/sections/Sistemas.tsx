import { useOrbit } from '../data/OrbitContext';
import { Panel, SimTag, StatusDot } from '../components/ui';
import { ago, formatMb, formatPct, formatTemp, formatUptime } from '../lib/format';
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
  return (
    <div className="sistemas">
      <div className="col"><SystemCard host="hp" /><Detail host="hp" /></div>
      <div className="col"><SystemCard host="pi" /><Detail host="pi" /></div>
      <Panel title="Pantalla compartida" className="span-2">
        <p>Prototipo sin KVM: el <b>MSI PRO MP161 E2U</b> recibe el HP por una entrada (Mini-HDMI o USB-C) y la Pi por la otra. El cambio se hace a mano en el OSD del monitor; Orbit no puede saber qué entrada está visible.</p>
        <button className="btn btn-primary" onClick={openOsd}>Ver guía para cambiar de sistema</button>
      </Panel>
    </div>
  );
}
