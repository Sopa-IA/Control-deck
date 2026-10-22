import monitorPines from '../../../arduino-pruebas/monitor_pines/monitor_pines.ino?raw';

export const BLINK = `void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  digitalWrite(LED_BUILTIN, HIGH);
  delay(1000);
  digitalWrite(LED_BUILTIN, LOW);
  delay(1000);
}
`;

export const ANALOG = `void setup() {
  Serial.begin(9600);
}

void loop() {
  int sensor = analogRead(A0);
  Serial.println(sensor);
  delay(100);
}
`;

export const EJEMPLOS: { name: string; source: string }[] = [
  { name: 'Blink', source: BLINK },
  { name: 'AnalogReadSerial', source: ANALOG },
  { name: 'monitor_pines', source: monitorPines.endsWith('\n') ? monitorPines : `${monitorPines}\n` },
];

export const PLANTILLA = `void setup() {
}

void loop() {
}
`;
