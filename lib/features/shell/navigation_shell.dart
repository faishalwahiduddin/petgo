import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petgo/l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/ui/glass_bar.dart';

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
              icon: const Icon(Icons.pets_outlined),
              selectedIcon: const Icon(Icons.pets),
              label: l10n.navPets,
            ),
            NavigationDestination(
              icon: const Icon(Icons.medical_services_outlined),
              selectedIcon: const Icon(Icons.medical_services),
              label: l10n.navCare,
            ),
            NavigationDestination(
              icon: const Icon(Icons.today_outlined),
              selectedIcon: const Icon(Icons.today),
              label: l10n.navDaily,
            ),
            NavigationDestination(
              icon: const Icon(Icons.folder_outlined),
              selectedIcon: const Icon(Icons.folder),
              label: l10n.navDocs,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
