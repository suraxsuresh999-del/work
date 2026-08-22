import 'package:flutter/material.dart';

/// WorkSphere Typography System
/// Heading: Outfit (Bold, Modern, Professional)
/// Body: Inter (Clean, Readable)
class AppTypography {
  AppTypography._();

  // ─── Font Families ────────────────────────────────────────────
  static const String headingFont = 'Outfit';
  static const String bodyFont = 'Inter';

  // ─── Display Styles (Hero Sections) ───────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: headingFont,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -1.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: headingFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -1.0,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: headingFont,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );

  // ─── Heading Styles ───────────────────────────────────────────
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: headingFont,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: headingFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.2,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: headingFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ─── Title Styles ─────────────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontFamily: headingFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.45,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.45,
  );

  // ─── Body Styles ──────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ─── Label Styles ─────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.3,
  );

  // ─── Special Styles ───────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontFamily: bodyFont,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.3,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.2,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: bodyFont,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 1.0,
  );

  static const TextStyle price = TextStyle(
    fontFamily: headingFont,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle badge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.5,
  );
}
