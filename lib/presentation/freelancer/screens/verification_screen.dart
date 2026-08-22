import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../common/widgets/ws_button.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _picker = ImagePicker();
  String _selectedDocType = 'Aadhaar Card';
  Uint8List? _documentBytes;
  Uint8List? _selfieBytes;
  String? _documentName;
  String? _selfieName;
  bool _isLoading = false;

  static const _docTypes = [
    'Aadhaar Card',
    'PAN Card',
    'Voter ID',
    'Driving License',
    'Passport',
  ];

  Future<void> _chooseImage({required bool isSelfie}) async {
    // A selfie must be captured during this verification session. Documents
    // may come from the gallery so a clear scan can be used.
    final source = isSelfie
        ? ImageSource.camera
        : await showModalBottomSheet<ImageSource>(
            context: context,
            builder: (context) => SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt_outlined),
                    title: const Text('Take a photo'),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: const Text('Choose from gallery'),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
            ),
          );
    if (source == null) return;

    // Request the permission before starting the native camera activity. This
    // makes the live-selfie action work reliably on Android instead of failing
    // silently when camera access was previously denied.
    if (source == ImageSource.camera) {
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        if (mounted) {
          final openSettings = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Camera permission needed'),
              content: const Text(
                'Allow camera access to capture your live selfie.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                if (cameraStatus.isPermanentlyDenied)
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Open settings'),
                  ),
              ],
            ),
          );
          if (openSettings == true) await openAppSettings();
        }
        return;
      }
    }

    XFile? image;
    try {
      image = await _picker.pickImage(
        source: source,
        preferredCameraDevice:
            isSelfie ? CameraDevice.front : CameraDevice.rear,
        imageQuality: 82,
        maxWidth: 1800,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera access is required to capture your live selfie.'),
          ),
        );
      }
      return;
    }
    final selectedImage = image;
    if (selectedImage == null) return;
    final bytes = await selectedImage.readAsBytes();
    if (!mounted) return;
    setState(() {
      if (isSelfie) {
        _selfieBytes = bytes;
        _selfieName = selectedImage.name;
      } else {
        _documentBytes = bytes;
        _documentName = selectedImage.name;
      }
    });
  }

  Future<String> _upload(Uint8List bytes, String name) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final safeName = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final path = '$userId/verification/${DateTime.now().microsecondsSinceEpoch}_$safeName';
    await Supabase.instance.client.storage.from('verification-documents').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false),
        );
    return path;
  }

  Future<void> _handleSubmit() async {
    if (_documentBytes == null || _selfieBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add both your document and a clear selfie.')),
      );
      return;
    }
    if (Supabase.instance.client.auth.currentUser == null) return;

    setState(() => _isLoading = true);
    try {
      final documentPath = await _upload(_documentBytes!, _documentName ?? 'document.jpg');
      final selfiePath = await _upload(_selfieBytes!, _selfieName ?? 'selfie.jpg');
      await Supabase.instance.client.rpc(
        'submit_verification_request',
        params: {
          'document_type_input': _selectedDocType,
          'document_path_input': documentPath,
          'selfie_path_input': selfiePath,
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification submitted for review.')),
      );
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not submit verification. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identity Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.verified_user_outlined, size: 72, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Verify your identity',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your document is visible only to authorised WorkSphere reviewers.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            DropdownButtonFormField<String>(
              initialValue: _selectedDocType,
              decoration: const InputDecoration(
                labelText: 'Government-issued document',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              items: _docTypes
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedDocType = value);
              },
            ),
            const SizedBox(height: 20),
            _UploadCard(
              title: 'Document photo',
              subtitle: 'Make all text readable and avoid glare.',
              imageBytes: _documentBytes,
              onTap: () => _chooseImage(isSelfie: false),
            ),
            const SizedBox(height: 16),
            _UploadCard(
              title: 'Live selfie',
              subtitle: 'Use the camera to capture a clear, recent photo of your face.',
              imageBytes: _selfieBytes,
              actionLabel: _selfieBytes == null ? 'Capture live selfie' : 'Retake selfie',
              actionIcon: Icons.camera_front_outlined,
              onTap: () => _chooseImage(isSelfie: true),
            ),
            const SizedBox(height: 28),
            WsButton(
              text: 'Submit for review',
              onPressed: _handleSubmit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Uint8List? imageBytes;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback onTap;

  const _UploadCard({
    required this.title,
    required this.subtitle,
    required this.imageBytes,
    this.actionLabel,
    this.actionIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        height: 156,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFF7FBFF),
        ),
        child: imageBytes == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
                  const SizedBox(height: 8),
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (actionLabel != null) ...[
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: onTap,
                      icon: Icon(actionIcon ?? Icons.camera_alt_outlined),
                      label: Text(actionLabel!),
                    ),
                  ],
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(imageBytes!, fit: BoxFit.cover),
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: ColoredBox(
                        color: Color(0x990B1F33),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Tap to replace', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
