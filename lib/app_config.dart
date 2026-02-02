import 'package:flutter/material.dart';

class AppConfig {
  // Replace with ngrok url
  static const baseUrl = "https://crownless-unrequited-hana.ngrok-free.dev";

  static final themeData = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  );
}
