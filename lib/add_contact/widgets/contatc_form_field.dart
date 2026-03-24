import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/contact_provider.dart';

class ContactFormField extends StatelessWidget {
  final String field;
  final String label;
  final TextInputType? keyboardType;

  const ContactFormField({
    super.key,
    required this.field,
    required this.label,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContactProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: provider.getField(field),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty
                ? "$label is required"
                : null,
        onChanged: (value) => provider.updateField(field, value),
      ),
    );
  }
}