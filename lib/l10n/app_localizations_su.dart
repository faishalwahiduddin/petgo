// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sundanese (`su`).
class AppLocalizationsSu extends AppLocalizations {
  AppLocalizationsSu([String locale = 'su']) : super(locale);

  @override
  String get appTitle => 'PetGo';

  @override
  String get appTagline => 'Profil sato, jadwal miara & catetan sapopoé';

  @override
  String get navPets => 'Sato';

  @override
  String get navCare => 'Miara';

  @override
  String get navDaily => 'Sapopoé';

  @override
  String get navDocs => 'Surat';

  @override
  String get navSettings => 'Pangaturan';

  @override
  String get onboardingHeadline => 'PetGo';

  @override
  String get onboardingDescription =>
      'Atur profil sato, jadwal vaksin jeung ubar cacing, kadatangan ka dokter sato, sarta catetan sapopoé — sadayana offline dina alat anjeun.\n\nTanpa akun. Data henteu pernah kaluar ti alat anjeun.';

  @override
  String get onboardingContinue => 'Ngartos — teraskeun';

  @override
  String get onbSkip => 'Liwat';

  @override
  String get onbNext => 'Teraskeun';

  @override
  String get onbGetStarted => 'Mimitian ayeuna';

  @override
  String get onbSlide1Title => 'Profil sato';

  @override
  String get onbSlide1Sub => 'Anjing, ucing, jeung sasatoan lianna';

  @override
  String get onbSlide1Badge => '100% offline jeung teu dilacak';

  @override
  String get onbSlide2Title => 'Jadwal miara';

  @override
  String get onbSlide2Sub => 'Vaksin, ubar cacing, kutu, jeung ngarawat bulu';

  @override
  String get onbSlide2Badge => 'Panginget lokal';

  @override
  String get onbSlide3Title => 'Catetan sapopoé';

  @override
  String get onbSlide3Sub => 'Dahar, leumpang, jeung kotak keusik';

  @override
  String get onbSlide3Badge => 'Taya iklan, taya akun';

  @override
  String get onbSlide4Title => 'Surat lokal';

  @override
  String get onbSlide4Sub => 'Kartu vaksinasi jeung résép disimpen rapi';

  @override
  String get onbSlide4Badge => 'Data dina alat';

  @override
  String get onbPrivacyHeadline => 'Privasi jeung offline kajaga';

  @override
  String get onbPrivacyDetail =>
      'Sadaya data disimpen aman dina alat anjeun, taya palacak.';

  @override
  String get loadingLabel => 'Ngamuat…';

  @override
  String get homeActivePet => 'Sato aktip';

  @override
  String get homeNoPets => 'Teu acan aya sato. Tambihkeun profil heula.';

  @override
  String get homeDueSoon => 'Wayahna & énggal';

  @override
  String get homeNoDue => 'Teu aya jadwal nu mendesak.';

  @override
  String get homeAllPets => 'Sadaya sato';

  @override
  String get actionAddPet => 'Tambahkeun sato';

  @override
  String get actionAddSchedule => 'Tambahkeun jadwal';

  @override
  String get actionAddVet => 'Catet dokter';

  @override
  String get actionAddWeight => 'Catet beurat';

  @override
  String get actionAddDoc => 'Tambahkeun surat';

  @override
  String get actionSave => 'Simpen';

  @override
  String get actionCancel => 'Bolaykeun';

  @override
  String get speciesDog => 'Anjing';

  @override
  String get speciesCat => 'Ucing';

  @override
  String get speciesBird => 'Manuk';

  @override
  String get speciesRabbit => 'Kelenci';

  @override
  String get speciesOther => 'Lianna';

  @override
  String get fieldPetName => 'Ngaran';

  @override
  String get fieldSpecies => 'Jenis';

  @override
  String get fieldBreed => 'Turunan';

  @override
  String get fieldWeightKg => 'Beurat (kg)';

  @override
  String get fieldTitle => 'Judul';

  @override
  String get fieldIntervalMonths => 'Sela waktu (bulan)';

