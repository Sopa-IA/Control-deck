// Estado de la interfaz y reductor puro de mensajes del protocolo.
import type {
  ActionResultPayload, ConfirmRequiredPayload, ControlEventPayload, MappingPayload, Message, Mode, NodeState, StatePayload, TelemetryPayload,
} from '@shared/ts/protocol';

export type SourceKind = 'sim' | 'ws';
export type ConnStatus = 'conectando' | 'conectado' | 'desconectado';

export interface ControlReading extends ControlEventPayload { ts: number }
export interface LogEntry { ts: number; level: 'info' | 'ok' | 'warn' | 'error'; text: string; simulated?: boolean; count?: number }

export interface OrbitState {
  source: SourceKind;
  conn: ConnStatus;
  connDetail?: string;
  mode: Mode | null;
  nodes: { hp: NodeState | null; pi: NodeState | null; arduino: NodeState | null };
  telemetry: { hp?: TelemetryPayload & { ts: number }; pi?: TelemetryPayload & { ts: number } };
  controls: Record<string, ControlReading>;
  mapping: MappingPayload | null;
  pendingConfirm: ConfirmRequiredPayload | null;
  /** Sistema visible (remoto = Moonlight en la Pi; ddc = entrada de la MSI por DDC/CI). */
  visible: StatePayload['visible'] | null;
  log: LogEntry[];
}

export const initialState = (source: SourceKind): OrbitState => ({
  source, conn: 'conectando', mode: null,
  nodes: { hp: null, pi: null, arduino: null },
  telemetry: {}, controls: {}, mapping: null, pendingConfirm: null, visible: null, log: [],
});

export type OrbitEvent =
  | { kind: 'message'; msg: Message; now?: number }
  | { kind: 'conn'; conn: ConnStatus; detail?: string }
  | { kind: 'log'; entry: LogEntry }
  | { kind: 'clear_confirm' }
  | { kind: 'reset'; source: SourceKind };

const MAX_LOG = 60;
export function pushLog(log: LogEntry[], e: LogEntry): LogEntry[] {
  const head = log[0];
  if (head && head.text === e.text && head.level === e.level && !!head.simulated === !!e.simulated) {
    return [{ ...head, ts: e.ts, count: (head.count ?? 1) + 1 }, ...log.slice(1)];
  }
  return [e, ...log].slice(0, MAX_LOG);
}

export function reduce(s: OrbitState, ev: OrbitEvent): OrbitState {
  switch (ev.kind) {
    case 'reset': return initialState(ev.source);
    case 'conn': return { ...s, conn: ev.conn, connDetail: ev.detail };
    case 'log': return { ...s, log: pushLog(s.log, ev.entry) };
    case 'clear_confirm': return { ...s, pendingConfirm: null };
    case 'message': {
      const m = ev.msg;
      const now = ev.now ?? Date.now();
      switch (m.type) {
        case 'welcome': return { ...s, mode: (m as Message<'welcome'>).payload.mode };
        case 'state': {
          const p = (m as Message<'state'>).payload;
          return { ...s, mode: p.mode, nodes: { hp: p.hp, pi: p.pi, arduino: p.arduino }, visible: p.visible ?? s.visible };
        }
        case 'telemetry': {
          const p = (m as Message<'telemetry'>).payload;
          return { ...s, telemetry: { ...s.telemetry, [p.host]: { ...p, ts: now } } };
        }
        case 'control_event': {
          const p = (m as Message<'control_event'>).payload;
          const prev = s.controls[p.control];
          const merged: ControlReading = { ...prev, ...p, ts: now };
          if (p.kind === 'button' && p.event === 'long' && prev) merged.event = 'long';
          return { ...s, controls: { ...s.controls, [p.control]: merged } };
        }
        case 'mapping': return { ...s, mapping: (m as Message<'mapping'>).payload };
        case 'confirm_required': return { ...s, pendingConfirm: (m as Message<'confirm_required'>).payload };
        case 'action_result': {
          const p = m.payload as ActionResultPayload;
          const tag = p.simulated ? 'SIMULADO · ' : p.dry_run ? 'DRY-RUN · ' : '';
          return { ...s, log: pushLog(s.log, { ts: now, level: p.ok ? 'ok' : 'warn', text: `${tag}${p.action}: ${p.message}`, simulated: p.simulated }) };
        }
        case 'error': {
          const p = (m as Message<'error'>).payload;
          return { ...s, log: pushLog(s.log, { ts: now, level: 'error', text: `${p.code}: ${p.message}` }) };
        }
        default: return s;
      }
    }
  }
}

/**
 * ¿Hay datos simulados a la vista? Regla: la fuente es el simulador del navegador, o orbitd declara
 * modo sim/mixto, o cualquier nodo/telemetría/control llega marcado como simulado.
 * Si devuelve true, la interfaz DEBE mostrar el distintivo «MODO SIMULACIÓN».
 */
export function isSimulated(s: OrbitState): boolean {
  if (s.source === 'sim') return true;
  if (s.mode === 'sim' || s.mode === 'mixto') return true;
  if (Object.values(s.nodes).some((n) => n?.simulated)) return true;
  if (Object.values(s.telemetry).some((t) => t?.simulated)) return true;
  return Object.values(s.controls).some((c) => c.simulated);
}

/** Lista de qué partes están simuladas (para el tooltip del distintivo). */
export function simulatedParts(s: OrbitState): string[] {
  const out: string[] = [];
  if (s.source === 'sim') out.push('fuente de datos: simulador del navegador');
  if (s.nodes.hp?.simulated || s.telemetry.hp?.simulated) out.push('HP');
  if (s.nodes.pi?.simulated || s.telemetry.pi?.simulated) out.push('Raspberry Pi');
  if (s.nodes.arduino?.simulated || Object.values(s.controls).some((c) => c.simulated)) out.push('controles');
  return out;
}

export type { MappingPayload };
