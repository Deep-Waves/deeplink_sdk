import 'dart:async';
import 'package:flutter/services.dart' as services;
import 'package:flutter/widgets.dart';
import 'deeplink_router.dart';
import 'deeplink_config.dart';
import 'deeplink_observer.dart';
import 'models/deeplink_data.dart';
import 'exceptions/deeplink_exceptions.dart';

/// Main handler for deep links in the application
class DeepLinkHandler {
  static DeepLinkHandler? _instance;
  
  /// Get the singleton instance of DeepLinkHandler
  static DeepLinkHandler get instance {
    _instance ??= DeepLinkHandler._internal();
    return _instance!;
  }

  DeepLinkHandler._internal();

  static const services.MethodChannel _channel = services.MethodChannel('deeplink_sdk');
  static const services.EventChannel _eventChannel = services.EventChannel('deeplink_sdk/events');
  
  final DeepLinkRouter router = DeepLinkRouter();
  DeepLinkConfig? _config;
  
  StreamSubscription<String>? _linkSubscription;
  final StreamController<DeepLinkData> _deepLinkController = StreamController<DeepLinkData>.broadcast();
  final List<DeepLinkObserver> _observers = [];

  /// Stream of incoming deep links
  Stream<DeepLinkData> get deepLinkStream => _deepLinkController.stream;

  /// Initialize the deep link handler with configuration
  Future<void> initialize({
    required DeepLinkConfig config,
    List<DeepLinkObserver>? observers,
  }) async {
    _config = config;
    
    if (observers != null) {
      _observers.addAll(observers);
    }

    // Set up method channel for platform communication
    _channel.setMethodCallHandler(_handleMethodCall);
    
    // Listen for deep links
    _startListening();
    
    // Check for initial link (app opened via deep link)
    await _checkInitialLink();
  }

  /// Register routes for deep link handling
  void registerRoutes(Map<String, RouteHandler> routes) {
    router.registerRoutes(routes);
  }

  /// Register a single route
  void registerRoute(String pattern, RouteHandler handler) {
    router.registerRoute(pattern, handler);
  }

  /// Handle an incoming deep link
  Future<bool> handleDeepLink(String url) async {
    try {
      final uri = Uri.parse(url);
      
      // Validate the deep link
      if (!_isValidDeepLink(uri)) {
        throw InvalidDeepLinkException('Invalid deep link: $url');
      }

      // Create deep link data
      final deepLinkData = DeepLinkData(
        uri: uri,
        timestamp: DateTime.now(),
        source: DeepLinkSource.external,
      );

      // Notify observers
      for (final observer in _observers) {
        observer.onDeepLinkReceived(deepLinkData);
      }

      // Add to stream
      _deepLinkController.add(deepLinkData);

      // Route the deep link
      final handled = await router.route(deepLinkData);
      
      if (handled) {
        for (final observer in _observers) {
          observer.onDeepLinkHandled(deepLinkData);
        }
      } else {
        for (final observer in _observers) {
          observer.onDeepLinkFailed(deepLinkData, 'No matching route found');
        }
      }

      return handled;
    } catch (e) {
      for (final observer in _observers) {
        observer.onDeepLinkFailed(
          DeepLinkData(
            uri: Uri.parse(url),
            timestamp: DateTime.now(),
            source: DeepLinkSource.external,
          ),
          e.toString(),
        );
      }
      rethrow;
    }
  }

  /// Navigate to a deep link internally
  Future<bool> navigateTo(String path, {Map<String, dynamic>? parameters}) async {
    final uri = Uri(
      scheme: _config?.defaultScheme ?? 'app',
      host: _config?.defaultHost ?? 'deeplink',
      path: path,
      queryParameters: parameters?.map((key, value) => MapEntry(key, value.toString())),
    );

    final deepLinkData = DeepLinkData(
      uri: uri,
      timestamp: DateTime.now(),
      source: DeepLinkSource.internal,
    );

    return router.route(deepLinkData);
  }

  /// Start listening for deep links
  void _startListening() {
    _linkSubscription?.cancel();
    _linkSubscription = _eventChannel
        .receiveBroadcastStream()
        .cast<String>()
        .listen((String link) {
      handleDeepLink(link);
    });
  }

  /// Check for initial deep link (app opened via deep link)
  Future<void> _checkInitialLink() async {
    try {
      final initialLink = await _channel.invokeMethod<String>('getInitialLink');
      if (initialLink != null && initialLink.isNotEmpty) {
        await handleDeepLink(initialLink);
      }
    } on services.PlatformException catch (e) {
      debugPrint('Failed to get initial link: ${e.message}');
    }
  }

  /// Handle method calls from platform
  Future<dynamic> _handleMethodCall(services.MethodCall call) async {
    switch (call.method) {
      case 'onDeepLink':
        final String url = call.arguments as String;
        await handleDeepLink(url);
        break;
      default:
        throw services.PlatformException(
          code: 'Unimplemented',
          details: 'Method ${call.method} not implemented',
        );
    }
  }

  /// Validate if the deep link is valid according to configuration
  bool _isValidDeepLink(Uri uri) {
    if (_config == null) return true;

    // Check allowed schemes
    if (_config!.allowedSchemes.isNotEmpty && 
        !_config!.allowedSchemes.contains(uri.scheme)) {
      return false;
    }

    // Check allowed hosts
    if (_config!.allowedHosts.isNotEmpty && 
        !_config!.allowedHosts.contains(uri.host)) {
      return false;
    }

    return true;
  }

  /// Add an observer
  void addObserver(DeepLinkObserver observer) {
    _observers.add(observer);
  }

  /// Remove an observer
  void removeObserver(DeepLinkObserver observer) {
    _observers.remove(observer);
  }

  /// Dispose of resources
  void dispose() {
    _linkSubscription?.cancel();
    _deepLinkController.close();
    _observers.clear();
  }
}
