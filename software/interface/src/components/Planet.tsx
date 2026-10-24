import { useEffect, useState } from 'react';
import {
  PLANET_CX, PLANET_CY, PLANET_FRAME_MS, PLANET_MOTION_KEY, PLANET_R, ROT_RAD_S,
  haloAlpha, makeStars, orbitAngle, projectStar, readPlanetMotion, shouldAnimate,
  type Proj,
} from './planetMotion';

const VIEW = 640;
const RING = PLANET_R + 16;
const BUCKETS = 6;

function readStoredMotion(): boolean {
  try { return readPlanetMotion(localStorage.getItem(PLANET_MOTION_KEY)); }
  catch { return true; }
}

export function usePlanetMotion(): [boolean, (on: boolean) => void] {
  const [on, setOn] = useState(readStoredMotion);
  useEffect(() => {
    const sync = () => setOn(readStoredMotion());
    window.addEventListener('orbit-planet-motion', sync);
    window.addEventListener('storage', sync);
    return () => {
      window.removeEventListener('orbit-planet-motion', sync);
      window.removeEventListener('storage', sync);
    };
  }, []);
  const set = (value: boolean) => {
    try { localStorage.setItem(PLANET_MOTION_KEY, value ? '1' : '0'); } catch { /* el navegador puede bloquearlo */ }
    window.dispatchEvent(new Event('orbit-planet-motion'));
    setOn(value);
  };
  return [on, set];
}

function reducedNow(): boolean {
  if (typeof window.matchMedia !== 'function') return false;
  return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

function useReducedMotion(): boolean {
  const [on, setOn] = useState(reducedNow);
  useEffect(() => {
    if (typeof window.matchMedia !== 'function') return;
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)');
    const sync = () => setOn(mq.matches);
    mq.addEventListener('change', sync);
    return () => mq.removeEventListener('change', sync);
  }, []);
  return on;
}

function layer(paint: (g: CanvasRenderingContext2D, size: number) => void, size = VIEW): HTMLCanvasElement | null {
  const c = document.createElement('canvas');
  c.width = size;
  c.height = size;
  let g: CanvasRenderingContext2D | null = null;
  try { g = c.getContext('2d'); } catch { g = null; }
  if (!g) return null;
  paint(g, size);
  return c;
}

function paintBody(g: CanvasRenderingContext2D) {
  const body = g.createRadialGradient(PLANET_CX - 70, PLANET_CY - 90, 20, PLANET_CX, PLANET_CY, PLANET_R);
  body.addColorStop(0, '#3a2410');
  body.addColorStop(0.35, '#1a1109');
  body.addColorStop(0.8, '#07060a');
  body.addColorStop(1, '#020203');
  g.fillStyle = body;
  g.beginPath();
  g.arc(PLANET_CX, PLANET_CY, PLANET_R, 0, Math.PI * 2);
  g.fill();
  const shade = g.createRadialGradient(PLANET_CX, PLANET_CY, PLANET_R * 0.62, PLANET_CX, PLANET_CY, PLANET_R);
  shade.addColorStop(0, 'rgba(0,0,0,0)');
  shade.addColorStop(1, 'rgba(0,0,0,0.62)');
  g.fillStyle = shade;
  g.beginPath();
  g.arc(PLANET_CX, PLANET_CY, PLANET_R, 0, Math.PI * 2);
  g.fill();
}

function paintHalo(g: CanvasRenderingContext2D) {
  const glow = g.createRadialGradient(PLANET_CX, PLANET_CY, PLANET_R * 0.86, PLANET_CX, PLANET_CY, PLANET_R * 1.22);
  glow.addColorStop(0, 'rgba(255,154,31,0)');
  glow.addColorStop(0.45, 'rgba(255,154,31,0.20)');
  glow.addColorStop(0.72, 'rgba(255,176,64,0.34)');
  glow.addColorStop(1, 'rgba(255,154,31,0)');
  g.fillStyle = glow;
  g.beginPath();
  g.arc(PLANET_CX, PLANET_CY, PLANET_R * 1.22, 0, Math.PI * 2);
  g.fill();
}

function paintSun(g: CanvasRenderingContext2D, s: number) {
  const grd = g.createRadialGradient(s / 2, s / 2, 0, s / 2, s / 2, s / 2);
  grd.addColorStop(0, 'rgba(255,242,214,0.95)');
  grd.addColorStop(0.16, 'rgba(255,196,107,0.72)');
  grd.addColorStop(0.42, 'rgba(255,138,0,0.16)');
  grd.addColorStop(1, 'rgba(255,138,0,0)');
  g.fillStyle = grd;
  g.fillRect(0, 0, s, s);
}

