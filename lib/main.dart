import 'package:flutter/material.dart';
import 'screens/evidence_collection_screen.dart';
import 'screens/hub_screen.dart';
import 'screens/notifications_screen.dart';

void main() {
  runApp(const AuraAgentApp());
}

class AuraAgentApp extends StatelessWidget {
  const AuraAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura-Agent Prototype',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HubScreen(),
    );
  }
}


