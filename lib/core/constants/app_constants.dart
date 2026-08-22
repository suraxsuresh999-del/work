/// WorkSphere Application Constants
class AppConstants {
  AppConstants._();

  // ─── App Info ─────────────────────────────────────────────────
  static const String appName = 'WorkSphere';
  static const String appTagline = 'Connect • Collaborate • Grow';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // ─── Region ───────────────────────────────────────────────────
  static const String targetRegion = 'Tamil Nadu';
  static const String targetCountry = 'India';
  static const String defaultLanguage = 'en';
  static const String secondaryLanguage = 'ta';
  static const String currencySymbol = '₹';
  static const String currencyCode = 'INR';
  static const String countryCode = '+91';

  // ─── Pagination ───────────────────────────────────────────────
  static const int pageSize = 20;
  static const int searchPageSize = 15;
  static const int chatPageSize = 50;

  // ─── Limits ───────────────────────────────────────────────────
  static const int maxSkills = 15;
  static const int maxPortfolioItems = 20;
  static const int maxImages = 10;
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5 MB
  static const int maxResumeSize = 5 * 1024 * 1024; // 5 MB
  static const int maxBioLength = 500;
  static const int maxDescriptionLength = 2000;
  static const int maxTitleLength = 100;

  // ─── Timeouts ─────────────────────────────────────────────────
  static const int otpTimeoutSeconds = 60;
  static const int sessionTimeoutMinutes = 30;
  static const int apiTimeoutSeconds = 30;

  // ─── Ratings ──────────────────────────────────────────────────
  static const int maxRating = 5;
  static const int minReviewLength = 20;
  static const int maxReviewLength = 1000;

  // ─── Platform Fee ─────────────────────────────────────────────
  static const double platformFeePercent = 10.0;
  static const double gstPercent = 18.0;
  static const double minWithdrawalAmount = 500.0;

  // ─── Hive Boxes ───────────────────────────────────────────────
  static const String userBox = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String cacheBox = 'cache_box';
  static const String searchHistoryBox = 'search_history_box';

  // ─── Settings Keys ────────────────────────────────────────────
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String notificationsKey = 'notifications_enabled';
  static const String onboardingKey = 'onboarding_completed';
  static const String biometricKey = 'biometric_enabled';
}
