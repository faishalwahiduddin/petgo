import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_motion.dart';
import 'fleet_app_config.dart';
import 'fleet_press_scale.dart';

/// Fleet onboarding v2 — "Character Welcome".
///
/// The old screen put a Material icon inside a white rounded card. Every one of
/// the 35 apps already ships a bespoke mascot with a documented 12-pose
/// vocabulary (`assets/mascot/pose-*.png`), and none of it was used. This
/// rewrite makes the mascot the host of the first run:
///
///   * ambient brand gradient instead of a flat grey ground
///   * mascot hero on a soft halo + tilted aperture card, with swipe parallax
///   * fixed chrome (brand, skip, progress, CTA) so copy crossfades instead of
///     sliding with the page — the pager only moves the illustration
///   * segmented progress instead of dots (reads as a promise, not a metric)
///   * staggered entrance (hero → copy → chrome) in 760ms, skipped entirely
///     when `MediaQuery.disableAnimations` is set
///   * no new dependencies: the fleet has no Lottie/Rive/flutter_animate and
///     this screen keeps it that way
///
/// Copy and colours still come from [FleetAppConfig]; pose order is mapped by
/// slide index so no app needs a config change to adopt the new hero:
/// welcome → explaining → pointing → celebrating.
class FleetOnboardingScreen extends StatefulWidget {
  const FleetOnboardingScreen({
    super.key,
    required this.config,
    this.slides,
    this.onComplete,
  });

  /// Brand, copy and labels for the current app. Required: three apps resolve
  /// it from `AppLocalizations` and have no static `current`, so a global
  /// fallback here would not compile fleet-wide.
  final FleetAppConfig config;

  /// Copy override for apps whose slide list is built from ARB keys
  /// (`membersheep`, `eyego`, `workout`). Defaults to the resolved config's
  /// slides.
  final List<FleetSlideItem>? slides;

  /// Completion hook. Defaults to persisting `onboarding_completed` and going
  /// to `/`.
  final Future<void> Function()? onComplete;

  @override
  State<FleetOnboardingScreen> createState() => _FleetOnboardingScreenState();
}

