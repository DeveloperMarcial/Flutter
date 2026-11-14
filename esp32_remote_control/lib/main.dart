import 'package:flutter/material.dart';

void main() {
  runApp(const Esp32RemoteApp());
}

class Esp32RemoteApp extends StatelessWidget {
  const Esp32RemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Mesh Remote',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('ESP32-S3 Mesh Remote Control Initialized'),
        ),
      ),
    );
  }
}
