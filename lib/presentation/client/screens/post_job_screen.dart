import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../common/widgets/ws_button.dart';
import '../../common/widgets/ws_text_field.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetMinController = TextEditingController();
  final _budgetMaxController = TextEditingController();
  final _skillsController = TextEditingController();
  final _categoryController = TextEditingController();
  String _experienceLevel = 'Intermediate';
  PlatformFile? _attachment;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _skillsController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _handlePostJob() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job posted successfully!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hire Tamil Nadu\'s Top Freelancers',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Describe your project to get proposals from qualified professionals.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              WsTextField(
                label: 'Job Title',
                hint: 'e.g. Build a Flutter E-commerce Mobile App',
                controller: _titleController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              WsTextField(
                label: 'Job Description / Project Requirements',
                hint: 'Describe the scope, deliverables, and requirements in detail...',
                controller: _descriptionController,
                maxLines: 5,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              WsTextField(
                label: 'Required Skills',
                hint: 'e.g. Flutter, Dart, Supabase',
                controller: _skillsController,
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _experienceLevel,
                decoration: const InputDecoration(labelText: 'Experience Level'),
                items: const ['Entry Level', 'Intermediate', 'Expert']
                    .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) => setState(() => _experienceLevel = value!),
              ),
              const SizedBox(height: 20),
              WsTextField(
                label: 'Project Category',
                hint: 'e.g. Mobile Development',
                controller: _categoryController,
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: WsTextField(
                      label: 'Min Budget (₹)',
                      hint: '5000',
                      controller: _budgetMinController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: WsTextField(
                      label: 'Max Budget (₹)',
                      hint: '20000',
                      controller: _budgetMaxController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.attach_file_outlined),
                title: Text(_attachment?.name ?? 'Attachments (optional)'),
                trailing: TextButton(
                  onPressed: () async {
                    final file = await FilePicker.pickFile();
                    if (file != null) {
                      setState(() => _attachment = file);
                    }
                  },
                  child: Text(_attachment == null ? 'Attach' : 'Change'),
                ),
              ),
              const SizedBox(height: 32),
              WsButton(
                text: 'Publish Job',
                onPressed: _handlePostJob,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
