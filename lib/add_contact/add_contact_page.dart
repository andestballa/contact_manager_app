// lib/ui/add_contact_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/contact_provider.dart';
import '../models/contact_model.dart';

class AddContactPage extends StatelessWidget {
  final ContactModel? contact;

  const AddContactPage({super.key, this.contact});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ContactProvider>();
    final isEditing = contact != null;

    // TODO providers should not set values in the build methods
    // Initialize form values in provider
    provider.setFormData(
      name: contact?.name ?? '',
      surname: contact?.surname ?? '',
      email: contact?.email ?? '',
      phoneNumber: contact?.phoneNumber ?? '',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Contact" : "Add Contact"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<ContactProvider>(
          builder: (context, provider, _) {
            return Form(
              key: provider.formKey,
              child: Column(
                children: [
                  _buildTextField(provider, 'name', 'Name'),
                  _buildTextField(provider, 'surname', 'Surname'),
                  _buildTextField(provider, 'email', 'Email', keyboardType: TextInputType.emailAddress),
                  _buildTextField(provider, 'phoneNumber', 'Phone', keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              final success = await provider.submitContact(isEditing ? contact : null);
                              if (success && context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEditing ? "Update Contact" : "Add Contact"),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // TODO create widget instead of helper method, also no need to pass provider as a parameter as you can get it from context 
  Widget _buildTextField(ContactProvider provider, String field, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: provider.getField(field),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.trim().isEmpty ? "$label is required" : null,
        onChanged: (val) => provider.updateField(field, val),
      ),
    );
  }
}