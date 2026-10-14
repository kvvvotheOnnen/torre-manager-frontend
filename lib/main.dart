import 'package:flutter/material.dart';

void main() {
  runApp(const TorreManagerApp());
}

class TorreManagerApp extends StatelessWidget {
  const TorreManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Torre Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Torre Manager - Esperando conexión')),
      ),
    );
  }
}
