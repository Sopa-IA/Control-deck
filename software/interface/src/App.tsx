import { useEffect, useRef, useState } from 'react';
import type { Message } from '@shared/ts/protocol';
import { OrbitProvider, useOrbit } from './data/OrbitContext';
import { simulatedParts } from './data/state';
import { etiquetaConexion } from './lib/equipo';
import { ORBIT_VERSION } from './version';
import { Marco } from './components/Marco';
import { Clock, OrbitLogo, SimBadge, StatusDot, useIdleCursor } from './components/ui';
import { ConfirmDialog, OsdHelp, PowerMenu } from './components/Dialogs';
import { route } from './lib/controlRouter';
import { SECTIONS, nextSection, type SectionId } from './sections';
import { Inicio } from './sections/Inicio';
import { Sistemas } from './sections/Sistemas';
import { Hardware } from './sections/Hardware';
import { Controles } from './sections/Controles';
import { Herramientas } from './sections/Herramientas';
import { ArduLab } from './sections/ArduLab';
import { Configuracion } from './sections/Configuracion';

function initialSection(): SectionId {
  const s = new URLSearchParams(window.location.search).get('s');
  return SECTIONS.some((x) => x.id === s) ? (s as SectionId) : 'inicio';
}

function Shell() {
  useIdleCursor();
  const orbit = useOrbit();
  const { state, simulated } = orbit;
  const [section, setSection] = useState<SectionId>(initialSection);
  const [osd, setOsd] = useState(false);
  const [power, setPower] = useState(false);
  const [brightness, setBrightness] = useState(100);
  const prevPots = useRef<Record<string, number>>({});
  const mappingRef = useRef(state.mapping);
  mappingRef.current = state.mapping;

  useEffect(() => orbit.onMessage((m: Message) => {
    if (m.type !== 'action_result') return;
    const p = (m as Message<'action_result'>).payload;
    if (p.action === 'pi.restart_ui' && p.ok && !p.simulated && !p.dry_run) window.location.reload();
  }), [orbit]);

  // Controles físicos -> órdenes de interfaz (las del HP y de la Pi las resuelve el controlador)
  useEffect(() => orbit.onMessage((m: Message) => {
    if (m.type !== 'control_event') return;
    const ev = (m as Message<'control_event'>).payload;
    const cmd = route(ev, mappingRef.current, prevPots.current[ev.control]);
    if (ev.kind === 'pot' && ev.value !== undefined) prevPots.current[ev.control] = ev.value;
    if (!cmd) return;
    switch (cmd.cmd) {
      case 'next_section': setSection((s) => nextSection(s)); break;
      case 'back': setOsd(false); setPower(false); setSection('inicio'); break;
      case 'power_menu': setPower(true); break;
      case 'switch_help': setOsd(true); break;
      case 'brightness': setBrightness(cmd.pct); break;
      case 'select': (document.activeElement as HTMLElement | null)?.click(); break;
      case 'scroll': {
        const items = Array.from(document.querySelectorAll<HTMLElement>('main button:not([disabled]), main select, main input'));
        if (!items.length) break;
        const i = Math.max(0, items.indexOf(document.activeElement as HTMLElement));
        items[(i + cmd.delta + items.length * 10) % items.length].focus();
        break;
      }
      default: break;
    }
  }), [orbit]);

  const current = SECTIONS.find((s) => s.id === section);
  const title = current?.label ?? '';
  const forzarMarco = new URLSearchParams(window.location.search).get('vista') === 'integrado';
  const hpAbierto = state.visible?.system === 'hp';
  if (forzarMarco || hpAbierto) return <Marco />;
  return (
    <div className="app" data-section={section}>
      <aside className="sidebar">
        <div className="brand">
          <OrbitLogo />
          <div className="brand-t"><b>ORBIT TERMINAL</b><span>DOS MUNDOS, UN TERMINAL</span></div>
        </div>
        <nav aria-label="Secciones">
          {SECTIONS.map((s) => (
            <button key={s.id} className={`nav-item ${s.id === section ? 'active' : ''} ${s.literal ? 'as-written' : ''}`} onClick={() => setSection(s.id)} aria-current={s.id === section ? 'page' : undefined}>
              <span className="nav-icon">{s.icon}</span>{s.label}
            </button>
          ))}
        </nav>
        <div className="sidebar-foot">
          <div><StatusDot ok={state.conn === 'conectado'} sim={state.source === 'sim'} /> {state.source === 'sim' ? 'Simulador' : etiquetaConexion(state.conn)}</div>
          <div className="muted">v{ORBIT_VERSION}</div>
        </div>
      </aside>
      <div className="main-col">
        <header className="topbar">
          <h1 className={current?.literal ? 'as-written' : undefined}>{title}</h1>
          <div className="topbar-right">
            {simulated && <SimBadge parts={simulatedParts(state)} />}
            {state.busyAction && !state.pendingConfirm && <div className="busy-badge" role="status">En curso</div>}
            {state.source === 'ws' && state.conn !== 'conectado' && <div className="offline-badge">Sin conexión con el equipo</div>}
            <span className="tb-icons" aria-hidden>
              <span title="Red">◠</span><span title="Controles">◎</span>
            </span>
            <Clock />
          </div>
        </header>
        <main className="content">
          {section === 'inicio' && <Inicio go={setSection} openPower={() => setPower(true)} />}
          {section === 'sistemas' && <Sistemas openOsd={() => setOsd(true)} />}
          {section === 'hardware' && <Hardware />}
          {section === 'controles' && <Controles />}
          {section === 'ardulab' && <ArduLab />}
          {section === 'herramientas' && <Herramientas />}
          {section === 'configuracion' && <Configuracion brightness={brightness} setBrightness={setBrightness} />}
        </main>
        <footer className="footbar"><span>ORBIT TERMINAL</span></footer>
      </div>
      {osd && <OsdHelp onClose={() => setOsd(false)} />}
      {power && <PowerMenu onClose={() => setPower(false)} />}
      <ConfirmDialog />
      <div className="dimmer" style={{ opacity: (100 - brightness) / 100 * 0.8 }} aria-hidden />
    </div>
  );
}

export { Shell };
export default function App() {
  const params = new URLSearchParams(window.location.search);
  return (
    <OrbitProvider animate={params.get('animate') !== '0'}>
      <Shell />
    </OrbitProvider>
  );
}
