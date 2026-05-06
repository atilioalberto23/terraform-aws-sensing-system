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
const char* serverName =  "";

// ------------------- NTP --------------------
const char* ntpServer = "pool.ntp.org";
const long gmtOffset_sec = 0;
const int daylightOffset_sec = 0;

// ------------------- PINES HUZZAH32 --------------------
// DHT11
#define DHTTYPE DHT11
DHT dht1(14, DHTTYPE);   // A6
DHT dht2(32, DHTTYPE);   // A8
DHT dht3(12, DHTTYPE);   // A10
DHT dht4(27, DHTTYPE);   // A12

// DS18B20
OneWire oneWire1(26);   // A0
OneWire oneWire2(25);   // A1
OneWire oneWire3(15);   // A3
OneWire oneWire4(4);    // A5

DallasTemperature ds1(&oneWire1);
DallasTemperature ds2(&oneWire2);
DallasTemperature ds3(&oneWire3);
DallasTemperature ds4(&oneWire4);

// ------------------- STRUCT DE LECTURA -------------------
struct SensorData {
  float temp_dht[4];
  float hum_dht[4];
  float temp_ds[4];
};

// ------------------- HORA ISO8601 -------------------
String getISO8601Time() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) return "";
  char buffer[30];
  strftime(buffer, sizeof(buffer), "%Y-%m-%dT%H:%M:%SZ", &timeinfo);
  return String(buffer);
}

// ------------------- LECTURA DE SENSORES -------------------
SensorData readSensors() {
  SensorData data;

  // DHT11 readings
  data.temp_dht[0] = dht1.readTemperature();
  data.hum_dht[0]  = dht1.readHumidity();

  data.temp_dht[1] = dht2.readTemperature();
  data.hum_dht[1]  = dht2.readHumidity();

  data.temp_dht[2] = dht3.readTemperature();
  data.hum_dht[2]  = dht3.readHumidity();

  data.temp_dht[3] = dht4.readTemperature();
  data.hum_dht[3]  = dht4.readHumidity();

  // DS18B20 readings
  ds1.requestTemperatures();
  ds2.requestTemperatures();
  ds3.requestTemperatures();
  ds4.requestTemperatures();

  data.temp_ds[0] = ds1.getTempCByIndex(0);
  data.temp_ds[1] = ds2.getTempCByIndex(0);
  data.temp_ds[2] = ds3.getTempCByIndex(0);
  data.temp_ds[3] = ds4.getTempCByIndex(0);

  return data;
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
  Serial.println("\nConectado a WiFi!");

  // Inicializar DHT
  dht1.begin();
  dht2.begin();
  dht3.begin();
  dht4.begin();

  // Inicializar DS18B20
  ds1.begin();
  ds2.begin();
  ds3.begin();
  ds4.begin();

  // Sincronizar hora NTP
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
}

// ------------------- LOOP -------------------
void loop() {

  if (WiFi.status() == WL_CONNECTED) {

    SensorData s = readSensors();

    HTTPClient http;
    http.begin(serverName);
    http.addHeader("Content-Type", "application/json");

    DynamicJsonDocument doc(1024);
    doc["sensor_id"] = "sensor001";
    doc["request_time"] = getISO8601Time();

    JsonObject payload = doc.createNestedObject("payload");
    payload["msr_prd_id"] = 20250302115930;

    // DHT11 values
    payload["dht1_temp"] = s.temp_dht[0];
    payload["dht1_hum"]  = s.hum_dht[0];

    payload["dht2_temp"] = s.temp_dht[1];
    payload["dht2_hum"]  = s.hum_dht[1];

    payload["dht3_temp"] = s.temp_dht[2];
    payload["dht3_hum"]  = s.hum_dht[2];

    payload["dht4_temp"] = s.temp_dht[3];
    payload["dht4_hum"]  = s.hum_dht[3];

    // DS18B20 values
    payload["ds1_temp"] = s.temp_ds[0];
    payload["ds2_temp"] = s.temp_ds[1];
    payload["ds3_temp"] = s.temp_ds[2];
    payload["ds4_temp"] = s.temp_ds[3];

    // Serializar JSON
    String jsonData;
    serializeJson(doc, jsonData);

    Serial.println("\n--- JSON ENVIADO ---");
    Serial.println(jsonData);

    // Enviar
    int httpResponseCode = http.POST(jsonData);

    Serial.print("HTTP Response: ");
    Serial.println(httpResponseCode);

    if (httpResponseCode > 0) {
      Serial.println("Respuesta del servidor:");
      Serial.println(http.getString());
    } else {
      Serial.print("Error enviando: ");
      Serial.println(httpResponseCode);
    }

    http.end();
  }
  else {
    Serial.println("Error: WiFi desconectado.");
  }

  delay(10000); // 10s
}