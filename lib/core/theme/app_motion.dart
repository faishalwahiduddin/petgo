import 'package:flutter/widgets.dart';

abstract final class AppMotion {
  static const Duration instant = Duration(milliseconds: 50);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);

  /// Alias kept for apps that name the middle step `medium` (apps hub).
  static const Duration medium = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 350);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubic;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
  static const Curve spring = Curves.easeOutCubic;
  static const Curve springBounce = Curves.elasticOut;
  static const Curve decelerate = Curves.decelerate;

  /// Scale factor for press feedback.
  static const double pressScale = 0.97;

  /// Exit animations ~65% of enter duration.
  static Duration exitOf(Duration enterDuration) => enterDuration * 0.65;

  /// Collapse to zero when the user requested reduced motion.
  static Duration resolve(BuildContext context, Duration d) =>
      (MediaQuery.maybeOf(context)?.disableAnimations ?? false)
          ? Duration.zero
          : d;
}
