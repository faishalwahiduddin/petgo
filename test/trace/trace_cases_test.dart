// §TRACE case evidence — one test per TC in docs/trace/flows.yaml (title prefix = TC id).
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petgo/core/models/pet.dart';
import 'package:petgo/core/providers/app_providers.dart';
import 'package:petgo/core/storage/local_storage_service.dart';
import 'package:petgo/core/utils/backup_codec.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container({bool seed = false, Map<String, Object> initial = const {}}) async {
  SharedPreferences.setMockInitialValues(initial);
  final storage = LocalStorageService(await SharedPreferences.getInstance());
  if (seed) storage.seedInitialIfEmpty();
  final c = ProviderContainer(overrides: [localStorageServiceProvider.overrideWithValue(storage)]);
  addTearDown(c.dispose);
  return c;
}

Future<LocalStorageService> _storage([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  return LocalStorageService(await SharedPreferences.getInstance());
}

final _nowUtc = DateTime.now().toUtc();
DateTime _daysAgo(int d) => DateTime.utc(_nowUtc.year, _nowUtc.month, _nowUtc.day).subtract(Duration(days: d));
CareSchedule _sch(String id, {int interval = 3, DateTime? last, String petId = 'p1', String title = 'Obat cacing'}) =>
    CareSchedule(id: id, petId: petId, title: title, kind: CareKind.deworm, intervalMonths: interval, lastDoneAt: last ?? _daysAgo(0));

void main() {
  group('FLOW-PET-01 profil hewan', () {
    test('FLOW-PET-01-T01 hewan pertama tersimpan dan otomatis menjadi hewan aktif', () async {
      final c = await _container();
      expect(await c.read(petsProvider.notifier).upsert(const Pet(id: 'p1', name: '  Kopi  ', species: PetSpecies.cat, weightKg: 4.2)), isNull);
      expect(c.read(petsProvider).single.name, 'Kopi');
      expect(c.read(activePetIdProvider), 'p1');
      expect(c.read(activePetProvider)!.weightKg, 4.2);
    });

    test('FLOW-PET-01-T02 nama satu huruf atau berat di luar 0–500 kg ditolak', () async {
      final c = await _container();
      final n = c.read(petsProvider.notifier);
      expect(await n.upsert(const Pet(id: 'a', name: 'K', species: PetSpecies.dog)), 'errorPetNameRequired');
      expect(await n.upsert(const Pet(id: 'b', name: 'Kopi', species: PetSpecies.dog, weightKg: 0)), 'errorWeightInvalid');
      expect(await n.upsert(const Pet(id: 'c', name: 'Kopi', species: PetSpecies.dog, weightKg: 500.1)), 'errorWeightInvalid');
      expect(c.read(petsProvider), isEmpty);
    });

    test('FLOW-PET-01-T03 batas: nama 50 karakter dan berat 500 kg diterima, 51 karakter ditolak', () async {
      final c = await _container();
      final n = c.read(petsProvider.notifier);
      expect(await n.upsert(Pet(id: 'a', name: 'a' * 50, species: PetSpecies.other, weightKg: 500)), isNull);
      expect(await n.upsert(Pet(id: 'b', name: 'a' * 51, species: PetSpecies.other)), 'errorPetNameTooLong');
    });

    test('FLOW-PET-01-T04 hapus hewan aktif men-cascade semua catatannya; hewan terakhir diblok', () async {
      final c = await _container(seed: true);
      final n = c.read(petsProvider.notifier);
      expect(c.read(careSchedulesProvider).where((s) => s.petId == 'sample-dog'), isNotEmpty);
      expect(await n.remove('sample-dog'), isNull);
      expect(c.read(activePetIdProvider), 'sample-cat');
      expect(c.read(careSchedulesProvider).where((s) => s.petId == 'sample-dog'), isEmpty);
      expect(c.read(dailyLogsProvider).where((s) => s.petId == 'sample-dog'), isEmpty);
      expect(c.read(documentsProvider).where((s) => s.petId == 'sample-dog'), isEmpty);
      expect(await n.remove('sample-cat'), 'errorMinOnePet');
    });
  });

  group('FLOW-CAR-01 jadwal perawatan', () {
    test('FLOW-CAR-01-T01 tandai selesai mencatat tanggal aktual dan menggeser jatuh tempo', () async {
      final c = await _container();
      await c.read(careSchedulesProvider.notifier).upsert(_sch('s', interval: 3, last: _daysAgo(100)));
      expect(c.read(careSchedulesProvider).single.urgency, ScheduleUrgency.overdue);
      await c.read(careSchedulesProvider.notifier).markDone('s');
      final s = c.read(careSchedulesProvider).single;
      expect(s.lastDoneAt.difference(_nowUtc).inMinutes.abs(), lessThan(5));
      expect(s.urgency, ScheduleUrgency.safe);
    });

    test('FLOW-CAR-01-T02 jadwal tanpa judul atau interval < 1 bulan ditolak', () async {
      final c = await _container();
      final n = c.read(careSchedulesProvider.notifier);
      expect(await n.upsert(_sch('a', title: ' ')), 'errorTitleRequired');
      expect(await n.upsert(_sch('b', interval: 0)), 'errorIntervalRequired');
      expect(c.read(careSchedulesProvider), isEmpty);
    });

    test('FLOW-CAR-01-T03 batas urgensi: jatuh tempo hari ini terlewat, H-14 segera, H-15 aman', () {
      final s = _sch('x', interval: 1, last: DateTime.utc(2026, 1, 31));
      expect(s.dueDate, DateTime.utc(2026, 2, 28));
      DateTime lastFor(int daysLeft) {
        // pick lastDoneAt so that dueDate = today + daysLeft (1-month interval, mid-month safe)
        final due = _daysAgo(-daysLeft);
        return DateTime.utc(due.month == 1 ? due.year - 1 : due.year, due.month == 1 ? 12 : due.month - 1, due.day);
      }
      final today = _daysAgo(0);
      if (today.day <= 28) {
        expect(_sch('a', interval: 1, last: lastFor(0)).urgency, ScheduleUrgency.overdue);
      }
      final d14 = _daysAgo(-14), d15 = _daysAgo(-15);
      if (d14.day <= 28 && d15.day <= 28) {
        expect(_sch('b', interval: 1, last: lastFor(14)).urgency, ScheduleUrgency.dueSoon);
        expect(_sch('c', interval: 1, last: lastFor(15)).urgency, ScheduleUrgency.safe);
      }
    });

    test('FLOW-CAR-01-T04 interval melewati akhir tahun dan akhir bulan dijepit ke tanggal terakhir', () {
      expect(_sch('a', interval: 3, last: DateTime.utc(2026, 11, 30)).dueDate, DateTime.utc(2027, 2, 28));
      expect(_sch('b', interval: 14, last: DateTime.utc(2026, 1, 15)).dueDate, DateTime.utc(2027, 3, 15));
    });
  });

  group('FLOW-VET-01 kunjungan dokter hewan', () {
    test('FLOW-VET-01-T01 kunjungan vet tersimpan terurut terbaru dengan obat dan biaya', () async {
      final c = await _container();
      final n = c.read(vetLogsProvider.notifier);
      await n.upsert(VetLog(id: 'a', petId: 'p1', date: _daysAgo(30), title: 'Vaksin', cost: 150000));
      expect(await n.upsert(VetLog(id: 'b', petId: 'p1', date: _daysAgo(1), title: 'Diare', medication: 'Probiotik')), isNull);
      expect(c.read(vetLogsProvider).map((e) => e.id), ['b', 'a']);
      expect(c.read(localStorageServiceProvider).getVetLogs().first.medication, 'Probiotik');
    });

    test('FLOW-VET-01-T02 kunjungan tanpa judul ditolak', () async {
      final c = await _container();
      expect(await c.read(vetLogsProvider.notifier).upsert(VetLog(id: 'a', petId: 'p1', date: _daysAgo(0), title: '  ')), 'errorTitleRequired');
    });

    test('FLOW-VET-01-T03 biaya kosong diperbolehkan dan bertahan setelah disimpan ulang', () async {
      final s = await _storage();
      await s.saveVetLogs([VetLog(id: 'a', petId: 'p1', date: _daysAgo(0), title: 'Kontrol')]);
      expect(s.getVetLogs().single.cost, isNull);
    });

    test('FLOW-VET-01-T04 menyimpan ulang id yang sama memperbarui; data vet korup dibaca kosong', () async {
      final c = await _container();
      final n = c.read(vetLogsProvider.notifier);
      await n.upsert(VetLog(id: 'a', petId: 'p1', date: _daysAgo(2), title: 'Kontrol'));
      await n.upsert(VetLog(id: 'a', petId: 'p1', date: _daysAgo(2), title: 'Kontrol ulang'));
      expect(c.read(vetLogsProvider).single.title, 'Kontrol ulang');
      final s = await _storage({'petgo_vet_logs': '{rusak'});
      expect(s.getVetLogs(), isEmpty);
    });
  });

  group('FLOW-DAY-01 log harian & berat', () {
    test('FLOW-DAY-01-T01 log makan dan timbang berat memperbarui berat profil hewan aktif', () async {
      final c = await _container();
      await c.read(petsProvider.notifier).upsert(const Pet(id: 'p1', name: 'Kopi', species: PetSpecies.cat, weightKg: 4));
      await c.read(dailyLogsProvider.notifier).add(DailyCareLog(id: 'd', petId: 'p1', date: _daysAgo(0), kind: DailyCareKind.feed));
      expect(await c.read(weightLogsProvider.notifier).add(WeightLog(id: 'w', petId: 'p1', date: _daysAgo(0), weightKg: 4.4)), isNull);
      expect(c.read(activePetProvider)!.weightKg, 4.4);
      expect(c.read(dailyLogsProvider).single.kind, DailyCareKind.feed);
    });

    test('FLOW-DAY-01-T02 berat 0 atau di atas 500 kg ditolak', () async {
      final c = await _container();
      final n = c.read(weightLogsProvider.notifier);
      expect(await n.add(WeightLog(id: 'a', petId: 'p1', date: _daysAgo(0), weightKg: 0)), 'errorWeightInvalid');
      expect(await n.add(WeightLog(id: 'b', petId: 'p1', date: _daysAgo(0), weightKg: 501)), 'errorWeightInvalid');
      expect(c.read(weightLogsProvider), isEmpty);
    });

    test('FLOW-DAY-01-T03 riwayat berat terurut terbaru meski dicatat tidak berurutan', () async {
      final c = await _container();
      final n = c.read(weightLogsProvider.notifier);
      await n.add(WeightLog(id: 'baru', petId: 'p1', date: _daysAgo(1), weightKg: 5));
      await n.add(WeightLog(id: 'lama', petId: 'p1', date: _daysAgo(20), weightKg: 4.5));
      expect(c.read(weightLogsProvider).map((e) => e.id), ['baru', 'lama']);
    });

    test('FLOW-DAY-01-T04 timbang hewan yang tidak aktif tidak mengubah profil hewan aktif', () async {
      final c = await _container();
      await c.read(petsProvider.notifier).upsert(const Pet(id: 'p1', name: 'Kopi', species: PetSpecies.cat, weightKg: 4));
      await c.read(petsProvider.notifier).upsert(const Pet(id: 'p2', name: 'Susu', species: PetSpecies.cat, weightKg: 3));
      await c.read(weightLogsProvider.notifier).add(WeightLog(id: 'w', petId: 'p2', date: _daysAgo(0), weightKg: 3.3));
      expect(c.read(activePetProvider)!.weightKg, 4);
    });
  });

  group('FLOW-DOC-01 dokumen', () {
    test('FLOW-DOC-01-T01 dokumen kartu vaksin dengan masa berlaku tersimpan', () async {
      final c = await _container();
      expect(await c.read(documentsProvider.notifier).upsert(PetDocument(id: 'd', petId: 'p1', title: 'Kartu vaksin', kind: DocKind.vaccineCard, expiresAt: DateTime.utc(2027, 1, 1))), isNull);
      expect(c.read(localStorageServiceProvider).getDocuments().single.expiresAt, DateTime.utc(2027, 1, 1));
    });

    test('FLOW-DOC-01-T02 dokumen tanpa judul ditolak', () async {
      final c = await _container();
      expect(await c.read(documentsProvider.notifier).upsert(const PetDocument(id: 'd', petId: 'p1', title: '', kind: DocKind.other)), 'errorTitleRequired');
    });

    test('FLOW-DOC-01-T03 dokumen tanpa masa berlaku tetap tersimpan', () async {
      final c = await _container();
      await c.read(documentsProvider.notifier).upsert(const PetDocument(id: 'd', petId: 'p1', title: 'Resep', kind: DocKind.prescription));
      expect(c.read(documentsProvider).single.expiresAt, isNull);
    });

    test('FLOW-DOC-01-T04 jenis dokumen tak dikenal di data lama dibaca tanpa crash', () async {
      final raw = const PetDocument(id: 'd', petId: 'p1', title: 'X', kind: DocKind.insurance).toJson()..['kind'] = 'paspor';
      final s = await _storage({'petgo_documents': jsonEncode([raw])});
      expect(s.getDocuments().single.title, 'X');
    });
  });

  group('FLOW-SET-01 cadangan & pengaturan', () {
    test('FLOW-SET-01-T01 ekspor cadangan lalu impor memulihkan hewan dan jadwal', () async {
      final s = await _storage();
      s.seedInitialIfEmpty();
      await Future<void>.delayed(Duration.zero);
      final backup = s.exportBackupString();
      final fresh = await _storage();
      expect(await fresh.importBackupString(backup), isNull);
      expect(fresh.getPets().map((p) => p.id), ['sample-dog', 'sample-cat']);
      expect(fresh.getCareSchedules().length, 2);
    });

    test('FLOW-SET-01-T02 cadangan milik app lain, tanpa hewan, atau JSON mentah ditolak', () async {
      final s = await _storage();
      expect(await s.importBackupString(FleetBackupCodec.encode(appTag: 'GARAGEGO', data: {})), 'errorBackupNotPetGo');
      expect(await s.importBackupString(FleetBackupCodec.encode(appTag: 'PETGO', data: {'app': 'petgo', 'pets': []})), 'errorBackupNoPets');
      expect(await s.importBackupString('{"pets":[]}'), isNotNull);
    });

    test('FLOW-SET-01-T03 instalasi baru berisi contoh hewan dan tidak menimpa data yang ada', () async {
      final s = await _storage();
      s.seedInitialIfEmpty();
      await Future<void>.delayed(Duration.zero);
      expect(s.getPets().length, 2);
      await s.savePets([const Pet(id: 'x', name: 'Kopi', species: PetSpecies.cat)]);
      s.seedInitialIfEmpty();
      expect(s.getPets().single.id, 'x');
    });

    test('FLOW-SET-01-T04 impor dengan hewan aktif yang hilang memilih hewan pertama', () async {
      final s = await _storage();
      final data = FleetBackupCodec.encode(appTag: 'PETGO', data: {
        'app': 'petgo',
        'activePetId': 'hilang',
        'pets': [const Pet(id: 'x', name: 'Kopi', species: PetSpecies.cat).toJson()],
      });
      expect(await s.importBackupString(data), isNull);
      expect(s.getActivePetId(), 'x');
    });
  });
}
