import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'ui/login.dart';
import 'ui/contact.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    print('AuthGate rebuild — loggedIn=${auth.isLoggedIn}');

    if (!auth.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // TODO why no const?
    return auth.isLoggedIn
        ? ContactPage() // ⬅️ NO const
        : LoginPage(); // ⬅️ NO const
  }
}
