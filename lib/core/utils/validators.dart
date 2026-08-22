/// Form validators for WorkSphere
class Validators {
  Validators._();

  /// Email validation
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Password validation (min 8 chars, 1 uppercase, 1 lowercase, 1 digit)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }
    return null;
  }

  /// Confirm password validation
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Phone number validation (Indian format)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final phoneRegex = RegExp(r'^(\+91)?[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Enter a valid Indian mobile number';
    }
    return null;
  }

  /// OTP validation
  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required';
    }
    if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Enter a valid 6-digit OTP';
    }
    return null;
  }

  /// Name validation
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  /// Required field validation
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Min length validation
  static String? minLength(String? value, int minLen, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < minLen) {
      return '$fieldName must be at least $minLen characters';
    }
    return null;
  }

  /// Max length validation
  static String? maxLength(String? value, int maxLen, [String fieldName = 'This field']) {
    if (value != null && value.trim().length > maxLen) {
      return '$fieldName must be less than $maxLen characters';
    }
    return null;
  }

  /// URL validation
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional
    }
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value.trim())) {
      return 'Enter a valid URL';
    }
    return null;
  }

  /// Budget/amount validation
  static String? amount(String? value, {double min = 0, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null) {
      return 'Enter a valid amount';
    }
    if (amount < min) {
      return 'Amount must be at least ₹${min.toStringAsFixed(0)}';
    }
    if (max != null && amount > max) {
      return 'Amount must not exceed ₹${max.toStringAsFixed(0)}';
    }
    return null;
  }

  /// Aadhaar number validation
  static String? aadhaar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Aadhaar number is required';
    }
    final cleaned = value.replaceAll(' ', '');
    if (cleaned.length != 12 || !RegExp(r'^\d{12}$').hasMatch(cleaned)) {
      return 'Enter a valid 12-digit Aadhaar number';
    }
    return null;
  }

  /// Pincode validation
  static String? pincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pincode is required';
    }
    if (!RegExp(r'^[1-9]\d{5}$').hasMatch(value.trim())) {
      return 'Enter a valid 6-digit pincode';
    }
    return null;
  }
}
