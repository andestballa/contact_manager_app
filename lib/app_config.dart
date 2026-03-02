import 'package:flutter/material.dart';

class AppConfig {
  // Replace with ngrok url
  static const baseUrl = "http://127.0.0.1:8000";

  static final themeData = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  );
}
