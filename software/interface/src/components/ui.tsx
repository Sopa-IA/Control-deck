import { useEffect, useState, type ReactNode } from 'react';
import { clamp, formatClock } from '../lib/format';
import { ESTADO_LABEL, type Estado } from '../lib/hardware';

/** Oculta el cursor tras unos segundos sin movimiento. Vuelve al mover el ratón. */
export function useIdleCursor(ms = 2000) {
  useEffect(() => {
    let t = 0;
    const show = () => {
      document.documentElement.classList.remove('cursor-idle');
      window.clearTimeout(t);
      t = window.setTimeout(() => document.documentElement.classList.add('cursor-idle'), ms);
    };
    show();
    window.addEventListener('mousemove', show);
    return () => {
      window.removeEventListener('mousemove', show);
      window.clearTimeout(t);
      document.documentElement.classList.remove('cursor-idle');
    };
  }, [ms]);
}

export function useNow(periodMs = 1000): Date {
  const [now, setNow] = useState(() => new Date());
  useEffect(() => { const t = setInterval(() => setNow(new Date()), periodMs); return () => clearInterval(t); }, [periodMs]);
  return now;
}

export function OrbitLogo({ size = 34 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 40 40" aria-hidden>
      <defs>
        <linearGradient id="lg-ring" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor="#ffd08a" /><stop offset="0.5" stopColor="#ff9a1f" /><stop offset="1" stopColor="#5a2c00" />
        </linearGradient>
      </defs>
      <circle cx="20" cy="20" r="16" fill="none" stroke="url(#lg-ring)" strokeWidth="2.2" />
      <circle cx="20" cy="20" r="10.5" fill="none" stroke="#ff9a1f" strokeOpacity="0.35" strokeWidth="1" />
      <circle cx="31.3" cy="8.7" r="2.4" fill="#ffb347" />
    </svg>
  );
}

export function SimBadge({ parts }: { parts: string[] }) {
  return (
    <div className="sim-badge" role="status" aria-live="polite" title={`Datos simulados: ${parts.join(', ') || 'sí'}`}>
      <span className="sim-dot" /> MODO SIMULACIÓN
      {parts.length > 0 && <span className="sim-parts">{parts.join(' · ')}</span>}
    </div>
  );
}

export function SimTag({ show }: { show?: boolean }) {
  return show ? <span className="sim-tag" title="Valor simulado, no real">SIM</span> : null;
}

export function Meter({ label, value, display, warn = 75 }: { label: string; value: number | null | undefined; display: string; warn?: number }) {
  const v = value === null || value === undefined || !Number.isFinite(value) ? null : clamp(value, 0, 100);
  return (
    <div className="meter">
      <span className="meter-label">{label}</span>
      <div className="meter-track"><div className={`meter-fill ${v !== null && v >= warn ? 'hot' : ''}`} style={{ width: `${v ?? 0}%` }} /></div>
      <span className="meter-value">{display}</span>
    </div>
  );
}

export function StatusDot({ ok, sim }: { ok: boolean | null | undefined; sim?: boolean }) {
  return <span className={`status-dot ${ok ? (sim ? 'sim' : 'ok') : 'off'}`} />;
}

export function Chip({ estado }: { estado: Estado }) {
  return <span className={`chip chip-${estado}`}>{ESTADO_LABEL[estado]}</span>;
}

export function Panel({ title, right, children, className = '' }: { title?: ReactNode; right?: ReactNode; children: ReactNode; className?: string }) {
  return (
    <section className={`panel ${className}`}>
      {(title || right) && <header className="panel-head"><h3>{title}</h3>{right}</header>}
      {children}
    </section>
  );
}

export function Clock({ big }: { big?: boolean }) {
  const now = useNow(1000);
  return <span className={big ? 'clock-big' : 'clock-small'}>{formatClock(now)}</span>;
}

/** Dial semicircular para un potenciómetro (0..1023). */
export function Dial({ value, label, sim }: { value: number | undefined; label: string; sim?: boolean }) {
  const pct = value === undefined ? 0 : clamp(value / 1023, 0, 1);
  const a0 = -225, a1 = 45; // 270° de recorrido
  const ang = a0 + (a1 - a0) * pct;
  const r = 44, cx = 60, cy = 60;
  const pt = (deg: number, rr = r) => [cx + rr * Math.cos((deg * Math.PI) / 180), cy + rr * Math.sin((deg * Math.PI) / 180)];
  const arc = (from: number, to: number) => {
    const [x0, y0] = pt(from), [x1, y1] = pt(to);
    const large = to - from > 180 ? 1 : 0;
    return `M ${x0} ${y0} A ${r} ${r} 0 ${large} 1 ${x1} ${y1}`;
  };
  const [kx, ky] = pt(ang, 30);
  return (
    <svg className="dial" viewBox="0 0 120 112" role="img" aria-label={`${label}: ${value ?? 'sin dato'}`}>
      <path d={arc(a0, a1)} className="dial-track" />
      {value !== undefined && pct > 0.002 && <path d={arc(a0, ang)} className="dial-fill" />}
      <circle cx={cx} cy={cy} r="24" className="dial-knob" />
      <line x1={cx} y1={cy} x2={kx} y2={ky} className="dial-pointer" />
      <text x={cx} y="106" textAnchor="middle" className="dial-text">{value === undefined ? '—' : `${Math.round(pct * 100)}%`}{sim ? ' · SIM' : ''}</text>
    </svg>
  );
}

