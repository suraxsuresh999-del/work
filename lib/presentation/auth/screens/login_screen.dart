import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/di/auth_providers.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/validators.dart';
import '../../common/widgets/ws_button.dart';
import '../../common/widgets/ws_text_field.dart';
import '../../common/widgets/ws_auth_animation.dart';
import '../helpers/auth_flow_helper.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(loginViewModelProvider.notifier).signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        await _handleAuthenticatedRedirect();
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    final success = await ref.read(loginViewModelProvider.notifier).signInWithGoogle();
    if (success && mounted) {
      await _handleAuthenticatedRedirect();
    }
  }

  Future<void> _handleAuthenticatedRedirect() async {
    final currentUser = await ref.read(getCurrentUserUseCaseProvider).call();
    if (!mounted) return;
    await navigateToNextAuthStep(context, currentUser);
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);
    final isLoading = loginState is AsyncLoading;

    // Show error if any
    ref.listen<AsyncValue>(loginViewModelProvider, (_, state) {
      if (state is AsyncError) {
        final error = state.error;
        if (error is AuthException && error.code == 'EMAIL_NOT_VERIFIED') {
          context.go(
            RouteNames.emailVerification,
            extra: {'email': _emailController.text.trim()},
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      const Center(child: WsAuthAnimation(size: 132)),
                      const SizedBox(height: 8),
                      Text(
                          'Welcome Back',
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Log in to continue to WorkSphere',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        WsTextField(
                          label: 'Email Address',
                          hint: 'Enter your email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 20),
                        WsTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) => Validators.required(value, 'Password'),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push(RouteNames.forgotPassword),
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        WsButton(
                          text: 'Log In',
                          onPressed: _handleLogin,
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'Or continue with',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 20),
                        WsButton(
                          text: 'Continue with Google',
                          type: WsButtonType.outlined,
                          onPressed: _handleGoogleLogin,
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () => context.push(RouteNames.register),
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
