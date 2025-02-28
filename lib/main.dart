import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:serial_port_win32/serial_port_win32.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(DinoApp());
}

class DinoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DinoGameScreen(),
    );
  }
}

class DinoGameScreen extends StatefulWidget {
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
  Timer? speedTimer;
  int score = 0;
  int jumpCount = 0;
  double speedMultiplier = 1.0;

  SerialPort? port;
  Timer? serialListener;
  String buttonState = "Button Not Pressed";

  @override
  void initState() {
    super.initState();
    startGame();
    startSpeedTimer();
    connectToArduino();
  }

  void connectToArduino() {
    try {
      port = SerialPort("COM4"); // Ensure this is the correct port

      if (!port!.isOpened) {
        port!.open();
      }

      if (port!.isOpened) {
        print("✅ Connected to Arduino");
        startListening();
      } else {
        print("❌ Failed to connect to Arduino");
      }
    } catch (e) {
      print("⚠️ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to connect to Arduino. Check COM Port!"),
        ),
      );
    }
  }

  void startListening() {
    serialListener = Timer.periodic(Duration(milliseconds: 100), (timer) async {
      if (port != null && port!.isOpened) {
        try {
          Uint8List data = await port!.readBytes(
            32, // Increased buffer size
            timeout: Duration(seconds: 2),
          );

          if (data.isNotEmpty) {
            setState(() {
              jump();
            });
          }
        } catch (e) {
          print("⚠️ Serial Read Error: $e");
        }
      }
    });
  }

  void handleButtonPress() {
    if (shouldJump()) {
      jump();
    }
  }

  bool shouldJump() {
    for (double cactus in cactusX) {
      if (cactus < 0.2 && cactus > -0.2) {
        return true;
      }
    }
    return false;
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
          cactusX[i] -= 0.02 * speedMultiplier;
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

  void startSpeedTimer() {
    speedTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        speedMultiplier += 0.2;
      });
    });
  }

  void jump({double jumpVelocity = 0.07}) {
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
    speedTimer?.cancel();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Game Over"),
            content: Text("Score: $score"),
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
  }

  void resetGame() {
    setState(() {
      dinoY = 1;
      cactusX = [1.5, 3.0, 4.5];
      score = 0;
      jumpCount = 0;
      speedMultiplier = 1.0;
      startGame();
      startSpeedTimer();
    });
  }

  void showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    serialListener?.cancel();
    port?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Stack(
          children: [
            Align(
              alignment: Alignment(0, dinoY),
              child: Image.asset(
                'assets/images/dino.gif',
                height: 100,
                width: 100,
              ),
            ),
            for (double cactus in cactusX)
              Align(
                alignment: Alignment(cactus, 1),
                child: Image.asset("assets/images/cactus.png", width: 60),
              ),
            Positioned(
              top: 20,
              right: 20,
              child: Text(
                "Score: $score",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              top: 80,
              right: 20,
              child: Text(
                "Button: $buttonState",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
