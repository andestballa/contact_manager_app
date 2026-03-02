import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../services/contact_service.dart';

class SearchProvider extends ChangeNotifier {
  final ContactService _service = ContactService();

  List<ContactModel> _results = [];
  bool _isLoading = false;
  String? _error;

  List<ContactModel> get results => _results;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Search contacts (NO pagination logic here)
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data =
          await _service.fetchContacts(page: 1, query: query);

      final results = data['results'] as List;

      _results =
          results.map((e) => ContactModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
      _results = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _results = [];
    notifyListeners();
  }
}