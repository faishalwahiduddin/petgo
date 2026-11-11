// GENERATED COPY of tools/gen-store-scaffold/flutter_harness/lib/ - edit there,
// then re-run install-harness.sh.
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

  static const all = [ios, android];
}

/// Paints the app plus a fixed 9:41 status bar and home indicator on top,
/// like simctl status_bar override / Android SystemUI demo mode.
class StoreStatusBarFrame extends StatelessWidget {
  const StoreStatusBarFrame({super.key, required this.device, required this.child});

  final StoreDevice device;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
          child: IgnorePointer(child: ios ? const _IosBar() : const _AndroidBar()),
        ),
        Positioned(
          bottom: ios ? 8 : 10,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: ios ? 144 : 108,
              height: ios ? 5 : 4,
              decoration: BoxDecoration(
                color: ios ? Colors.black : const Color(0xFF202124),
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
  const _IosBar();

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
      const Positioned(
        left: 0,
        width: 150,
        top: 17,
        child: Center(
          child: Text('9:41',
              style: TextStyle(
                  fontFamily: 'CupertinoSystemText',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
        ),
      ),
      Positioned(
        right: 0,
        width: 150,
        top: 20,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const _SignalBars(),
          const SizedBox(width: 6),
          const Icon(Icons.wifi, size: 18, color: Colors.black),
          const SizedBox(width: 6),
          Container(
            width: 26,
            height: 13,
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black45),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _SignalBars extends StatelessWidget {
  const _SignalBars();

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      for (final h in [4.0, 6.5, 9.0, 11.5]) ...[
        Container(
          width: 3,
          height: h,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 1.5),
      ],
    ]);
  }
}

class _AndroidBar extends StatelessWidget {
  const _AndroidBar();

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF444746);
    return const Padding(
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
