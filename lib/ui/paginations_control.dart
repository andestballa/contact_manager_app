import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contact_provider.dart';

class PaginationControls extends StatelessWidget {
  const PaginationControls({super.key});

  @override
  Widget build(BuildContext context) {
    final contactProvider = context.watch<ContactProvider>();

    // -----------------------------
    // Declare long variables first
    // -----------------------------
    final int currentPage = contactProvider.currentPage;
    final int totalPages = contactProvider.totalPages;

    final bool canGoBack = currentPage > 1;
    final bool canGoForward = currentPage < totalPages;

    // -----------------------------
    // Extract callbacks
    // -----------------------------
    VoidCallback? onBackPressed;
    if (canGoBack) {
      onBackPressed = () {
        contactProvider.fetchContacts(page: currentPage - 1);
      };
    }

    VoidCallback? onForwardPressed;
    if (canGoForward) {
      onForwardPressed = () {
        contactProvider.fetchContacts(page: currentPage + 1);
      };
    }

    // -----------------------------
    // Return widget
    // -----------------------------
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onBackPressed,
            icon: const Icon(Icons.arrow_back),
          ),
          Text(
            "Page $currentPage / $totalPages",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: onForwardPressed,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}