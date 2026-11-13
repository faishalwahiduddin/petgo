// GENERATED COPY of tools/gen-store-scaffold/flutter_harness/lib/ - edit there,
// then re-run install-harness.sh.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Target capture geometry (matches the real-device raws).
class StoreDevice {
  const StoreDevice._(this.name, this.dir, this.platform, this.logical,
      this.dpr, this.topInset, this.bottomInset);

  final String name;
  final String dir; // output subfolder, same names as docs/store/screenshots
  final TargetPlatform platform;
  final Size logical;
  final double dpr;
  final double topInset;
  final double bottomInset;

  Size get physicalSize => logical * dpr;

  /// iPhone 17 class: 402x874 pt @3x = 1206x2622 px.
  static const ios = StoreDevice._(
      'ios', 'raw-ios', TargetPlatform.iOS, Size(402, 874), 3, 62, 34);

  /// Android phone slot: 1080x1920 px @2.625 = 411.43x731.43 dp.
  static const android = StoreDevice._('android', 'raw',
      TargetPlatform.android, Size(1080 / 2.625, 1920 / 2.625), 2.625, 24, 24);

  /// iPad 13" (M4/M5) slot: 1032x1376 pt @2 = 2064x2752 px. Top 24, home 20.
  static const ipad = StoreDevice._(
      'ipad', 'raw-tablet', TargetPlatform.iOS, Size(1032, 1376), 2, 24, 20);

  /// Android 7" slot: 600x960 dp @2 = 1200x1920 px.
  static const tablet7 = StoreDevice._('tablet7', 'raw-android-tablet7',
      TargetPlatform.android, Size(600, 960), 2, 24, 24);

  /// Android 10" slot: 800x1280 dp @2 = 1600x2560 px.
  static const tablet10 = StoreDevice._('tablet10', 'raw-android-tablet10',
      TargetPlatform.android, Size(800, 1280), 2, 24, 24);

  static const all = [ios, android, ipad, tablet7, tablet10];

  bool get isIpad => name == 'ipad';

  /// Font registration key: tablets share their platform's phone fonts.
  String get fontKey => platform == TargetPlatform.iOS ? 'ios' : 'android';
}

/// Paints the app plus a fixed 9:41 status bar and home indicator on top,
/// like simctl status_bar override / Android SystemUI demo mode.
/// Glyph colors for the status bar and home indicator. The render loop first
/// paints with [StoreBarStyle.hidden], samples the app background behind the
/// bars, then picks light or dark glyphs (like the OS does per app).
class StoreBarStyle {
  const StoreBarStyle(this.top, this.bottom);
  final Color? top; // null = not painted
  final Color? bottom;
  static const hidden = StoreBarStyle(null, null);
}

class StoreStatusBarFrame extends StatelessWidget {
  const StoreStatusBarFrame(
      {super.key, required this.device, required this.child, required this.style});

  final StoreDevice device;
  final Widget child;
  final ValueListenable<StoreBarStyle> style;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<StoreBarStyle>(
      valueListenable: style, builder: (context, s, _) => _frame(s));

  Widget _frame(StoreBarStyle s) {
    final ios = device.platform == TargetPlatform.iOS;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(children: [
        Positioned.fill(child: child),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: device.topInset,
          child: s.top == null
              ? const SizedBox.shrink()
              : IgnorePointer(child: device.isIpad
                  ? _IpadBar(s.top!)
                  : ios
                      ? _IosBar(s.top!)
                      : _AndroidBar(s.top!)),
        ),
        if (s.bottom != null) Positioned(
          bottom: device.isIpad ? 7 : ios ? 8 : 10,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: device.isIpad ? 315 : ios ? 144 : 108,
              height: ios ? 5 : 4,
              decoration: BoxDecoration(
                color: s.bottom,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _IosBar extends StatelessWidget {
  const _IosBar(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Dynamic Island.
      Positioned(
        top: 11,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            width: 125,
            height: 37,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(19),
            ),
          ),
        ),
      ),
      Positioned(
        left: 0,
        width: 150,
        top: 17,
        child: Center(
          child: Text('9:41',
              style: TextStyle(
                  fontFamily: 'CupertinoSystemText',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ),
      ),
      Positioned(
        right: 0,
        width: 150,
        top: 20,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _SignalBars(color),
          const SizedBox(width: 6),
          Icon(Icons.wifi, size: 18, color: color),
          const SizedBox(width: 6),
          Container(
            width: 26,
            height: 13,
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.45)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
        ]),
      ),
    ]);
  }
}

/// iPad status bar: time + date left, wifi/percent/battery right, no island.
class _IpadBar extends StatelessWidget {
  const _IpadBar(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
        fontFamily: 'CupertinoSystemText',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color);
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 0, 26, 0),
      child: Row(children: [
        // Time only: a hard-coded date would be English in every locale.
        Text('9:41', style: style),
        const Spacer(),
        Icon(Icons.wifi, size: 16, color: color),
        const SizedBox(width: 6),
        Text('100%', style: style),
        const SizedBox(width: 6),
        Container(
          width: 25,
          height: 12,
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.45)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        ),
      ]),
    );
  }
}

class _SignalBars extends StatelessWidget {
  const _SignalBars(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      for (final h in [4.0, 6.5, 9.0, 11.5]) ...[
        Container(
          width: 3,
          height: h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 1.5),
      ],
    ]);
  }
}

class _AndroidBar extends StatelessWidget {
  const _AndroidBar(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Text('9:41',
            style: TextStyle(
                fontFamily: 'Roboto', fontSize: 14, color: color)),
        Spacer(),
        Icon(Icons.wifi, size: 16, color: color),
        SizedBox(width: 4),
        Icon(Icons.battery_full, size: 16, color: color),
      ]),
    );
  }
}
