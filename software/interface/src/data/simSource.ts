// Fuente SIMULADA: imita a orbitd dentro del navegador. TODO lo que emite va marcado simulated:true.
import { ACTIONS, makeMessage, type ControlEventPayload, type MappingPayload, type Message, type TelemetryPayload } from '@shared/ts/protocol';
import defaultControls from '@shared/controls.default.json';
import marco from '@shared/marco.json';
import type { DataSource } from './source';
import type { ConnStatus } from './state';

export function simTelemetry(host: 'hp' | 'pi', t: number): TelemetryPayload {
  const s = t / 1000;
  // La fase es el segundo dentro de la hora. Sumar `s` (la época unix) pintaba «20748 d».
  const fase = s % 3600;
  if (host === 'hp') {
    return {
      host, simulated: true, hostname: 'hp-simulado', model: 'HP (simulado · modelo PENDIENTE)', os: 'simulado',
      cpu_pct: round(18 + 12 * Math.sin(s / 7) + 6 * Math.sin(s / 1.7)), mem_pct: round(41 + 4 * Math.sin(s / 30)),
      mem_used_mb: round(8192 * (41 + 4 * Math.sin(s / 30)) / 100), mem_total_mb: 8192, disk_pct: 63,
      temp_c: round(44 + 6 * Math.sin(s / 11)), uptime_s: Math.round(15_300 + fase), net_up_kbps: round(Math.abs(120 * Math.sin(s / 5))),
      net_down_kbps: round(Math.abs(900 * Math.sin(s / 3))),
    };
  }
  return {
    host, simulated: true, hostname: 'pi-simulada', model: 'Raspberry Pi (simulada · modelo PENDIENTE)', os: 'simulado',
    cpu_pct: round(4 + 3 * Math.sin(s / 5)), mem_pct: round(19 + 2 * Math.sin(s / 20)), mem_used_mb: round(780 + 60 * Math.sin(s / 20)),
    mem_total_mb: 4096, disk_pct: 22, temp_c: round(47 + 3 * Math.sin(s / 9)), uptime_s: Math.round(7_200 + fase),
  };
}
const round = (v: number) => Math.round(Math.max(0, v) * 10) / 10;

export class SimDataSource implements DataSource {
  readonly kind = 'sim' as const;
  private timers: ReturnType<typeof setInterval>[] = [];
  private onMessage: (m: Message) => void = () => {};
  private pots = Object.keys(defaultControls.pots).sort().map((_, i) => [512, 300, 800][i] ?? 512);
  private mapping: MappingPayload = { version: 1, pots: { ...defaultControls.pots }, buttons: { ...defaultControls.buttons } };
  private pending = new Map<string, { action: string; challenge: string; expires: number }>();
  private visibleSystem: 'hp' | 'pi' = 'pi';
  private layout: 'integrado' | 'completa' = 'integrado';
  private sidebar: 'cerrado' | 'abierto' = 'cerrado';
  constructor(private opts: { animateControls?: boolean; seed?: number } = {}) {}

  private emit<T extends Message['type']>(type: T, payload: Message<T>['payload'], replyTo?: string) {
    this.onMessage(makeMessage(type, 'pi', payload as never, replyTo) as Message);
  }

  connect(onMessage: (m: Message) => void, onStatus: (s: ConnStatus, detail?: string) => void): void {
    this.onMessage = onMessage;
    onStatus('conectado', 'simulador local del navegador');
    this.emit('welcome', { session: 'sim', server_time: Date.now(), heartbeat_s: 5, mode: 'sim' });
    const state = () => {
      const side = this.sidebar === 'abierto' ? marco.sidebar_px : 0;
      this.emit('state', {
        mode: 'sim', video_input: 'pi',
        hp: { connected: true, simulated: true, last_seen: Date.now(), detail: 'HP simulado' },
        pi: { connected: true, simulated: true, last_seen: Date.now(), detail: 'Pi simulada' },
        arduino: { connected: true, simulated: true, last_seen: Date.now(), detail: `orbit-controls-sim v1: ${Object.keys(this.mapping.pots).length} pots, ${Object.keys(this.mapping.buttons).length} botones` },
        visible: {
          system: this.visibleSystem, mode: 'remoto', pairing: 'pendiente', layout: this.layout, sidebar: this.sidebar,
          hole: { x: side, y: marco.bar_px, w: marco.screen_w - side, h: marco.screen_h - marco.bar_px },
          detail: 'Moonlight no está emparejado con Sunshine en el HP (10.0.0.1).',
        },
      });
    };
    state();
    this.emit('mapping', this.mapping);
    const tick = () => { const t = Date.now(); this.emit('telemetry', simTelemetry('hp', t)); this.emit('telemetry', simTelemetry('pi', t)); };
    tick();
    this.pots.forEach((v, i) => this.control({ control: `P${i + 1}`, kind: 'pot', value: v, simulated: true }));
    this.timers.push(setInterval(tick, 2000), setInterval(state, 5000));
    if (this.opts.animateControls !== false) {
      this.timers.push(setInterval(() => {
        const i = Math.floor(Math.random() * this.pots.length);
        this.pots[i] = Math.max(0, Math.min(1023, this.pots[i] + Math.round((Math.random() - 0.5) * 120)));
        this.control({ control: `P${i + 1}`, kind: 'pot', value: this.pots[i], simulated: true });
      }, 1500));
    }
  }

