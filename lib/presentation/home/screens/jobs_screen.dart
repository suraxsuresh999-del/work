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
  _JobFilter _filter = _JobFilter.all;

  @override
  void initState() {
    super.initState();
    _jobs = _loadJobs();
  }

  Future<List<Map<String, dynamic>>> _loadJobs() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return const [];
    const select =
        'id, title, description, budget_min, budget_max, experience_level, '
        'category_label, required_skill_names, status, created_at';
    dynamic rows;
    switch (_filter) {
      case _JobFilter.saved:
        final saved = await client
            .from('saved_jobs')
            .select('job_id')
            .eq('freelancer_id', user.id);
        final ids = (saved as List)
            .map((row) => row['job_id'])
            .whereType<String>()
            .toSet()
            .toList();
        if (ids.isEmpty) return const [];
        rows = await client
            .from('jobs')
            .select(select)
            .inFilter('id', ids)
            .order('created_at', ascending: false);
        break;
      case _JobFilter.applied:
      case _JobFilter.interviews:
        var query = client
            .from('job_applications')
            .select('job_id')
            .eq('freelancer_id', user.id);
        if (_filter == _JobFilter.interviews) {
          query = query.eq('status', 'shortlisted');
        }
        final applications = await query;
        final ids = (applications as List)
            .map((row) => row['job_id'])
            .whereType<String>()
            .toSet()
            .toList();
        if (ids.isEmpty) return const [];
        rows = await client
            .from('jobs')
            .select(select)
            .inFilter('id', ids)
            .order('created_at', ascending: false);
        break;
      case _JobFilter.all:
        rows = await client
            .from('jobs')
            .select(select)
            .eq('status', 'open')
            .order('created_at', ascending: false);
        break;
    }
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  Future<void> _refresh() {
    final request = _loadJobs();
    setState(() => _jobs = request);
    return request.then<void>((_) {});
  }

  void _setFilter(_JobFilter value) {
    setState(() {
      _filter = value;
      _jobs = _loadJobs();
    });
  }

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
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<_JobFilter>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: _JobFilter.saved,
                      label: Text('Saved Jobs'),
                    ),
                    ButtonSegment(
                      value: _JobFilter.interviews,
                      label: Text('Interviews'),
                    ),
                    ButtonSegment(
                      value: _JobFilter.applied,
                      label: Text('Applied'),
                    ),
                    ButtonSegment(
                      value: _JobFilter.all,
                      label: Text('Show All'),
                    ),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (value) => _setFilter(value.first),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: jobs.isEmpty ? 1 : jobs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (jobs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('No jobs match this filter right now.'),
                        ),
                      );
                    }
                    final job = jobs[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const CircleAvatar(
                          child: Icon(Icons.work_outline),
                        ),
                        title: Text(job['title'] as String),
                        subtitle: Text(_summary(job)),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/job/${job['id']}'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _summary(Map<String, dynamic> job) {
    final details = <String>[];
    final experience = job['experience_level'] as String?;
    final description = job['description'] as String?;
    final minimum = job['budget_min'];
    final maximum = job['budget_max'];
    if (experience != null && experience.isNotEmpty) details.add(experience);
    if (description != null && description.isNotEmpty) details.add(description);
    if (minimum != null || maximum != null) {
      details.add(
        '₹${minimum ?? ''}${minimum != null && maximum != null ? ' – ' : ''}${maximum ?? ''}',
      );
    }
    return details.join('\n');
  }
}

enum _JobFilter { saved, interviews, applied, all }
