import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// Apple-style spring motion.
///
/// CANONICAL FILE -- source of truth lives at
/// `docs/apple-design/canonical/lib/core/motion/app_spring.dart`.
/// Every app carries a byte-identical copy. Edit the canonical file first, then
/// re-copy; never hand-edit an app's copy.
///
/// This is deliberately *additive*: it sits alongside each app's existing
/// `AppMotion` (durations + curves) rather than replacing it, because those
/// tokens legitimately differ per app (150/250/350 in most, 180/280/400 in
/// `apps`, 150/220/320 in `almatsurat` and `doa`) and the middle duration is
/// named `base` in some apps and `medium` in others. Keep using `AppMotion` for
/// non-interactive fades; reach for `AppSpring` for anything the user can
/// touch.
///
/// Why springs at all: a fixed-duration curve cannot respond to new input. Once
/// it starts, its path is decided. A spring's target can be changed mid-flight
/// and the motion stays continuous, which is what makes an interface feel
/// grabbable rather than scripted.
abstract final class AppSpring {
  /// Flutter's [SpringDescription.withDurationAndBounce] takes exactly the two
  /// parameters Apple designs with, and the mapping is exact rather than
  /// approximate:
  ///
  ///   * `duration` == Apple's *response*. Flutter sets
  ///     `stiffness = 4*pi^2*m / T^2`, so `w0 = 2*pi/T` and `T` is the undamped
  ///     period -- the same quantity Apple calls response.
  ///   * `bounce` == `1 - dampingRatio` (for `bounce >= 0`).
  ///
  /// So Apple's published table transfers over unchanged.

  /// Default UI motion: critically damped, no overshoot. Apple 1.0 / 0.4.
  ///
  /// Start here. Overshoot on something that merely appeared reads as sloppy;
  /// it only feels right when the user's own gesture put energy into it.
  static final SpringDescription snappy = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 400),
    bounce: 0.0,
  );

  /// Momentum-carrying, slight overshoot. Apple 0.8 / 0.4.
  ///
  /// Use ONLY when a gesture carried momentum into the animation -- a flick, a
  /// throw, a drag release. Never for something that just faded in.
  static final SpringDescription bouncy = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 400),
    bounce: 0.2,
  );

  /// Sheets and drawers. Apple 0.8 / 0.3.
  static final SpringDescription sheet = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 300),
    bounce: 0.2,
  );

  /// Where a flick would come to rest, per Apple's *Designing Fluid Interfaces*
  /// projection. Snap to the target nearest this point rather than the one
  /// nearest the release point -- that is what makes a flick feel thrown
  /// instead of merely let go.
  ///
  /// [velocity] is in logical pixels per second, matching
  /// `DragEndDetails.velocity.pixelsPerSecond`. Returns a DISPLACEMENT to add
  /// to the current offset, not an absolute position.
  ///
  /// Note this is the exponential-decay form Apple actually ships, not the
  /// textbook `v^2 / (2a)`. Use 0.99 for a snappier, shorter throw.
  static double project(double velocity, {double decelerationRate = 0.998}) =>
      (velocity / 1000) * decelerationRate / (1 - decelerationRate);

  /// Whether the user asked for reduced motion.
  ///
  /// Reduced motion does not mean *no* feedback -- it means no vestibular
  /// motion. Prefer swapping a spring for an instant settle or a short
  /// cross-fade rather than dropping the feedback entirely.
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}

/// Spring helpers on [AnimationController].
extension AppSpringAnimation on AnimationController {
  /// Springs to [target] from the controller's CURRENT value and velocity.
  ///
  /// This is the whole point of using a spring: because the simulation starts
  /// at the presentation value rather than a logical "from" value, an
  /// in-flight animation can be grabbed, retargeted, and reversed with no
  /// visible jump, and the velocity carries through the retarget instead of
  /// hard-cutting to zero (which reads as hitting a brick wall).
  ///
  /// Pass [velocity] in units-per-second to hand off a gesture's release
  /// velocity so there is no seam between dragging and animating. Omit it to
  /// inherit the controller's current velocity, which is what you want when
  /// retargeting mid-flight.
  ///
  /// A spring with `bounce > 0` overshoots its target, so build the controller
  /// with [AnimationController.unbounded] when using [AppSpring.bouncy] or
  /// [AppSpring.sheet] -- a bounded controller clamps the overshoot and the
  /// bounce silently disappears.
  ///
  /// When [reduceMotion] is true the value snaps to [target] immediately.
  TickerFuture springTo(
    double target, {
    SpringDescription? spring,
    double? velocity,
    bool reduceMotion = false,
  }) {
    if (reduceMotion) {
      value = target;
      return TickerFuture.complete();
    }
    return animateWith(
      SpringSimulation(
        spring ?? AppSpring.snappy,
        value,
        target,
        velocity ?? this.velocity,
      ),
    );
  }
}

/// Progressive resistance past a boundary, as in iOS scroll views.
///
/// A hard stop reads as "frozen"; resistance that grows the further you push
/// reads as "responsive, but there is nothing more here".
///
/// [overshoot] is how far past the bound the pointer has travelled and
/// [dimension] is the size of the scrollable axis. Returns the distance the
/// content should actually move.
double rubberBand(double overshoot, double dimension, {double constant = 0.55}) {
  if (dimension <= 0) return overshoot;
  return (overshoot * dimension * constant) /
      (dimension + constant * overshoot.abs());
}
