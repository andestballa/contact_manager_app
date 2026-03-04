import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contact_provider.dart';

class PaginationControls extends StatelessWidget {
  const PaginationControls({super.key});

  // TODO declare callbacks here instead of inlining in onPressed
  // TODO declare long variables before returning widget instead of inlining
  @override
  Widget build(BuildContext context) {
    final contactProvider = context.watch<ContactProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: contactProvider.currentPage > 1
                ? () => contactProvider.fetchContacts(
                      page: contactProvider.currentPage - 1,
                    )
                : null,
            icon: const Icon(Icons.arrow_back),
          ),
          Text(
            "Page ${contactProvider.currentPage} / ${contactProvider.totalPages}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed:
                contactProvider.currentPage < contactProvider.totalPages
                    ? () => contactProvider.fetchContacts(
                          page: contactProvider.currentPage + 1,
                        )
                    : null,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}