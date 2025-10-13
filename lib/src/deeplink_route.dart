import 'deeplink_router.dart';

/// Represents a deep link route
class DeepLinkRoute {
  final String pattern;
  final RouteHandler handler;
  final String? name;
  final Map<String, dynamic>? metadata;

  DeepLinkRoute({
    required this.pattern,
    required this.handler,
    this.name,
    this.metadata,
  });

  @override
  String toString() {
    return 'DeepLinkRoute(pattern: $pattern, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeepLinkRoute && other.pattern == pattern;
  }

  @override
  int get hashCode => pattern.hashCode;
}
