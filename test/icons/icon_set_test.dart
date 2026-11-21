import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petgo/core/ui/app_icon.dart';

import '../support/real_fonts.dart';

/// Every `AppIcon('name')` literal used in lib/, plus nav `_active` variants.
Set<String> _iconNamesUsedInLib() {
  final names = <String>{};
  final literal = RegExp(r"""AppIcon\(\s*'([a-z0-9_]+)'""");
  final ternary = RegExp(r"""AppIcon\(\s*\w+\s*\?\s*'([a-z0-9_]+)'\s*:\s*'([a-z0-9_]+)'""");
  final svgArg = RegExp(r"""svg:\s*'([a-z0-9_]+)'""");
  for (final f in Directory('lib').listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.dart')) continue;
    final src = f.readAsStringSync();
    for (final m in literal.allMatches(src)) {
      names.add(m.group(1)!);
    }
    for (final m in ternary.allMatches(src)) {
      names
        ..add(m.group(1)!)
        ..add(m.group(2)!);
    }
    for (final m in svgArg.allMatches(src)) {
      names.add(m.group(1)!);
    }
  }
  return names;
}

List<String> _allIconFiles() {
  final files = Directory('assets/icons')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.svg'))
      .map((f) => f.uri.pathSegments.last.replaceAll('.svg', ''))
      .toList()
    ..sort();
  return files;
}

void main() {
  group('icon set', () {
    test('every icon used in lib/ exists in assets/icons', () {
      final used = _iconNamesUsedInLib();
      expect(used, isNotEmpty);
      for (final name in used) {
        expect(File('assets/icons/$name.svg').existsSync(), isTrue,
            reason: 'missing assets/icons/$name.svg');
      }
      // Nav uses a pair for every tab.
      for (final tab in ['pets', 'care', 'daily', 'docs', 'settings']) {
        expect(used, containsAll(['nav_$tab', 'nav_${tab}_active']));
      }
    });

    test('every svg follows the spec and parses', () async {
      final names = _allIconFiles();
      expect(names, isNotEmpty);
      for (final name in names) {
        final src = File('assets/icons/$name.svg').readAsStringSync();
        expect(RegExp(r'^[a-z0-9_]+$').hasMatch(name), isTrue, reason: name);
        expect(src, contains('viewBox="0 0 24 24"'), reason: name);
        final root = RegExp(r'<svg[^>]*>').firstMatch(src)!.group(0)!;
        expect(root, isNot(contains('width=')), reason: name);
        expect(root, isNot(contains('height=')), reason: name);
        expect(root, isNot(contains('transform')), reason: name);
        for (final banned in ['<style', '<text', '<image']) {
          expect(src, isNot(contains(banned)), reason: '$name has $banned');
        }
        final info = await vg.loadPicture(SvgStringLoader(src), null);
        expect(info.size, const Size(24, 24), reason: name);
        info.picture.dispose();
      }
    });
  });

  testWidgets('icon preview sheet (light + dark)', (tester) async {
    await loadRealRoboto();
    final names = _allIconFiles();
    const cellW = 170.0;
    const perRow = 6;
    final rows = (names.length / perRow).ceil();
    final panelH = rows * 100.0 + 24;
    tester.view.physicalSize = Size(cellW * perRow + 24, panelH * 2);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Widget panel(Color bg, Color fg) => Container(
          color: bg,
          height: panelH,
          padding: const EdgeInsets.all(12),
          child: Wrap(
            children: [
              for (final n in names)
                SizedBox(
                  width: cellW,
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (final s in [24.0, 32.0, 48.0])
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: AppIcon(n, size: s, color: fg),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(n, style: TextStyle(fontSize: 11, color: fg)),
                    ],
                  ),
                ),
            ],
          ),
        );

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Roboto'),
        home: Material(
          child: Column(
            children: [
              panel(const Color(0xFFF8FAFC), const Color(0xFF0F172A)),
              panel(const Color(0xFF0F172A), const Color(0xFFF8FAFC)),
            ],
          ),
        ),
      ),
    );
    // flutter_svg decodes asynchronously; let real I/O finish, then repaint.
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
    expect(tester.takeException(), isNull);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/icon_sheet.png'));
  });
}
