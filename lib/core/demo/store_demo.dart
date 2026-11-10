import 'dart:ui' as ui;

import '../models/pet.dart';
import '../storage/local_storage_service.dart';

/// Enabled by store screenshot captures: `--dart-define=STORE_DEMO=true`.
const bool kStoreDemo = bool.fromEnvironment('STORE_DEMO');

const _kSeeded = 'store_demo_seeded';
const _langs = {'id', 'en', 'ar', 'ja', 'zh', 'es'};

/// Language used for seed text: saved locale, else device locale. Regional
/// languages without seed text (jv, su) fall back to Indonesian.
String seedLang(LocalStorageService s) {
  final code =
      s.prefs.getString('locale') ?? ui.PlatformDispatcher.instance.locale.languageCode;
  return _langs.contains(code) ? code : 'id';
}

class DemoText {
  const DemoText(this.id, this.en, this.ar, this.ja, this.zh, this.es);
  final String id, en, ar, ja, zh, es;
  String of(String lang) => switch (lang) {
        'id' => id,
        'ar' => ar,
        'ja' => ja,
        'zh' => zh,
        'es' => es,
        _ => en,
      };
}

const _rabies = DemoText('Vaksin rabies', 'Rabies vaccine', 'لقاح داء الكلب', '狂犬病ワクチン', '狂犬病疫苗', 'Vacuna antirrábica');
const _deworm = DemoText('Obat cacing', 'Deworming', 'دواء الديدان', '駆虫薬', '驱虫', 'Desparasitación');
const _flea = DemoText('Obat kutu & pinjal', 'Flea & tick treatment', 'علاج البراغيث والقراد', 'ノミ・ダニ予防', '驱跳蚤和蜱虫', 'Antipulgas y garrapatas');
const _groom = DemoText('Grooming', 'Grooming', 'العناية بالفرو', 'トリミング', '美容护理', 'Peluquería');
const _felv = DemoText('Vaksin tahunan kucing', 'Annual cat vaccine', 'اللقاح السنوي للقطط', '猫の年次ワクチン', '猫年度疫苗', 'Vacuna anual felina');
const _feedAm = DemoText('Makan pagi', 'Morning meal', 'وجبة الصباح', '朝ごはん', '早餐', 'Desayuno');
const _feedPm = DemoText('Makan sore', 'Evening meal', 'وجبة المساء', '夕ごはん', '晚餐', 'Cena');
const _parkWalk = DemoText('Jalan di taman', 'Walk in the park', 'نزهة في الحديقة', '公園の散歩', '公园散步', 'Paseo por el parque');
const _litter = DemoText('Ganti pasir', 'Litter changed', 'تغيير الرمل', 'トイレ掃除', '更换猫砂', 'Arena cambiada');
const _checkup = DemoText('Pemeriksaan rutin', 'Routine checkup', 'فحص دوري', '定期健診', '常规检查', 'Revisión de rutina');
const _skin = DemoText('Iritasi kulit ringan', 'Mild skin irritation', 'تهيج جلدي خفيف', '軽い皮膚の炎症', '轻微皮肤过敏', 'Irritación leve de la piel');
const _dental = DemoText('Pembersihan gigi', 'Dental cleaning', 'تنظيف الأسنان', '歯のクリーニング', '洁牙', 'Limpieza dental');
const _boost = DemoText('Vaksin booster', 'Booster vaccine', 'لقاح منشط', '追加ワクチン', '加强疫苗', 'Vacuna de refuerzo');
const _clinic = DemoText('Klinik Hewan Sehat', 'Happy Paws Clinic', 'عيادة الحيوانات السعيدة', 'ハッピーポーズ動物病院', '快乐爪爪宠物诊所', 'Clínica Patitas Felices');
const _medSkin = DemoText('Salep antijamur 7 hari', '7-day antifungal ointment', 'مرهم مضاد للفطريات 7 أيام', '抗真菌軟膏（7日間）', '抗真菌药膏（7天）', 'Pomada antifúngica 7 días');
const _noteCheck = DemoText('Berat badan ideal, gigi bersih.', 'Healthy weight, clean teeth.', 'وزن صحي وأسنان نظيفة.', '体重は適正、歯もきれい。', '体重正常，牙齿干净。', 'Peso saludable y dientes limpios.');
const _noteSkin = DemoText('Kontrol ulang jika belum membaik.', 'Recheck if it does not improve.', 'إعادة الفحص إن لم يتحسن.', '改善しなければ再診。', '若未好转请复诊。', 'Revisar de nuevo si no mejora.');
const _docCard = DemoText('Kartu vaksin Milo', 'Milo vaccine card', 'بطاقة تطعيم ميلو', 'ミロのワクチン手帳', 'Milo 疫苗本', 'Cartilla de vacunas de Milo');
const _docInsurance = DemoText('Asuransi hewan', 'Pet insurance policy', 'وثيقة تأمين الحيوان', 'ペット保険証券', '宠物保险单', 'Póliza de seguro de mascota');
const _docRx = DemoText('Resep dokter hewan', 'Vet prescription', 'وصفة الطبيب البيطري', '獣医の処方箋', '兽医处方', 'Receta veterinaria');
const _docChip = DemoText('Sertifikat microchip Luna', 'Luna microchip certificate', 'شهادة شريحة لونا', 'ルナのマイクロチップ証明書', 'Luna 芯片证书', 'Certificado de microchip de Luna');
const _mixed = DemoText('Campuran', 'Mixed breed', 'مختلط', 'ミックス', '混种', 'Mestizo');
const _shorthair = DemoText('Domestik', 'Domestic shorthair', 'قصير الشعر', '短毛種', '短毛猫', 'Pelo corto doméstico');

