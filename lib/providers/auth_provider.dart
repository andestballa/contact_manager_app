import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../app_config.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  bool _initialized = false;
  bool _isLoading = false;
  String? _error;

  AuthProvider() {
    loadFromStorage();
  }

  String? get token => _token;
  bool get isLoggedIn => _token != null;
  bool get isInitialized => _initialized;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("auth_token");
    _initialized = true;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/api/login/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email.trim(), "password": password}),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("LOGIN DATA: $data");

        final token = data["token"];
        if (token == null || token.isEmpty) {
          _error = "Login failed: no token returned";
          print("ERROR: No token in response");
          return false;
        }

        await _saveToken(token);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data["error"] ?? "Login failed";
        print("LOGIN ERROR: $_error");
        return false;
      }
    } catch (e) {
      print("LOGIN EXCEPTION: $e");
      _error = "Network error: $e";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signup({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final url = Uri.parse("${AppConfig.baseUrl}/api/signup/");
      final response = await http.post(
        url,
        body: {
          "email": email.trim(),
          "password": password,
        },
      );

      print("SIGNUP STATUS: ${response.statusCode}");
      print("SIGNUP BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("SIGNUP DATA: $data");

        final token = data["token"];
        if (token == null || token.isEmpty) {
          _error = "Signup failed: no token returned";
          print("ERROR: No token in response");
          return false;
        }

        await _saveToken(token);
        return true;
      }

      final data = jsonDecode(response.body);
      _error = data["error"] ?? "Signup failed";
      print("SIGNUP ERROR: $_error");
      return false;
    } catch (e) {
      print("SIGNUP EXCEPTION: $e");
      _error = "Network error: $e";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
