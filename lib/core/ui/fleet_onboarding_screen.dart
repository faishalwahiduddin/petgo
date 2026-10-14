import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fleet_app_config.dart';
import '../theme/app_motion.dart';
import 'fleet_press_scale.dart';

/// Emil Kowalski style modular 3/4-step onboarding flow.
///
/// Features staggered entrance transitions, spring-animated expanding dot
/// indicators, tactile PressScale buttons with haptic feedback, and an
/// immediate "Skip" escape hatch.
class FleetOnboardingScreen extends StatefulWidget {
  const FleetOnboardingScreen({super.key});

  @override
  State<FleetOnboardingScreen> createState() => _FleetOnboardingScreenState();
}

class _FleetOnboardingScreenState extends State<FleetOnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
    } catch (_) {}
    if (mounted) {
      context.go('/');
    }
  }

  void _nextPage(int totalSlides) {
    if (_currentPage < totalSlides - 1) {
      HapticFeedback.selectionClick();
      final disableMotion =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      _pageController.nextPage(
        duration: disableMotion
            ? Duration.zero
            : AppMotion.resolve(context, const Duration(milliseconds: 320)),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = FleetAppConfig.current;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = config.primaryColor;
    final slides = config.slides;

    final bgColor = isDark ? const Color(0xFF0F1115) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF1B1F27) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111827);
    final textSecondary = isDark
        ? Colors.white.withValues(alpha: 0.65)
        : const Color(0xFF4B5563);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Brand Mark & Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          config.fallbackIcon,
                          size: 18,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        config.appName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  FleetPressScale(
                    onTap: _completeOnboarding,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        config.skipLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Middle Carousel: Interactive Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  final isLast = index == slides.length - 1;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 1),

                        // Glowing Hero Visual Badge
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.22),
                                blurRadius: 36,
                                offset: const Offset(0, 14),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.16),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              slide.icon ?? config.fallbackIcon,
                              size: 54,
                              color: primaryColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Slide Headline
                        Text(
                          slide.headline,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: textPrimary,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Slide Subtext
                        Text(
                          slide.subtext,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Extra pill highlight or privacy guarantee card
                        if (!isLast)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.12),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 16,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  slide.badgeText ?? config.defaultBadgeText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.shield_rounded,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        config.privacyHeadline,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        config.privacyDetail,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const Spacer(flex: 2),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area with Spring Dot Indicator & Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: _currentPage == slides.length - 1
                  // Final Slide: Full-width prominent CTA
                  ? FleetPressScale(
                      onTap: _completeOnboarding,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                config.getStartedLabel,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  // Intermediate Slides: Expanding Spring Dots & Next Pill
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Spring Dot Indicator
                        Row(
                          children: List.generate(slides.length, (index) {
                            final isActive = index == _currentPage;
                            return AnimatedContainer(
                              duration: AppMotion.resolve(
                                context,
                                const Duration(milliseconds: 240),
                              ),
                              curve: Curves.easeOutCubic,
                              margin: const EdgeInsets.only(right: 6),
                              width: isActive ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? primaryColor
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.20)
                                        : Colors.black.withValues(alpha: 0.14)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                        // Next Pill Button
                        FleetPressScale(
                          onTap: () => _nextPage(slides.length),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.28),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  config.nextLabel,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
