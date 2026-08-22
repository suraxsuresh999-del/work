import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/di/auth_providers.dart';
import '../../../core/utils/validators.dart';
import '../../common/widgets/ws_button.dart';
import '../../common/widgets/ws_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        // BUG-07 FIX: Call the real sendPasswordResetEmail use case
        // instead of just simulating a delay.
        final authRepository = ref.read(authRepositoryProvider);
        await authRepository.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );

        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Password reset link sent! Please check your email.')),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Icon(
                _emailSent ? Icons.mark_email_read_outlined : Icons.lock_reset,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                _emailSent
                    ? 'Check your inbox!'
                    : 'Forgot your password?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _emailSent
                    ? 'A password reset link has been sent to ${_emailController.text.trim()}.'
                    : 'Enter your email address and we will send you a link to reset your password.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (!_emailSent) ...[
                WsTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                ),
                const SizedBox(height: 32),
                WsButton(
                  text: 'Send Reset Link',
                  onPressed: _handleResetPassword,
                  isLoading: _isLoading,
                ),
              ] else ...[
                const SizedBox(height: 16),
                WsButton(
                  text: 'Back to Login',
                  onPressed: () => context.pop(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
