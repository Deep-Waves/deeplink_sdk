/// Base exception for deep link errors
class DeepLinkException implements Exception {
  final String message;
  final dynamic cause;

  DeepLinkException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return 'DeepLinkException: $message\nCause: $cause';
    }
    return 'DeepLinkException: $message';
  }
}

/// Exception thrown when a deep link is invalid
class InvalidDeepLinkException extends DeepLinkException {
  InvalidDeepLinkException(String message, [dynamic cause]) : super(message, cause);
}

/// Exception thrown when no route is found for a deep link
class RouteNotFoundException extends DeepLinkException {
  final String path;

  RouteNotFoundException(this.path) : super('No route found for path: $path');
}

/// Exception thrown when deep link configuration is invalid
class InvalidConfigurationException extends DeepLinkException {
  InvalidConfigurationException(String message) : super(message);
}

/// Exception thrown when platform-specific operations fail
class PlatformException extends DeepLinkException {
  final String code;

  PlatformException({
    required this.code,
    required String message,
    dynamic cause,
  }) : super(message, cause);
}
