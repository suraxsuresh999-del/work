import 'package:flutter/material.dart';

class AdminSupportDetailScreen extends StatelessWidget {
  final String section;

  const AdminSupportDetailScreen({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final details = switch (section) {
      'inbox' => ('Support Inbox', 'No support conversations are waiting for review.'),
      'contacts' => ('Contacts', 'No support contacts have been added yet.'),
      _ => ('Help Center', 'No help-center articles have been published yet.'),
    };
    return Scaffold(
      appBar: AppBar(title: Text(details.$1)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(details.$2, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