  @override
  String get fieldClinic => 'Tempat dokter';

  @override
  String get fieldMedication => 'Ubar';

  @override
  String get careSchedulesTitle => 'Jadwal miara';

  @override
  String get vetLogsTitle => 'Kadatangan & ubar';

  @override
  String get careEmptySchedules => 'Teu acan aya jadwal.';

  @override
  String get careEmptyVet => 'Teu acan aya catetan dokter.';

  @override
  String get careVaccine => 'Vaksin';

  @override
  String get careDeworm => 'Ubar cacing';

  @override
  String get careFlea => 'Kutu jeung caplak';

  @override
  String get careGrooming => 'Ngarawat bulu';

  @override
  String get careOther => 'Lianna';

  @override
  String everyMonths(int months) {
    return 'unggal $months bulan';
  }

  @override
  String daysRemaining(int days) {
    return '$days poé deui';
  }

  @override
  String get urgencyOverdue => 'Kaliwat';

  @override
  String get dailyQuickAdd => 'Catet gancang';

  @override
  String get dailyTimeline => 'Garis waktu';

  @override
  String get dailyEmpty => 'Teu acan aya catetan sapopoé.';

  @override
  String get dailyFeed => 'Dahar';

  @override
  String get dailyWalk => 'Leumpang';

  @override
  String get dailyLitter => 'Kotak keusik';

  @override
  String get dailyOther => 'Lianna';

  @override
  String get weightHistory => 'Riwayat beurat';

  @override
  String get docsEmpty => 'Teu acan aya surat.';

  @override
  String get docVaccineCard => 'Kartu vaksinasi';

  @override
  String get docPrescription => 'Résép dokter';

  @override
  String get docInsurance => 'Asuransi sato';

  @override
  String get docOther => 'Lianna';

  @override
  String get settingsLanguage => 'Basa';

  @override
  String get settingsPets => 'Profil sato';

  @override
  String get settingsBackup => 'Simpenan';

  @override
  String get settingsVersion => 'Vérsi';

  @override
  String get tileExportBackup => 'Kaluarkeun simpenan';

  @override
  String get tileImportBackup => 'Asupkeun simpenan';

  @override
  String get snackbarImportSuccess => 'Simpenan hasil diasupkeun';

  @override
  String get errorPetNameRequired => 'Ngaran sato sahenteuna 2 aksara';

  @override
  String get errorPetNameTooLong => 'Ngaran sato kacida panjangna';

  @override
  String get errorWeightInvalid => 'Beurat teu bener';

  @override
  String get errorMinOnePet => 'Kudu aya sahenteuna hiji profil sato';

  @override
  String get errorTitleRequired => 'Judul kedah dieusian';

  @override
  String get errorIntervalRequired => 'Sela waktu sahenteuna 1 bulan';

  @override
  String get errorBackupNotPetGo => 'Ieu surat lain simpenan PetGo';

  @override
  String get actionEditPet => 'Robih sato';

  @override
  String get actionMarkDone => 'Cirian réngsé';

  @override
  String get actionEditSchedule => 'Robih jadwal';

  @override
  String get actionEditVet => 'Robih kadatangan dokter';

  @override
  String get actionEditDoc => 'Robih surat';

  @override
  String get actionAttachFile => 'Lampirkeun surat';

  @override
  String get fieldOptional => 'Henteu wajib';

  @override
  String get fieldDateOfBirth => 'Tanggal babaran';

  @override
  String get fieldLastDone => 'Panungtungan dilakukeun';

  @override
  String get fieldCost => 'Waragad';

  @override
  String get fieldNotes => 'Catetan';

  @override
  String get fieldDate => 'Tanggal';

  @override
  String get fieldExpires => 'Bérés waktuna';

  @override
  String get docHasFile => 'Surat geus dilampirkeun';

  @override
  String get settingsReminders => 'Panginget miara';

  @override
  String get settingsRemindersSubtitle => 'Béjakeun saméméh jadwal wayahna';
}
