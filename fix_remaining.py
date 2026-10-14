import re

# settings_screen.dart
with open('lib/features/settings/settings_screen.dart', 'r') as f: c = f.read()
c = c.replace("Text('Gagal memulihkan backup: ${e.toString()}')", "Text(AppLocalizations.of(context)!.gagalMemulihkanBackup(e.toString()))")
with open('lib/features/settings/settings_screen.dart', 'w') as f: f.write(c)

# glovebox/add_document_sheet.dart
with open('lib/features/glovebox/add_document_sheet.dart', 'r') as f: c = f.read()
c = c.replace("hintText: 'Misal: Pajak PKB Tahunan STNK 2026'", "hintText: AppLocalizations.of(context)!.misalPajakPkbTahunanStnk2026")
c = c.replace("hintText: 'B 1234 ABC'", "hintText: AppLocalizations.of(context)!.hintPlatB1234")
c = c.replace("hintText: 'Misal: STNK di dompet, BPKB di lemari arsip'", "hintText: AppLocalizations.of(context)!.misalStnkDiDompet")
with open('lib/features/glovebox/add_document_sheet.dart', 'w') as f: f.write(c)

# maintenance/add_schedule_sheet.dart
with open('lib/features/maintenance/add_schedule_sheet.dart', 'r') as f: c = f.read()
c = c.replace("hintText: 'Misal: Kuras Minyak Rem DOT 4'", "hintText: AppLocalizations.of(context)!.misalKurasMinyakRem")
with open('lib/features/maintenance/add_schedule_sheet.dart', 'w') as f: f.write(c)

# garage/add_vehicle_sheet.dart
with open('lib/features/garage/add_vehicle_sheet.dart', 'r') as f: c = f.read()
c = c.replace("Text('Kendaraan ${v.name} berhasil ditambahkan ke garasi!')", "Text(AppLocalizations.of(context)!.kendaraanBerhasilDitambahkan(v.name))")
with open('lib/features/garage/add_vehicle_sheet.dart', 'w') as f: f.write(c)

# maintenance/maintenance_screen.dart
with open('lib/features/maintenance/maintenance_screen.dart', 'r') as f: c = f.read()
c = c.replace("labelText: 'Kategori'", "labelText: AppLocalizations.of(context)!.kategori")
c = c.replace("Text('Selesaikan: ${schedule.title}')", "Text(AppLocalizations.of(context)!.selesaikanJadwal(schedule.title))")
c = c.replace("Text('Jadwal (${schedules.length})')", "Text(AppLocalizations.of(context)!.jadwalCount(schedules.length.toString()))")
c = c.replace("Text('Riwayat (${serviceLogs.length})')", "Text(AppLocalizations.of(context)!.riwayatCount(serviceLogs.length.toString()))")
c = c.replace("Text('Inspeksi (${inspections.length})')", "Text(AppLocalizations.of(context)!.inspeksiCount(inspections.length.toString()))")
c = c.replace("Text('Rekomendasi pabrik ${active.type.label} berhasil dimuat!')", "Text(AppLocalizations.of(context)!.rekomendasiPabrikBerhasilDimuat(active.type.label))")
c = c.replace("Text('Muat Standar Pabrik (${active.type.label})')", "Text(AppLocalizations.of(context)!.muatStandarPabrik(active.type.label))")
c = c.replace("Text('Odometer: ${NumberFormat(\"#,###\", \"id_ID\").format(item.odometer)} km')", "Text(AppLocalizations.of(context)!.odometerValue(NumberFormat(\"#,###\", \"id_ID\").format(item.odometer)))")
# fallback for other cases just in case NumberFormat spacing differences
import re
c = re.sub(r'Text\(\s*\'Odometer: \$\{([^}]+)\}\s*km\'\s*\)', r'Text(AppLocalizations.of(context)!.odometerValue(\1))', c)

with open('lib/features/maintenance/maintenance_screen.dart', 'w') as f: f.write(c)
