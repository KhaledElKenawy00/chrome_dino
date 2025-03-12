import 'dart:io';

import 'package:chrome_dino/constant/const.dart';
import 'package:chrome_dino/screens/dino_game.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'package:restart_app/restart_app.dart';
import 'package:serial_port_win32/serial_port_win32.dart'; // For COM port access

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    super.initState();
    checkAndConnectArduino(); // Check for COM ports when the screen loads
  }

  void checkAndConnectArduino() {
    List<String> availablePorts = SerialPort.getAvailablePorts();

    // Filter COM ports from COM1 to COM10
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
            connectedAurduinoPort = port;
            print("✅ Arduino found on $connectedAurduinoPort");
            isArduinoConnected = true;
            serialPort.close(); // Close the port after confirming connection
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (context) => DinoGameScreen(
                      connectedArduinoPort: connectedAurduinoPort,
                    ),
              ),
            );
          });
          return; // Stop checking further since Arduino is found
        }
      } catch (e) {
        print("⚠️ Error connecting to $port: $e");
      }
    }
  }

  void restartApplication() async {
    String executable = Platform.resolvedExecutable;
    String script = Platform.script.toFilePath();

    if (Platform.isWindows) {
      await Shell().run('taskkill /F /IM ${executable.split("\\").last}');
      await Process.start(executable, [script]);
      exit(0);
    } else {
      await Restart.restartApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text("Arduino not Connected. Please check ports again."),
          ),
          ElevatedButton(
            onPressed: () async {
              // Restart logic here
              restartApplication();
            },
            child: Text("Restart App"),
          ),
        ],
      ),
    );
  }
}
