// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'PetGo';

  @override
  String get navPets => 'Hewan';

  @override
  String get navCare => 'Perawatan';

  @override
  String get navDaily => 'Harian';

  @override
  String get navDocs => 'Dokumen';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get onboardingHeadline => 'PetGo';

  @override
  String get onboardingDescription =>
      'Kelola profil hewan, jadwal vaksin/cacing, kunjungan vet, dan log harian secara offline di perangkat Anda.\n\nTanpa akun. Data tersimpan lokal.';

  @override
  String get onboardingContinue => 'Saya mengerti — lanjut';

  @override
  String get homeActivePet => 'Hewan aktif';

  @override
  String get homeNoPets => 'Belum ada hewan. Tambahkan profil dulu.';

  @override
  String get homeDueSoon => 'Jatuh tempo / segera';

  @override
  String get homeNoDue => 'Tidak ada jadwal mendesak.';

  @override
  String get homeAllPets => 'Semua hewan';

  @override
  String get actionAddPet => 'Tambah hewan';

  @override
  String get actionAddSchedule => 'Tambah jadwal';

  @override
  String get actionAddVet => 'Catat vet';

  @override
  String get actionAddWeight => 'Catat berat';

  @override
  String get actionAddDoc => 'Tambah dokumen';

  @override
  String get actionSave => 'Simpan';

  @override
  String get actionCancel => 'Batal';

  @override
  String get speciesDog => 'Anjing';

  @override
  String get speciesCat => 'Kucing';

  @override
  String get speciesBird => 'Burung';

  @override
  String get speciesRabbit => 'Kelinci';

  @override
  String get speciesOther => 'Lainnya';

  @override
  String get fieldPetName => 'Nama';

  @override
  String get fieldSpecies => 'Spesies';

  @override
  String get fieldBreed => 'Ras';

  @override
  String get fieldWeightKg => 'Berat (kg)';

  @override
  String get fieldTitle => 'Judul';

  @override
  String get fieldIntervalMonths => 'Interval (bulan)';

  @override
  String get fieldClinic => 'Klinik';

  @override
  String get fieldMedication => 'Obat';

  @override
  String get careSchedulesTitle => 'Jadwal perawatan';

  @override
  String get vetLogsTitle => 'Kunjungan & obat';

  @override
  String get careEmptySchedules => 'Belum ada jadwal.';

  @override
  String get careEmptyVet => 'Belum ada catatan vet.';

  @override
  String get careVaccine => 'Vaksin';

  @override
  String get careDeworm => 'Obat cacing';

  @override
  String get careFlea => 'Kutu / flea';

  @override
  String get careGrooming => 'Grooming';

  @override
  String get careOther => 'Lainnya';

  @override
  String everyMonths(int months) {
    return 'tiap $months bln';
  }

  @override
  String daysRemaining(int days) {
    return '$days hari lagi';
  }

  @override
  String get urgencyOverdue => 'Terlewat';

  @override
  String get dailyQuickAdd => 'Catat cepat';

  @override
  String get dailyTimeline => 'Timeline';

  @override
  String get dailyEmpty => 'Belum ada log harian.';

  @override
  String get dailyFeed => 'Makan';

  @override
  String get dailyWalk => 'Jalan';

  @override
  String get dailyLitter => 'Litter';

  @override
  String get dailyOther => 'Lainnya';

  @override
  String get weightHistory => 'Riwayat berat';

  @override
  String get docsEmpty => 'Belum ada dokumen.';

  @override
  String get docVaccineCard => 'Kartu vaksin';

  @override
  String get docPrescription => 'Resep';

  @override
  String get docInsurance => 'Asuransi';

  @override
  String get docOther => 'Lainnya';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsPets => 'Profil hewan';

  @override
  String get settingsBackup => 'Cadangan';

  @override
  String get settingsVersion => 'Versi';

  @override
  String get tileExportBackup => 'Ekspor cadangan';

  @override
  String get tileImportBackup => 'Impor cadangan';

  @override
  String get snackbarImportSuccess => 'Cadangan berhasil diimpor';

  @override
  String get errorPetNameRequired => 'Nama hewan minimal 2 karakter';

  @override
  String get errorPetNameTooLong => 'Nama hewan terlalu panjang';

  @override
  String get errorWeightInvalid => 'Berat tidak valid';

  @override
  String get errorMinOnePet => 'Minimal satu profil hewan';

  @override
  String get errorTitleRequired => 'Judul wajib diisi';

  @override
  String get errorIntervalRequired => 'Interval minimal 1 bulan';

  @override
  String get errorBackupNotPetGo => 'Berkas bukan cadangan PetGo';
}
