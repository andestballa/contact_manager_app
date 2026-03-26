import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../services/contact_service.dart';

class SearchProvider extends ChangeNotifier {
  final ContactService _service = ContactService();

  List<ContactModel> _results = [];
  bool _isLoading = false;
  String? _error;
  String? _lastQuery; // ✅ store last search term

  // ---------------- Getters ----------------
  List<ContactModel> get results => _results;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get lastQuery => _lastQuery;

  /// Search contacts (no pagination here)
  Future<void> search(String query) async {
    final trimmedQuery = query.trim();
    _lastQuery = trimmedQuery; // ✅ save last search term

    if (trimmedQuery.isEmpty) {
      _results = [];
      _error = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _service.fetchContacts(page: 1, query: trimmedQuery);

      final resultsList = data['results'] as List<dynamic>;

      _results = resultsList.map((e) => ContactModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
      _results = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear search results
  void clear() {
    _results = [];
    _error = null;
    _lastQuery = null; // ✅ reset last query
    notifyListeners();
  }
}