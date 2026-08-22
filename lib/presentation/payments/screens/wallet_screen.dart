import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/enums/enums.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  late Future<List<Map<String, dynamic>>> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions = _loadTransactions();
  }

  Future<List<Map<String, dynamic>>> _loadTransactions() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    final client = Supabase.instance.client;
    if (user == null) return const [];

    final rows = user.type == UserType.freelancer
        ? await client
            .from('project_payment_transactions')
            .select()
            .eq('freelancer_id', user.id)
            .order('created_at', ascending: false)
            .limit(50)
        : await client
            .from('project_payment_transactions')
            .select()
            .eq('client_id', user.id)
            .order('created_at', ascending: false)
            .limit(50);
    return (rows as List).map((row) => Map<String, dynamic>.from(row as Map)).toList();
  }

  void _refresh() => setState(() => _transactions = _loadTransactions());

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isFreelancer = user?.type == UserType.freelancer;

    return Scaffold(
      appBar: AppBar(
        title: Text(isFreelancer ? 'Payments & Earnings' : 'Payments & Transactions'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _transactions,
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
                    const Text('Unable to load payment history.'),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: _refresh, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }

          final items = snapshot.data ?? const [];
          final total = items.fold<double>(0, (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0));
          final pending = items.where((item) => (item['payment_status'] as String?) == 'under_review' || (item['payment_status'] as String?) == 'payment_submitted').length;
          final verified = items.where((item) => (item['payment_status'] as String?) == 'verified').length;
          final rejected = items.where((item) => (item['payment_status'] as String?) == 'rejected').length;

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _SummaryCard(label: isFreelancer ? 'Total earnings' : 'Total paid', value: 'Rs. ${total.toStringAsFixed(2)}'),
                    _SummaryCard(label: 'Pending', value: '$pending'),
                    _SummaryCard(label: 'Verified', value: '$verified'),
                    _SummaryCard(label: 'Rejected', value: '$rejected'),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Recent transactions', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('No transactions found.'),
                  )
                else
                  ...items.map((item) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(isFreelancer ? Icons.trending_up_rounded : Icons.receipt_long_rounded),
                        ),
                        title: Text(item['project_name'] as String? ?? 'Project'),
                        subtitle: Text('${item['transaction_id'] ?? ''}\n${item['payment_status'] ?? ''}'),
                        isThreeLine: true,
                        trailing: Text(
                          'Rs. ${(item['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
