import 'package:flutter/widgets.dart';

/// Numeric text styling for counters, currency, timers, percentages and
/// coordinates.
///
/// Tabular figures give every digit the same advance width, so a ticking
/// timer or a changing total does not jitter horizontally. This is
/// deliberately separate from the per-app `AppTypography` so it can be synced
/// fleet-wide without touching app fonts.
///
/// ```dart
/// Text(
///   formattedTotal,
///   style: Theme.of(context).textTheme.headlineMedium?.tabular,
/// );
/// Text(count, style: AppNumeric.metric(Theme.of(context).textTheme.displaySmall));
/// ```
abstract final class AppNumeric {
  static const List<FontFeature> tabularFeatures = [
    FontFeature.tabularFigures(),
  ];

  /// Hero number style: bold, tight leading, tabular digits.
  /// Inherits family, size and color from [base].
  static TextStyle metric(TextStyle? base) =>
      (base ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w700,
        height: 1.15,
        fontFeatures: tabularFeatures,
      );
}

extension TabularTextStyle on TextStyle {
  /// Same style with tabular (fixed-width) digits.
  TextStyle get tabular => copyWith(fontFeatures: AppNumeric.tabularFeatures);
}
