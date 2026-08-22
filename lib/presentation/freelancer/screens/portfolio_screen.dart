import 'package:flutter/material.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add portfolio item
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Portfolio Items (Phase 5 Implementation)'),
      ),
    );
  }
}
