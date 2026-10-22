import { describe, expect, it } from 'vitest';
import { BLINK } from './ejemplos';
import { parseErrors, parseSamples, simProblema } from './parse';

describe('salida de arduino-cli', () => {
  it('marca la línea del error', () => {
    const text = '/home/pi/Blink/Blink.ino:4:1: error: expected \';\' before \'}\' token';
    expect(parseErrors(text)).toEqual([{ line: 4, col: 1, message: 'expected \';\' before \'}\' token' }]);
  });
  it('Blink no tiene el fallo que marca el simulador', () => {
    expect(simProblema(BLINK)).toBeNull();
  });
  it('una llamada sin punto y coma cae en su línea', () => {
    const src = 'void setup() {\n  pinMode(LED_BUILTIN, OUTPUT)\n}\n';
    expect(simProblema(src)?.line).toBe(2);
  });
});

describe('valores del monitor', () => {
  it('lee un número suelto y un nombre', () => {
    expect(parseSamples('512')).toEqual([{ name: 'valor', value: 512 }]);
    expect(parseSamples('A0 480')).toEqual([{ name: 'A0', value: 480 }]);
    expect(parseSamples('A0:12 A1:34')).toEqual([{ name: 'A0', value: 12 }, { name: 'A1', value: 34 }]);
    expect(parseSamples('monitor-pines 1')).toEqual([]);
  });
});
