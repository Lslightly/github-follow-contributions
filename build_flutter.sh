#!/bin/bash

# Build script for Flutter web and Android

echo "Building Flutter application..."

# Change to Flutter project directory
cd flutter_project

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build for web
echo "Building for web..."
flutter build web --release

# Build for Android
echo "Building for Android..."
flutter build apk --release

echo "Build completed!"
echo "Web build: build/web/"
echo "Android APK: build/app/outputs/flutter-apk/app-release.apk"