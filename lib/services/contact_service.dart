import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contact_model.dart';
import '../app_config.dart';

class ContactService {
  /// Get headers with token
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null) {
      throw Exception("User not authenticated");
    }

    return {
      "Content-Type": "application/json",
      "Authorization": "Token $token",
    };
  }

  /// Fetch contacts with optional search query and pagination
  Future<Map<String, dynamic>> fetchContacts({
    int page = 1,
    String query = "",
  }) async {
    String url;

    if (query.isNotEmpty) {
      url =
          "${AppConfig.baseUrl}/api/contacts/search/?q=$query&page=$page";
    } else {
      url =
          "${AppConfig.baseUrl}/api/contacts/list/?page=$page";
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );

    // 🔥 Debug log
    print("FETCH CONTACTS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to load contacts (${response.statusCode}): ${response.body}",
      );
    }

    final data = jsonDecode(response.body);

    // Handle non-paginated search response
    if (data is List) {
      return {
        "count": data.length,
        "page_size": data.length,
        "results": data,
        "next": null,
        "previous": null,
      };
    }

    return data;
  }

  /// Create new contact
  Future<void> createContact(ContactModel contact) async {
    final url = Uri.parse("${AppConfig.baseUrl}/api/contacts/create/");

    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode(contact.toJson()),
    );

    // 🔥 CRITICAL DEBUG LOGS
    print("CREATE CONTACT:");
    print("Request Body: ${jsonEncode(contact.toJson())}");
    print("Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode != 201) {
      throw Exception(
        "Failed to create contact: ${response.statusCode} - ${response.body}",
      );
    }
  }

  /// Update contact
  Future<void> updateContact(ContactModel contact) async {
    final url = Uri.parse(
      "${AppConfig.baseUrl}/api/contacts/update/${contact.id}/",
    );

    final response = await http.put(
      url,
      headers: await _headers(),
      body: jsonEncode(contact.toJson()),
    );

    // 🔥 Debug log
    print("UPDATE CONTACT:");
    print("Request Body: ${jsonEncode(contact.toJson())}");
    print("Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to update contact: ${response.statusCode} - ${response.body}",
      );
    }
  }
}