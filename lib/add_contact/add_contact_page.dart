// lib/add_contact/add_contact_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/contact_provider.dart';
import '../models/contact_model.dart';
import 'widgets/contatc_form_field.dart';

class AddContactPage extends StatefulWidget {
  final ContactModel? contact;

  const AddContactPage({super.key, this.contact});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  @override
  void initState() {
    super.initState();

    // Initialize provider form data AFTER build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ContactProvider>();

      provider.setFormData(
        name: widget.contact?.name ?? '',
        surname: widget.contact?.surname ?? '',
        email: widget.contact?.email ?? '',
        phoneNumber: widget.contact?.phoneNumber ?? '',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contact != null;

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
                  const ContactFormField(
                    field: 'name',
                    label: 'Name',
                  ),
                  const ContactFormField(
                    field: 'surname',
                    label: 'Surname',
                  ),
                  const ContactFormField(
                    field: 'email',
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const ContactFormField(
                    field: 'phoneNumber',
                    label: 'Phone',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              final success = await provider.submitContact(
                                isEditing ? widget.contact : null,
                              );

                              if (success && context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isEditing
                                  ? "Update Contact"
                                  : "Add Contact",
                            ),
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
}