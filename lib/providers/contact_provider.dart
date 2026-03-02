import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../services/contact_service.dart';

class ContactProvider extends ChangeNotifier {
  final ContactService _service = ContactService();

  List<ContactModel> _contacts = [];
  bool _isLoading = false;
  String? _error;

  int _currentPage = 1;
  int _totalPages = 1;

  List<ContactModel> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

Future<void> fetchContacts({int page = 1}) async {
  // Prevent invalid page numbers
  if (page < 1) return;

  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final data = await _service.fetchContacts(page: page);

    List results = [];
    if (data['results'] is List<dynamic>) {
      results = data['results'];
    } else {
      results = data as List<dynamic>;
    }

    final contacts = results.map((e) => ContactModel.fromJson(e)).toList();

    // Calculate total pages based on current fetch
    final totalCount = data['count'] ?? (contacts.length * page);
    final pageSize = (results.length > 0) ? results.length : 5;

    _totalPages = (totalCount / pageSize).ceil();

    // Safety: clamp page
    if (page > _totalPages && _totalPages > 0) {
      _currentPage = _totalPages;
      _contacts = contacts;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _contacts = contacts;
    _currentPage = page;
  } catch (e) {
    // If backend returns 404 or empty page, just ignore and do not crash
    if (e.toString().contains("404")) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _error = e.toString();
  }

  _isLoading = false;
  notifyListeners();
}

  /// Create new contact
  Future<void> createContact(ContactModel contact) async {
    await _service.createContact(contact);
    await fetchContacts(page: _currentPage);
  }

  /// Update existing contact
  Future<void> updateContact(ContactModel contact) async {
    await _service.updateContact(contact);
    await fetchContacts(page: _currentPage);
  }
}