import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_config.dart';
import 'providers/auth_provider.dart';
import 'auth_gate.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..loadFromStorage(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppConfig.themeData,
      home: const AuthGate(),
    );
  }
}
