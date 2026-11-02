// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'PetGo';

  @override
  String get appTagline => 'ملفات الحيوانات وجداول الرعاية والسجلات اليومية';

  @override
  String get navPets => 'الحيوانات';

  @override
  String get navCare => 'الرعاية';

  @override
  String get navDaily => 'اليوميات';

  @override
  String get navDocs => 'المستندات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get onboardingHeadline => 'PetGo';

  @override
  String get onboardingDescription =>
      'نظّم ملفات حيواناتك الأليفة وجداول التطعيم ومكافحة الديدان وزيارات الطبيب البيطري والرعاية اليومية، كل ذلك دون اتصال على جهازك.\n\nبلا حساب. تبقى بياناتك على جهازك.';

  @override
  String get onboardingContinue => 'فهمت — تابع';

  @override
  String get onbSkip => 'تخطٍّ';

  @override
  String get onbNext => 'التالي';

  @override
  String get onbGetStarted => 'ابدأ الآن';

  @override
  String get onbSlide1Title => 'ملفات الحيوانات';

  @override
  String get onbSlide1Sub => 'كلاب وقطط وأكثر';

  @override
  String get onbSlide1Badge => '‏100% دون اتصال وخاصة';

  @override
  String get onbSlide2Title => 'جداول الرعاية';

  @override
  String get onbSlide2Sub => 'تطعيم ومكافحة ديدان وبراغيث وتنظيف';

  @override
  String get onbSlide2Badge => 'تذكير محلي';

  @override
  String get onbSlide3Title => 'السجل اليومي';

  @override
  String get onbSlide3Sub => 'طعام وتنزه وفراش';

  @override
  String get onbSlide3Badge => 'بلا إعلانات وبلا حساب';

  @override
  String get onbSlide4Title => 'مستندات على الجهاز';

  @override
  String get onbSlide4Sub => 'بطاقات التطعيم والوصفات مرتبة';

  @override
  String get onbSlide4Badge => 'البيانات على جهازك';

  @override
  String get onbPrivacyHeadline => 'خصوصية دون اتصال';

  @override
  String get onbPrivacyDetail =>
      'تُحفظ جميع بياناتك بأمان على جهازك، دون أي متتبعات.';

  @override
  String get loadingLabel => 'جارٍ التحميل…';

  @override
  String get homeActivePet => 'الحيوان النشط';

  @override
  String get homeNoPets => 'لا توجد حيوانات بعد. أضف ملفًا أولًا.';

  @override
  String get homeDueSoon => 'مستحق وقريب';

  @override
  String get homeNoDue => 'لا مواعيد عاجلة.';

  @override
  String get homeAllPets => 'كل الحيوانات';

  @override
  String get actionAddPet => 'إضافة حيوان';

  @override
  String get actionAddSchedule => 'إضافة موعد';

  @override
  String get actionAddVet => 'تسجيل زيارة الطبيب';

  @override
  String get actionAddWeight => 'تسجيل الوزن';

  @override
  String get actionAddDoc => 'إضافة مستند';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get speciesDog => 'كلب';

  @override
  String get speciesCat => 'قطة';

  @override
  String get speciesBird => 'طائر';

  @override
  String get speciesRabbit => 'أرنب';

  @override
  String get speciesOther => 'أخرى';

  @override
  String get fieldPetName => 'الاسم';

  @override
  String get fieldSpecies => 'النوع';

  @override
  String get fieldBreed => 'السلالة';

  @override
  String get fieldWeightKg => 'الوزن (كغ)';

  @override
  String get fieldTitle => 'العنوان';

  @override
  String get fieldIntervalMonths => 'الفترة (أشهر)';

  @override
  String get fieldClinic => 'العيادة';

  @override
  String get fieldMedication => 'الدواء';

  @override
  String get careSchedulesTitle => 'جداول الرعاية';

  @override
  String get vetLogsTitle => 'الزيارات والأدوية';

  @override
  String get careEmptySchedules => 'لا جداول بعد.';

  @override
  String get careEmptyVet => 'لا سجلات بيطرية بعد.';

  @override
  String get careVaccine => 'تطعيم';

  @override
  String get careDeworm => 'مكافحة الديدان';

  @override
  String get careFlea => 'براغيث';

  @override
  String get careGrooming => 'تنظيف';

  @override
  String get careOther => 'أخرى';

  @override
  String everyMonths(int months) {
    return 'كل $months أشهر';
  }

  @override
  String daysRemaining(int days) {
    return 'بقي $days يومًا';
  }

  @override
  String get urgencyOverdue => 'متأخر';

  @override
  String get dailyQuickAdd => 'تسجيل سريع';

  @override
  String get dailyTimeline => 'الخط الزمني';

  @override
  String get dailyEmpty => 'لا سجلات يومية بعد.';

  @override
  String get dailyFeed => 'طعام';

  @override
  String get dailyWalk => 'تنزه';

  @override
  String get dailyLitter => 'فراش';

  @override
  String get dailyOther => 'أخرى';

  @override
  String get weightHistory => 'سجل الوزن';

  @override
  String get docsEmpty => 'لا مستندات بعد.';

  @override
  String get docVaccineCard => 'بطاقة التطعيم';

  @override
  String get docPrescription => 'وصفة طبية';

  @override
  String get docInsurance => 'تأمين';

  @override
  String get docOther => 'أخرى';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsPets => 'ملفات الحيوانات';

  @override
  String get settingsBackup => 'النسخ الاحتياطي';

  @override
  String get settingsVersion => 'الإصدار';

  @override
  String get tileExportBackup => 'تصدير نسخة احتياطية';

  @override
  String get tileImportBackup => 'استيراد نسخة احتياطية';

  @override
  String get snackbarImportSuccess => 'تم استيراد النسخة الاحتياطية';

  @override
  String get errorPetNameRequired => 'اسم الحيوان لا يقل عن حرفين';

  @override
  String get errorPetNameTooLong => 'اسم الحيوان طويل جدًا';

  @override
  String get errorWeightInvalid => 'الوزن غير صالح';

  @override
  String get errorMinOnePet => 'يجب الإبقاء على ملف حيوان واحد على الأقل';

  @override
  String get errorTitleRequired => 'العنوان مطلوب';

  @override
  String get errorIntervalRequired => 'يجب ألا تقل الفترة عن شهر واحد';

  @override
  String get errorBackupNotPetGo => 'هذا الملف ليس نسخة احتياطية من PetGo';

  @override
  String get actionEditPet => 'تعديل الحيوان';

  @override
  String get actionMarkDone => 'تحديد كمنجز';

  @override
  String get actionEditSchedule => 'تعديل الموعد';

  @override
  String get actionEditVet => 'تعديل الزيارة';

  @override
  String get actionEditDoc => 'تعديل المستند';

  @override
  String get actionAttachFile => 'إرفاق ملف';

  @override
  String get fieldOptional => 'اختياري';

  @override
  String get fieldDateOfBirth => 'تاريخ الميلاد';

  @override
  String get fieldLastDone => 'آخر تنفيذ';

  @override
  String get fieldCost => 'التكلفة';

  @override
  String get fieldNotes => 'ملاحظات';

  @override
  String get fieldDate => 'التاريخ';

  @override
  String get fieldExpires => 'ينتهي في';

  @override
  String get docHasFile => 'ملف مرفق';

  @override
  String get settingsReminders => 'تذكيرات الرعاية';

  @override
  String get settingsRemindersSubtitle => 'أشعرك قبل حلول المواعيد';
}
