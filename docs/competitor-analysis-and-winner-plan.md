# PetGo — Riset 10 Kompetitor, Gap Analysis & Blueprint "Market Winner"

Dokumen arsitektur, riset pasar komparatif melalui Wigolo CLI, dan rencana strategis implementasi fitur PetGo menjadi aplikasi manajemen garasi, servis, konsumsi BBM, dan pengingat pajak nomor satu di kelasnya.

---

## 1. Benchmarking 10 Kompetitor (Riset via Wigolo CLI)

Berdasarkan riset pasar, crawling UI/UX produk, dan dokumentasi aplikasi manajemen kendaraan global maupun domestik:

### Matriks Komparasi 10 Kompetitor

| No | Kompetitor | Kategori & Platform | Keunggulan Kunci (USPs) | Kelemahan UX / Bottleneck |
|----|------------|---------------------|--------------------------|---------------------------|
| 1 | **Drivvo** | Direct (Android, iOS, Web) | Modul lengkap: BBM, servis, pengeluaran, checklist inspeksi, grafik bulanan | Iklan banner/interstitial agresif, paywall fitur PDF/backup, input form rumit |
| 2 | **Fuelio (Sygic)** | Direct (Android, iOS) | Algoritma konsumsi BBM full-tank presisi tinggi, timeline activity gabungan, offline-first | Tampilan jadwal servis terasa sekunder, minim spesialisasi roda dua (motor) |
| 3 | **Simply Auto** | Direct (Android, iOS, Web) | Digital glovebox (STNK/asuransi), jadwal servis bertingkat per part, sinkronisasi bisnis/pajak | Batasan kendaraan di free tier, antarmuka terlalu padat ala fleet korporat |
| 4 | **CARFAX Car Care** | Direct (Android, iOS, Web) | Timeline rekomendasi servis pabrikan (10k, 20k km), riwayat servis digital untuk nilai jual | Ketergantungan VIN database Amerika Serikat, tidak relevan untuk motor & regulasi Indonesia |
| 5 | **Fuelly / aCar** | Direct (iOS, Android, Web) | Mesin kalkulasi konsumsi BBM legendaris, komunitas data konsumsi bahan bakar | UI sudah tertinggal zaman, pengembangan lambat, fitur lampiran foto berbayar |
| 6 | **AutoCare** | Direct (Android, iOS) | Sistem pengingat ganda (Dual-Trigger: Odometer KM vs Tanggal Kalender, mana yang lebih dulu) | Kurang memiliki checklist inspeksi dan pembagian biaya total kepemilikan (TCO) |
| 7 | **Road Trip MPG** | Direct (iOS) | Dashboard metrik sangat padat (dense metrics), moving average, biaya/hari & biaya/km | Hanya tersedia di ekosistem iOS, berbayar di muka, tidak ada lokalisasi bahasa Indonesia |
| 8 | **MyCar / Car Manager** | Direct (Android, iOS) | Glovebox dokumen terpusat, buku harian penggantian sparepart, ringkasan pengeluaran multi-kendaraan | Butuh sinkronisasi akun, performa lambat pada data riwayat yang banyak |
| 9 | **Yamaha Y-Connect / Honda RoadSync** | Indirect / Telemetry (Android, iOS) | Indikator kondisi oli motor, tombol Reset Interval Oli, voltase aki, pengingat V-Belt/Rantai | Terkunci hardware motor tertentu, tidak bisa menggabungkan mobil dan motor dalam 1 keluarga |
| 10 | **FIXD / OBD Health** | Indirect / Diagnostic (Android, iOS) | Skor kesehatan kendaraan (0-100%), pelacak keausan komponen (ban, aki, wiper), cek pra-perjalanan | Memerlukan dongle sensor fisik OBD2, fitur prediksi terkunci subscription |

---

## 2. Bedah Detail Fitur, Layar & Aliran Data Tiap Kompetitor

