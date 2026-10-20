// Orbit Terminal · monitor_pines · ejemplo para el Nano de prácticas
// OLED 0,96" 128x64 I2C (controlador SSD1306, dirección 0x3C) en A4 (SDA) y A5 (SCL).
// Muestra el estado digital de D2..D13 y las lecturas de A0 A1 A2 A3 A6 A7.
// A4 y A5 no se leen: son el bus de la pantalla.
//
// Este sketch es un ejemplo para que Miguel lo sustituya. No es el firmware de los
// mandos (ese es software/arduino-controls) y no habla el protocolo de orbitd.
// No se ha probado con una pantalla real. Si la imagen sale girada, cambiar 0xA1/0xC8
// en oledInit() (queda anotado abajo).
//
// Cableado previsto [DISEÑO], sin probar:
//   VCC del módulo -> 5 V del Nano. La wiki de Waveshare 0.96inch OLED (B) dice
//   VCC 3,3 V/5 V; la ficha de producto, en «Operating Voltage», dice 3,3 V.
//   Confirmarlo en el módulo real antes de alimentarlo a 5 V.
//   GND -> GND
//   SDA -> A4
//   SCL -> A5
// Muchos módulos traen las resistencias de pull-up del I2C. Confirmarlo en el módulo real.

#include <Wire.h>

static const uint8_t OLED_ADDR = 0x3C;
static const uint8_t DIG_PINS[] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13};
static const uint8_t DIG_N = sizeof(DIG_PINS);
static const uint8_t ANA_PINS[] = {A0, A1, A2, A3, A6, A7};
static const char ANA_NAME[] = {'0', '1', '2', '3', '6', '7'};

// Fuente 5x7 propia (bit 0 = fila de arriba). Índice: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ =-/"
static const char FONT_INDEX[] PROGMEM = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ =-/" ;
static const uint8_t FONT[][5] PROGMEM = {
    {0x3E, 0x51, 0x49, 0x45, 0x3E}, {0x00, 0x42, 0x7F, 0x40, 0x00}, {0x42, 0x61, 0x51, 0x49, 0x46},
    {0x22, 0x41, 0x49, 0x49, 0x36}, {0x18, 0x14, 0x12, 0x7F, 0x10}, {0x27, 0x45, 0x45, 0x45, 0x39},
    {0x3C, 0x4A, 0x49, 0x49, 0x30}, {0x01, 0x71, 0x09, 0x05, 0x03}, {0x36, 0x49, 0x49, 0x49, 0x36},
    {0x06, 0x49, 0x49, 0x29, 0x1E}, {0x7E, 0x09, 0x09, 0x09, 0x7E}, {0x7F, 0x49, 0x49, 0x49, 0x36},
    {0x3E, 0x41, 0x41, 0x41, 0x22}, {0x7F, 0x41, 0x41, 0x41, 0x3E}, {0x7F, 0x49, 0x49, 0x49, 0x41},
    {0x7F, 0x09, 0x09, 0x09, 0x01}, {0x3E, 0x41, 0x49, 0x49, 0x7A}, {0x7F, 0x08, 0x08, 0x08, 0x7F},
    {0x00, 0x41, 0x7F, 0x41, 0x00}, {0x30, 0x40, 0x41, 0x3F, 0x01}, {0x7F, 0x08, 0x14, 0x22, 0x41},
    {0x7F, 0x40, 0x40, 0x40, 0x40}, {0x7F, 0x02, 0x0C, 0x02, 0x7F}, {0x7F, 0x02, 0x04, 0x08, 0x7F},
    {0x3E, 0x41, 0x41, 0x41, 0x3E}, {0x7F, 0x09, 0x09, 0x09, 0x06}, {0x3E, 0x41, 0x51, 0x21, 0x5E},
    {0x7F, 0x09, 0x19, 0x29, 0x46}, {0x46, 0x49, 0x49, 0x49, 0x31}, {0x01, 0x01, 0x7F, 0x01, 0x01},
    {0x3F, 0x40, 0x40, 0x40, 0x3F}, {0x1F, 0x20, 0x40, 0x20, 0x1F}, {0x3F, 0x40, 0x38, 0x40, 0x3F},
    {0x63, 0x14, 0x08, 0x14, 0x63}, {0x03, 0x04, 0x78, 0x04, 0x03}, {0x61, 0x51, 0x49, 0x45, 0x43},
    {0x00, 0x00, 0x00, 0x00, 0x00}, {0x0A, 0x0A, 0x0A, 0x0A, 0x0A}, {0x08, 0x08, 0x08, 0x08, 0x08},
    {0x40, 0x30, 0x08, 0x06, 0x01},
};

static int fontIndex(char c) {
  for (uint8_t i = 0; i < sizeof(FONT) / sizeof(FONT[0]); i++) {
    if (pgm_read_byte(&FONT_INDEX[i]) == c) return i;
  }
  return 36;  // espacio
}

