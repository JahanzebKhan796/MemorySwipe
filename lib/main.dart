import 'package:flutter/material.dart';
import 'game.dart'; // Make sure this file exists

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Detect taps anywhere
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GameScreen()),
        );
      },
      child: const Scaffold(
        backgroundColor: Colors.black, // ✅ Set background color
        body: Center(
          child: Text(
            "Start Game",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white, // ✅ Text color white
            ),
          ),
        ),
      ),
    );
  }
}
