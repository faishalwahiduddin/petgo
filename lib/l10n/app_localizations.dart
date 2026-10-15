import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_jv.dart';
import 'app_localizations_su.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('id'),
    Locale('ja'),
    Locale('jv'),
    Locale('su'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'PetGo'**
  String get appTitle;

  /// No description provided for @navPets.
  ///
  /// In id, this message translates to:
  /// **'Hewan'**
  String get navPets;

  /// No description provided for @navCare.
  ///
  /// In id, this message translates to:
  /// **'Perawatan'**
  String get navCare;

  /// No description provided for @navDaily.
  ///
  /// In id, this message translates to:
  /// **'Harian'**
  String get navDaily;

  /// No description provided for @navDocs.
  ///
  /// In id, this message translates to:
  /// **'Dokumen'**
  String get navDocs;

  /// No description provided for @navSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get navSettings;

  /// No description provided for @onboardingHeadline.
  ///
  /// In id, this message translates to:
  /// **'PetGo'**
  String get onboardingHeadline;

  /// No description provided for @onboardingDescription.
  ///
  /// In id, this message translates to:
  /// **'Kelola profil hewan, jadwal vaksin/cacing, kunjungan vet, dan log harian secara offline di perangkat Anda.\n\nTanpa akun. Data tersimpan lokal.'**
  String get onboardingDescription;

  /// No description provided for @onboardingContinue.
  ///
  /// In id, this message translates to:
  /// **'Saya mengerti — lanjut'**
  String get onboardingContinue;

  /// No description provided for @homeActivePet.
  ///
  /// In id, this message translates to:
  /// **'Hewan aktif'**
  String get homeActivePet;

  /// No description provided for @homeNoPets.
  ///
  /// In id, this message translates to:
  /// **'Belum ada hewan. Tambahkan profil dulu.'**
  String get homeNoPets;

  /// No description provided for @homeDueSoon.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo / segera'**
  String get homeDueSoon;

  /// No description provided for @homeNoDue.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada jadwal mendesak.'**
  String get homeNoDue;

  /// No description provided for @homeAllPets.
  ///
  /// In id, this message translates to:
  /// **'Semua hewan'**
  String get homeAllPets;

  /// No description provided for @actionAddPet.
  ///
  /// In id, this message translates to:
  /// **'Tambah hewan'**
  String get actionAddPet;

  /// No description provided for @actionAddSchedule.
  ///
  /// In id, this message translates to:
  /// **'Tambah jadwal'**
  String get actionAddSchedule;

  /// No description provided for @actionAddVet.
  ///
  /// In id, this message translates to:
  /// **'Catat vet'**
  String get actionAddVet;

  /// No description provided for @actionAddWeight.
  ///
  /// In id, this message translates to:
  /// **'Catat berat'**
  String get actionAddWeight;

  /// No description provided for @actionAddDoc.
  ///
  /// In id, this message translates to:
  /// **'Tambah dokumen'**
  String get actionAddDoc;

  /// No description provided for @actionSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get actionCancel;

  /// No description provided for @speciesDog.
  ///
  /// In id, this message translates to:
  /// **'Anjing'**
  String get speciesDog;

  /// No description provided for @speciesCat.
  ///
  /// In id, this message translates to:
  /// **'Kucing'**
  String get speciesCat;

  /// No description provided for @speciesBird.
  ///
  /// In id, this message translates to:
  /// **'Burung'**
  String get speciesBird;

  /// No description provided for @speciesRabbit.
  ///
  /// In id, this message translates to:
  /// **'Kelinci'**
  String get speciesRabbit;

  /// No description provided for @speciesOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get speciesOther;

  /// No description provided for @fieldPetName.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get fieldPetName;

  /// No description provided for @fieldSpecies.
  ///
  /// In id, this message translates to:
  /// **'Spesies'**
  String get fieldSpecies;

  /// No description provided for @fieldBreed.
  ///
  /// In id, this message translates to:
  /// **'Ras'**
  String get fieldBreed;

  /// No description provided for @fieldWeightKg.
  ///
  /// In id, this message translates to:
  /// **'Berat (kg)'**
  String get fieldWeightKg;

  /// No description provided for @fieldTitle.
  ///
  /// In id, this message translates to:
  /// **'Judul'**
  String get fieldTitle;

  /// No description provided for @fieldIntervalMonths.
  ///
  /// In id, this message translates to:
  /// **'Interval (bulan)'**
  String get fieldIntervalMonths;

  /// No description provided for @fieldClinic.
  ///
  /// In id, this message translates to:
  /// **'Klinik'**
  String get fieldClinic;

  /// No description provided for @fieldMedication.
  ///
  /// In id, this message translates to:
  /// **'Obat'**
  String get fieldMedication;

  /// No description provided for @careSchedulesTitle.
  ///
  /// In id, this message translates to:
  /// **'Jadwal perawatan'**
  String get careSchedulesTitle;

  /// No description provided for @vetLogsTitle.
  ///
  /// In id, this message translates to:
  /// **'Kunjungan & obat'**
  String get vetLogsTitle;

  /// No description provided for @careEmptySchedules.
  ///
  /// In id, this message translates to:
  /// **'Belum ada jadwal.'**
  String get careEmptySchedules;

  /// No description provided for @careEmptyVet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada catatan vet.'**
  String get careEmptyVet;

  /// No description provided for @careVaccine.
  ///
  /// In id, this message translates to:
  /// **'Vaksin'**
  String get careVaccine;

  /// No description provided for @careDeworm.
  ///
  /// In id, this message translates to:
  /// **'Obat cacing'**
  String get careDeworm;

  /// No description provided for @careFlea.
  ///
  /// In id, this message translates to:
  /// **'Kutu / flea'**
  String get careFlea;

  /// No description provided for @careGrooming.
  ///
  /// In id, this message translates to:
  /// **'Grooming'**
  String get careGrooming;

  /// No description provided for @careOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get careOther;

  /// No description provided for @everyMonths.
  ///
  /// In id, this message translates to:
  /// **'tiap {months} bln'**
  String everyMonths(int months);

  /// No description provided for @daysRemaining.
  ///
  /// In id, this message translates to:
  /// **'{days} hari lagi'**
  String daysRemaining(int days);

  /// No description provided for @urgencyOverdue.
  ///
  /// In id, this message translates to:
  /// **'Terlewat'**
  String get urgencyOverdue;

  /// No description provided for @dailyQuickAdd.
  ///
  /// In id, this message translates to:
  /// **'Catat cepat'**
  String get dailyQuickAdd;

  /// No description provided for @dailyTimeline.
  ///
  /// In id, this message translates to:
  /// **'Timeline'**
  String get dailyTimeline;

  /// No description provided for @dailyEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada log harian.'**
  String get dailyEmpty;

  /// No description provided for @dailyFeed.
  ///
  /// In id, this message translates to:
  /// **'Makan'**
  String get dailyFeed;

  /// No description provided for @dailyWalk.
  ///
  /// In id, this message translates to:
  /// **'Jalan'**
  String get dailyWalk;

  /// No description provided for @dailyLitter.
  ///
  /// In id, this message translates to:
  /// **'Litter'**
  String get dailyLitter;

  /// No description provided for @dailyOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get dailyOther;

  /// No description provided for @weightHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat berat'**
  String get weightHistory;

  /// No description provided for @docsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada dokumen.'**
  String get docsEmpty;

  /// No description provided for @docVaccineCard.
  ///
  /// In id, this message translates to:
  /// **'Kartu vaksin'**
  String get docVaccineCard;

  /// No description provided for @docPrescription.
  ///
  /// In id, this message translates to:
  /// **'Resep'**
  String get docPrescription;

  /// No description provided for @docInsurance.
  ///
  /// In id, this message translates to:
  /// **'Asuransi'**
  String get docInsurance;

  /// No description provided for @docOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get docOther;

  /// No description provided for @settingsLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get settingsLanguage;

  /// No description provided for @settingsPets.
  ///
  /// In id, this message translates to:
  /// **'Profil hewan'**
  String get settingsPets;

  /// No description provided for @settingsBackup.
  ///
  /// In id, this message translates to:
  /// **'Cadangan'**
  String get settingsBackup;

  /// No description provided for @settingsVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi'**
  String get settingsVersion;

  /// No description provided for @tileExportBackup.
  ///
  /// In id, this message translates to:
  /// **'Ekspor cadangan'**
  String get tileExportBackup;

  /// No description provided for @tileImportBackup.
  ///
  /// In id, this message translates to:
  /// **'Impor cadangan'**
  String get tileImportBackup;

  /// No description provided for @snackbarImportSuccess.
  ///
  /// In id, this message translates to:
  /// **'Cadangan berhasil diimpor'**
  String get snackbarImportSuccess;

  /// No description provided for @errorPetNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama hewan minimal 2 karakter'**
  String get errorPetNameRequired;

  /// No description provided for @errorPetNameTooLong.
  ///
  /// In id, this message translates to:
  /// **'Nama hewan terlalu panjang'**
  String get errorPetNameTooLong;

  /// No description provided for @errorWeightInvalid.
  ///
  /// In id, this message translates to:
  /// **'Berat tidak valid'**
  String get errorWeightInvalid;

  /// No description provided for @errorMinOnePet.
  ///
  /// In id, this message translates to:
  /// **'Minimal satu profil hewan'**
  String get errorMinOnePet;

  /// No description provided for @errorTitleRequired.
  ///
  /// In id, this message translates to:
  /// **'Judul wajib diisi'**
  String get errorTitleRequired;

  /// No description provided for @errorIntervalRequired.
  ///
  /// In id, this message translates to:
  /// **'Interval minimal 1 bulan'**
  String get errorIntervalRequired;

  /// No description provided for @errorBackupNotPetGo.
  ///
  /// In id, this message translates to:
  /// **'Berkas bukan cadangan PetGo'**
  String get errorBackupNotPetGo;

  /// No description provided for @actionEditPet.
  ///
  /// In id, this message translates to:
  /// **'Edit hewan'**
  String get actionEditPet;

  /// No description provided for @actionMarkDone.
  ///
  /// In id, this message translates to:
  /// **'Tandai selesai'**
  String get actionMarkDone;

  /// No description provided for @actionEditSchedule.
  ///
  /// In id, this message translates to:
  /// **'Edit jadwal'**
  String get actionEditSchedule;

  /// No description provided for @actionEditVet.
  ///
  /// In id, this message translates to:
  /// **'Edit kunjungan vet'**
  String get actionEditVet;

  /// No description provided for @actionEditDoc.
  ///
  /// In id, this message translates to:
  /// **'Edit dokumen'**
  String get actionEditDoc;

  /// No description provided for @actionAttachFile.
  ///
  /// In id, this message translates to:
  /// **'Lampirkan berkas'**
  String get actionAttachFile;

  /// No description provided for @fieldOptional.
  ///
  /// In id, this message translates to:
  /// **'Opsional'**
  String get fieldOptional;

  /// No description provided for @fieldDateOfBirth.
  ///
  /// In id, this message translates to:
  /// **'Tanggal lahir'**
  String get fieldDateOfBirth;

  /// No description provided for @fieldLastDone.
  ///
  /// In id, this message translates to:
  /// **'Terakhir dikerjakan'**
  String get fieldLastDone;

  /// No description provided for @fieldCost.
  ///
  /// In id, this message translates to:
  /// **'Biaya'**
  String get fieldCost;

  /// No description provided for @fieldNotes.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get fieldNotes;

  /// No description provided for @fieldDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get fieldDate;

  /// No description provided for @fieldExpires.
  ///
  /// In id, this message translates to:
  /// **'Kedaluwarsa'**
  String get fieldExpires;

  /// No description provided for @docHasFile.
  ///
  /// In id, this message translates to:
  /// **'Berkas terlampir'**
  String get docHasFile;

  /// No description provided for @settingsReminders.
  ///
  /// In id, this message translates to:
  /// **'Pengingat perawatan'**
  String get settingsReminders;

  /// No description provided for @settingsRemindersSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Beritahu sebelum jadwal jatuh tempo'**
  String get settingsRemindersSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'id',
    'ja',
    'jv',
    'su',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'jv':
      return AppLocalizationsJv();
    case 'su':
      return AppLocalizationsSu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
