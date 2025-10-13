#!/bin/bash

echo "🚀 Setting up DeepLink SDK..."

# Get dependencies for the main package
echo "📦 Installing package dependencies..."
flutter pub get

# Get dependencies for the example app
echo "📱 Setting up example app..."
cd example
flutter pub get
cd ..

# Run tests
echo "🧪 Running tests..."
flutter test

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze

echo "✅ Setup complete! The DeepLink SDK is ready to use."
echo ""
echo "To run the example app:"
echo "  cd example"
echo "  flutter run"
echo ""
echo "To test deep links on Android:"
echo "  adb shell am start -W -a android.intent.action.VIEW -d \"myapp://example.com/product/123\""
echo ""
echo "To test deep links on iOS Simulator:"
echo "  xcrun simctl openurl booted \"myapp://example.com/product/123\""
