import 'models/deeplink_data.dart';

/// Observer for deep link events
abstract class DeepLinkObserver {
  /// Called when a deep link is received
  void onDeepLinkReceived(DeepLinkData data);
  
  /// Called when a deep link is successfully handled
  void onDeepLinkHandled(DeepLinkData data);
  
  /// Called when a deep link fails to be handled
  void onDeepLinkFailed(DeepLinkData data, String error);
}

/// Default implementation of DeepLinkObserver for logging
class LoggingDeepLinkObserver extends DeepLinkObserver {
  @override
  void onDeepLinkReceived(DeepLinkData data) {
    print('[DeepLink] Received: ${data.uri}');
  }

  @override
  void onDeepLinkHandled(DeepLinkData data) {
    print('[DeepLink] Handled: ${data.uri}');
  }

  @override
  void onDeepLinkFailed(DeepLinkData data, String error) {
    print('[DeepLink] Failed: ${data.uri} - Error: $error');
  }
}

/// Analytics observer for tracking deep link events
class AnalyticsDeepLinkObserver extends DeepLinkObserver {
  final void Function(String event, Map<String, dynamic> parameters)? trackEvent;

  AnalyticsDeepLinkObserver({this.trackEvent});

  @override
  void onDeepLinkReceived(DeepLinkData data) {
    trackEvent?.call('deep_link_received', {
      'url': data.uri.toString(),
      'source': data.source.toString(),
      'timestamp': data.timestamp.toIso8601String(),
    });
  }

  @override
  void onDeepLinkHandled(DeepLinkData data) {
    trackEvent?.call('deep_link_handled', {
      'url': data.uri.toString(),
      'source': data.source.toString(),
      'timestamp': data.timestamp.toIso8601String(),
    });
  }

  @override
  void onDeepLinkFailed(DeepLinkData data, String error) {
    trackEvent?.call('deep_link_failed', {
      'url': data.uri.toString(),
      'source': data.source.toString(),
      'error': error,
      'timestamp': data.timestamp.toIso8601String(),
    });
  }
}
