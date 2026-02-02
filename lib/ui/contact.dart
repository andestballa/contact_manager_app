import 'package:contact_manager_app/ui/add_contact_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/contact_provider.dart';
import '../../providers/auth_provider.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(fetchContacts);
  }

  Future<void> fetchContacts() async {
    if (!mounted) return;

    final provider = context.read<ContactProvider>();
    provider.fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContactProvider>();

    // TODO: move this in initState as a listener of ContactProvider instead
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO declare this as a function just like _openAddDialog
              context.read<ContactProvider>().clear();
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: _buildBody(provider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(ContactProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.contacts.isEmpty) {
      return const Center(child: Text('No contacts yet'));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ContactProvider>().fetchContacts(),
      child: ListView.builder(
        itemCount: provider.contacts.length,
        itemBuilder: (_, index) {
          final contact = provider.contacts[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(contact.name[0].toUpperCase()),
            ),
            title: Text('${contact.name} ${contact.surname}'),
            subtitle: Text(contact.email),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(contact.id!),
            ),
          );
        },
      ),
    );
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (_) => const AddContactDialog(),
    );
  }

  void _confirmDelete(int contactId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete contact?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<ContactProvider>().deleteContact(contactId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
