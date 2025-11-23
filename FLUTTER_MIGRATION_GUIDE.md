# Flutter Migration Guide

This document explains how to migrate from the Vue.js application to the Flutter application.

## Project Structure

```
flutter_project/
├── lib/
│   ├── main.dart                    # Main application entry point
│   ├── models/
│   │   └── event_data.dart         # Event data model
│   ├── providers/
│   │   └── event_provider.dart     # State management (equivalent to Vuex/Pinia)
│   ├── screens/
│   │   └── home_screen.dart        # Main screen
│   └── widgets/
│       ├── event_filter_dropdown.dart  # Filter dropdown widget
│       ├── legend_widget.dart         # Legend widget
│       └── user_card_widget.dart      # User card widget
├── assets/
│   └── events.json                 # GitHub events data
├── android/                        # Android-specific configuration
├── web/                           # Web-specific configuration
└── pubspec.yaml                   # Flutter dependencies
```

## Key Differences from Vue.js

### 1. State Management
- **Vue.js**: Uses reactive data in components
- **Flutter**: Uses Provider pattern for state management
- The `EventProvider` class manages all application state

### 2. Component Structure
- **Vue.js**: Single File Components (.vue files)
- **Flutter**: Widget classes with build methods
- Each Vue component is converted to a Flutter widget

### 3. Styling
- **Vue.js**: CSS in `<style>` tags
- **Flutter**: Inline styling with `BoxDecoration`, `TextStyle`, etc.
- Colors and styling are defined in the widgets themselves

### 4. Data Loading
- **Vue.js**: `created()` lifecycle hook
- **Flutter**: `initState()` with `WidgetsBinding.instance.addPostFrameCallback`

### 5. Navigation
- **Vue.js**: Vue Router
- **Flutter**: MaterialApp with Navigator (simplified for this app)

## Building and Running

### Prerequisites
1. Install Flutter SDK
2. Install Android Studio (for Android builds)
3. Install Chrome (for web builds)

### Build Commands
```bash
# Make build script executable
chmod +x build_flutter.sh

# Run build script
./build_flutter.sh
```

### Manual Build Commands
```bash
cd flutter_project

# Get dependencies
flutter pub get

# Build for web
flutter build web --release

# Build for Android
flutter build apk --release
```

### Run Development Server
```bash
cd flutter_project
flutter run -d chrome  # For web
flutter run -d android  # For Android (requires emulator/device)
```

## Deployment

### Web Deployment
1. Build for web: `flutter build web --release`
2. Deploy the `build/web/` folder to your web server
3. The app is configured as a PWA with offline support

### Android Deployment
1. Build APK: `flutter build apk --release`
2. Install APK: `flutter install`
3. Or manually install from `build/app/outputs/flutter-apk/app-release.apk`

## Features Migrated

✅ Event filtering with dropdown
✅ User cards with avatars
✅ Event type styling and colors
✅ Tooltips with detailed information
✅ Responsive design
✅ GitHub links (using url_launcher)
✅ Legend with categories
✅ Mobile-friendly UI

## Dependencies Used

- `provider`: State management (equivalent to Vuex/Pinia)
- `url_launcher`: Open URLs in browser (equivalent to `<a>` tags)
- `http`: For potential future API calls

## Future Enhancements

1. Add pull-to-refresh functionality
2. Implement dark mode support
3. Add search functionality
4. Cache data for offline use
5. Add animations and transitions
6. Implement infinite scroll for large datasets