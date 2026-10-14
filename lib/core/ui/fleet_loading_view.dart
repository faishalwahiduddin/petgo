import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// Emil Kowalski style fast perceived loading indicator and state switcher.
class FleetLoadingView extends StatefulWidget {
  const FleetLoadingView({
    super.key,
    this.message,
    this.color,
    this.size = 32.0,
  });

  final String? message;
  final Color? color;
  final double size;

  @override
  State<FleetLoadingView> createState() => _FleetLoadingViewState();
}

class _FleetLoadingViewState extends State<FleetLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Emil Kowalski rule: Fast-spinning spinner improves perceived speed
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        widget.color ?? Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Semantics(
        label: widget.message ?? 'Memuat...',
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _FleetSpinnerPainter(
                      color: effectiveColor,
                      trackColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                );
              },
            ),
            if (widget.message != null) ...[
              const SizedBox(height: 16),
              Text(
                widget.message!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.black.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FleetSpinnerPainter extends CustomPainter {
  const _FleetSpinnerPainter({
    required this.color,
    required this.trackColor,
  });

  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.12;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Active arc with round cap
    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 1.3,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FleetSpinnerPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.trackColor != trackColor;
}

/// Shimmer card for skeleton loading states.
class FleetShimmerCard extends StatefulWidget {
  const FleetShimmerCard({
    super.key,
    this.width,
    this.height = 72,
    this.borderRadius = 16,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<FleetShimmerCard> createState() => _FleetShimmerCardState();
}

class _FleetShimmerCardState extends State<FleetShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);
    final highlightColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + (_controller.value * 3.0), -0.3),
              end: Alignment(0.5 + (_controller.value * 3.0), 0.3),
              colors: [baseColor, highlightColor, baseColor],
            ),
          ),
        );
      },
    );
  }
}

/// Blur-masked crossfade between loading and loaded state.
/// Emil Kowalski principle: Blur bridges the visual gap between two states.
class FleetStateSwitcher extends StatelessWidget {
  const FleetStateSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final disableMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableMotion) return child;

    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: (1.0 - animation.value) * 1.5,
              sigmaY: (1.0 - animation.value) * 1.5,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
