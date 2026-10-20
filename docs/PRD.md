# PRD: PetGo — Manajer Hewan Peliharaan

## 1. Overview

**PetGo** adalah manajer hewan peliharaan: profil hewan, jadwal perawatan
(vaksin, cacing, flea, grooming), kunjungan vet, log harian, berat badan,
dan dokumen lokal. Offline-first, tanpa backend, tanpa akun.

- **Subdomain**: petgo.faishal.id
- **CF Project**: `petgo-faishal` · **appId**: `id.faishal.petgo`
- **Platform**: Web, Android, iOS
- **Repository**: `git@github.com:faishalwahiduddin/petgo.git` (private)

## 2. Problem Statement

1. **Jadwal perawatan lupa.** Vaksin ulang, obat cacing, dan grooming
   terlewat karena tidak tercatat.
2. **Riwayat vet tercecer.** Dokter hewan bertanya riwayat, pemilik hanya
   mengandalkan ingatan.
3. **Berat tak terpantau.** Perubahan berat yang drastis (tanda sakit)
   tidak terdeteksi karena tidak ditimbang rutin.

## 3. Target Users

- Pemilik kucing, anjing, dan hewan kecil di rumah
- Keluarga dengan lebih dari satu hewan
- Foster atau rescuer yang merawat banyak hewan sementara

## 4. Features

### 4.1 MVP

| Kode | Fitur | SP | Deskripsi | Lokasi kode |
|---|---|:---:|---|---|
| `US-001` | **Shell + profil hewan** | 3 | CRUD hewan + foto + spesies/ras | `lib/features/` |
| `US-002` | **Jadwal perawatan** | 5 | Vaksin, cacing, flea, grooming + jatuh tempo | `lib/features/` |
| `US-003` | **Kunjungan vet** | 3 | Tanggal, dokter, diagnosis, biaya, resep | `lib/features/` |
| `US-004` | **Log harian** | 3 | Makan, aktivitas, kondisi, catatan | `lib/features/` |
| `US-005` | **Berat badan** | 2 | Timbang rutin + grafik tren | `lib/features/` |
| `US-006` | **Dokumen lokal** | 2 | Foto kartu vaksin dan dokumen via file | `lib/features/` |
| `US-007` | **Ekspor/impor** | 2 | Backup JSON via share + FilePicker | `lib/features/` |
| `US-008` | **i18n** | 3 | 8 bahasa (id, en, ar, jv, su, zh, ja, es) | `lib/l10n/` |

### 4.2 Di luar cakupan

- Pengingat push server-side (notifikasi lokal bila didukung platform)
- Direktori dokter hewan atau booking klinik
- Backend, akun, sinkronisasi cloud

### 4.3 Kebutuhan produk (§TRACE)

`FR`/`NFR` di kolom pertama adalah SSOT; kolom berikutnya menunjuk `BR` asal
([BRD](./BRD.md)) dan story/flow yang merealisasikannya
([user-flows](./reference/specs/user-flows.md)).

| ID | Kebutuhan | Asal | Realisasi |
|---|---|---|---|
| FR-001 | Profil hewan (nama 2–50 karakter, spesies, ras, berat 0–500 kg, tanggal lahir); hewan pertama otomatis aktif; hapus men-cascade semua catatan; hewan terakhir tidak bisa dihapus. | BR-005 | US-001, FLOW-PET-01 |
| FR-002 | Jadwal perawatan (judul wajib, interval ≥ 1 bulan) dengan status aman/segera (≤ 14 hari)/terlewat; tandai selesai mencatat tanggal hari ini. | BR-001 | US-002, FLOW-CAR-01 |
| FR-003 | Kunjungan vet (judul wajib, klinik, obat, biaya opsional) terurut terbaru. | BR-002 | US-003, FLOW-VET-01 |
| FR-004 | Log harian satu ketukan (makan, jalan, litter) dan catatan berat 0–500 kg yang memperbarui profil hewan aktif. | BR-003 | US-004, US-005, FLOW-DAY-01 |
| FR-005 | Dokumen per hewan (judul wajib, jenis, masa berlaku opsional, lampiran). | BR-004 | US-006, FLOW-DOC-01 |
| FR-006 | Ekspor/impor cadangan; berkas app lain, tanpa hewan, atau JSON mentah ditolak; pengingat perawatan; 8 bahasa. | BR-006 | US-007, US-008, FLOW-SET-01 |
| NFR-001 | Offline-first: data hanya di `shared_preferences` perangkat; data korup dibaca sebagai kosong. | BR-006 | FLOW-SET-01, FLOW-VET-01 |

## 5. Data Model

| Model | Isi |
|---|---|
| `Pet` | id, name, species, breed, birthDate, photoPath |
| `CareSchedule` | id, petId, kind, dueDate, doneDate, notes |
| `VetVisit` | id, petId, date, vet, diagnosis, cost, prescription |
| `DailyLog` | id, petId, date, meals, activity, condition, notes |
| `WeightRecord` | id, petId, date, weightKg |

Penyimpanan: SharedPreferences JSON dengan kunci `petgo_*`. Foto dan
dokumen di penyimpanan lokal perangkat. Bukan alat diagnosis medis hewan.

## 6. User Flows

1. **Daftarkan hewan.** Isi nama, spesies, tanggal lahir → profil tampil
   di beranda → jadikan hewan aktif.
2. **Jadwalkan perawatan.** Pilih jenis (vaksin/cacing/grooming) → isi
   jatuh tempo → tandai selesai + tanggal aktual.
3. **Ke dokter.** Catat kunjungan + diagnosis + biaya → riwayat terkumpul
   per hewan untuk ditunjukkan ke vet berikutnya.
4. **Pantau berat.** Timbang rutin → catat → grafik menunjukkan tren naik
   atau turun.

## 7. Validasi (§VAL)

- Nama hewan wajib non-kosong; spesies wajib dari daftar terdaftar.
- Tanggal lahir tidak boleh di masa depan.
- Berat wajib angka positif dalam rentang wajar per spesies.
- Biaya vet wajib angka non-negatif.
- Jadwal yang selesai wajib punya tanggal aktual yang valid.

## 8. Acceptance Criteria

- [ ] Jadwal jatuh tempo tampil urut dari yang terdekat per hewan.
- [ ] Riwayat vet lengkap bisa ditunjukkan saat kontrol berikutnya.
- [ ] Grafik berat mencerminkan seluruh catatan yang valid.
- [ ] `flutter analyze` nol peringatan, `flutter test` hijau.
- [ ] Seluruh data menetap di perangkat; tanpa akun.

## 9. Technical Constraints

- Offline-first; SharedPreferences JSON (`petgo_*`), tanpa http inti.
- MVVM + Riverpod + GoRouter feature-first.
- Tanpa backend, tanpa akun.
- CLI: `gh-faishal`, `wrangler-faishal`.
- Version: `python3 ../tools/bump_version.py petgo patch`.
