import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:serial_port_win32/serial_port_win32.dart';

class EmgChartPage extends StatefulWidget {
  @override
  State<EmgChartPage> createState() => _EmgChartPageState();
}

class _EmgChartPageState extends State<EmgChartPage> {
  StreamController<List<int>> _serialStreamController = StreamController();
  StreamSubscription<List<int>>? _serialSubscription;
  List<FlSpot> emgData_1 = [];
  List<FlSpot> emgData_2 = [];
  int xIndex = 0;
  SerialPort? arduinoPort;

  @override
  void initState() {
    super.initState();
    checkArduinoConnectedPortName();
  }

  void checkArduinoConnectedPortName() {
    final ports = SerialPort.getAvailablePorts();
    if (ports.isEmpty) {
      print("⚠️ لا توجد منافذ متاحة.");
      return;
    }

    final List<PortInfo> portInfoList = SerialPort.getPortsWithFullMessages();
    for (var portInfo in portInfoList) {
      print("🔍 فحص المنفذ: ${portInfo.portName}");
      if (portInfo.hardwareID.toLowerCase().contains("usb") ||
          portInfo.friendlyName.toLowerCase().contains("arduino")) {
        print("✅ تم العثور على Arduino في: ${portInfo.portName}");
        arduinoPort = SerialPort(portInfo.portName, BaudRate: 9600);
        if (arduinoPort != null) {
          listenToArduino(arduinoPort!);
        }
        break;
      }
    }
  }

  void listenToArduino(SerialPort port) {
    if (!port.isOpened) {
      print("❌ المنفذ غير مفتوح. فتح الاتصال...");
      port.open();
    }

    print("🔄 بدء الاستماع إلى Arduino...");
    _serialSubscription = _serialStreamController.stream.listen((data) {
      if (data.isNotEmpty) {
        String message = utf8.decode(data);
        RegExp regexRight = RegExp(r'right=\s*(-?\d+)');
        RegExp regexLeft = RegExp(r'left=\s*(-?\d+)');

        Match? matchRight = regexRight.firstMatch(message);
        Match? matchLeft = regexLeft.firstMatch(message);

        if (matchRight != null && matchLeft != null) {
          int rightValue = int.parse(matchRight.group(1)!);
          int leftValue = int.parse(matchLeft.group(1)!);

          print("✅ Received Right Value: $rightValue");
          print("✅ Received Left Value: $leftValue");

          if (mounted) {
            setState(() {
              if (emgData_1.length > 50) {
                emgData_1.removeAt(0);
              }
              emgData_1.add(FlSpot(xIndex.toDouble(), rightValue.toDouble()));

              if (emgData_2.length > 50) {
                emgData_2.removeAt(0);
              }
              emgData_2.add(FlSpot(xIndex.toDouble(), leftValue.toDouble()));

              xIndex++;
            });
          }
        } else {
          print("⚠️ لم يتم العثور على القيم المطلوبة.");
        }
      }
    });

    Timer.periodic(Duration(milliseconds: 100), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      try {
        final data = await port.readBytes(
          1024,
          timeout: Duration(milliseconds: 500),
        );
        if (data.isNotEmpty) {
          _serialStreamController.add(data);
        }
      } catch (e) {
        print("❌ خطأ أثناء القراءة: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic minY and maxY
    double minY = -100;
    double maxY = 900;

    if (emgData_1.isNotEmpty && emgData_2.isNotEmpty) {
      double minValue = emgData_1
          .map((e) => e.y)
          .reduce((a, b) => a < b ? a : b);
      double maxValue = emgData_2
          .map((e) => e.y)
          .reduce((a, b) => a > b ? a : b);

      minY = minValue < -100 ? minValue : -100;
      maxY = maxValue > 900 ? maxValue : 900;
    }

    return Scaffold(
      appBar: AppBar(title: Text("EMG Signal Chart")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.blue, width: 2),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: emgData_1.isEmpty ? [FlSpot(0, 0)] : emgData_1,
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
              ),
              LineChartBarData(
                spots: emgData_2.isEmpty ? [FlSpot(0, 0)] : emgData_2,
                isCurved: true,
                color: Colors.red,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _serialSubscription?.cancel();
    _serialStreamController.close();
    arduinoPort?.close();
    super.dispose();
  }
}
