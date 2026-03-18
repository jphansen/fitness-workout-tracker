/// Custom exception for authentication-related errors
class AuthenticationException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  AuthenticationException(this.message, {this.statusCode, this.details});

  @override
  String toString() {
    if (statusCode != null) {
      return 'AuthenticationException: $message (Status: $statusCode)';
    }
    return 'AuthenticationException: $message';
  }
}

/// Exception thrown when token refresh fails
class TokenRefreshException extends AuthenticationException {
  TokenRefreshException(String message, {int? statusCode, String? details})
      : super(message, statusCode: statusCode, details: details);
}

/// Exception thrown when token validation fails
class TokenValidationException extends AuthenticationException {
  TokenValidationException(String message, {int? statusCode, String? details})
      : super(message, statusCode: statusCode, details: details);
}