#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <time.h>

// Configura tu red WiFi
const char* ssid = "COWIFI17517225/0";
const char* password = "WiFi-85378219";

// URL del endpoint de la API (revisa que termine con /data si así lo definiste)
const char* serverName = "https://73r0vyqss8.execute-api.us-east-1.amazonaws.com/prod/data";

// Configurar NTP para obtener hora UTC
const char* ntpServer = "pool.ntp.org";
const long gmtOffset_sec = 0;
const int daylightOffset_sec = 0;

String getISO8601Time() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    return "";
  }
  char buffer[30];
  strftime(buffer, sizeof(buffer), "%Y-%m-%dT%H:%M:%SZ", &timeinfo);
  return String(buffer);
}

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);

  Serial.print("Conectando a WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }
  Serial.println("\nConectado a WiFi!");

  // Sincronizar hora
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(serverName);
    http.addHeader("Content-Type", "application/json");

    // Crear JSON con los campos esperados por la Lambda
    DynamicJsonDocument doc(256);
    doc["sensor_id"] = "sensor001";
    doc["request_time"] = getISO8601Time();

    JsonObject payload = doc.createNestedObject("payload");
    payload["temperature"] = 23.5;
    payload["humidity"] = 60.0;

    String jsonData;
    serializeJson(doc, jsonData);

    Serial.println("Enviando JSON:");
    Serial.println(jsonData);

    int httpResponseCode = http.POST(jsonData);

    if (httpResponseCode > 0) {
      Serial.print("Código de respuesta HTTP: ");
      Serial.println(httpResponseCode);
      String response = http.getString();
      Serial.println(response);
    } else {
      Serial.print("Error al enviar solicitud. Código: ");
      Serial.println(httpResponseCode);
    }

    http.end();
  } else {
    Serial.println("Error de conexión WiFi.");
  }

  delay(10000);
}
