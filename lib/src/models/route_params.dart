/// Parameters extracted from a deep link route
class RouteParams {
  final String path;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
  final Uri uri;

  RouteParams({
    required this.path,
    required this.pathParameters,
    required this.queryParameters,
    required this.uri,
  });

  /// Get a path parameter by key
  String? pathParam(String key) => pathParameters[key];

  /// Get a query parameter by key
  String? queryParam(String key) => queryParameters[key];

  /// Get a parameter from either path or query parameters
  String? param(String key) {
    return pathParameters[key] ?? queryParameters[key];
  }

  /// Get a path parameter as integer
  int? pathParamAsInt(String key) {
    final value = pathParameters[key];
    return value != null ? int.tryParse(value) : null;
  }

  /// Get a query parameter as integer
  int? queryParamAsInt(String key) {
    final value = queryParameters[key];
    return value != null ? int.tryParse(value) : null;
  }

  /// Get a path parameter as double
  double? pathParamAsDouble(String key) {
    final value = pathParameters[key];
    return value != null ? double.tryParse(value) : null;
  }

  /// Get a query parameter as double
  double? queryParamAsDouble(String key) {
    final value = queryParameters[key];
    return value != null ? double.tryParse(value) : null;
  }

  /// Get a path parameter as boolean
  bool pathParamAsBool(String key, {bool defaultValue = false}) {
    final value = pathParameters[key]?.toLowerCase();
    if (value == null) return defaultValue;
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// Get a query parameter as boolean
  bool queryParamAsBool(String key, {bool defaultValue = false}) {
    final value = queryParameters[key]?.toLowerCase();
    if (value == null) return defaultValue;
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// Check if a path parameter exists
  bool hasPathParam(String key) => pathParameters.containsKey(key);

  /// Check if a query parameter exists
  bool hasQueryParam(String key) => queryParameters.containsKey(key);

  /// Get all parameters as a single map
  Map<String, String> get allParameters => {
        ...pathParameters,
        ...queryParameters,
      };

  @override
  String toString() {
    return 'RouteParams(path: $path, pathParams: $pathParameters, queryParams: $queryParameters)';
  }
}
