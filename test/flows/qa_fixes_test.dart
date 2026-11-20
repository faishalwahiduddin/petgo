import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petgo/core/models/pet.dart';
import 'package:petgo/core/providers/app_providers.dart';
import 'package:petgo/core/providers/theme_provider.dart';
import 'package:petgo/core/storage/local_storage_service.dart';
import 'package:petgo/core/theme/app_theme.dart';
import 'package:petgo/core/utils/app_timezone.dart';
import 'package:petgo/core/utils/pet_format.dart';
import 'package:petgo/features/care/care_screen.dart';
import 'package:petgo/features/daily/daily_screen.dart';
import 'package:petgo/features/docs/docs_screen.dart';
import 'package:petgo/l10n/app_localizations.dart';
import 'package:petgo/l10n/fallback_framework_delegates.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/real_fonts.dart';

Future<LocalStorageService> _storage() async {
  SharedPreferences.setMockInitialValues({'locale': 'id'});
  final s = await LocalStorageService.init();
  return s;
}

Widget _wrap(Widget child, LocalStorageService storage, {ThemeMode mode = ThemeMode.system}) {
  return ProviderScope(
    overrides: [
      localStorageServiceProvider.overrideWithValue(storage),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FallbackMaterialLocalizationsDelegate(),
        FallbackWidgetsLocalizationsDelegate(),
        FallbackCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('id'),
      home: child,
    ),
  );
}

void main() {
  setUpAll(() async {
    await loadRealRoboto();
    AppTimeZone.initAppTimeZones();
  });

  testWidgets('P2 F5: Deleting weight log recomputes pet profile weight', (tester) async {
    final storage = await _storage();
    final c = ProviderContainer(
      overrides: [localStorageServiceProvider.overrideWithValue(storage)],
    );
    addTearDown(c.dispose);

    // Initial Milo weight is 12.5 kg
    expect(c.read(activePetProvider)!.weightKg, 12.5);

    // Add new weight log: 13.1 kg
    final logId = 'w-test-131';
    await c.read(weightLogsProvider.notifier).add(
      WeightLog(
        id: logId,
        petId: 'sample-dog',
        date: DateTime.now().toUtc(),
        weightKg: 13.1,
      ),
    );
    expect(c.read(activePetProvider)!.weightKg, 13.1);

    // Remove the 13.1 kg weight log -> profile weight reverts back to 12.5 kg
    await c.read(weightLogsProvider.notifier).remove(logId);
    expect(c.read(activePetProvider)!.weightKg, 12.5);
  });

  testWidgets('P1 F3: Total vet cost computed and formatted correctly', (tester) async {
    final storage = await _storage();
    final c = ProviderContainer(
      overrides: [localStorageServiceProvider.overrideWithValue(storage)],
    );
    addTearDown(c.dispose);

    // Add two vet logs with cost
    await c.read(vetLogsProvider.notifier).upsert(
      VetLog(
        id: 'v1',
        petId: 'sample-dog',
        date: DateTime.now().toUtc(),
        title: 'Vaksin Rabies',
        cost: 250000,
      ),
    );
    await c.read(vetLogsProvider.notifier).upsert(
      VetLog(
        id: 'v2',
        petId: 'sample-dog',
        date: DateTime.now().toUtc(),
        title: 'Pembersihan Karang Gigi',
        cost: 350000,
      ),
    );

    final vetLogs = c
        .read(vetLogsProvider)
        .where((v) => v.petId == 'sample-dog')
        .toList();
    final totalCost = vetLogs.fold<double>(0.0, (sum, v) => sum + (v.cost ?? 0.0));
    expect(totalCost, 600000.0);
    expect(PetFormat.rupiah(totalCost, 'id'), contains('600.000'));
  });

  testWidgets('P2 F8: Pet selector chip visible in Care, Daily and Docs AppBars', (tester) async {
    final storage = await _storage();
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // Care screen
    await tester.pumpWidget(_wrap(const CareScreen(), storage));
    await tester.pumpAndSettle();
    expect(find.text('Milo'), findsWidgets);

    // Daily screen
    await tester.pumpWidget(_wrap(const DailyScreen(), storage));
    await tester.pumpAndSettle();
    expect(find.text('Milo'), findsWidgets);

    // Docs screen
    await tester.pumpWidget(_wrap(const DocsScreen(), storage));
    await tester.pumpAndSettle();
    expect(find.text('Milo'), findsWidgets);
  });

  testWidgets('P2 F12: Theme mode toggles between light and dark in settings', (tester) async {
    final storage = await _storage();
    final c = ProviderContainer(
      overrides: [localStorageServiceProvider.overrideWithValue(storage)],
    );
    addTearDown(c.dispose);

    expect(c.read(themeModeProvider), ThemeMode.system);
    await c.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
    expect(c.read(themeModeProvider), ThemeMode.dark);
    await c.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
    expect(c.read(themeModeProvider), ThemeMode.light);
  });
}
