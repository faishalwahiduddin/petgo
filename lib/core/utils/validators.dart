import '../constants/app_constants.dart';

class Validators {
  static String? validatePetName(String? name) {
    final trimmed = name?.trim() ?? '';
    if (trimmed.length < AppConstants.minPetNameLength) {
      return 'errorPetNameRequired';
    }
    if (trimmed.length > AppConstants.maxPetNameLength) {
      return 'errorPetNameTooLong';
    }
    return null;
  }

  static String? validateWeight(double? kg) {
    if (kg == null) return null;
    if (kg <= 0 || kg > AppConstants.maxWeightKg) {
      return 'errorWeightInvalid';
    }
    return null;
  }
}
