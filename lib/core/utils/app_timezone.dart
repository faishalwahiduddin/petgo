/// Selected-zone wall clock (IANA, DST-aware) — the platform time contract.
///
/// Contract (`~/projects/docs/standards.md` §TZ): every stored instant is
/// UTC, every instant a human reads or types is shown in the SELECTED zone:
/// the manual IANA zone from Settings, or the device zone while Settings is
/// on "Auto". Storage, parsing and instant math stay in UTC; only display
/// projects into the zone.
///
/// This replaces the old WIB-hardcoded helper: a phone in New York must show
/// New York prayer times, not Jakarta's. WIB (`Asia/Jakarta`) survives only
/// as the fallback when nothing better is known — never as an assumption.
///
/// Rules for this module (the only file allowed to touch them):
/// - `package:timezone` is fed from the embedded `latest_all` database, so it
///   works on web too. Never `standalone.dart`/`browser.dart`.
/// - Offsets are computed PER INSTANT (`offsetFor`) — never cached — because
///   DST zones change offset twice a year.
/// - No `DateTime.now()` in here: the clock comes from `package:clock` so
///   tests can freeze it. Callers pass real time at the edge.
library;

import 'package:clock/clock.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Fallback when the device zone cannot be read and no manual zone is set.
/// A fallback, not an assumption: most users are in Indonesia, but the app
/// works anywhere.
const String kFallbackZoneName = 'Asia/Jakarta';

/// Zones offered in Settings, in picker order: (IANA name, short label).
/// The short label is a proper noun (WIB/WITA/WIT) or null — other zones
/// show their live GMT offset instead, which is DST-aware.
const List<({String iana, String? shortLabel})> kCuratedZones = [
  (iana: 'Asia/Jakarta', shortLabel: 'WIB'),
  (iana: 'Asia/Makassar', shortLabel: 'WITA'),
  (iana: 'Asia/Jayapura', shortLabel: 'WIT'),
  (iana: 'Asia/Singapore', shortLabel: null),
  (iana: 'Asia/Kuala_Lumpur', shortLabel: null),
  (iana: 'Asia/Dubai', shortLabel: null),
  (iana: 'Europe/London', shortLabel: null),
  (iana: 'America/New_York', shortLabel: null),
  (iana: 'Etc/UTC', shortLabel: null),
];

/// App-specific (non-WIB) zone helper. All state lives in the caller or in
/// [timezoneProvider]; this class is pure functions plus two statics below.
class AppTimeZone {
  AppTimeZone._();

  /// Last device zone resolved in `main()` (and on app resume while on Auto).
  /// Read by `deviceZoneProvider` as its initial state.
  static String cachedDeviceZone = kFallbackZoneName;

  /// Test seam: when set, [getDeviceZoneName] returns it without touching
  /// the platform channel. Never set outside tests.
  static String? debugDeviceZoneOverride;

  /// Loads the embedded tz database. Idempotent — safe to call again from
  /// `NotificationHelper.init`.
  static void initAppTimeZones() {
    tzdata.initializeTimeZones();
  }

