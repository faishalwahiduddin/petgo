import '../../l10n/app_localizations.dart';

String mapPetError(String? code, AppLocalizations l10n) {
  if (code == null) return '';
  return switch (code) {
    'errorPetNameRequired' => l10n.errorPetNameRequired,
    'errorPetNameTooLong' => l10n.errorPetNameTooLong,
    'errorWeightInvalid' => l10n.errorWeightInvalid,
    'errorMinOnePet' => l10n.errorMinOnePet,
    'errorTitleRequired' => l10n.errorTitleRequired,
    'errorIntervalRequired' => l10n.errorIntervalRequired,
    'errorBackupNotPetGo' => l10n.errorBackupNotPetGo,
    _ => code,
  };
}
