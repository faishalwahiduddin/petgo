# User flows — PetGo

> Narasi per flow (SSOT nama/role/modul: `docs/reference/system/traceability.json`; case uji: `docs/trace/flows.yaml`;
> panduan BAST: `docs/client/bast/guide/`). Matriks lengkap: `docs/reference/system/traceability-matrix.md`.

## FLOW-PET-01 — Menambah profil hewan

- Role: USR (`ROL-001`) · Modul: `MOD-001` · Story: US-001 · Kebutuhan: FR-001

1. Setujui penafian (**Saya mengerti — lanjut**).
2. **Tambah hewan** → Nama, Spesies, Ras, Berat → **Simpan**.
3. Pilih **Hewan aktif**; hapus hewan di Pengaturan men-cascade catatannya.

## FLOW-CAR-01 — Mengelola jadwal perawatan

- Role: USR (`ROL-001`) · Modul: `MOD-002` · Story: US-002 · Kebutuhan: FR-002

1. Tab **Perawatan**: jadwal dengan sisa hari.
2. **Tandai selesai** mencatat tanggal hari ini.
3. **Tambah jadwal**: Judul, jenis, Interval (bulan) → **Simpan**.

## FLOW-VET-01 — Mencatat kunjungan dokter hewan

- Role: USR (`ROL-001`) · Modul: `MOD-002` · Story: US-003 · Kebutuhan: FR-003

1. Tab **Perawatan** → **Catat vet**: Judul, Klinik, Obat, Biaya → **Simpan**.

## FLOW-DAY-01 — Mencatat log harian dan berat

- Role: USR (`ROL-001`) · Modul: `MOD-003` · Story: US-004, US-005 · Kebutuhan: FR-004

1. Tab **Harian**: **Makan**/**Jalan**/**Litter** satu ketukan.
2. **Catat berat** → Berat (kg) → **Simpan**.

## FLOW-DOC-01 — Menyimpan dokumen hewan

- Role: USR (`ROL-001`) · Modul: `MOD-004` · Story: US-006 · Kebutuhan: FR-005

1. Tab **Dokumen** → **Tambah dokumen**: Judul, jenis, kedaluwarsa, lampiran → **Simpan**.

## FLOW-SET-01 — Mencadangkan data dan mengatur pengingat

- Role: USR (`ROL-001`) · Modul: `MOD-005` · Story: US-007, US-008 · Kebutuhan: FR-006, NFR-001

1. Tab **Pengaturan**: Bahasa, Profil hewan, Pengingat perawatan, Ekspor/Impor cadangan.