  /// `true` when [name] resolves in the tz database (§VAL: validate IANA
  /// input via `tz.getLocation`, never trust a raw string).
  static bool isValidZoneName(String name) {
    try {
      tz.getLocation(name);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// [name] as a location, or the Jakarta fallback when it is null/unknown.
  /// Never throws.
  static tz.Location locationOrFallback(String? name) {
    if (name != null) {
      try {
        return tz.getLocation(name);
      } catch (_) {}
    }
    return tz.getLocation(kFallbackZoneName);
  }

  /// The device IANA zone (e.g. `America/New_York`), or the Jakarta fallback
  /// when the plugin is unavailable or returns garbage.
  static Future<String> getDeviceZoneName() async {
    final debug = debugDeviceZoneOverride;
    if (debug != null && isValidZoneName(debug)) return debug;
    try {
      // flutter_timezone ^5 returns a TimezoneInfo record, not a String.
      final name = (await FlutterTimezone.getLocalTimezone()).identifier;
      if (isValidZoneName(name)) return name;
    } catch (_) {}
    return kFallbackZoneName;
  }

  /// Now as a UTC instant. Uses `package:clock`, never `DateTime.now()`.
  static DateTime nowUtc() => clock.now().toUtc();

  /// Now as a wall clock in [loc].
  static tz.TZDateTime nowIn(tz.Location loc) => toZoned(nowUtc(), loc);

  /// [instant] as a wall clock in [loc]. The result is zone-flagged, so it
  /// is only for display and calendar fields — never store or compare it
  /// against UTC instants.
  static tz.TZDateTime toZoned(DateTime instant, tz.Location loc) =>
      tz.TZDateTime.from(instant.toUtc(), loc);

  /// Zone calendar date of [instant], `YYYY-MM-DD` (sorts correctly as text).
  static String zoneDateKey(DateTime instant, tz.Location loc) {
    final z = toZoned(instant, loc);
    return '${_four(z.year)}-${_two(z.month)}-${_two(z.day)}';
  }

  /// Today's zone calendar date, `YYYY-MM-DD`.
  static String todayKey(tz.Location loc) => zoneDateKey(nowUtc(), loc);

  /// Half-open UTC range `[startUtc, endUtc)` for one zone calendar day.
  /// [day]'s year/month/day are read as the zone calendar day; its flag is
  /// irrelevant. Query with `>= startUtc AND < endUtc`.
  ///
  /// Both edges are zone midnights projected to UTC, so the window is
  /// 23/25h across a DST transition — never a flat 24h step, which would
  /// leak into the next zone day (or leave a gap) twice a year.
  ///
  /// The real-date guard is belt and braces: a `DateTime` constructor
  /// already normalizes `2026-02-30` into March, so prefer validating raw
  /// strings with [parseUtc] before building the [day] value.
  static ({DateTime startUtc, DateTime endUtc}) dayRangeUtc(
    tz.Location loc,
    DateTime day,
  ) {
    if (!_isRealDate(day.year, day.month, day.day)) {
      throw FormatException(
        'Zone date does not exist: ${day.year}-${day.month}-${day.day}',
      );
    }
    final start = tz.TZDateTime(loc, day.year, day.month, day.day).toUtc();
    // Day overflow normalizes (day+1 on the 31st rolls the month), same as
    // the DateTime constructor.
    final end =
        tz.TZDateTime(loc, day.year, day.month, day.day + 1).toUtc();
    return (startUtc: start, endUtc: end);
  }

  /// The zone's UTC offset at [utcInstant], DST-aware. Computed per instant —
  /// never cached — because the offset changes on DST transitions.
  static Duration offsetFor(DateTime utcInstant, tz.Location loc) {
    final ms = utcInstant.toUtc().millisecondsSinceEpoch;
    return loc.timeZone(ms).offset;
  }

  /// `GMT+7`, `GMT-4`, `GMT+5:30`: the offset of [ianaName] right now,
  /// DST-aware. Falls back to Jakarta, never throws.
  static String offsetLabel(String ianaName, DateTime utcInstant) {
    final loc = locationOrFallback(ianaName);
    final offset = offsetFor(utcInstant, loc);
    final sign = offset.isNegative ? '-' : '+';
    final absMinutes = offset.inMinutes.abs();
    final hours = absMinutes ~/ 60;
    final minutes = absMinutes % 60;
    final mm = minutes == 0 ? '' : ':${_two(minutes)}';
    return 'GMT$sign$hours$mm';
  }

  /// Short display label for a zone: `WIB`/`WITA`/`WIT`, else the live GMT
  /// offset (DST-aware).
  static String zoneShortLabel(String ianaName, DateTime utcInstant) {
    for (final z in kCuratedZones) {
      if (z.iana == ianaName && z.shortLabel != null) return z.shortLabel!;
    }
    return offsetLabel(ianaName, utcInstant);
  }

  /// `HH:mm` in [loc]. Always 24-hour — never AM/PM.
  static String formatTime(
    DateTime instant,
    tz.Location loc, {
    String? locale,
  }) {
    return DateFormat('HH:mm', locale).format(toZoned(instant, loc));
  }

  /// Locale-aware calendar date in [loc] (`21/08/2026` for `id`).
  static String formatDate(
    DateTime instant,
    tz.Location loc, {
    String? locale,
  }) {
    return DateFormat.yMd(locale).format(toZoned(instant, loc));
  }

  /// `21/08/2026 13:45 WIB`-style stamp in [loc] for the [ianaName] zone.
  static String formatDateTime(
    DateTime instant,
    tz.Location loc,
    String ianaName, {
    String? locale,
  }) {
    final now = nowUtc();
    return '${formatDate(instant, loc, locale: locale)} '
        '${formatTime(instant, loc, locale: locale)} '
        '${zoneShortLabel(ianaName, now)}';
  }

  /// Localized long date of the zone day (`EEEE, dd MMMM yyyy`) — the
  /// tracker header and anywhere else a full date line is shown.
  static String formatLongDate(
    DateTime instant,
    tz.Location loc, {
    String? locale,
  }) {
    return DateFormat('EEEE, dd MMMM yyyy', locale)
        .format(toZoned(instant, loc));
  }

  /// Month-year label for calendar headers (`MMMM yyyy`).
  static String formatMonthYear(
    DateTime instant,
    tz.Location loc, {
    String? locale,
  }) {
    return DateFormat('MMMM yyyy', locale).format(toZoned(instant, loc));
  }

  /// Short day label for rows (`E, dd`).
  static String formatShortDay(
    DateTime instant,
    tz.Location loc, {
    String? locale,
  }) {
    return DateFormat('E, dd', locale).format(toZoned(instant, loc));
  }

  /// Month-year label for a (year, month) calendar pair (`MMMM yyyy`).
  /// Fields only — a calendar month is not an instant, so there is no zone
  /// to convert and nothing here may shift the value.
  static String formatCalendarMonth(int year, int month, {String? locale}) {
    return DateFormat('MMMM yyyy', locale).format(DateTime.utc(year, month));
  }

  /// Short day label for a calendar-day value (`E, dd`). Fields only, never
  /// shifted: the value is a day on a calendar, not a moment in time.
  static String formatCalendarDay(DateTime calendarDay, {String? locale}) {
    return DateFormat('E, dd', locale).format(
      DateTime.utc(calendarDay.year, calendarDay.month, calendarDay.day),
    );
  }

  /// intl locale for a UI locale code. intl ships no jv/su date data, so
  /// those fall back to `id` (same convention as before).
  static String intlLocale(String code) =>
      (code == 'jv' || code == 'su') ? 'id' : code;

  /// Parses a raw value (JSON, storage, server) into a UTC instant.
  ///
  /// Same semantics as the old `parseUtc`:
  /// - `Z` or a full `+07:00` offset — parsed as is.
  /// - Postgres-style `+00`/`-07` (two digits) or `+0700` (four digits, no
  ///   colon) — normalised first, but ONLY when directly after the time
  ///   component; otherwise `-15` in `2026-01-15` would be eaten as an offset.
  /// - Bare date `YYYY-MM-DD` — midnight of that calendar day in [zone]
  ///   (Jakarta fallback when null, for legacy stored values).
  /// - A string with a time but NO zone, or epoch milliseconds (`int`, or a
  ///   pure-digit string of >= 11 digits) — treated as already UTC, never as
  ///   device-local. Shorter pure-digit strings are rejected.
  ///
  /// The leading `YYYY-MM-DD` is always checked as a real calendar date:
  /// Dart's parser silently rolls `2026-02-30` over to March 2. Anything
  /// that does not start with a full `YYYY-MM-DD` returns `null`.
  static DateTime? parseUtc(Object? raw, {tz.Location? zone}) {
    if (raw == null) return null;
    if (raw is DateTime) return raw.toUtc();
    if (raw is int) {
      return DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true);
    }

    final text = raw.toString().trim();
    if (text.isEmpty) return null;

    final asEpoch = int.tryParse(text);
    if (asEpoch != null && !text.contains('-') && !text.contains(':')) {
      // Pure digits never fall through to DateTime.tryParse, which accepts
      // compact ISO such as "20260115" as a (local) date. >= 11 digits covers
      // every plausible epoch-ms; anything shorter is rejected, not guessed.
      if (text.length >= 11) {
        return DateTime.fromMillisecondsSinceEpoch(asEpoch, isUtc: true);
      }
      return null;
    }

    // Bare date: midnight in the selected zone, stored as UTC.
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
      final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text)!;
      final y = int.parse(m.group(1)!);
      final mo = int.parse(m.group(2)!);
      final d = int.parse(m.group(3)!);
      if (!_isRealDate(y, mo, d)) return null;
      final loc = zone ?? tz.getLocation(kFallbackZoneName);
      return tz.TZDateTime(loc, y, mo, d).toUtc();
    }

