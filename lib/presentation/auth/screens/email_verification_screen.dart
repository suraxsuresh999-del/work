import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/di/auth_providers.dart';
import '../../../app/router/route_names.dart';
import '../../common/widgets/ws_button.dart';
import '../../common/widgets/ws_auth_animation.dart';

class EmailVerificationArguments {
  final String email;

  EmailVerificationArguments({required this.email});
}

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  bool _isLoading = false;
  int _remainingSeconds = 30;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _remainingSeconds = 30;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  Future<void> _resendEmail() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).resendVerificationEmail(email: widget.email);
      if (!mounted) return;
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email resent successfully.')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _continue() async {
    setState(() => _isLoading = true);
    try {
      if (!mounted) return;
      final authUser = ref.read(supabaseClientProvider).auth.currentUser;
      if (authUser == null || authUser.emailConfirmedAt == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please verify your email before continuing.')),
        );
        return;
      }
 
      if (!mounted) return;
      await ref.read(authRepositoryProvider).signOut();
      if (mounted) context.go(RouteNames.login);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Email')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Center(child: WsAuthAnimation(size: 142)),
            const SizedBox(height: 16),
            Text(
              'A verification link has been sent to:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              widget.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text(
              'Please open your email and click the verification link before continuing. If you do not see the email, check your spam folder.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            WsButton(
              text: 'I have verified my email',
              onPressed: _continue,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: WsButton(
                    text: 'Resend Verification Email',
                    type: WsButtonType.outlined,
                    onPressed: (_isLoading || _remainingSeconds > 0) ? null : _resendEmail,
                  ),
                ),
                if (_remainingSeconds > 0) ...[
                  const SizedBox(width: 12),
                  Text(
                    'Wait ${_remainingSeconds}s',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
