# Banner master prompt — PetGo

Use this as the **system / style lock** for every blog banner for `petgo`.
Fill the ARTICLE block per package, then paste into Gemini Images (or any image model).

## Brand tokens (from `web-landing/style.css`)

| Token | Value |
|-------|-------|
| primary | `#059669` |
| secondary | `#34D399` |
| accent | `#F59E0B` |
| bg_dark | `#022C22` |
| accent_rgb | `245, 158, 11` |
| subdomain | `petgo.faishal.id` |

## Visual system (matches fleet Chrome banners)

Existing fleet banners are **1200×675** editorial cards:

- Dark atmospheric base (`bg_dark`) with soft radial glows using `accent` / `primary`
- Subtle grid pattern at low opacity (`rgba(accent_rgb, ~0.05)`)
- Left: badge + bold title + short description + footer `petgo.faishal.id · Offline-first · Privasi Terjaga`
- Right: glassmorphism “product card” (blurred panel, thin accent border, progress/checklist motif)
- Typography feel: Plus Jakarta Sans weight 800 titles, clean sans UI chrome (illustrated, not a real screenshot)
- No cluttered text walls; title may appear in the image sparingly or not at all if the model adds noise

Domain mood for `petgo`: **warm household organization, soft daylight, intimate but not cutesy**
Motifs: shared calendars, bottles/feeding timers, pet tags, two-person checklists
Avoid: stock family smiles, baby-face closeups, cartoon mascots unless brand has one

## Master prompt (copy below)

```text
Editorial blog hero image, exactly 1200x675, 16:9, ultra-clean product marketing still.

Brand: PetGo (petgo.faishal.id).
Color script: background #022C22, primary #059669, secondary #34D399, accent #F59E0B. Soft radial glows and a faint technical grid. Glassmorphism card on the right with accent border.

Mood: warm household organization, soft daylight, intimate but not cutesy.
Motifs: shared calendars, bottles/feeding timers, pet tags, two-person checklists.
Style lock: dark premium editorial, offline-first privacy apps by faishal.id, no stock-photo people faces, no real phone UI screenshot, no watermark, no busy typography, no purple SaaS gradient cliché.

Composition: left negative space for title overlay OR minimal elegant title; right a single frosted glass info card suggesting the article topic with progress bars / checklist / compass / journal fields as abstract UI (illustrated).

ARTICLE TOPIC: {{ARTICLE_TITLE}}
ARTICLE ANGLE: {{IDEA_TYPE}} — keyword {{KEYWORD}}
ONE-LINE SCENE: {{SCENE_HINT}}

Output: single image, sharp, high contrast, ready as og:image / blog banner.
```

## Article fill-in rules

1. `ARTICLE_TITLE` = Indonesian H1 (or English if generating EN-only creative).
2. `IDEA_TYPE` = how-to | glossary | checklist | comparison | persona.
3. `KEYWORD` = primary SEO keyword from schedule TSV.
4. `SCENE_HINT` = one concrete noun phrase (e.g. “weekly amal review checklist on a dark glass card”).
5. Keep text inside the image minimal; HTML page already carries the real title.
6. Export JPEG 1200×675 (crop with `sips` if the model returns another size).
7. Save as `_queue/{package_id}/banner.jpg` then promote/inject.

## Fallback (no Gemini)

Use fleet Chrome renderer:

```bash
python3 tools/generate_all_article_banners.py --queue petgo
```

That path rebuilds the same glass-card layout from CSS tokens without an external image model.
