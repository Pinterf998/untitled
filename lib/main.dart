import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const HealthApp());
}

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '健康記錄',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HealthHomePage(),
    );
  }
}

class HealthHomePage extends StatefulWidget {
  const HealthHomePage({super.key});

  @override
  State<HealthHomePage> createState() => _HealthHomePageState();
}

class _HealthHomePageState extends State<HealthHomePage> {
  final List<Map<String, dynamic>> _records = [];

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();

  void _addRecord() {
    final String weightText = _weightController.text;
    final String systolicText = _systolicController.text;
    final String diastolicText = _diastolicController.text;

    if (weightText.isNotEmpty &&
        systolicText.isNotEmpty &&
        diastolicText.isNotEmpty) {
      setState(() {
        _records.add({
          'weight': double.tryParse(weightText) ?? 0.0,
          'systolic': int.tryParse(systolicText) ?? 0,
          'diastolic': int.tryParse(diastolicText) ?? 0,
          'date': DateTime.now(),
        });
      });
      _weightController.clear();
      _systolicController.clear();
      _diastolicController.clear();
    }
  }

  bool _isBloodPressureNormal(int systolic, int diastolic) {
    return (systolic >= 90 && systolic <= 120) && (diastolic >= 60 && diastolic <= 80);
  }

  String _timeSinceLastMeasurement(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays >= 1) {
      return '${difference.inDays}天前';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}小時前';
    } else {
      return '${difference.inMinutes}分鐘前';
    }
  }

  String _getHealthAdvice(int systolic, int diastolic) {
    if (systolic > 120 || diastolic > 80) {
      return '您的血壓偏高，請考慮降低鹽分攝取，增加運動量，並諮詢醫生';
    } else if (systolic < 90 || diastolic < 60) {
      return '您的血壓偏低，建議補充水分，保持適當的飲食，並諮詢醫生';
    } else {
      return '您的血壓正常，請繼續保持健康的生活習慣';
    }
  }

  void _deleteRecord(int index) {
    setState(() {
      _records.removeAt(index);
    });
  }

  List<FlSpot> _getBloodPressureData() {
    return _records
        .map((record) {
      return FlSpot(
        record['date'].millisecondsSinceEpoch.toDouble(),
        record['systolic'].toDouble(),
      );
    })
        .toList();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康記錄'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: '體重 (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _systolicController,
              decoration: const InputDecoration(
                labelText: '收縮壓 (mmHg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _diastolicController,
              decoration: const InputDecoration(
                labelText: '舒張壓 (mmHg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addRecord,
              child: const Text('新增記錄'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BloodPressureChartPage(records: _records),
                  ),
                );
              },
              child: const Text('查看圖表'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _records.length,
                itemBuilder: (context, index) {
                  final record = _records[index];
                  final isNormal = _isBloodPressureNormal(
                    record['systolic'],
                    record['diastolic'],
                  );
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(
                        isNormal ? Icons.check_circle : Icons.warning,
                        color: isNormal ? Colors.green : Colors.red,
                      ),
                      title: Text(
                          '體重: ${record['weight']} kg, 血壓: ${record['systolic']}/${record['diastolic']} mmHg'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('距離上次量測：${_timeSinceLastMeasurement(record['date'])}'),
                          Text('健康建議: ${_getHealthAdvice(record['systolic'], record['diastolic'])}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteRecord(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BloodPressureChartPage extends StatelessWidget {
  final List<Map<String, dynamic>> records;

  const BloodPressureChartPage({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> _getBloodPressureData() {
      return records
          .map((record) {
        return FlSpot(
          record['date'].millisecondsSinceEpoch.toDouble(),
          record['systolic'].toDouble(),
        );
      })
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('血壓圖表'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  minX: records.isEmpty
                      ? 0
                      : records.first['date']
                      .millisecondsSinceEpoch
                      .toDouble(),
                  maxX: records.isEmpty
                      ? 0
                      : records.last['date']
                      .millisecondsSinceEpoch
                      .toDouble(),
                  minY: 60,
                  maxY: 180,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getBloodPressureData(),
                      isCurved: true,
                      colors: [Colors.blue],
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