    // Everything else must start with a full, real calendar date.
    final dateHead = RegExp(r'^(\d{4})-(\d{2})-(\d{2})[T ]').firstMatch(text);
    if (dateHead == null) return null;
    final hy = int.parse(dateHead.group(1)!);
    final hmo = int.parse(dateHead.group(2)!);
    final hd = int.parse(dateHead.group(3)!);
    if (!_isRealDate(hy, hmo, hd)) return null;

    // Two- or four-digit offset without a colon, only right after HH:mm[:ss].
    var normalized = text;
    final bareOffset = RegExp(
      r'^(.*\d{2}:\d{2}(?::\d{2}(?:\.\d+)?)?)([+-]\d{2})(\d{2})?$',
    ).firstMatch(text);
    if (bareOffset != null) {
      final minutes = bareOffset.group(3) ?? '00';
      normalized = '${bareOffset.group(1)}${bareOffset.group(2)}:$minutes';
    }

    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) return null;
    if (parsed.isUtc) return parsed;

    // No zone in the string: keep the numbers and flag them UTC. Never call
    // .toUtc() here — that would shift by the DEVICE zone.
    return DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    );
  }

  /// A user-typed zone wall clock (`YYYY-MM-DDTHH:mm[:ss]`) in [loc] → ISO
  /// UTC string to store, or `null` when it is not a valid input.
  ///
  /// A value that ALREADY carries a zone (`Z`, `+HH`, `+HHMM`, `+HH:MM`)
  /// right after the time is passed through [parseUtc], not shifted again.
  static String? zoneInputToUtc(String? local, tz.Location loc) {
    if (local == null) return null;
    final trimmed = local.trim();
    if (trimmed.isEmpty) return null;

    final withOffset = RegExp(
      r'^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}(?::\d{2}(?:\.\d+)?)?'
      r'(?:Z|[+-]\d{2}(?::?\d{2})?)$',
    );
    if (withOffset.hasMatch(trimmed)) {
      return parseUtc(trimmed, zone: loc)?.toIso8601String();
    }

    final m = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})[T ](\d{2}):(\d{2})(?::(\d{2})(?:\.\d+)?)?$',
    ).firstMatch(trimmed);
    if (m == null) return null;

    final y = int.parse(m.group(1)!);
    final mo = int.parse(m.group(2)!);
    final d = int.parse(m.group(3)!);
    final h = int.parse(m.group(4)!);
    final mi = int.parse(m.group(5)!);
    final s = m.group(6) != null ? int.parse(m.group(6)!) : 0;
    if (h > 23 || mi > 59 || s > 59) return null;
    if (!_isRealDate(y, mo, d)) return null;

    return tz.TZDateTime(loc, y, mo, d, h, mi, s).toUtc().toIso8601String();
  }

  /// Inverse of [zoneInputToUtc]: instant → `YYYY-MM-DDTHH:mm` zone wall
  /// clock, for the initial value of an input field.
  static String utcToZoneInput(DateTime instant, tz.Location loc) {
    final z = toZoned(instant, loc);
    return '${_four(z.year)}-${_two(z.month)}-${_two(z.day)}'
        'T${_two(z.hour)}:${_two(z.minute)}';
  }

  /// Storage encoding: instant → UTC ISO-8601 `Z` string. Always UTC, in
  /// every zone — decode with [decodeToZone] for display.
  static String encodeForPrefs(DateTime instant) =>
      instant.toUtc().toIso8601String();

  /// Storage decoding: a UTC ISO string → wall clock in [loc] for display.
  /// Throws [FormatException] on garbage — fail loud, never guess a time.
  static tz.TZDateTime decodeToZone(String isoUtc, tz.Location loc) {
    final parsed = parseUtc(isoUtc, zone: loc);
    if (parsed == null) throw FormatException('Not a UTC instant: $isoUtc');
    return toZoned(parsed, loc);
  }

  /// Displays a raw date-only value (`YYYY-MM-DD`) as a locale date WITHOUT
  /// any zone shift — there is no time to convert. A full instant is shown
  /// as its zone date-time instead of crashing; garbage is returned as is.
  static String formatServerDate(
    String raw,
    tz.Location loc,
    String ianaName, {
    String? locale,
  }) {
    final text = raw.trim();
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
    if (m != null) {
      final y = int.parse(m.group(1)!);
      final mo = int.parse(m.group(2)!);
      final d = int.parse(m.group(3)!);
      if (!_isRealDate(y, mo, d)) return raw;
      return DateFormat.yMd(locale).format(tz.TZDateTime(loc, y, mo, d));
    }
    final parsed = parseUtc(text, zone: loc);
    return parsed == null
        ? raw
        : formatDateTime(parsed, loc, ianaName, locale: locale);
  }

  static bool _isRealDate(int y, int mo, int d) {
    final probe = DateTime.utc(y, mo, d);
    return probe.year == y && probe.month == mo && probe.day == d;
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _four(int n) => n.toString().padLeft(4, '0');
}
