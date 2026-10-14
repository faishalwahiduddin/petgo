import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/app_motion.dart';

/// Emil Kowalski style tactile press feedback widget.
///
/// Gives instant scale feedback (0.97) on pointer down, reversing snappily on
/// pointer up or cancel with subtle haptic feedback.
class FleetPressScale extends StatefulWidget {
  const FleetPressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool enabled;

  @override
  State<FleetPressScale> createState() => _FleetPressScaleState();
}

class _FleetPressScaleState extends State<FleetPressScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = AppMotion.resolve(
      context,
      const Duration(milliseconds: 140),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.enabled) return;
    _controller.forward();
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!widget.enabled) return;
    _controller.reverse();
    HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final disableMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableMotion) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? widget.onTap : null,
        child: widget.child,
      );
    }

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
