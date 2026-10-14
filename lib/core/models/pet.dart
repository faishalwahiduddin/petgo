import '../utils/app_timezone.dart';

DateTime _decodeDate(Object? raw) {
  final parsed = AppTimeZone.parseUtc(raw);
  if (parsed == null) throw FormatException('Not a UTC instant: $raw');
  return parsed;
}

DateTime? _decodeDateOpt(Object? raw) => raw == null ? null : _decodeDate(raw);

String _encodeDate(DateTime instant) => AppTimeZone.encodeForPrefs(instant);

String? _encodeDateOpt(DateTime? instant) =>
    instant == null ? null : AppTimeZone.encodeForPrefs(instant);

enum PetSpecies { dog, cat, bird, rabbit, other }

enum CareKind { vaccine, deworm, flea, grooming, other }

enum DailyCareKind { feed, walk, litter, other }

enum DocKind { vaccineCard, prescription, insurance, other }

enum ScheduleUrgency { safe, dueSoon, overdue }

class Pet {
  final String id;
  final String name;
  final PetSpecies species;
  final String breed;
  final DateTime? dateOfBirth;
  final double? weightKg;
  final String notes;

  const Pet({
    required this.id,
    required this.name,
    required this.species,
    this.breed = '',
    this.dateOfBirth,
    this.weightKg,
    this.notes = '',
  });

  factory Pet.sampleDog() => Pet(
        id: 'sample-dog',
        name: 'Milo',
        species: PetSpecies.dog,
        breed: 'Mixed',
        dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 2)),
        weightKg: 12.5,
      );

  factory Pet.sampleCat() => Pet(
        id: 'sample-cat',
        name: 'Luna',
        species: PetSpecies.cat,
        breed: 'Domestic',
        dateOfBirth: DateTime.now().subtract(const Duration(days: 365)),
        weightKg: 4.2,
      );

  Pet copyWith({
    String? name,
    PetSpecies? species,
    String? breed,
    DateTime? dateOfBirth,
    double? weightKg,
    String? notes,
    bool clearDob = false,
    bool clearWeight = false,
  }) =>
      Pet(
        id: id,
        name: name ?? this.name,
        species: species ?? this.species,
        breed: breed ?? this.breed,
        dateOfBirth: clearDob ? null : (dateOfBirth ?? this.dateOfBirth),
        weightKg: clearWeight ? null : (weightKg ?? this.weightKg),
        notes: notes ?? this.notes,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'species': species.name,
        'breed': breed,
        'dateOfBirth': _encodeDateOpt(dateOfBirth),
        'weightKg': weightKg,
        'notes': notes,
      };

  factory Pet.fromJson(Map<String, dynamic> j) => Pet(
        id: j['id'] as String,
        name: j['name'] as String,
        species: PetSpecies.values.firstWhere(
          (e) => e.name == j['species'],
          orElse: () => PetSpecies.other,
        ),
        breed: j['breed'] as String? ?? '',
        dateOfBirth: _decodeDateOpt(j['dateOfBirth']),
        weightKg: (j['weightKg'] as num?)?.toDouble(),
        notes: j['notes'] as String? ?? '',
      );
}

class CareSchedule {
  final String id;
  final String petId;
  final String title;
  final CareKind kind;
  final int intervalMonths;
  final DateTime lastDoneAt;
  final String notes;

  const CareSchedule({
    required this.id,
    required this.petId,
    required this.title,
    required this.kind,
    required this.intervalMonths,
    required this.lastDoneAt,
    this.notes = '',
  });

  DateTime get dueDate {
    var y = lastDoneAt.year;
    var m = lastDoneAt.month + intervalMonths;
    while (m > 12) {
      m -= 12;
      y++;
    }
    final day = lastDoneAt.day;
    final lastDay = DateTime(y, m + 1, 0).day;
    return DateTime.utc(y, m, day > lastDay ? lastDay : day);
  }

