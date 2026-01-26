import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // TODO: signup page

  final _formKey = GlobalKey<FormState>();

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState!.validate()) {
      // Here you would send data to backend
      print("Email: ${email.text}");
      print("Password: ${password.text}");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Signup successful")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) =>
                    value!.contains("@") ? null : "Enter a valid email",
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: password,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? "Minimum 6 characters" : null,
              ),
              const SizedBox(height: 12),

              ElevatedButton(onPressed: _signup, child: const Text("Sign Up")),
            ],
          ),
        ),
      ),
    );
  }
}
