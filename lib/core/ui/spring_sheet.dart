import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';

import '../motion/app_spring.dart';
import '../motion/spring_draggable.dart';

/// Spring-dismissible modal sheet — Apple fluid sheet + Emil interruptibility.
///
/// CANONICAL — source: `tools/faishal-id-fleet/canonical/ui/spring_sheet.dart`.
/// Needs sibling `../motion/app_spring.dart` + `../motion/spring_draggable.dart`.
///
/// Use instead of bare [showCupertinoModalPopup] / [showModalBottomSheet] when
/// the sheet should track the finger, rubber-band, and flick-dismiss with
/// [AppSpring.sheet] velocity handoff.
///
/// ```dart
/// await showSpringSheet(
///   context: context,
///   builder: (ctx) => MySheetBody(),
/// );
/// ```
Future<T?> showSpringSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double dismissOffset = 420,
  bool barrierDismissible = true,
  ImageFilter? filter,
}) {
  return showCupertinoModalPopup<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    filter: filter,
    builder: (ctx) {
      return SpringSheetScaffold(
        dismissOffset: dismissOffset,
        child: builder(ctx),
      );
    },
  );
}

/// Wraps sheet content so a downward flick dismisses with spring physics.
class SpringSheetScaffold extends StatelessWidget {
  const SpringSheetScaffold({
    super.key,
    required this.child,
    this.dismissOffset = 420,
  });

  final Widget child;
  final double dismissOffset;

  @override
  Widget build(BuildContext context) {
    // Keep the drag even with reduce-motion on: SpringDraggable snaps instead
    // of springing then, but the swipe-to-dismiss gesture must not disappear
    // (users with animations off could not close sheets by swiping).
    return SpringDraggable(
      detents: [0, dismissOffset],
      spring: AppSpring.sheet,
      onSettled: (i) {
        if (i == 1 && context.mounted) {
          Navigator.of(context).maybePop();
        }
      },
      child: child,
    );
  }
}

/// Drag handle for sheet chrome (36×4 pill).
class SpringSheetHandle extends StatelessWidget {
  const SpringSheetHandle({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? CupertinoColors.systemGrey2.resolveFrom(context);
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
