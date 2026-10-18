import { useEffect, useRef, useState } from 'react';
import type { Message } from '@shared/ts/protocol';
import { OrbitProvider, useOrbit } from './data/OrbitContext';
import { simulatedParts } from './data/state';
import { Clock, OrbitLogo, SimBadge, StatusDot } from './components/ui';
import { ConfirmDialog, OsdHelp, PowerMenu } from './components/Dialogs';
import { route } from './lib/controlRouter';
import { SECTIONS, nextSection, type SectionId } from './sections';
import { Inicio } from './sections/Inicio';
import { Sistemas } from './sections/Sistemas';
import { Hardware } from './sections/Hardware';
import { Controles } from './sections/Controles';
import { Herramientas } from './sections/Herramientas';
import { Configuracion } from './sections/Configuracion';

function initialSection(): SectionId {
  const s = new URLSearchParams(window.location.search).get('s');
  return SECTIONS.some((x) => x.id === s) ? (s as SectionId) : 'inicio';
}

function Shell() {
  const orbit = useOrbit();
  const { state, simulated } = orbit;
  const [section, setSection] = useState<SectionId>(initialSection);
  const [osd, setOsd] = useState(false);
  const [power, setPower] = useState(false);
  const [brightness, setBrightness] = useState(100);
  const prevPots = useRef<Record<string, number>>({});
  const mappingRef = useRef(state.mapping);
  mappingRef.current = state.mapping;

  // Controles físicos -> órdenes de interfaz (las hp.* las resuelve orbitd)
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

  const title = SECTIONS.find((s) => s.id === section)?.label ?? '';
  return (
    <div className="app" data-section={section}>
      <aside className="sidebar">
        <div className="brand">
          <OrbitLogo />
          <div className="brand-t"><b>ORBIT TERMINAL</b><span>DOS MUNDOS, UN TERMINAL</span></div>
        </div>
        <nav aria-label="Secciones">
          {SECTIONS.map((s) => (
            <button key={s.id} className={`nav-item ${s.id === section ? 'active' : ''}`} onClick={() => setSection(s.id)} aria-current={s.id === section ? 'page' : undefined}>
              <span className="nav-icon">{s.icon}</span>{s.label}
            </button>
          ))}
        </nav>
        <div className="sidebar-foot">
          <div><StatusDot ok={state.conn === 'conectado'} sim={state.source === 'sim'} /> {state.source === 'sim' ? 'Simulador local' : `orbitd: ${state.conn}`}</div>
          <div className="muted">v0.1.0 · prototipo</div>
        </div>
      </aside>
      <div className="main-col">
        <header className="topbar">
          <h1>{title}</h1>
          <div className="topbar-right">
            {simulated && <SimBadge parts={simulatedParts(state)} />}
            {state.source === 'ws' && state.conn !== 'conectado' && <div className="offline-badge">SIN CONEXIÓN CON ORBITD</div>}
            <span className="tb-icons" aria-hidden>
              <span title="Red">◠</span><span title="Controles">◎</span>
            </span>
            <Clock />
          </div>
        </header>
        <main className="content">
          {section === 'inicio' && <Inicio go={setSection} openOsd={() => setOsd(true)} openPower={() => setPower(true)} />}
          {section === 'sistemas' && <Sistemas openOsd={() => setOsd(true)} />}
          {section === 'hardware' && <Hardware />}
          {section === 'controles' && <Controles />}
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
