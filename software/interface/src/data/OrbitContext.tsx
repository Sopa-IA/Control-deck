import { createContext, useCallback, useContext, useEffect, useMemo, useReducer, useRef, useState, type ReactNode } from 'react';
import { makeMessage, type ControlEventPayload, type MappingPayload, type Message } from '@shared/ts/protocol';
import { initialState, isSimulated, reduce, type OrbitState, type SourceKind } from './state';
import { chooseSource, defaultWsUrl, type DataSource } from './source';
import { SimDataSource } from './simSource';
import { WsDataSource } from './wsSource';

interface OrbitApi {
  state: OrbitState;
  simulated: boolean;
  requestAction: (action: string, params?: Record<string, unknown>) => void;
  confirm: () => void;
  cancelConfirm: () => void;
  setMapping: (m: MappingPayload) => void;
  setSource: (k: SourceKind) => void;
  injectControl: ((p: Omit<ControlEventPayload, 'simulated'>) => void) | null;
  wsUrl: string;
  setWsUrl: (u: string) => void;
  onMessage: (fn: (m: Message) => void) => () => void;
}

const Ctx = createContext<OrbitApi | null>(null);

export function OrbitProvider({ children, forceSource, animate = true }: { children: ReactNode; forceSource?: SourceKind; animate?: boolean }) {
  const initial = forceSource ?? chooseSource(window.location.search, localStorage.getItem('orbit.source'), import.meta.env.DEV);
  const [source, setSourceState] = useState<SourceKind>(initial);
  const [wsUrl, setWsUrlState] = useState(() => localStorage.getItem('orbit.wsUrl') || new URLSearchParams(window.location.search).get('ws') || defaultWsUrl(window.location));
  const [state, dispatch] = useReducer(reduce, initial, initialState);
  const ds = useRef<DataSource | null>(null);
  const listeners = useRef(new Set<(m: Message) => void>());

  useEffect(() => {
    dispatch({ kind: 'reset', source });
    const token = sessionStorage.getItem('orbit.uiToken') || undefined;
    const d: DataSource = source === 'sim' ? new SimDataSource({ animateControls: animate }) : new WsDataSource(wsUrl, token);
    ds.current = d;
    d.connect(
      (m) => { dispatch({ kind: 'message', msg: m }); listeners.current.forEach((fn) => fn(m)); },
      (conn, detail) => dispatch({ kind: 'conn', conn, detail }),
    );
    return () => d.close();
  }, [source, wsUrl, animate]);

  const send = useCallback((m: Message) => ds.current?.send(m), []);
  const api = useMemo<OrbitApi>(() => ({
    state,
    simulated: isSimulated(state),
    requestAction: (action, params) => send(makeMessage('action_request', 'ui', params ? { action, params } : { action })),
    confirm: () => {
      if (state.pendingConfirm) {
        send(makeMessage('action_confirm', 'ui', { request_id: state.pendingConfirm.request_id, challenge: state.pendingConfirm.challenge }));
        dispatch({ kind: 'clear_confirm' });
      }
    },
    cancelConfirm: () => {
      dispatch({ kind: 'clear_confirm' });
      dispatch({ kind: 'log', entry: { ts: Date.now(), level: 'info', text: 'Acción cancelada por el usuario' } });
    },
    setMapping: (m) => send(makeMessage('mapping_set', 'ui', m)),
    setSource: (k) => { localStorage.setItem('orbit.source', k); setSourceState(k); },
    injectControl: ds.current instanceof SimDataSource ? (p) => (ds.current as SimDataSource).inject(p) : null,
    wsUrl,
    setWsUrl: (u) => { localStorage.setItem('orbit.wsUrl', u); setWsUrlState(u); },
    onMessage: (fn) => { listeners.current.add(fn); return () => listeners.current.delete(fn); },
  }), [state, send, wsUrl]);

  return <Ctx.Provider value={api}>{children}</Ctx.Provider>;
}

export function useOrbit(): OrbitApi {
  const v = useContext(Ctx);
  if (!v) throw new Error('useOrbit fuera de OrbitProvider');
  return v;
}
