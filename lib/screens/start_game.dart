import 'package:chrome_dino/constant/const.dart';
import 'package:chrome_dino/constant/dimentions.dart';
import 'package:chrome_dino/screens/emg_chart_page.dart';
import 'package:chrome_dino/screens/root_screen.dart';
import 'package:flutter/material.dart';
import 'package:serial_port_win32/serial_port_win32.dart';

class StartGamePage extends StatefulWidget {
  const StartGamePage({super.key});

  @override
  _StartGamePageState createState() => _StartGamePageState();
}

class _StartGamePageState extends State<StartGamePage> {
  SerialPort? arduinoPort;
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
        if (arduinoPort != null) {}
        break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkArduinoConnectedPortName();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Start Game"),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => StartGamePage(),
              ),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text(
                      "اختر سرعة اللعبة:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButton<double>(
                      value: selectedSpeed,
                      items:
                          List.generate(4, (index) => (index + 1) * 0.01)
                              .map<DropdownMenuItem<double>>(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value.toStringAsFixed(2)),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSpeed = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => RootScreen()),
                        );
                      },
                      child: const Text("ابدأ اللعبة"),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => EmgChartPage(),
                      ),
                    );
                  },
                  child: Container(
                    height: Dimentions.hightPercentage(context, 13),
                    width: Dimentions.widthPercentage(context, 25),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(
                        Dimentions.radiusPercentage(context, 5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Show EMG Curves",
                          style: TextStyle(
                            fontFamily: "Lemonada",
                            fontSize: Dimentions.fontPercentage(context, 3),
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Image.asset(
                          "assets/images/curve_icon.png",
                          height: Dimentions.hightPercentage(context, 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy game screen to receive the speed factor
class GameScreen extends StatelessWidget {
  final double speedFactor;
  const GameScreen({super.key, required this.speedFactor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Game Screen")),
      body: Center(
        child: Text(
          "🚀 سرعة اللعبة: $speedFactor",
          style: TextStyle(fontSize: Dimentions.hightPercentage(context, 2)),
        ),
      ),
    );
  }
}
