// GENERATED COPY of tools/gen-store-scaffold/flutter_harness/lib/ - edit there,
// then re-run install-harness.sh. Per-app code lives in app_config.dart.
//
// Device-free store screenshot renderer: pumps the real app per store locale x
// route x platform with the Flutter test renderer and writes raw PNGs at store
// pixel size. Run via tools/gen-store-scaffold/flutter_harness/render-raws.sh.
//
//   --dart-define=STORE_RAWS_OUT=<dir>        required; without it every case skips
//   --dart-define=STORE_RAWS_LOCALES=en-US,ar (subset of store locales)
//   --dart-define=STORE_RAWS_PLATFORMS=ios    (subset: ios, android)
//   --dart-define=STORE_FONTS_DIR=<dir>       fleet fonts (default ../tools/...)
//
// Writes <out>/raw-ios/<loc>/<n>.png (1206x2622), <out>/raw/<loc>/<n>.png
// (1080x1920) and appends layout defects to <out>/overflows.txt.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_config.dart';
import 'store_fonts.dart';
import 'store_overflow.dart';
import 'store_routes.g.dart';
import 'store_status_bar.dart';

const _outDir = String.fromEnvironment('STORE_RAWS_OUT');
const _onlyLocales = String.fromEnvironment('STORE_RAWS_LOCALES');
const _onlyPlatforms = String.fromEnvironment('STORE_RAWS_PLATFORMS');

final _defects = <String>[];

void main() {
  setUpAll(storeSetUpAll);

  tearDownAll(() {
    if (_outDir.isEmpty) return;
    final f = File('$_outDir/overflows.txt')..createSync(recursive: true);
    if (_defects.isNotEmpty) {
      f.writeAsStringSync('${_defects.join('\n')}\n', mode: FileMode.append);
    }
  });

  for (final device in StoreDevice.all) {
    if (_onlyPlatforms.isNotEmpty &&
        !_onlyPlatforms.split(',').contains(device.name)) {
      continue;
    }
    for (final entry in kStoreLocales.entries) {
      if (_onlyLocales.isNotEmpty &&
          !_onlyLocales.split(',').contains(entry.key)) {
        continue;
      }
      for (var i = 0; i < kStoreRoutes.length; i++) {
        final slide = i + 1;
        final label = '${device.name}/${entry.key}/$slide ${kStoreRoutes[i]}';
        testWidgets(label, (tester) async {
          // flutter_test paints elevation as a hard black outline by default.
          debugDisableShadows = false;
          try {
            await _renderOne(tester, device, entry.value, slide,
                '$_outDir/${device.dir}/${entry.key}/$slide.png', label);
          } finally {
            // Must be unset before the binding checks invariants.
            debugDefaultTargetPlatformOverride = null;
            debugDisableShadows = true;
          }
        },
            skip: _outDir.isEmpty,
            timeout: const Timeout(Duration(seconds: 90)));
      }
    }
  }
}

Future<void> _renderOne(WidgetTester tester, StoreDevice device, String lang,
    int slide, String outPath, String label) async {
  await tester.runAsync(loadStoreFonts);
  final text = StoreTextStyle(device, lang);

  final inset = FakeViewPadding(
      top: device.topInset * device.dpr, bottom: device.bottomInset * device.dpr);
  tester.view
    ..physicalSize = device.physicalSize
    ..devicePixelRatio = device.dpr
    ..padding = inset
    ..viewPadding = inset;
  tester.platformDispatcher.localeTestValue = ui.Locale(lang);
  debugDefaultTargetPlatformOverride = device.platform;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearLocaleTestValue();
  });

  // Overflow reports from frames laid out before the font patch are noise
  // (box glyphs); defects are measured on the final layout instead.
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (!details.exceptionAsString().contains('overflowed')) {
      previousOnError?.call(details);
    }
  };
  addTearDown(() => FlutterError.onError = previousOnError);

  final key = GlobalKey();
  final app = await tester.runAsync(() => storeBuildApp(lang));
  await tester.pumpWidget(RepaintBoundary(
    key: key,
    child: StoreStatusBarFrame(device: device, child: app!),
  ));
  await tester.pump(kStoreSplash);
  await storeGo(tester, kStoreRoutes[slide - 1]);
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  final action = kStoreActions.length >= slide ? kStoreActions[slide - 1] : '';
  await storeAfterNavigate(tester, slide, action);

  // Decode asset images for real (fake-async never finishes the decode).
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  final root = key.currentContext!.findRenderObject()!;
  for (var i = 0; i < 10 && text.patch(root) > 0; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pump(const Duration(milliseconds: 100));

  for (final d in [...findFlexOverflows(root), ...findBrokenWords(root)]) {
    _defects.add('$label: $d');
  }

  final boundary = root as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: device.dpr);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  File(outPath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!);

  // Leave the tree before teardown so timers/animations are disposed.
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}
