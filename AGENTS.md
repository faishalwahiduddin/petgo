# CLAUDE.md — PetGo

## Overview
PetGo — Pet manager: profil hewan, jadwal perawatan (vaksin/cacing/flea/grooming), kunjungan vet, log harian, berat, dan dokumen lokal. **Tanpa backend, tanpa akun.** Offline-first.

**Subdomain:** petgo.faishal.id · **CF Project:** `petgo-faishal` · **appId:** `id.faishal.petgo`
**Git remote:** `git@github.com:faishalwahiduddin/petgo.git`

## Tech Stack
**Flutter 3.44.8 · Dart 3.12.2 · Riverpod 3.x · GoRouter · Cloudflare**

## Rules
1. Feature-first under `lib/features/` + `lib/core/`.
2. Offline-first SharedPreferences JSON (`petgo_*` keys).
3. No dev servers/builds unless explicitly asked.
4. §VAL on every form/mutation.
5. CLI: `gh-faishal`, `wrangler-faishal`.
6. §VER: `python3 ../tools/bump_version.py petgo patch`; UI via `package_info_plus`.
