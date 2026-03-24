import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/search_provider.dart';
import '../../add_contact/add_contact_page.dart';

class SearchResultsWidget extends StatelessWidget {
  const SearchResultsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    if (searchProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchProvider.error != null) {
      return Center(child: Text(searchProvider.error!));
    }

    if (searchProvider.results.isEmpty) {
      return const Center(
        child: Text(
          "No contacts found",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await searchProvider.search(
          searchProvider.lastQuery ?? "",
        );
      },
      child: ListView.builder(
        itemCount: searchProvider.results.length,
        itemBuilder: (context, index) {
          final contact = searchProvider.results[index];

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