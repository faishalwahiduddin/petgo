import json

locales = ['id', 'en', 'ar', 'jv', 'su', 'zh', 'ja', 'es']

new_keys = {
    'gagalMemulihkanBackup': 'Gagal memulihkan backup: {error}',
    'misalPajakPkbTahunanStnk2026': 'Misal: Pajak PKB Tahunan STNK 2026',
    'hintPlatB1234': 'B 1234 ABC',
    'misalStnkDiDompet': 'Misal: STNK di dompet, BPKB di lemari arsip',
    'misalKurasMinyakRem': 'Misal: Kuras Minyak Rem DOT 4',
    'kategori': 'Kategori',
    'selesaikanJadwal': 'Selesaikan: {title}',
    'jadwalCount': 'Jadwal ({count})',
    'riwayatCount': 'Riwayat ({count})',
    'inspeksiCount': 'Inspeksi ({count})',
    'rekomendasiPabrikBerhasilDimuat': 'Rekomendasi pabrik {label} berhasil dimuat!',
    'muatStandarPabrik': 'Muat Standar Pabrik ({label})',
    'odometerValue': 'Odometer: {odo} km',
    'kendaraanBerhasilDitambahkan': 'Kendaraan {name} berhasil ditambahkan ke garasi!'
}

en = {
    'gagalMemulihkanBackup': 'Failed to restore backup: {error}',
    'misalPajakPkbTahunanStnk2026': 'E.g.: Annual Vehicle Tax 2026',
    'hintPlatB1234': 'B 1234 ABC',
    'misalStnkDiDompet': 'E.g.: Registration in wallet, Title in cabinet',
    'misalKurasMinyakRem': 'E.g.: Flush Brake Fluid DOT 4',
    'kategori': 'Category',
    'selesaikanJadwal': 'Complete: {title}',
    'jadwalCount': 'Schedules ({count})',
    'riwayatCount': 'History ({count})',
    'inspeksiCount': 'Inspections ({count})',
    'rekomendasiPabrikBerhasilDimuat': 'Factory recommendation {label} loaded!',
    'muatStandarPabrik': 'Load Factory Standard ({label})',
    'odometerValue': 'Odometer: {odo} km',
    'kendaraanBerhasilDitambahkan': 'Vehicle {name} successfully added to garage!'
}

for lang in locales:
    with open(f'lib/l10n/app_{lang}.arb', 'r') as f:
        arb = json.load(f)
    for k, v in new_keys.items():
        if k not in arb:
            if lang == 'id':
                arb[k] = v
            elif lang == 'en':
                arb[k] = en[k]
            else:
                # Basic fallback
                arb[k] = en[k]
            
            # Add metadata for placeholders if any
            placeholders = {}
            if '{error}' in v: placeholders['error'] = {'type': 'String'}
            if '{title}' in v: placeholders['title'] = {'type': 'String'}
            if '{count}' in v: placeholders['count'] = {'type': 'String'}
            if '{label}' in v: placeholders['label'] = {'type': 'String'}
            if '{name}' in v: placeholders['name'] = {'type': 'String'}
            if '{odo}' in v: placeholders['odo'] = {'type': 'String'}
            
            if placeholders:
                arb['@' + k] = {'placeholders': placeholders}
                
    with open(f'lib/l10n/app_{lang}.arb', 'w') as f:
        json.dump(arb, f, indent=2, ensure_ascii=False)
