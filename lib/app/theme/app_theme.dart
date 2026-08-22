import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_decorations.dart';

/// WorkSphere Theme Configuration
/// Material 3 theme with custom design system
class AppTheme {
  AppTheme._();

  // ─── Light Theme ──────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: AppTypography.bodyFont,

        // Color Scheme
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.textOnPrimary,
          primaryContainer: AppColors.cardBackgroundLight,
          onPrimaryContainer: AppColors.primaryDark,
          secondary: AppColors.secondary,
          onSecondary: AppColors.textOnPrimary,
          secondaryContainer: AppColors.backgroundSecondary,
          onSecondaryContainer: AppColors.secondaryDark,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          surfaceContainerHighest: AppColors.surfaceContainerHighest,
          onSurfaceVariant: AppColors.textSecondary,
          error: AppColors.error,
          onError: AppColors.textOnPrimary,
          outline: AppColors.border,
          outlineVariant: AppColors.divider,
        ),

        // Scaffold
        // Screen backdrops are provided by WsAnimatedPage. Keeping scaffolds
        // transparent lets every routed page share the same light-blue depth.
        scaffoldBackgroundColor: Colors.transparent,

        // AppBar
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
          titleTextStyle: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),

        // Bottom Navigation
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedLabelStyle: AppTypography.labelSmall,
          unselectedLabelStyle: AppTypography.labelSmall,
        ),

        // Navigation Bar (Material 3)
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          height: 72,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.primary.withAlpha(31),
          labelTextStyle: WidgetStatePropertyAll(
            AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 24);
            }
            return const IconThemeData(color: AppColors.textTertiary, size: 24);
          }),
        ),

        // Card
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppDecorations.borderRadiusLg,
            side: BorderSide(
              color: AppColors.border.withAlpha(190),
            ),
          ),
          margin: EdgeInsets.zero,
        ),

        // Elevated Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            disabledBackgroundColor: AppColors.disabled,
            disabledForegroundColor: AppColors.textTertiary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
            shape: RoundedRectangleBorder(
              borderRadius: AppDecorations.borderRadiusMd,
            ),
            textStyle: AppTypography.button,
            minimumSize: const Size(double.infinity, 52),
          ),
        ),

        // Outlined Button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            elevation: 0,
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.textTertiary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: AppDecorations.borderRadiusMd,
            ),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            textStyle: AppTypography.button,
            minimumSize: const Size(double.infinity, 52),
          ),
        ),

        // Text Button
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: AppTypography.button,
          ),
        ),

        // Input Decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          floatingLabelStyle: AppTypography.labelMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
          errorStyle: AppTypography.bodySmall.copyWith(
            color: AppColors.error,
          ),
          border: OutlineInputBorder(
            borderRadius: AppDecorations.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppDecorations.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppDecorations.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppDecorations.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppDecorations.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: AppDecorations.borderRadiusMd,
            borderSide: BorderSide(color: AppColors.border.withAlpha(128)),
          ),
        ),

        // Chip Theme
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.primary.withAlpha(20),
          labelStyle: AppTypography.labelMedium.copyWith(
            color: AppColors.primary,
          ),
          side: BorderSide(
            color: AppColors.primary.withAlpha(38),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppDecorations.borderRadiusFull,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          elevation: 8,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppDecorations.borderRadiusXl,
          ),
          titleTextStyle: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          contentTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        // Bottom Sheet
        bottomSheetTheme: const BottomSheetThemeData(
          elevation: 0,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          showDragHandle: true,
          dragHandleColor: AppColors.border,
        ),

        // Snackbar
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          contentTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppDecorations.borderRadiusMd,
          ),
          elevation: 4,
        ),

        // Tab Bar
        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          labelStyle: AppTypography.titleSmall,
          unselectedLabelStyle: AppTypography.bodyMedium,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2.5,
            ),
          ),
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: AppColors.divider,
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),

        // Floating Action Button
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 4,
          shape: CircleBorder(),
        ),

        // Switch
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.textTertiary;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary.withAlpha(77);
            }
            return AppColors.border;
          }),
        ),

        // Progress Indicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.divider,
        ),

        // Text Theme
        textTheme: const TextTheme(
          displayLarge: AppTypography.displayLarge,
          displayMedium: AppTypography.displayMedium,
          displaySmall: AppTypography.displaySmall,
          headlineLarge: AppTypography.headlineLarge,
          headlineMedium: AppTypography.headlineMedium,
          headlineSmall: AppTypography.headlineSmall,
          titleLarge: AppTypography.titleLarge,
          titleMedium: AppTypography.titleMedium,
          titleSmall: AppTypography.titleSmall,
          bodyLarge: AppTypography.bodyLarge,
          bodyMedium: AppTypography.bodyMedium,
          bodySmall: AppTypography.bodySmall,
          labelLarge: AppTypography.labelLarge,
          labelMedium: AppTypography.labelMedium,
          labelSmall: AppTypography.labelSmall,
        ),
      );

  // ─── Dark Theme ───────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: AppTypography.bodyFont,

        // Color Scheme
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryLight,
          onPrimary: AppColors.darkBackground,
          primaryContainer: AppColors.darkCard,
          onPrimaryContainer: AppColors.primaryLight,
          secondary: AppColors.secondaryLight,
          onSecondary: AppColors.darkBackground,
          secondaryContainer: AppColors.darkSurfaceVariant,
          onSecondaryContainer: AppColors.secondaryLight,
          surface: AppColors.darkSurface,
          onSurface: AppColors.textOnDark,
          surfaceContainerHighest: AppColors.darkSurfaceVariant,
          onSurfaceVariant: AppColors.textOnDarkSecondary,
          error: AppColors.error,
          onError: AppColors.textOnPrimary,
          outline: AppColors.borderDark,
          outlineVariant: AppColors.darkSurfaceVariant,
        ),

        // Scaffold
        scaffoldBackgroundColor: AppColors.darkBackground,

        // AppBar
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: false,
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.textOnDark,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
          titleTextStyle: AppTypography.headlineMedium.copyWith(
            color: AppColors.textOnDark,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.textOnDark,
            size: 24,
          ),
        ),

        // Navigation Bar
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          height: 72,
          backgroundColor: AppColors.darkSurface,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.primaryLight.withAlpha(38),
          labelTextStyle: WidgetStatePropertyAll(
            AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                  color: AppColors.primaryLight, size: 24);
            }
            return const IconThemeData(
                color: AppColors.textOnDarkSecondary, size: 24);
          }),
        ),

        // Card
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.darkSurface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppDecorations.borderRadiusLg,
            side: BorderSide(
              color: AppColors.borderDark.withAlpha(77),
            ),
          ),
          margin: EdgeInsets.zero,
        ),

        // Elevated Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.darkBackground,
            disabledBackgroundColor: AppColors.darkSurfaceVariant,
            disabledForegroundColor: AppColors.textOnDarkSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: AppDecorations.borderRadiusMd,
            ),
            textStyle: AppTypography.button,
            minimumSize: const Size(double.infinity, 52),
          ),
        ),

        // Outlined Button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            elevation: 0,
            foregroundColor: AppColors.primaryLight,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: AppDecorations.borderRadiusMd,
            ),
            side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
            textStyle: AppTypography.button,
            minimumSize: const Size(double.infinity, 52),
          ),
        ),

        // Input Decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurfaceVariant,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textOnDarkSecondary,
          ),
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textOnDarkSecondary,
          ),
          floatingLabelStyle: AppTypography.labelMedium.copyWith(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(
            borderRadius: AppDecorations.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppDecorations.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppDecorations.borderRadiusMd,
            borderSide:
                const BorderSide(color: AppColors.primaryLight, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppDecorations.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.error),
          ),
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          elevation: 8,
          backgroundColor: AppColors.darkSurface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppDecorations.borderRadiusXl,
          ),
          titleTextStyle: AppTypography.headlineMedium.copyWith(
            color: AppColors.textOnDark,
          ),
          contentTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textOnDarkSecondary,
          ),
        ),

        // Bottom Sheet
        bottomSheetTheme: const BottomSheetThemeData(
          elevation: 0,
          backgroundColor: AppColors.darkSurface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          showDragHandle: true,
          dragHandleColor: AppColors.borderDark,
        ),

        // Snackbar
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.darkSurfaceVariant,
          contentTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textOnDark,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppDecorations.borderRadiusMd,
          ),
          elevation: 4,
        ),

        // Tab Bar
        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textOnDarkSecondary,
          labelStyle: AppTypography.titleSmall,
          unselectedLabelStyle: AppTypography.bodyMedium,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(
              color: AppColors.primaryLight,
              width: 2.5,
            ),
          ),
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: AppColors.borderDark,
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.borderDark,
          thickness: 1,
          space: 1,
        ),

        // Switch
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryLight;
            }
            return AppColors.textOnDarkSecondary;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryLight.withAlpha(77);
            }
            return AppColors.borderDark;
          }),
        ),

        // Progress Indicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primaryLight,
          linearTrackColor: AppColors.darkSurfaceVariant,
        ),

        // Text Theme
        textTheme: TextTheme(
          displayLarge:
              AppTypography.displayLarge.copyWith(color: AppColors.textOnDark),
          displayMedium:
              AppTypography.displayMedium.copyWith(color: AppColors.textOnDark),
          displaySmall:
              AppTypography.displaySmall.copyWith(color: AppColors.textOnDark),
          headlineLarge:
              AppTypography.headlineLarge.copyWith(color: AppColors.textOnDark),
          headlineMedium: AppTypography.headlineMedium
              .copyWith(color: AppColors.textOnDark),
          headlineSmall:
              AppTypography.headlineSmall.copyWith(color: AppColors.textOnDark),
          titleLarge:
              AppTypography.titleLarge.copyWith(color: AppColors.textOnDark),
          titleMedium:
              AppTypography.titleMedium.copyWith(color: AppColors.textOnDark),
          titleSmall:
              AppTypography.titleSmall.copyWith(color: AppColors.textOnDark),
          bodyLarge:
              AppTypography.bodyLarge.copyWith(color: AppColors.textOnDark),
          bodyMedium: AppTypography.bodyMedium
              .copyWith(color: AppColors.textOnDarkSecondary),
          bodySmall: AppTypography.bodySmall
              .copyWith(color: AppColors.textOnDarkSecondary),
          labelLarge:
              AppTypography.labelLarge.copyWith(color: AppColors.textOnDark),
          labelMedium: AppTypography.labelMedium
              .copyWith(color: AppColors.textOnDarkSecondary),
          labelSmall: AppTypography.labelSmall
              .copyWith(color: AppColors.textOnDarkSecondary),
        ),
      );
}
