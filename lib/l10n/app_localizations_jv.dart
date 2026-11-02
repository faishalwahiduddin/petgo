// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Javanese (`jv`).
class AppLocalizationsJv extends AppLocalizations {
  AppLocalizationsJv([String locale = 'jv']) : super(locale);

  @override
  String get appTitle => 'PetGo';

  @override
  String get appTagline => 'Profil kewan, jadwal rumatan & cathetan padinan';

  @override
  String get navPets => 'Kewan';

  @override
  String get navCare => 'Ngrumat';

  @override
  String get navDaily => 'Padinan';

  @override
  String get navDocs => 'Layang';

  @override
  String get navSettings => 'Pangaturan';

  @override
  String get onboardingHeadline => 'PetGo';

  @override
  String get onboardingDescription =>
      'Ngatur profil kewan, jadwal vaksin lan tamba cacing, kunjungan menyang dhokter kewan, lan cathetan padinan — kabeh offline ing piranti panjenengan.\n\nTanpa akun. Data ora tau metu saka piranti.';

  @override
  String get onboardingContinue => 'Ngerti — terasna';

  @override
  String get onbSkip => 'Liwati';

  @override
  String get onbNext => 'Terusake';

  @override
  String get onbGetStarted => 'Wiwiti saiki';

  @override
  String get onbSlide1Title => 'Profil kewan';

  @override
  String get onbSlide1Sub => 'Asu, kucing, lan liya-liyane';

  @override
  String get onbSlide1Badge => '100% offline lan ora dilacak';

  @override
  String get onbSlide2Title => 'Jadwal rumatan';

  @override
  String get onbSlide2Sub => 'Vaksin, tamba cacing, kutu, lan rawat wulu';

  @override
  String get onbSlide2Badge => 'Pangeling lokal';

  @override
  String get onbSlide3Title => 'Cathetan padinan';

  @override
  String get onbSlide3Sub => 'Mangan, mlaku-mlaku, lan kothak pasir';

  @override
  String get onbSlide3Badge => 'Ora ana iklan lan ora perlu akun';

  @override
  String get onbSlide4Title => 'Layang lokal';

  @override
  String get onbSlide4Sub => 'Kertu vaksin lan resep disimpen rapi';

  @override
  String get onbSlide4Badge => 'Data ing piranti';

  @override
  String get onbPrivacyHeadline => 'Privasi lan offline kajaga';

  @override
  String get onbPrivacyDetail =>
      'Kabeh data disimpen kanthi aman ing piranti panjenengan, ora ana pelacak.';

  @override
  String get loadingLabel => 'Ngemot…';

  @override
  String get homeActivePet => 'Kewan aktif';

  @override
  String get homeNoPets => 'Durung ana kewan. Tambahake profil dhisik.';

  @override
  String get homeDueSoon => 'Wis wayahe & enggal';

  @override
  String get homeNoDue => 'Ora ana jadwal sing meksa.';

  @override
  String get homeAllPets => 'Kabeh kewan';

  @override
  String get actionAddPet => 'Nambah kewan';

  @override
  String get actionAddSchedule => 'Nambah jadwal';

  @override
  String get actionAddVet => 'Nyathet dhokter';

  @override
  String get actionAddWeight => 'Nyathet bobot';

  @override
  String get actionAddDoc => 'Nambah layang';

  @override
  String get actionSave => 'Simpen';

  @override
  String get actionCancel => 'Ora sida';

  @override
  String get speciesDog => 'Asu';

  @override
  String get speciesCat => 'Kucing';

  @override
  String get speciesBird => 'Manuk';

  @override
  String get speciesRabbit => 'Terwelu';

  @override
  String get speciesOther => 'Liyane';

  @override
  String get fieldPetName => 'Jeneng';

  @override
  String get fieldSpecies => 'Jinis';

  @override
  String get fieldBreed => 'Turunan';

  @override
  String get fieldWeightKg => 'Bobot (kg)';

  @override
  String get fieldTitle => 'Judhul';

