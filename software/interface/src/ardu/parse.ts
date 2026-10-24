export interface Diag { line: number; col: number; message: string }
export interface Sample { name: string; value: number }
export interface PortRow { role: string; by_path: string; device: string; blocked: boolean; present?: boolean }

const ERROR_RE = /:(\d+):(\d+):\s*(?:fatal\s+)?error:\s*(.+)$/i;

export function parseErrors(text: string): Diag[] {
  const out: Diag[] = [];
  for (const line of text.split(/\r?\n/)) {
    const m = ERROR_RE.exec(line.trim());
    if (!m) continue;
    out.push({ line: Number(m[1]), col: Number(m[2]), message: m[3].trim() });
  }
  return out;
}

export function parseSamples(line: string): Sample[] {
  const t = line.trim();
  if (!t || t.startsWith('#')) return [];
  const named = [...t.matchAll(/(?:^|[\s,])([A-Za-z_][A-Za-z0-9_]*)\s*[:= ]\s*(-?\d+(?:\.\d+)?)/g)];
  if (named.length) return named.map((m) => ({ name: m[1], value: Number(m[2]) }));
  if (/^-?\d+(?:\.\d+)?$/.test(t)) return [{ name: 'valor', value: Number(t) }];
  return [];
}

export function parsePorts(output: string | undefined): PortRow[] {
  if (!output) return [];
  try {
    const data = JSON.parse(output) as { ports?: PortRow[] };
    return Array.isArray(data.ports) ? data.ports : [];
  } catch {
    return [];
  }
}

/** Marca en el simulador una llamada sin punto y coma, para poder enseñar el error en la línea. */
export function simProblema(source: string): Diag | null {
  const lines = source.split(/\r?\n/);
  for (let i = 0; i < lines.length; i++) {
    const t = lines[i].trim();
    if (!t || t.startsWith('//') || t.startsWith('#') || t.startsWith('/*') || t.startsWith('*')) continue;
    if (/[{};]$/.test(t) || /^(if|for|while|else|do)\b/.test(t)) continue;
    if (t.includes('no_compila') || /\b(digitalWrite|pinMode|delay|Serial\.\w+)\([^;]*\)\s*$/.test(t)) {
      return { line: i + 1, col: 1, message: 'falta un punto y coma' };
    }
  }
  return null;
}