class _FleetOnboardingScreenState extends State<FleetOnboardingScreen>
    with SingleTickerProviderStateMixin {
  /// Pose per slide index. Every app ships all four (normalized to
  /// `hero-*.png`, 720px subject on a 900px canvas).
  static const _poses = <String>[
    'pose-welcome',
    'pose-explaining',
    'pose-pointing',
    'pose-celebrating',
  ];

  late final PageController _controller;
  late final AnimationController _intro;
  late final Animation<double> _introHero;
  late final Animation<double> _introCopy;
  late final Animation<double> _introChrome;

  late List<FleetSlideItem> _slides;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _slides = widget.slides ?? widget.config.slides;
    if (_slides.isEmpty) {
      _slides = const [FleetSlideItem(headline: 'Selamat datang', subtext: '')];
    }

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );
    _introHero = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.00, 0.66, curve: Cubic(0.16, 1, 0.30, 1)),
    );
    _introCopy = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.18, 0.82, curve: Cubic(0.16, 1, 0.30, 1)),
    );
    _introChrome = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.30, 1.00, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
        _intro.value = 1;
      } else {
        _intro.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var i = 0; i < _slides.length; i++) {
      precacheImage(AssetImage(_heroAsset(i)), context, onError: (_, _) {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _intro.dispose();
    super.dispose();
  }

  String _heroAsset(int index) {
    final pose = _poses[math.min(index, _poses.length - 1)];
    return 'assets/mascot/hero-$pose.png';
  }

  Future<void> _complete() async {
    HapticFeedback.mediumImpact();
    final custom = widget.onComplete;
    if (custom != null) {
      await custom();
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
    } catch (_) {
      // A blocked prefs write must never trap the user on onboarding.
    }
    if (mounted) context.go('/');
  }

  void _next() {
    if (_page < _slides.length - 1) {
      HapticFeedback.selectionClick();
      final duration = AppMotion.resolve(
        context,
        const Duration(milliseconds: 380),
      );
      // `nextPage` asserts on a zero duration; reduced-motion users must jump.
      if (duration == Duration.zero) {
        _controller.jumpToPage(_page + 1);
        return;
      }
      _controller.nextPage(
        duration: duration,
        curve: const Cubic(0.23, 1, 0.32, 1),
      );
    } else {
      _complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final theme = Theme.of(context);
    // Material apps expose brightness through Theme; the 16 Cupertino apps
    // expose it through CupertinoTheme. Read both so dark mode is honoured on
    // both generations.
    final isDark =
        (CupertinoTheme.maybeBrightnessOf(context) ?? theme.brightness) ==
        Brightness.dark;

    // A near-black brand (Workout) disappears on a dark ground, so the action
    // colour falls back to the app's accent instead of rendering an invisible
    // CTA. Background glows use the same resolved colour.
    final brand = config.primaryColor;
    final glow = brand.computeLuminance() < 0.045 ? config.accentColor : brand;
    final action = isDark && brand.computeLuminance() < 0.045
        ? config.accentColor
        : brand;
    final brandInk = _readable(action, isDark);
    final onAction = _onColor(action);

    final ground = isDark ? const Color(0xFF0B0D11) : const Color(0xFFFBFAF7);
    final ink = isDark ? const Color(0xFFF4F5F7) : const Color(0xFF14161A);
    final inkSoft = isDark ? const Color(0xFFA8AEB8) : const Color(0xFF5B616B);
    final hairline = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.07);

    // Honour OS text size without letting a 2x scale shove the CTA off-screen.
    final scaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.90, maxScaleFactor: 1.35);

    final slide = _slides[_page];
    final isLast = _page == _slides.length - 1;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: scaler),
      child: Scaffold(
        backgroundColor: ground,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _Ambient(
              ground: ground,
              glow: glow,
              accent: config.accentColor,
              isDark: isDark,
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 720;
                  return Column(
                    children: [
                      FadeTransition(
                        opacity: _introChrome,
                        child: _TopBar(
                          config: config,
                          brandInk: brandInk,
                          ink: ink,
                          hairline: hairline,
                          isDark: isDark,
                          compact: compact,
                          onSkip: _complete,
                        ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _controller,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _slides.length,
                          onPageChanged: (index) {
                            if (index == _page) return;
                            setState(() => _page = index);
                          },
                          itemBuilder: (context, index) => _HeroScene(
                            controller: _controller,
                            intro: _introHero,
                            index: index,
                            asset: _heroAsset(index),
                            fallbackIcon:
                                _slides[index].icon ?? config.fallbackIcon,
                            glow: glow,
                            isDark: isDark,
                            compact: compact,
                          ),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight * 0.42,
                        ),
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: FadeTransition(
                            opacity: _introCopy,
                            child: AnimatedSwitcher(
                              duration: AppMotion.resolve(
                                context,
                                const Duration(milliseconds: 280),
                              ),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.06),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  ),
                              child: _CopyBlock(
                                key: ValueKey<int>(_page),
                                slide: slide,
                                config: config,
                                ink: ink,
                                inkSoft: inkSoft,
                                brandInk: brandInk,
                                isDark: isDark,
                                compact: compact,
                                isLast: isLast,
                              ),
                            ),
                          ),
                        ),
                      ),
                      FadeTransition(
                        opacity: _introChrome,
                        child: _BottomBar(
                          page: _page,
                          total: _slides.length,
                          action: action,
                          onAction: onAction,
                          isDark: isDark,
                          compact: compact,
                          isLast: isLast,
                          label: isLast
                              ? config.getStartedLabel
                              : config.nextLabel,
                          onTap: _next,
                          resolve: (d) => AppMotion.resolve(context, d),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background
// ─────────────────────────────────────────────────────────────────────────────

/// Vertical brand wash plus two off-screen radial glows. Static on purpose:
/// animating a gradient behind a pager is the classic Flutter jank source.
class _Ambient extends StatelessWidget {
  const _Ambient({
    required this.ground,
    required this.glow,
    required this.accent,
    required this.isDark,
  });

  final Color ground;
  final Color glow;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tint = isDark ? 0.26 : 0.12;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.lerp(ground, glow, tint)!, ground, ground],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -170,
          right: -130,
          child: _Glow(
            size: 400,
            color: glow.withValues(alpha: isDark ? 0.24 : 0.15),
          ),
        ),
        Positioned(
          bottom: -210,
          left: -160,
          child: _Glow(
            size: 460,
            color: accent.withValues(alpha: isDark ? 0.14 : 0.10),
          ),
        ),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chrome
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.config,
    required this.brandInk,
    required this.ink,
    required this.hairline,
    required this.isDark,
    required this.compact,
    required this.onSkip,
  });

  final FleetAppConfig config;
  final Color brandInk;
  final Color ink;
  final Color hairline;
  final bool isDark;
  final bool compact;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22, compact ? 6 : 10, 22, 2),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF171A20)
                  : Colors.white.withValues(alpha: 0.80),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: hairline),
            ),
            child: Image.asset(
              'assets/icon/icon.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stack) =>
                  Icon(config.fallbackIcon, size: 18, color: brandInk),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              config.appName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: ink,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FleetPressScale(
            onTap: onSkip,
            child: Container(
              padding: const EdgeInsets.fromLTRB(13, 8, 10, 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: hairline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    config.skipLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: brandInk,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 15, color: brandInk),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero
// ─────────────────────────────────────────────────────────────────────────────

/// One pager page. The illustration drifts against the swipe and fades/scales
/// with its distance from centre; the page subtree is passed as `child` so only
/// the transform wrappers rebuild while dragging.
class _HeroScene extends StatelessWidget {
  const _HeroScene({
    required this.controller,
    required this.intro,
    required this.index,
    required this.asset,
    required this.fallbackIcon,
    required this.glow,
    required this.isDark,
    required this.compact,
  });

  final PageController controller;
  final Animation<double> intro;
  final int index;
  final String asset;
  final IconData fallbackIcon;
  final Color glow;
  final bool isDark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, intro]),
      child: _HeroArt(
        asset: asset,
        fallbackIcon: fallbackIcon,
        glow: glow,
        isDark: isDark,
        compact: compact,
      ),
      builder: (context, child) {
        final attached =
            controller.hasClients && controller.position.haveDimensions;
        final page = attached
            ? (controller.page ?? index.toDouble())
            : index.toDouble();
        final delta = (page - index).clamp(-1.5, 1.5);
        final visibility = (1 - delta.abs()).clamp(0.0, 1.0);

        final scale =
            (0.90 + 0.10 * visibility) *
            (0.96 + 0.04 * Curves.easeOut.transform(intro.value));
        final dx = -delta * 46;
        final dy = delta * 22;

        // No Opacity on the animated hero: a per-frame saveLayer over a 1024px
        // PNG is the classic Android jank source. Scale + travel carry the
        // depth cue on their own.
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );
  }
}

