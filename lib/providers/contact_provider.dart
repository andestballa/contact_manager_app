import 'package:flutter/material.dart';

import '../models/contact_model.dart';
import '../services/contact_service.dart';

class ContactProvider with ChangeNotifier {
  final ContactService _contactService = ContactService();

  List<ContactModel> _contacts = [];
  bool _isLoading = false;
  String? _error;

  List<ContactModel> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setState({bool? loading, String? error}) {
    if (loading != null) _isLoading = loading;
    _error = error;
    notifyListeners();
  }

  Future<void> fetchContacts() async {
    _setState(loading: true, error: null);

    try {
      _contacts = await _contactService.fetchContacts();
    } catch (e) {
      _setState(error: e.toString());
    } finally {
      _setState(loading: false);
    }
  }

  Future<void> createContact(ContactModel contact) async {
    _setState(loading: true, error: null);

    try {
      final newContact = await _contactService.createContact(contact);
      _contacts.add(newContact);
      notifyListeners();
    } catch (e) {
      _setState(error: e.toString());
    } finally {
      _setState(loading: false);
    }
  }

  Future<void> deleteContact(int contactId) async {
    _setState(error: null);

    final index = _contacts.indexWhere((c) => c.id == contactId);
    if (index == -1) return;

    final removed = _contacts[index];
    _contacts.removeAt(index);
    notifyListeners();

    try {
      await _contactService.deleteContact(contactId);
    } catch (e) {
      _contacts.insert(index, removed);
      _setState(error: e.toString());
    }
  }

  void clear() {
    _contacts = [];
    _error = null;
    notifyListeners();
  }
}
