import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petgo/core/providers/app_providers.dart';
import 'package:petgo/core/storage/local_storage_service.dart';
import 'package:petgo/core/theme/app_theme.dart';
import 'package:petgo/core/utils/app_timezone.dart';
import 'package:petgo/features/care/care_screen.dart';
import 'package:petgo/features/daily/daily_screen.dart';
import 'package:petgo/features/docs/docs_screen.dart';
import 'package:petgo/features/home/home_screen.dart';
import 'package:petgo/features/settings/settings_screen.dart';
import 'package:petgo/l10n/app_localizations.dart';
import 'package:petgo/l10n/fallback_framework_delegates.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/contrast_audit.dart';
import '../support/real_fonts.dart';

final _screens = <String, Widget Function()>{
  'home': () => const HomeScreen(),
  'care': () => const CareScreen(),
  'daily': () => const DailyScreen(),
  'docs': () => const DocsScreen(),
  'settings': () => const SettingsScreen(),
};

Future<LocalStorageService> _seededStorage() async {
  SharedPreferences.setMockInitialValues({'locale': 'id'});
  final storage = await LocalStorageService.init();
  return storage;
}

Future<void> _pump(
  WidgetTester tester,
  Widget screen,
  ThemeData theme,
  LocalStorageService storage,
) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(storage),
      ],
      child: MaterialApp(
        theme: theme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          FallbackMaterialLocalizationsDelegate(),
          FallbackWidgetsLocalizationsDelegate(),
          FallbackCupertinoLocalizationsDelegate(),
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('id'),
        home: screen,
      ),
    ),
  );
  await tester.pump(const Duration(seconds: 1));
}

Future<List<String>> _auditWholeScreen(
  WidgetTester tester,
  Color baseBg,
) async {
  final bad = <String>{...lowContrastTexts(tester, base: baseBg)};
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isEmpty) return bad.toList();

  final body = scrollables.evaluate().firstWhere(
    (e) => (e.widget as Scrollable).axisDirection == AxisDirection.down,
    orElse: () => scrollables.evaluate().first,
  );
  final finder = find.byWidget(body.widget);

  for (var i = 0; i < 8; i++) {
    await tester.drag(finder, const Offset(0, -350));
    await tester.pump(const Duration(milliseconds: 100));
    bad.addAll(lowContrastTexts(tester, base: baseBg));
  }
  return bad.toList();
}

void main() {
  setUpAll(() async {
    await loadRealRoboto();
    AppTimeZone.initAppTimeZones();
  });

  for (final themeEntry in [
    MapEntry('light', AppTheme.lightTheme),
    MapEntry('dark', AppTheme.darkTheme),
  ]) {
    final themeName = themeEntry.key;
    final theme = themeEntry.value;

    group('Contrast audit ($themeName)', () {
      for (final screenEntry in _screens.entries) {
        final screenName = screenEntry.key;
        final screenBuilder = screenEntry.value;

        testWidgets(screenName, (tester) async {
          final storage = await _seededStorage();
          await _pump(tester, screenBuilder(), theme, storage);

          final bg = theme.scaffoldBackgroundColor;
          final lowContrast = await _auditWholeScreen(tester, bg);
          expect(
            lowContrast,
            isEmpty,
            reason:
                'Screen $screenName in $themeName has low contrast texts: $lowContrast',
          );
        });
      }
    });
  }
}
