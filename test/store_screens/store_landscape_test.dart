// GENERATED COPY of tools/gen-store-scaffold/flutter_harness/lib/ - edit there,
// then re-run install-harness.sh.
//
// Landscape layout regression suite: mounts every store route at real landscape
// geometries (phone, 7", 10", iPad) with the OS safe-area insets a device
// applies when rotated, then fails on any RenderFlex overflow or mid-word wrap.
//
// This is the authoritative "landscape is not broken" gate. It renders the same
// seeded app the store harness uses, so it needs no device and no golden.
import 'dart:ui' as ui;

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_config.dart';
import 'store_fonts.dart';
import 'store_overflow.dart';
import 'store_routes.g.dart';

/// One landscape target: logical size, density, platform and the insets the OS
/// hands the app once rotated.
class _Landscape {
  const _Landscape(
    this.name,
    this.logical,
    this.dpr,
    this.platform, {
    this.top = 0,
    this.bottom = 0,
    this.left = 0,
    this.right = 0,
  });

  final String name;
  final Size logical;
  final double dpr;
  final TargetPlatform platform;

  /// Logical safe-area insets (converted to physical before use).
  final double top;
  final double bottom;
  final double left;
  final double right;

  Size get physical => logical * dpr;

  FakeViewPadding get insets => FakeViewPadding(
        top: top * dpr,
        bottom: bottom * dpr,
        left: left * dpr,
        right: right * dpr,
      );
}

/// Rotated versions of the fleet's store devices, plus the notch insets the OS
/// reserves on the long edges (iPhone landscape: 44 pt each side, 21 bottom).
const _landscapes = <_Landscape>[
  _Landscape('iphone-874x402', Size(874, 402), 3, TargetPlatform.iOS,
      left: 44, right: 44, bottom: 21),
  _Landscape('android-731x411', Size(1920 / 2.625, 1080 / 2.625), 2.625,
      TargetPlatform.android, top: 24),
  _Landscape('tablet7-960x600', Size(960, 600), 2, TargetPlatform.android,
      top: 24, bottom: 24),
  _Landscape('tablet10-1280x800', Size(1280, 800), 2, TargetPlatform.android,
      top: 24, bottom: 24),
  _Landscape('ipad-1376x1032', Size(1376, 1032), 2, TargetPlatform.iOS,
      top: 24, bottom: 20),
];

void main() {
  setUpAll(storeSetUpAll);

  for (final land in _landscapes) {
    for (var i = 0; i < kStoreRoutes.length; i++) {
      final route = kStoreRoutes[i];
      final action = kStoreActions.length > i ? kStoreActions[i] : '';
      testWidgets('${land.name} $route', (tester) async {
        await tester.runAsync(loadStoreFonts);
        rootBundle.clear();

        final insets = land.insets;
        tester.view
          ..physicalSize = land.physical
          ..devicePixelRatio = land.dpr
          ..padding = insets
          ..viewPadding = insets;
        tester.platformDispatcher.localeTestValue = const ui.Locale('id');
        debugDefaultTargetPlatformOverride = land.platform;
        // Reset inside the test body: the binding asserts the foundation debug
        // vars are unset before tearDown runs.
        try {
          final app = await tester.runAsync(
              () => withClock(Clock.fixed(DateTime.now()), () async {
                    return storeBuildApp('id');
                  }));
          await tester.pumpWidget(app!);
          await tester.pump(kStoreSplash);
          await storeGo(tester, route);
          for (var f = 0; f < 20; f++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          await storeAfterNavigate(tester, i + 1, action);

          // Decode images for real; fake-async never finishes the decode.
          await tester.runAsync(() async {
            for (final e in find.byType(Image).evaluate()) {
              await precacheImage((e.widget as Image).image, e);
            }
          });
          await tester.pump(const Duration(milliseconds: 100));

          final root = tester.binding.rootElement!.renderObject!;
          final defects = <String>[
            ...findFlexOverflows(root),
            ...findBrokenWords(root),
          ];
          // Leave the tree before the binding checks invariants, so timers and
          // animations owned by widgets are disposed (same as the store renderer).
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 1));
          expect(
            defects,
            isEmpty,
            reason: 'landscape ${land.name} @ "$route" '
                '(${land.logical.width.toInt()}x${land.logical.height.toInt()} dp) '
                'has layout defects:\n  ${defects.join('\n  ')}',
          );
        } finally {
          debugDefaultTargetPlatformOverride = null;
          tester.view.reset();
          tester.platformDispatcher.clearLocaleTestValue();
          rootBundle.clear();
        }
      });
    }
  }
}
