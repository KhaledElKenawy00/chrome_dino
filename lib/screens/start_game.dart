import 'package:chrome_dino/constant/dimentions.dart';
import 'package:chrome_dino/screens/root_screen.dart';
import 'package:flutter/material.dart';

class StartGamePage extends StatefulWidget {
  const StartGamePage({super.key});

  @override
  _StartGamePageState createState() => _StartGamePageState();
}

class _StartGamePageState extends State<StartGamePage> {
  double _selectedSpeed = 0.01; // Default speed factor

  @override
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
            const Text(
              "اختر سرعة اللعبة:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButton<double>(
              value: _selectedSpeed,
              items:
                  List.generate(9, (index) => (index + 1) * 0.01)
                      .map<DropdownMenuItem<double>>(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.toStringAsFixed(2)),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSpeed = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => RootScreen()));
              },
              child: const Text("ابدأ اللعبة"),
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
