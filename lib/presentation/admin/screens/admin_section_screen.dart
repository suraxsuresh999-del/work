import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminSectionScreen extends StatefulWidget {
  final String section;

  const AdminSectionScreen({super.key, required this.section});

  @override
  State<AdminSectionScreen> createState() => _AdminSectionScreenState();
}

class _AdminSectionScreenState extends State<AdminSectionScreen> {
  late Future<List<Map<String, dynamic>>> _items;

  @override
  void initState() {
    super.initState();
    _items = _loadItems();
  }

  Future<List<Map<String, dynamic>>> _loadItems() async {
    final client = Supabase.instance.client;
    final section = widget.section;
    final rows = section == 'users'
        ? await client.from('profiles').select('id, full_name, email, user_type, verification_status, created_at').order('created_at', ascending: false).limit(50)
        : section == 'jobs'
            ? await client.from('jobs').select('id, title, status, budget_min, budget_max, created_at').order('created_at', ascending: false).limit(50)
            : section == 'projects'
                ? await client.from('projects').select('id, title, status, total_amount, payment_status, created_at').order('created_at', ascending: false).limit(50)
                : section == 'transactions'
                    ? await client.from('project_payment_transactions').select('transaction_id, project_name, amount, payment_method, payment_status, utr, created_at').order('created_at', ascending: false).limit(50)
                    : section == 'reports'
                        ? await client.from('reports').select('id, target_type, category, status, created_at, description').order('created_at', ascending: false).limit(50)
                        : <Map<String, dynamic>>[];

    return (rows as List).map((row) => Map<String, dynamic>.from(row as Map)).toList();
  }

  void _refresh() => setState(() => _items = _loadItems());

  String get _title => switch (widget.section) {
        'users' => 'Users Management',
        'jobs' => 'Jobs Management',
        'projects' => 'Projects Management',
        'transactions' => 'Transactions & Payments',
        'reports' => 'Reports & Disputes',
        _ => 'Admin Section',
      };

  @override
  Widget build(BuildContext context) {
    if (widget.section == 'support') {
      return Scaffold(
        appBar: AppBar(title: Text(_title)),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            Card(
              child: ListTile(
                leading: Icon(Icons.support_agent_outlined),
                title: Text('Support inbox'),
                subtitle: Text('Route support tickets, policy questions and customer messages here.'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.phone_outlined),
                title: Text('Contact us'),
                subtitle: Text('support@worksphere.example'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.help_outline),
                title: Text('Help center'),
                subtitle: Text('Add your FAQs and help articles in this section.'),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _items,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Unable to load this admin section.'),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: _refresh, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }

          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return const Center(child: Text('No records found.'));
          }

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    title: Text(_titleForItem(item)),
                    subtitle: Text(_subtitleForItem(item)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(_titleForItem(item)),
                        content: SingleChildScrollView(
                          child: SelectableText(item.entries.map((entry) => '${entry.key}: ${entry.value}').join('\n')),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _titleForItem(Map<String, dynamic> item) {
    return switch (widget.section) {
      'users' => item['full_name'] as String? ?? 'User',
      'jobs' => item['title'] as String? ?? 'Job',
      'projects' => item['title'] as String? ?? 'Project',
      'transactions' => item['transaction_id'] as String? ?? 'Transaction',
      'reports' => item['category'] as String? ?? 'Report',
      _ => 'Record',
    };
  }

  String _subtitleForItem(Map<String, dynamic> item) {
    return switch (widget.section) {
      'users' => '${item['email'] ?? ''} | ${item['user_type'] ?? ''}',
      'jobs' => '${item['status'] ?? ''} | ${item['budget_min'] ?? ''} - ${item['budget_max'] ?? ''}',
      'projects' => '${item['status'] ?? ''} | ${item['payment_status'] ?? ''}',
      'transactions' => '${item['payment_status'] ?? ''} | Rs. ${item['amount'] ?? ''}',
      'reports' => '${item['status'] ?? ''} | ${item['target_type'] ?? ''}',
      _ => '',
    };
  }
}
