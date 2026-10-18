export type SectionId = 'inicio' | 'sistemas' | 'hardware' | 'controles' | 'herramientas' | 'configuracion';
export const SECTIONS: { id: SectionId; label: string; icon: string }[] = [
  { id: 'inicio', label: 'Inicio', icon: '◉' },
  { id: 'sistemas', label: 'Sistemas', icon: '⧉' },
  { id: 'hardware', label: 'Hardware', icon: '▤' },
  { id: 'controles', label: 'Controles', icon: '◎' },
  { id: 'herramientas', label: 'Herramientas', icon: '⚒' },
  { id: 'configuracion', label: 'Configuración', icon: '⚙' },
];
export function nextSection(cur: SectionId): SectionId {
  const i = SECTIONS.findIndex((s) => s.id === cur);
  return SECTIONS[(i + 1) % SECTIONS.length].id;
}
