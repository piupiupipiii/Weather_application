import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<dynamic> sensorData = [];
  bool isLoading = true;

  Future<void> fetchStatisticsData() async {
    try {
      String backendHost = "127.0.0.1:5000";
      final url = Uri.parse('http://$backendHost/sensor-data');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          sensorData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStatisticsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Statistik Sensor"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              series: <LineSeries>[
                LineSeries<dynamic, String>(
                  dataSource: sensorData,
                  xValueMapper: (data, _) => data['timestamp'],
                  yValueMapper: (data, _) => data['temperature'],
                  name: 'Temperature',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sensorData.length,
              itemBuilder: (context, index) {
                final data = sensorData[index];
                return ListTile(
                  title: Text("Suhu: ${data['temperature']}°C"),
                  subtitle: Text("Kelembapan: ${data['humidity']}%"),
                  trailing: Text(data['timestamp']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
