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

  /// Optional selected-state semantics (null = not announced).
  final bool? selected;

  const TapTarget({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.minSize = 44,
    this.haptic = true,
    this.behavior = HitTestBehavior.opaque,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      selected: selected,
      label: semanticLabel,
      child: GestureDetector(
        behavior: behavior,
        onTap:
            onTap == null
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
  final bool? selected;

  /// Optional minimum row height. Null (default) = child keeps its own height.
  final double? minHeight;
  final HitTestBehavior behavior;

  const TappableRow({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.semanticValue,
    this.haptic = true,
    this.selected,
    this.minHeight,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  Widget build(BuildContext context) {
    final h = minHeight;
    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      selected: selected,
      label: semanticLabel,
      value: semanticValue,
      child: GestureDetector(
        behavior: behavior,
        onTap:
            onTap == null
                ? null
                : () {
                  if (haptic) HapticFeedback.selectionClick();
                  onTap!();
                },
        child:
            h == null
                ? child
                : ConstrainedBox(
                  constraints: BoxConstraints(minHeight: h),
                  child: child,
                ),
      ),
    );
  }
}
