import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:serial_port_win32/serial_port_win32.dart';

class DinoGameProvider with ChangeNotifier {
  double dinoY = 1;
  double gravity = 0.005;
  double velocity = 0;
  bool isJumping = false;
  List<double> cactusX = [1.5, 3.0, 4.5];
  Timer? gameLoop;
  Timer? speedTimer;
  int score = 0;
  int jumpCount = 0;
  double speedMultiplier = 1.0;
  List<String> ports = [];
  bool isArduinoConnected = false;

  SerialPort? port;
  Timer? serialListener;

  void startListening() {
    serialListener = Timer.periodic(Duration(milliseconds: 100), (timer) async {
      if (port != null && port!.isOpened) {
        try {
          Uint8List data = await port!.readBytes(
            32, // Increased buffer size
            timeout: Duration(seconds: 2),
          );

          if (data.isNotEmpty) {
            jump();
          }
        } catch (e) {
          print("⚠️ Serial Read Error: $e");
        }
      }
    });
  }

  void startGame() {
    gameLoop = Timer.periodic(Duration(milliseconds: 20), (timer) {
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
        cactusX[i] -= 0.02 * speedMultiplier;
        if (cactusX[i] < -1.5) {
          cactusX[i] = 1.5;
          score++;
        }
      }

      for (double cactus in cactusX) {
        if (cactus < 0.2 && cactus > -0.2 && dinoY > 0.8) {
          if (port != null && port!.isOpened) {
            gameOver();
          }
        }
      }
      notifyListeners();
    });
  }

  void startSpeedTimer() {
    speedTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      speedMultiplier += 0.2;
      notifyListeners();
    });
  }

  void jump({double jumpVelocity = 0.07}) {
    if (jumpCount < 2) {
      isJumping = true;
      velocity = jumpVelocity;
      jumpCount++;
      notifyListeners();
    }
  }

  void gameOver() {
    gameLoop?.cancel();
    speedTimer?.cancel();
    notifyListeners();
  }

  void resetGame() {
    dinoY = 1;
    cactusX = [1.5, 3.0, 4.5];
    score = 0;
    jumpCount = 0;
    speedMultiplier = 1.0;
    startGame();
    startSpeedTimer();
    notifyListeners();
  }

  @override
  void dispose() {
    serialListener?.cancel();
    gameLoop?.cancel();
    speedTimer?.cancel();
    super.dispose();
  }
}
