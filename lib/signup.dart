import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:contact_manager_app/app_config.dart';
import 'providers/auth_provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/signup/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.text.trim(),
          "password": password.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await context.read<AuthProvider>().login(data["token"]);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"] ?? "Signup failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) =>
                    v != null && v.contains("@") ? null : "Invalid email",
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: password,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (v) =>
                    v != null && v.length >= 6 ? null : "Min 6 characters",
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _signup,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Sign Up"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Already have an account? Log in"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
