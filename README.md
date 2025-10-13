# DeepLink SDK

A comprehensive Flutter SDK for handling deep links on Android and iOS platforms with easy routing and configuration.

## Features

- 🔗 **Universal Deep Link Support** - Handle custom URL schemes, App Links (Android), and Universal Links (iOS)
- 🛣️ **Advanced Routing** - Pattern-based routing with parameter extraction
- 📱 **Cross-Platform** - Seamless integration for both Android and iOS
- 🎯 **Type-Safe Parameters** - Extract and parse route parameters with type safety
- 📊 **Analytics Ready** - Built-in observer pattern for tracking deep link events
- 🔧 **Flexible Configuration** - Customize allowed schemes, hosts, and error handling
- 🌊 **Stream-Based** - Real-time deep link updates via streams
- 🧪 **Easy Testing** - Test deep links directly in your app

## Installation

Add `deeplink_sdk` to your `pubspec.yaml`:

```yaml
dependencies:
  deeplink_sdk: ^1.0.4
```

Then run:

```bash
flutter pub get
```

## Platform Setup

### Android Setup

1. **Add intent filters to your `AndroidManifest.xml`:**

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop">
    
    <!-- Custom URL Scheme -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="myapp" android:host="example.com"/>
    </intent-filter>
    
    <!-- App Links (HTTPS) -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="https" android:host="example.com"/>
    </intent-filter>
</activity>
```

2. **For App Links, add your Digital Asset Links file:**

Create `.well-known/assetlinks.json` on your server:

```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.example.yourapp",
    "sha256_cert_fingerprints": ["YOUR_APP_SIGNING_CERTIFICATE_SHA256"]
  }
}]
```

### iOS Setup

1. **Add URL schemes to `Info.plist`:**

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
        <key>CFBundleURLName</key>
        <string>com.example.deeplink</string>
    </dict>
</array>
```

2. **For Universal Links, add Associated Domains:**

