// lib/ui/add_contact_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contact_provider.dart';
import '../models/contact_model.dart';

class AddContactPage extends StatefulWidget {
  final ContactModel? contact;

  const AddContactPage({super.key, this.contact});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If editing, populate fields with existing contact data
    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
      _surnameController.text = widget.contact!.surname;
      _emailController.text = widget.contact!.email;
      _phoneController.text = widget.contact!.phoneNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final contact = widget.contact != null
        ? ContactModel(
            id: widget.contact!.id,
            name: _nameController.text,
            surname: _surnameController.text,
            email: _emailController.text,
            phoneNumber: _phoneController.text,
          )
        : ContactModel(
            name: _nameController.text,
            surname: _surnameController.text,
            email: _emailController.text,
            phoneNumber: _phoneController.text,
          );

    final provider = context.read<ContactProvider>();
    try {
      if (widget.contact != null) {
        await provider.updateContact(contact);
      } else {
        await provider.createContact(contact);
      }

      if (provider.error == null) {
        Navigator.pop(context); // Back to ContactPage
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error!)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contact != null;
    final title = isEditing ? "Edit Contact" : "Add Contact";
    final buttonText = isEditing ? "Update Contact" : "Add Contact";

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) =>
                    value!.isEmpty ? "Name is required" : null,
              ),
              TextFormField(
                controller: _surnameController,
                decoration: const InputDecoration(labelText: "Surname"),
                validator: (value) =>
                    value!.isEmpty ? "Surname is required" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) =>
                    value!.isEmpty ? "Email is required" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                validator: (value) =>
                    value!.isEmpty ? "Phone is required" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
