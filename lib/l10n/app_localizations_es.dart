// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'PetGo';

  @override
  String get appTagline =>
      'Perfiles de mascotas, planes de cuidado y registros diarios';

  @override
  String get navPets => 'Mascotas';

  @override
  String get navCare => 'Cuidados';

  @override
  String get navDaily => 'Diario';

  @override
  String get navDocs => 'Documentos';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get onboardingHeadline => 'PetGo';

  @override
  String get onboardingDescription =>
      'Gestiona los perfiles de tus mascotas, los calendarios de vacunas y desparasitación, las visitas al veterinario y el cuidado diario, todo sin conexión en tu dispositivo.\n\nSin cuenta. Los datos se quedan en tu dispositivo.';

  @override
  String get onboardingContinue => 'Entendido — continuar';

  @override
  String get onbSkip => 'Omitir';

  @override
  String get onbNext => 'Siguiente';

  @override
  String get onbGetStarted => 'Empezar';

  @override
  String get onbSlide1Title => 'Perfiles de mascotas';

  @override
  String get onbSlide1Sub => 'Perros, gatos y más';

  @override
  String get onbSlide1Badge => '100 % sin conexión y privado';

  @override
  String get onbSlide2Title => 'Planes de cuidado';

  @override
  String get onbSlide2Sub => 'Vacunas, desparasitación, pulgas y peluquería';

  @override
  String get onbSlide2Badge => 'Recordatorios locales';

  @override
  String get onbSlide3Title => 'Registro diario';

  @override
  String get onbSlide3Sub => 'Comida, paseos y arenero';

  @override
  String get onbSlide3Badge => 'Sin anuncios y sin cuenta';

  @override
  String get onbSlide4Title => 'Documentos locales';

  @override
  String get onbSlide4Sub => 'Cartillas de vacunas y recetas ordenadas';

  @override
  String get onbSlide4Badge => 'Datos en tu dispositivo';

  @override
  String get onbPrivacyHeadline => 'Privacidad y sin conexión';

  @override
  String get onbPrivacyDetail =>
      'Todos tus datos se guardan de forma segura en tu dispositivo, sin rastreadores.';

  @override
  String get loadingLabel => 'Cargando…';

  @override
  String get homeActivePet => 'Mascota activa';

  @override
  String get homeNoPets => 'Aún no hay mascotas. Añade un perfil primero.';

  @override
  String get homeDueSoon => 'Próximo y pendiente';

  @override
  String get homeNoDue => 'Nada urgente.';

  @override
  String get homeAllPets => 'Todas las mascotas';

  @override
  String get actionAddPet => 'Añadir mascota';

  @override
  String get actionAddSchedule => 'Añadir plan';

  @override
  String get actionAddVet => 'Registrar visita';

  @override
  String get actionAddWeight => 'Registrar peso';

  @override
  String get actionAddDoc => 'Añadir documento';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get speciesDog => 'Perro';

  @override
  String get speciesCat => 'Gato';

  @override
  String get speciesBird => 'Pájaro';

  @override
  String get speciesRabbit => 'Conejo';

  @override
  String get speciesOther => 'Otro';

  @override
  String get fieldPetName => 'Nombre';

  @override
  String get fieldSpecies => 'Especie';

  @override
  String get fieldBreed => 'Raza';

  @override
  String get fieldWeightKg => 'Peso (kg)';

  @override
  String get fieldTitle => 'Título';

  @override
  String get fieldIntervalMonths => 'Intervalo (meses)';

  @override
  String get fieldClinic => 'Clínica';

  @override
  String get fieldMedication => 'Medicamento';

  @override
  String get careSchedulesTitle => 'Planes de cuidado';

  @override
  String get vetLogsTitle => 'Visitas y medicación';

  @override
  String get careEmptySchedules => 'Aún no hay planes.';

  @override
  String get careEmptyVet => 'Aún no hay visitas registradas.';

  @override
  String get careVaccine => 'Vacuna';

  @override
  String get careDeworm => 'Desparasitación';

  @override
  String get careFlea => 'Pulgas';

  @override
  String get careGrooming => 'Peluquería';

  @override
  String get careOther => 'Otro';

  @override
  String everyMonths(int months) {
    return 'cada $months meses';
  }

  @override
  String daysRemaining(int days) {
    return 'quedan $days días';
  }

  @override
  String get urgencyOverdue => 'Atrasado';

  @override
  String get dailyQuickAdd => 'Registro rápido';

  @override
  String get dailyTimeline => 'Cronología';

  @override
  String get dailyEmpty => 'Aún no hay registros diarios.';

  @override
  String get dailyFeed => 'Comida';

  @override
  String get dailyWalk => 'Paseo';

  @override
  String get dailyLitter => 'Arenero';

  @override
  String get dailyOther => 'Otro';

  @override
  String get weightHistory => 'Historial de peso';

  @override
  String get docsEmpty => 'Aún no hay documentos.';

  @override
  String get docVaccineCard => 'Cartilla de vacunas';

  @override
  String get docPrescription => 'Receta';

  @override
  String get docInsurance => 'Seguro';

  @override
  String get docOther => 'Otro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsPets => 'Perfiles de mascotas';

  @override
  String get settingsBackup => 'Copia de seguridad';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get tileExportBackup => 'Exportar copia';

  @override
  String get tileImportBackup => 'Importar copia';

  @override
  String get snackbarImportSuccess => 'Copia importada';

  @override
  String get errorPetNameRequired =>
      'El nombre debe tener al menos 2 caracteres';

  @override
  String get errorPetNameTooLong => 'El nombre es demasiado largo';

  @override
  String get errorWeightInvalid => 'Peso no válido';

  @override
  String get errorMinOnePet => 'Conserva al menos un perfil de mascota';

  @override
  String get errorTitleRequired => 'El título es obligatorio';

  @override
  String get errorIntervalRequired => 'El intervalo debe ser de al menos 1 mes';

  @override
  String get errorBackupNotPetGo => 'El archivo no es una copia de PetGo';

  @override
  String get actionEditPet => 'Editar mascota';

  @override
  String get actionMarkDone => 'Marcar como hecho';

  @override
  String get actionEditSchedule => 'Editar plan';

  @override
  String get actionEditVet => 'Editar visita';

  @override
  String get actionEditDoc => 'Editar documento';

  @override
  String get actionAttachFile => 'Adjuntar archivo';

  @override
  String get fieldOptional => 'Opcional';

  @override
  String get fieldDateOfBirth => 'Fecha de nacimiento';

  @override
  String get fieldLastDone => 'Última vez';

  @override
  String get fieldCost => 'Coste';

  @override
  String get fieldNotes => 'Notas';

  @override
  String get fieldDate => 'Fecha';

  @override
  String get fieldExpires => 'Caduca';

  @override
  String get docHasFile => 'Archivo adjunto';

  @override
  String get settingsReminders => 'Recordatorios de cuidado';

  @override
  String get settingsRemindersSubtitle => 'Avisar antes de que venza cada plan';
}
