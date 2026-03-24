import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/contact_provider.dart';
import '../../add_contact/add_contact_page.dart';

class ContactListWidget extends StatelessWidget {
  const ContactListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final contactProvider = context.watch<ContactProvider>();

    if (contactProvider.isLoading &&
        contactProvider.contacts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (contactProvider.error != null) {
      return Center(child: Text(contactProvider.error!));
    }

    if (contactProvider.contacts.isEmpty) {
      return const Center(
        child: Text(
          "No contacts available",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await contactProvider.fetchContacts(page: 1);
      },
      child: ListView.builder(
        itemCount: contactProvider.contacts.length,
        itemBuilder: (context, index) {
          final contact = contactProvider.contacts[index];

          return ListTile(
            title: Text("${contact.name} ${contact.surname}"),
            subtitle: Text(contact.email),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddContactPage(contact: contact),
                ),
              );
            },
          );
        },
      ),
    );
  }
}