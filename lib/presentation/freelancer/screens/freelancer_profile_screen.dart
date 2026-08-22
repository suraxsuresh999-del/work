import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FreelancerProfileScreen extends StatefulWidget {
  final String freelancerId;
  const FreelancerProfileScreen({super.key, required this.freelancerId});

  @override
  State<FreelancerProfileScreen> createState() => _FreelancerProfileScreenState();
}

class _FreelancerProfileScreenState extends State<FreelancerProfileScreen> {
  late Future<Map<String, dynamic>?> _profile;

  @override
  void initState() {
    super.initState();
    _profile = _loadProfile();
  }

  Future<String?> _resolveAvatar(String? path) async {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http')) return path;
    try {
      return await Supabase.instance.client.storage.from('verification-documents').createSignedUrl(path, 600);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    final client = Supabase.instance.client;
    final response = await client.rpc('get_public_freelancer_profile', params: {'freelancer_id_input': widget.freelancerId});
    if (response == null) return null;
    final profile = Map<String, dynamic>.from(response as Map);
    profile['avatar_url'] = await _resolveAvatar(profile['avatar_url'] as String?);
    final portfolioRows = await client.from('portfolio_items').select().eq('freelancer_id', widget.freelancerId).order('created_at', ascending: false).limit(20);
    final experienceRows = await client.from('experience').select().eq('freelancer_id', widget.freelancerId).order('created_at', ascending: false).limit(10);
    final reviewRows = await client.from('reviews').select('rating, comment, created_at').eq('reviewee_id', widget.freelancerId).order('created_at', ascending: false).limit(10);
    profile['portfolio'] = (portfolioRows as List).map((row) => Map<String, dynamic>.from(row as Map)).toList();
    profile['experience'] = (experienceRows as List).map((row) => Map<String, dynamic>.from(row as Map)).toList();
    profile['reviews'] = (reviewRows as List).map((row) => Map<String, dynamic>.from(row as Map)).toList();
    return profile;
  }

  void _refresh() => setState(() => _profile = _loadProfile());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Freelancer Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profile,
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
                    const Text('Unable to load freelancer profile.'),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: _refresh, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }

          final profile = snapshot.data;
          if (profile == null) {
            return const Center(child: Text('Freelancer not found.'));
          }

          final avatarUrl = profile['avatar_url'] as String?;
          final paymentMethod = profile['payment_method'] as Map<String, dynamic>? ?? const {};
          final verified = (profile['verification_status'] as String?) == 'approved';
          final hasPaymentMethod = profile['has_payment_method'] == true;

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null ? Text(_initials(profile['full_name'] as String? ?? '')) : null,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(profile['full_name'] as String? ?? 'Freelancer', style: Theme.of(context).textTheme.headlineSmall),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(profile['title'] as String? ?? '', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      Chip(
                        avatar: Icon(verified ? Icons.verified : Icons.verified_outlined, color: verified ? Colors.green : null),
                        label: Text(verified ? 'Verified' : 'Not verified'),
                      ),
                      if (hasPaymentMethod) const Chip(label: Text('UPI Payment Available')),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _infoCard(
                  'About',
                  [
                    _infoRow('Bio', profile['bio'] as String?),
                    _infoRow('Location', _compact([profile['city_profile'], profile['district'], profile['state'], profile['country']])),
                    _infoRow('Skills', _listText(profile['languages'])),
                    _infoRow('Availability', profile['availability'] as String?),
                    _infoRow('Preferred work type', profile['preferred_work_type'] as String?),
                    _infoRow('Experience', profile['experience_level'] as String?),
                    _infoRow('Certifications', profile['certifications'] as String?),
                    _infoRow('Portfolio link', profile['portfolio_url'] as String?),
                  ],
                ),
                if (hasPaymentMethod)
                  _infoCard(
                    'Payment availability',
                    [
                      _infoRow('Status', paymentMethod['status'] as String?),
                      const Text('UPI Payment Available'),
                    ],
                  ),
                _listCard('Portfolio', (profile['portfolio'] as List).cast<Map<String, dynamic>>(), (item) => '${item['title'] ?? ''}\n${item['description'] ?? ''}'),
                _listCard('Experience', (profile['experience'] as List).cast<Map<String, dynamic>>(), (item) => '${item['title'] ?? ''} • ${item['company'] ?? ''}'),
                _listCard('Reviews', (profile['reviews'] as List).cast<Map<String, dynamic>>(), (item) => '${item['rating'] ?? ''} stars\n${item['comment'] ?? ''}'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _listCard(
    String title,
    List<Map<String, dynamic>> items,
    String Function(Map<String, dynamic>) builder,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Text('No records found.')
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(builder(item)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text((value == null || value.trim().isEmpty) ? 'Not added' : value)),
        ],
      ),
    );
  }

  String _compact(List<Object?> values) {
    final parts = values.where((value) => value != null && value.toString().trim().isNotEmpty).map((value) => value.toString().trim()).toList();
    return parts.isEmpty ? 'Not added' : parts.join(', ');
  }

  String _listText(Object? value) {
    if (value is List) {
      final parts = value.map((item) => item.toString().trim()).where((item) => item.isNotEmpty).toList();
      return parts.isEmpty ? 'Not added' : parts.join(', ');
    }
    return value?.toString() ?? 'Not added';
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
