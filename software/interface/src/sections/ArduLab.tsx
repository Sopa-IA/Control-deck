import { useEffect, useMemo, useRef, useState } from 'react';
import { cpp } from '@codemirror/lang-cpp';
import { defaultKeymap, history, historyKeymap } from '@codemirror/commands';
import { bracketMatching, defaultHighlightStyle, HighlightStyle, syntaxHighlighting } from '@codemirror/language';
import { type Diagnostic, lintGutter, setDiagnostics } from '@codemirror/lint';
import { EditorState, type Extension } from '@codemirror/state';
import { drawSelection, EditorView, highlightActiveLine, highlightActiveLineGutter, keymap, lineNumbers } from '@codemirror/view';
import { tags } from '@lezer/highlight';
import type { ActionResultPayload } from '@shared/ts/protocol';
import { EJEMPLOS, PLANTILLA } from '../ardu/ejemplos';
import { parseErrors, parsePorts, parseSamples, type Diag, type PortRow } from '../ardu/parse';
import { Panel } from '../components/ui';
import { useOrbit } from '../data/OrbitContext';

const BAUDS = [9600, 19200, 38400, 57600, 115200] as const;
const TOP = ['D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', 'D9', 'D10', 'D11', 'D12', 'D13'];
const BOT: { name: string; kind: string; note?: string }[] = [
  { name: 'A0', kind: '' }, { name: 'A1', kind: '' }, { name: 'A2', kind: '' }, { name: 'A3', kind: '' },
  { name: 'A4', kind: 'oled', note: 'SDA' }, { name: 'A5', kind: 'oled', note: 'SCL' },
  { name: 'A6', kind: '' }, { name: 'A7', kind: '' },
  { name: 'GND', kind: 'gnd' }, { name: 'RST', kind: '' }, { name: '5V', kind: 'pwr' }, { name: '3V3', kind: 'pwr' },
];

const amberSyntax = HighlightStyle.define([
  { tag: tags.keyword, color: '#ffa53a' },
  { tag: tags.comment, color: '#8d867c', fontStyle: 'italic' },
  { tag: tags.string, color: '#ffd59a' },
  { tag: tags.number, color: '#ffcf3a' },
  { tag: [tags.function(tags.variableName), tags.function(tags.propertyName)], color: '#ffe2b8' },
  { tag: tags.typeName, color: '#ffb347' },
]);

const editorTheme = EditorView.theme({
  '&': { height: '100%', backgroundColor: '#0c0b10', color: '#ece6dc' },
  '.cm-scroller': { overflow: 'auto', fontFamily: 'ui-monospace, monospace' },
  '.cm-content': { caretColor: '#ffa53a' },
  '.cm-cursor, .cm-dropCursor': { borderLeftColor: '#ffa53a' },
  '.cm-gutters': { backgroundColor: '#100e14', color: '#8d867c', border: 'none' },
  '.cm-activeLine': { backgroundColor: 'rgba(255, 165, 58, 0.07)' },
  '.cm-activeLineGutter': { backgroundColor: 'transparent', color: '#ffa53a' },
  '&.cm-focused': { outline: '1px solid rgba(255, 165, 58, 0.45)' },
  '.cm-lintRange-error': { background: 'rgba(255, 90, 60, 0.28)' },
}, { dark: true });

function extensions(onChange: { current: (text: string) => void }): Extension[] {
  return [
    lineNumbers(), highlightActiveLine(), highlightActiveLineGutter(), drawSelection(), history(),
    keymap.of([...defaultKeymap, ...historyKeymap]),
    cpp(), syntaxHighlighting(amberSyntax), syntaxHighlighting(defaultHighlightStyle, { fallback: true }),
    bracketMatching(), lintGutter(), EditorView.lineWrapping, editorTheme,
    EditorView.updateListener.of((update) => { if (update.docChanged) onChange.current(update.state.doc.toString()); }),
  ];
}

function toDiags(state: EditorState, errors: Diag[]): Diagnostic[] {
  return errors.map((e) => {
    const n = Math.min(Math.max(1, e.line), state.doc.lines);
    const line = state.doc.line(n);
    const from = Math.min(line.to, line.from + Math.max(0, e.col - 1));
    const to = line.to > from ? Math.min(line.to, from + Math.max(1, 1)) : from;
    return { from, to, severity: 'error', message: e.message };
  });
}

