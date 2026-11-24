import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Fleet-wide wrapper around `package:home_widget` for updating native
/// Android/iOS home screen widgets and routing widget tap deep links.
///
/// Deep-link URIs follow the canonical format:
/// `faishal-<app>://open<route>` (for example `faishal-shalat://open/kiblat`).
class HomeWidgetService {
  HomeWidgetService._();

  static StreamSubscription<Uri?>? _clickSub;
  static bool _initialized = false;
  static bool _bound = false;

  /// Whether home screen widgets are supported on the current platform.
  static bool get isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Initializes the bridge (sets the iOS App Group ID when provided).
  static Future<void> init({String? appGroupId}) async {
    if (!isSupported || _initialized) return;
    _initialized = true;
    if (appGroupId != null && appGroupId.isNotEmpty) {
      try {
        await HomeWidget.setAppGroupId(appGroupId);
      } catch (e) {
        debugPrint('HomeWidgetService.init setAppGroupId: $e');
      }
    }
  }

  /// Saves key/value pairs to shared widget storage and triggers a native
  /// widget refresh. Safe no-op on unsupported platforms.
  static Future<void> update({
    required String androidWidgetName,
    String? iOSWidgetName,
    required Map<String, Object?> data,
  }) async {
    if (!isSupported) return;
    try {
      for (final entry in data.entries) {
        final value = entry.value;
        if (value == null) {
          await HomeWidget.saveWidgetData<String?>(entry.key, null);
        } else if (value is String) {
          await HomeWidget.saveWidgetData<String>(entry.key, value);
        } else if (value is int) {
          await HomeWidget.saveWidgetData<int>(entry.key, value);
        } else if (value is double) {
          await HomeWidget.saveWidgetData<double>(entry.key, value);
        } else if (value is bool) {
          await HomeWidget.saveWidgetData<bool>(entry.key, value);
        } else {
          await HomeWidget.saveWidgetData<String>(entry.key, value.toString());
        }
      }
      await HomeWidget.updateWidget(
        androidName: androidWidgetName,
        qualifiedAndroidName: null,
        iOSName: iOSWidgetName,
      );
    } catch (e) {
      debugPrint('HomeWidgetService.update: $e');
    }
  }

  /// Parses a widget launch [Uri] into a GoRouter-compatible route path.
  static String parseRouteFromUri(Uri uri) {
    final path = uri.path;
    if (path.isEmpty) return '/';
    final normalized = path.startsWith('/') ? path : '/$path';
    if (uri.hasQuery) {
      return '$normalized?${uri.query}';
    }
    return normalized;
  }

  /// Checks if the app was cold-started from a widget tap and listens for
  /// subsequent warm-resume widget taps, invoking [onRoute] with the target
  /// GoRouter path. Safe to call multiple times (no-ops after first bind).
  static Future<void> bindDeepLinks(void Function(String route) onRoute) async {
    if (!isSupported || _bound) return;
    _bound = true;
    try {
      final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (initialUri != null) {
        onRoute(parseRouteFromUri(initialUri));
      }
    } catch (e) {
      debugPrint('HomeWidgetService.bindDeepLinks initial: $e');
    }

    await _clickSub?.cancel();
    _clickSub = HomeWidget.widgetClicked.listen(
      (uri) {
        if (uri != null) {
          onRoute(parseRouteFromUri(uri));
        }
      },
      onError: (Object e) {
        debugPrint('HomeWidgetService.bindDeepLinks stream: $e');
      },
    );
  }

  /// Releases the widget click subscription (for tests/shutdown).
  static Future<void> dispose() async {
    await _clickSub?.cancel();
    _clickSub = null;
    _bound = false;
  }
}
