import { useOrbit } from '../data/OrbitContext';
import { Chip, Panel, SimTag, StatusDot } from '../components/ui';
import { INVENTARIO } from '../lib/hardware';
import { ago } from '../lib/format';

export function Hardware() {
  const { state } = useOrbit();
  const live: { id: string; label: string; n: typeof state.nodes.hp }[] = [
    { id: 'hp', label: 'Enlace hp-agent', n: state.nodes.hp },
    { id: 'pi', label: 'orbitd (Pi)', n: state.nodes.pi },
    { id: 'arduino', label: 'Arduino Micro', n: state.nodes.arduino },
  ];
  const piModel = state.telemetry.pi?.model;
  return (
    <div className="hardware">
      <Panel title="Estado en vivo" className="hw-live">
        <div className="live-grid">
          {live.map(({ id, label, n }) => (
            <div key={id} className={`live-card ${n?.connected ? 'on' : 'off'}`}>
              <div className="live-head"><StatusDot ok={n?.connected} sim={n?.simulated} /><b>{label}</b><SimTag show={n?.simulated} /></div>
              <div className="live-detail">{n?.detail ?? 'sin datos'}</div>
              <div className="muted">{n?.connected ? `visto ${ago(n.last_seen ?? null)}` : 'desconectado'}</div>
            </div>
          ))}
          <div className="live-card">
            <div className="live-head"><StatusDot ok={!!piModel} sim={state.telemetry.pi?.simulated} /><b>Placa detectada</b><SimTag show={state.telemetry.pi?.simulated} /></div>
            <div className="live-detail">{piModel ?? '—'}</div>
            <div className="muted">leído de /proc/device-tree/model</div>
          </div>
        </div>
      </Panel>
      <Panel title="Inventario del prototipo" right={<span className="muted">solo piezas que ya tiene Miguel</span>} className="hw-inv">
        <table className="inv">
          <thead><tr><th>Componente</th><th>Detalle</th><th>Estado</th><th>Nota</th></tr></thead>
          <tbody>
            {INVENTARIO.map((p) => (
              <tr key={p.id}><td><b>{p.nombre}</b></td><td>{p.detalle}</td><td><Chip estado={p.estado} /></td><td className="muted">{p.nota}</td></tr>
            ))}
          </tbody>
        </table>
      </Panel>
    </div>
  );
}