/** Planeta de Inicio. Lienzo 2D a 30 fps, sin filtros ni gradientes por fotograma. */
export function Planet({ animar = true, moonlight = false }: { animar?: boolean; moonlight?: boolean }) {
  const reduced = useReducedMotion();
  const run = shouldAnimate({ setting: animar, reduced, hidden: false, moonlight });
  const [node, setNode] = useState<HTMLCanvasElement | null>(null);

  useEffect(() => {
    if (!node) return;
    if (typeof navigator !== 'undefined' && /jsdom/i.test(navigator.userAgent)) return;
    let ctx: CanvasRenderingContext2D | null = null;
    try { ctx = node.getContext('2d'); } catch { ctx = null; }
    if (!ctx) return;
    const g = ctx;
    const stars = makeStars();
    const body = layer(paintBody);
    const halo = layer(paintHalo);
    const sun = layer(paintSun, 96);
    if (!body || !halo || !sun) return;
    const scratch: Proj = { x: 0, y: 0, radius: 0, alpha: 0 };
    const xs = new Float32Array(stars.length);
    const ys = new Float32Array(stars.length);
    const rs = new Float32Array(stars.length);
    const glow = new Uint8Array(stars.length);
    const lists: number[][] = Array.from({ length: BUCKETS }, () => []);
    let timer = 0;
    let alive = true;

    const paint = (t: number) => {
      if (!alive) return;
      g.clearRect(0, 0, VIEW, VIEW);
      g.globalAlpha = haloAlpha(t);
      g.drawImage(halo, 0, 0);
      g.globalAlpha = 1;
      g.drawImage(body, 0, 0);

      const rot = t * ROT_RAD_S;
      let n = 0;
      for (let b = 0; b < BUCKETS; b++) lists[b].length = 0;
      for (let i = 0; i < stars.length; i++) {
        if (!projectStar(stars[i], rot, t, scratch)) continue;
        xs[n] = scratch.x;
        ys[n] = scratch.y;
        rs[n] = scratch.radius;
        glow[n] = stars[i].glow ? 1 : 0;
        const bucket = Math.min(BUCKETS - 1, (scratch.alpha * BUCKETS) | 0);
        lists[bucket].push(n);
        n += 1;
      }

      g.save();
      g.beginPath();
      g.arc(PLANET_CX, PLANET_CY, PLANET_R - 0.5, 0, Math.PI * 2);
      g.clip();
      g.fillStyle = '#ffad42';
      for (let pass = 0; pass < 2; pass++) {
        for (let b = 0; b < BUCKETS; b++) {
          const ids = lists[b];
          if (!ids.length) continue;
          g.globalAlpha = ((b + 0.65) / BUCKETS) * (pass === 0 ? 0.2 : 1);
          g.beginPath();
          let any = false;
          for (let k = 0; k < ids.length; k++) {
            const i = ids[k];
            if (pass === 0 && !glow[i]) continue;
            const rad = Math.max(0.35, (pass === 0 ? rs[i] * 1.7 : rs[i]) * 0.5);
            g.moveTo(xs[i] + rad, ys[i]);
            g.arc(xs[i], ys[i], rad, 0, Math.PI * 2);
            any = true;
          }
          if (any) g.fill();
        }
      }
      g.restore();
      g.globalAlpha = 1;

      g.beginPath();
      g.arc(PLANET_CX, PLANET_CY, RING, 0, Math.PI * 2);
      g.strokeStyle = 'rgba(255,179,71,0.38)';
      g.lineWidth = 1.6;
      g.stroke();

      const ang = orbitAngle(t);
      g.beginPath();
      g.arc(PLANET_CX, PLANET_CY, RING, ang - 0.85, ang);
      g.strokeStyle = 'rgba(255,198,112,0.92)';
      g.lineWidth = 2.6;
      g.stroke();

      const px = PLANET_CX + Math.cos(ang) * RING;
      const py = PLANET_CY + Math.sin(ang) * RING;
      g.drawImage(sun, px - 34, py - 34, 68, 68);
    };

    const stop = () => {
      window.clearTimeout(timer);
      timer = 0;
    };
    const loop = () => {
      paint(performance.now() / 1000);
      timer = window.setTimeout(loop, PLANET_FRAME_MS);
    };

    if (!run || document.hidden) {
      paint(0);
    } else {
      loop();
    }
    const onVis = () => {
      if (!run) return;
      if (document.hidden) stop();
      else if (!timer) loop();
    };
    document.addEventListener('visibilitychange', onVis);
    return () => {
      alive = false;
      stop();
      document.removeEventListener('visibilitychange', onVis);
    };
  }, [node, run]);

  return <canvas ref={setNode} className="planet" width={VIEW} height={VIEW} aria-hidden />;
}
