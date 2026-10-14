import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/care/care_screen.dart';
import '../../features/daily/daily_screen.dart';
import '../../features/docs/docs_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/navigation_shell.dart';
import '../providers/app_providers.dart';
import '../ui/fleet_splash_screen.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  final accepted = ref.watch(disclaimerProvider);
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      if (state.matchedLocation == '/splash') return null;
      final onboarding = state.matchedLocation == '/onboarding';
      if (!accepted && !onboarding) return '/onboarding';
      if (accepted && onboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const FleetSplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/care',
                builder: (context, state) => const CareScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/daily',
                builder: (context, state) => const DailyScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/docs',
                builder: (context, state) => const DocsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
