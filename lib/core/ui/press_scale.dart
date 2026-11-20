import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../motion/app_spring.dart';

/// Instant press feedback (scale-down on pointer down, spring back on release).
///
/// CANONICAL FILE -- fleet superset of every per-app `press_scale.dart`.
/// Uses the app's own `AppSpring.snappy` (core/motion/app_spring.dart), so each
/// app keeps its tuned press timing (400 ms fleet default, 220 ms in a few apps).
///
/// Keep `TapTarget` for the 44pt hit area + semantics and put [PressScale]
/// inside it around the visual. Set [onTap] here only when no `TapTarget`
/// wraps it (e.g. a full-bleed card).
///
/// * [onTap] == null  -> visual only. Uses a raw `Listener`, so it never joins
///   the gesture arena and an enclosing tap handler still wins the tap.
/// * [onTap] != null  -> own tap. Feedback on pointer *down*; [onTap] fires on
///   pointer *up* only if the pointer stayed inside (drag-away cancels).
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.haptic = false,
    this.enabled = true,
    this.semanticLabel,
  });

  final Widget child;

  /// Fires on pointer up, only if the press was not cancelled.
  final VoidCallback? onTap;

  /// Pressed scale. 0.97 is the fleet default.
  final double scale;

  /// Leave false when an enclosing `TapTarget` already fires a selection
  /// haptic. Only applies when [onTap] is set.
  final bool haptic;

  /// When false the widget is a transparent pass-through (no feedback, no tap).
  final bool enabled;

  /// Optional screen-reader label for the tappable. When set it replaces the
  /// descendants' text (no double announcement). Only applies when [onTap] is
  /// set.
  final String? semanticLabel;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale>
    with SingleTickerProviderStateMixin {
  // Critically damped (bounce 0): a button that wobbles back reads as a toy.
  static SpringDescription get _spring => AppSpring.snappy;

  // Created in initState (not lazily): a disabled PressScale never reads the
  // controller, and a lazy `late final` would first be built inside dispose().
  late final AnimationController _controller;

  bool _pointerInside = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this, value: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _springTo(double target) {
    if (AppSpring.reduceMotion(context)) {
      _controller.value = target;
      return;
    }
    _controller.animateWith(
      SpringSimulation(
          _spring, _controller.value, target, _controller.velocity),
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

    final scaled = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) =>
          Transform.scale(scale: _controller.value, child: child),
      child: widget.child,
    );

    // Visual-only: a Listener stays out of the gesture arena, so an enclosing
    // TapTarget's onTap still wins. A GestureDetector here would claim the tap.
    if (widget.onTap == null) {
      return Listener(
        onPointerDown: (_) => _springTo(widget.scale),
        onPointerUp: (_) => _springTo(1.0),
        onPointerCancel: (_) => _springTo(1.0),
        child: scaled,
      );
    }

    final label = widget.semanticLabel;
    return MergeSemantics(
      child: Semantics(
        button: true,
        label: label,
        // The label already names the control; folding descendant text in
        // would announce the same words twice.
        excludeSemantics: label != null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // Down/up/cancel rather than onTap so the visual responds the instant
          // the finger lands.
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: scaled,
        ),
      ),
    );
  }
}
