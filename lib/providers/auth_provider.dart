import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  bool _initialized = false;

  String? get token => _token;
  bool get isLoggedIn => _token != null;
  bool get isInitialized => _initialized;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("auth_token");
    _initialized = true;
    notifyListeners();
  }

  Future<void> login(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    notifyListeners();
  }
}
