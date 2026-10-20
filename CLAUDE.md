# CLAUDE.md — PetGo

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
