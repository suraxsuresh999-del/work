import 'package:equatable/equatable.dart';
import '../../core/enums/enums.dart';

/// Core User entity representing an authenticated user in the domain layer
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? phone;
  final String fullName;
  final String? avatarUrl;
  final UserType type;
  final VerificationStatus verificationStatus;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool hasProfile;
  final OnboardingStatus onboardingStatus;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.phone,
    required this.fullName,
    this.avatarUrl,
    this.type = UserType.rolePending,
    this.verificationStatus = VerificationStatus.unverified,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.hasProfile = false,
    this.onboardingStatus = OnboardingStatus.rolePending,
    required this.createdAt,
  });

  /// Get initials for avatar fallback
  String get initials {
    // BUG-09 FIX: Filter out empty strings in case fullName is only whitespace
    final names = fullName.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (names.isEmpty) return '';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  bool get isVerified => verificationStatus == VerificationStatus.approved;

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        fullName,
        avatarUrl,
        type,
        verificationStatus,
        isEmailVerified,
        isPhoneVerified,
        hasProfile,
        onboardingStatus,
        createdAt,
      ];
}
