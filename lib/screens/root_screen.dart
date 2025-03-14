import 'package:chrome_dino/constant/dimentions.dart';
import 'package:chrome_dino/screens/dino_game.dart';
import 'package:chrome_dino/screens/logain_page.dart';
import 'package:flutter/material.dart';
import 'package:serial_port_win32/serial_port_win32.dart';

class RootScreen extends StatefulWidget {
  final double speedFator;

  const RootScreen({this.speedFator = 0.02});
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  String? connectedArduinoPort;
  bool isArduinoConnected = false;
  List<String> ports = [];

  @override
  void initState() {
    super.initState();
    checkAndConnectArduino();
  }

  void checkAndConnectArduino() {
    List<String> availablePorts = SerialPort.getAvailablePorts();

    // Filter only valid COM ports (COM1 to COM10)
    ports =
        availablePorts.where((port) {
          int? portNumber = int.tryParse(
            port.replaceAll(RegExp(r'[^0-9]'), ''),
          );
          return portNumber != null && portNumber >= 1 && portNumber <= 10;
        }).toList();

    print("Available COM Ports: $ports");

    for (String port in ports) {
      try {
        SerialPort serialPort = SerialPort(port);
        if (!serialPort.isOpened) {
          serialPort.open();
        }

        if (serialPort.isOpened) {
          setState(() {
            connectedArduinoPort = port;
            isArduinoConnected = true;
            serialPort.close();
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (context) => DinoGameScreen(
                      speedFactor: widget.speedFator,
                      connectedArduinoPort: connectedArduinoPort!,
                    ),
              ),
            );
          });
          return;
        }
      } catch (e) {
        print("⚠️ Error connecting to $port: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(left: Dimentions.widthPercentage(context, 40)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isArduinoConnected) ...[
              SizedBox(height: 20),
              Text("⚠️ Device not Connected. Please check ports."),
              ElevatedButton(
                onPressed:
                    () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage(),
                      ),
                    ),
                child: Text("Restart App"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
