# AGENTS.md — PetGo (petgo)

> Guidelines for AI agents working in this Flutter codebase.
> Workspace root: `../` · Canonical fleet guide: [`../AGENTS.md`](../AGENTS.md)

## Mulai di sini (60 detik)

<!-- trace:begin start-here -->
- **App**: `petgo` (PetGo) — Pet manager: profil hewan, jadwal perawatan (vaksin/cacing/flea/grooming), kunjungan vet, log harian, berat, dan dokumen lokal. **Tanpa backend, tanpa akun.** Offline-first.
- **Platform & jalankan**: Flutter Web (Cloudflare Pages `petgo-faishal` → https://petgo.faishal.id) + Android + iOS. `flutter run -d chrome` untuk web, `flutter run -d <device>` untuk mobile. applicationId: `id.faishal.petgo`.
- **Branch**: `main` = default dan rilis.
- **Cek**: `flutter analyze && flutter test` sebelum commit — wajib nol peringatan.
- **CLI**: `gh-faishal` (remote `faishalwahiduddin/petgo`) dan `wrangler-faishal` — jangan bare `gh`/`wrangler`.
- **Validasi (§VAL)**: Di setiap project tanpa kecuali, setiap input, form, dan mutation wajib divalidasi di frontend dan backend.
- **Versi (§VER)**: bump via `python3 ../tools/bump_version.py petgo patch` (atau `minor`/`major`) sebelum commit kode di `lib/`/`assets`/platform. SSOT = `pubspec.yaml`; UI pakai `package_info_plus`. Detail: [`../../CLAUDE.md` §VER](../../CLAUDE.md#versioning-ver).
- **Larangan**: Jangan menjalankan dev server (`flutter run`) atau `flutter build` kecuali diminta secara eksplisit oleh pengguna.
<!-- trace:end -->

## Overview
PetGo — Pet manager: profil hewan, jadwal perawatan (vaksin/cacing/flea/grooming), kunjungan vet, log harian, berat, dan dokumen lokal. **Tanpa backend, tanpa akun.** Offline-first.

**Subdomain:** petgo.faishal.id · **CF Project:** `petgo-faishal` · **appId:** `id.faishal.petgo`
**Git remote:** `git@github.com:faishalwahiduddin/petgo.git`

## Struktur repo (§ORG)

<!-- repo-layout:begin -->
- Root repo hanya **source code + konfigurasi**. Jangan membuat folder atau berkas baru di root (laporan, catatan, scratch, screenshot, ekspor).
- Rencana → `docs/plans/active/` (tuntas → `docs/plans/archive/`) · changelog → `docs/changelog/YYYY/MM/YYYY-MM-DD-<slug>.md` · test Playwright → `tests/e2e/` (Flutter: `test/`, `integration_test/`) · trace / openspec / store / QA / riset → `docs/<topik>/`.
- Screenshot & artefak QA (`test-results/`, `playwright-report/`, `qa-*`, `screenshots/`, bukti run) tidak pernah di-commit — sudah di-ignore lewat blok `repo-layout standard` di `.gitignore`.
- Berkas sementara → scratchpad sesi atau `/tmp`, bukan repo.
- Aturan lengkap: `~/projects/docs/standards.md` §ORG.
<!-- repo-layout:end -->

## Tech Stack
**Flutter 3.44.8 · Dart 3.12.2 · Riverpod 3.x · GoRouter · Cloudflare**

## Rules
1. Feature-first under `lib/features/` + `lib/core/`.
2. Offline-first SharedPreferences JSON (`petgo_*` keys).
3. No dev servers/builds unless explicitly asked.
4. §VAL on every form/mutation.
5. CLI: `gh-faishal`, `wrangler-faishal`.
6. §VER: `python3 ../tools/bump_version.py petgo patch`; UI via `package_info_plus`.

### Design Systems

Sistem desain PetGo terdokumentasi di:
- **SSOT Desain**: [`DESIGN.md`](./DESIGN.md) (pointer kanonik).
- **Panduan Token**: [`docs/reference/design-system/`](./docs/reference/design-system/) ([`foundations.md`](./docs/reference/design-system/foundations.md) + [`components.md`](./docs/reference/design-system/components.md)).
- **Implementasi Token**: [`lib/core/constants/app_colors.dart`](./lib/core/constants/app_colors.dart), [`lib/core/theme/app_theme.dart`](./lib/core/theme/app_theme.dart).

Aturan pengerjaan UI:
- Dilarang hardcode literal `Color(0x...)` di widget presentation; gunakan token yang terdokumentasi di `foundations.md`.
- Warna baru ditambahkan sebagai konstanta bernama di berkas token, bukan inline.
- Pertahankan dukungan tema terang/gelap, kontras WCAG AA, dan Dynamic Type hingga 1.6×.

<!-- mascot-sheet:begin -->
## Mascot sheet (50 poses + 50 expressions)

The full character sheet for **Pego** (anak anjing corgi ramah (corgi pup)) lives **outside this repo** in the fleet library
`../docs/mascots/sheets/petgo/` (`~/projects/faishal.id/docs/mascots/sheets/petgo/`). It is on this machine
only, not in git and not in the app bundle.

- `poses/pose-NN-<id>.png` (01 to 50) and `expressions/expr-NN-<id>.png` (01 to 50): transparent RGBA 1024x1024.
- `README.md` there: an index of every file (ID, what it shows, QA result). Pick a pose from it by meaning.
- Pose and expression lists: `../tools/mascot_kits/catalog.py`. How the sheet was made: `../tools/mascot_kits/README.md`.
- Known gaps: `expressions/expr-16-terrified-panicked.png` is a failed best attempt (see qa-log.tsv).

To use one in the app:
1. Copy only the files `lib/` uses into `assets/mascot/poses/` or `assets/mascot/expressions/` (keep the file name).
   Downscale to 512 px when shown small. Never copy the whole sheet (about 50 MB).
2. List each new subfolder under `flutter: assets:` in `pubspec.yaml`: `assets/mascot/` does not include subfolders.
3. Bump the version (§VER) from the fleet root: `python3 tools/bump_version.py petgo minor`.
<!-- mascot-sheet:end -->
