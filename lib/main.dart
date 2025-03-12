import 'package:chrome_dino/providers/dion_provider.dart';
import 'package:chrome_dino/screens/root_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(DinoApp());
}

class DinoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DinoGameProvider()),
      ],
      child: MaterialApp(debugShowCheckedModeBanner: false, home: RootScreen()),
    );
  }
}
