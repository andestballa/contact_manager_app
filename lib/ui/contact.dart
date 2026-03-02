import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/contact_provider.dart';
import '../providers/search_provider.dart';
import '../add_contact/add_contact_page.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TextEditingController _searchController = TextEditingController();

  bool get _isSearching => _searchController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactProvider>().fetchContacts(page: 1);
    });
  }

  Future<void> _onRefresh() async {
    if (_isSearching) {
      await context
          .read<SearchProvider>()
          .search(_searchController.text);
    } else {
      await context.read<ContactProvider>().fetchContacts(page: 1);
    }
  }

  void _onSearchChanged(String value) {
    if (value.trim().isEmpty) {
      context.read<SearchProvider>().clear();
    } else {
      context.read<SearchProvider>().search(value);
    }
    setState(() {}); // refresh UI for suffix icon + pagination toggle
  }

  @override
  Widget build(BuildContext context) {
    final contactProvider = context.watch<ContactProvider>();
    final searchProvider = context.watch<SearchProvider>();

    final isSearching = _isSearching;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts"),
        actions: [
          IconButton(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddContactPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // -----------------------
          // SEARCH BAR
          // -----------------------
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search contacts...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<SearchProvider>().clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          // -----------------------
          // LIST SECTION
          // -----------------------
          Expanded(
            child: Builder(
              builder: (_) {
                // -----------------------
                // SEARCH MODE
                // -----------------------
                if (isSearching) {
                  if (searchProvider.isLoading) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (searchProvider.error != null) {
                    return Center(
                        child: Text(searchProvider.error!));
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
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      itemCount: searchProvider.results.length,
                      itemBuilder: (context, index) {
                        final contact =
                            searchProvider.results[index];

                        return ListTile(
                          title: Text(
                              "${contact.name} ${contact.surname}"),
                          subtitle: Text(contact.email),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddContactPage(
                                        contact: contact),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }

                // -----------------------
                // NORMAL PAGINATED MODE
                // -----------------------
                if (contactProvider.isLoading &&
                    contactProvider.contacts.isEmpty) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (contactProvider.error != null) {
                  return Center(
                      child: Text(contactProvider.error!));
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
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    itemCount:
                        contactProvider.contacts.length,
                    itemBuilder: (context, index) {
                      final contact =
                          contactProvider.contacts[index];

                      return ListTile(
                        title: Text(
                            "${contact.name} ${contact.surname}"),
                        subtitle: Text(contact.email),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddContactPage(
                                      contact: contact),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // -----------------------
          // PAGINATION (HIDE WHEN SEARCHING)
          // -----------------------
          if (!isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: contactProvider.currentPage > 1
                        ? () => contactProvider.fetchContacts(
                              page: contactProvider.currentPage -
                                  1,
                            )
                        : null,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    "Page ${contactProvider.currentPage}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: contactProvider.currentPage <
                            contactProvider.totalPages
                        ? () => contactProvider.fetchContacts(
                              page: contactProvider.currentPage +
                                  1,
                            )
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}