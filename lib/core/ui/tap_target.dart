import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Accessible tap wrapper: guarantees a >=44pt hit area, adds Semantics
/// (button + label), and fires selection haptics. Use for ALL icon taps
/// that were bare GestureDetectors.
class TapTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double minSize;
  final bool haptic;
  final HitTestBehavior behavior;

  const TapTarget({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.minSize = 44,
    this.haptic = true,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: semanticLabel,
      child: GestureDetector(
        behavior: behavior,
        onTap: onTap == null
            ? null
            : () {
                if (haptic) HapticFeedback.selectionClick();
                onTap!();
              },
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
          child: Center(widthFactor: 1, heightFactor: 1, child: child),
        ),
      ),
    );
  }
}

/// Full-width tappable row wrapper: keeps the child's own layout/height but
/// adds Semantics, haptics, and an opaque hit area. Use for list/settings rows
/// that were bare GestureDetectors and already exceed 44pt vertically.
class TappableRow extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? semanticValue;
  final bool haptic;

  const TappableRow({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.semanticValue,
    this.haptic = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: semanticLabel,
      value: semanticValue,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null
            ? null
            : () {
                if (haptic) HapticFeedback.selectionClick();
                onTap!();
              },
        child: child,
      ),
    );
  }
}
