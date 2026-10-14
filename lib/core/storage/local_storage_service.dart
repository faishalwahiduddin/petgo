import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/pet.dart';
import '../utils/backup_codec.dart';

class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  SharedPreferences get prefs => _prefs;

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = LocalStorageService(prefs);
    service.seedInitialIfEmpty();
    return service;
  }

  void seedInitialIfEmpty() {
    if (_prefs.containsKey(AppConstants.keyPets)) return;
    final pets = [Pet.sampleDog(), Pet.sampleCat()];
    savePets(pets);
    saveActivePetId(pets.first.id);
    final now = DateTime.now().toUtc();
    saveCareSchedules([
      CareSchedule(
        id: 'sch-1',
        petId: pets.first.id,
        title: 'Vaksin rabies',
        kind: CareKind.vaccine,
        intervalMonths: 12,
        lastDoneAt: now.subtract(const Duration(days: 300)),
      ),
      CareSchedule(
        id: 'sch-2',
        petId: pets.first.id,
        title: 'Obat cacing',
        kind: CareKind.deworm,
        intervalMonths: 3,
        lastDoneAt: now.subtract(const Duration(days: 70)),
      ),
    ]);
    saveDailyLogs([
      DailyCareLog(
        id: 'd1',
        petId: pets.first.id,
        date: now.subtract(const Duration(hours: 4)),
        kind: DailyCareKind.feed,
        notes: 'Pagi',
      ),
      DailyCareLog(
        id: 'd2',
        petId: pets.first.id,
        date: now.subtract(const Duration(hours: 2)),
        kind: DailyCareKind.walk,
      ),
    ]);
    saveDocuments([
      PetDocument(
        id: 'doc-1',
        petId: pets.first.id,
        title: 'Kartu vaksin',
        kind: DocKind.vaccineCard,
      ),
    ]);
  }

  bool get disclaimerAccepted =>
      _prefs.getBool(AppConstants.keyDisclaimer) ?? false;

  Future<void> setDisclaimerAccepted(bool v) =>
      _prefs.setBool(AppConstants.keyDisclaimer, v);

  List<Pet> getPets() {
    final raw = _prefs.getString(AppConstants.keyPets);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(Pet.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePets(List<Pet> items) async {
    await _prefs.setString(
      AppConstants.keyPets,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  String? getActivePetId() => _prefs.getString(AppConstants.keyActivePetId);

  Future<void> saveActivePetId(String id) =>
      _prefs.setString(AppConstants.keyActivePetId, id);

  List<CareSchedule> getCareSchedules() {
    final raw = _prefs.getString(AppConstants.keyCareSchedules);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(CareSchedule.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCareSchedules(List<CareSchedule> items) async {
    await _prefs.setString(
      AppConstants.keyCareSchedules,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  List<VetLog> getVetLogs() {
    final raw = _prefs.getString(AppConstants.keyVetLogs);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(VetLog.fromJson)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveVetLogs(List<VetLog> items) async {
    await _prefs.setString(
      AppConstants.keyVetLogs,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  List<DailyCareLog> getDailyLogs() {
    final raw = _prefs.getString(AppConstants.keyDailyLogs);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(DailyCareLog.fromJson)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveDailyLogs(List<DailyCareLog> items) async {
    await _prefs.setString(
      AppConstants.keyDailyLogs,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  List<WeightLog> getWeightLogs() {
    final raw = _prefs.getString(AppConstants.keyWeightLogs);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(WeightLog.fromJson)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWeightLogs(List<WeightLog> items) async {
    await _prefs.setString(
      AppConstants.keyWeightLogs,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  List<PetDocument> getDocuments() {
    final raw = _prefs.getString(AppConstants.keyDocuments);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(PetDocument.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveDocuments(List<PetDocument> items) async {
    await _prefs.setString(
      AppConstants.keyDocuments,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Map<String, dynamic> exportBackupJson() => {
        'app': 'petgo',
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'activePetId': getActivePetId(),
        'pets': getPets().map((e) => e.toJson()).toList(),
        'careSchedules': getCareSchedules().map((e) => e.toJson()).toList(),
        'vetLogs': getVetLogs().map((e) => e.toJson()).toList(),
        'dailyLogs': getDailyLogs().map((e) => e.toJson()).toList(),
        'weightLogs': getWeightLogs().map((e) => e.toJson()).toList(),
        'documents': getDocuments().map((e) => e.toJson()).toList(),
      };

  String exportBackupString() => FleetBackupCodec.encode(
        appTag: 'PETGO',
        data: exportBackupJson(),
      );

  ThemeMode getThemeMode() {
    final mode = _prefs.getString('theme_mode');
    if (mode == 'light') return ThemeMode.light;
    if (mode == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<bool> saveThemeMode(ThemeMode mode) async {
    final str = mode == ThemeMode.light
        ? 'light'
        : (mode == ThemeMode.dark ? 'dark' : 'system');
    return _prefs.setString('theme_mode', str);
  }

  Future<String?> importBackupString(String raw) async {
    try {
      final map = FleetBackupCodec.decode(appTag: 'PETGO', encoded: raw);
      if (map['app'] != null && map['app'] != 'petgo') {
        return 'errorBackupNotPetGo';
      }
      final pets = (map['pets'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(Pet.fromJson)
          .toList();
      if (pets.isEmpty) return 'errorBackupNoPets';
      await savePets(pets);
      await saveCareSchedules(
        (map['careSchedules'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(CareSchedule.fromJson)
            .toList(),
      );
      await saveVetLogs(
        (map['vetLogs'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(VetLog.fromJson)
            .toList(),
      );
      await saveDailyLogs(
        (map['dailyLogs'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(DailyCareLog.fromJson)
            .toList(),
      );
      await saveWeightLogs(
        (map['weightLogs'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(WeightLog.fromJson)
            .toList(),
      );
      await saveDocuments(
        (map['documents'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(PetDocument.fromJson)
            .toList(),
      );
      final active = map['activePetId'] as String?;
      if (active != null && pets.any((p) => p.id == active)) {
        await saveActivePetId(active);
      } else {
        await saveActivePetId(pets.first.id);
      }
      return null;
    } on FormatException {
      return 'errorBackupNotPetGo';
    } catch (e) {
      return 'errorInvalidJson:$e';
    }
  }
}
