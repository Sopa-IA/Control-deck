// Abstracción de fuente de datos: simulador local o backend real (orbitd por WebSocket).
import type { Message } from '@shared/ts/protocol';
import type { ConnStatus, SourceKind } from './state';

export interface DataSource {
  readonly kind: SourceKind;
  connect(onMessage: (m: Message) => void, onStatus: (s: ConnStatus, detail?: string) => void): void;
  send(m: Message): void;
  close(): void;
}

/** Elige fuente: ?source=sim|ws manda; si no, guardada en localStorage; si no, sim en `vite dev` y ws servido por orbitd. */
export function chooseSource(search: string, stored: string | null, isDev: boolean): SourceKind {
  const q = new URLSearchParams(search).get('source');
  if (q === 'sim' || q === 'ws') return q;
  if (stored === 'sim' || stored === 'ws') return stored;
  return isDev ? 'sim' : 'ws';
}

export function defaultWsUrl(loc: { protocol: string; host: string }): string {
  return `${loc.protocol === 'https:' ? 'wss' : 'ws'}://${loc.host}/ws`;
}
