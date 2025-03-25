import 'dart:async';
import 'dart:convert';
import 'package:chrome_dino/constant/const.dart';
import 'package:chrome_dino/screens/root_screen.dart';
import 'package:flutter/material.dart';
import 'package:serial_port_win32/serial_port_win32.dart';

class DinoGameScreen extends StatefulWidget {
  final String connectedArduinoPort;
  final double speedFactor;

  const DinoGameScreen({
    this.speedFactor = 0.02,
    required this.connectedArduinoPort,
  });

  @override
  _DinoGameScreenState createState() => _DinoGameScreenState();
}

class _DinoGameScreenState extends State<DinoGameScreen> {
  double dinoY = 1;
  double gravity = 0.005;
  double velocity = 0;
  bool isJumping = false;
  List<double> cactusX = [1.5, 3.0, 4.5];
  Timer? gameLoop;
  SerialPort? port;
  Timer? serialListener;
  int score = 0;
  int jumpCount = 0;
  double speedMultiplier = 1.0;
  bool isListening = true;

  @override
  void initState() {
    super.initState();
    listenToArduino(SerialPort(widget.connectedArduinoPort));
    startGame();
  }

  void listenToArduino(SerialPort port) async {
    if (!port.isOpened) {
      print("❌ المنفذ غير مفتوح. فتح الاتصال...");
      port.open();
    }

    print("🔄 بدء الاستماع إلى Arduino...");

    serialListener = Timer.periodic(Duration(milliseconds: 100), (timer) async {
      while (port.isOpened) {
        try {
          final data = await port.readBytes(
            1024,
            timeout: Duration(milliseconds: 500),
          );

          if (data.isNotEmpty) {
            String message = utf8.decode(data).trim();

            print("📡 البيانات المستلمة: $message");

            if (message.contains("JUMP")) {
              setState(() => jump());
              print("⬆️ تنفيذ القفز!");
            }
          }
        } catch (e) {
          String errorMessage = e.toString();
          // Efficiently check for multiple error codes using RegExp
          if (RegExp(
            r"Win32 Error Code is (0|1|2|3|4|5|6|7|8|9|10)|ClearCommError",
          ).hasMatch(errorMessage)) {
            print("⚠️ Arduino disconnected. Stopping listener...");
            stopListening();
          }
        }
      }

      print("🔴 توقف الاستماع. المنفذ مغلق.");
    });
  }

  void stopListening() {
    try {
      serialListener?.cancel();
      if (port != null && port!.isOpened) {
        port!.close();
      }
      isListening = false;
      print("🛑 Stopped listening to Arduino.");
    } catch (e) {
      String errorMessage = e.toString();
      // Efficiently check for multiple error codes using RegExp
      if (RegExp(
        r"Win32 Error Code is (0|1|2|3|4|5|6|7|8|9|10)|ClearCommError",
      ).hasMatch(errorMessage)) {
        print("⚠️ Arduino disconnected. Stopping listener...");
        stopListening();
      }
    }
  }

  void startGame() {
    gameLoop = Timer.periodic(Duration(milliseconds: 20), (timer) {
      setState(() {
        if (isJumping) {
          velocity -= gravity * speedMultiplier;
          dinoY -= velocity;
          if (dinoY >= 1) {
            dinoY = 1;
            isJumping = false;
            jumpCount = 0;
          }
        }

        for (int i = 0; i < cactusX.length; i++) {
          cactusX[i] -= selectedSpeed * speedMultiplier;
          if (cactusX[i] < -1.5) {
            cactusX[i] = 1.5;
            score++;
          }
        }

        for (double cactus in cactusX) {
          if (cactus < 0.2 && cactus > -0.2 && dinoY > 0.8) {
            gameOver();
          }
        }
      });
    });
  }

  void jump({double jumpVelocity = 0.09}) {
    if (jumpCount < 2) {
      setState(() {
        isJumping = true;
        velocity = jumpVelocity;
        jumpCount++;
      });
    }
  }

  void gameOver() {
    gameLoop?.cancel();
    if (isListening) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text("Game Over"),
              content: Text("Try again!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    resetGame();
                  },
                  child: Text("Restart"),
                ),
              ],
            ),
      );
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: Colors.amberAccent.shade100,
              title: Text("⚠️⚠️Warninggg⚠️⚠️"),
              content: Text("Device is not connected 🛑🛑"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (BuildContext context) => RootScreen(),
                      ),
                    );
                  },
                  child: Text("Restart"),
                ),
              ],
            ),
      );
    }
  }

  void resetGame() {
    setState(() {
      dinoY = 1;
      cactusX = [1.5, 3.0, 4.5];
      score = 0;
      jumpCount = 0;
      speedMultiplier = 1.0;
      startGame();
    });
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Stack(
        children: [
          Align(
            alignment: Alignment(0, dinoY),
            child: Image.asset(
              'assets/images/dino.gif',
              height: 300,
              width: 300,
            ),
          ),
          for (double cactus in cactusX)
            Align(
              alignment: Alignment(cactus, 1),
              child: Image.asset("assets/images/cactus.png", width: 150),
            ),
        ],
      ),
    );
  }
}
