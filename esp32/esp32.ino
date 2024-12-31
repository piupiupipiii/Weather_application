#include <WiFi.h>
#include <HTTPClient.h>
#include <DHT.h>

// Konfigurasi WiFi
const char* ssid = "Minyi";          // Ganti dengan SSID WiFi Anda
const char* password = "lcdi2c8gb";  // Ganti dengan password WiFi Anda

// Konfigurasi DHT
#define DHTPIN 4 // Pin data DHT
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(115200);
  dht.begin();

  // Hubungkan ke WiFi
  Serial.println("Menghubungkan ke WiFi...");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }
  Serial.println("\nWiFi Terhubung!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;

    // Ganti dengan IP dan port server Flask
    http.begin("http://192.168.43.36:5000/sensor-data");
    http.addHeader("Content-Type", "application/json");

    // Baca data dari DHT
    float suhu = dht.readTemperature();
    float kelembapan = dht.readHumidity();

    // Cek validitas data
    if (isnan(suhu) || isnan(kelembapan)) {
      Serial.println("Gagal membaca data dari sensor DHT!");
      delay(5000);
      return;
    }

    // Buat JSON data
    String jsonData = "{\"temperature\": " + String(suhu) + ", \"humidity\": " + String(kelembapan) + "}";
    Serial.println("Mengirim data: " + jsonData);

    // Kirim POST request
    int httpResponseCode = http.POST(jsonData);

    // Tampilkan hasil pengiriman
    if (httpResponseCode > 0) {
      Serial.print("HTTP Response code: ");
      Serial.println(httpResponseCode);
      String response = http.getString();
      Serial.println("Response: " + response);
    } else {
      Serial.print("Error mengirim data. HTTP code: ");
      Serial.println(httpResponseCode);
    }

    http.end();
  } else {
    Serial.println("WiFi tidak terhubung!");
  }

  delay(15000); // Interval pengiriman data
}