  private control(p: ControlEventPayload) { this.emit('control_event', p); }

  /** Inyecta un evento de control simulado (botones de prueba en la sección Controles). */
  inject(p: Omit<ControlEventPayload, 'simulated'>) { this.control({ ...p, simulated: true }); }

  send(m: Message): void {
    if (m.type === 'action_request') {
      const p = (m as Message<'action_request'>).payload;
      const spec = ACTIONS[p.action];
      if (!spec) { this.emit('error', { code: 'not_allowed', message: `acción no permitida: ${p.action}` }, m.id); return; }
      if (p.action === 'pi.switch_visible') this.visibleSystem = this.visibleSystem === 'pi' ? 'hp' : 'pi';
      if (p.action === 'pi.stream_layout') {
        const layout = (p.params as { layout?: string } | undefined)?.layout;
        if (layout === 'integrado' || layout === 'completa') this.layout = layout;
      }
      if (p.action === 'pi.marco_sidebar') {
        const sidebar = (p.params as { sidebar?: string } | undefined)?.sidebar;
        if (sidebar === 'abierto' || sidebar === 'cerrado') this.sidebar = sidebar;
      }
      if (spec.confirm) {
        const request_id = Math.random().toString(36).slice(2, 10);
        const challenge = Math.random().toString(16).slice(2, 18).padEnd(16, '0');
        this.pending.set(request_id, { action: p.action, challenge, expires: Date.now() + 15000 });
        this.emit('confirm_required', { request_id, action: p.action, challenge, expires_in_s: 15 }, m.id);
        return;
      }
      this.emitVisible();
      this.result(p.action, m.id);
    } else if (m.type === 'action_confirm') {
      const p = (m as Message<'action_confirm'>).payload;
      const pend = this.pending.get(p.request_id);
      this.pending.delete(p.request_id);
      if (!pend || pend.challenge !== p.challenge || Date.now() > pend.expires) {
        this.emit('error', { code: 'confirm_expired', message: 'confirmación caducada o incorrecta' }, m.id);
        return;
      }
      this.result(pend.action, m.id);
    } else if (m.type === 'mapping_set') {
      this.mapping = (m as Message<'mapping_set'>).payload;
      this.emit('mapping', this.mapping);
    }
  }

  private emitVisible() {
    const side = this.sidebar === 'abierto' ? marco.sidebar_px : 0;
    this.emit('state', {
      mode: 'sim', video_input: 'pi',
      hp: { connected: true, simulated: true, last_seen: Date.now(), detail: 'HP simulado' },
      pi: { connected: true, simulated: true, last_seen: Date.now(), detail: 'Pi simulada' },
      arduino: { connected: true, simulated: true, last_seen: Date.now(), detail: 'simulado' },
      visible: {
        system: this.visibleSystem, mode: 'remoto', pairing: 'pendiente', layout: this.layout, sidebar: this.sidebar,
        hole: { x: side, y: marco.bar_px, w: marco.screen_w - side, h: marco.screen_h - marco.bar_px },
        detail: 'Moonlight no está emparejado con Sunshine en el HP (10.0.0.1).',
      },
    });
  }

  private result(action: string, replyTo: string) {
    const label = ACTIONS[action]?.label ?? action;
    let message = `SIMULADO: no se ha ejecutado «${label}».`;
    if (action === 'pi.switch_visible') {
      message = this.visibleSystem === 'hp'
        ? 'SIMULADO: Moonlight no se ha abierto. El emparejamiento con Sunshine en 10.0.0.1 no está hecho.'
        : 'SIMULADO: Moonlight cerrado. Se vuelve a Orbit OS.';
    }
    this.emit('action_result', { action, ok: true, dry_run: true, simulated: true, message }, replyTo);
  }

  close(): void { this.timers.forEach(clearInterval); this.timers = []; }
}
