// GENERATED COPY of tools/gen-store-scaffold/flutter_harness/lib/ - edit there,
// then re-run install-harness.sh.
import 'package:flutter/rendering.dart';

/// RenderFlex children that do not fit the flex's main axis, measured on the
/// visible tree only (offstage and hidden IndexedStack children skipped).
///
/// FlutterError overflow reports are unusable here: they fire on the first
/// (box-font) layout and only once per render object.
List<String> findFlexOverflows(RenderObject root) {
  final out = <String>[];
  void visit(RenderObject o) {
    if (o is RenderOffstage && o.offstage) return;
    if (o is RenderIndexedStack) {
      var i = 0;
      o.visitChildren((c) {
        if (i++ == (o.index ?? 0)) visit(c);
      });
      return;
    }
    if (o is RenderFlex && o.hasSize) {
      final horizontal = o.direction == Axis.horizontal;
      var used = 0.0;
      var n = 0;
      o.visitChildren((c) {
        final b = c as RenderBox;
        if (b.hasSize) used += horizontal ? b.size.width : b.size.height;
        n++;
      });
      if (n > 1) used += o.spacing * (n - 1);
      final avail = horizontal ? o.size.width : o.size.height;
      if (used - avail > 0.5) {
        out.add('${horizontal ? 'Row' : 'Column'} overflows by '
            '${(used - avail).toStringAsFixed(1)} px near "${_firstText(o)}" '
            '(${o.debugCreator})');
      }
    }
    o.visitChildren(visit);
  }

  visit(root);
  return out;
}

final _cjk = RegExp(r'[぀-ヿ㐀-鿿가-힯]');

/// Words broken across lines in the middle (e.g. "Mantenimient/o"): a label
/// too narrow for its longest word. CJK runs are skipped (they wrap anywhere).
List<String> findBrokenWords(RenderObject root) {
  final out = <String>[];
  void visit(RenderObject o) {
    if (o is RenderOffstage && o.offstage) return;
    if (o is RenderIndexedStack) {
      var i = 0;
      o.visitChildren((c) {
        if (i++ == (o.index ?? 0)) visit(c);
      });
      return;
    }
    if (o is RenderParagraph && o.hasSize) {
      final text = o.text.toPlainText();
      for (final m in RegExp(r'\S{2,}').allMatches(text)) {
        if (_cjk.hasMatch(m[0]!)) continue;
        final boxes = o.getBoxesForSelection(
            TextSelection(baseOffset: m.start, extentOffset: m.end));
        // Different lines = boxes that do not overlap vertically (glyphs from
        // fallback fonts shift box tops slightly on the same line).
        final wrapped = boxes.any((a) => boxes
            .any((b) => b.top >= a.bottom - 0.5 || a.top >= b.bottom - 0.5));
        if (wrapped) out.add('word "${m[0]}" wraps mid-word in "$text"');
      }
    }
    o.visitChildren(visit);
  }

  visit(root);
  return out;
}

/// All text under [o] (icons as `<U+XXXX>`), to locate the widget in source.
String _firstText(RenderObject o) {
  final parts = <String>[];
  void visit(RenderObject c) {
    if (c is RenderParagraph) {
      parts.add(c.text.toPlainText().runes.map((r) => r >= 0xE000 && r <= 0xF8FF ||
              r >= 0xF0000
          ? '<U+${r.toRadixString(16).toUpperCase()}>'
          : String.fromCharCode(r)).join());
      return;
    }
    c.visitChildren(visit);
  }

  visit(o);
  final t = parts.where((p) => p.isNotEmpty).join(' | ');
  return t.length > 80 ? '${t.substring(0, 80)}...' : t;
}
