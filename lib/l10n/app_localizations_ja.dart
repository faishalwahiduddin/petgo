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
  String get appTagline => 'ペットの記録・ケア予定・毎日のログ';

  @override
  String get navPets => 'ペット';

  @override
  String get navCare => 'ケア';

  @override
  String get navDaily => '毎日';

  @override
  String get navDocs => '書類';

  @override
  String get navSettings => '設定';

  @override
  String get onboardingHeadline => 'PetGo';

  @override
  String get onboardingDescription =>
      'ペットのプロフィール、ワクチンや駆虫の予定、通院の記録、毎日のケアを端末内でオフライン管理できます。\n\nアカウント不要。データは端末内に保存されます。';

  @override
  String get onboardingContinue => '了解しました — 続ける';

  @override
  String get onbSkip => 'スキップ';

  @override
  String get onbNext => '次へ';

  @override
  String get onbGetStarted => 'はじめる';

  @override
  String get onbSlide1Title => 'ペットのプロフィール';

  @override
  String get onbSlide1Sub => '犬、猫、その他の動物';

  @override
  String get onbSlide1Badge => '100% オフライン＆プライベート';

  @override
  String get onbSlide2Title => 'ケアの予定';

  @override
  String get onbSlide2Sub => 'ワクチン、駆虫、ノミ、トリミング';

  @override
  String get onbSlide2Badge => '端末内リマインダー';

  @override
  String get onbSlide3Title => '毎日の記録';

  @override
  String get onbSlide3Sub => 'ごはん、散歩、トイレ';

  @override
  String get onbSlide3Badge => '広告なし・アカウント不要';

  @override
  String get onbSlide4Title => '端末内の書類';

  @override
  String get onbSlide4Sub => 'ワクチン証明書や処方箋をまとめて';

  @override
  String get onbSlide4Badge => 'データは端末内に';

  @override
  String get onbPrivacyHeadline => 'プライバシーとオフライン';

  @override
  String get onbPrivacyDetail => 'すべてのデータは端末内に安全に保存され、トラッカーはありません。';

  @override
  String get loadingLabel => '読み込み中…';

  @override
  String get homeActivePet => '選択中のペット';

  @override
  String get homeNoPets => 'まだペットがいません。先にプロフィールを追加してください。';

  @override
  String get homeDueSoon => '期限間近';

  @override
  String get homeNoDue => '急ぎの予定はありません。';

  @override
  String get homeAllPets => 'すべてのペット';

  @override
  String get actionAddPet => 'ペットを追加';

  @override
  String get actionAddSchedule => '予定を追加';

  @override
  String get actionAddVet => '通院を記録';

  @override
  String get actionAddWeight => '体重を記録';

  @override
  String get actionAddDoc => '書類を追加';

  @override
  String get actionSave => '保存';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get speciesDog => '犬';

  @override
  String get speciesCat => '猫';

  @override
  String get speciesBird => '鳥';

  @override
  String get speciesRabbit => 'うさぎ';

  @override
  String get speciesOther => 'その他';

  @override
  String get fieldPetName => '名前';

  @override
  String get fieldSpecies => '種類';

  @override
  String get fieldBreed => '品種';

  @override
  String get fieldWeightKg => '体重（kg）';

  @override
  String get fieldTitle => 'タイトル';

  @override
  String get fieldIntervalMonths => '間隔（か月）';

  @override
  String get fieldClinic => '動物病院';

  @override
  String get fieldMedication => '薬';

  @override
  String get careSchedulesTitle => 'ケアの予定';

  @override
  String get vetLogsTitle => '通院と投薬';

  @override
  String get careEmptySchedules => '予定はまだありません。';

  @override
  String get careEmptyVet => '通院の記録はまだありません。';

  @override
  String get careVaccine => 'ワクチン';

  @override
  String get careDeworm => '駆虫';

  @override
  String get careFlea => 'ノミ';

  @override
  String get careGrooming => 'トリミング';

  @override
  String get careOther => 'その他';

  @override
  String everyMonths(int months) {
    return '$monthsか月ごと';
  }

  @override
  String daysRemaining(int days) {
    return 'あと$days日';
  }

  @override
  String get urgencyOverdue => '期限切れ';

  @override
  String get dailyQuickAdd => 'クイック記録';

  @override
  String get dailyTimeline => 'タイムライン';

  @override
  String get dailyEmpty => '毎日の記録はまだありません。';

  @override
  String get dailyFeed => 'ごはん';

  @override
  String get dailyWalk => '散歩';

  @override
  String get dailyLitter => 'トイレ';

  @override
  String get dailyOther => 'その他';

  @override
  String get weightHistory => '体重の履歴';

  @override
  String get docsEmpty => '書類はまだありません。';

  @override
  String get docVaccineCard => 'ワクチン証明書';

  @override
  String get docPrescription => '処方箋';

  @override
  String get docInsurance => '保険';

  @override
  String get docOther => 'その他';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsPets => 'ペットのプロフィール';

  @override
  String get settingsBackup => 'バックアップ';

  @override
  String get settingsVersion => 'バージョン';

  @override
  String get tileExportBackup => 'バックアップを書き出す';

  @override
  String get tileImportBackup => 'バックアップを読み込む';

  @override
  String get snackbarImportSuccess => 'バックアップを読み込みました';

  @override
  String get errorPetNameRequired => 'ペットの名前は2文字以上で入力してください';

  @override
  String get errorPetNameTooLong => 'ペットの名前が長すぎます';

  @override
  String get errorWeightInvalid => '体重が正しくありません';

  @override
  String get errorMinOnePet => 'ペットのプロフィールを1件以上残してください';

  @override
  String get errorTitleRequired => 'タイトルを入力してください';

  @override
  String get errorIntervalRequired => '間隔は1か月以上にしてください';

  @override
  String get errorBackupNotPetGo => 'PetGoのバックアップファイルではありません';

  @override
  String get actionEditPet => 'ペットを編集';

  @override
  String get actionMarkDone => '完了にする';

  @override
  String get actionEditSchedule => '予定を編集';

  @override
  String get actionEditVet => '通院記録を編集';

  @override
  String get actionEditDoc => '書類を編集';

  @override
  String get actionAttachFile => 'ファイルを添付';

  @override
  String get fieldOptional => '任意';

  @override
  String get fieldDateOfBirth => '生年月日';

  @override
  String get fieldLastDone => '前回の実施日';

  @override
  String get fieldCost => '費用';

  @override
  String get fieldNotes => 'メモ';

  @override
  String get fieldDate => '日付';

  @override
  String get fieldExpires => '有効期限';

  @override
  String get docHasFile => 'ファイル添付済み';

  @override
  String get settingsReminders => 'ケアのリマインダー';

  @override
  String get settingsRemindersSubtitle => '予定の期限前に通知します';

  @override
  String get commercialContactTitle => '商用利用';

  @override
  String get commercialContactDesc =>
      '商用ライセンス、ホワイトレーベル、カスタマイズが必要ですか？お問い合わせください。';

  @override
  String get acquireAppTitle => 'このアプリの買収';

  @override
  String get acquireAppDesc => 'ソースコードやアセットを含め、このアプリの買収にご関心がありますか？お気軽にご相談ください。';

  @override
  String get contactEmailCopied => 'メールアドレスをコピーしました: contact@faishal.id';

  @override
  String get licenseUsageTitle => '利用ライセンス';

  @override
  String get licenseUsageNotice => '個人および非営利目的での利用は無料です。';

  @override
  String get licenseBadgeText => '個人・非営利';

  @override
  String dialogDeletePetTitle(String petName) {
    return '「$petName」を削除しますか？';
  }

  @override
  String dialogDeletePetMessage(String petName, int count) {
    return '「$petName」と関連する$count件の記録を削除しますか？この操作は元に戻せません。';
  }

  @override
  String get dialogDeleteRecordTitle => '記録を削除しますか？';

  @override
  String get dialogDeleteRecordMessage => 'この記録を削除してもよろしいですか？';

  @override
  String get actionDelete => '削除';

  @override
  String get actionUndo => '元に戻す';

  @override
  String get snackbarDeleted => '削除しました';

  @override
  String get snackbarRecordDeleted => '記録を削除しました';

  @override
  String get snackbarDailyLogDeleted => '日課記録を削除しました';

  @override
  String snackbarScheduleDone(String title) {
    return '「$title」を完了にしました';
  }

  @override
  String snackbarQuickLogDone(String label) {
    return '「$label」を記録しました';
  }

  @override
  String get snackbarSaved => '保存しました';

  @override
  String fieldTotalCost(String cost) {
    return '診察費合計: $cost';
  }

  @override
  String get errorCostInvalid => '無効な金額です';

  @override
  String get settingsTheme => 'テーマ';

  @override
  String get themeSystem => '端末の設定に従う';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get notificationPermissionTitle => 'ケアリマインダー';

  @override
  String get notificationPermissionMessage =>
      'PetGoはワクチンやケアの予定を適時お知らせするために通知の許可が必要です。';

  @override
  String get actionAllow => '許可する';

  @override
  String get actionNotNow => '今はしない';

  @override
  String get notificationPermissionDenied => '通知の許可が拒否されました。端末の設定から有効にできます。';
}
