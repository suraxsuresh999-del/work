import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/network/network_info.dart';
import '../../core/constants/app_constants.dart';

// ─── Core Providers ─────────────────────────────────────────────

/// Network connectivity
final connectivityStatusProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(ref.watch(connectivityProvider));
});

// ─── Theme Provider ─────────────────────────────────────────────

/// Current theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeModeState>((ref) {
  return ThemeModeNotifier();
});

enum ThemeModeState { light, dark, system }

class ThemeModeNotifier extends StateNotifier<ThemeModeState> {
  ThemeModeNotifier() : super(ThemeModeState.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final box = await Hive.openBox(AppConstants.settingsBox);
    final themeValue = box.get(AppConstants.themeKey, defaultValue: 'system');
    state = ThemeModeState.values.firstWhere(
      (e) => e.name == themeValue,
      orElse: () => ThemeModeState.system,
    );
  }

  Future<void> setThemeMode(ThemeModeState mode) async {
    state = mode;
    final box = await Hive.openBox(AppConstants.settingsBox);
    await box.put(AppConstants.themeKey, mode.name);
  }

  Future<void> toggle() async {
    // BUG-17 FIX: Cycle through all three theme modes including system.
    ThemeModeState next;
    switch (state) {
      case ThemeModeState.system:
        next = ThemeModeState.light;
        break;
      case ThemeModeState.light:
        next = ThemeModeState.dark;
        break;
      case ThemeModeState.dark:
        next = ThemeModeState.system;
        break;
    }
    await setThemeMode(next);
  }
}

// ─── Locale Provider ────────────────────────────────────────────

/// Current locale
final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super(AppConstants.defaultLanguage) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final box = await Hive.openBox(AppConstants.settingsBox);
    state = box.get(AppConstants.languageKey, defaultValue: AppConstants.defaultLanguage);
  }

  Future<void> setLocale(String locale) async {
    state = locale;
    final box = await Hive.openBox(AppConstants.settingsBox);
    await box.put(AppConstants.languageKey, locale);
  }
}

// ─── Onboarding Provider ────────────────────────────────────────

/// Whether onboarding has been completed
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final box = await Hive.openBox(AppConstants.settingsBox);
  return box.get(AppConstants.onboardingKey, defaultValue: false);
});
