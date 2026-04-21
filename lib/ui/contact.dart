import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/contact_provider.dart';
import '../providers/search_provider.dart';
import '../add_contact/add_contact_page.dart';
import '../ui/paginations_control.dart';
import '../contact/widgeds/contact_list_widget.dart';
import '../contact/widgeds/search_results_widget.dart';
import '../core/extensions/snackbar_extension.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    if (_isSearching) {
      await context.read<SearchProvider>().search(_searchController.text);
    } else {
      await context.read<ContactProvider>().fetchContacts(page: 1);
    }
  }

  void _onSearchChanged(String value) {
    final searchProvider = context.read<SearchProvider>();
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      searchProvider.clear();
    } else {
      searchProvider.search(trimmedValue);
    }

    setState(() {});
  }

  void _clearSearch() {
    final searchProvider = context.read<SearchProvider>();
    _searchController.clear();
    searchProvider.clear();
    setState(() {});
  }

  Future<void> _importCsv() async {
    final provider = context.read<ContactProvider>();

    await provider.importFromCsv();

    if (!mounted) return;

    if (provider.error != null) {
      context.showErrorSnackBar("Import failed: ${provider.error}");
    } else if (provider.importedContactsCount > 0) {
      context.showSuccessSnackBar(
        "✅ Imported ${provider.importedContactsCount} contacts successfully!",
      );
    } else {
      context.showErrorSnackBar("No contacts were imported from CSV.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _isSearching;
    final isLoading = context.watch<ContactProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts"),
        actions: [
          // Refresh
          IconButton(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
          ),

          // CSV Import
          IconButton(
            onPressed: isLoading ? null : _importCsv,
            icon: const Icon(Icons.upload_file),
            tooltip: "Import CSV",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddContactPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // SEARCH BAR
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
                        onPressed: _clearSearch,
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          // LIST SECTION
          Expanded(
            child: isSearching
                ? const SearchResultsWidget()
                : const ContactListWidget(),
          ),

          // PAGINATION
          if (!isSearching) const PaginationControls(),
        ],
      ),
    );
  }
}
