// CANONICAL test helper: tools/faishal-id-fleet/canonical/test_support/. Copy to test/support/.
// lowContrastTexts(tester, base: <page background>) -> texts below 4.5:1 (3:1 for large) vs their real ancestor background.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG contrast ratio between two opaque colours.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Backgrounds actually painted behind [node]: colored boxes/materials up the
/// render tree are alpha-composited until an opaque one (else [base]).
/// A gradient counts as opaque and yields one background per color stop.
List<Color> _backgroundsOf(RenderObject node, Color base) {
  final layers = <Color>[];
  var bases = <Color>[base];
  for (RenderObject? p = node.parent; p != null; p = p.parent) {
    Color? c;
    if (p is RenderDecoratedBox &&
        p.position == DecorationPosition.background) {
      final d = p.decoration;
      final gradient = d is BoxDecoration
          ? d.gradient
          : d is ShapeDecoration
          ? d.gradient
          : null;
      if (gradient != null) {
        bases = gradient.colors.where((g) => g.a > 0).toList();
        break;
      }
      c = d is BoxDecoration
          ? d.color
          : d is ShapeDecoration
          ? d.color
          : null;
    } else if (p.runtimeType.toString() == '_RenderColoredBox') {
      // ColoredBox / Container(color:) paint through a private render object.
      c = (p as dynamic).color as Color;
    } else if (p is RenderPhysicalModel) {
      c = p.color;
    } else if (p is RenderPhysicalShape) {
      c = p.color;
    }
    if (c != null && c.a > 0) {
      if (c.a >= 0.999) {
        bases = [c];
        break;
      }
      layers.add(c);
    }
  }
  return [
    for (final b in bases)
      layers.reversed.fold<Color>(b, (bg, c) => Color.alphaBlend(c, bg)),
  ];
}

bool _isIconGlyph(String t) =>
    t.runes.every((r) => (r >= 0xE000 && r <= 0xF8FF) || r >= 0xF0000);

/// Emoji render in their own colours, so the text colour does not apply.
bool _isEmoji(String t) => RegExp(
  r'^[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{200D}\u{FE0F}\s]+$',
  unicode: true,
).hasMatch(t);

/// WCAG "large text": >= 24 px, or >= 18.66 px bold.
bool _isLarge(TextStyle? s) {
  final size = s?.fontSize ?? 14;
  final bold =
      (s?.fontWeight ?? FontWeight.normal).value >= FontWeight.w700.value;
  return size >= 24 || (bold && size >= 18.66);
}

/// Visible, non-icon text whose contrast against its painted background is
/// below WCAG AA: 4.5:1, or 3:1 for large text.
List<String> lowContrastTexts(WidgetTester tester, {required Color base}) {
  final out = <String>[];
  for (final e in find.byType(RichText).evaluate()) {
    final r = e.renderObject;
    if (r is! RenderParagraph || !r.attached || !r.hasSize || r.size.isEmpty) {
      continue;
    }
    final text = r.text.toPlainText().trim();
    if (text.isEmpty || _isIconGlyph(text) || _isEmoji(text)) continue;
    final style = r.text.style;
    final fg = style?.color;
    if (fg == null || fg.a < 0.5) continue; // decorative / disabled text
    final min = _isLarge(style) ? 3.0 : 4.5;
    var worst = double.infinity;
    final chip = e.findAncestorWidgetOfExactType<RawChip>();
    // RawChip paints its own fill (invisible to the render-tree walk).
    final chipBg = chip == null
        ? null
        : (chip.selected == true ? chip.selectedColor : chip.backgroundColor);
    final ink = e.findAncestorWidgetOfExactType<Ink>();
    final inkDecoration = ink?.decoration;
    final inkBg = inkDecoration is BoxDecoration
        ? inkDecoration.color
        : inkDecoration is ShapeDecoration
        ? inkDecoration.color
        : null;
    final backgrounds = _backgroundsOf(r, base);
    // InputDecorator paints its own fill (invisible to the render-tree walk).
    final input = e.findAncestorWidgetOfExactType<InputDecorator>();
    final inputBg = input == null || input.decoration.filled == false
        ? null
        : input.decoration.fillColor ??
              (input.decoration.filled == true
                  ? Theme.of(e).inputDecorationTheme.fillColor
                  : null);
    final fill =
        chipBg ??
        inkBg ??
        inputBg; // Ink paints into the Material, invisible to the render-tree walk
    for (final bg
        in fill == null
            ? backgrounds
            : [for (final b in backgrounds) Color.alphaBlend(fill, b)]) {
      final c = contrastRatio(Color.alphaBlend(fg, bg), bg);
      if (c < worst) worst = c;
    }
    if (worst < min) {
      out.add(
        '"${text.length > 40 ? text.substring(0, 40) : text}" ${worst.toStringAsFixed(2)} < $min',
      );
    }
  }
  return out;
}
