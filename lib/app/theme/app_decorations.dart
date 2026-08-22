import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// WorkSphere Decorations
/// Glassmorphism, rounded corners, and reusable box decorations
class AppDecorations {
  AppDecorations._();

  // ─── Border Radius ────────────────────────────────────────────
  static const double radiusXs = 6.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 100.0;

  static BorderRadius get borderRadiusXs => BorderRadius.circular(radiusXs);
  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusXxl => BorderRadius.circular(radiusXxl);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);

  // ─── Padding ──────────────────────────────────────────────────
  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 12.0;
  static const double paddingLg = 16.0;
  static const double paddingXl = 20.0;
  static const double paddingXxl = 24.0;
  static const double paddingSection = 32.0;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );

  // ─── Glass Morphism (Light) ───────────────────────────────────
  static BoxDecoration get glassLight => BoxDecoration(
        color: Colors.white.withAlpha(153),
        borderRadius: borderRadiusLg,
        border: Border.all(
          color: Colors.white.withAlpha(77),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get glassDark => BoxDecoration(
        color: const Color(0xFF1E293B).withAlpha(179),
        borderRadius: borderRadiusLg,
        border: Border.all(
          color: Colors.white.withAlpha(20),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // ─── Glass Morphism (Strong) ──────────────────────────────────
  static BoxDecoration get glassStrong => BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: borderRadiusLg,
        border: Border.all(
          color: Colors.white.withAlpha(51),
          width: 1.5,
        ),
      );

  // ─── Blur Filter ──────────────────────────────────────────────
  static ImageFilter get blurFilter => ImageFilter.blur(sigmaX: 20, sigmaY: 20);
  static ImageFilter get blurFilterLight =>
      ImageFilter.blur(sigmaX: 10, sigmaY: 10);

  // ─── Card Decoration ──────────────────────────────────────────
  static BoxDecoration get card => BoxDecoration(
        color: AppColors.surface,
        borderRadius: borderRadiusLg,
        border: Border.all(
          color: AppColors.border.withAlpha(128),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get cardDark => BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: borderRadiusLg,
        border: Border.all(
          color: AppColors.borderDark.withAlpha(77),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // ─── Elevated Card ────────────────────────────────────────────
  static BoxDecoration get elevatedCard => BoxDecoration(
        color: AppColors.surface,
        borderRadius: borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(20),
            blurRadius: 32,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      );

  // ─── Input Decoration ─────────────────────────────────────────
  static BoxDecoration get input => BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: borderRadiusMd,
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
      );

  static BoxDecoration get inputFocused => BoxDecoration(
        color: AppColors.surface,
        borderRadius: borderRadiusMd,
        border: Border.all(
          color: AppColors.primary,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  // ─── Chip Decoration ──────────────────────────────────────────
  static BoxDecoration chip({Color? color}) => BoxDecoration(
        color: (color ?? AppColors.primary).withAlpha(20),
        borderRadius: borderRadiusFull,
        border: Border.all(
          color: (color ?? AppColors.primary).withAlpha(38),
          width: 1.0,
        ),
      );

  // ─── Bottom Sheet ─────────────────────────────────────────────
  static BoxDecoration get bottomSheet => const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      );

  static BoxDecoration get bottomSheetDark => const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      );

  // ─── Status Badge ─────────────────────────────────────────────
  static BoxDecoration statusBadge(Color color) => BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: borderRadiusFull,
        border: Border.all(
          color: color.withAlpha(51),
          width: 1.0,
        ),
      );
}