### 1. Drivvo
- **Fitur Unggulan**: Catatan pengisian BBM multi-bahan bakar (bensin, diesel, ethanol, EV kWh), pencatat rute perjalanan, pencatat pengeluaran berkala, checklist inspeksi pra-jalan.
- **Arsitektur Layar**:
  - *Main Dashboard*: Kartu pengeluaran bulan ini (persentase naik/turun), banner servis terdekat, pemilih kendaraan atas, FAB "+" aksi cepat.
  - *Refueling Log & Form*: Input liter, harga/L, total biaya, odometer, tangki penuh (toggle), nama SPBU.
  - *Service & Expense View*: Daftar kartu riwayat dengan ikon kategori, catatan sparepart, bengkel, dan biaya jasa.
  - *Inspection Checklist Screen*: Formulir centang item keselamatan (lampu, oli, ban, rem).
- **Aliran Data**:
  - *Displayed*: Total pengeluaran bulanan, km/L rata-rata, pengingat km tersisa, grafik kategori.
  - *Stored*: Entitas Kendaraan, RefuelLog, ServiceLog, ExpenseLog, InspectionCheck.
  - *Processed*: Perhitungan konsumsi bahan bakar antara dua pengisian full tank, agregasi biaya bulanan, trigger peringatan servis saat odometer melampaui ambang batas.

### 2. Fuelio
- **Fitur Unggulan**: Timeline feed terpadu (gabungan log BBM dan servis dalam 1 aliran waktu), statistik efisiensi konsumsi, ekspor CSV, dukungan bi-fuel.
- **Arsitektur Layar**:
  - *Dashboard Summary*: Estimasi sisa jarak tempuh, konsumsi rata-rata, kartu kendaraan aktif.
  - *Timeline View*: Infinite scroll feed berurutan secara kronologis dari catatan terbaru.
  - *Stats & Charts*: Grafik tren km/L terhadap waktu, perbandingan harga bahan bakar per liter.
- **Aliran Data**:
  - *Displayed*: Timeline list, kurva grafik tren, total biaya per kilometer.
  - *Stored*: Fill-up logs, station locations, service expense entries, unit preferences.
  - *Processed*: Algoritma deteksi missed fill-up, rolling average konsumsi BBM, normalisasi unit.

### 3. Simply Auto
- **Fitur Unggulan**: Pelacak jadwal servis per komponen suku cadang (ganti busi, filter oli, rotasi ban), brankas dokumen kadaluarsa (STNK, asuransi, garansi).
- **Arsitektur Layar**:
  - *Home Fleet Screen*: Pilihan armada mobil/motor, indikator status merah/kuning/hijau.
  - *Service Tasks Manager*: Katalog suku cadang dengan progress bar jarak/waktu tersisa.
  - *Document & Tax Vault*: Daftar masa berlaku dokumen STNK tahunan, pelat 5 tahunan, polis asuransi.
- **Aliran Data**:
  - *Displayed*: Countdown hari/km per suku cadang, tanggal jatuh tempo dokumen, akumulasi biaya kepemilikan.
  - *Stored*: Dokumen lisensi/pajak, parameter interval servis per komponen, log historis.
  - *Processed*: Komparasi interval ganda (mana yang lebih dulu tercapai antara jarak tempuh atau waktu).

### 4. CARFAX Car Care
- **Fitur Unggulan**: Timeline rekomendasi servis pabrikan berbasis kelipatan odometer (10.000, 20.000, 40.000 km), paspor riwayat servis untuk menjaga nilai jual kembali kendaraan (resale value).
- **Arsitektur Layar**:
  - *Milestone Schedule View*: Kartu tahapan servis berkala dengan daftar poin ceklis standar pabrik.
  - *Digital Service Passport*: Daftar bukti pengerjaan bengkel yang siap dicetak/diekspor.
- **Aliran Data**:
  - *Displayed*: Checklist pekerjaan servis berkala berikutnya, estimasi biaya bengkel.
  - *Stored*: Riwayat faktur bengkel, odometer pengerjaan, catatan mekanik.
  - *Processed*: Pencocokan milestone berikutnya berdasarkan nilai odometer aktif.

