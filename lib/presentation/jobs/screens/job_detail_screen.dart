import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../app/theme/app_colors.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late Future<Map<String, dynamic>?> _job;

  @override
  void initState() {
    super.initState();
    _job = _loadJob();
  }

  Future<Map<String, dynamic>?> _loadJob() async {
    final row = await Supabase.instance.client
        .from('jobs')
        .select(
          'id, title, description, budget_min, budget_max, experience_level, '
          'category_label, required_skill_names, status, created_at',
        )
        .eq('id', widget.jobId)
        .maybeSingle();
    return row == null ? null : Map<String, dynamic>.from(row);
  }

  Future<void> _refresh() {
    final request = _loadJob();
    setState(() => _job = request);
    return request.then<void>((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _job,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: OutlinedButton(
                onPressed: _refresh,
                child: const Text('Retry loading job'),
              ),
            );
          }
          final job = snapshot.data;
          if (job == null) {
            return const Center(
              child: Text('This job is no longer available.'),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    Chip(label: Text(_label(job['status']))),
                    const Spacer(),
                    Text(
                      _postedAt(job['created_at']),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  job['title'] as String,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if ((job['category_label'] as String? ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    job['category_label'] as String,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.currency_rupee,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _budget(job),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if ((job['experience_level'] as String? ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(job['experience_level'] as String),
                ],
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  job['description'] as String,
                  style: const TextStyle(height: 1.5),
                ),
                if (_skills(job).isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Required Skills',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skills(
                      job,
                    ).map((skill) => Chip(label: Text(skill))).toList(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<String> _skills(Map<String, dynamic> job) =>
      (job['required_skill_names'] as List? ?? const [])
          .map((skill) => skill.toString())
          .where((skill) => skill.isNotEmpty)
          .toList();

  String _budget(Map<String, dynamic> job) {
    final minimum = job['budget_min'];
    final maximum = job['budget_max'];
    if (minimum == null && maximum == null) return 'Budget not specified';
    if (minimum == null) return 'Up to ₹$maximum';
    if (maximum == null) return 'From ₹$minimum';
    return '₹$minimum – ₹$maximum';
  }

  String _label(Object? value) =>
      (value?.toString() ?? '').replaceAll('_', ' ').trim();

  String _postedAt(Object? value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    return date == null ? '' : 'Posted ${timeago.format(date)}';
  }
}
