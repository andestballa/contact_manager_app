import 'package:contact_manager_app/app_config.dart';
import 'package:flutter/material.dart';
import 'login.dart'; // adjust path if needed

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // TODO: render home page if user is logged in (aka persist token)

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contact Manager',
      theme: AppConfig.themeData,
      home: const LoginPage(),
    );
  }
}
