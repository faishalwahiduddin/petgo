import 'package:flutter/widgets.dart';

import '../motion/app_spring.dart';
import '../theme/app_motion.dart';

/// Cascading list entrance — Emil Kowalski stagger (30–80ms steps).
///
/// CANONICAL — copy via `tools/sync_apple_primitives.py`.
///
/// Decorative only: never blocks interaction. Reduced motion → instant show.
///
/// ```dart
/// ListView.builder(
///   itemBuilder: (context, i) => StaggerFadeIn(
///     index: i,
///     child: MyCard(...),
///   ),
/// )
/// ```
class StaggerFadeIn extends StatefulWidget {
  const StaggerFadeIn({
    super.key,
    required this.index,
    required this.child,
    this.step = const Duration(milliseconds: 45),
    this.duration = const Duration(milliseconds: 280),
    this.maxIndex = 12,
    this.slide = 10,
  });

  /// Zero-based position in the list. Delay = min(index, maxIndex) * step.
  final int index;
  final Widget child;

  /// Gap between successive items (keep 30–80ms).
  final Duration step;

  /// Per-item fade/slide duration (UI, stay under 300ms).
  final Duration duration;

  /// Cap stagger so long lists do not feel slow.
  final int maxIndex;

  /// Initial translateY in logical pixels (opacity + small slide, never scale(0)).
  final double slide;

  @override
  State<StaggerFadeIn> createState() => _StaggerFadeInState();
}

class _StaggerFadeInState extends State<StaggerFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _offset = Tween<Offset>(
      begin: Offset(0, widget.slide),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (AppSpring.reduceMotion(context)) {
        _controller.value = 1;
        return;
      }
      final i = widget.index.clamp(0, widget.maxIndex);
      Future<void>.delayed(widget.step * i, () {
        if (mounted) _controller.forward();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: _offset.value,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Convenience: wrap children of a [Column] / static list with staggered delays.
class StaggerColumn extends StatelessWidget {
  const StaggerColumn({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.step = const Duration(milliseconds: 45),
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final Duration step;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (var i = 0; i < children.length; i++)
          StaggerFadeIn(index: i, step: step, child: children[i]),
      ],
    );
  }
}

/// Duration helper re-export for call sites that only import this file.
Duration staggerResolve(BuildContext context, Duration d) =>
    AppMotion.resolve(context, d);
