import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

import '../models/contact_model.dart';
import 'contact_service.dart';

class CsvService {
  final ContactService _service = ContactService();

  Future<int?> importContactsFromCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) return null;

    String csvString;
    final pickedFile = result.files.first;

    if (pickedFile.bytes != null) {
      csvString = utf8.decode(pickedFile.bytes!);
    } else if (pickedFile.path != null) {
      csvString = await File(pickedFile.path!).readAsString();
    } else {
      throw Exception('Unable to read CSV file contents');
    }

    csvString = csvString.replaceFirst('\ufeff', '');

    // Debug: Show raw CSV content
    print(
      'Raw CSV String (first 200 chars): ${csvString.substring(0, csvString.length > 200 ? 200 : csvString.length)}',
    );
    print('CSV String length: ${csvString.length}');
    print('Contains CRLF: ${csvString.contains('\r\n')}');
    print('Contains LF: ${csvString.contains('\n')}');

    // Try manual parsing first (more reliable for different line endings)
    print('Trying manual CSV parsing...');

    List<String> lines;
    if (csvString.contains('\r\n')) {
      lines = csvString.split('\r\n');
    } else if (csvString.contains('\r')) {
      lines = csvString.split('\r');
    } else {
      lines = csvString.split('\n');
    }

    lines = lines.where((line) => line.trim().isNotEmpty).toList();
    var rows = lines
        .map((line) => line.split(',').map((cell) => cell.trim()).toList())
        .toList();
    print('Manual parsing result: ${rows.length} rows');

    // Fallback to CsvToListConverter if manual parsing didn't work
    if (rows.length <= 1) {
      print('Manual parsing failed, trying CsvToListConverter...');
      rows = const CsvToListConverter().convert(csvString);

      final needsSemicolon = rows.any((row) {
        return row.length == 1 && row[0].toString().contains(';');
      });

      if (needsSemicolon) {
        rows = const CsvToListConverter(fieldDelimiter: ';').convert(csvString);
      }
      print('CsvToListConverter result: ${rows.length} rows');
    }

    // Debug: Show first few rows of CSV
    print('CSV Content Preview:');
    for (int i = 0; i < rows.length && i < 5; i++) {
      print('  Row ${i + 1}: ${rows[i]}');
    }

    // Validate that we have data rows (more than just header)
    print('CSV Import: ${rows.length} rows parsed');

    if (rows.isEmpty || rows.length < 2) {
      throw Exception(
        "CSV file is empty or contains only headers. Expected format:\nname,surname,email,phone_number\nJohn,Doe,john@example.com,1234567890",
      );
    }

    int successCount = 0;
    final List<String> errors = [];

    // Assuming first row is header → skip it
    for (int i = 1; i < rows.length; i++) {
      try {
        final row = rows[i];

        print('CSV Row ${i + 1}: $row');

        // Validate row has required columns
        if (row.length < 4) {
          errors.add("Row ${i + 1}: Missing required columns");
          continue;
        }

        // Skip empty rows
        if (row.every((cell) => cell.toString().trim().isEmpty)) {
          continue;
        }

        final contact = ContactModel(
          name: row[0].toString().trim(),
          surname: row[1].toString().trim(),
          email: row[2].toString().trim(),
          phoneNumber: row[3].toString().trim(),
        );

        print('Creating contact: ${contact.toJson()}');
        await _service.createContact(contact);
        successCount++;
      } catch (e) {
        errors.add("Row ${i + 1}: ${e.toString()}");
      }
    }

    // Throw error if no contacts were imported
    if (successCount == 0) {
      final errorMsg = errors.isNotEmpty
          ? "Failed to import any contacts: ${errors.take(3).join(', ')}"
          : "No valid contacts found in CSV";
      throw Exception(errorMsg);
    }

    // Log warnings if some rows failed
    if (errors.isNotEmpty) {
      print("CSV Import Warnings: ${errors.join('; ')}");
    }

    return successCount;
  }
}
