import { useOrbit } from '../data/OrbitContext';
import { Planet, usePlanetMotion } from '../components/Planet';
import { Clock, Meter, Panel, SimTag, StatusDot, useNow } from '../components/ui';
import { motivoFuera, etiquetaConexion } from '../lib/equipo';
import { ago, formatDate, formatPct, formatTemp, formatUptime } from '../lib/format';
import type { SectionId } from './index';

export function SystemCard({ host, onOpen }: { host: 'hp' | 'pi'; onOpen?: () => void }) {
  const { state } = useOrbit();
  const t = state.telemetry[host];
  const n = state.nodes[host];
  const sim = !!(t?.simulated || n?.simulated);
  const title = host === 'hp' ? 'HP' : 'Raspberry Pi';
  const role = host === 'hp' ? 'Sistema principal' : 'Orbit OS · laboratorio';
  const status = !n ? 'sin datos' : n.connected ? (host === 'hp' ? 'Activo' : 'En línea') : 'Desconectado';
  return (
    <button className={`sys-card ${n?.connected ? 'on' : 'off'}`} onClick={onOpen}>
      <div className="sys-card-head">
        <span className="sys-glyph">{host === 'hp' ? 'HP' : 'π'}</span>
        <div className="sys-titles"><b>{title}</b><span>{role}</span></div>
        <span className="sys-status"><StatusDot ok={n?.connected} sim={sim} /> {status} <SimTag show={sim} /></span>
      </div>
      <Meter label="CPU" value={t?.cpu_pct} display={formatPct(t?.cpu_pct)} />
      <Meter label="RAM" value={t?.mem_pct} display={formatPct(t?.mem_pct)} />
      {host === 'hp'
        ? <Meter label="Disco" value={t?.disk_pct} display={formatPct(t?.disk_pct)} warn={90} />
        : <Meter label="SoC" value={t?.temp_c ?? null} display={formatTemp(t?.temp_c)} warn={70} />}
      <div className="sys-foot"><span>Activo {formatUptime(t?.uptime_s)}</span><span>{t ? `dato ${ago(t.ts)}` : 'sin telemetría'}</span></div>
    </button>
  );
}

export function Inicio({ go, openPower }: { go: (s: SectionId) => void; openPower: () => void }) {
  const { state, requestAction } = useOrbit();
  const now = useNow(1000);
  const conn = state.conn;
  const [motion] = usePlanetMotion();
  const sinHp = motivoFuera(state, 'hp');
  const sinPi = motivoFuera(state, 'pi');
  return (
    <div className="inicio">
      <div className="inicio-left">
        <Panel title="Sistema">
          <div className="sys-mini-list">
            {(['hp', 'pi'] as const).map((h) => {
              const n = state.nodes[h];
              const sim = !!(n?.simulated || state.telemetry[h]?.simulated);
              return (
                <button key={h} className={`sys-mini ${h === 'hp' ? 'active' : ''}`} onClick={() => go('sistemas')}>
                  <span className="sys-glyph small">{h === 'hp' ? 'HP' : 'π'}</span>
                  <span className="sys-mini-t"><b>{h === 'hp' ? 'HP' : 'Raspberry Pi'}</b><small>{h === 'hp' ? 'Sistema principal' : 'Laboratorio / Proyectos'}</small></span>
                  <StatusDot ok={n?.connected} sim={sim} />
                </button>
              );
            })}
          </div>
        </Panel>
        <Panel title="Acceso rápido">
          <div className="quick-grid">
            <button className="quick" disabled={!!sinPi} title={sinPi ?? undefined} onClick={() => requestAction('pi.switch_visible')}><span className="qi">⇄</span>Cambiar sistema</button>
            <button className="quick" disabled={!!sinHp} title={sinHp ?? undefined} onClick={() => requestAction('hp.volume_mute')}><span className="qi">♪</span>Silenciar HP</button>
            <button className="quick" disabled={!!sinHp} title={sinHp ?? undefined} onClick={() => requestAction('hp.lock_screen')}><span className="qi">⌧</span>Bloquear HP</button>
            <button className="quick" onClick={() => go('controles')}><span className="qi">◎</span>Controles</button>
            <button className="quick" onClick={() => go('herramientas')}><span className="qi">⚒</span>Herramientas</button>
            <button className="quick danger" onClick={openPower}><span className="qi">⏻</span>Apagado seguro</button>
          </div>
        </Panel>
      </div>

      <div className="inicio-center">
        <Planet animar={motion} moonlight={state.visible?.system === 'hp'} />
        <div className="hero">
          <div className="hero-tag">EXPLORA · CREA · CONTROLA</div>
          <Clock big />
          <div className="hero-date">{formatDate(now)}</div>
        </div>
      </div>

      <div className="inicio-right">
        <SystemCard host="hp" onOpen={() => go('sistemas')} />
        <SystemCard host="pi" onOpen={() => go('sistemas')} />
        <Panel title="Conexión" className="conn-panel">
          <ul className="conn-list">
            <li><StatusDot ok={conn === 'conectado'} sim={state.source === 'sim'} /> Orbit OS <span>{state.source === 'sim' ? 'Simulador' : etiquetaConexion(conn)}</span></li>
            <li><StatusDot ok={state.nodes.hp?.connected} sim={state.nodes.hp?.simulated} /> HP <span>{state.nodes.hp?.connected ? 'Conectado' : 'No conectado'}</span></li>
            <li><StatusDot ok={state.nodes.arduino?.connected} sim={state.nodes.arduino?.simulated} /> Controles <span>{state.nodes.arduino?.connected ? 'Arduino Nano' : (state.nodes.arduino?.detail ?? '—')}</span></li>
            <li><StatusDot ok={state.visible?.pairing === 'hecho'} /> Vídeo <span>{state.visible?.pairing === 'hecho' ? 'MSI en la Pi · Moonlight listo' : 'MSI en la Pi · sin emparejar'}</span></li>
          </ul>
        </Panel>
      </div>
    </div>
  );
}
