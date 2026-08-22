/// Base exception class for the application
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException($code): $message';
}

/// Server/API exceptions
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.details,
  });

  factory AuthException.invalidCredentials() => const AuthException(
        message: 'Invalid email, password, or phone number.',
        code: 'INVALID_CREDENTIALS',
      );

  factory AuthException.emailNotVerified() => const AuthException(
        message: 'Please verify your email before logging in.',
        code: 'EMAIL_NOT_VERIFIED',
      );

  factory AuthException.sessionExpired() => const AuthException(
        message: 'Your session has expired. Please log in again.',
        code: 'SESSION_EXPIRED',
      );

  factory AuthException.userNotFound() => const AuthException(
        message: 'No account found with this email.',
        code: 'USER_NOT_FOUND',
      );

  factory AuthException.emailAlreadyExists() => const AuthException(
        message: 'An account with this email already exists. Please log in instead.',
        code: 'EMAIL_EXISTS',
      );
 
  factory AuthException.phoneAlreadyExists() => const AuthException(
        message: 'This phone number is already registered. Please log in instead.',
        code: 'PHONE_EXISTS',
      );
 
  factory AuthException.phoneNumberNotFound() => const AuthException(
        message: 'No WorkSphere account was found with this phone number. Please sign up first.',
        code: 'PHONE_NOT_FOUND',
      );
 
  factory AuthException.weakPassword() => const AuthException(
        message: 'Password is too weak. Use at least 8 characters.',
        code: 'WEAK_PASSWORD',
      );

  factory AuthException.otpExpired() => const AuthException(
        message: 'OTP has expired. Please request a new one.',
        code: 'OTP_EXPIRED',
      );

  factory AuthException.invalidOtp() => const AuthException(
        message: 'Invalid OTP. Please try again.',
        code: 'INVALID_OTP',
      );

  factory AuthException.tooManyRequests() => const AuthException(
        message: 'Too many attempts. Please try again later.',
        code: 'TOO_MANY_REQUESTS',
      );
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache operation failed.',
    super.code = 'CACHE_ERROR',
    super.details,
  });
}

/// Storage exceptions (file operations)
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code = 'STORAGE_ERROR',
    super.details,
  });

  factory StorageException.uploadFailed() => const StorageException(
        message: 'Failed to upload file. Please try again.',
        code: 'UPLOAD_FAILED',
      );

  factory StorageException.fileTooLarge(int maxSizeMB) => StorageException(
        message: 'File size exceeds the maximum limit of ${maxSizeMB}MB.',
        code: 'FILE_TOO_LARGE',
      );

  factory StorageException.invalidFileType() => const StorageException(
        message: 'Invalid file type. Please select a supported format.',
        code: 'INVALID_FILE_TYPE',
      );
}

/// Payment exceptions
class PaymentException extends AppException {
  const PaymentException({
    required super.message,
    super.code = 'PAYMENT_ERROR',
    super.details,
  });

  factory PaymentException.paymentFailed() => const PaymentException(
        message: 'Payment failed. Please try again.',
        code: 'PAYMENT_FAILED',
      );

  factory PaymentException.insufficientBalance() => const PaymentException(
        message: 'Insufficient balance in your wallet.',
        code: 'INSUFFICIENT_BALANCE',
      );
}
