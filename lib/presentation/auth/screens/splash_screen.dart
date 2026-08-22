import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/di/providers.dart';
import '../../../app/di/auth_providers.dart';
import '../helpers/auth_flow_helper.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Artificial delay for splash screen animation
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Check if onboarding is completed
    final onboardingCompleted = await ref.read(onboardingCompletedProvider.future);
    
    if (!mounted) return;

    if (!onboardingCompleted) {
      context.go(RouteNames.onboarding);
      return;
    }

    try {
      // BUG-05 FIX: currentUserProvider is no longer a FutureProvider.
      // Use GetCurrentUserUseCase directly for the splash one-shot check.
      final currentUser = await ref.read(getCurrentUserUseCaseProvider).call();
 
      if (!mounted) return;
      await navigateToNextAuthStep(context, currentUser);
    } catch (_) {
      if (!mounted) return;
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Placeholder for Logo
              const Icon(
                Icons.work_outline,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                'WorkSphere',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect • Collaborate • Grow',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withAlpha(230),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
