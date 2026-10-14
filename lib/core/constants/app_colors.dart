import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF5B7F5A);
  static const Color primaryLight = Color(0xFF7A9E78);
  static const Color primaryDark = Color(0xFF3E5A3D);

  static const Color secondary = Color(0xFF2A332B);
  static const Color accent = Color(0xFFD4A373);
  static const Color accentLight = Color(0xFFE4C3A0);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  static const Color bgDark = Color(0xFF121816);
  static const Color bgSurface = Color(0xFF1E2420);
  static const Color bgCard = Color(0xFF242C26);
  static const Color border = Color(0xFF334038);
  static const Color textDarkPrimary = Color(0xFFF5F7F5);
  static const Color textDarkSecondary = Color(0xFFA8B5AA);
  static const Color textDarkMuted = Color(0xFF6F7C72);

  static const Color bgLight = Color(0xFFF7F4EF);
  static const Color bgLightSurface = Color(0xFFFFFFFF);
  static const Color bgLightElevated = Color(0xFFEEE9E1);
  static const Color borderLight = Color(0xFFE2DBD0);
  static const Color textLightPrimary = Color(0xFF1F2A22);
  static const Color textLightSecondary = Color(0xFF5C6B5E);
  static const Color textLightMuted = Color(0xFF8A968C);

  static const Color ink = textLightPrimary;
  static const Color inkSoft = textLightSecondary;
}

extension AppThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get textPrimary =>
      isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
  Color get textSecondary =>
      isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary;
  Color get textMuted =>
      isDark ? AppColors.textDarkMuted : AppColors.textLightMuted;

  Color get cardBg => isDark ? AppColors.bgCard : AppColors.bgLightSurface;
  Color get surfaceBg =>
      isDark ? AppColors.bgSurface : AppColors.bgLightElevated;
  Color get scaffoldBg => isDark ? AppColors.bgDark : AppColors.bgLight;
  Color get borderColor => isDark
      ? Colors.white.withValues(alpha: 0.10)
      : AppColors.textLightPrimary.withValues(alpha: 0.08);
}
