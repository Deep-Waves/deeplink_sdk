import 'package:flutter_test/flutter_test.dart';
import 'package:deeplink_sdk/deeplink_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() {
  group('DeepLinkConfig Tests', () {
    test('should create default config', () {
      final config = DeepLinkConfig.defaultConfig();
      
      expect(config.defaultScheme, 'app');
      expect(config.defaultHost, 'deeplink');
      expect(config.allowedSchemes, isEmpty);
      expect(config.allowedHosts, isEmpty);
      expect(config.handleInBackground, isTrue);
      expect(config.enableLogging, isFalse);
      expect(config.autoHandleAppLinks, isTrue);
    });

    test('should create development config', () {
      final config = DeepLinkConfig.development();
      
      expect(config.enableLogging, isTrue);
      expect(config.allowedSchemes, contains('http'));
      expect(config.allowedSchemes, contains('https'));
      expect(config.allowedSchemes, contains('app'));
    });

    test('should create production config', () {
      final config = DeepLinkConfig.production(
        allowedSchemes: ['myapp', 'https'],
        allowedHosts: ['example.com'],
      );
      
      expect(config.enableLogging, isFalse);
      expect(config.handleInBackground, isTrue);
      expect(config.allowedSchemes, contains('myapp'));
      expect(config.allowedSchemes, contains('https'));
      expect(config.allowedHosts, contains('example.com'));
    });

    test('should copy with new values', () {
      final original = DeepLinkConfig.defaultConfig();
      final copied = original.copyWith(
        defaultScheme: 'custom',
        enableLogging: true,
      );
      
      expect(copied.defaultScheme, 'custom');
      expect(copied.enableLogging, isTrue);
      expect(copied.defaultHost, original.defaultHost);
    });
  });

  group('DeepLinkData Tests', () {
    test('should create deep link data', () {
      final uri = Uri.parse('myapp://example.com/product/123?ref=home');
      final data = DeepLinkData(
        uri: uri,
        timestamp: DateTime(2024, 1, 1),
        source: DeepLinkSource.external,
      );
      
      expect(data.scheme, 'myapp');
      expect(data.host, 'example.com');
      expect(data.path, '/product/123');
      expect(data.queryParameters['ref'], 'home');
      expect(data.source, DeepLinkSource.external);
    });

    test('should convert to and from JSON', () {
      final uri = Uri.parse('myapp://example.com/test');
      final original = DeepLinkData(
        uri: uri,
        timestamp: DateTime(2024, 1, 1),
        source: DeepLinkSource.notification,
        metadata: {'key': 'value'},
      );
      
      final json = original.toJson();
      final restored = DeepLinkData.fromJson(json);
      
      expect(restored.uri.toString(), original.uri.toString());
      expect(restored.source, original.source);
      expect(restored.metadata, original.metadata);
    });

    test('should check query parameter existence', () {
      final uri = Uri.parse('myapp://example.com/test?foo=bar&baz=qux');
      final data = DeepLinkData(
        uri: uri,
        timestamp: DateTime.now(),
        source: DeepLinkSource.external,
      );
      
      expect(data.hasQueryParameter('foo'), isTrue);
      expect(data.hasQueryParameter('baz'), isTrue);
      expect(data.hasQueryParameter('missing'), isFalse);
      expect(data.queryParameter('foo'), 'bar');
      expect(data.queryParameter('missing'), isNull);
    });
  });

  group('RouteParams Tests', () {
    test('should extract path and query parameters', () {
      final params = RouteParams(
        path: '/user/123/profile',
        pathParameters: {'userId': '123'},
        queryParameters: {'tab': 'posts', 'sort': 'recent'},
        uri: Uri.parse('myapp://example.com/user/123/profile?tab=posts&sort=recent'),
      );
      
      expect(params.pathParam('userId'), '123');
      expect(params.queryParam('tab'), 'posts');
      expect(params.queryParam('sort'), 'recent');
      expect(params.param('userId'), '123');
      expect(params.param('tab'), 'posts');
    });

    test('should parse parameters as different types', () {
      final params = RouteParams(
        path: '/test',
        pathParameters: {'id': '42', 'ratio': '3.14', 'active': 'true'},
        queryParameters: {'count': '10', 'price': '19.99', 'featured': 'false'},
        uri: Uri.parse('test://test'),
      );
      
      expect(params.pathParamAsInt('id'), 42);
      expect(params.pathParamAsDouble('ratio'), 3.14);
      expect(params.pathParamAsBool('active'), isTrue);
      
      expect(params.queryParamAsInt('count'), 10);
      expect(params.queryParamAsDouble('price'), 19.99);
      expect(params.queryParamAsBool('featured'), isFalse);
    });

    test('should handle missing parameters', () {
      final params = RouteParams(
        path: '/test',
        pathParameters: {},
        queryParameters: {},
        uri: Uri.parse('test://test'),
      );
      
      expect(params.pathParam('missing'), isNull);
      expect(params.queryParam('missing'), isNull);
      expect(params.pathParamAsInt('missing'), isNull);
      expect(params.queryParamAsDouble('missing'), isNull);
      expect(params.pathParamAsBool('missing'), isFalse);
      expect(params.queryParamAsBool('missing', defaultValue: true), isTrue);
    });

    test('should check parameter existence', () {
      final params = RouteParams(
        path: '/test',
        pathParameters: {'pathKey': 'value'},
        queryParameters: {'queryKey': 'value'},
        uri: Uri.parse('test://test'),
      );
      
      expect(params.hasPathParam('pathKey'), isTrue);
      expect(params.hasPathParam('missing'), isFalse);
      expect(params.hasQueryParam('queryKey'), isTrue);
      expect(params.hasQueryParam('missing'), isFalse);
    });

    test('should get all parameters', () {
      final params = RouteParams(
        path: '/test',
        pathParameters: {'id': '123'},
        queryParameters: {'name': 'test'},
        uri: Uri.parse('test://test'),
      );
      
      final all = params.allParameters;
      expect(all['id'], '123');
      expect(all['name'], 'test');
      expect(all.length, 2);
    });
  });

  group('DeepLinkRouter Tests', () {
    late DeepLinkRouter router;
    late BuildContext context;

    setUp(() {
      router = DeepLinkRouter();
      context = _MockBuildContext();
      router.setContext(context);
    });

    test('should register and match exact routes', () async {
      var called = false;
      router.registerRoute('/test', (context, params) async {
        called = true;
        return true;
      });
      
      expect(router.hasRoute('/test'), isTrue);
      expect(router.registeredPatterns, contains('/test'));
      
      final deepLink = DeepLinkData(
        uri: Uri.parse('myapp://example.com/test'),
        timestamp: DateTime.now(),
        source: DeepLinkSource.external,
      );
      
      final result = await router.route(deepLink);
      expect(result, isTrue);
      expect(called, isTrue);
    });

    test('should match routes with path parameters', () async {
      String? capturedId;
      router.registerRoute('/product/:id', (context, params) async {
        capturedId = params.pathParam('id');
        return true;
      });
      
      final deepLink = DeepLinkData(
        uri: Uri.parse('myapp://example.com/product/123'),
        timestamp: DateTime.now(),
        source: DeepLinkSource.external,
      );
      
      final result = await router.route(deepLink);
      expect(result, isTrue);
      expect(capturedId, '123');
    });

    test('should match routes with multiple parameters', () async {
      String? userId;
      String? postId;
      
      router.registerRoute('/user/:userId/post/:postId', (context, params) async {
        userId = params.pathParam('userId');
        postId = params.pathParam('postId');
        return true;
      });
      
      final deepLink = DeepLinkData(
        uri: Uri.parse('myapp://example.com/user/456/post/789'),
        timestamp: DateTime.now(),
        source: DeepLinkSource.external,
      );
      
      final result = await router.route(deepLink);
      expect(result, isTrue);
      expect(userId, '456');
      expect(postId, '789');
    });

    test('should match wildcard routes', () async {
      String? section;
      
      router.registerRoute('/settings/*section', (context, params) async {
        section = params.pathParam('section');
        return true;
      });
      
      final deepLink = DeepLinkData(
        uri: Uri.parse('myapp://example.com/settings/privacy/general'),
        timestamp: DateTime.now(),
        source: DeepLinkSource.external,
      );
      
      final result = await router.route(deepLink);
      expect(result, isTrue);
      expect(section, 'privacy/general');
    });

    test('should pass query parameters', () async {
      Map<String, String>? queryParams;
      
      router.registerRoute('/search', (context, params) async {
        queryParams = params.queryParameters;
        return true;
      });
      
      final deepLink = DeepLinkData(
        uri: Uri.parse('myapp://example.com/search?q=flutter&category=mobile'),
        timestamp: DateTime.now(),
        source: DeepLinkSource.external,
      );
      
      final result = await router.route(deepLink);
      expect(result, isTrue);
      expect(queryParams?['q'], 'flutter');
      expect(queryParams?['category'], 'mobile');
    });

    test('should return false for unmatched routes', () async {
      router.registerRoute('/test', (context, params) async => true);
      
      final deepLink = DeepLinkData(
        uri: Uri.parse('myapp://example.com/unknown'),
        timestamp: DateTime.now(),
        source: DeepLinkSource.external,
      );
      
      final result = await router.route(deepLink);
      expect(result, isFalse);
    });

    test('should remove routes', () {
      router.registerRoute('/test', (context, params) async => true);
      expect(router.hasRoute('/test'), isTrue);
      
      router.removeRoute('/test');
      expect(router.hasRoute('/test'), isFalse);
    });

    test('should clear all routes', () {
      router.registerRoute('/test1', (context, params) async => true);
      router.registerRoute('/test2', (context, params) async => true);
      expect(router.registeredPatterns.length, 2);
      
      router.clearRoutes();
      expect(router.registeredPatterns, isEmpty);
    });
  });

  group('DeepLinkRoute Tests', () {
    test('should create route with metadata', () {
      final route = DeepLinkRoute(
        pattern: '/test',
        handler: (context, params) async => true,
        name: 'TestRoute',
        metadata: {'key': 'value'},
      );
      
      expect(route.pattern, '/test');
      expect(route.name, 'TestRoute');
      expect(route.metadata?['key'], 'value');
    });

    test('should compare routes by pattern', () {
      final route1 = DeepLinkRoute(
        pattern: '/test',
        handler: (context, params) async => true,
      );
      
      final route2 = DeepLinkRoute(
        pattern: '/test',
        handler: (context, params) async => false,
      );
      
      final route3 = DeepLinkRoute(
        pattern: '/other',
        handler: (context, params) async => true,
      );
      
      expect(route1, equals(route2));
      expect(route1, isNot(equals(route3)));
    });
  });

  group('Exception Tests', () {
    test('should create InvalidDeepLinkException', () {
      final exception = InvalidDeepLinkException('Invalid URL', 'cause');
      expect(exception.message, 'Invalid URL');
      expect(exception.cause, 'cause');
      expect(exception.toString(), contains('Invalid URL'));
      expect(exception.toString(), contains('cause'));
    });

    test('should create RouteNotFoundException', () {
      final exception = RouteNotFoundException('/unknown');
      expect(exception.path, '/unknown');
      expect(exception.message, contains('/unknown'));
    });

    test('should create InvalidConfigurationException', () {
      final exception = InvalidConfigurationException('Bad config');
      expect(exception.message, 'Bad config');
    });

    test('should create PlatformException', () {
      final exception = PlatformException(
        code: 'ERROR_CODE',
        message: 'Platform error',
        cause: 'Some cause',
      );
      expect(exception.code, 'ERROR_CODE');
      expect(exception.message, 'Platform error');
      expect(exception.cause, 'Some cause');
    });
  });
}

