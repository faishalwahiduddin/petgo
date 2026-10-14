import 'package:flutter/cupertino.dart';

import 'app_spring.dart';

/// One-dimensional 1:1 drag with rubber-banding, momentum projection and
/// velocity handoff into a spring.
///
/// CANONICAL FILE -- source of truth lives at
/// `docs/apple-design/canonical/lib/core/motion/spring_draggable.dart`.
///
/// There is currently no genuine gesture tracking anywhere in the suite. The
/// single drag handler (`doa`'s toast) reads `primaryVelocity` at the end of a
/// drag and then plays a canned animation -- the toast never follows the
/// finger. This widget is the difference between "swipe detected" and "the
/// thing is attached to your finger".
///
/// What it does, in Apple's terms:
///
///  * **Direct manipulation** -- content tracks the pointer 1:1 and preserves
///    the grab offset, so the element does not jump to centre itself under the
///    finger on touch-down.
///  * **Rubber-banding** -- past a [detents] endpoint, resistance grows instead
///    of stopping dead.
///  * **Momentum projection** -- on release it projects where a flick would
///    come to rest and snaps to the nearest detent to THAT point, not to the
///    release point. A small flick therefore throws the sheet.
///  * **Velocity handoff** -- the release velocity becomes the spring's initial
///    velocity, so there is no seam between dragging and animating.
///  * **Interruptibility** -- grabbing mid-flight stops the simulation at its
///    presentation value and resumes tracking from there, with no jump.
///
/// The child is translated along [axis] by the current offset. Wire
/// [onSettled] to react once it lands (dismiss a route, commit a delete).
///
/// ```dart
/// SpringDraggable(
///   axis: Axis.vertical,
///   detents: const [0, 320],            // 0 = open, 320 = dismissed
///   onSettled: (i) { if (i == 1) Navigator.pop(context); },
///   child: sheetContent,
/// )
/// ```
class SpringDraggable extends StatefulWidget {
  const SpringDraggable({
    super.key,
    required this.child,
    required this.detents,
    this.axis = Axis.vertical,
    this.initialDetent = 0,
    this.onSettled,
    this.onOffsetChanged,
    this.spring,
    this.enabled = true,
  }) : assert(detents.length > 0, 'need at least one detent');

  final Widget child;

  /// Resting offsets in logical pixels along [axis], ascending.
  final List<double> detents;

  final Axis axis;
  final int initialDetent;

  /// Fires with the detent index once motion settles.
  final ValueChanged<int>? onSettled;

  /// Fires continuously while dragging -- use it to drive a backdrop opacity
  /// or a parent scale so the whole scene responds, not just this widget.
  final ValueChanged<double>? onOffsetChanged;

  /// Defaults to [AppSpring.sheet].
  final SpringDescription? spring;

  final bool enabled;

  @override
  State<SpringDraggable> createState() => _SpringDraggableState();
}

class _SpringDraggableState extends State<SpringDraggable>
    with SingleTickerProviderStateMixin {
  // Unbounded: a spring with bounce overshoots its target, and a bounded
  // controller would clamp that away.
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
    value: widget.detents[widget.initialDetent.clamp(0, widget.detents.length - 1)],
  );

  double get _min => widget.detents.first;
  double get _max => widget.detents.last;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => widget.onOffsetChanged?.call(_controller.value));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails _) {
    // Interruption: freeze wherever it currently IS on screen. Reading the
    // presentation value (rather than the target it was heading to) is what
    // prevents the visible jump when the user grabs a moving element.
    _controller.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final delta = widget.axis == Axis.vertical
        ? details.delta.dy
        : details.delta.dx;

    var next = _controller.value + delta;

    // Past an endpoint, follow the finger less and less.
    if (next < _min) {
      final dimension = context.size?.height ?? 1;
      next = _min + rubberBand(next - _min, dimension);
    } else if (next > _max) {
      final dimension = context.size?.height ?? 1;
      next = _max + rubberBand(next - _max, dimension);
    }

    _controller.value = next;
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = widget.axis == Axis.vertical
        ? details.velocity.pixelsPerSecond.dy
        : details.velocity.pixelsPerSecond.dx;

    // Animate to where the gesture was GOING, not where it stopped.
    final projected = _controller.value + AppSpring.project(velocity);

    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < widget.detents.length; i++) {
      final d = (widget.detents[i] - projected).abs();
      if (d < bestDistance) {
        bestDistance = d;
        bestIndex = i;
      }
    }

    final target = widget.detents[bestIndex];
    final reduce = AppSpring.reduceMotion(context);

    _controller
        .springTo(
          target,
          spring: widget.spring ?? AppSpring.sheet,
          // Hand the finger's own velocity to the spring so the transition
          // from drag to animation is invisible.
          velocity: velocity,
          reduceMotion: reduce,
        )
        .whenCompleteOrCancel(() {
      if (mounted) widget.onSettled?.call(bestIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vertical = widget.axis == Axis.vertical;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: vertical && widget.enabled ? _onDragStart : null,
      onVerticalDragUpdate: vertical && widget.enabled ? _onDragUpdate : null,
      onVerticalDragEnd: vertical && widget.enabled ? _onDragEnd : null,
      onHorizontalDragStart: !vertical && widget.enabled ? _onDragStart : null,
      onHorizontalDragUpdate: !vertical && widget.enabled ? _onDragUpdate : null,
      onHorizontalDragEnd: !vertical && widget.enabled ? _onDragEnd : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: vertical
              ? Offset(0, _controller.value)
              : Offset(_controller.value, 0),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
