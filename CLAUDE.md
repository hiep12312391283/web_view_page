# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Flutter package (`web_view_page`) that provides a `WebViewPage` widget for displaying a user feedback/support web app inside a Flutter application via an in-app WebView.

## Commands

```bash
# Get dependencies
flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/<test_file>.dart

# Format code
dart format lib/
```

## Architecture

The package exposes a single widget: `WebViewPage` (`lib/web_view_page.dart`).

**How it works:**
- `WebViewPage` accepts three required parameters: `version`, `route`, and `appId`
- These are JSON-encoded and passed as a `appData` query parameter to `https://support-user-package.web.app/`
- The widget uses `flutter_inappwebview` to render the remote web app
- State is managed with GetX observables (`_isLoading`, `_progress`) from the `get` package
- A JavaScript handler named `closeWebView` is registered so the web page can call `window.flutter_inappwebview.callHandler('closeWebView')` to trigger `Navigator.pop`
- Cache and cookies are cleared on every WebView creation

**Key dependencies:**
- `flutter_inappwebview: ^6.1.5` — WebView rendering
- `get: ^4.7.3` — reactive state (`.obs`, `Obx`)

**Integration in consumer apps:**

Consumer apps must configure `flutter_inappwebview` platform requirements (Android `minSdkVersion`, iOS Info.plist entries) per the plugin's documentation.
