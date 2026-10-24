import type { ConnStatus, OrbitState } from '../data/state';

export function etiquetaConexion(conn: ConnStatus): string {
  if (conn === 'conectado') return 'Conectado';
  if (conn === 'conectando') return 'Conectando';
  return 'Sin conexión';
}

/** null si se puede mandar una acción a ese equipo. En el simulador no bloquea. */
export function motivoFuera(state: OrbitState, host: 'hp' | 'pi'): string | null {
  if (state.source === 'sim') return null;
  if (state.conn !== 'conectado') return 'Sin conexión.';
  if (!state.nodes[host]?.connected) {
    return host === 'hp' ? 'El HP no está conectado.' : 'La Raspberry Pi no está conectada.';
  }
  return null;
}
