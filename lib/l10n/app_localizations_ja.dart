// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'PetGo';

  @override
  String get navPets => 'Pets';

  @override
  String get navCare => 'Care';

  @override
  String get navDaily => 'Daily';

  @override
  String get navDocs => 'Docs';

  @override
  String get navSettings => 'Settings';

  @override
  String get onboardingHeadline => 'PetGo';

  @override
  String get onboardingDescription =>
      'Manage pet profiles, vaccine/deworm schedules, vet visits, and daily care offline on your device.\n\nNo account. Data stays local.';

  @override
  String get onboardingContinue => 'I understand — continue';

  @override
  String get homeActivePet => 'Active pet';

  @override
  String get homeNoPets => 'No pets yet. Add a profile first.';

  @override
  String get homeDueSoon => 'Due / soon';

  @override
  String get homeNoDue => 'Nothing urgent.';

  @override
  String get homeAllPets => 'All pets';

  @override
  String get actionAddPet => 'Add pet';

  @override
  String get actionAddSchedule => 'Add schedule';

  @override
  String get actionAddVet => 'Log vet visit';

  @override
  String get actionAddWeight => 'Log weight';

  @override
  String get actionAddDoc => 'Add document';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get speciesDog => 'Dog';

  @override
  String get speciesCat => 'Cat';

  @override
  String get speciesBird => 'Bird';

  @override
  String get speciesRabbit => 'Rabbit';

  @override
  String get speciesOther => 'Other';

  @override
  String get fieldPetName => 'Name';

  @override
  String get fieldSpecies => 'Species';

  @override
  String get fieldBreed => 'Breed';

  @override
  String get fieldWeightKg => 'Weight (kg)';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldIntervalMonths => 'Interval (months)';

  @override
  String get fieldClinic => 'Clinic';

  @override
  String get fieldMedication => 'Medication';

  @override
  String get careSchedulesTitle => 'Care schedules';

  @override
  String get vetLogsTitle => 'Vet & meds';

  @override
  String get careEmptySchedules => 'No schedules yet.';

  @override
  String get careEmptyVet => 'No vet logs yet.';

  @override
  String get careVaccine => 'Vaccine';

  @override
  String get careDeworm => 'Deworm';

  @override
  String get careFlea => 'Flea';

  @override
  String get careGrooming => 'Grooming';

  @override
  String get careOther => 'Other';

  @override
  String everyMonths(int months) {
    return 'every $months mo';
  }

  @override
  String daysRemaining(int days) {
    return '$days days left';
  }

  @override
  String get urgencyOverdue => 'Overdue';

  @override
  String get dailyQuickAdd => 'Quick log';

  @override
  String get dailyTimeline => 'Timeline';

  @override
  String get dailyEmpty => 'No daily logs yet.';

  @override
  String get dailyFeed => 'Feed';

  @override
  String get dailyWalk => 'Walk';

  @override
  String get dailyLitter => 'Litter';

  @override
  String get dailyOther => 'Other';

  @override
  String get weightHistory => 'Weight history';

  @override
  String get docsEmpty => 'No documents yet.';

  @override
  String get docVaccineCard => 'Vaccine card';

  @override
  String get docPrescription => 'Prescription';

  @override
  String get docInsurance => 'Insurance';

  @override
  String get docOther => 'Other';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsPets => 'Pet profiles';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsVersion => 'Version';

  @override
  String get tileExportBackup => 'Export backup';

  @override
  String get tileImportBackup => 'Import backup';

  @override
  String get snackbarImportSuccess => 'Backup imported';

  @override
  String get errorPetNameRequired => 'Pet name needs at least 2 characters';

  @override
  String get errorPetNameTooLong => 'Pet name is too long';

  @override
  String get errorWeightInvalid => 'Invalid weight';

  @override
  String get errorMinOnePet => 'Keep at least one pet profile';

  @override
  String get errorTitleRequired => 'Title is required';

  @override
  String get errorIntervalRequired => 'Interval must be at least 1 month';

  @override
  String get errorBackupNotPetGo => 'File is not a PetGo backup';
}
