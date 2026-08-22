import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/di/auth_providers.dart';
import '../../../app/router/route_names.dart';
import '../../common/widgets/ws_button.dart';
import '../../common/widgets/ws_text_field.dart';
import '../../../core/utils/validators.dart';

class ClientProfileSetupScreen extends ConsumerStatefulWidget {
  const ClientProfileSetupScreen({super.key});

  @override
  ConsumerState<ClientProfileSetupScreen> createState() => _ClientProfileSetupScreenState();
}

class _ClientProfileSetupScreenState extends ConsumerState<ClientProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _aboutController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _companyController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.completeClientProfile(
        companyName: _companyController.text.trim(),
        location: _locationController.text.trim(),
        about: _aboutController.text.trim(),
      );
      if (!mounted) return;
      context.go(RouteNames.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Client Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tell us about your business',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Complete your client profile so you can post jobs and hire freelancers.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              WsTextField(
                label: 'Company Name',
                hint: 'Enter your company or brand',
                controller: _companyController,
                validator: Validators.required,
              ),
              const SizedBox(height: 20),
              WsTextField(
                label: 'Location',
                hint: 'e.g. Chennai, Tamil Nadu',
                controller: _locationController,
                validator: Validators.required,
              ),
              const SizedBox(height: 20),
              WsTextField(
                label: 'About / Bio',
                hint: 'Tell freelancers what you are looking for',
                controller: _aboutController,
                maxLines: 4,
                validator: Validators.required,
              ),
              const SizedBox(height: 32),
              WsButton(
                text: 'Complete Profile',
                onPressed: _handleSave,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