  @override
  String get fieldIntervalMonths => 'Sela wektu (sasi)';

  @override
  String get fieldClinic => 'Panggonan dhokter';

  @override
  String get fieldMedication => 'Tamba';

  @override
  String get careSchedulesTitle => 'Jadwal rumatan';

  @override
  String get vetLogsTitle => 'Kunjungan lan tamba';

  @override
  String get careEmptySchedules => 'Durung ana jadwal.';

  @override
  String get careEmptyVet => 'Durung ana cathetan dhokter.';

  @override
  String get careVaccine => 'Vaksin';

  @override
  String get careDeworm => 'Tamba cacing';

  @override
  String get careFlea => 'Kutu & caplak';

  @override
  String get careGrooming => 'Rawat wulu';

  @override
  String get careOther => 'Liyane';

  @override
  String everyMonths(int months) {
    return 'saben $months sasi';
  }

  @override
  String daysRemaining(int days) {
    return '$days dina maneh';
  }

  @override
  String get urgencyOverdue => 'Keliwat';

  @override
  String get dailyQuickAdd => 'Cathet cepet';

  @override
  String get dailyTimeline => 'Garis wektu';

  @override
  String get dailyEmpty => 'Durung ana cathetan padinan.';

  @override
  String get dailyFeed => 'Mangan';

  @override
  String get dailyWalk => 'Mlaku-mlaku';

  @override
  String get dailyLitter => 'Kothak pasir';

  @override
  String get dailyOther => 'Liyane';

  @override
  String get weightHistory => 'Riwayat bobot';

  @override
  String get docsEmpty => 'Durung ana layang.';

  @override
  String get docVaccineCard => 'Kertu vaksin';

  @override
  String get docPrescription => 'Resep dhokter';

  @override
  String get docInsurance => 'Asuransi kewan';

  @override
  String get docOther => 'Liyane';

  @override
  String get settingsLanguage => 'Basa';

  @override
  String get settingsPets => 'Profil kewan';

  @override
  String get settingsBackup => 'Simpenan';

  @override
  String get settingsVersion => 'Versi';

  @override
  String get tileExportBackup => 'Metuake simpenan';

  @override
  String get tileImportBackup => 'Mlebuake simpenan';

  @override
  String get snackbarImportSuccess => 'Simpenan kasil dilebokake';

  @override
  String get errorPetNameRequired => 'Jeneng kewan paling sithik 2 aksara';

  @override
  String get errorPetNameTooLong => 'Jeneng kewan kebangeten dawa';

  @override
  String get errorWeightInvalid => 'Bobot ora bener';

  @override
  String get errorMinOnePet => 'Kudu ana paling sithik siji profil kewan';

  @override
  String get errorTitleRequired => 'Judhul kudu diisi';

  @override
  String get errorIntervalRequired => 'Sela wektu paling sithik 1 sasi';

  @override
  String get errorBackupNotPetGo => 'Layang iki dudu simpenan PetGo';

  @override
  String get actionEditPet => 'Owahi kewan';

  @override
  String get actionMarkDone => 'Tandhani rampung';

  @override
  String get actionEditSchedule => 'Owahi jadwal';

  @override
  String get actionEditVet => 'Owahi kunjungan dhokter';

  @override
  String get actionEditDoc => 'Owahi layang';

  @override
  String get actionAttachFile => 'Lampirake layang';

  @override
  String get fieldOptional => 'Ora wajib';

  @override
  String get fieldDateOfBirth => 'Tanggal lair';

  @override
  String get fieldLastDone => 'Pungkasan ditindakake';

  @override
  String get fieldCost => 'Ragad';

  @override
  String get fieldNotes => 'Cathetan';

  @override
  String get fieldDate => 'Tanggal';

  @override
  String get fieldExpires => 'Entek wektune';

  @override
  String get docHasFile => 'Layang wis dilampirake';

  @override
  String get settingsReminders => 'Pangeling rumatan';

  @override
  String get settingsRemindersSubtitle => 'Kabarake sadurunge jadwal wayahe';
}
