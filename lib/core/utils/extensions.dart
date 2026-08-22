import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Dart extension methods for common operations
extension StringExtension on String {
  /// Capitalize first letter
  String get capitalize =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  /// Capitalize each word
  String get titleCase => split(' ')
      .map((word) => word.isEmpty
          ? ''
          : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
      .join(' ');

  /// Convert to initials (John Doe → JD)
  String get initials {
    final words = trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  /// Truncate with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Check if valid email
  bool get isValidEmail => RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(this);

  /// Check if valid Indian phone number
  bool get isValidPhone {
    final cleaned = replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return RegExp(r'^(\+91)?[6-9]\d{9}$').hasMatch(cleaned);
  }

  /// Get clean phone number (just 10 digits)
  String get cleanPhone {
    final cleaned = replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      return cleaned.substring(2);
    }
    return cleaned;
  }
}

extension NumExtension on num {
  /// Format as INR currency
  String get toCurrency {
    if (this >= 10000000) {
      return '₹${(this / 10000000).toStringAsFixed(1)}Cr';
    } else if (this >= 100000) {
      return '₹${(this / 100000).toStringAsFixed(1)}L';
    } else if (this >= 1000) {
      return '₹${(this / 1000).toStringAsFixed(1)}K';
    }
    return '₹${toStringAsFixed(0)}';
  }
}

extension DateTimeExtension on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is this week
  bool get isThisWeek {
    final now = DateTime.now();
    return now.difference(this).inDays < 7;
  }

  /// Age from date of birth
  int get age {
    final now = DateTime.now();
    var age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// Time ago string
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }
}

extension ContextExtension on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Get padding
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  /// Check if dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Screen breakpoints
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  /// Show snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Theme.of(this).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppConstants.pageSize.toDouble()),
      ),
    );
  }
}

extension ListExtension<T> on List<T> {
  /// Safe element at index
  T? safeAt(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}
