import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petgo/core/models/pet.dart';
import 'package:petgo/core/providers/app_providers.dart';
import 'package:petgo/core/storage/local_storage_service.dart';
import 'package:petgo/core/utils/backup_codec.dart';
import 'package:petgo/l10n/app_localizations.dart';
import 'package:petgo/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding then home', (tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'id'});
    final storage = await LocalStorageService.init();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
        ],
        child: const PetGoApp(),
      ),
    );
    await tester.pumpAndSettle();
    // splash may animate — pump longer
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    if (find.textContaining('Saya mengerti').evaluate().isNotEmpty) {
      await tester.tap(find.textContaining('Saya mengerti'));
      await tester.pumpAndSettle();
    }
    expect(find.textContaining('PetGo'), findsWidgets);
  });

  test('pet JSON roundtrip', () {
    final pet = Pet(
      id: '1',
      name: 'Milo',
      species: PetSpecies.dog,
      breed: 'Mix',
      weightKg: 12.5,
    );
    final again = Pet.fromJson(pet.toJson());
    expect(again.name, 'Milo');
    expect(again.weightKg, 12.5);
  });

  test('backup import', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.init();
    final backup = {
      'app': 'petgo',
      'version': 1,
      'pets': [
        {
          'id': 'p1',
          'name': 'Luna',
          'species': 'cat',
          'breed': '',
          'notes': '',
        },
      ],
      'careSchedules': <Map<String, dynamic>>[],
      'vetLogs': <Map<String, dynamic>>[],
      'dailyLogs': <Map<String, dynamic>>[],
      'weightLogs': <Map<String, dynamic>>[],
      'documents': <Map<String, dynamic>>[],
      'activePetId': 'p1',
    };
    final encoded = FleetBackupCodec.encode(appTag: 'PETGO', data: backup);
    expect(await storage.importBackupString(encoded), isNull);
    expect(storage.getPets().single.name, 'Luna');
  });

  test('AppLocalizations loads', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('id'));
    expect(l10n.appTitle, 'PetGo');
  });
}
