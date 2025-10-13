import 'package:flutter/widgets.dart';
import 'models/deeplink_data.dart';
import 'models/route_params.dart';
import 'deeplink_route.dart';

/// Type definition for route handlers
typedef RouteHandler = Future<bool> Function(
    BuildContext context, RouteParams params);

/// Router for handling deep link navigation
class DeepLinkRouter {
  final Map<String, DeepLinkRoute> _routes = {};
  BuildContext? _context;

  /// Set the build context for navigation
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Register multiple routes
  void registerRoutes(Map<String, RouteHandler> routes) {
    routes.forEach((pattern, handler) {
      registerRoute(pattern, handler);
    });
  }

  /// Register a single route
  void registerRoute(String pattern, RouteHandler handler) {
    _routes[pattern] = DeepLinkRoute(
      pattern: pattern,
      handler: handler,
    );
  }

  /// Route a deep link to the appropriate handler
  Future<bool> route(DeepLinkData deepLinkData) async {
    if (_context == null) {
      debugPrint(
          'Warning: No context set for routing. Call setContext() first.');
      return false;
    }

    final path = deepLinkData.uri.path;
    final queryParams = deepLinkData.uri.queryParameters;

    // Try to find exact match first
    if (_routes.containsKey(path)) {
      final route = _routes[path]!;
      final params = RouteParams(
        path: path,
        pathParameters: {},
        queryParameters: queryParams,
        uri: deepLinkData.uri,
      );
      return await route.handler(_context!, params);
    }

    // Try pattern matching
    for (final entry in _routes.entries) {
      final routePattern = entry.key;
      final route = entry.value;

      final matchResult = _matchPattern(routePattern, path);
      if (matchResult != null) {
        final params = RouteParams(
          path: path,
          pathParameters: matchResult,
          queryParameters: queryParams,
          uri: deepLinkData.uri,
        );
        return await route.handler(_context!, params);
      }
    }

    // No matching route found
    return false;
  }

  /// Match a pattern against a path and extract parameters
  Map<String, String>? _matchPattern(String pattern, String path) {
    // Convert pattern to regex
    // Example: /user/:id/profile -> /user/([^/]+)/profile
    final patternSegments = pattern.split('/');
    final pathSegments = path.split('/');

    // Check if pattern contains wildcard
    bool hasWildcard = false;
    int wildcardIndex = -1;
    for (int i = 0; i < patternSegments.length; i++) {
      if (patternSegments[i].startsWith('*')) {
        hasWildcard = true;
        wildcardIndex = i;
        break;
      }
    }

    // If no wildcard and lengths don't match, no match
    if (!hasWildcard && patternSegments.length != pathSegments.length) {
      return null;
    }

    // If wildcard exists, path must have at least as many segments up to wildcard
    if (hasWildcard && pathSegments.length < wildcardIndex) {
      return null;
    }

    final params = <String, String>{};

    for (int i = 0; i < patternSegments.length; i++) {
      final patternSegment = patternSegments[i];

      if (patternSegment.startsWith(':')) {
        // This is a parameter
        if (i >= pathSegments.length) return null;
        final paramName = patternSegment.substring(1);
        params[paramName] = pathSegments[i];
      } else if (patternSegment.startsWith('*')) {
        // This is a wildcard - capture remaining path segments
        final paramName = patternSegment.substring(1);
        if (paramName.isNotEmpty) {
          params[paramName] = pathSegments.sublist(i).join('/');
        }
        return params; // Wildcard matches everything after this point
      } else {
        // Exact match required
        if (i >= pathSegments.length || patternSegment != pathSegments[i]) {
          return null;
        }
      }
    }

    return params;
  }

  /// Check if a route exists for a given pattern
  bool hasRoute(String pattern) {
    return _routes.containsKey(pattern);
  }

  /// Remove a route
  void removeRoute(String pattern) {
    _routes.remove(pattern);
  }

  /// Clear all routes
  void clearRoutes() {
    _routes.clear();
  }

  /// Get all registered route patterns
  List<String> get registeredPatterns => _routes.keys.toList();
}
