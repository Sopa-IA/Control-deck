// Fuente REAL: conecta con orbitd. No inventa datos: si no hay conexión, la interfaz lo muestra.
import { isMessage, makeMessage, type Message } from '@shared/ts/protocol';
import type { DataSource } from './source';
import type { ConnStatus } from './state';

export class WsDataSource implements DataSource {
  readonly kind = 'ws' as const;
  private ws: WebSocket | null = null;
  private closed = false;
  private retry = 1000;
  private timer: ReturnType<typeof setTimeout> | null = null;
  constructor(private url: string, private token?: string) {}

  connect(onMessage: (m: Message) => void, onStatus: (s: ConnStatus, detail?: string) => void): void {
    this.closed = false;
    const open = () => {
      onStatus('conectando', this.url);
      let ws: WebSocket;
      try { ws = new WebSocket(this.url); } catch (e) { onStatus('desconectado', String(e)); return; }
      this.ws = ws;
      ws.onopen = () => {
        const hello = makeMessage('hello', 'ui', { role: 'ui', client: 'orbit-interface', version: '0.1.0', ...(this.token ? { token: this.token } : {}) });
        ws.send(JSON.stringify(hello));
      };
      ws.onmessage = (ev) => {
        let m: unknown;
        try { m = JSON.parse(String(ev.data)); } catch { return; }
        if (!isMessage(m)) return;
        if (m.type === 'welcome') { this.retry = 1000; onStatus('conectado', this.url); }
        if (m.type === 'ping') { ws.send(JSON.stringify(makeMessage('pong', 'ui', { seq: (m as Message<'ping'>).payload.seq }, m.id))); return; }
        onMessage(m);
      };
      ws.onclose = () => {
        this.ws = null;
        if (this.closed) return;
        onStatus('desconectado', `sin conexión con orbitd (${this.url}); reintento en ${Math.round(this.retry / 1000)} s`);
        this.timer = setTimeout(open, this.retry);
        this.retry = Math.min(this.retry * 2, 15000);
      };
    };
    open();
  }

  send(m: Message): void {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) this.ws.send(JSON.stringify(m));
  }

  close(): void {
    this.closed = true;
    if (this.timer) clearTimeout(this.timer);
    this.ws?.close();
  }
}
