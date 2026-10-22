// Capturas de la interfaz en marcha con Chromium sin cabeza (playwright-core).
// Uso: node scripts/screenshots.mjs [URL_BASE] [carpeta_salida]
//   URL_BASE por defecto http://127.0.0.1:8765/ (orbitd sirviendo software/interface/dist)
//   CHROME_PATH=/ruta/a/chrome si no está en /usr/bin/google-chrome
import { createRequire } from 'node:module';
import { mkdirSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const require = createRequire(resolve(here, '../software/interface/package.json'));
const { chromium } = require('playwright-core');

const base = process.argv[2] ?? 'http://127.0.0.1:8765/';
const out = resolve(process.argv[3] ?? resolve(here, '../assets/screenshots'));
mkdirSync(out, { recursive: true });

const shots = [
  { name: 'inicio_1920x1080', s: 'inicio', w: 1920, h: 1080 },
  { name: 'hardware_1920x1080', s: 'hardware', w: 1920, h: 1080 },
  { name: 'controles_1920x1080', s: 'controles', w: 1920, h: 1080 },
  { name: 'sistemas_1920x1080', s: 'sistemas', w: 1920, h: 1080 },
  { name: 'inicio_1920x720', s: 'inicio', w: 1920, h: 720 },
  { name: 'integrado_1920x1080', s: 'inicio', vista: 'integrado', w: 1920, h: 1080 },
  { name: 'ardulab_1920x1080', s: 'ardulab', w: 1920, h: 1080 },
];

const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH ?? '/usr/bin/google-chrome', args: ['--no-sandbox'] });
for (const sh of shots) {
  const page = await browser.newPage({ viewport: { width: sh.w, height: sh.h }, deviceScaleFactor: 1 });
  const q = new URLSearchParams({ s: sh.s });
  if (sh.vista) q.set('vista', sh.vista);
  const root = base.endsWith('/') ? base : `${base}/`;
  await page.goto(`${root}?${q}`, { waitUntil: 'networkidle' });
  await page.waitForTimeout(4500); // deja llegar telemetría y eventos de control
  const file = resolve(out, `${sh.name}.png`);
  await page.screenshot({ path: file });
  console.log('captura', file);
  await page.close();
}
await browser.close();
