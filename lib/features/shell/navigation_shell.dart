import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petgo/l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/ui/app_icon.dart';
import '../../core/ui/glass_bar.dart';

/// Height of the Material 3 [NavigationBar] drawn over tab pages (extendBody):
/// tab-page FABs pad by this so the bar does not cover them.
const kShellNavBarHeight = 80.0;

class NavigationShell extends StatelessWidget {
  const NavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navSurface = isDark ? AppColors.bgSurface : AppColors.bgLightSurface;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: GlassBar(
        borderSide: BarBorderSide.top,
        color: navSurface,
        opacity: 0.82,
        blurSigma: 20,
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onTap,
          destinations: [
            NavigationDestination(
              icon: const AppIcon('nav_pets', size: 22),
              selectedIcon: const AppIcon('nav_pets_active', size: 22, color: AppColors.primary),
              label: l10n.navPets,
            ),
            NavigationDestination(
              icon: const AppIcon('nav_care', size: 22),
              selectedIcon: const AppIcon('nav_care_active', size: 22, color: AppColors.primary),
              label: l10n.navCare,
            ),
            NavigationDestination(
              icon: const AppIcon('nav_daily', size: 22),
              selectedIcon: const AppIcon('nav_daily_active', size: 22, color: AppColors.primary),
              label: l10n.navDaily,
            ),
            NavigationDestination(
              icon: const AppIcon('nav_docs', size: 22),
              selectedIcon: const AppIcon('nav_docs_active', size: 22, color: AppColors.primary),
              label: l10n.navDocs,
            ),
            NavigationDestination(
              icon: const AppIcon('nav_settings', size: 22),
              selectedIcon: const AppIcon('nav_settings_active', size: 22, color: AppColors.primary),
              label: l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
