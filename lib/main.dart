import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        colorScheme: ColorScheme.light(primary: Colors.blueAccent, secondary: Colors.green),
      ),
      home: SensorDataPage(),
    );
  }
}

class SensorDataPage extends StatefulWidget {
  @override
  _SensorDataPageState createState() => _SensorDataPageState();
}

class _SensorDataPageState extends State<SensorDataPage> {
  String temperature = "--";
  String humidity = "--";
  String message = "Fetching data...";

  Future<void> fetchLatestSensorData() async {
    try {
      String backendHost = "127.0.0.1:5000"; 
      final url = Uri.parse('http://$backendHost/sensor-data');
      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            final latestData = data.last;
            temperature = (latestData['temperature']?.toString() ?? "--");
            humidity = (latestData['humidity']?.toString() ?? "--");
            message = "Data berhasil diperbarui!";
          });
        } else {
          setState(() {
            message = "Data tidak tersedia.";
          });
        }
      } else {
        setState(() {
          message = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        message = "Error: Gagal mengambil data. Periksa koneksi.";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLatestSensorData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: Text("IoT Sensor Data"),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,  // Ensures centering on different screen sizes
              children: [
                // Data Display Card
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.blue.withOpacity(0.1), spreadRadius: 3, blurRadius: 6),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Suhu: $temperature°C",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Kelembapan: $humidity%",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Message display
                Text(
                  message,
                  style: TextStyle(fontSize: 18, color: Colors.red, fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 40),
                // Refresh Button
                ElevatedButton(
                  onPressed: fetchLatestSensorData,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Refresh'),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(height: 20),
                // Navigate to Statistics Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StatisticsPage()),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bar_chart, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Statistik'),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<dynamic> sensorData = [];
  bool isLoading = true;

  Future<void> fetchAllSensorData() async {
    try {
      String backendHost = "127.0.0.1:5000"; // Ganti dengan alamat backend yang sesuai
      final url = Uri.parse('http://$backendHost/sensor-data');
      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          sensorData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          sensorData = [];
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        sensorData = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllSensorData();
  }

  @override
  Widget build(BuildContext context) {
    final highestTemperature = sensorData.isNotEmpty ? sensorData.reduce((a, b) => a['temperature'] > b['temperature'] ? a : b) : null;
    final lowestTemperature = sensorData.isNotEmpty ? sensorData.reduce((a, b) => a['temperature'] < b['temperature'] ? a : b) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text("Statistik Sensor"),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.blue.withOpacity(0.1), spreadRadius: 3, blurRadius: 6),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Suhu Tertinggi: ${highestTemperature != null ? highestTemperature['temperature'].toString() : "--"}°C",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                SizedBox(height: 10),
                Text(
                  "Suhu Terendah: ${lowestTemperature != null ? lowestTemperature['temperature'].toString() : "--"}°C",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sensorData.length,
              itemBuilder: (context, index) {
                final data = sensorData[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text("Suhu: ${data['temperature']}°C", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Kelembapan: ${data['humidity']}%", style: TextStyle(fontStyle: FontStyle.italic)),
                    leading: Icon(Icons.cloud, color: Colors.blue),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
