import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/di/auth_providers.dart';
import '../../../app/router/route_names.dart';
import '../../../core/enums/enums.dart';

class UserTypeSelectionScreen extends ConsumerStatefulWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  ConsumerState<UserTypeSelectionScreen> createState() => _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends ConsumerState<UserTypeSelectionScreen> {
  bool _isSaving = false;

  Future<void> _selectType(UserType type) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(authRepositoryProvider).updateAccountType(userType: type);
      if (!mounted) return;
      context.go(
        type == UserType.client
            ? RouteNames.clientProfileSetup
            : RouteNames.freelancerProfileSetup,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save your account type. Please check your connection and try again.'),
        ),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your role')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'How do you want to use WorkSphere?',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Choose one to create your starter profile. You can expand it later.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _buildTypeCard(
              title: 'Continue as Client',
              description: 'Post jobs and hire trusted freelancers',
              icon: Icons.business_center_rounded,
              onTap: () => _selectType(UserType.client),
            ),
            const SizedBox(height: 20),
            _buildTypeCard(
              title: 'Continue as Freelancer',
              description: 'Find jobs and build your professional presence',
              icon: Icons.person_search_rounded,
              onTap: () => _selectType(UserType.freelancer),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: _isSaving ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(icon, size: 44, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(description, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              _isSaving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
