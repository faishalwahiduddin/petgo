import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'fleet_press_scale.dart';

/// Shared consent gate for the fleet's health/family apps.
///
/// These apps block first run on a disclaimer rather than a marketing tour
/// (`fallcare`, `toiletjournal`, `mothergo`, `petgo`). The logic stays in each
/// app's `disclaimerProvider`; this widget only replaces the plain icon +
/// paragraph + button with the same "Character Welcome" language as the
/// onboarding v2 screen: ambient brand wash, mascot hero, editorial headline,
/// readable body card, and one confident CTA.
class FleetConsentGate extends StatelessWidget {
  const FleetConsentGate({
    super.key,
    required this.appName,
    required this.headline,
    required this.body,
    required this.ctaLabel,
    required this.primary,
    required this.accent,
    required this.icon,
    required this.onAccept,
    this.note,
  });

  final String appName;
  final String headline;
  final String body;
  final String? note;
  final String ctaLabel;
  final Color primary;
  final Color accent;
  final IconData icon;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark =
        (CupertinoTheme.maybeBrightnessOf(context) ?? theme.brightness) ==
        Brightness.dark;

    final ground = isDark ? const Color(0xFF0B0D11) : const Color(0xFFFBFAF7);
    final surface = isDark ? const Color(0xFF15181E) : Colors.white;
    final ink = isDark ? const Color(0xFFF4F5F7) : const Color(0xFF14161A);
    final inkSoft = isDark ? const Color(0xFFA8AEB8) : const Color(0xFF5B616B);
    final hairline = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.07);

    final brandInk = _readable(primary, isDark);
    final onPrimary = _onColor(primary);

    final scaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.90, maxScaleFactor: 1.35);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: scaler),
      child: Scaffold(
        backgroundColor: ground,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _Ambient(
              ground: ground,
              primary: primary,
              accent: accent,
              isDark: isDark,
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 720;
                  final hero = compact ? 186.0 : 248.0;
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          22,
                          compact ? 6 : 10,
                          22,
                          2,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(color: hairline),
                              ),
                              child: Image.asset(
                                'assets/icon/icon.png',
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.medium,
                                errorBuilder: (context, error, stack) =>
                                    Icon(icon, size: 18, color: brandInk),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                appName,
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
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 17,
                              color: inkSoft,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: compact ? 4 : 12),
                      _Hero(
                        asset: 'assets/mascot/hero-pose-welcome.png',
                        icon: icon,
                        primary: primary,
                        isDark: isDark,
                        size: hero,
                      ),
                      SizedBox(height: compact ? 8 : 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Semantics(
                          header: true,
                          child: Text(
                            headline,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: compact ? 24 : 28,
                              height: 1.14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.8,
                              color: ink,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 10 : 14),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, bodyBox) => SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                            // Centre the copy block in the leftover height so
                            // tall screens do not open a void above the CTA;
                            // still scrolls when the text outgrows the space.
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: bodyBox.maxHeight - 10,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: surface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: hairline),
                                    ),
                                    child: Text(
                                      body,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        height: 1.58,
                                        color: inkSoft,
                                      ),
                                    ),
                                  ),
                                  if (note != null) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.fromLTRB(
                                        14,
                                        12,
                                        14,
                                        12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primary.withValues(
                                          alpha: isDark ? 0.16 : 0.075,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.shield_rounded,
                                            size: 16,
                                            color: brandInk,
                                          ),
                                          const SizedBox(width: 9),
                                          Expanded(
                                            child: Text(
                                              note!,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                height: 1.5,
                                                fontWeight: FontWeight.w500,
                                                color: brandInk,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          4,
                          24,
                          compact ? 10 : 18,
                        ),
                        child: FleetPressScale(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            onAccept();
                          },
                          child: Container(
                            height: 56,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  primary,
                                  Color.lerp(primary, Colors.black, 0.16)!,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.30),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ctaLabel,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                    color: onPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 19,
                                  color: onPrimary,
                                ),
                              ],
                            ),
                          ),
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

class _Ambient extends StatelessWidget {
  const _Ambient({
    required this.ground,
    required this.primary,
    required this.accent,
    required this.isDark,
  });

  final Color ground;
  final Color primary;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(ground, primary, isDark ? 0.26 : 0.12)!,
                ground,
                ground,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -170,
          right: -130,
          child: _Glow(
            size: 400,
            color: primary.withValues(alpha: isDark ? 0.24 : 0.15),
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

class _Hero extends StatelessWidget {
  const _Hero({
    required this.asset,
    required this.icon,
    required this.primary,
    required this.isDark,
    required this.size,
  });

  final String asset;
  final IconData icon;
  final Color primary;
  final bool isDark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 1.02,
            height: size * 1.02,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primary.withValues(alpha: isDark ? 0.28 : 0.16),
                  primary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          Container(
            width: size * 0.78,
            height: size * 0.78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primary.withValues(alpha: isDark ? 0.18 : 0.12),
              ),
            ),
          ),
          Transform.rotate(
            angle: -0.09,
            child: Container(
              width: size * 0.66,
              height: size * 0.66,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: isDark ? 0.10 : 0.06),
                borderRadius: BorderRadius.circular(size * 0.22),
                border: Border.all(
                  color: primary.withValues(alpha: isDark ? 0.13 : 0.09),
                ),
              ),
            ),
          ),
          ExcludeSemantics(
            child: Padding(
              padding: EdgeInsets.all(size * 0.04),
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stack) =>
                    Icon(icon, size: size * 0.32, color: primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _readable(Color base, bool isDark) {
  final hsl = HSLColor.fromColor(base);
  return hsl.withLightness(isDark ? 0.74 : 0.28).toColor();
}

Color _onColor(Color background) =>
    ThemeData.estimateBrightnessForColor(background) == Brightness.dark
    ? Colors.white
    : const Color(0xFF101216);