### 5. Fuelly / aCar
- **Fitur Unggulan**: Rekor efisiensi BBM terbaik, terburuk, dan rata-rata; ekspor-impor CSV; katalog interval perawatan.
- **Arsitektur Layar**:
  - *Console View*: Ringkasan statistik cepat dan tombol cepat tambah catatan.
  - *Browse Log History*: Filter pencarian riwayat berdasarkan tanggal, tipe, atau kendaraan.
- **Aliran Data**:
  - *Displayed*: Best km/L, Worst km/L, Average km/L, Total Fuel Spent.
  - *Stored*: Entitas log bbm dengan jenis bahan bakar.
  - *Processed*: Kalkulasi deviasi efisiensi berkendara dan total akumulasi pengeluaran.

### 6. AutoCare
- **Fitur Unggulan**: Dual-trigger smart reminders (jarak tempuh km ATAU jangka waktu bulan, mana yang tercapai lebih dulu), badge visual status warna (Hijau = Aman, Kuning = Segera, Merah = Terlewat).
- **Arsitektur Layar**:
  - *Schedule Status Screen*: Kartu item perawatan berjejer dengan badge status yang mencolok.
  - *Add Reminder Sheet*: Input nama part, interval km, interval bulan, dan catatan.
- **Aliran Data**:
  - *Displayed*: Indikator status warna cerah, selisih km dan hari tersisa.
  - *Stored*: Konfigurasi jadwal pengingat per kendaraan.
  - *Processed*: Evaluasi: `isDue = (currentKm >= dueKm) || (today >= dueDate)`.

### 7. Road Trip MPG
- **Fitur Unggulan**: Layout dasbor ultra-padat (dense layout), menghitung moving averages, biaya per hari, biaya per kilometer, dan proyeksi biaya tahunan.
- **Arsitektur Layar**:
  - *High-Density Summary*: Satu layar memuat semua metrik penting tanpa perlu berpindah-pindah.
  - *Fast Entry Keypad*: Form pengisian cepat di SPBU dengan fokus pada kecepatan input.
- **Aliran Data**:
  - *Displayed*: Biaya operasional harian (Rp/hari), biaya per kilometer (Rp/km), proyeksi biaya 12 bulan ke depan.
  - *Stored*: Nilai odometer, tanggal, biaya transaksi.
  - *Processed*: Ekstrapolasi rata-rata pemakaian harian dikali 365 hari untuk proyeksi tahunan.

### 8. MyCar / Car Manager
- **Fitur Unggulan**: Buku harian penggantian sparepart (riwayat kapan aki, kampas rem, ban diganti), brankas penyimpanan dokumen kendaraan, total cost of ownership.
- **Arsitektur Layar**:
  - *Parts Diary*: Riwayat per komponen spesifik (Aki, Ban, Kampas Rem, Suspensi, Busi).
  - *Document Reminders*: Tampilan kartu STNK, BPKB, dan polis asuransi.
- **Aliran Data**:
  - *Displayed*: Usia pakai komponen dalam bulan dan kilometer.
  - *Stored*: Metadata sparepart (merek, tipe, tanggal pasang, km pasang).
  - *Processed*: Umur pemakaian sparepart sejak tanggal pemasangan.

### 9. Yamaha Y-Connect / Honda RoadSync
- **Fitur Unggulan**: Spesialisasi kendaraan roda dua (motor matic & manual), pemantauan interval oli mesin & oli gardan (gear oil), tombol konfirmasi "Reset Oli", pengingat ganti V-Belt CVT / Rantai roda, status kesehatan aki.
- **Arsitektur Layar**:
  - *Motorcycle Cockpit*: Pengukur kondisi oli dengan indikator warna, status aki, status V-belt.
  - *Oil Reset Dialog*: Konfirmasi pengaturan ulang counter oli ke odometer saat ini.
- **Aliran Data**:
  - *Displayed*: Persentase sisa umur oli, sisa km sebelum ganti V-belt/rantai roda.
  - *Stored*: Odometer terakhir penggantian oli mesin dan oli gardan.
  - *Processed*: Pengurangan `(lastOilKm + intervalKm) - currentKm`.

