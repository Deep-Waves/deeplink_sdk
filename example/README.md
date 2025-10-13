# DeepLink SDK Example

This example demonstrates how to use the DeepLink SDK package to handle deep links in a Flutter application.

## Features Demonstrated

- Route registration and pattern matching
- Path parameter extraction
- Query parameter handling
- Wildcard routes
- Deep link history tracking
- Real-time deep link monitoring
- Custom deep link testing interface

## Getting Started

1. Run the example app:
```bash
flutter run
```

2. Test deep links using the in-app interface or platform-specific commands:

### Android
```bash
adb shell am start -W -a android.intent.action.VIEW -d "myapp://example.com/product/123"
```

### iOS
```bash
xcrun simctl openurl booted "myapp://example.com/product/123"
```

## Supported Routes

- `/` - Home route
- `/product/:id` - Product details with ID parameter
- `/user/:userId/profile` - User profile with user ID
- `/search` - Search with query parameters
- `/settings/*section` - Settings with wildcard section

## Platform Configuration

The example app is pre-configured with:
- Custom URL scheme: `myapp://`
- HTTPS links: `https://example.com`
- Android App Links support
- iOS Universal Links support

See the main package documentation for detailed setup instructions.
