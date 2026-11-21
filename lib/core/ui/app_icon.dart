import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// App-specific SVG icon (personalised icon set per app).
///
/// CANONICAL — source: `tools/faishal-id-fleet/canonical/ui/app_icon.dart`.
/// Needs `flutter_svg` and SVGs under `assets/icons/<name>.svg` (declared in
/// pubspec `flutter: assets:`), bundled for offline use.
///
/// Tinting: the whole glyph is painted with [color] via [BlendMode.srcIn], so
/// it follows the theme like a Material [Icon]. Alpha is preserved, so a
/// duotone style works by giving secondary shapes `fill-opacity` /
/// `stroke-opacity` in the SVG.
///
/// Colour fallback: [color] → ambient [IconTheme] colour (what Material
/// `Icon` uses, theme-aware in light and dark) → ambient text colour.
///
/// Semantics: decorative by default (like an `Icon` without a label). Pass
/// [semanticLabel] only when the icon carries meaning on its own (e.g. an
/// icon-only button without a tooltip).
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.name, {
    super.key,
    this.size = md,
    this.color,
    this.semanticLabel,
  });

  final String name;
  final double size;
  final Color? color;
  final String? semanticLabel;

  /// Size tokens — use these instead of arbitrary values.
  static const double sm = 20;
  static const double md = 24;
  static const double lg = 28;
  static const double xl = 32;

  @override
  Widget build(BuildContext context) {
    final tint = color ??
        IconTheme.of(context).color ??
        DefaultTextStyle.of(context).style.color ??
        const Color(0xFF808080);
    final svg = SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      excludeFromSemantics: true,
    );
    if (semanticLabel == null) return ExcludeSemantics(child: svg);
    return Semantics(label: semanticLabel, image: true, child: svg);
  }
}
