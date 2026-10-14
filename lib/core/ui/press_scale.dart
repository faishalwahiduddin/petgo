import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../motion/app_spring.dart';

/// Instant press feedback.
///
/// CANONICAL FILE -- source of truth lives at
/// `docs/apple-design/canonical/lib/core/ui/press_scale.dart`.
///
/// Apple's first rule of fluid interfaces is response: the moment lag appears,
/// the feeling of directness "falls off a cliff". Feedback belongs on pointer
/// *down*, not on tap-up. Every `GestureDetector(onTap: ...)` in this suite
/// currently shows nothing until the finger lifts, which reads as dead.
///
/// Wraps rather than replaces `TapTarget`: keep `TapTarget` for the 44pt hit
/// area, semantics and haptics, and put [PressScale] inside it around the
/// visual. That way no existing call site changes.
///
/// ```dart
/// TapTarget(
///   semanticLabel: l.settings,
///   onTap: _open,
///   child: const PressScale(child: Icon(CupertinoIcons.settings)),
/// )
/// ```
///
/// Set [onTap] here instead only when you want the press-and-commit behaviour
/// without a `TapTarget` around it -- e.g. a full-bleed card.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.haptic = false,
    this.enabled = true,
  });

  final Widget child;

  /// Fires on pointer *up*, and only if the pointer is still within the
  /// widget -- dragging away and lifting cancels, as it does on iOS.
  final VoidCallback? onTap;

  /// Pressed scale. 0.97 is the suite default: perceptible without wobbling.
  final double scale;

  /// Leave false when an enclosing `TapTarget` already fires
  /// `HapticFeedback.selectionClick`, so a tap does not buzz twice.
  final bool haptic;

  final bool enabled;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
    value: 1.0,
  );

  bool _pointerInside = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _springTo(double target) {
    _controller.springTo(
      target,
      // Critically damped: a button that wobbles back reads as a toy. The
      // bouncy spring is reserved for motion the user threw.
      spring: AppSpring.snappy,
      reduceMotion: AppSpring.reduceMotion(context),
    );
  }

  void _onTapDown(TapDownDetails _) {
    _pointerInside = true;
    _springTo(widget.scale);
  }

  void _onTapUp(TapUpDetails _) {
    _springTo(1.0);
    if (!_pointerInside) return;
    if (widget.haptic) HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _pointerInside = false;
    _springTo(1.0);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Down/up/cancel rather than onTap, so the visual responds the instant
      // the finger lands instead of waiting for the tap to be recognised.
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _controller.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
