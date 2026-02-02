import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contact_model.dart';
import '../app_config.dart';

class ContactService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Token $token',
  };

  Future<List<ContactModel>> fetchContacts() async {
    final token = await _getToken();
    if (token == null) throw Exception('No auth token found');

    final url = Uri.parse('${AppConfig.baseUrl}/api/contacts/list/');

    final response = await http.get(
      url,
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((json) => ContactModel.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch contacts (${response.statusCode})',
      );
    }
  }

  Future<ContactModel> createContact(ContactModel contact) async {
    final token = await _getToken();
    if (token == null) throw Exception('No auth token found');

    final url = Uri.parse('${AppConfig.baseUrl}/api/contacts/create/');

    final response = await http.post(
      url,
      headers: _headers(token),
      body: jsonEncode(contact.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return contact.copyWith(id: data['contact_id']);
    } else {
      throw Exception(
        'Failed to create contact (${response.statusCode})',
      );
    }
  }

  Future<void> updateContact(
    int contactId,
    ContactModel contact,
  ) async {
    final token = await _getToken();
    if (token == null) throw Exception('No auth token found');

    final url = Uri.parse(
      '${AppConfig.baseUrl}/api/contacts/update/$contactId/',
    );

    final response = await http.put(
      url,
      headers: _headers(token),
      body: jsonEncode(contact.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update contact (${response.statusCode})',
      );
    }
  }

  Future<void> deleteContact(int contactId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No auth token found');

    final url = Uri.parse(
      '${AppConfig.baseUrl}/api/contacts/delete/$contactId/',
    );

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete contact (${response.statusCode})',
      );
    }
  }
}
