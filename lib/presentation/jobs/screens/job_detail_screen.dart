import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../common/widgets/ws_button.dart';

class JobDetailScreen extends StatelessWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: const Text('Open'),
                  backgroundColor: Colors.green[50],
                  labelStyle: TextStyle(color: Colors.green[800]),
                ),
                const Spacer(),
                Text(
                  'Posted 2 hours ago',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Build a Flutter E-commerce Mobile App',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.currency_rupee, size: 20, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '₹10,000 - ₹25,000',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                const Text('(Fixed Price)'),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'We are looking for an experienced Flutter developer to create a responsive and smooth e-commerce app for our local business in Chennai. The app will feature Supabase Auth, Razorpay integration, and product catalogs.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Required Skills',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                Chip(label: Text('Flutter')),
                Chip(label: Text('Dart')),
                Chip(label: Text('Supabase')),
                Chip(label: Text('Razorpay')),
              ],
            ),
            const SizedBox(height: 32),
            WsButton(
              text: 'Apply / Submit Proposal',
              width: double.infinity,
              onPressed: () {
                // Show proposal modal or navigate
              },
            ),
          ],
        ),
      ),
    );
  }
}
