import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Descriptor for a single quick-action slot in the Android Quick Actions
/// notification bar (4 actions + 1 dismiss button, CamScanner-style).
@immutable
class QuickNotifAction {
  const QuickNotifAction({
    required this.id,
    required this.label,
    required this.route,
    required this.iconRes,
  });

  final String id;
  final String label;
  final String route;
  final String iconRes;

  Map<String, String> toMap() => {
        'id': id,
        'label': label,
        'route': route,
        'iconRes': iconRes,
      };
}

/// Manages the CamScanner-style persistent/dismissible Quick Action
/// Notification bar on Android via `MethodChannel`.
///
/// On iOS, macOS, and Web, all methods are safe no-ops ([isSupported] is false).
class QuickActionNotificationService {
  QuickActionNotificationService._();

  static const MethodChannel _channel =
      MethodChannel('id.faishal.fleet/quick_notif');

  @visibleForTesting
  static TargetPlatform? debugPlatformOverride;

  static bool get isSupported {
    if (kIsWeb) return false;
    final platform = debugPlatformOverride ?? defaultTargetPlatform;
    return platform == TargetPlatform.android;
  }

  /// Registers a callback invoked when the user taps one of the 4 quick-action
  /// buttons while the app is running or resumed from background.
  static void setActionHandler(void Function(String route) onRoute) {
    if (!isSupported) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onQuickAction') {
        final route = call.arguments as String?;
        if (route != null && route.isNotEmpty) {
          onRoute(route);
        }
      }
    });
  }

  /// Returns the route if the app was cold-started from a quick-action tap,
  /// consuming it so subsequent calls return `null`.
  static Future<String?> getInitialActionRoute() async {
    if (!isSupported) return null;
    try {
      return await _channel.invokeMethod<String>('getInitialActionRoute');
    } catch (e) {
      debugPrint('QuickActionNotificationService.getInitialActionRoute: $e');
      return null;
    }
  }

  /// Shows or updates the 4-action Quick Actions notification bar.
  static Future<bool> show({
    required List<QuickNotifAction> actions,
    required int accentColorArgb,
    bool ongoing = true,
  }) async {
    if (!isSupported) return false;
    assert(actions.length == 4, 'Quick action bar expects exactly 4 actions');
    try {
      return await _channel.invokeMethod<bool>('show', {
            'actions': actions.map((a) => a.toMap()).toList(),
            'accentColor': accentColorArgb,
            'ongoing': ongoing,
          }) ??
          false;
    } catch (e) {
      debugPrint('QuickActionNotificationService.show: $e');
      return false;
    }
  }

  /// Hides/cancels the Quick Actions notification bar.
  static Future<void> hide() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('hide');
    } catch (e) {
      debugPrint('QuickActionNotificationService.hide: $e');
    }
  }

  /// Returns whether the Quick Actions notification bar is currently enabled.
  static Future<bool> isEnabled() async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('isEnabled') ?? false;
    } catch (e) {
      debugPrint('QuickActionNotificationService.isEnabled: $e');
      return false;
    }
  }
}
