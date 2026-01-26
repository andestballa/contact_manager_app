import 'package:flutter/material.dart';

class AppConfig {
  // Replace with ngrok url
  static const baseUrl = "https://ae041b757ef6.ngrok-free.app";

  static final themeData = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  );
}
