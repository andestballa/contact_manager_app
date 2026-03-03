import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/contact_provider.dart';
import 'providers/search_provider.dart';
import 'auth_gate.dart';
import 'app_config.dart';

void main() {
  runApp(const MyApp());
}

// TODO create readme that explains the application infrastructure
// TODO fix linter problems

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),

        ChangeNotifierProvider<ContactProvider>(
          create: (_) => ContactProvider(),
        ),

        ChangeNotifierProvider<SearchProvider>(
          create: (_) => SearchProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Contact Manager',
        theme: AppConfig.themeData,
        home: const AuthGate(),
      ),
    );
  }
}
