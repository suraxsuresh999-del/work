import '../../domain/entities/user_entity.dart';
import '../../core/enums/enums.dart';

class UserModel {
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

  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      type: UserType.fromString(json['user_type'] as String? ?? UserType.rolePending.value),
      verificationStatus: VerificationStatus.fromString(json['verification_status'] as String? ?? ''),
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? false,
      hasProfile: (json['onboarding_status'] as String? ?? '') == OnboardingStatus.active.value,
      onboardingStatus: OnboardingStatus.fromString(
        json['onboarding_status'] as String? ?? '',
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'user_type': type.value,
      'verification_status': verificationStatus.value,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'onboarding_status': onboardingStatus.value,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      phone: phone,
      fullName: fullName,
      avatarUrl: avatarUrl,
      type: type,
      verificationStatus: verificationStatus,
      isEmailVerified: isEmailVerified,
      isPhoneVerified: isPhoneVerified,
      hasProfile: hasProfile,
      onboardingStatus: onboardingStatus,
      createdAt: createdAt,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      phone: entity.phone,
      fullName: entity.fullName,
      avatarUrl: entity.avatarUrl,
      type: entity.type,
      verificationStatus: entity.verificationStatus,
      isEmailVerified: entity.isEmailVerified,
      isPhoneVerified: entity.isPhoneVerified,
      hasProfile: entity.hasProfile,
      onboardingStatus: entity.onboardingStatus,
      createdAt: entity.createdAt,
    );
  }
}
