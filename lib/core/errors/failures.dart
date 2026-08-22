import 'package:equatable/equatable.dart';

/// Base failure class for error handling across the application
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];
}

/// Server-side failures (Supabase, API errors)
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory ServerFailure.fromException(Exception e) {
    return ServerFailure(
      message: e.toString(),
      details: e,
    );
  }
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Network/connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Cache/local storage failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to access local storage.',
    super.code = 'CACHE_ERROR',
    super.details,
  });
}

/// Validation failures (form validation, business rules)
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });

  // BUG-11 FIX: Added missing props override to include fieldErrors
  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// Permission/authorization failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'You do not have permission to perform this action.',
    super.code = 'PERMISSION_DENIED',
  });
}

/// Storage failures (file upload/download)
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code = 'STORAGE_ERROR',
    super.details,
  });
}

/// Payment failures
class PaymentFailure extends Failure {
  const PaymentFailure({
    required super.message,
    super.code = 'PAYMENT_ERROR',
    super.details,
  });
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found.',
    super.code = 'NOT_FOUND',
  });
}

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code = 'UNKNOWN_ERROR',
    super.details,
  });
}
