import 'package:flutter/material.dart';
import 'app_colors.dart';

/// WorkSphere Shadow System
/// Soft, modern shadows for depth and elevation
class AppShadows {
  AppShadows._();

  // ─── Light Mode Shadows ───────────────────────────────────────
  static List<BoxShadow> get small => [
        BoxShadow(
          color: AppColors.primary.withAlpha(10),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: AppColors.primary.withAlpha(15),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: AppColors.primary.withAlpha(8),
          blurRadius: 6,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get large => [
        BoxShadow(
          color: AppColors.primary.withAlpha(20),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: AppColors.primary.withAlpha(10),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get xl => [
        BoxShadow(
          color: AppColors.primary.withAlpha(31),
          blurRadius: 40,
          offset: const Offset(0, 12),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: AppColors.primary.withAlpha(15),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  // ─── Card Shadows ─────────────────────────────────────────────
  static List<BoxShadow> get card => [
        BoxShadow(
          color: const Color(0xFF1E90FF).withAlpha(15),
          blurRadius: 20,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
      ];

  static List<BoxShadow> get cardHover => [
        BoxShadow(
          color: const Color(0xFF1E90FF).withAlpha(31),
          blurRadius: 32,
          offset: const Offset(0, 8),
          spreadRadius: -2,
        ),
      ];

  // ─── Button Shadow ────────────────────────────────────────────
  static List<BoxShadow> get button => [
        BoxShadow(
          color: AppColors.primary.withAlpha(77),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
      ];

  // ─── Dark Mode Shadows ────────────────────────────────────────
  static List<BoxShadow> get darkSmall => [
        BoxShadow(
          color: Colors.black.withAlpha(51),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get darkMedium => [
        BoxShadow(
          color: Colors.black.withAlpha(77),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get darkLarge => [
        BoxShadow(
          color: Colors.black.withAlpha(102),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
      ];

  // ─── Glow Effect ──────────────────────────────────────────────
  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: AppColors.primary.withAlpha(64),
          blurRadius: 24,
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> get successGlow => [
        BoxShadow(
          color: AppColors.success.withAlpha(64),
          blurRadius: 24,
          spreadRadius: -4,
        ),
      ];
}
