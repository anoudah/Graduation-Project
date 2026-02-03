import 'package:flutter/material.dart';

void main() {
  runApp(const WaselApp());
}

class WaselApp extends StatelessWidget {
  const WaselApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wasel', // Naming your app
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // You can change this to your brand color later
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text("Wasel System is running...")),
      ),
    );
  }
}