static void oledCmd(uint8_t c) {
  Wire.beginTransmission(OLED_ADDR);
  Wire.write(0x00);
  Wire.write(c);
  Wire.endTransmission();
}

static void oledCmd2(uint8_t a, uint8_t b) {
  Wire.beginTransmission(OLED_ADDR);
  Wire.write(0x00);
  Wire.write(a);
  Wire.write(b);
  Wire.endTransmission();
}

static void oledInit() {
  Wire.begin();
  oledCmd(0xAE);
  oledCmd2(0xD5, 0x80);
  oledCmd2(0xA8, 0x3F);
  oledCmd2(0xD3, 0x00);
  oledCmd(0x40);
  oledCmd2(0x8D, 0x14);   // bomba de carga; sin ella el panel se queda en negro
  oledCmd2(0x20, 0x00);   // direccionamiento horizontal
  oledCmd(0xA1);          // si queda en espejo, probar 0xA0
  oledCmd(0xC8);          // si queda boca abajo, probar 0xC0
  oledCmd2(0xDA, 0x12);
  oledCmd2(0x81, 0xCF);
  oledCmd2(0xD9, 0xF1);
  oledCmd2(0xDB, 0x40);
  oledCmd(0xA4);
  oledCmd(0xA6);
  oledCmd(0xAF);
}

static void oledSendPage(uint8_t page, const uint8_t *buf) {
  oledCmd(0xB0 | (page & 0x07));
  oledCmd(0x00);
  oledCmd(0x10);
  for (uint8_t off = 0; off < 128; off += 16) {
    Wire.beginTransmission(OLED_ADDR);
    Wire.write(0x40);
    for (uint8_t i = 0; i < 16; i++) Wire.write(buf[off + i]);
    Wire.endTransmission();
  }
}

static void drawText(uint8_t *page, int x, const char *s) {
  while (*s && x < 123) {
    int gi = fontIndex(*s++);
    for (uint8_t col = 0; col < 5 && x + col < 128; col++) {
      page[x + col] = pgm_read_byte(&FONT[gi][col]);
    }
    x += 6;
  }
}

static void fmt4(char *o, int v) {
  if (v < 0) v = 0;
  if (v > 1023) v = 1023;
  o[0] = '0' + (v / 1000);
  o[1] = '0' + ((v / 100) % 10);
  o[2] = '0' + ((v / 10) % 10);
  o[3] = '0' + (v % 10);
  o[4] = 0;
  if (o[0] == '0') {
    o[0] = ' ';
    if (o[1] == '0') {
      o[1] = ' ';
      if (o[2] == '0') o[2] = ' ';
    }
  }
}

static void paint() {
  uint8_t page[128];
  char line[22];
  char num[5];

  for (uint8_t i = 0; i < 128; i++) page[i] = 0;
  drawText(page, 0, "ORBIT PINES");
  oledSendPage(0, page);

  for (uint8_t i = 0; i < 128; i++) page[i] = 0;
  line[0] = 'D'; line[1] = ' ';
  for (uint8_t i = 0; i < DIG_N; i++) line[2 + i] = digitalRead(DIG_PINS[i]) == LOW ? '0' : '1';
  line[2 + DIG_N] = 0;
  drawText(page, 0, line);
  oledSendPage(1, page);

  for (uint8_t i = 0; i < 128; i++) page[i] = 0;
  drawText(page, 0, "  23456789ABCD");
  oledSendPage(2, page);

  for (uint8_t row = 0; row < 3; row++) {
    for (uint8_t i = 0; i < 128; i++) page[i] = 0;
    uint8_t a = row * 2;
    fmt4(num, analogRead(ANA_PINS[a]));
    line[0] = 'A'; line[1] = ANA_NAME[a]; line[2] = ' ';
    line[3] = num[0]; line[4] = num[1]; line[5] = num[2]; line[6] = num[3];
    line[7] = ' ';
    fmt4(num, analogRead(ANA_PINS[a + 1]));
    line[8] = 'A'; line[9] = ANA_NAME[a + 1]; line[10] = ' ';
    line[11] = num[0]; line[12] = num[1]; line[13] = num[2]; line[14] = num[3];
    line[15] = 0;
    drawText(page, 0, line);
    oledSendPage(3 + row, page);
  }

  for (uint8_t i = 0; i < 128; i++) page[i] = 0;
  drawText(page, 0, "A4/A5 = OLED");
  oledSendPage(6, page);

  for (uint8_t i = 0; i < 128; i++) page[i] = 0;
  drawText(page, 0, "EJEMPLO");
  oledSendPage(7, page);
}

void setup() {
  for (uint8_t i = 0; i < DIG_N; i++) pinMode(DIG_PINS[i], INPUT_PULLUP);
  Serial.begin(115200);
  Serial.println(F("monitor-pines 1"));  // no es el saludo de orbit-controls
  oledInit();
  paint();
}

void loop() {
  static uint32_t last = 0;
  uint32_t now = millis();
  if (now - last >= 200) {
    last = now;
    paint();
  }
}
