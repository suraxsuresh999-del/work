import 'package:intl/intl.dart';

/// Date, currency, and number formatters
class Formatters {
  Formatters._();

  // ─── Currency ─────────────────────────────────────────────────
  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _inrDecimalFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Format amount as INR (₹1,00,000)
  static String currency(double amount) => _inrFormat.format(amount);

  /// Format amount as INR with decimals (₹1,00,000.00)
  static String currencyDecimal(double amount) =>
      _inrDecimalFormat.format(amount);

  /// Compact currency (₹1.5L, ₹50K)
  static String currencyCompact(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  // ─── Numbers ──────────────────────────────────────────────────
  static final NumberFormat _compactFormat = NumberFormat.compact();

  /// Compact number (1.5K, 2.3M)
  static String compact(num number) => _compactFormat.format(number);

  /// Number with Indian formatting (1,00,000)
  static String indianNumber(num number) {
    return NumberFormat('#,##,##0', 'en_IN').format(number);
  }

  // ─── Date & Time ──────────────────────────────────────────────
  /// Full date (January 15, 2024)
  static String dateFullMonth(DateTime date) =>
      DateFormat('MMMM d, y').format(date);

  /// Short date (Jan 15, 2024)
  static String dateShortMonth(DateTime date) =>
      DateFormat('MMM d, y').format(date);

  /// Date only (15/01/2024)
  static String dateNumeric(DateTime date) =>
      DateFormat('dd/MM/yyyy').format(date);

  /// Time only (2:30 PM)
  static String time(DateTime date) => DateFormat('h:mm a').format(date);

  /// Date with time (Jan 15, 2024 • 2:30 PM)
  static String dateTime(DateTime date) =>
      DateFormat('MMM d, y • h:mm a').format(date);

  /// Relative time (2 hours ago, 3 days ago)
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}w ago';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else {
      return '${(diff.inDays / 365).floor()}y ago';
    }
  }

  /// Chat timestamp (Today 2:30 PM, Yesterday 10:00 AM, Jan 15)
  static String chatTimestamp(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDay = DateTime(date.year, date.month, date.day);

    if (messageDay == today) {
      return DateFormat('h:mm a').format(date);
    } else if (messageDay == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  // ─── Phone ────────────────────────────────────────────────────
  /// Format Indian phone number (+91 98765 43210)
  static String phone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (cleaned.length == 10) {
      return '+91 ${cleaned.substring(0, 5)} ${cleaned.substring(5)}';
    } else if (cleaned.length == 12 && cleaned.startsWith('91')) {
      return '+91 ${cleaned.substring(2, 7)} ${cleaned.substring(7)}';
    }
    return phone;
  }

  // ─── File Size ────────────────────────────────────────────────
  /// Format file size (1.5 MB, 256 KB)
  static String fileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // ─── Duration ─────────────────────────────────────────────────
  /// Format duration (2h 30m, 45m, 3d)
  static String duration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  // ─── Rating ───────────────────────────────────────────────────
  /// Format rating (4.5 out of 5)
  static String rating(double rating) => rating.toStringAsFixed(1);
}
