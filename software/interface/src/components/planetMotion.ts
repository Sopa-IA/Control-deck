/** Geometría del planeta de Inicio. Sin canvas: se puede probar y no asigna por fotograma. */

export const PLANET_CX = 340;
export const PLANET_CY = 360;
export const PLANET_R = 250;
export const PLANET_FPS = 30;
export const PLANET_FRAME_MS = 1000 / PLANET_FPS;
/** Una vuelta de las luces, en torno a un minuto y medio. */
export const ROT_RAD_S = 0.07;
/** El punto del anillo da una vuelta en torno a dos minutos. */
export const ORBIT_RAD_S = 0.05;
/** En t = 0 el punto queda arriba a la izquierda, como el dibujo quieto. */
export const ORBIT_PHASE = -2.15;
const LIMB = 0.07;

export interface Star {
  lon: number;
  lat: number;
  r: number;
  base: number;
  phase: number;
  freq: number;
  glow: boolean;
}

export interface Proj {
  x: number;
  y: number;
  radius: number;
  alpha: number;
}

export function makeStars(count = 280): Star[] {
  let seed = 7;
  const rnd = () => ((seed = (seed * 16807) % 2147483647) / 2147483647);
  const centers: [number, number][] = [
    [0.15, -0.05], [-0.55, 0.28], [0.72, -0.32], [-0.2, -0.55],
    [1.05, 0.22], [-0.95, -0.18], [0.4, 0.48], [-1.25, 0.42],
  ];
  const out: Star[] = [];
  for (let i = 0; i < count; i++) {
    const c = centers[Math.floor(rnd() * centers.length)];
    const ang = rnd() * Math.PI * 2;
    const dist = Math.pow(rnd(), 1.45) * 0.62;
    const r = rnd() < 0.08 ? 2.15 : 0.55 + rnd() * 1.05;
    out.push({
      lon: c[0] + Math.cos(ang) * dist,
      lat: c[1] + Math.sin(ang) * dist * 0.72,
      r,
      base: 0.4 + rnd() * 0.6,
      phase: rnd() * Math.PI * 2,
      freq: 0.45 + rnd() * 1.15,
      glow: r > 1.7,
    });
  }
  return out;
}

/** Proyecta una luz. z cerca de 0 es el borde: más pequeña, más tenue y, al rotar, más lenta en pantalla. */
export function projectStar(star: Star, rot: number, t: number, out: Proj): boolean {
  const lon = star.lon + rot;
  const cl = Math.cos(star.lat);
  const z = cl * Math.cos(lon);
  if (z < LIMB) return false;
  const tw = 0.8 + 0.2 * Math.sin(t * star.freq + star.phase);
  out.x = PLANET_CX + cl * Math.sin(lon) * PLANET_R;
  out.y = PLANET_CY + Math.sin(star.lat) * PLANET_R;
  out.radius = star.r * (0.4 + 0.6 * z);
  out.alpha = star.base * tw * (0.3 + 0.7 * z);
  return true;
}

export function orbitAngle(t: number): number {
  return ORBIT_PHASE + t * ORBIT_RAD_S;
}

export function haloAlpha(t: number): number {
  return 0.78 + 0.22 * Math.sin(t * 0.42);
}

export function shouldAnimate(opts: {
  setting: boolean;
  reduced: boolean;
  hidden: boolean;
  moonlight: boolean;
}): boolean {
  return opts.setting && !opts.reduced && !opts.hidden && !opts.moonlight;
}

export const PLANET_MOTION_KEY = 'orbit.planetMotion';

/** Ausente o cualquier cosa distinta de "0": activada. */
export function readPlanetMotion(stored: string | null): boolean {
  return stored !== '0';
}
