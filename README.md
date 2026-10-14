# PetGo

> PetGo — Personal Vehicle Garage & Maintenance Manager: pencatat riwayat servis, penggantian oli, konsumsi BBM, jadwal pajak/STNK/asuransi, dan odometer untuk seluruh armada mobil dan motor keluarga.

Part of the **faishal.id** fleet (Lifestyle Utility Go-Series).

- **Production / Web**: https://petgo.faishal.id
- **Application ID**: `id.faishal.petgo`
- **Repository**: private `faishalwahiduddin/petgo`

## Tech Stack
- **Framework**: [Flutter](https://flutter.dev) (Web, Android, iOS)
- **Language**: [Dart](https://dart.dev)
- **State Management**: [Riverpod](https://riverpod.dev)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Platform Deploy**: Cloudflare Pages (`petgo-faishal`)

## Fitur Utama / Key Features
1. **Garasi Mobil & Motor Multi-Kendaraan**: Tambah dan pantau seluruh mobil dan motor keluarga dalam satu dasbor rapi.
2. **Riwayat Servis & Penggantian Oli**: Catat kilometer ganti oli mesin, oli gardan/transmisi, filter oli, kampas rem, ban, dan aki dengan estimasi jadwal servis berikutnya.
3. **Pencatat Konsumsi BBM (Fuel Log)**: Hitung efisiensi bahan bakar (km/liter) dan biaya pengeluaran per kilometer secara otomatis.
4. **Pengingat Pajak STNK & Asuransi**: Hitung mundur jatuh tempo Pajak Kendaraan Bermotor (PKB tahunan) dan pergantian pelat nomor 5 tahunan.
5. **100% Offline & Privat**: Seluruh data tersimpan aman secara lokal di perangkat Anda.

## Getting Started

```bash
flutter pub get
flutter test
flutter analyze
```

## Agent Guides
- [`AGENTS.md`](./AGENTS.md) — Comprehensive guide for AI coding agents.
- [`CLAUDE.md`](./CLAUDE.md) — Quick developer reference.
- [`GEMINI.md`](./GEMINI.md) — Antigravity & Gemini instructions.

## License
Private repository © Faishal Wahiduddin. All rights reserved.