class StoreDemoSeeder {
  /// Writes a lived-in 6-week history. Idempotent.
  static Future<void> seedIfNeeded(LocalStorageService s) async {
    if (!kStoreDemo || s.prefs.getBool(_kSeeded) == true) return;
    final lang = seedLang(s);
    final now = DateTime.now().toUtc();
    DateTime ago(int days, [int hours = 0]) =>
        now.subtract(Duration(days: days, hours: hours));

    final pets = [
      Pet(
        id: 'demo-milo',
        name: 'Milo',
        species: PetSpecies.dog,
        breed: _mixed.of(lang),
        dateOfBirth: ago(365 * 2 + 40),
        weightKg: 12.8,
      ),
      Pet(
        id: 'demo-luna',
        name: 'Luna',
        species: PetSpecies.cat,
        breed: _shorthair.of(lang),
        dateOfBirth: ago(365 + 90),
        weightKg: 4.3,
      ),
      Pet(
        id: 'demo-kiwi',
        name: 'Kiwi',
        species: PetSpecies.rabbit,
        breed: '',
        dateOfBirth: ago(300),
        weightKg: 1.9,
      ),
    ];
    const milo = 'demo-milo';
    const luna = 'demo-luna';
    await s.savePets(pets);
    await s.saveActivePetId(milo);

    await s.saveCareSchedules([
      CareSchedule(id: 'dsch-1', petId: milo, title: _rabies.of(lang), kind: CareKind.vaccine, intervalMonths: 12, lastDoneAt: ago(318)),
      CareSchedule(id: 'dsch-2', petId: milo, title: _deworm.of(lang), kind: CareKind.deworm, intervalMonths: 3, lastDoneAt: ago(79)),
      CareSchedule(id: 'dsch-3', petId: milo, title: _flea.of(lang), kind: CareKind.flea, intervalMonths: 1, lastDoneAt: ago(36)),
      CareSchedule(id: 'dsch-4', petId: milo, title: _groom.of(lang), kind: CareKind.grooming, intervalMonths: 2, lastDoneAt: ago(21)),
      CareSchedule(id: 'dsch-5', petId: luna, title: _felv.of(lang), kind: CareKind.vaccine, intervalMonths: 12, lastDoneAt: ago(240)),
      CareSchedule(id: 'dsch-6', petId: luna, title: _deworm.of(lang), kind: CareKind.deworm, intervalMonths: 3, lastDoneAt: ago(64)),
    ]);

    await s.saveVetLogs([
      VetLog(id: 'dvet-1', petId: milo, date: ago(12), title: _checkup.of(lang), clinic: _clinic.of(lang), cost: 185000, notes: _noteCheck.of(lang)),
      VetLog(id: 'dvet-2', petId: milo, date: ago(41), title: _skin.of(lang), clinic: _clinic.of(lang), medication: _medSkin.of(lang), cost: 245000, notes: _noteSkin.of(lang)),
      VetLog(id: 'dvet-3', petId: milo, date: ago(97), title: _dental.of(lang), clinic: _clinic.of(lang), cost: 420000),
      VetLog(id: 'dvet-4', petId: luna, date: ago(28), title: _boost.of(lang), clinic: _clinic.of(lang), cost: 165000),
      VetLog(id: 'dvet-5', petId: luna, date: ago(75), title: _checkup.of(lang), clinic: _clinic.of(lang), cost: 120000, notes: _noteCheck.of(lang)),
    ]);

    final daily = <DailyCareLog>[];
    for (var d = 0; d < 6; d++) {
      daily.add(DailyCareLog(id: 'dd-f$d', petId: milo, date: ago(d, 7), kind: DailyCareKind.feed, notes: _feedAm.of(lang)));
      if (d.isEven) {
        daily.add(DailyCareLog(id: 'dd-e$d', petId: milo, date: ago(d, 1), kind: DailyCareKind.feed, notes: _feedPm.of(lang)));
      }
      daily.add(DailyCareLog(id: 'dd-w$d', petId: milo, date: ago(d, 4), kind: DailyCareKind.walk, notes: d % 3 == 0 ? _parkWalk.of(lang) : ''));
    }
    daily.addAll([
      DailyCareLog(id: 'dd-l0', petId: luna, date: ago(0, 3), kind: DailyCareKind.litter, notes: _litter.of(lang)),
      DailyCareLog(id: 'dd-l1', petId: luna, date: ago(1, 5), kind: DailyCareKind.litter),
    ]);
    await s.saveDailyLogs(daily);

    const miloWeights = [11.6, 11.9, 12.1, 12.4, 12.6, 12.8];
    const lunaWeights = [4.0, 4.1, 4.1, 4.2, 4.3];
    await s.saveWeightLogs([
      for (var i = 0; i < miloWeights.length; i++)
        WeightLog(id: 'dw-m$i', petId: milo, date: ago(70 - i * 13), weightKg: miloWeights[i]),
      for (var i = 0; i < lunaWeights.length; i++)
        WeightLog(id: 'dw-l$i', petId: luna, date: ago(60 - i * 14), weightKg: lunaWeights[i]),
    ]);

    await s.saveDocuments([
      PetDocument(id: 'ddoc-1', petId: milo, title: _docCard.of(lang), kind: DocKind.vaccineCard, expiresAt: now.add(const Duration(days: 47))),
      PetDocument(id: 'ddoc-2', petId: milo, title: _docInsurance.of(lang), kind: DocKind.insurance, expiresAt: now.add(const Duration(days: 210))),
      PetDocument(id: 'ddoc-3', petId: milo, title: _docRx.of(lang), kind: DocKind.prescription),
      PetDocument(id: 'ddoc-4', petId: luna, title: _docChip.of(lang), kind: DocKind.other),
    ]);

    await s.setDisclaimerAccepted(true);
    await s.prefs.setBool('onboarding_completed', true);
    await s.prefs.setBool(_kSeeded, true);
  }
}

/// Localized text for the minimal first-run seed (real users).
const kDefaultSeedText = {
  'rabies': _rabies,
  'deworm': _deworm,
  'feed': _feedAm,
  'card': _docCard,
};
