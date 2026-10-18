// Formateadores de presentación (es-ES). Funciones puras: se prueban en format.test.ts.

const pad = (n: number) => String(n).padStart(2, '0');

export function formatClock(d: Date, withSeconds = false): string {
  return withSeconds ? `${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}` : `${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

const DIAS = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
const MESES = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

export function formatDate(d: Date): string {
  return `${DIAS[d.getDay()]}, ${d.getDate()} ${MESES[d.getMonth()]} ${d.getFullYear()}`;
}

export function formatUptime(s: number | undefined): string {
  if (s === undefined || !Number.isFinite(s) || s < 0) return '—';
  const d = Math.floor(s / 86400);
  const h = Math.floor((s % 86400) / 3600);
  const m = Math.floor((s % 3600) / 60);
  if (d > 0) return `${d} d ${h} h`;
  if (h > 0) return `${h} h ${m} min`;
  return `${m} min`;
}

export function clamp(v: number, lo: number, hi: number): number {
  return Math.min(hi, Math.max(lo, v));
}

export function formatPct(v: number | undefined | null): string {
  return v === undefined || v === null || !Number.isFinite(v) ? '—' : `${Math.round(clamp(v, 0, 100))}%`;
}

export function formatTemp(v: number | undefined | null): string {
  return v === undefined || v === null || !Number.isFinite(v) ? '—' : `${Math.round(v)} °C`;
}

export function formatMb(used?: number, total?: number): string {
  if (used === undefined || total === undefined) return '—';
  const g = (x: number) => (x / 1024).toFixed(1);
  return `${g(used)} / ${g(total)} GB`;
}

/** Hace cuánto (texto corto) desde un timestamp en ms. */
export function ago(ts: number | null | undefined, now = Date.now()): string {
  if (!ts) return 'nunca';
  const s = Math.max(0, Math.round((now - ts) / 1000));
  if (s < 5) return 'ahora';
  if (s < 60) return `hace ${s} s`;
  if (s < 3600) return `hace ${Math.floor(s / 60)} min`;
  return `hace ${Math.floor(s / 3600)} h`;
}

/** Valor de potenciómetro 0..1023 -> porcentaje 0..100 */
export const potToPct = (v: number) => Math.round((clamp(v, 0, 1023) * 100) / 1023);