### 10. FIXD / OBD Health
- **Fitur Unggulan**: Vehicle Health Score (0-100%), daftar periksa keausan barang pakai habis (wear items), checklist inspeksi pra-perjalanan panjang (mudik/roadtrip).
- **Arsitektur Layar**:
  - *Health Gauge*: Lingkaran skor kondisi kendaraan keseluruhan.
  - *Wear Items Tracker*: Kondisi ban, aki, wiper, filter, kampas rem.
  - *Pre-Trip Inspection Screen*: 10 poin ceklis sebelum perjalanan jauh.
- **Aliran Data**:
  - *Displayed*: Health score (0-100%), status kelayakan jalan (Layak / Butuh Perhatian / Kritis).
  - *Stored*: Log hasil inspeksi dan timestamp pemeriksaan.
  - *Processed*: Bobot skor kesehatan berkurang jika ada servis yang jatuh tempo atau dokumen pajak mati.

---

## 3. Blueprint Strategi "Market Winner" untuk PetGo

Menggabungkan semua keunggulan kompetitor di atas ke dalam satu aplikasi Flutter modern, 100% offline-first, tanpa iklan, tanpa registrasi akun, dengan penyesuaian khusus untuk ekosistem Indonesia (mobil & motor):

### A. Fitur Utama yang Diadopsi & Diintegrasikan:
1. **Garasi Multi-Kendaraan Komprehensif (Mobil & Motor)**:
   - Dukungan armada tak terbatas dengan ikon dan tipe spesifik (Mobil vs Motor).
   - Pemilih kendaraan aktif yang mulus di seluruh layar.
2. **Vehicle Health Score & Dense Cockpit (dari FIXD + Road Trip)**:
   - Skor Kesehatan Kendaraan (0-100%) otomatis berdasarkan status oli, servis terjadwal, dan pajak STNK.
   - Kartu Metrik Padat: Biaya Operasional / km (Rp/km), Total Biaya Pemilikan (TCO), Konsumsi Rata-rata (km/L).
3. **Jadwal Servis Berkala Dual-Trigger (dari AutoCare + Simply Auto + Y-Connect)**:
   - Evaluasi ganda: Jarak tempuh (KM) ATAU Waktu (Bulan/Hari), mana yang tercapai lebih dulu.
   - Preset standar Indonesia untuk Mobil (Oli Sintetik, Filter Oli, Filter Udara/Kabin, Minyak Rem, Radiator Coolant, Rotasi Ban, Busi).
   - Preset standar Indonesia untuk Motor (Oli Mesin Matic/Manual, Oli Gardan/Gear Oil, V-Belt & Roller CVT / Rantai & Sprocket, Kampas Rem, Filter Udara, Busi Motor).
   - Tombol satu-ketuk "Tandai Selesai / Reset Interval" dengan pencatatan otomatis ke Log Servis.
4. **Log Konsumsi BBM Presisi & Analisis Efisiensi (dari Fuelio + Drivvo)**:
   - Pencatat pengisian BBM dengan perhitungan efisiensi km/L (antara dua pengisian tangki penuh / full tank).
   - Menghitung biaya pengisian per km.
   - Pilihan jenis BBM populer (Pertalite, Pertamax, Pertamax Turbo, Solar/Dex, atau Listrik kWh).
5. **Brankas Dokumen & Pengingat Pajak (dari Simply Auto + MyCar)**:
   - Pengingat Pajak PKB Tahunan STNK dengan hitungan mundur hari.
   - Pengingat Ganti Pelat Nomor & STNK 5 Tahunan.
   - Pengingat Asuransi Kendaraan (All Risk / TLO).
   - Pengingat Uji Emisi / Dokumen Kendaraan.
6. **Checklist Inspeksi Pra-Perjalanan / Mudik (dari Drivvo + FIXD)**:
   - Formulir inspeksi 8-10 poin cepat (tekanan ban, oli mesin, air radiator, minyak rem, lampu & sein, wiper, aki, klakson).
   - Audit riwayat inspeksi terakhir dengan timestamp.
