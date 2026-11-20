// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PetGo';

  @override
  String get appTagline => 'Pet profiles, care schedules & daily logs';

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
      'Track pet profiles, vaccine and deworming schedules, vet visits, and daily care — all offline.\n\nNo account. Your data never leaves your device.';

  @override
  String get onboardingContinue => 'Got it — continue';

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbNext => 'Next';

  @override
  String get onbGetStarted => 'Get started';

  @override
  String get onbSlide1Title => 'Pet profiles';

  @override
  String get onbSlide1Sub => 'Dogs, cats, and more';

  @override
  String get onbSlide1Badge => '100% offline & private';

  @override
  String get onbSlide2Title => 'Care schedules';

  @override
  String get onbSlide2Sub => 'Vaccines, deworming, fleas, and grooming';

  @override
  String get onbSlide2Badge => 'Local reminders';

  @override
  String get onbSlide3Title => 'Daily log';

  @override
  String get onbSlide3Sub => 'Meals, walks, and litter';

  @override
  String get onbSlide3Badge => 'No ads, no account';

  @override
  String get onbSlide4Title => 'Local documents';

  @override
  String get onbSlide4Sub => 'Vaccine cards and prescriptions, kept tidy';

  @override
  String get onbSlide4Badge => 'Data on your device';

  @override
  String get onbPrivacyHeadline => 'Private & offline';

  @override
  String get onbPrivacyDetail =>
      'Everything stays safely on your device — no trackers, no cloud.';

  @override
  String get loadingLabel => 'Loading…';

  @override
  String get homeActivePet => 'Active pet';

  @override
  String get homeNoPets => 'No pets yet. Add a profile first.';

  @override
  String get homeDueSoon => 'Due soon';

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
  String get careDeworm => 'Deworming';

  @override
  String get careFlea => 'Fleas & ticks';

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
  String get dailyFeed => 'Meal';

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
  String get errorBackupNotPetGo => 'This file isn\'t a PetGo backup';

  @override
  String get actionEditPet => 'Edit pet';

  @override
  String get actionMarkDone => 'Mark done';

  @override
  String get actionEditSchedule => 'Edit schedule';

  @override
  String get actionEditVet => 'Edit vet visit';

  @override
  String get actionEditDoc => 'Edit document';

  @override
  String get actionAttachFile => 'Attach file';

  @override
  String get fieldOptional => 'Optional';

  @override
  String get fieldDateOfBirth => 'Date of birth';

  @override
  String get fieldLastDone => 'Last done';

  @override
  String get fieldCost => 'Cost';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldExpires => 'Expires';

  @override
  String get docHasFile => 'File attached';

  @override
  String get settingsReminders => 'Care reminders';

  @override
  String get settingsRemindersSubtitle =>
      'Notify you before schedules fall due';

  @override
  String get commercialContactTitle => 'Commercial use';

  @override
  String get commercialContactDesc =>
      'Need a commercial license, white-label, or customization? Get in touch.';

  @override
  String get acquireAppTitle => 'Acquire this app';

  @override
  String get acquireAppDesc =>
      'Interested in acquiring this app, including source code and assets? Let\'s talk.';

  @override
  String get contactEmailCopied => 'Email address copied: contact@faishal.id';

  @override
  String get licenseUsageTitle => 'Usage License';

  @override
  String get licenseUsageNotice => 'Free for personal and non-profit use.';

  @override
  String get licenseBadgeText => 'Personal & Non-Profit';

  @override
  String dialogDeletePetTitle(String petName) {
    return 'Delete $petName?';
  }

  @override
  String dialogDeletePetMessage(String petName, int count) {
    return 'Delete $petName and $count associated records? This cannot be undone.';
  }

  @override
  String get dialogDeleteRecordTitle => 'Delete record?';

  @override
  String get dialogDeleteRecordMessage =>
      'Are you sure you want to delete this record?';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionUndo => 'Undo';

  @override
  String get snackbarDeleted => 'Deleted';

  @override
  String get snackbarRecordDeleted => 'Record deleted';

  @override
  String get snackbarDailyLogDeleted => 'Daily log deleted';

  @override
  String snackbarScheduleDone(String title) {
    return '$title marked done';
  }

  @override
  String snackbarQuickLogDone(String label) {
    return '$label logged';
  }

  @override
  String get snackbarSaved => 'Saved successfully';

  @override
  String fieldTotalCost(String cost) {
    return 'Total vet cost: $cost';
  }

  @override
  String get errorCostInvalid => 'Invalid cost amount';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get notificationPermissionTitle => 'Care Reminders';

  @override
  String get notificationPermissionMessage =>
      'PetGo needs notification permission to remind you about vaccine and care schedules on time.';

  @override
  String get actionAllow => 'Allow';

  @override
  String get actionNotNow => 'Not now';

  @override
  String get notificationPermissionDenied =>
      'Notification permission denied. You can enable it in device settings.';
}