// Mock BuildContext for testing
class _MockBuildContext implements BuildContext {
  @override
  bool get debugDoingBuild => false;

  @override
  bool get mounted => true;

  @override
  InheritedWidget dependOnInheritedElement(InheritedElement ancestor, {Object? aspect}) {
    throw UnimplementedError();
  }

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({Object? aspect}) {
    return null;
  }

  @override
  T? getInheritedWidgetOfExactType<T extends InheritedWidget>() {
    return null;
  }

  @override
  DiagnosticsNode describeElement(String name, {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  List<DiagnosticsNode> describeMissingAncestor({required Type expectedAncestorType}) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeOwnershipChain(String name) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeWidget(String name, {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  T? findAncestorRenderObjectOfType<T extends RenderObject>() {
    return null;
  }

  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() {
    return null;
  }

  @override
  T? findAncestorWidgetOfExactType<T extends Widget>() {
    return null;
  }

  @override
  RenderObject? findRenderObject() {
    return null;
  }

  @override
  T? findRootAncestorStateOfType<T extends State<StatefulWidget>>() {
    return null;
  }

  @override
  InheritedElement? getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() {
    return null;
  }

  @override
  BuildOwner? get owner => null;

  @override
  Size? get size => null;

  @override
  void visitAncestorElements(bool Function(Element element) visitor) {}

  @override
  void visitChildElements(void Function(Element element) visitor) {}

  @override
  Widget get widget => throw UnimplementedError();

  @override
  void dispatchNotification(Notification notification) {}
}