class _HeroArt extends StatelessWidget {
  const _HeroArt({
    required this.asset,
    required this.fallbackIcon,
    required this.glow,
    required this.isDark,
    required this.compact,
  });

  final String asset;
  final IconData fallbackIcon;
  final Color glow;
  final bool isDark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // Size the stage to the space the pager actually has: a fixed 336px hero
    // left a ~120px dead band on tall phones. Scaling to the available height
    // keeps the art and the copy visually joined at every screen size.
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = math.min(
          constraints.maxHeight * 0.86,
          compact ? 300.0 : 440.0,
        );
        return Center(
          child: SizedBox(
            height: h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Soft brand halo.
                Container(
                  width: h * 1.06,
                  height: h * 1.06,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        glow.withValues(alpha: isDark ? 0.30 : 0.18),
                        glow.withValues(alpha: 0),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
                // Hairline orbit.
                Container(
                  width: h * 0.80,
                  height: h * 0.80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: glow.withValues(alpha: isDark ? 0.20 : 0.13),
                    ),
                  ),
                ),
                // Tilted aperture card gives the mascot a stage without boxing it.
                Transform.rotate(
                  angle: -0.09,
                  child: Container(
                    width: h * 0.68,
                    height: h * 0.68,
                    decoration: BoxDecoration(
                      color: glow.withValues(alpha: isDark ? 0.10 : 0.065),
                      borderRadius: BorderRadius.circular(h * 0.22),
                      border: Border.all(
                        color: glow.withValues(alpha: isDark ? 0.14 : 0.10),
                      ),
                    ),
                  ),
                ),
                // The mascot itself. Excluded from semantics: the headline carries
                // the meaning, and a decorative character should not be announced.
                ExcludeSemantics(
                  child: Padding(
                    padding: EdgeInsets.all(h * 0.045),
                    child: Image.asset(
                      asset,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (context, error, stack) =>
                          Icon(fallbackIcon, size: h * 0.34, color: glow),
                    ),
                  ),
                ),
                Positioned(
                  top: h * 0.10,
                  right: h * 0.14,
                  child: _Spark(size: 7, color: glow.withValues(alpha: 0.50)),
                ),
                Positioned(
                  bottom: h * 0.15,
                  left: h * 0.10,
                  child: _Spark(size: 4, color: glow.withValues(alpha: 0.32)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Spark extends StatelessWidget {
  const _Spark({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Copy
// ─────────────────────────────────────────────────────────────────────────────

class _CopyBlock extends StatelessWidget {
  const _CopyBlock({
    super.key,
    required this.slide,
    required this.config,
    required this.ink,
    required this.inkSoft,
    required this.brandInk,
    required this.isDark,
    required this.compact,
    required this.isLast,
  });

  final FleetSlideItem slide;
  final FleetAppConfig config;
  final Color ink;
  final Color inkSoft;
  final Color brandInk;
  final bool isDark;
  final bool compact;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final badge = (slide.badgeText ?? config.defaultBadgeText).toUpperCase();
    return Padding(
      padding: EdgeInsets.fromLTRB(28, compact ? 4 : 10, 28, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(11, 7, 13, 7),
            decoration: BoxDecoration(
              color: brandInk.withValues(alpha: isDark ? 0.14 : 0.09),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: brandInk,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    badge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.25,
                      color: brandInk,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 13 : 17),
          Semantics(
            header: true,
            child: Text(
              slide.headline,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 26 : 31,
                height: 1.12,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.9,
                color: ink,
              ),
            ),
          ),
          SizedBox(height: compact ? 8 : 11),
          Text(
            slide.subtext,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 14.5 : 15.5,
              height: 1.48,
              fontWeight: FontWeight.w400,
              color: inkSoft,
            ),
          ),
          if (isLast && !compact) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 9, 14, 9),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.035),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded, size: 15, color: brandInk),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      config.privacyHeadline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: inkSoft,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom chrome
// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.page,
    required this.total,
    required this.action,
    required this.onAction,
    required this.isDark,
    required this.compact,
    required this.isLast,
    required this.label,
    required this.onTap,
    required this.resolve,
  });

  final int page;
  final int total;
  final Color action;
  final Color onAction;
  final bool isDark;
  final bool compact;
  final bool isLast;
  final String label;
  final VoidCallback onTap;
  final Duration Function(Duration) resolve;

  @override
  Widget build(BuildContext context) {
    final track = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.10);
    final duration = resolve(const Duration(milliseconds: 320));

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        compact ? 10 : 14,
        24,
        compact ? 10 : 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Segmented progress: four equal bars, first page already lit so the
          // user knows the shape of the flow before deciding to continue.
          Row(
            children: List.generate(total, (index) {
              final done = index < page;
              final active = index == page;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == total - 1 ? 0 : 6),
                  child: AnimatedContainer(
                    duration: duration,
                    curve: const Cubic(0.23, 1, 0.32, 1),
                    height: 5,
                    decoration: BoxDecoration(
                      color: active
                          ? action
                          : done
                          ? action.withValues(alpha: 0.45)
                          : track,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: compact ? 12 : 16),
          FleetPressScale(
            onTap: onTap,
            child: Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [action, Color.lerp(action, Colors.black, 0.16)!],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: action.withValues(alpha: 0.30),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: onAction,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLast
                        ? Icons.arrow_forward_rounded
                        : Icons.chevron_right_rounded,
                    size: 19,
                    color: onAction,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Colour helpers
// ─────────────────────────────────────────────────────────────────────────────

/// [base] shifted in lightness only (hue and saturation kept) until it reads as
/// text on the page ground. Mirrors the contrast rule from v1.
Color _readable(Color base, bool isDark) {
  final hsl = HSLColor.fromColor(base);
  return hsl.withLightness(isDark ? 0.74 : 0.28).toColor();
}

/// Black or white, whichever is legible on [background].
Color _onColor(Color background) =>
    ThemeData.estimateBrightnessForColor(background) == Brightness.dark
    ? Colors.white
    : const Color(0xFF101216);
