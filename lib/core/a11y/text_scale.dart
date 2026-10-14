import 'package:flutter/widgets.dart';

/// Dynamic Type support.
///
/// CANONICAL FILE -- source of truth lives at
/// `docs/apple-design/canonical/lib/core/a11y/text_scale.dart`.
///
/// Respecting the user's text-size setting is not optional on Apple platforms;
/// it is one of the most-used accessibility features on iOS. No app in this
/// suite currently reads it, and `dzikir` actively destroys it: `app.dart`
/// wraps the tree in
///
/// ```dart
/// MediaQuery(data: ...copyWith(textScaler: TextScaler.linear(fontSize)))
/// ```
///
/// where `fontSize` comes from a provider hardcoded to `1.0`. That REPLACES the
/// inherited scaler, so the OS setting is discarded app-wide.
///
/// The fix is to *compose* with the inherited scaler instead of replacing it,
/// and to clamp only the extreme end so layouts do not shatter.
/// [MediaQuery.withClampedTextScaling] does exactly this -- it narrows whatever
/// the platform reports rather than substituting a value.
///
/// Wrap the app once, in `CupertinoApp.builder`:
///
/// ```dart
/// CupertinoApp.router(
///   builder: (context, child) => AppTextScale(child: child!),
///   ...
/// )
/// ```
///
/// Then walk every screen at maximum text size. Fixed-height containers are
/// where this breaks -- e.g. `height: 340` on `workout`'s rest-timer sheet and
/// `height: 260` on `eyego`'s picker sheets will clip. Prefer intrinsic height.
class AppTextScale extends StatelessWidget {
  const AppTextScale({
    super.key,
    required this.child,
    this.minScaleFactor = 1.0,
    this.maxScaleFactor = 1.6,
  });

  final Widget child;

  /// Never render text smaller than designed.
  final double minScaleFactor;

  /// 1.6 keeps the largest standard Dynamic Type sizes usable while stopping
  /// short of the accessibility sizes, which need bespoke layouts. Raise it
  /// only once the screens have been checked at that size.
  final double maxScaleFactor;

  @override
  Widget build(BuildContext context) => MediaQuery.withClampedTextScaling(
        minScaleFactor: minScaleFactor,
        maxScaleFactor: maxScaleFactor,
        child: child,
      );
}

/// Per-widget escape hatch for text that genuinely must not grow -- a fixed
/// numeric readout inside a fixed-size ring, for instance.
///
/// Use sparingly and never on body copy: opting out of Dynamic Type is exactly
/// what makes an app unusable for someone who needs larger text. If a whole
/// screen needs this, the layout is the problem.
class NoTextScale extends StatelessWidget {
  const NoTextScale({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(child: child);
}

/// Divides a grid's [childAspectRatio] by the active text scale so tiles grow
/// taller as Dynamic Type grows.
///
/// A fixed aspect ratio sets tile height from tile width, which has nothing to
/// do with how tall the label inside actually is. At large text sizes the label
/// outgrows the box and Flutter clips it — the category grid and the
/// achievement grid both overflowed this way at 1.6x. Slightly airier tiles are
/// the correct trade: iOS grows rows for larger text rather than truncating.
double scaledAspectRatio(BuildContext context, double base,
    {double maxScale = 1.6}) {
  final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, maxScale);
  return base / scale;
}
