---
type: Reference
title: Design System Components
description: Component patterns and rules for PetGo.
status: active
last-updated: 2026-11-13
---

# Components — PetGo

## 1. Layar & komponen baku

- Antarmuka mengikuti spesifikasi produk di [`DESIGN.md`](../../../DESIGN.md) dan dokumen produk di `docs/`.
- Komponen bersama ada di `lib/core/ui/` dan `lib/core/a11y/`:

| Berkas | Kelas |
|---|---|
| `lib/core/a11y/text_scale.dart` | `AppTextScale` |
| `lib/core/a11y/text_scale.dart` | `NoTextScale` |
| `lib/core/ui/fleet_app_config.dart` | `FleetSlideItem` |
| `lib/core/ui/fleet_app_config.dart` | `FleetAppConfig` |
| `lib/core/ui/fleet_consent_gate.dart` | `FleetConsentGate` |
| `lib/core/ui/fleet_loading_view.dart` | `FleetLoadingView` |
| `lib/core/ui/fleet_loading_view.dart` | `FleetShimmerCard` |
| `lib/core/ui/fleet_loading_view.dart` | `FleetStateSwitcher` |
| `lib/core/ui/fleet_onboarding_screen.dart` | `FleetOnboardingScreen` |
| `lib/core/ui/fleet_press_scale.dart` | `FleetPressScale` |
| `lib/core/ui/fleet_splash_screen.dart` | `FleetSplashScreen` |
| `lib/core/ui/glass_bar.dart` | `GlassBar` |
| `lib/core/ui/press_scale.dart` | `PressScale` |
| `lib/core/ui/spring_sheet.dart` | `SpringSheetScaffold` |
| `lib/core/ui/spring_sheet.dart` | `SpringSheetHandle` |
| `lib/core/ui/stagger_fade_in.dart` | `StaggerFadeIn` |
| `lib/core/ui/stagger_fade_in.dart` | `StaggerColumn` |
| `lib/core/ui/tap_target.dart` | `TapTarget` |
| `lib/core/ui/tap_target.dart` | `TappableRow` |

## 2. Disiplin semantic tokens

- **Dilarang** menulis `Color(0x...)` literal langsung di widget presentation; pakai token dari [`foundations.md`](./foundations.md) / kelas warna & tema aplikasi.
- Bila perlu warna baru, tambahkan sebagai konstanta bernama di berkas token (lihat daftar sumber di foundations), lalu rujuk lewat nama.
- Teks status tidak boleh bergantung pada warna saja; sertakan label atau ikon.
- Ikon: pakai ikon Material/Cupertino resmi, bukan emoji.

## 3. Aksesibilitas

- Mendukung skala teks hingga 1.6× tanpa overflow.
- Target sentuh minimal 44pt (`TapTarget`).
- Animasi lewat `AppMotion.resolve` supaya `disableAnimations` dihormati.