7. **Total Cost of Ownership (TCO) & Analitik Keuangan (dari Road Trip + Drivvo)**:
   - Pemecahan kategori pengeluaran: BBM, Servis/Perawatan, Pajak/Surat, Sparepart, Cuci/Lainnya.
8. **Portabilitas Data & Backup Lokal (dari Fuelio + Simply Auto)**:
   - Ekspor backup lengkap JSON.
   - Impor / Pulihkan dari backup JSON dengan validasi skema ketat (§VAL).
   - Ekspor log riwayat Servis & BBM ke format CSV siap pakai untuk spreadsheet / Excel.

---

## 4. Target Site Map & Screen Architecture

```
PetGo App
│
├── [Shell] NavigationShell (Bottom Bar & Navigation Rail responsif)
│   ├── Tab 1: 🏠 Garasi (GarageDashboardScreen)
│   │   ├── Header: Active Vehicle Selector + Badge Tipe Kendaraan
│   │   ├── Card: Vehicle Health Score Gauge (0-100%) & Status Layak Jalan
│   │   ├── Metric Row: Odometer Terkini, Biaya Operasional / km, Konsumsi Rata-rata (km/L)
│   │   ├── Card: Status Oli Mesin (Progress bar sisa km/hari & tombol Cepat Reset Oli)
│   │   ├── Card: Status Pajak STNK & Pelat 5 Tahunan (Countdown hari & badge status)
│   │   ├── Quick Action Speed Dial / Modal:
│   │   │   ├── + Catat Servis
│   │   │   ├── + Catat Isi BBM
│   │   │   ├── + Jadwal Perawatan Baru
│   │   │   ├── 📋 Checklist Inspeksi Kendaraan
│   │   │   └── 🚗 Tambah Kendaraan Baru
│   │   └── Card: Total Biaya Kepemilikan (TCO Breakdown)
│   │
│   ├── Tab 2: 🔧 Perawatan (MaintenanceScreen)
│   │   ├── Sub-Tab / Filter: Jadwal Servis Berkala (Maintenance Schedule)
│   │   │   ├── Status Chips: Semua, Perlu Perhatian, Terlewat, Aman
│   │   │   ├── Preset Selector: Muat Rekomendasi Standar Pabrik (Mobil / Motor)
│   │   │   └── Action: Tambah Jadwal Kustom (Dual-trigger km & bulan)
│   │   ├── Sub-Tab / Filter: Riwayat Servis (Service History Logs)
│   │   │   ├── Search & Filter berdasarkan kata kunci
│   │   │   ├── Kartu riwayat servis dengan rincian biaya, bengkel, odometer, & tipe pengerjaan
│   │   │   └── Tombol hapus / tambah servis baru
│   │   └── Sub-Tab: Checklist Inspeksi Kendaraan (Roadtrip / Harian)
│   │       ├── Formulir checklist interaktif
│   │       └── Riwayat hasil inspeksi
│   │
│   ├── Tab 3: ⛽ BBM (FuelScreen)
│   │   ├── Header Metrik BBM: Rata-rata Konsumsi (km/L), Biaya per KM (Rp/km), Total Biaya BBM
│   │   ├── List: Riwayat Pengisian Bahan Bakar
│   │   │   ├── Badge Full Tank, volume liter, harga/L, total bayar, odometer saat isi
│   │   │   └── Efisiensi km/L sejak pengisian sebelumnya
│   │   └── Action: Modal Tambah Log BBM Baru dengan validasi ketat (§VAL)
│   │
│   ├── Tab 4: 📂 Brankas & Dokumen (GloveboxScreen)
│   │   ├── Kartu Pajak PKB Tahunan STNK
│   │   ├── Kartu Ganti Pelat & STNK 5 Tahunan
│   │   ├── Kartu Asuransi Kendaraan (Polis, Masa Berlaku, Nomor Kontak Darurat)
│   │   ├── Kartu Uji Emisi / Dokumen Lainnya
│   │   └── Form Tambah / Perbarui Dokumen
│   │
│   └── Tab 5: ⚙️ Pengaturan & Backup (SettingsScreen)
│       ├── Manajemen Data: Ekspor Backup JSON & Impor Backup JSON
│       ├── Ekspor Laporan: Ekspor CSV Riwayat Servis & CSV BBM
│       ├── Kelola Garasi: Tambah, edit, dan hapus kendaraan
│       ├── Info Aplikasi & Privasi: 100% Offline-First, Bebas Iklan, Tanpa Akun
│       └── Reset Data Garasi
```

