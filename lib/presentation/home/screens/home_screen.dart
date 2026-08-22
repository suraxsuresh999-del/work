import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../core/enums/enums.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

/// Temporary safe landing page shown immediately after a successful login.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user?.type == UserType.rolePending) {
      return SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Choose your role', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('Your account is ready, but WorkSphere still needs you to choose whether you want to continue as a Client or Freelancer.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(RouteNames.userTypeSelection),
              child: const Text('Select role'),
            ),
          ],
        ),
      );
    }
    final isClient = user?.type == UserType.client;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(isClient ? 'Client Dashboard' : 'Freelancer Dashboard', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Welcome, ${user?.fullName ?? 'WorkSphere member'}'),
          const SizedBox(height: 24),
          Card(child: ListTile(leading: const Icon(Icons.verified_user_outlined), title: const Text('Verification status'), subtitle: Text(user?.verificationStatus.label ?? 'Not submitted'), onTap: () => context.push(RouteNames.verification))),
          if (isClient) ...[
            Card(child: ListTile(leading: const Icon(Icons.add_business_outlined), title: const Text('Post a project'), subtitle: const Text('Create a new job for freelancers.'), onTap: () => context.push(RouteNames.postJob))),
            Card(child: ListTile(leading: const Icon(Icons.search_outlined), title: const Text('Find freelancers'), subtitle: const Text('Search qualified professionals.'), onTap: () => context.go(RouteNames.search))),
          ] else ...[
            Card(child: ListTile(leading: const Icon(Icons.work_outline), title: const Text('Find projects'), subtitle: const Text('Browse projects that match your skills.'), onTap: () => context.go(RouteNames.jobs))),
            Card(child: ListTile(leading: const Icon(Icons.person_outline), title: const Text('Edit professional profile'), subtitle: const Text('Update skills, portfolio, and experience.'), onTap: () => context.push(RouteNames.editProfile))),
          ],
        ],
      ),
    );
  }
}
