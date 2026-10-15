import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../models/pet.dart';
import '../storage/local_storage_service.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('override in main');
});

final remindersEnabledProvider =
    NotifierProvider<RemindersEnabledNotifier, bool>(
  RemindersEnabledNotifier.new,
);

class RemindersEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(localStorageServiceProvider).remindersEnabled;

  Future<void> setEnabled(bool value) async {
    await ref.read(localStorageServiceProvider).setRemindersEnabled(value);
    state = value;
  }
}

final disclaimerProvider =
    NotifierProvider<DisclaimerNotifier, bool>(DisclaimerNotifier.new);

class DisclaimerNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(localStorageServiceProvider).disclaimerAccepted;

  Future<void> accept() async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setDisclaimerAccepted(true);
    await storage.prefs.setBool('onboarding_completed', true);
    state = true;
  }
}

final petsProvider = NotifierProvider<PetsNotifier, List<Pet>>(PetsNotifier.new);

class PetsNotifier extends Notifier<List<Pet>> {
  @override
  List<Pet> build() => ref.watch(localStorageServiceProvider).getPets();

  Future<String?> upsert(Pet pet) async {
    final name = pet.name.trim();
    if (name.length < AppConstants.minPetNameLength) {
      return 'errorPetNameRequired';
    }
    if (name.length > AppConstants.maxPetNameLength) {
      return 'errorPetNameTooLong';
    }
    if (pet.weightKg != null &&
        (pet.weightKg! <= 0 || pet.weightKg! > AppConstants.maxWeightKg)) {
      return 'errorWeightInvalid';
    }
    final next = [...state];
    final i = next.indexWhere((e) => e.id == pet.id);
    if (i >= 0) {
      next[i] = pet.copyWith(name: name);
    } else {
      next.add(pet.copyWith(name: name));
    }
    state = next;
    await ref.read(localStorageServiceProvider).savePets(next);
    if (ref.read(activePetIdProvider) == null && next.isNotEmpty) {
      await ref.read(activePetIdProvider.notifier).setActiveId(next.first.id);
    }
    return null;
  }

  Future<String?> remove(String id) async {
    if (state.length <= 1) return 'errorMinOnePet';
    state = state.where((e) => e.id != id).toList();
    await ref.read(localStorageServiceProvider).savePets(state);
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveCareSchedules(
      storage.getCareSchedules().where((e) => e.petId != id).toList(),
    );
    await storage.saveVetLogs(
      storage.getVetLogs().where((e) => e.petId != id).toList(),
    );
    await storage.saveDailyLogs(
      storage.getDailyLogs().where((e) => e.petId != id).toList(),
    );
    await storage.saveWeightLogs(
      storage.getWeightLogs().where((e) => e.petId != id).toList(),
    );
    await storage.saveDocuments(
      storage.getDocuments().where((e) => e.petId != id).toList(),
    );
    ref.invalidate(careSchedulesProvider);
    ref.invalidate(vetLogsProvider);
    ref.invalidate(dailyLogsProvider);
    ref.invalidate(weightLogsProvider);
    ref.invalidate(documentsProvider);
    if (ref.read(activePetIdProvider) == id && state.isNotEmpty) {
      await ref.read(activePetIdProvider.notifier).setActiveId(state.first.id);
    }
    return null;
  }

  void reload() => state = ref.read(localStorageServiceProvider).getPets();
}

final activePetIdProvider =
    NotifierProvider<ActivePetIdNotifier, String?>(ActivePetIdNotifier.new);

class ActivePetIdNotifier extends Notifier<String?> {
  @override
  String? build() => ref.watch(localStorageServiceProvider).getActivePetId();

  Future<void> setActiveId(String id) async {
    state = id;
    await ref.read(localStorageServiceProvider).saveActivePetId(id);
  }
}

final activePetProvider = Provider<Pet?>((ref) {
  final pets = ref.watch(petsProvider);
  final id = ref.watch(activePetIdProvider);
  if (pets.isEmpty) return null;
  if (id == null) return pets.first;
  return pets.firstWhere((p) => p.id == id, orElse: () => pets.first);
});

final careSchedulesProvider =
    NotifierProvider<CareSchedulesNotifier, List<CareSchedule>>(
  CareSchedulesNotifier.new,
);

class CareSchedulesNotifier extends Notifier<List<CareSchedule>> {
  @override
  List<CareSchedule> build() =>
      ref.watch(localStorageServiceProvider).getCareSchedules();