  int get daysRemaining {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    final due = DateTime.utc(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  ScheduleUrgency get urgency {
    final d = daysRemaining;
    if (d <= 0) return ScheduleUrgency.overdue;
    if (d <= 14) return ScheduleUrgency.dueSoon;
    return ScheduleUrgency.safe;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'title': title,
        'kind': kind.name,
        'intervalMonths': intervalMonths,
        'lastDoneAt': _encodeDate(lastDoneAt),
        'notes': notes,
      };

  factory CareSchedule.fromJson(Map<String, dynamic> j) => CareSchedule(
        id: j['id'] as String,
        petId: j['petId'] as String,
        title: j['title'] as String,
        kind: CareKind.values.firstWhere(
          (e) => e.name == j['kind'],
          orElse: () => CareKind.other,
        ),
        intervalMonths: (j['intervalMonths'] as num).toInt(),
        lastDoneAt: _decodeDate(j['lastDoneAt']),
        notes: j['notes'] as String? ?? '',
      );
}

class VetLog {
  final String id;
  final String petId;
  final DateTime date;
  final String title;
  final String clinic;
  final String medication;
  final double? cost;
  final String notes;

  const VetLog({
    required this.id,
    required this.petId,
    required this.date,
    required this.title,
    this.clinic = '',
    this.medication = '',
    this.cost,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'date': _encodeDate(date),
        'title': title,
        'clinic': clinic,
        'medication': medication,
        'cost': cost,
        'notes': notes,
      };

  factory VetLog.fromJson(Map<String, dynamic> j) => VetLog(
        id: j['id'] as String,
        petId: j['petId'] as String,
        date: _decodeDate(j['date']),
        title: j['title'] as String,
        clinic: j['clinic'] as String? ?? '',
        medication: j['medication'] as String? ?? '',
        cost: (j['cost'] as num?)?.toDouble(),
        notes: j['notes'] as String? ?? '',
      );
}

class DailyCareLog {
  final String id;
  final String petId;
  final DateTime date;
  final DailyCareKind kind;
  final String notes;

  const DailyCareLog({
    required this.id,
    required this.petId,
    required this.date,
    required this.kind,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'date': _encodeDate(date),
        'kind': kind.name,
        'notes': notes,
      };

  factory DailyCareLog.fromJson(Map<String, dynamic> j) => DailyCareLog(
        id: j['id'] as String,
        petId: j['petId'] as String,
        date: _decodeDate(j['date']),
        kind: DailyCareKind.values.firstWhere(
          (e) => e.name == j['kind'],
          orElse: () => DailyCareKind.other,
        ),
        notes: j['notes'] as String? ?? '',
      );
}

class WeightLog {
  final String id;
  final String petId;
  final DateTime date;
  final double weightKg;
  final String notes;

  const WeightLog({
    required this.id,
    required this.petId,
    required this.date,
    required this.weightKg,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'date': _encodeDate(date),
        'weightKg': weightKg,
        'notes': notes,
      };

  factory WeightLog.fromJson(Map<String, dynamic> j) => WeightLog(
        id: j['id'] as String,
        petId: j['petId'] as String,
        date: _decodeDate(j['date']),
        weightKg: (j['weightKg'] as num).toDouble(),
        notes: j['notes'] as String? ?? '',
      );
}

class PetDocument {
  final String id;
  final String petId;
  final String title;
  final DocKind kind;
  final DateTime? expiresAt;
  final String notes;

  const PetDocument({
    required this.id,
    required this.petId,
    required this.title,
    required this.kind,
    this.expiresAt,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'title': title,
        'kind': kind.name,
        'expiresAt': _encodeDateOpt(expiresAt),
        'notes': notes,
      };

  factory PetDocument.fromJson(Map<String, dynamic> j) => PetDocument(
        id: j['id'] as String,
        petId: j['petId'] as String,
        title: j['title'] as String,
        kind: DocKind.values.firstWhere(
          (e) => e.name == j['kind'],
          orElse: () => DocKind.other,
        ),
        expiresAt: _decodeDateOpt(j['expiresAt']),
        notes: j['notes'] as String? ?? '',
      );
}
