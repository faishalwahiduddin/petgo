import json
import os
import re

with open('keys.json', 'r') as f:
    id_keys = json.load(f)

locales = ['id', 'en', 'ar', 'jv', 'su', 'zh', 'ja', 'es']

# Remove ignored keys
keys_to_remove = ["13700", "15000", "20000", "2023", "25000", "2500000", "25500", "355", "450000", "5000", "6", "nVersion110NVehiclesN", "b1234Abc", "b1234Cd", "misalBengkelResmiAstra", "misalGantiOliMesinFilter", "misalHondaHrVYamahaNmax", "misalKurasMinyakRemDot4", "misalPajakPkbTahunanStnk2026", "misalStnkDiDompetBpkbDiLemariA", "pertamina3415321Serpong", "garagego", "usageLicense", "licenciaDeUso"]
for k in keys_to_remove:
    if k in id_keys:
        del id_keys[k]

dict_replace = {
    'en': {'Simpan': 'Save', 'Tutup': 'Close', 'Batal': 'Cancel', 'Hapus': 'Delete', 'Tambah': 'Add', 'Edit': 'Edit', 'Kendaraan': 'Vehicle', 'Garasi': 'Garage'},
    'ar': {'Simpan': 'حفظ', 'Tutup': 'إغلاق', 'Batal': 'إلغاء', 'Hapus': 'حذف', 'Tambah': 'إضافة', 'Edit': 'تعديل', 'Kendaraan': 'مركبة', 'Garasi': 'كراج'},
    'jv': {'Simpan': 'Simpen', 'Tutup': 'Tutup', 'Batal': 'Batal', 'Hapus': 'Busek', 'Tambah': 'Tambah', 'Edit': 'Owah', 'Kendaraan': 'Tunggangan', 'Garasi': 'Garasi'},
    'su': {'Simpan': 'Simpen', 'Tutup': 'Tutup', 'Batal': 'Batal', 'Hapus': 'Hapus', 'Tambah': 'Tambih', 'Edit': 'Ubah', 'Kendaraan': 'Kandaraan', 'Garasi': 'Garasi'},
    'zh': {'Simpan': '保存', 'Tutup': '关闭', 'Batal': '取消', 'Hapus': '删除', 'Tambah': '添加', 'Edit': '编辑', 'Kendaraan': '车辆', 'Garasi': '车库'},
    'ja': {'Simpan': '保存', 'Tutup': '閉じる', 'Batal': 'キャンセル', 'Hapus': '削除', 'Tambah': '追加', 'Edit': '編集', 'Kendaraan': '車両', 'Garasi': 'ガレージ'},
    'es': {'Simpan': 'Guardar', 'Tutup': 'Cerrar', 'Batal': 'Cancelar', 'Hapus': 'Eliminar', 'Tambah': 'Agregar', 'Edit': 'Editar', 'Kendaraan': 'Vehículo', 'Garasi': 'Garaje'}
}

def translate(text, lang):
    if lang == 'id': return text
    res = text
    if lang in dict_replace:
        for k, v in dict_replace[lang].items():
            res = re.sub(r'(?i)\b' + k + r'\b', v, res)
    return res

for lang in locales:
    path = f"lib/l10n/app_{lang}.arb"
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            arb = json.load(f)
    else:
        arb = {}

    for k, v in id_keys.items():
        if k not in arb:
            arb[k] = translate(v, lang)
            
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(arb, f, indent=2, ensure_ascii=False)

print("Done generating ARBs")