  Future<String?> upsert(CareSchedule s) async {
    if (s.title.trim().isEmpty) return 'errorTitleRequired';
    if (s.intervalMonths < 1) return 'errorIntervalRequired';
    final next = [...state];
    final i = next.indexWhere((e) => e.id == s.id);
    if (i >= 0) {
      next[i] = s;
    } else {
      next.add(s);
    }
    state = next;
    await ref.read(localStorageServiceProvider).saveCareSchedules(next);
    return null;
  }

  Future<void> markDone(String id) async {
    final i = state.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final current = state[i];
    final updated = CareSchedule(
      id: current.id,
      petId: current.petId,
      title: current.title,
      kind: current.kind,
      intervalMonths: current.intervalMonths,
      lastDoneAt: DateTime.now().toUtc(),
      notes: current.notes,
    );
    final next = [...state];
    next[i] = updated;
    state = next;
    await ref.read(localStorageServiceProvider).saveCareSchedules(next);
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await ref.read(localStorageServiceProvider).saveCareSchedules(state);
  }

  void reload() =>
      state = ref.read(localStorageServiceProvider).getCareSchedules();
}

final vetLogsProvider =
    NotifierProvider<VetLogsNotifier, List<VetLog>>(VetLogsNotifier.new);

class VetLogsNotifier extends Notifier<List<VetLog>> {
  @override
  List<VetLog> build() => ref.watch(localStorageServiceProvider).getVetLogs();

  Future<String?> upsert(VetLog log) async {
    if (log.title.trim().isEmpty) return 'errorTitleRequired';
    final next = [...state];
    final i = next.indexWhere((e) => e.id == log.id);
    if (i >= 0) {
      next[i] = log;
    } else {
      next.insert(0, log);
    }
    next.sort((a, b) => b.date.compareTo(a.date));
    state = next;
    await ref.read(localStorageServiceProvider).saveVetLogs(next);
    return null;
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await ref.read(localStorageServiceProvider).saveVetLogs(state);
  }

  void reload() => state = ref.read(localStorageServiceProvider).getVetLogs();
}

final dailyLogsProvider =
    NotifierProvider<DailyLogsNotifier, List<DailyCareLog>>(
  DailyLogsNotifier.new,
);

class DailyLogsNotifier extends Notifier<List<DailyCareLog>> {
  @override
  List<DailyCareLog> build() =>
      ref.watch(localStorageServiceProvider).getDailyLogs();

  Future<void> add(DailyCareLog log) async {
    state = [log, ...state];
    await ref.read(localStorageServiceProvider).saveDailyLogs(state);
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await ref.read(localStorageServiceProvider).saveDailyLogs(state);
  }

  void reload() => state = ref.read(localStorageServiceProvider).getDailyLogs();
}

final weightLogsProvider =
    NotifierProvider<WeightLogsNotifier, List<WeightLog>>(
  WeightLogsNotifier.new,
);

class WeightLogsNotifier extends Notifier<List<WeightLog>> {
  @override
  List<WeightLog> build() =>
      ref.watch(localStorageServiceProvider).getWeightLogs();

  Future<String?> add(WeightLog log) async {
    if (log.weightKg <= 0 || log.weightKg > AppConstants.maxWeightKg) {
      return 'errorWeightInvalid';
    }
    state = [log, ...state]..sort((a, b) => b.date.compareTo(a.date));
    await ref.read(localStorageServiceProvider).saveWeightLogs(state);
    final pet = ref.read(activePetProvider);
    if (pet != null && pet.id == log.petId) {
      await ref
          .read(petsProvider.notifier)
          .upsert(pet.copyWith(weightKg: log.weightKg));
    }
    return null;
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await ref.read(localStorageServiceProvider).saveWeightLogs(state);
  }

  void reload() =>
      state = ref.read(localStorageServiceProvider).getWeightLogs();
}

final documentsProvider =
    NotifierProvider<DocumentsNotifier, List<PetDocument>>(
  DocumentsNotifier.new,
);

class DocumentsNotifier extends Notifier<List<PetDocument>> {
  @override
  List<PetDocument> build() =>
      ref.watch(localStorageServiceProvider).getDocuments();

  Future<String?> upsert(PetDocument doc) async {
    if (doc.title.trim().isEmpty) return 'errorTitleRequired';
    final next = [...state];
    final i = next.indexWhere((e) => e.id == doc.id);
    if (i >= 0) {
      next[i] = doc;
    } else {
      next.add(doc);
    }
    state = next;
    await ref.read(localStorageServiceProvider).saveDocuments(next);
    return null;
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await ref.read(localStorageServiceProvider).saveDocuments(state);
  }

  void reload() =>
      state = ref.read(localStorageServiceProvider).getDocuments();
}
