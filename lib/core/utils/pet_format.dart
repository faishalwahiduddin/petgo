import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import 'app_timezone.dart';

/// Display formatting for care/timeline rows. Everything is locale-aware and
/// zone-aware; nothing here may fall back to `DateTime.toString()`.
abstract final class PetFormat {
  /// Cost in rupiah (the app only tracks IDR), grouped per [localeCode]:
  /// `Rp 185.000` for id, `Rp185,000` for en.
  static String rupiah(num amount, String localeCode) => NumberFormat.currency(
    locale: AppTimeZone.intlLocale(localeCode),
    symbol: 'Rp',
    decimalDigits: 0,
  ).format(amount);

  /// Medium date (`21 Aug 2026`) of [instant] in [loc].
  static String date(DateTime instant, tz.Location loc, String localeCode) =>
      DateFormat.yMMMd(
        AppTimeZone.intlLocale(localeCode),
      ).format(AppTimeZone.toZoned(instant, loc));

  /// Date plus 24-hour time (`21 Aug 2026 · 18:52`) of [instant] in [loc].
  static String dateTime(
    DateTime instant,
    tz.Location loc,
    String localeCode,
  ) =>
      '${date(instant, loc, localeCode)} · '
      '${AppTimeZone.formatTime(instant, loc, locale: AppTimeZone.intlLocale(localeCode))}';
}
