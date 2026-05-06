#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <time.h>

#include <DHT.h>
#include <OneWire.h>
#include <DallasTemperature.h>

// ------------------- WIFI -------------------
const char* ssid = "CoffeeSolutionsDTX";
const char* password = "CoffeeSolutionsDTX";

// ------------------- API --------------------
const char* serverName =
  "https://kbmxq1670b.execute-api.us-east-1.amazonaws.com/prod/data";

// ------------------- NTP --------------------
const char* ntpServer = "pool.ntp.org";
const long gmtOffset_sec = 0;
const int daylightOffset_sec = 0;

// ------------------- SENSOR STRUCTS -------------------
struct OrientationInfo {
  const char* name;
  float x;
  float y;
};

struct SensorPoint {
  OrientationInfo orient;
  uint8_t dhtPin;
  uint8_t dsPin;

  DHT dht;
  DallasTemperature* ds;   // PUNTERO, no objeto
};

// ------------------- ORIENTACIONES -------------------
OrientationInfo NE = {"NE",  1,  1};
OrientationInfo NO = {"NO", -1,  1};
OrientationInfo SE = {"SE",  1, -1};
OrientationInfo SO = {"SO", -1, -1};

// ------------------- PINES -------------------
#define NE_DHT_PIN 32
#define NE_DS_PIN  26

#define NO_DHT_PIN 14
#define NO_DS_PIN  15

#define SE_DHT_PIN 27
#define SE_DS_PIN  12

#define SO_DHT_PIN 25
#define SO_DS_PIN   4

// ------------------- ONEWIRE + DS18B20 -------------------
OneWire owNE(NE_DS_PIN);
OneWire owNO(NO_DS_PIN);
OneWire owSE(SE_DS_PIN);
OneWire owSO(SO_DS_PIN);

DallasTemperature dsNE(&owNE);
DallasTemperature dsNO(&owNO);
DallasTemperature dsSE(&owSE);
DallasTemperature dsSO(&owSO);

// ------------------- POINTS -------------------
SensorPoint points[] = {
  {NE, NE_DHT_PIN, NE_DS_PIN, DHT(NE_DHT_PIN, DHT11), &dsNE},
  {NO, NO_DHT_PIN, NO_DS_PIN, DHT(NO_DHT_PIN, DHT11), &dsNO},
  {SE, SE_DHT_PIN, SE_DS_PIN, DHT(SE_DHT_PIN, DHT11), &dsSE},
  {SO, SO_DHT_PIN, SO_DS_PIN, DHT(SO_DHT_PIN, DHT11), &dsSO}
};

const int NUM_POINTS = 4;

// ------------------- ISO8601 -------------------
String getISO8601Time() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) return "";
  char buffer[30];
  strftime(buffer, sizeof(buffer), "%Y-%m-%dT%H:%M:%SZ", &timeinfo);
  return String(buffer);
}

// ------------------- SETUP -------------------
void setup() {
  Serial.begin(115200);

  WiFi.begin(ssid, password);
  Serial.print("Conectando a WiFi");

  while (WiFi.status() != WL_CONNECTED) {
    delay(800);
    Serial.print(".");
  }
  Serial.println("\nConectado!");

  // Iniciar DHT y DS
  for (int i = 0; i < NUM_POINTS; i++) {
    points[i].dht.begin();
  }

  dsNE.begin();
  dsNO.begin();
  dsSE.begin();
  dsSO.begin();

  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
}

// ------------------- LOOP -------------------
void loop() {

  if (WiFi.status() == WL_CONNECTED) {

    DynamicJsonDocument doc(2048);
    doc["sensor_id"] = "sensor001";
    doc["request_time"] = getISO8601Time();

    JsonObject payload = doc.createNestedObject("payload");
    payload["msr_prd_id"] = 20250302115930;

    // ----- LECTURA -----
    for (int i = 0; i < NUM_POINTS; i++) {

      points[i].ds->requestTemperatures();
      float dht_temp = points[i].dht.readTemperature();
      float dht_hum  = points[i].dht.readHumidity();
      float ds_temp  = points[i].ds->getTempCByIndex(0);

      String P = points[i].orient.name;

      payload[(P + "_dht_temp").c_str()] = dht_temp;
      payload[(P + "_dht_hum").c_str()]  = dht_hum;
      payload[(P + "_ds_temp").c_str()]  = ds_temp;

      payload[(P + "_coord_x").c_str()] = points[i].orient.x;
      payload[(P + "_coord_y").c_str()] = points[i].orient.y;
    }

    // ----- ENVÍO -----
    String jsonData;
    serializeJson(doc, jsonData);

    Serial.println("\n--- JSON ENVIADO ---");
    Serial.println(jsonData);

    HTTPClient http;
    http.begin(serverName);
    http.addHeader("Content-Type", "application/json");

    int httpResponseCode = http.POST(jsonData);
    Serial.print("HTTP Response: ");
    Serial.println(httpResponseCode);

    if (httpResponseCode > 0) {
      Serial.println(http.getString());
    }

    http.end();
  }

  delay(10000);
}