import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../utils/app_timezone.dart';
import 'app_providers.dart';

/// Persisted manual zone key. Absent (or corrupt) means Auto: follow device.
const kAppTimezoneKey = 'app_timezone';

/// Device zone name, resolved in `main()` before `runApp` and refreshed on
/// app resume while the mode is Auto. Never the display zone on its own —
/// read [timezoneLocationProvider] for that.
final deviceZoneProvider =
    NotifierProvider<DeviceZoneNotifier, String>(DeviceZoneNotifier.new);

class DeviceZoneNotifier extends Notifier<String> {
  @override
  String build() => AppTimeZone.cachedDeviceZone;

  /// Re-reads the device zone (e.g. after travel). No-op when unchanged.
  Future<void> refresh() async {
    final name = await AppTimeZone.getDeviceZoneName();
    AppTimeZone.cachedDeviceZone = name;
    if (name != state) state = name;
  }
}

/// Manual zone override, IANA name. `null` follows the device zone (Auto) —
/// the same nullable-means-system pattern as `localeProvider`.
final timezoneProvider =
    NotifierProvider<TimezoneNotifier, String?>(TimezoneNotifier.new);

class TimezoneNotifier extends Notifier<String?> {
  @override
  String? build() {
    final name =
        ref.watch(localStorageServiceProvider).prefs.getString(kAppTimezoneKey);
    if (name == null) return null;
    if (AppTimeZone.isValidZoneName(name)) return name;
    // Corrupt value from an older build: drop it rather than crash (§VAL —
    // an IANA name that does not resolve is not a setting, it is garbage).
    _dropBadKey();
    return null;
  }

  /// Pins a manual zone. Throws [ArgumentError] on an unknown IANA name
  /// (§VAL: validate via `tz.getLocation`, never store a raw string).
  Future<void> setZone(String ianaName) async {
    final loc = tz.getLocation(ianaName);
    state = loc.name;
    await ref
        .read(localStorageServiceProvider)
        .prefs
        .setString(kAppTimezoneKey, loc.name);
  }

  /// Back to Auto: follow the device zone again.
  Future<void> resetToAuto() async {
    state = null;
    await ref.read(localStorageServiceProvider).prefs.remove(kAppTimezoneKey);
  }

  Future<void> _dropBadKey() async {
    try {
      await ref.read(localStorageServiceProvider).prefs.remove(kAppTimezoneKey);
    } catch (_) {}
  }
}

/// The zone every displayed time is projected into: the manual zone when
/// set, otherwise the live device zone, otherwise the Jakarta fallback.
/// Never throws.
final timezoneLocationProvider = Provider<tz.Location>((ref) {
  final manual = ref.watch(timezoneProvider);
  if (manual != null) return AppTimeZone.locationOrFallback(manual);
  return AppTimeZone.locationOrFallback(ref.watch(deviceZoneProvider));
});

/// The effective IANA name behind [timezoneLocationProvider] — for labels
/// like `WIB` / `GMT-4` that need the name, not just the location.
final timezoneNameProvider = Provider<String>((ref) {
  final manual = ref.watch(timezoneProvider);
  if (manual != null && AppTimeZone.isValidZoneName(manual)) return manual;
  final device = ref.watch(deviceZoneProvider);
  if (AppTimeZone.isValidZoneName(device)) return device;
  return kFallbackZoneName;
});
