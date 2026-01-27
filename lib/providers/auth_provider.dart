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

  String? get token => _token;
  bool get isLoggedIn => _token != null;
  bool get isInitialized => _initialized;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Thirret në start të app-it
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("auth_token");
    _initialized = true;
    notifyListeners();
  }

  /// LOGIN
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/login/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveToken(data["token"]);
        return true;
      } else {
        _error = data["error"] ?? "Login failed";
        return false;
      }
    } catch (e) {
      _error = "Network error";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// SIGNUP
  Future<bool> signup({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/signup/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveToken(data["token"]);
        return true;
      } else {
        _error = data["error"] ?? "Signup failed";
        return false;
      }
    } catch (e) {
      _error = "Network error";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    notifyListeners();
  }

  /// Helpers
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
