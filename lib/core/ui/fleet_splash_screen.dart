import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fleet_app_config.dart';

/// Emil Kowalski style micro-settle splash screen.
///
/// Animates logo smoothly from scale(0.94) and opacity(0.0) with an Apple-style
/// snappy curve, then seamlessly transitions to the main app or onboarding.
class FleetSplashScreen extends StatefulWidget {
  const FleetSplashScreen({super.key});

  @override
  State<FleetSplashScreen> createState() => _FleetSplashScreenState();
}

class _FleetSplashScreenState extends State<FleetSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  Timer? _handoffTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Emil Kowalski rule: Never animate from scale(0) -- start from scale(0.94)
    _logoScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOut),
      ),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // Staggered text entrance (+60ms delay)
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.90, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startHandoff();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableMotion && _controller.value < 1.0) {
      _controller.value = 1.0;
    }
  }

  void _startHandoff() {
    final disableMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final delay = disableMotion
        ? const Duration(milliseconds: 300)
        : const Duration(milliseconds: 750);

    _handoffTimer = Timer(delay, () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final completed = prefs.getBool('onboarding_completed') ?? false;
        if (!mounted) return;
        if (completed) {
          context.go('/');
        } else {
          context.go('/onboarding');
        }
      } catch (_) {
        if (mounted) context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _handoffTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = FleetAppConfig.current;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = config.primaryColor;

    final bgColor = isDark
        ? const Color(0xFF0F1115)
        : const Color(0xFFF9FAFB);

    final titleColor = isDark
        ? Colors.white
        : const Color(0xFF111827);

    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.65)
        : const Color(0xFF4B5563);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient soft radial brand glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.32 - 140,
            left: MediaQuery.of(context).size.width * 0.5 - 140,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withValues(alpha: isDark ? 0.22 : 0.14),
                    primaryColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Central content with micro-settle animation
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SlideTransition(
                    position: _logoSlide,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E222A)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.16),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.05),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Image.asset(
                            'assets/icon/icon.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                config.fallbackIcon,
                                size: 48,
                                color: primaryColor,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Staggered title and tagline
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          Text(
                            config.appName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            config.tagline,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: subtitleColor,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom minimal loading bar
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 42,
                height: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      primaryColor.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
