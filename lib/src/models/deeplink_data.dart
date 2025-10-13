/// Represents deep link data
class DeepLinkData {
  final Uri uri;
  final DateTime timestamp;
  final DeepLinkSource source;
  final Map<String, dynamic>? metadata;

  DeepLinkData({
    required this.uri,
    required this.timestamp,
    required this.source,
    this.metadata,
  });

  /// Get the scheme of the deep link
  String get scheme => uri.scheme;

  /// Get the host of the deep link
  String? get host => uri.host.isEmpty ? null : uri.host;

  /// Get the path of the deep link
  String get path => uri.path;

  /// Get query parameters
  Map<String, String> get queryParameters => uri.queryParameters;

  /// Get a specific query parameter
  String? queryParameter(String key) => queryParameters[key];

  /// Check if a query parameter exists
  bool hasQueryParameter(String key) => queryParameters.containsKey(key);

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uri': uri.toString(),
      'timestamp': timestamp.toIso8601String(),
      'source': source.toString(),
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory DeepLinkData.fromJson(Map<String, dynamic> json) {
    return DeepLinkData(
      uri: Uri.parse(json['uri'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: DeepLinkSource.values.firstWhere(
        (e) => e.toString() == json['source'],
        orElse: () => DeepLinkSource.external,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'DeepLinkData(uri: $uri, source: $source, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeepLinkData &&
        other.uri == uri &&
        other.source == source &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => uri.hashCode ^ source.hashCode ^ timestamp.hashCode;
}

/// Source of the deep link
enum DeepLinkSource {
  /// Deep link from external source (e.g., browser, other app)
  external,
  
  /// Deep link generated internally within the app
  internal,
  
  /// Deep link from push notification
  notification,
  
  /// Deep link from QR code scan
  qrCode,
  
  /// Deep link from NFC tag
  nfc,
  
  /// Unknown source
  unknown,
}
