---
type: Reference
title: Design System Foundations
description: Visual tokens and theme for PetGo.
status: active
last-updated: 2026-11-13
---

# Foundations — PetGo

SSOT: [`DESIGN.md`](../../../DESIGN.md) · Panduan ini diturunkan dari kode tema yang ada, bukan sebaliknya: bila nilai di sini berbeda dengan kode, kodelah yang benar — perbarui dokumen ini.

## Sumber token di kode

- [`lib/core/constants/app_colors.dart`](../../../lib/core/constants/app_colors.dart)
- [`lib/core/theme/app_theme.dart`](../../../lib/core/theme/app_theme.dart)
- [`lib/core/theme/app_motion.dart`](../../../lib/core/theme/app_motion.dart) (durasi & kurva gerak)

## Tema

- **Material 3** (`useMaterial3: true`).
- **Terang + gelap**: `theme` dan `darkTheme` dipasang di `lib/main.dart`.

## Palet warna

Nilai dibaca dari konstanta `Color(0x…)` di berkas sumber. Gunakan lewat nama token, jangan menyalin heksa.

### `app_colors.dart`

| Token | Nilai | Catatan |
|---|---|---|
| `primary` | `#5B7F5A` |  |
| `primaryLight` | `#7A9E78` |  |
| `primaryDark` | `#3E5A3D` |  |
| `secondary` | `#2A332B` |  |
| `accent` | `#D4A373` |  |
| `accentLight` | `#E4C3A0` |  |
| `success` | `#10B981` |  |
| `warning` | `#F59E0B` |  |
| `danger` | `#EF4444` |  |
| `bgDark` | `#121816` |  |
| `bgSurface` | `#1E2420` |  |
| `bgCard` | `#242C26` |  |
| `border` | `#334038` |  |
| `textDarkPrimary` | `#F5F7F5` |  |
| `textDarkSecondary` | `#A8B5AA` |  |
| `textDarkMuted` | `#6F7C72` |  |
| `bgLight` | `#F7F4EF` |  |
| `bgLightSurface` | `#FFFFFF` |  |
| `bgLightElevated` | `#EEE9E1` |  |
| `borderLight` | `#E2DBD0` |  |
| `textLightPrimary` | `#1F2A22` |  |
| `textLightSecondary` | `#5C6B5E` |  |
| `textLightMuted` | `#8A968C` |  |

## Tipografi

- Tidak ada keluarga font kustom ter-bundle di `pubspec.yaml`; teks memakai font bawaan platform.

## Radius

Nilai `BorderRadius.circular(...)` yang dipakai di tema/`main.dart`: `10`, `12`, `16`, `20`, `24`.

## Motion

Dari `AppMotion`: `fast` 150 ms, `base` 250 ms, `slow` 350 ms. Selalu resolve lewat `AppMotion.resolve(context, d)` agar mode reduced-motion dihormati (durasi menjadi nol).

## Aksesibilitas

- `AppTextScale` (`lib/core/a11y/text_scale.dart`) membatasi skala teks platform maksimum 1.6×; setiap layar harus bertahan di 1.6× tanpa terpotong.
- Target sentuh minimal 44pt lewat `TapTarget` (`lib/core/ui/tap_target.dart`).
- Kontras teks minimal WCAG AA 4.5:1 di kedua tema (DS-6).
