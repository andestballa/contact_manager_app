// lib/providers/contact_provider.dart
import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../services/contact_service.dart';
import '../services/csv_service.dart';

class ContactProvider extends ChangeNotifier {
  final ContactService _service = ContactService();

  // -----------------------------
  // CONTACT LIST STATE
  // -----------------------------
  List<ContactModel> _contacts = [];
  bool _isLoading = false;
  String? _error;

  int _currentPage = 1;
  int _totalPages = 1;
  int _importedContactsCount = 0;

  List<ContactModel> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get importedContactsCount => _importedContactsCount;

  Future<void> fetchContacts({int page = 1}) async {
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

      final totalCount = data['count'] ?? (contacts.length * page);
      final pageSize = results.isNotEmpty ? results.length : 5;
      _totalPages = (totalCount / pageSize).ceil();

      // Clamp page
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

  Future<void> createContact(ContactModel contact) async {
    _isLoading = true;
    notifyListeners();
    await _service.createContact(contact);
    await fetchContacts(page: _currentPage);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateContact(ContactModel contact) async {
    _isLoading = true;
    notifyListeners();
    await _service.updateContact(contact);
    await fetchContacts(page: _currentPage);
    _isLoading = false;
    notifyListeners();
  }

  // -----------------------------
  // ADD / EDIT CONTACT FORM STATE
  // -----------------------------
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoadingForm = false;

  String name = '';
  String surname = '';
  String email = '';
  String phoneNumber = '';

  void setFormData({
    String? name,
    String? surname,
    String? email,
    String? phoneNumber,
  }) {
    this.name = name ?? this.name;
    this.surname = surname ?? this.surname;
    this.email = email ?? this.email;
    this.phoneNumber = phoneNumber ?? this.phoneNumber;
    notifyListeners();
  }

  String getField(String field) {
    switch (field) {
      case 'name':
        return name;
      case 'surname':
        return surname;
      case 'email':
        return email;
      case 'phoneNumber':
        return phoneNumber;
      default:
        return '';
    }
  }

  void updateField(String field, String value) {
    switch (field) {
      case 'name':
        name = value;
        break;
      case 'surname':
        surname = value;
        break;
      case 'email':
        email = value;
        break;
      case 'phoneNumber':
        phoneNumber = value;
        break;
    }
    notifyListeners();
  }

  /// Submit contact form (create or update)
  Future<bool> submitContact(ContactModel? contact) async {
    if (!formKey.currentState!.validate()) return false;

    isLoadingForm = true;
    notifyListeners();

    final newContact = ContactModel(
      id: contact?.id,
      name: name.trim(),
      surname: surname.trim(),
      email: email.trim(),
      phoneNumber: phoneNumber.trim(),
    );

    try {
      if (contact != null) {
        await updateContact(newContact);
      } else {
        await createContact(newContact);
      }

      isLoadingForm = false;
      notifyListeners();
      return error == null;
    } catch (_) {
      isLoadingForm = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> importFromCsv() async {
    _isLoading = true;
    _error = null;
    _importedContactsCount = 0;
    notifyListeners();

    try {
      final csvService = CsvService();
      final successCount = await csvService.importContactsFromCsv();

      if (successCount == null) {
        _isLoading = false;
        notifyListeners();
        return; // User canceled file picking
      }

      _importedContactsCount = successCount;

      if (successCount == 0) {
        _error = 'No contacts were imported from the CSV file.';
      } else {
        print("✅ Successfully imported $successCount contacts");
      }

      await fetchContacts(page: 1); // Start from page 1 to see new imports
    } catch (e) {
      _error = e.toString();
      _importedContactsCount = 0;
      print("❌ Import error: $_error");
    }

    _isLoading = false;
    notifyListeners();
  }
}
