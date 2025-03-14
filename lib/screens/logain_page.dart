import 'package:chrome_dino/constant/dimentions.dart';
import 'package:chrome_dino/screens/start_game.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 🔐 Hardcoded username & password (hashed)
  final String correctUsername = "admin";
  final String correctPasswordHash = "admin"; // Hash of "password"

  void _login() {
    String enteredUsername = _usernameController.text;
    String enteredPasswordHash = _passwordController.text;

    if (enteredUsername == correctUsername &&
        enteredPasswordHash == correctPasswordHash) {
      _showMessage("✅ تسجيل دخول ناجح!", Colors.green);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => StartGamePage()),
      );
    } else {
      _showMessage("❌ اسم المستخدم أو كلمة المرور غير صحيحة!", Colors.red);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            "Logain Page",
            style: TextStyle(
              fontFamily: "Lemonada",
              fontSize: Dimentions.fontPercentage(context, 5),
              color: Colors.black,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(Dimentions.hightPercentage(context, 3)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: Dimentions.hightPercentage(context, 3)),
              Text(
                "R F I",
                style: TextStyle(
                  fontFamily: "Lemonada",
                  fontSize: Dimentions.fontPercentage(context, 5),
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Dimentions.hightPercentage(context, 3)),

              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "اسم المستخدم",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "كلمة المرور",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text("تسجيل الدخول"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
