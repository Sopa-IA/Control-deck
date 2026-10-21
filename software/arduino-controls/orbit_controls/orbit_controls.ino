// Orbit Terminal · orbit_controls v1 · Arduino Nano (ATmega328P)
// Lee N potenciómetros (EMA + histéresis) y M botones (antirrebote + pulsación larga) y emite
// eventos serie compactos (ver software/shared/PROTOCOLO.md §7):
//   H orbit-controls 1 P2 B2    saludo (al arrancar y al recibir '?'; los números salen de config.h)
//   P1 512                      potenciómetro 1 = 512 (0..1023)
//   B2 1 / B2 0 / B2 L          botón 2 pulsado / soltado / pulsación larga
// El USB lo pone el conversor serie (en el clon de Miguel, probablemente CH340): no hay USB CDC
// ni HID. PROVISIONAL: pensado para compilar con arduino-cli (FQBN arduino:avr:nano y
// arduino:avr:nano:cpu=atmega328old). NO probado en la placa.

#include "config.h"

#if ENABLE_HID_VOLUME
#error "ENABLE_HID_VOLUME no es posible en el Arduino Nano: el ATmega328P no tiene USB nativo"
#endif

struct PotState { uint16_t ema_x8; int16_t sent; };
struct ButtonState { uint8_t stable; uint8_t last_raw; uint32_t changed_ms; uint32_t pressed_ms; bool long_sent; };

static PotState pots[NUM_POTS];
static ButtonState buttons[NUM_BUTTONS];
static uint32_t last_sample_ms = 0;

static void sendHello() {
  Serial.print(F("H " FW_NAME " " FW_VERSION " P"));
  Serial.print(NUM_POTS);
  Serial.print(F(" B"));
  Serial.println(NUM_BUTTONS);
}

static void sendPot(uint8_t i, int16_t v) {
  Serial.print('P'); Serial.print(i + 1); Serial.print(' '); Serial.println(v);
}

static void sendButton(uint8_t i, char ev) {
  Serial.print('B'); Serial.print(i + 1); Serial.print(' '); Serial.println(ev);
}

// Filtro: media exponencial en punto fijo (x8) y salida con histéresis; se ajusta a 0/1023 en los extremos.
static int16_t potFilteredValue(uint8_t i) {
  uint16_t raw = analogRead(POT_PINS[i]);
  PotState &p = pots[i];
  p.ema_x8 = p.ema_x8 - (p.ema_x8 >> POT_EMA_SHIFT) + ((raw << 3) >> POT_EMA_SHIFT);
  int16_t v = (p.ema_x8 + 4) >> 3;
  if (v <= POT_HYSTERESIS) v = 0;
  if (v >= 1023 - POT_HYSTERESIS) v = 1023;
  return v;
}

static void updatePots() {
  for (uint8_t i = 0; i < NUM_POTS; i++) {
    int16_t v = potFilteredValue(i);
    PotState &p = pots[i];
    bool edge = (v == 0 || v == 1023) && v != p.sent;
    if (p.sent < 0 || abs(v - p.sent) >= POT_HYSTERESIS || edge) {
      p.sent = v;
      sendPot(i, v);
    }
  }
}

static void updateButtons(uint32_t now) {
  for (uint8_t i = 0; i < NUM_BUTTONS; i++) {
    ButtonState &b = buttons[i];
    uint8_t raw = digitalRead(BUTTON_PINS[i]) == LOW ? 1 : 0;   // pulsado = LOW (pull-up)
    if (raw != b.last_raw) { b.last_raw = raw; b.changed_ms = now; }
    if (raw != b.stable && (now - b.changed_ms) >= DEBOUNCE_MS) {
      b.stable = raw;
      if (raw) { b.pressed_ms = now; b.long_sent = false; sendButton(i, '1'); }
      else { sendButton(i, '0'); }
    }
    if (b.stable && !b.long_sent && (now - b.pressed_ms) >= LONG_PRESS_MS) {
      b.long_sent = true;
      sendButton(i, 'L');
    }
  }
}

static void handleSerialInput() {
  while (Serial.available() > 0) {
    int c = Serial.read();
    if (c == '?') {
      sendHello();
      for (uint8_t i = 0; i < NUM_POTS; i++) if (pots[i].sent >= 0) sendPot(i, pots[i].sent);
    }
  }
}

void setup() {
  // En el Nano, Serial es el UART de hardware. Tras begin() ya está listo: no hay
  // que esperar a un USB CDC. Quien abre el puerto (orbitd) es el que debe contar
  // con el reinicio del bootloader; ver serial_events.py.
  Serial.begin(SERIAL_BAUD);
  for (uint8_t i = 0; i < NUM_BUTTONS; i++) {
    pinMode(BUTTON_PINS[i], INPUT_PULLUP);
    buttons[i] = {0, 0, 0, 0, false};
  }
  for (uint8_t i = 0; i < NUM_POTS; i++) {
    uint16_t raw = analogRead(POT_PINS[i]);
    pots[i].ema_x8 = raw << 3;
    pots[i].sent = -1;
  }
  sendHello();
}

void loop() {
  uint32_t now = millis();
  handleSerialInput();
  if (now - last_sample_ms >= POT_SAMPLE_MS) {
    last_sample_ms = now;
    updatePots();
  }
  updateButtons(now);
}
