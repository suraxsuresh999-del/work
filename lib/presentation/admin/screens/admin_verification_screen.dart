import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/theme/app_colors.dart';

class AdminVerificationScreen extends StatefulWidget {
  const AdminVerificationScreen({super.key});

  @override
  State<AdminVerificationScreen> createState() => _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  late Future<List<Map<String, dynamic>>> _queue;

  @override
  void initState() {
    super.initState();
    _queue = _loadQueue();
  }

  Future<List<Map<String, dynamic>>> _loadQueue() async {
    final response = await Supabase.instance.client.rpc('get_admin_verification_queue');
    return (response as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  void _refresh() => setState(() => _queue = _loadQueue());

  Future<void> _review(Map<String, dynamic> request, String decision) async {
    final notes = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(decision == 'approved' ? 'Approve verification?' : 'Reject verification?'),
        content: TextField(
          controller: notes,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Review note (optional)',
            hintText: 'Explain the decision to the user',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(decision == 'approved' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await Supabase.instance.client.rpc(
        'review_verification_request',
        params: {
          'request_id_input': request['id'],
          'decision_input': decision,
          'admin_notes_input': notes.text.trim().isEmpty ? null : notes.text.trim(),
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification $decision.')),
      );
      _refresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The review could not be saved.')),
        );
      }
    } finally {
      notes.dispose();
    }
  }

  Future<void> _viewDocument(String path, String title) async {
    try {
      final url = await Supabase.instance.client.storage
          .from('documents')
          .createSignedUrl(path, 120);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(title: Text(title), automaticallyImplyLeading: false),
              InteractiveViewer(child: Image.network(url)),
            ],
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document preview is unavailable.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification queue'),
        actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _queue,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load the verification queue.'));
          }
          final requests = snapshot.data!;
          if (requests.isEmpty) {
            return const Center(child: Text('No verification requests are waiting.'));
          }
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final request = requests[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request['full_name'] as String,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(request['email'] as String),
                        const SizedBox(height: 12),
                        Chip(
                          avatar: const Icon(Icons.badge_outlined, size: 18),
                          label: Text(request['document_type'] as String),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _viewDocument(
                                request['document_path'] as String,
                                'Document',
                              ),
                              icon: const Icon(Icons.description_outlined),
                              label: const Text('Document'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _viewDocument(
                                request['selfie_path'] as String,
                                'Selfie',
                              ),
                              icon: const Icon(Icons.face_outlined),
                              label: const Text('Selfie'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _review(request, 'rejected'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red.shade700,
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () => _review(request, 'approved'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                ),
                                child: const Text('Approve'),
                              ),
                            ),
                          ],
                        ),
                      ],
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
}
