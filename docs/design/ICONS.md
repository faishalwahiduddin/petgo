# PetGo icon set

Custom SVG icons for bottom navigation and companion pet care tracker glyphs (pet profiles, veterinary schedules, daily logs, pet passports/docs, feeding bowls, walking leashes, and scales). Files live in `assets/icons/` (bundled); render them with `AppIcon('name')` (`lib/core/ui/app_icon.dart`). Preview sheet: `test/icons/goldens/icon_sheet.png` (regenerate with `flutter test test/icons/icon_set_test.dart --update-goldens`).

## Style spec

- **Personality:** playful, warm, loving, dependable companion care (Dinda, 31, loving pet parent to Milo the dog & Luna the cat).
- **Grid:** 24x24, `viewBox="0 0 24 24"`, 2px safe padding (live area 2–22).
- **Stroke:** 1.75, `stroke-linecap="round"`, `stroke-linejoin="round"`.
- **Corners:** friendly rounded curves (radius 1.5–3), organic paw pads, soft bowl rims, reassuring vet crosses.
- **Fill:** outline + duotone. Secondary shape (pad fills, bowl interior, doc seal, calendar header, medicine coat) is filled at `fill-opacity="0.25"` to `0.3`.
- **Colour:** draw only with `currentColor`; `AppIcon` tints with `BlendMode.srcIn`, so only alpha matters. No `<style>`, text, raster, root transforms or width/height.
- **Nav states:** inactive = pure outline (`nav_x`); selected = same outline plus duotone secondary fill (`nav_x_active`). Domain icons always use the duotone variant.

## Inventory

| File | Meaning | Used in |
|------|---------|---------|
| `nav_pets(_active)` | Companion pet profile outline with cat/dog ear silhouette | nav tab Hewan (Pets) |
| `nav_care(_active)` | Pet care medical cross with heart emblem | nav tab Perawatan (Care) |
| `nav_daily(_active)` | Daily routine calendar pad with feeding dish | nav tab Harian (Daily) |
| `nav_docs(_active)` | Pet health passport folder with paw badge | nav tab Dokumen (Docs) |
| `nav_settings(_active)` | Clean mechanical gear with central axle | nav tab Pengaturan (Settings) |
| `pet_paw` | Friendly pet paw print with main pad and four toes | Avatar fallback, empty states, pet chip |
| `meal_bowl` | Elevated pet feeding dish with food mound | Daily quick log: Makan (feed) |
| `dog_leash` | Pet collar with lead strap and clip | Daily quick log: Jalan (walk) |
| `litter_box` | Litter tray with hygiene scoop handle | Daily quick log: Pasir / Kebersihan (litter) |
| `pet_scale` | Digital veterinary weight scale with paw emblem | Weight recording header & history |
| `vet_clinic` | Veterinary clinic shelter with medical cross | Vet visit log & clinic expense card |
| `pet_vaccine` | Vaccine syringe with dosage calibration lines | Vaccination schedules (rabies, FVRCP) |
| `pet_meds` | Deworming tablet & capsule pair | Medication & deworming schedules (obat cacing) |

Kept as standard Material/Cupertino icons: back, close, chevron, search, share, delete, edit, more (three dots), add (+), check.