---

## 5. Technical Implementation Roadmap

1. **Phase 1: Skema Data & Model Terintegrasi (`lib/core/models/`)**
   - Perluas `Vehicle` (tambahkan tanggal STNK 5 tahunan, asuransi, estimasi pajak tahunan).
   - Buat `MaintenanceSchedule` model (dual-trigger jarak km & waktu bulan, status aman/perhatian/terlewat, preset rekomendasi mobil & motor).
   - Buat `VehicleDocument` model (STNK tahunan, pelat 5 tahun, asuransi, uji emisi).
   - Buat `InspectionChecklist` model (item-item pra-perjalanan beserta status centang).
   - Perbarui `FuelLog` (tambahkan tipe BBM: Pertalite, Pertamax, Pertamax Turbo, Solar/Dex, Listrik).

2. **Phase 2: Storage & Logic Layer (`lib/core/storage/` & `lib/core/providers/`)**
   - Perluas `LocalStorageService` untuk menyimpan dan memulihkan MaintenanceSchedules, Documents, dan InspectionChecklists.
   - Buat fungsi backup ekspor JSON dan impor JSON dengan validasi ketat (§VAL).
   - Buat fungsi ekspor CSV untuk Service Logs dan Fuel Logs.
   - Buat mesin kalkulasi metrik:
     * `VehicleHealthCalculator`: kalkulasi skor kesehatan 0-100%.
     * `TCOCalculator`: kalkulasi Total Cost of Ownership.
     * `FuelEfficiencyCalculator`: kalkulasi delta km/L dan cost/km.
   - Daftarkan StateNotifiers di Riverpod (`maintenanceSchedulesProvider`, `vehicleDocumentsProvider`, `inspectionChecklistsProvider`).

3. **Phase 3: Routing & Navigasi (`lib/core/router/` & `lib/features/shell/`)**
   - Daftarkan rute baru: `/` (Garasi), `/maintenance` (Perawatan & Servis), `/fuel` (BBM), `/glovebox` (Brankas & Pajak), `/settings` (Pengaturan & Ekspor).
   - Perbarui `NavigationShell` dengan 5 tab responsif berikon Material You.

4. **Phase 4: Tampilan Antarmuka Pengguna (UI Presentation)**
   - Perbarui `GarageDashboardScreen`: Health Score circular gauge, KPI cards, status oli mesin & pajak, TCO chart, speed dial.
   - Buat `MaintenanceScreen`: Tab Jadwal Servis (dengan pemuat preset pabrik mobil & motor), Tab Riwayat Servis, dan Tab Ceklis Inspeksi.
   - Perbarui `FuelLogsScreen`: Kartu metrik efisiensi, daftar riwayat BBM dengan indikator km/L, sheet tambah BBM lengkap.
   - Buat `GloveboxScreen`: Manajemen pajak tahunan, pelat 5 tahun, dan polis asuransi.
   - Perbarui `SettingsScreen`: Fitur ekspor/impor JSON, ekspor CSV, switch kendaraan, dan info privasi.
   - Buat Sheet & Modal Dialog: `AddMaintenanceScheduleSheet`, `AddDocumentSheet`, `InspectionSheet`, `EditVehicleSheet`.

5. **Phase 5: Verifikasi Kualitas & Test Suite (`test/`)**
   - Tambahkan unit test untuk `MaintenanceSchedule`, `TCOCalculator`, `VehicleHealthCalculator`, `BackupService`.
   - Jalankan `flutter analyze` dan `flutter test` sampai 0 warning dan 0 error.
