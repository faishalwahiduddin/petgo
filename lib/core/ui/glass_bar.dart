import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';

/// Translucent chrome -- the material layer iOS uses to float navigation above
/// content.
///
/// CANONICAL FILE -- source of truth lives at
/// `docs/apple-design/canonical/lib/core/ui/glass_bar.dart`.
///
/// Every hand-rolled bottom nav in this suite is an opaque `DecoratedBox` in a
/// `Column`, which consumes a fixed strip of the screen. Content never passes
/// under it, so the defining iOS depth cue is absent. Several also carry a
/// coloured glow shadow (`activeColor.withValues(alpha: 0.14)`); that is not an
/// Apple treatment and should be dropped when adopting this widget.
///
/// IMPORTANT -- adopting this is a layout change, not a drop-in swap. The bar
/// must OVERLAY the content, so the caller moves from:
///
/// ```dart
/// Column(children: [Expanded(child: content), MyBottomNav()])
/// ```
///
/// to:
///
/// ```dart
/// Stack(children: [
///   content,                                    // scrolls the full height
///   Positioned(left: 0, right: 0, bottom: 0, child: GlassBar(child: MyBottomNav())),
/// ])
/// ```
///
/// and the scrollable adds bottom padding equal to the bar's height so the last
/// item is not trapped underneath it.
class GlassBar extends StatelessWidget {
  const GlassBar({
    super.key,
    required this.child,
    this.blurSigma = 20,
    this.opacity = 0.72,
    this.color,
    this.borderSide = BarBorderSide.top,
    this.borderRadius,
  });

  final Widget child;

  /// Blur radius. Bigger surfaces should read as thicker: 20 suits a tab bar,
  /// 24-30 a large sheet, 12-16 a small floating chip.
  final double blurSigma;

  /// Fill opacity over the blur. Below ~0.6 text legibility starts to suffer
  /// over busy content; above ~0.85 the material stops reading as translucent.
  final double opacity;

  /// Defaults to the theme's bar colour, which already adapts light/dark.
  final Color? color;

  final BarBorderSide borderSide;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final media = MediaQuery.maybeOf(context);

    // Flutter does not surface iOS "Reduce Transparency", so highContrast is
    // the closest available signal. When it is on, go solid and drop the blur
    // rather than serving a low-contrast material.
    final solid = media?.highContrast ?? false;

    final base = color ?? theme.barBackgroundColor;
    final fill = solid ? base.withValues(alpha: 1.0) : base.withValues(alpha: opacity);

    final hairline = CupertinoColors.separator.resolveFrom(context);
    final border = switch (borderSide) {
      BarBorderSide.top => Border(top: BorderSide(color: hairline, width: 0.0)),
      BarBorderSide.bottom => Border(bottom: BorderSide(color: hairline, width: 0.0)),
      BarBorderSide.none => null,
    };

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        border: border,
        borderRadius: borderRadius,
      ),
      child: child,
    );

    if (!solid) {
      // The clip is required: an unclipped BackdropFilter samples the entire
      // layer tree and blurs far more than this bar.
      surface = ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: surface,
        ),
      );
    }

    return surface;
  }
}

enum BarBorderSide { top, bottom, none }
