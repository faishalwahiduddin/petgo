// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'PetGo';

  @override
  String get appTagline => '宠物档案、护理计划与每日记录';

  @override
  String get navPets => '宠物';

  @override
  String get navCare => '护理';

  @override
  String get navDaily => '日常';

  @override
  String get navDocs => '文档';

  @override
  String get navSettings => '设置';

  @override
  String get onboardingHeadline => 'PetGo';

  @override
  String get onboardingDescription =>
      '在设备上离线管理宠物档案、疫苗与驱虫计划、就诊记录以及日常护理。\n\n无需账号，数据只保存在本地。';

  @override
  String get onboardingContinue => '我已了解 — 继续';

  @override
  String get onbSkip => '跳过';

  @override
  String get onbNext => '下一步';

  @override
  String get onbGetStarted => '开始使用';

  @override
  String get onbSlide1Title => '宠物档案';

  @override
  String get onbSlide1Sub => '狗狗、猫咪和更多';

  @override
  String get onbSlide1Badge => '100% 离线与私密';

  @override
  String get onbSlide2Title => '护理计划';

  @override
  String get onbSlide2Sub => '疫苗、驱虫、跳蚤和美容';

  @override
  String get onbSlide2Badge => '本地提醒';

  @override
  String get onbSlide3Title => '每日记录';

  @override
  String get onbSlide3Sub => '喂食、散步和猫砂';

  @override
  String get onbSlide3Badge => '无广告，无需账号';

  @override
  String get onbSlide4Title => '本地文档';

  @override
  String get onbSlide4Sub => '疫苗卡和处方，整理有序';

  @override
  String get onbSlide4Badge => '数据保存在设备上';

  @override
  String get onbPrivacyHeadline => '隐私与离线保障';

  @override
  String get onbPrivacyDetail => '所有数据都安全保存在你的设备上，没有追踪器。';

  @override
  String get loadingLabel => '正在加载…';

  @override
  String get homeActivePet => '当前宠物';

  @override
  String get homeNoPets => '还没有宠物，请先添加档案。';

  @override
  String get homeDueSoon => '即将到期';

  @override
  String get homeNoDue => '暂无紧急事项。';

  @override
  String get homeAllPets => '全部宠物';

  @override
  String get actionAddPet => '添加宠物';

  @override
  String get actionAddSchedule => '添加计划';

  @override
  String get actionAddVet => '记录就诊';

  @override
  String get actionAddWeight => '记录体重';

  @override
  String get actionAddDoc => '添加文档';

  @override
  String get actionSave => '保存';

  @override
  String get actionCancel => '取消';

  @override
  String get speciesDog => '狗';

  @override
  String get speciesCat => '猫';

  @override
  String get speciesBird => '鸟';

  @override
  String get speciesRabbit => '兔';

  @override
  String get speciesOther => '其他';

  @override
  String get fieldPetName => '名称';

  @override
  String get fieldSpecies => '物种';

  @override
  String get fieldBreed => '品种';

  @override
  String get fieldWeightKg => '体重（kg）';

  @override
  String get fieldTitle => '标题';

  @override
  String get fieldIntervalMonths => '间隔（月）';

  @override
  String get fieldClinic => '诊所';

  @override
  String get fieldMedication => '药物';

  @override
  String get careSchedulesTitle => '护理计划';

  @override
  String get vetLogsTitle => '就诊与用药';

  @override
  String get careEmptySchedules => '还没有计划。';

  @override
  String get careEmptyVet => '还没有就诊记录。';

  @override
  String get careVaccine => '疫苗';

  @override
  String get careDeworm => '驱虫';

  @override
  String get careFlea => '跳蚤';

  @override
  String get careGrooming => '美容';

  @override
  String get careOther => '其他';

  @override
  String everyMonths(int months) {
    return '每 $months 个月';
  }

  @override
  String daysRemaining(int days) {
    return '还剩 $days 天';
  }

  @override
  String get urgencyOverdue => '已逾期';

  @override
  String get dailyQuickAdd => '快速记录';

  @override
  String get dailyTimeline => '时间线';

  @override
  String get dailyEmpty => '还没有每日记录。';

  @override
  String get dailyFeed => '喂食';

  @override
  String get dailyWalk => '散步';

  @override
  String get dailyLitter => '猫砂';

  @override
  String get dailyOther => '其他';

  @override
  String get weightHistory => '体重记录';

  @override
  String get docsEmpty => '还没有文档。';

  @override
  String get docVaccineCard => '疫苗卡';

  @override
  String get docPrescription => '处方';

  @override
  String get docInsurance => '保险';

  @override
  String get docOther => '其他';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsPets => '宠物档案';

  @override
  String get settingsBackup => '备份';

  @override
  String get settingsVersion => '版本';

  @override
  String get tileExportBackup => '导出备份';

  @override
  String get tileImportBackup => '导入备份';

  @override
  String get snackbarImportSuccess => '备份已导入';

  @override
  String get errorPetNameRequired => '宠物名称至少需要 2 个字符';

  @override
  String get errorPetNameTooLong => '宠物名称过长';

  @override
  String get errorWeightInvalid => '体重无效';

  @override
  String get errorMinOnePet => '至少保留一个宠物档案';

  @override
  String get errorTitleRequired => '请填写标题';

  @override
  String get errorIntervalRequired => '间隔至少 1 个月';

  @override
  String get errorBackupNotPetGo => '该文件不是 PetGo 备份';

  @override
  String get actionEditPet => '编辑宠物';

  @override
  String get actionMarkDone => '标记完成';

  @override
  String get actionEditSchedule => '编辑计划';

  @override
  String get actionEditVet => '编辑就诊记录';

  @override
  String get actionEditDoc => '编辑文档';

  @override
  String get actionAttachFile => '附加文件';

  @override
  String get fieldOptional => '选填';

  @override
  String get fieldDateOfBirth => '出生日期';

  @override
  String get fieldLastDone => '上次完成';

  @override
  String get fieldCost => '费用';

  @override
  String get fieldNotes => '备注';

  @override
  String get fieldDate => '日期';

  @override
  String get fieldExpires => '到期';

  @override
  String get docHasFile => '已附文件';

  @override
  String get settingsReminders => '护理提醒';

  @override
  String get settingsRemindersSubtitle => '在计划到期前提醒你';
}
