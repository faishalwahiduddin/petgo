# BRD — PetGo

> Batas SSOT. Dokumen ini milik **WHY dan WHAT tingkat bisnis**: tujuan,
> aktor, glosarium, dan aturan bisnis PetGo. Alur rinci per fitur,
> katalog validasi, dan kriteria terima ada di [PRD](./PRD.md).

- App: `petgo` — manajer hewan peliharaan: profil, jadwal, vet, log, berat.
- Stack: Flutter 3.x, Riverpod, GoRouter, SharedPreferences (`petgo_*`).
- Subdomain: petgo.faishal.id · appId: `id.faishal.petgo`.
- Repo: private `faishalwahiduddin/petgo`. Aturan: [CLAUDE.md](../CLAUDE.md).

## 1. Tujuan dan latar

PetGo ada agar pemilik hewan tidak lagi mengandalkan ingatan untuk jadwal
vaksin, obat cacing, dan riwayat dokter. Satu rumah digital per hewan yang
selalu bisa dibuka, bahkan tanpa internet.

Nilai yang diimplementasikan:

1. **Perawatan tidak terlewat.** Jadwal vaksin, cacing, flea, dan grooming
   tercatat dengan jatuh tempo yang jelas.
2. **Riwayat siap ditunjukkan.** Kunjungan vet, diagnosis, dan resep
   terkumpul per hewan untuk kontrol berikutnya.
3. **Kesehatan terpantau.** Log harian dan tren berat memberi sinyal dini
   saat kondisi hewan berubah.
4. **Dokumen rapi.** Foto kartu vaksin dan dokumen penting tersimpan lokal
   per hewan.

Di luar lingkup: booking klinik, direktori dokter, backend atau akun.
Bukan alat diagnosis medis hewan.

## 2. Aktor dan peran

| Aktor | Sifat | Kemampuan |
|---|---|---|
| Pemilik hewan | Tanpa akun | Kelola profil, jadwal, vet, log, berat, dokumen |
| Keluarga | Perangkat yang sama | Catat dan lihat hewan bersama |
| Dokter hewan | Menerima info | Membaca riwayat yang ditunjukkan pemilik |

Tidak ada peran berbasis server.

## 3. Glosarium domain

- **Pet.** Profil hewan: nama, spesies, ras, tanggal lahir, foto.
- **Jadwal perawatan.** Vaksin, obat cacing, anti-flea, dan grooming
  dengan tanggal jatuh tempo.
- **Kunjungan vet.** Catatan periksa: tanggal, dokter, diagnosis, biaya.
- **Log harian.** Catatan makan, aktivitas, dan kondisi harian.
- **Berat badan.** Rekam timbang rutin untuk melihat tren.
- **Dokumen lokal.** Foto kartu vaksin dan berkas penting per hewan.

## 4. Aturan bisnis

1. Satu aplikasi mendukung banyak hewan dengan switcher profil.
2. Jadwal selesai wajib mencatat tanggal aktual, bukan sekadar status.
3. Semua data kesehatan hewan menetap di perangkat pemilik.
4. Tanpa backend, tanpa akun, tanpa sinkronisasi cloud.
5. Aplikasi bukan pengganti diagnosis dokter hewan; ada penafian jelas.
6. Backup JSON wajib bisa diimpor kembali tanpa kehilangan data.

## 5. Risiko dan batasan

- Tanpa sinkron antar perangkat; pindah HP memakai file backup.
- Pengingat jadwal hanya seakurat data yang dimasukkan pemilik.

## 6. Kebutuhan bisnis (§TRACE)

ID di kolom pertama adalah SSOT `BR-NNN`; kolom terakhir menunjuk kebutuhan
produk di [PRD](./PRD.md) yang merealisasikannya.

| ID | Kebutuhan bisnis | Direalisasikan oleh |
|---|---|---|
| BR-001 | Perawatan tidak terlewat: jadwal vaksin, cacing, flea, dan grooming dengan jatuh tempo jelas; selesai mencatat tanggal aktual. | FR-002 |
| BR-002 | Riwayat siap ditunjukkan: kunjungan vet, diagnosis, obat, dan biaya per hewan. | FR-003 |
| BR-003 | Kesehatan terpantau lewat log harian dan tren berat. | FR-004 |
| BR-004 | Dokumen penting tersimpan rapi per hewan. | FR-005 |
| BR-005 | Satu aplikasi untuk banyak hewan dengan pemilih profil. | FR-001 |
| BR-006 | Data tetap milik pemilik: lokal, tanpa akun, penafian bukan diagnosis, cadangan bisa diimpor kembali. | FR-006, NFR-001 |
