import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../core/enums/enums.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

/// Client-side guard for the back-office. Database RPCs enforce authorization too.
class AdminAccessGate extends ConsumerWidget {
  final Widget child;

  const AdminAccessGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return user.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => _Denied(onReturnHome: () => context.go(RouteNames.home)),
      data: (account) => account?.type == UserType.admin && account?.onboardingStatus == OnboardingStatus.active
          ? child
          : _Denied(onReturnHome: () => context.go(RouteNames.home)),
    );
  }
}

class _Denied extends StatelessWidget {
  final VoidCallback onReturnHome;
  const _Denied({required this.onReturnHome});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings_outlined, size: 56),
                const SizedBox(height: 16),
                Text('Administrator access is required.', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                FilledButton(onPressed: onReturnHome, child: const Text('Return home')),
              ],
            ),
          ),
        ),
      );
}