function SketchEditor({ docKey, text, errors, onChange }: { docKey: number; text: string; errors: Diag[]; onChange: (text: string) => void }) {
  const host = useRef<HTMLDivElement>(null);
  const viewRef = useRef<EditorView | null>(null);
  const onChangeRef = useRef(onChange);
  const textRef = useRef(text);
  onChangeRef.current = onChange;
  textRef.current = text;
  const [fallback, setFallback] = useState(false);

  useEffect(() => {
    const parent = host.current;
    if (!parent) return undefined;
    try {
      const view = new EditorView({ parent, state: EditorState.create({ doc: textRef.current, extensions: extensions(onChangeRef) }) });
      viewRef.current = view;
      return () => { view.destroy(); viewRef.current = null; };
    } catch {
      setFallback(true);
      return undefined;
    }
  }, [docKey]);

  useEffect(() => {
    const view = viewRef.current;
    if (!view) return;
    view.dispatch(setDiagnostics(view.state, toDiags(view.state, errors)));
  }, [errors, docKey]);

  if (fallback) {
    return <textarea className="ardu-fallback" value={text} aria-label="Sketch" onChange={(e) => onChange(e.target.value)} />;
  }
  return <div ref={host} className="ardu-cm" />;
}

function remembered(name: string): string | null {
  try { return localStorage.getItem(`orbit.ardu.${name}`); } catch { return null; }
}
function remember(name: string, source: string) {
  try { localStorage.setItem(`orbit.ardu.${name}`, source); } catch { /* el navegador puede bloquearlo */ }
}

function Graph({ series, sim }: { series: Record<string, number[]>; sim: boolean }) {
  const ref = useRef<HTMLCanvasElement>(null);
  const key = JSON.stringify(series);
  useEffect(() => {
    const canvas = ref.current;
    if (!canvas) return;
    const dpr = window.devicePixelRatio || 1;
    const cssW = canvas.clientWidth || 320;
    const cssH = 110;
    canvas.width = Math.floor(cssW * dpr);
    canvas.height = Math.floor(cssH * dpr);
    const ctx = canvas.getContext('2d');
    if (!ctx) return;
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.fillStyle = '#0c0b10';
    ctx.fillRect(0, 0, cssW, cssH);
    const colors = ['#ffa53a', '#ffcf3a', '#e7d3b0', '#ff8a00'];
    Object.values(series).slice(0, 4).forEach((pts, i) => {
      if (pts.length < 2) return;
      ctx.beginPath();
      ctx.strokeStyle = colors[i];
      ctx.lineWidth = 1.6;
      pts.forEach((v, x) => {
        const px = 6 + (x / (pts.length - 1)) * (cssW - 12);
        const py = cssH - 8 - (Math.max(0, Math.min(1023, v)) / 1023) * (cssH - 16);
        if (x === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py);
      });
      ctx.stroke();
    });
  }, [key, series]);
  const names = Object.keys(series).slice(0, 4);
  return (
    <div>
      <canvas ref={ref} className="ardu-graph" role="img" aria-label="Gráfico de valores del monitor" />
      <div className="ardu-legend">{names.length ? names.join(' · ') : 'Sin valores numéricos'}{sim ? ' · SIMULADO' : ''}</div>
    </div>
  );
}

function demoSeries(now: number): Record<string, number[]> {
  const a0: number[] = [];
  const a1: number[] = [];
  for (let i = 0; i < 40; i++) {
    const s = now / 1000 - (39 - i) * 0.15;
    a0.push(Math.round(Math.min(1023, Math.max(0, 512 + 380 * Math.sin(s)))));
    a1.push(Math.round(Math.min(1023, Math.max(0, 280 + 180 * Math.sin(s / 1.7)))));
  }
  return { A0: a0, A1: a1 };
}

