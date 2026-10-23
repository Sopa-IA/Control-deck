import { describe, expect, it } from 'vitest';
import {
  PLANET_CX, PLANET_CY, PLANET_R, ROT_RAD_S,
  haloAlpha, makeStars, orbitAngle, projectStar, readPlanetMotion, shouldAnimate,
  type Proj,
} from './planetMotion';

const center = { lon: 0, lat: 0, r: 2, base: 1, phase: 0, freq: 1, glow: false };

describe('planeta', () => {
  it('en el centro la luz es grande y en el borde no se pinta', () => {
    const out: Proj = { x: 0, y: 0, radius: 0, alpha: 0 };
    expect(projectStar(center, 0, 0, out)).toBe(true);
    expect(out.x).toBeCloseTo(PLANET_CX, 3);
    expect(out.y).toBeCloseTo(PLANET_CY, 3);
    const full = out.radius;
    expect(projectStar({ ...center, lon: Math.PI / 2 }, 0, 0, out)).toBe(false);
    expect(projectStar({ ...center, lon: 1.15 }, 0, 0, out)).toBe(true);
    expect(out.radius).toBeLessThan(full);
    expect(Math.abs(out.x - PLANET_CX)).toBeGreaterThan(PLANET_R * 0.7);
  });

  it('al girar, una luz del frente se desplaza', () => {
    const out: Proj = { x: 0, y: 0, radius: 0, alpha: 0 };
    projectStar(center, 0, 0, out);
    const x0 = out.x;
    projectStar(center, ROT_RAD_S * 4, 0, out);
    expect(out.x).not.toBeCloseTo(x0, 1);
  });

  it('el titileo depende de la fase', () => {
    const out: Proj = { x: 0, y: 0, radius: 0, alpha: 0 };
    projectStar(center, 0, 0.4, out);
    const a = out.alpha;
    projectStar({ ...center, phase: Math.PI }, 0, 0.4, out);
    expect(out.alpha).not.toBeCloseTo(a, 2);
  });

  it('las luces salen siempre igual y el halo solo respira un poco', () => {
    const a = makeStars();
    const b = makeStars();
    expect(a).toHaveLength(280);
    expect(a[0]).toEqual(b[0]);
    expect(haloAlpha(0)).toBeGreaterThan(0.7);
    expect(haloAlpha(0)).toBeLessThan(1.05);
    expect(orbitAngle(0)).toBeLessThan(0);
  });

  it('la animación se apaga con el ajuste, el sistema, la pestaña o Moonlight', () => {
    const on = { setting: true, reduced: false, hidden: false, moonlight: false };
    expect(shouldAnimate(on)).toBe(true);
    expect(shouldAnimate({ ...on, setting: false })).toBe(false);
    expect(shouldAnimate({ ...on, reduced: true })).toBe(false);
    expect(shouldAnimate({ ...on, hidden: true })).toBe(false);
    expect(shouldAnimate({ ...on, moonlight: true })).toBe(false);
    expect(readPlanetMotion(null)).toBe(true);
    expect(readPlanetMotion('1')).toBe(true);
    expect(readPlanetMotion('0')).toBe(false);
  });
});