In `Runner.entitlements`:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:example.com</string>
</array>
```

3. **Add your Apple App Site Association file:**

Create `apple-app-site-association` on your server:

```json
{
  "applinks": {
    "apps": [],
    "details": [{
      "appID": "TEAMID.com.example.yourapp",
      "paths": ["*"]
    }]
  }
}
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:deeplink_sdk/deeplink_sdk.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeDeepLinking();
  }

  Future<void> _initializeDeepLinking() async {
    // Configure the SDK
    final config = DeepLinkConfig(
      defaultScheme: 'myapp',
      defaultHost: 'example.com',
      allowedSchemes: ['myapp', 'https'],
      allowedHosts: ['example.com'],
      enableLogging: true,
    );

    // Initialize
    await DeepLinkHandler.instance.initialize(
      config: config,
      observers: [LoggingDeepLinkObserver()],
    );

    // Set context for navigation
    DeepLinkHandler.instance._router.setContext(context);

    // Register routes
    DeepLinkHandler.instance.registerRoutes({
      '/': _handleHome,
      '/product/:id': _handleProduct,
      '/user/:userId/profile': _handleUserProfile,
      '/search': _handleSearch,
    });

    // Listen to deep links
    DeepLinkHandler.instance.deepLinkStream.listen((deepLinkData) {
      print('Received deep link: ${deepLinkData.uri}');
    });
  }

  Future<bool> _handleHome(BuildContext context, RouteParams params) async {
    // Navigate to home screen
    Navigator.pushNamed(context, '/home');
    return true;
  }

  Future<bool> _handleProduct(BuildContext context, RouteParams params) async {
    final productId = params.pathParam('id');
    // Navigate to product screen with ID
    Navigator.pushNamed(context, '/product', arguments: productId);
    return true;
  }

  Future<bool> _handleUserProfile(BuildContext context, RouteParams params) async {
    final userId = params.pathParam('userId');
    final tab = params.queryParam('tab') ?? 'posts';
    // Navigate to user profile
    Navigator.pushNamed(context, '/profile', arguments: {'userId': userId, 'tab': tab});
    return true;
  }

  Future<bool> _handleSearch(BuildContext context, RouteParams params) async {
    final query = params.queryParam('q');
    // Navigate to search with query
    Navigator.pushNamed(context, '/search', arguments: query);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepLink Example',
      home: HomeScreen(),
    );
  }
}
```

## Advanced Usage

### Route Patterns

The SDK supports various route patterns:

- **Exact match**: `/home`
- **Path parameters**: `/product/:id` - Captures `id` as a parameter
- **Multiple parameters**: `/user/:userId/post/:postId`
- **Wildcard**: `/settings/*section` - Captures everything after `/settings/`

### Parameter Extraction

```dart
Future<bool> handleRoute(BuildContext context, RouteParams params) async {
  // Path parameters
  String? id = params.pathParam('id');
  int? numericId = params.pathParamAsInt('id');
  
  // Query parameters
  String? query = params.queryParam('q');
  bool featured = params.queryParamAsBool('featured', defaultValue: false);
  
  // Get all parameters
  Map<String, String> allParams = params.allParameters;
  
  return true;
}
```

### Custom Observers

Create custom observers to track deep link events:

```dart
class MyAnalyticsObserver extends DeepLinkObserver {
  @override
  void onDeepLinkReceived(DeepLinkData data) {
    // Track in your analytics service
    analytics.track('deep_link_received', {
      'url': data.uri.toString(),
      'source': data.source.toString(),
    });
  }

  @override
  void onDeepLinkHandled(DeepLinkData data) {
    // Track successful handling
  }

  @override
  void onDeepLinkFailed(DeepLinkData data, String error) {
    // Track failures
  }
}
```

### Internal Navigation

Navigate internally using deep links:

```dart
// Navigate to a route programmatically
await DeepLinkHandler.instance.navigateTo(
  '/product/123',
  parameters: {'ref': 'home', 'campaign': 'sale'},
);
```

### Configuration Options

```dart
final config = DeepLinkConfig(
  defaultScheme: 'myapp',
  defaultHost: 'example.com',
  allowedSchemes: ['myapp', 'https', 'http'],
  allowedHosts: ['example.com', 'app.example.com'],
  handleInBackground: true,
  enableLogging: true,
  autoHandleAppLinks: true,
  errorHandler: (url, error) {
    // Custom error handling
    print('Deep link error: $url - $error');
  },
);
```

## Testing Deep Links

### Android

Test using ADB:

```bash
# Custom scheme
adb shell am start -W -a android.intent.action.VIEW -d "myapp://example.com/product/123"

# HTTPS link
adb shell am start -W -a android.intent.action.VIEW -d "https://example.com/product/123"
```

### iOS

Test using the Simulator or device:

```bash
# Custom scheme
xcrun simctl openurl booted "myapp://example.com/product/123"

# Universal link
xcrun simctl openurl booted "https://example.com/product/123"
```

### In-App Testing

The example app includes a testing interface to simulate deep links:

```dart
DeepLinkHandler.instance.handleDeepLink('myapp://example.com/product/123');
```

## API Reference

### DeepLinkHandler

The main class for handling deep links.

**Methods:**
- `initialize()` - Initialize the handler with configuration
- `registerRoutes()` - Register multiple routes
- `registerRoute()` - Register a single route
- `handleDeepLink()` - Manually handle a deep link
- `navigateTo()` - Navigate internally using deep links
- `addObserver()` - Add an observer for deep link events
- `removeObserver()` - Remove an observer
- `dispose()` - Clean up resources

### DeepLinkConfig

Configuration for the deep link handler.

**Properties:**
- `defaultScheme` - Default scheme for internal navigation
- `defaultHost` - Default host for internal navigation
- `allowedSchemes` - List of allowed URL schemes
- `allowedHosts` - List of allowed hosts
- `handleInBackground` - Handle links when app is in background
- `enableLogging` - Enable debug logging
- `errorHandler` - Custom error handler function
- `autoHandleAppLinks` - Automatically handle app/universal links

### RouteParams

Parameters extracted from a deep link.

**Methods:**
- `pathParam()` - Get a path parameter
- `queryParam()` - Get a query parameter
- `pathParamAsInt()` - Get path parameter as integer
- `queryParamAsInt()` - Get query parameter as integer
- `pathParamAsBool()` - Get path parameter as boolean
- `queryParamAsBool()` - Get query parameter as boolean

### DeepLinkData

Data about a received deep link.

**Properties:**
- `uri` - The full URI
- `scheme` - URL scheme
- `host` - URL host
- `path` - URL path
- `queryParameters` - Query parameters map
- `timestamp` - When the link was received
- `source` - Source of the deep link (external, internal, notification, etc.)

## Troubleshooting

### Common Issues

**Deep links not working on Android:**
- Ensure `android:exported="true"` is set on your MainActivity
- Check that your intent filters are correctly configured
- Verify your Digital Asset Links file is accessible

**Deep links not working on iOS:**
- Ensure URL schemes are registered in Info.plist
- Check Associated Domains configuration
- Verify your Apple App Site Association file is accessible
- Make sure entitlements are properly configured

**Routes not matching:**
- Check that routes are registered before deep links are received
- Verify the route pattern matches the incoming URL path
- Ensure the context is set before routing

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues, questions, or suggestions, please file an issue on the [GitHub repository](https://github.com/yourusername/deeplink_sdk).
