# PetGo — Graphic Assets Checklist

All Play graphic requirements. Source icon: `petgo/assets/icon/icon.png` (1024×1024).

| Asset | Spec | Required | How | Status |
|-------|------|----------|-----|:------:|
| App icon | 512×512 PNG (32-bit, alpha) | ✅ | Resize source icon → `metadata/android/<loc>/images/icon.png` | ☐ |
| Feature graphic | 1024×500 PNG/JPG | ✅ (featuring) | `screenshots/feature-graphic.html` → capture | ☐ |
| Phone screenshots | 1080×1920, 4 per locale (panorama set) | ✅ | `capture-slides.mjs` (studio: `screenshots/index.html`) | ☐ |
| 7-inch tablet | 1200×1920, up to 8 | optional | `screenshots/tablet.html?size=7` → capture | ☐ |
| 10-inch tablet | 1600×2560, up to 8 | optional | `screenshots/tablet.html?size=10` → capture | ☐ |
| iPhone 6.9" (App Store) | 1290×2796, 4 per locale | ✅ | `capture-slides.mjs --only=iphone69` → `metadata/ios-screenshots/` | ☐ |
| iPad 13" (App Store) | 2064×2752, 4 per locale | ✅ | `capture-slides.mjs --only=ipad13` → `metadata/ios-screenshots/` | ☐ |

### Notes
- Play accepts phone screenshots 320–3840px per side; **1080×1920 (9:16)** is the studio default.
- Provide screenshots per locale where the UI/captions differ (studio switches language).
- Resize the 512 icon with: `sips -z 512 512 assets/icon/icon.png --out store/metadata/android/id/images/icon.png` (macOS) or ImageMagick `convert`.
- Icon must have **no rounded corners / no alpha shadow baked in** beyond Play's masking expectations.
