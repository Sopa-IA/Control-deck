// Orbit Terminal · tipos TypeScript del protocolo v1.
// Fuente de verdad: ../schemas/protocol.schema.json y ../actions.json (mantener en sincronía;
// el test de la interfaz `protocol.test.ts` comprueba la lista de tipos contra el esquema).
import actionsJson from '../actions.json';

export const PROTOCOL_VERSION = 1 as const;
export type Src = 'ui' | 'pi' | 'hp';
export type Mode = 'sim' | 'real' | 'mixto';

export const MESSAGE_TYPES = [
  'hello', 'welcome', 'error', 'ping', 'pong', 'state', 'telemetry', 'control_event',
  'action_request', 'confirm_required', 'action_confirm', 'action', 'action_result',
  'mapping', 'mapping_set',
] as const;
export type MessageType = (typeof MESSAGE_TYPES)[number];

export interface NodeState { connected: boolean; simulated: boolean; last_seen?: number | null; detail?: string }
export interface StatePayload { mode: Mode; hp: NodeState; pi: NodeState; arduino: NodeState; video_input?: 'hp' | 'pi' | 'desconocida' }
export interface TelemetryPayload {
  host: 'hp' | 'pi'; simulated: boolean; hostname?: string; model?: string; os?: string;
  cpu_pct: number; mem_pct: number; mem_used_mb?: number; mem_total_mb?: number; disk_pct?: number;
  temp_c?: number | null; uptime_s?: number; net_up_kbps?: number; net_down_kbps?: number;
}
export interface ControlEventPayload { control: string; kind: 'pot' | 'button'; value?: number; event?: 'press' | 'release' | 'long'; simulated: boolean }
export interface ActionRequestPayload { action: string; params?: Record<string, unknown>; dry_run?: boolean }
export interface ConfirmRequiredPayload { request_id: string; action: string; challenge: string; expires_in_s: number }
export interface ActionConfirmPayload { request_id: string; challenge: string }
export interface ActionResultPayload { action: string; ok: boolean; dry_run: boolean; simulated?: boolean; message: string }
export interface MappingPayload { version?: number; pots: Record<string, string>; buttons: Record<string, string> }
export interface WelcomePayload { session: string; server_time: number; heartbeat_s: number; mode: Mode }
export interface ErrorPayload { code: string; message: string }
export interface HelloPayload { role: 'ui' | 'hp-agent'; client: string; version: string; token?: string }

export interface PayloadMap {
  hello: HelloPayload; welcome: WelcomePayload; error: ErrorPayload; ping: { seq: number }; pong: { seq: number };
  state: StatePayload; telemetry: TelemetryPayload; control_event: ControlEventPayload;
  action_request: ActionRequestPayload; confirm_required: ConfirmRequiredPayload; action_confirm: ActionConfirmPayload;
  action: ActionRequestPayload; action_result: ActionResultPayload; mapping: MappingPayload; mapping_set: MappingPayload;
}

export interface Message<T extends MessageType = MessageType> {
  v: 1; type: T; id: string; ts: number; src: Src; reply_to?: string; payload: PayloadMap[T];
}

export interface ActionSpec { target: 'hp' | 'pi'; label: string; params: Record<string, unknown>; confirm: boolean; destructive: boolean }
export interface ControlFunctionSpec { kinds: ('pot' | 'button')[]; label: string }

export const ACTIONS = actionsJson.actions as unknown as Record<string, ActionSpec>;
export const CONTROL_FUNCTIONS = Object.fromEntries(
  Object.entries(actionsJson.control_functions).filter(([k]) => !k.startsWith('$')),
) as unknown as Record<string, ControlFunctionSpec>;

let counter = 0;
export function makeMessage<T extends MessageType>(type: T, src: Src, payload: PayloadMap[T], replyTo?: string): Message<T> {
  counter = (counter + 1) % 1_000_000;
  const id = `${Date.now().toString(36)}${counter.toString(36)}${Math.random().toString(36).slice(2, 6)}`.slice(0, 32);
  const m: Message<T> = { v: PROTOCOL_VERSION, type, id, ts: Date.now(), src, payload };
  if (replyTo) m.reply_to = replyTo;
  return m;
}

export function isMessage(x: unknown): x is Message {
  if (typeof x !== 'object' || x === null) return false;
  const m = x as Record<string, unknown>;
  return m.v === 1 && typeof m.type === 'string' && (MESSAGE_TYPES as readonly string[]).includes(m.type)
    && typeof m.id === 'string' && typeof m.ts === 'number' && typeof m.payload === 'object' && m.payload !== null;
}

/** Comprueba en cliente que una acción está en la lista blanca (orbitd vuelve a comprobarlo siempre). */
export function isAllowedAction(action: string): boolean {
  return Object.prototype.hasOwnProperty.call(ACTIONS, action);
}

/** ¿Se puede asignar `fn` a un control de tipo `kind`? */
export function canAssign(fn: string, kind: 'pot' | 'button'): boolean {
  const spec = CONTROL_FUNCTIONS[fn];
  return !!spec && spec.kinds.includes(kind);
}