export function ArduLab() {
  const orbit = useOrbit();
  const { state, requestAction } = orbit;
  const sim = state.source === 'sim' || state.mode === 'sim' || state.mode === 'mixto';
  const blink = EJEMPLOS[0];
  const [tabs, setTabs] = useState<string[]>(() => EJEMPLOS.map((e) => e.name));
  const [name, setName] = useState(blink.name);
  const [doc, setDoc] = useState(() => remembered(blink.name) ?? blink.source);
  const [gen, setGen] = useState(0);
  const [errors, setErrors] = useState<Diag[]>([]);
  const [out, setOut] = useState('');
  const [busy, setBusy] = useState(false);
  const [baud, setBaud] = useState<(typeof BAUDS)[number]>(9600);
  const [monitor, setMonitor] = useState(false);
  const [lines, setLines] = useState<string[]>([]);
  const [series, setSeries] = useState<Record<string, number[]>>({});
  const [ports, setPorts] = useState<PortRow[]>([]);
  const [portMsg, setPortMsg] = useState('Buscando los puertos…');
  const [tick, setTick] = useState(() => Date.now());
  const docRef = useRef(doc);
  const nameRef = useRef(name);
  const token = useRef(0);
  const pending = useRef({ id: 0, next: '' });
  const sendRef = useRef(requestAction);
  const serialRef = useRef<HTMLPreElement>(null);
  const saveTimer = useRef(0);
  docRef.current = doc;
  nameRef.current = name;
  sendRef.current = requestAction;

  useEffect(() => {
    if (!sim || monitor) return undefined;
    const t = window.setInterval(() => setTick(Date.now()), 400);
    return () => window.clearInterval(t);
  }, [sim, monitor]);

  useEffect(() => orbit.onMessage((m) => {
    if (m.type !== 'action_result') return;
    const p = (m as { payload: ActionResultPayload }).payload;
    if (!p.action.startsWith('pi.ardu_')) return;
    if (p.action === 'pi.ardu_ports') {
      setPortMsg(p.message);
      setPorts(parsePorts(p.output));
      return;
    }
    if (p.action === 'pi.ardu_sketch') {
      if (pending.current.id !== token.current) return;
      const next = pending.current.next;
      pending.current = { id: 0, next: '' };
      if (!p.ok) { setBusy(false); setOut(p.message); return; }
      if (next === 'compile') sendRef.current('pi.ardu_compile', { sketch: nameRef.current });
      else if (next === 'upload') sendRef.current('pi.ardu_upload', { sketch: nameRef.current });
      return;
    }
    if (p.action === 'pi.ardu_compile' || p.action === 'pi.ardu_upload') {
      setBusy(false);
      setOut([p.output, p.message].filter(Boolean).join('\n'));
      setErrors(parseErrors(p.output || ''));
      return;
    }
    if (p.action === 'pi.ardu_monitor') {
      if (!p.ok) { setMonitor(false); setPortMsg(p.message); return; }
      if (!p.output) return;
      const fresh = p.output.split(/\r?\n/).filter(Boolean);
      setLines((prev) => [...prev, ...fresh].slice(-80));
      setSeries((prev) => {
        const next = { ...prev };
        for (const line of fresh) {
          for (const sample of parseSamples(line)) {
            next[sample.name] = [...(next[sample.name] ?? []), sample.value].slice(-40);
          }
        }
        return next;
      });
    }
  }), [orbit]);

  useEffect(() => {
    if (!monitor) return undefined;
    const t = window.setInterval(() => sendRef.current('pi.ardu_monitor', { op: 'leer', baud }), 800);
    return () => window.clearInterval(t);
  }, [monitor, baud]);

  useEffect(() => { if (serialRef.current) serialRef.current.scrollTop = serialRef.current.scrollHeight; }, [lines, tick]);

  const asked = useRef(false);
  useEffect(() => {
    if (state.conn !== 'conectado' || asked.current) return;
    asked.current = true;
    requestAction('pi.ardu_ports');
  }, [state.conn, requestAction]);

  function show(next: string, source: string) {
    setName(next);
    setDoc(source);
    setGen((g) => g + 1);
    setErrors([]);
  }
  function abrir(next: string) {
    const base = EJEMPLOS.find((e) => e.name === next)?.source ?? PLANTILLA;
    show(next, remembered(next) ?? base);
  }
  function guardar(next: '' | 'compile' | 'upload') {
    const id = ++token.current;
    pending.current = { id, next };
    remember(nameRef.current, docRef.current);
    requestAction('pi.ardu_sketch', { op: 'guardar', sketch: nameRef.current, source: docRef.current });
  }
  function onEdit(text: string) {
    setDoc(text);
    window.clearTimeout(saveTimer.current);
    saveTimer.current = window.setTimeout(() => guardar(''), 900);
  }
  function verificar() { setBusy(true); setOut('Guardando y compilando…'); window.clearTimeout(saveTimer.current); guardar('compile'); }
  function subir() { setBusy(true); setOut('Guardando y subiendo solo al Nano de prácticas…'); window.clearTimeout(saveTimer.current); guardar('upload'); }
  function nuevo() {
    let n = 2;
    while (tabs.includes(`Sketch${n}`)) n += 1;
    const sketch = `Sketch${n}`;
    setTabs((t) => [...t, sketch]);
    show(sketch, PLANTILLA);
  }
  function toggleMonitor() {
    if (monitor) {
      setMonitor(false);
      requestAction('pi.ardu_monitor', { op: 'cerrar', baud });
      return;
    }
    setLines([]);
    setSeries({});
    setMonitor(true);
    requestAction('pi.ardu_monitor', { op: 'abrir', baud });
  }

  const practicas = ports.some((p) => p.role === 'practicas' && p.present !== false && !p.blocked);
  const puertosListos = portMsg !== 'Buscando los puertos…';
  const sinPracticas = sim || (puertosListos && !practicas);
  const porqueSubir = sim
    ? 'En simulación no hay placa.'
    : !puertosListos
      ? 'Buscando el Nano de prácticas.'
      : !practicas
        ? 'Falta conectar el Nano de prácticas.'
        : undefined;
  const showDemo = sim && lines.length === 0;
  const drawn = showDemo ? demoSeries(tick) : series;
  const serialText = lines.join('\n');
  const demoText = useMemo(() => {
    const s = demoSeries(tick);
    return `A0 ${s.A0.at(-1)}\nA1 ${s.A1.at(-1)}`;
  }, [tick]);

  return (
    <div className="ardu">
      {sim && <div className="ardu-sim">SIMULADO · no hay placa. Verificar y Subir no graban el Nano de prácticas ni el de mandos.</div>}
      <div className="ardu-tools">
        <div className="ardu-tabs" role="tablist" aria-label="Sketches">
          {tabs.map((tab) => (
            <button key={tab} role="tab" aria-selected={tab === name} className={`ardu-tab ${tab === name ? 'on' : ''}`} onClick={() => abrir(tab)}>{tab}</button>
          ))}
        </div>
        <button className="btn small" onClick={nuevo}>Nuevo</button>
        <button className="btn btn-primary small" disabled={busy} onClick={verificar}>Verificar</button>
        <button className="btn small" disabled={busy || sinPracticas || (!puertosListos && !sim)} title={porqueSubir} onClick={subir}>Subir</button>
        <label className="ardu-baud">Baudios
          <select aria-label="Baudios" value={baud} onChange={(e) => setBaud(Number(e.target.value) as (typeof BAUDS)[number])}>
            {BAUDS.map((b) => <option key={b} value={b}>{b}</option>)}
          </select>
        </label>
        <button className="btn small" disabled={!monitor && (sinPracticas || (!sim && !puertosListos))} title={!monitor ? porqueSubir : undefined} onClick={toggleMonitor}>{monitor ? 'Cerrar monitor' : 'Abrir monitor'}</button>
      </div>
      <div className="ardu-pins" aria-label="Pines del Nano de prácticas, como en el panel trasero">
        {TOP.map((pin) => <span key={pin} className="ardu-pin"><i />{pin}</span>)}
        {BOT.map((pin) => <span key={pin.name} className={`ardu-pin ${pin.kind}`}><i />{pin.name}{pin.note ? <small>{pin.note}</small> : null}</span>)}
      </div>
      <p className="muted ardu-pin-note">Visto desde fuera, como el panel trasero. A4 y A5 son la OLED. No es el orden serigrafiado del Nano. El de mandos no está en este panel.</p>
      <div className="ardu-body">
        <div className="ardu-editor">
          <SketchEditor docKey={gen} text={doc} errors={errors} onChange={onEdit} />
        </div>
        <div className="ardu-side">
          <Panel title="Puertos" className="ardu-card">
            <p className="ardu-block">El Nano de mandos queda bloqueado. Solo se sube al de prácticas, por el puerto USB físico.</p>
            <p className="muted">{portMsg}</p>
            {sinPracticas && <p className="callout">Falta conectar el Nano de prácticas. Verificar sigue compilando. Subir y el monitor esperan a esa placa. El Nano de mandos no se toca.</p>}
            <ul className="ardu-port-list">
              {ports.map((p) => (
                <li key={p.by_path || p.role}>{p.blocked ? 'Bloqueado' : p.role} · {p.by_path || 'sin anotar'}{p.present === false ? ' · no está enchufado' : ''}</li>
              ))}
            </ul>
          </Panel>
          <Panel title="Monitor serie" className="ardu-card" right={showDemo ? <span className="sim-tag">SIM</span> : undefined}>
            <pre ref={serialRef} className="ardu-serial">{showDemo ? demoText : (serialText || 'Abre el monitor. Los números de estas líneas pasan al gráfico.')}</pre>
          </Panel>
          <Panel title="Gráfico" className="ardu-card" right={showDemo ? <span className="sim-tag">SIM</span> : undefined}>
            <Graph series={drawn} sim={showDemo} />
          </Panel>
        </div>
      </div>
      <pre className="ardu-out">{out ? out.split('\n').map((line, i) => <span key={i} className={/error:/i.test(line) ? 'ardu-err' : undefined}>{line}{'\n'}</span>) : 'Pulsa Verificar. La salida del compilador sale aquí y el error queda marcado en la línea.'}</pre>
    </div>
  );
}
