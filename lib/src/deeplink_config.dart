/// Configuration for deep link handling
class DeepLinkConfig {
  /// Default scheme for internal navigation
  final String defaultScheme;

  /// Default host for internal navigation
  final String defaultHost;

  /// List of allowed schemes for incoming deep links
  final List<String> allowedSchemes;

  /// List of allowed hosts for incoming deep links
  final List<String> allowedHosts;

  /// Whether to handle deep links when app is in background
  final bool handleInBackground;

  /// Whether to log deep link events
  final bool enableLogging;

  /// Custom error handler for deep link failures
  final Function(String url, dynamic error)? errorHandler;

  /// Whether to automatically handle app links (Android) and universal links (iOS)
  final bool autoHandleAppLinks;

  const DeepLinkConfig({
    this.defaultScheme = 'app',
    this.defaultHost = 'deeplink',
    this.allowedSchemes = const [],
    this.allowedHosts = const [],
    this.handleInBackground = true,
    this.enableLogging = false,
    this.errorHandler,
    this.autoHandleAppLinks = true,
  });

  /// Create a configuration with default values
  factory DeepLinkConfig.defaultConfig() {
    return const DeepLinkConfig();
  }

  /// Create a configuration for development
  factory DeepLinkConfig.development() {
    return const DeepLinkConfig(
      enableLogging: true,
      allowedSchemes: ['http', 'https', 'app'],
    );
  }

  /// Create a configuration for production
  factory DeepLinkConfig.production({
    required List<String> allowedSchemes,
    required List<String> allowedHosts,
  }) {
    return DeepLinkConfig(
      allowedSchemes: allowedSchemes,
      allowedHosts: allowedHosts,
      enableLogging: false,
      handleInBackground: true,
    );
  }

  /// Copy with new values
  DeepLinkConfig copyWith({
    String? defaultScheme,
    String? defaultHost,
    List<String>? allowedSchemes,
    List<String>? allowedHosts,
    bool? handleInBackground,
    bool? enableLogging,
    Function(String url, dynamic error)? errorHandler,
    bool? autoHandleAppLinks,
  }) {
    return DeepLinkConfig(
      defaultScheme: defaultScheme ?? this.defaultScheme,
      defaultHost: defaultHost ?? this.defaultHost,
      allowedSchemes: allowedSchemes ?? this.allowedSchemes,
      allowedHosts: allowedHosts ?? this.allowedHosts,
      handleInBackground: handleInBackground ?? this.handleInBackground,
      enableLogging: enableLogging ?? this.enableLogging,
      errorHandler: errorHandler ?? this.errorHandler,
      autoHandleAppLinks: autoHandleAppLinks ?? this.autoHandleAppLinks,
    );
  }
}
