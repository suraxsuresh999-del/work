import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  late Future<List<Map<String, dynamic>>> _jobs;

  @override
  void initState() {
    super.initState();
    _jobs = _loadJobs();
  }

  Future<List<Map<String, dynamic>>> _loadJobs() async {
    final rows = await Supabase.instance.client
        .from('jobs')
        .select('id, title, description, budget_min, budget_max, experience_level, created_at')
        .eq('status', 'open')
        .order('created_at', ascending: false);
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  void _refresh() => setState(() => _jobs = _loadJobs());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _jobs,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Unable to load jobs. Please try again.'),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: _refresh, child: const Text('Retry')),
              ],
            ),
          );
        }
        final jobs = snapshot.data ?? const [];
        if (jobs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No projects are available right now. Check back soon.'),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final job = jobs[index];
              final min = job['budget_min'];
              final max = job['budget_max'];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(child: Icon(Icons.work_outline)),
                  title: Text(job['title'] as String? ?? 'Untitled project'),
                  subtitle: Text(
                    '${job['experience_level'] ?? 'Any experience'}\nRs. ${min ?? '-'} - ${max ?? '-'}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/job/${job['id']}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
