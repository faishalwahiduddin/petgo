import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class FleetSlideItem {
  final String headline;
  final String subtext;
  final IconData? icon;
  final String? badgeText;

  const FleetSlideItem({
    required this.headline,
    required this.subtext,
    this.icon,
    this.badgeText,
  });
}

/// Icons for the four onboarding slides, in slide order.
const _slideIcons = <IconData>[
  Icons.pets_rounded,
  Icons.medical_services_rounded,
  Icons.today_rounded,
  Icons.folder_rounded,
];

/// Brand colours and icons shared by the splash and onboarding screens.
///
/// Every user-visible string comes from `AppLocalizations`; [localized] builds
/// the full contract the v2 onboarding screen needs. [current] stays minimal
/// for the splash, which only reads the colours and the fallback icon.
class FleetAppConfig {
  final String appName;
  final String tagline;
  final Color primaryColor;
  final Color darkColor;
  final Color accentColor;
  final IconData fallbackIcon;

  /// Icons for the four onboarding slides, in slide order.
  final List<IconData> slideIcons;

  final String skipLabel;
  final String nextLabel;
  final String getStartedLabel;
  final String defaultBadgeText;
  final String privacyHeadline;
  final String privacyDetail;
  final List<FleetSlideItem> slides;

  const FleetAppConfig({
    required this.primaryColor,
    required this.darkColor,
    required this.accentColor,
    required this.fallbackIcon,
    this.slideIcons = const [],
    this.appName = '',
    this.tagline = '',
    this.skipLabel = '',
    this.nextLabel = '',
    this.getStartedLabel = '',
    this.defaultBadgeText = '',
    this.privacyHeadline = '',
    this.privacyDetail = '',
    this.slides = const [],
  });

  static const FleetAppConfig current = FleetAppConfig(
    primaryColor: Color(0xFF5B7F5A),
    darkColor: Color(0xFF3E5A3D),
    accentColor: Color(0xFFD4A373),
    fallbackIcon: Icons.pets_rounded,
    slideIcons: _slideIcons,
  );

  /// Localized variant used by the onboarding router.
  factory FleetAppConfig.localized(AppLocalizations l) => FleetAppConfig(
    appName: l.appTitle,
    tagline: l.appTagline,
    primaryColor: const Color(0xFF5B7F5A),
    darkColor: const Color(0xFF3E5A3D),
    accentColor: const Color(0xFFD4A373),
    fallbackIcon: Icons.pets_rounded,
    slideIcons: _slideIcons,
    skipLabel: l.onbSkip,
    nextLabel: l.onbNext,
    getStartedLabel: l.onbGetStarted,
    defaultBadgeText: l.onbSlide1Badge,
    privacyHeadline: l.onbPrivacyHeadline,
    privacyDetail: l.onbPrivacyDetail,
    slides: [
      FleetSlideItem(
        headline: l.onbSlide1Title,
        subtext: l.onbSlide1Sub,
        icon: _slideIcons[0],
        badgeText: l.onbSlide1Badge,
      ),
      FleetSlideItem(
        headline: l.onbSlide2Title,
        subtext: l.onbSlide2Sub,
        icon: _slideIcons[1],
        badgeText: l.onbSlide2Badge,
      ),
      FleetSlideItem(
        headline: l.onbSlide3Title,
        subtext: l.onbSlide3Sub,
        icon: _slideIcons[2],
        badgeText: l.onbSlide3Badge,
      ),
      FleetSlideItem(
        headline: l.onbSlide4Title,
        subtext: l.onbSlide4Sub,
        icon: _slideIcons[3],
        badgeText: l.onbSlide4Badge,
      ),
    ],
  );
}
