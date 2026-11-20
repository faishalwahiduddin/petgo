# Design Audit — PetGo

**Date:** 2026-11-20 · **Version:** 1.1.1+14 · **Grade: 56.7 / 100 — F**
**Mode:** deep (all 8 screens + shared widgets + tokens + real renders + Mobbin)
**Reviewer stance:** senior mobile designer. Grades are earned; "looks fine" is a C at best.

> **Read the grade correctly.** User-facing severity is **D**: the app is calm, legible, and
> obviously a pet-care tool. System-integrity severity is **F** for three measurable reasons:
> the due-ness status text fails WCAG AA at 2.15:1–3.76:1, the four pet-data screens carry
> **zero** `Semantics` for their own content, and none of the five tabs can tell you *which
> animal* it is editing. The first two are cheap to fix; the third is a data-integrity bug
> wearing a UI costume.

---

## 1. Snapshot

| Field | Value |
|---|---|
| Product | PetGo — pet profiles, care schedules (vaccine/deworming/flea/grooming), vet visits, daily logs, weight, local documents |
| Version | `1.1.1+14` |
| Platform | Flutter Web (CF Pages) + Android + iOS · Material 3 · light + dark |
| Dart files | 56 |
| Routes / screens | 8 routes / 8 screen classes (5 product tabs + splash + 2 onboarding) |
| Router | `lib/core/router/app_router.dart` — `StatefulShellRoute.indexedStack`, 5 branches, splash/onboarding on the root navigator |
| State | Riverpod; offline-only (`shared_preferences` JSON, `petgo_*` keys) |
| Locales | 8 (`id, en, ar, jv, su, zh, ja, es`) |
| Design tokens | `lib/core/constants/app_colors.dart` (23 tokens) + `lib/core/theme/app_theme.dart` (290 L) + `app_motion.dart` — **2 of 12** standard token files (T3) |
| Documented system | `DESIGN.md` → `docs/reference/design-system/{foundations,components}.md` |
| Test rigour | 10 test files incl. store renders, landscape, overflow, trace cases — store renders prove the screenshots are the real app |

**The number that matters most here is the one familygo failed:** `Color(0x…)` in presentation.

| Layer | `Color(0x…)` literals |
|---|---|
| `lib/features/**` (all 5 product screens) | **0** |
| `lib/core/ui/**` (fleet-shared widgets) | 27 |
| `lib/core/constants/app_colors.dart` (legal token file) | 23 |
| **total** | **50** |

PetGo is the **cleanest app in the fleet on this axis** — the screens use named tokens, not raw
hex. The defect is one layer deeper: screens use `AppColors.primary` (21 references) instead of
`Theme.of(context).colorScheme` (**2** references), so dark mode silently keeps the light-mode
green. That is covered in §6/§7, not as colour slop.

---

## 2. Sitemap

Generated from `lib/core/router/app_router.dart`.

```
/splash                     → FleetSplashScreen        core/ui/fleet_splash_screen.dart (303)
/onboarding                 → OnboardingPage           features/onboarding/onboarding_page.dart (28)
/fleet-onboarding           → FleetOnboardingScreen    core/ui/fleet_onboarding_screen.dart (968)
/                           → HomeScreen               features/home/home_screen.dart (419)
/care                       → CareScreen               features/care/care_screen.dart (453)
/daily                      → DailyScreen              features/daily/daily_screen.dart (197)
/docs                       → DocsScreen               features/docs/docs_screen.dart (220)
/settings                   → SettingsScreen           features/settings/settings_screen.dart (198)
```

Structural notes:

- **Shell is correct.** `StatefulShellRoute.indexedStack` (`app_router.dart:50`) gives each of the
  5 tabs its own Navigator, so state survives tab switching. 8 nodes, 0 unrouted screens.
- **The shell has no pet context.** The 5 branches are flat siblings (`app_router.dart:54-95`);
  the active pet lives in a provider (`app_providers.dart:121-127`), not in the route and not in
  the chrome. Every screen therefore renders "care" or "daily" with no owner.
- **No entity routes.** A pet, a schedule, a vet visit and a document have no URL. All detail is a
  `showModalBottomSheet` (`home_screen.dart:198`, `care_screen.dart:194,336`,
  `docs_screen.dart:103`). Nothing can be deep-linked or restored.
- **`Navigator.push` = 0** — good discipline, but it is also 0 because nothing pushes to a detail
  page. All navigation is `goBranch` (`navigation_shell.dart:17-22`).
- **Onboarding is two screens with different jobs.** `/onboarding` is the consent gate
  (`onboarding_page.dart:17-26`); `/fleet-onboarding` is the marketing tour. The consent copy is a
  *privacy* disclaimer only (`l10n/app_localizations_id.dart:36-38`) — there is no veterinary
  disclaimer anywhere (§4.2, §10).

---

## 3. Screen inventory

| # | Route | Screen | LOC | Archetype | Primary action | Loading | Empty | Error | Offline |
|---|---|---|---|---|---|---|---|---|---|
| 1 | `/` | HomeScreen | 419 | Dashboard / pet switcher | pick active pet | ✗ | bare text (`:53,:113`) | snackbar on save (`:383`) | ✗ |
| 2 | `/care` | CareScreen | 453 | List + inline editor | mark done / add schedule | ✗ | bare text (`:60,:135`) | snackbar (`:311`) | ✗ |
| 3 | `/daily` | DailyScreen | 197 | Quick-log + timeline | tap a log chip | ✗ | bare text (`:85`) | snackbar (`:176`) | ✗ |
| 4 | `/docs` | DocsScreen | 220 | List / vault | add document (FAB) | ✗ | bare text (`:39-45`) | snackbar (`:214`) | ✗ |
| 5 | `/settings` | SettingsScreen | 198 | Settings | export / restore | ✗ | n/a | snackbar (`:146`) | n/a |
| — | `/splash` | FleetSplashScreen | 303 | Launch | — | — | — | — | — |
| — | `/onboarding` | OnboardingPage | 28 | Consent gate | accept | — | — | — | — |
| — | `/fleet-onboarding` | FleetOnboardingScreen | 968 | Marketing tour | finish | — | — | — | — |

**Loading is absent on all five product screens; error is a SnackBar, never a designed state;
offline is never acknowledged** — which is remarkable for an app whose entire pitch is offline.
Backup import (`settings_screen.dart:139-161`) and photo/document picking
(`home_screen.dart:231-242`, `docs_screen.dart:174-179`) are fallible, async operations that show
no progress and no recovery state beyond a toast. The fleet's `FleetLoadingView` /
`FleetStateSwitcher` exist (`docs/reference/design-system/components.md:23-25`) and are used **0
times** here.

---

## 4. Screen anatomy

Values below are the ones actually in code, not the intended ones.

### 4.1 Home (`home_screen.dart`)

| Section | Components | Values | Verdict |
|---|---|---|---|
| App bar | `AppBar(title: Text(l10n.appTitle))` (`:31`) | 18/w700 theme | Title is the app name, not the job; "PetGo" tells a returning user nothing new |
| Active-pet header | `Text(homeActivePet)` + `TextButton.icon` "Add pet" (`:35-51`) | label 14, `AppColors.primary` text | `primary #5B7F5A` on cream `#F7F4EF` = **4.14:1** — under AA for 14sp text |
| Pet selector | `DropdownButtonFormField` (`:56-74`) | 16 default | Deprecated `value:` (`:57`); the selected pet is one tap away from invisible |
| Active pet card | `ListTile`: avatar 24, name 20/w700, meta `species · breed · 12.8 kg · Oct 2, 2024` (`:77-103`) | name 20, meta default | Weight has one decimal (good); **DOB is a raw date where age belongs** |
| Due soon | `Card`+`ListTile` per schedule, icon+title+status (`:105-136`) | status uses `danger`/`warning` (`:125-126`), text default 14 | **Not sorted** — the list keeps insertion order, so an overdue item can sit below a due-soon one. No countdown for overdue ("Overdue", never "3 days late") (`:129-133`) |
| All pets | `Card`+`ListTile`, `selected:` highlight (`:145-161`) | — | Third presentation of the same entity on one screen (header dropdown + active card + list) |
| Pet editor | bottom sheet, avatar picker, name/species/breed/weight/DOB (`:182-388`) | title 18/w700 (`:223-226`) | Weight validated 0–500 (`:309-316`); name ≥2 (`:269-274`); this is the best form in the app |

### 4.2 Care (`care_screen.dart`)

| Section | Components | Values | Verdict |
|---|---|---|---|
| App bar | `AppBar(title: Text(l10n.navCare))` (`:35`) | 18/w700 | **Says "Care", never whose.** The schedules below belong to the hidden active pet |
| Schedules header | title + "Add schedule" (`:40-58`) | primary | — |
| Schedule row | `ListTile`: title, `kind · every N mo`, trailing `[countdown][check]` (`:66-113`) | countdown **12/w600** (`:90`), coloured by urgency (`:84-88`) | Sorted by `daysRemaining` (`:26`) — correct. Long-press deletes (`:107-110`) with no confirm and no undo |
| Status colour | `success`/`warning`/`danger` (`:85-88`) | `#10B981` **2.54:1**, `#F59E0B` **2.15:1**, `#EF4444` **3.76:1** on white | All three **fail WCAG AA at 12sp**, and colour is the loudest signal on the row |
| Vet & meds | title + "Log vet visit" (`:115-133`) | primary | — |
| Vet row | title + `clinic · medication · Rp · date` (`:141-158`) | cost via `PetFormat.rupiah` (`:150`) | Cost separator good (`Rp185,000`); no attachments, no reason-vs-diagnosis split, no detail view |
| Schedule editor | title/kind/interval/last-done (`:180-318`) | — | Interval is a free integer; **no species template, no veterinary disclaimer** |
| Vet editor | title/clinic/medication/cost/notes/date (`:320-452`) | cost `number` only (`:384`) | Cost is parsed with no grouping validation; notes cap 2 lines |

### 4.3 Daily (`daily_screen.dart`)

| Section | Components | Values | Verdict |
|---|---|---|---|
| App bar | `AppBar(title: Text(l10n.navDaily))` (`:31`) | 18/w700 | **No pet identity**; every tap below writes to the hidden active pet |
| Quick log | 3× `ActionChip` Meal/Walk/Litter (`:43-69`) | icon 18 | Tap = instant write, no confirm, no haptic, no undo. "Two taps" claim (`iphone69-3`) is true only because there is no confirmation step |
| Log weight | `OutlinedButton.icon` (`:71-75`) | — | Opens a bare `AlertDialog` + `TextField` (`:153-173`); validation is parse-only in the dialog (`:175-181`), range enforced later by the provider (`app_providers.dart:245-248`) |
| Timeline | `Card`+`ListTile`, icon+label+`date · HH:mm` (`:89-100`) | — | Flat 30-row feed (`take(30)`), no day grouping; long-press delete (`:96-97`) |
| Weight history | `ListTile` list, `12.8 kg` + timestamp (`:101-124`) | one decimal (`:113`) | **A list, not a trend.** No chart, no delta, no axis, no period — you cannot see whether the dog is gaining |

### 4.4 Docs (`docs_screen.dart`)

| Section | Components | Verdict |
|---|---|---|
| App bar | `AppBar(title: Text(l10n.navDocs))` (`:29`) | No pet identity |
| List | `Card`+`ListTile`: icon, title, `kind · Expires: <date> · has file` (`:59-79`) | **Expiry is a raw date** (`:69-70`) — no "expires in 40 days", no "expired" state |
| Empty | `Center(Text(docsEmpty))` (`:39-45`) | Bare sentence, no icon, no CTA that points at the FAB |
| FAB | `FloatingActionButton.extended` padded by `kShellNavBarHeight` (`:30-38`) | Correctly clears the glass nav |
| Editor | title/kind/expiry/file picker (`:91-219`) | File is a path string; attachments are not previewed |

### 4.5 Settings (`settings_screen.dart`)

- Sections: Language (`:28`), Pets (`:80`), Reminders (`:106`), Backup (`:119`), then
  `UsageLicenseCard` + `CommercialContactCards` (`:164-166`).
- **Destructive delete with no confirmation** (`:87-104`): one tap on the trash icon calls
  `petsProvider.remove` (`:93-94`) which permanently cascades to every schedule, vet log, daily
  log, weight and document for that pet (`app_providers.dart:74-103`). No undo.
- Reminders switch is good (`:106-117`): it reschedules OS notifications on change.
- Backup import (`:139-161`) reloads six providers manually and shows a success toast — correct
  data handling, zero progress UI.
- Version row is honest: `PackageInfo` → `1.1.1+14` (`:168-180`).

### 4.6 Shell (`navigation_shell.dart`)

- 5 flat `NavigationDestination`s: Pets, Care, Daily, Docs, Settings (`:44-70`). Labels come from
  the theme at **11sp** (`app_theme.dart:61,67`).
- `GlassBar` + `extendBody` (`:30-40`); page padding compensates with `kShellNavBarHeight = 80`
  (`:10`). This is hand-tuned and works, but it is a magic constant duplicated into three screens
  (`home:33`, `care:38`, `docs:32,52`).

---

## 5. Visual evidence review (real renders)

Source: `docs/store/metadata/ios-screenshots/en-US/iphone69-{1..4}.png` (1290×2796) and
`ipad13-1.png` (2064×2752), produced by `test/store_screens/store_screens_test.dart` — i.e. these
are the real app inside a store frame, not mockups.

| # | Severity | Finding | Evidence | Fix |
|---|---|---|---|---|
| 1 | **CRITICAL** | The app bar on Care says only "Care"; on Daily only "Daily"; on Docs only "Docs". The pet name appears **nowhere** on those screens, yet every write is scoped to the invisible active pet. | `iphone69-2.png`, `iphone69-3.png`; code `care_screen.dart:35`, `daily_screen.dart:31`, `docs_screen.dart:29` | Persistent pet context chip in the app bar: avatar 24 + name + chevron, opening the same selector as Home |
| 2 | **HIGH** | Due-ness text is 12sp in amber/green/red that measure 2.15:1, 2.54:1, 3.76:1 on white. The most important sentence on the screen is the least readable. | `iphone69-2.png`; `care_screen.dart:83-91`; values from `app_colors.dart:11-13` | Status pill (tonal bg + 4.5:1 ink) + icon + 13sp/w700; add dark-mode tone variants |
| 3 | **HIGH** | Home's "Due soon" list is not ordered by urgency: the render happens to show 13-days-left above Overdue, but nothing in code sorts it. | `iphone69-1.png`; `home_screen.dart:25-28,113-136` | Sort by `daysRemaining` exactly as Care does (`care_screen.dart:26`) |
| 4 | **MEDIUM** | Documents show expiry as `Expires: Dec 28, 2026` — a date, not a deadline. | `iphone69-4.png`; `docs_screen.dart:69-70` | "expires in 38 days" / "expired 3 days ago" with the same urgency tokens |
| 5 | **MEDIUM** | The same pet is rendered three times on Home (header dropdown, large card, "All pets" row). | `iphone69-1.png`; `home_screen.dart:56,77,145` | Collapse to one identity band + a one-line "Manage pets" affordance |
| 6 | **MEDIUM** | iPad render is a 2064px-wide single column: cards stretch edge to edge, type stays phone-sized, and the lower half of the canvas is empty. | `ipad13-1.png`; no `maxWidth` anywhere in `lib/features` | `ConstrainedBox(maxWidth: 720)` or a 2-pane `NavigationRail` layout at ≥840dp |
| 7 | **POLISH** | Timeline rows repeat "Meal · Nov 11, 2026 · 08:41" with no day separators, so the eye cannot find "today". | `iphone69-3.png`; `daily_screen.dart:89-100` | Sticky date headers ("Today", "Yesterday", then date) |

What the renders get **right** and must not be thrown away: the cream/green palette is calm and
branded, cards use one 16dp radius with a 1px hairline (`app_theme.dart:44-52`), the empty states
are honest rather than fake, and the bottom nav is a real 5-tab shell with correct safe-area
padding. This is the most visually coherent app of the fleet sample — which makes the missing pet
identity and the failing status contrast more costly, not less.

---

## 6. Scorecard

`score = Σ(category × weight) / Σ(weight)`; a11y and touch weigh 1.5×. Auto-fails from
`SCORECARD.md:45-51` applied where noted.

| # | Category | W | P/W/F | Score | Grade |
|---|---|---|---|---|---|
| 1 | Visual hierarchy & composition | 1.0 | 4/2/3 | 55.6 | F |
| 2 | Typography | 1.0 | 4/4/4 | 50.0 | F |
| 3 | Color & theming | 1.0 | 5/3/4 | **50** (auto-capped) | F |
| 4 | Spacing & layout | 1.0 | 7/4/3 | 64.3 | D |
| 5 | Navigation | 1.0 | 7/3/1 | 77.3 | C |
| 6 | Touch & gesture | **1.5** | 4/3/3 | 55.0 | F |
| 7 | Platform conventions | 1.0 | 5/3/2 | 65.0 | D |
| 8 | Motion & animation | 1.0 | 3/4/3 | 50.0 | F |
| 9 | Content states | 1.0 | 2/4/4 | 40.0 | F |
| 10 | Accessibility | **1.5** | 2/4/5 | 36.4 | F |
| 11 | Responsive & adaptive | 1.0 | 4/3/3 | 55.0 | F |
| 12 | Performance as design | 1.0 | 6/1/1 | 81.3 | B |
| 13 | AI-slop detection | 1.0 | 4/3/1 | 68.8 | D |
| | **Weighted total** | **14.0** | | **56.7** | **F** |

Arithmetic (`Σ score×weight`; touch 55.0×1.5 = 82.5, accessibility 36.4×1.5 = 54.6):
`(55.6+50+50+64.3+77.3+82.5+65+50+40+54.6+55+81.3+68.8) / 14 = 794.4 / 14 = 56.7`.
Color's uncapped 54.2 is reduced to 50 by the "text on background under 4.5:1" auto-fail.

### Item-level failures (the ones that set the grade)

| SEVERITY | CATEGORY | Location | Issue | Fix |
|---|---|---|---|---|
| CRITICAL | Domain / hierarchy | `care_screen.dart:35`, `daily_screen.dart:31`, `docs_screen.dart:29`; writes at `care:303`, `daily:62`, `docs:205` | Three tabs write to the active pet while showing no pet identifier; `activePetProvider` silently falls back to `pets.first` (`app_providers.dart:126`) | App-bar pet chip on every pet-scoped screen; require explicit confirmation when the active pet changed in this session |
| CRITICAL | Color / a11y | `care_screen.dart:83-91` | Due-ness text at 12sp: `success` 2.54:1, `warning` 2.15:1, `danger` 3.76:1 on white | Tonal status pills with ≥4.5:1 ink; 13sp/w700 |
| CRITICAL | Accessibility | Home/Care/Daily/Docs; `MergeSemantics` 0× app-wide | No `Semantics` on any pet-data screen; the only one in `lib/features` is `commercial_contact_cards.dart:127`. Grep `Semantics(` = 9 app-wide but 3 are `ExcludeSemantics`; `semanticLabel` = 0 in product screens | `Semantics(button:true,label:'Mark <task> done')` on rows; `tooltip` on every icon button |
| HIGH | Accessibility | `home_screen.dart:97,155`; `settings_screen.dart:90`; `daily_screen.dart:117` | Edit/delete `IconButton`s have no tooltip or label — four unnamed interactive controls | Add `tooltip:` (one already exists at `care_screen.dart:95`) |
| HIGH | Touch | `settings_screen.dart:87-104` | One tap deletes a pet and cascades all its data (`app_providers.dart:74-103`) | Confirmation dialog + undo SnackBar |
| HIGH | Touch | `care_screen.dart:107-110,155-157`; `daily_screen.dart:96-97`; `docs_screen.dart:75-76` | All deletes are long-press-only: undiscoverable and unrecoverable | Swipe-to-delete with undo; move "Delete" into the edit sheet |
| HIGH | Typography | nav 11sp (`app_theme.dart:61,67`), 17 raw `TextStyle` in `lib/features`, 43 `fontSize:` declarations | No type token; body/labels mix 10.5–20 with no scale | `app_typography.dart`; floor 12sp; body 15, title 17, headline 22 |
| HIGH | Domain | `care_screen.dart:188-257` | Care interval is a free integer (default 3 mo) for every species; no core-vaccine template; no "reminder, not veterinary advice" copy anywhere (privacy-only gate at `onboarding_page.dart:17-26`) | Species/age template + disclaimer line under the schedule header and in the editor |
| HIGH | Content states | 5 screens | No loading, no error view, no offline banner; import/export/pickers are async with zero feedback | `FleetStateSwitcher` around backup + file pickers; skeleton list |
| MEDIUM | Motion | `lib/features/**` | `AppMotion` referenced 0× in features (`grep`); `HapticFeedback` 0× in features; mark-done has no confirmation motion | `AppMotion.resolve` fade on row reorder; `HapticFeedback.selectionClick()` on mark-done |
| MEDIUM | Layout | `ipad13-1.png` | Tablet = stretched phone column | `maxWidth` 720 or 2-pane |
| MEDIUM | Theming | 21 `AppColors.*` vs 2 `colorScheme` in `lib/features` | Dark mode keeps light-mode green tokens (`app_theme.dart:155-166` defines a different dark primary) | Replace `AppColors.primary` with `colorScheme.primary` in widgets |
| POLISH | AI slop | `home_screen.dart:31` etc. | App bar title is the product name, not the page job | Contextual titles ("Milo", "Care — Milo") |

---

## 7. Harsh verdict

1. **This app has a data-integrity bug that is disguised as a visual one.** Five tabs share one
   hidden "active pet"; only one of them shows which pet that is. A user who adds a vaccine from
   Care at 11pm will not discover until a vet visit that it went to the other animal. No amount of
   polish compensates for that.
2. **The visual system is the best in the sample and still fails the one test that matters.** Zero
   inline hex in screens, a real warm palette, a real dark theme — and then the status text that
   *is* the product (due in 13 days / overdue) is printed at 2.15:1 in 12sp. The craft is real;
   the measurement never happened.
3. **It is a set of five well-built forms, not a pet manager.** Weight is a list, not a trend;
   expiry is a date, not a deadline; a vet visit is one line, not a record; care schedules are
   typed by hand, not templated for a species. Everything is *stored*; almost nothing is
   *interpreted* — and interpretation is the job.

---

## 8. Competitor analysis

Scope: apps solving the same job — pet health records, care reminders, multi-pet identity. IA-level
comparison (stable across releases).

| Product | Model | Core IA | What they do that PetGo does not |
|---|---|---|---|
| **11pets** | freemium, offline-friendly | Per-pet profile with Health / Care / Documents tabs; species- and age-aware vaccine & deworming templates; weight chart with period | Care templates per species; a weight **chart**, not a list; exportable health report |
| **PetDesk** | clinic-connected | Home card = next appointment + due reminders supplied by the clinic; refill requests; pet records shared with the vet | Due reminders have a *provider* and a *time*, not just a date; one primary "next thing" card |
| **DogLog** | free + premium, household sharing | Two-tap activity logging (potty/walk/feed) with widgets and multi-dog switcher always visible | The active dog is on every logging surface; shared household log |
| **Pawtrack** | hardware + app | GPS/activity telemetry for cats: live map, zone alerts, activity trend | A trend with its own axis/period as the primary artifact — the model PetGo's weight tab needs |

**Positioning gap.** PetGo's differentiator — 100% offline, no account, no ads, local documents — is
real and worth protecting. Its weakness is that it treats "record" as the deliverable. Every
competitor above turns the same records into a *decision*: vaccinate now, refill now, this cat left
the zone, this dog is gaining weight. PetGo shows the data and stops.

Note: the repo's own competitor document, `docs/competitor-analysis-and-winner-plan.md`, is a
**vehicle/garage** study (Drivvo, Fuelio, CARFAX) — PetGo's pet-market research was never actually
done. The four products above are named from their public product IA, not from that file.

**Three moves worth copying, cheapest first**

1. **Pet identity in the chrome** (DogLog) — the active animal on every logging surface, one tap to
   switch. This is the §6 CRITICAL and the cheapest fix in the plan.
2. **Templates, then disclaimer** (11pets) — a dog/cat core-vaccine starter set, editable, with a
   one-line "reminder, not veterinary advice".
3. **A weight trend with an axis** (Pawtrack) — a 90-day line with kg ticks and a delta; the number
   already exists in `weightLogsProvider`.

---

## 9. Mobbin reference delta

Pulled via `mobbin screens … --platform ios --deep`, six references downloaded and read as images.
Every value below was read off the reference, not recalled.

### 9.1 Pet health home → Fi · `mobbin.com/screens/89958f60-b292-4cd5-8bca-69b2370f22f8`

| Dimension | PetGo | Fi | Verdict |
|---|---|---|---|
| Page identity | `AppBar` "PetGo" / "Care" / "Daily" (`home:31`, `care:35`, `daily:31`) | **"Maggie's health ⌄"** as the H1, with a chevron that switches pets | **worse** — PetGo has no per-pet identity at all |
| Pet switcher | `DropdownButtonFormField` on Home only (`home:56`) | name + chevron in the title bar, on every tab | worse — one hidden control vs persistent context |
| Section model | 3 stacked sections on Home | tabs Overview / Documents / Vets under the pet title | worse — PetGo's tabs are global, not per-pet |
| Period control | none on weight history | "Last 28 days" pill above Behaviors | **missing** — PetGo has no period control anywhere |
| Bottom nav | 5 labelled text tabs | 5 tabs, last = pet avatar | equal in count, worse in identity affordance |

### 9.2 Documents → Fi · `mobbin.com/screens/9f166570-1e69-4044-a6da-1f43c67cb315`

| Dimension | PetGo | Fi | Verdict |
|---|---|---|---|
| Identity | "Docs", no pet | **"Tilda's health ⌄"**, tabs Documents/Vets | worse |
| Row anatomy | icon + title + `kind · Expires: date · has file` (`docs:59-79`) | icon + title + `Feb 14, 2026 · $60.00` + 5 tag chips | worse — tags make a document findable; a date alone does not |
| Grouping | flat list | grouped by year ("2026") | missing |
| Add affordance | extended FAB over the list (`docs:30-38`) | "＋ Add" in the section header + "＋ Add more" inline | worse — FAB covers content; header add does not |
| Expiry semantics | raw date (`docs:69-70`) | date + cost; expiry surfaced as a tag | worse — neither is a countdown, but Fi at least classifies |

### 9.3 Vaccine reminder → CVS Health · `mobbin.com/screens/10deadb5-1561-4962-a056-b769cdfd8715`

| Dimension | PetGo | CVS Health | Verdict |
|---|---|---|---|
| Eligibility logic | free integer interval per row (`care:188-257`) | "Based on what you told us, Sam isn't eligible for a Pneumonia vaccine right now" | **worse** — PetGo has no rule, only a number the user must remember |
| Next action | mark-done check (`care:94-103`) | explicit "Would you like to schedule the COVID-19 vaccine?" + Yes/No | worse — never proposes the next step |
| Answer structure | countdown text | reason + follow-up + 2 large buttons | worse — the reference explains *why* |
| Disclaimer | absent | eligibility framed as rule-based, not a recommendation | **missing** in PetGo |

### 9.4 Multi-profile switcher → Linktree · `mobbin.com/screens/c947ba17-60a7-4beb-9d74-cf46bac0e231`

| Dimension | PetGo | Linktree | Verdict |
|---|---|---|---|
| Switcher surface | dropdown on Home only (`home:56`) | "Switch Linktrees" bottom sheet, every profile = avatar + handle + plan badge | worse — PetGo's switcher is a form control, not a set of identities |
| Current selection | dropdown value | current profile outlined, others listed | worse — no "which one am I in" cue off Home |
| Identity per row | `Milo · Dog` text | avatar 56 + handle + sub-line | worse — no avatar in the switcher |

### 9.5 Due-ness timeline → Structured · `mobbin.com/screens/26fae4e6-2163-4d93-8c47-5bd9839cb369`

| Dimension | PetGo | Structured | Verdict |
|---|---|---|---|
| Time reframing | "13 days left" / "Overdue" (`care:79-91`) | "Use 4h 1m, task approaching" | equal — both compute remaining time; Structured states the consequence |
| Temporal hierarchy | flat list | week strip with per-day glyph counts + timeline | worse — no day grouping anywhere in PetGo |
| Overdue treatment | red text only | overdue segment kept at top with a distinct marker | worse — PetGo sorts correctly in Care (`care:26`) but Home does not (`home:113`) |
| Completion feedback | check icon toggles | ring fills at the row | worse — no feedback animation |

### 9.6 Schedule editor → Apple Health · `mobbin.com/screens/97e0cc8f-ce4a-4b2a-8ff3-086a35392556`

| Dimension | PetGo | Apple Health | Verdict |
|---|---|---|---|
| Frequency input | integer months, free text (`care:246-257`) | "Every Day" plain-language row + "Change" | worse — one typo produces a 300-month reminder |
| Reminder time | OS notification only, no time field (`care_reminder_service`) | explicit time picker ("9:25 PM") + quantity | worse — the user cannot say *when* they want the nudge |
| Duration | "last done" date (`care:259-278`) | Start date + End date ("None") | equal-ish; PetGo's last-done is a reasonable pet-domain model |
| Safety copy | none | "Health will send you a notification…" | worse — no explanation of what the reminder will do |

**Cross-cutting deltas (component level)**

| Component | PetGo | Reference norm | Action |
|---|---|---|---|
| Pet context | dropdown on one screen | title + chevron / sheet, every screen | build `PetContextBar` |
| Status text | 12sp coloured text, 2.15–3.76:1 | pill with tonal bg + icon + ≥4.5:1 | build `DueChip` |
| Weight | list of values | line chart with axis + period | build `WeightTrend` |
| Document row | 1 line meta | tags + year grouping | extend `DocRow` |
| Delete | long-press only | swipe + undo | add `Dismissible` + undo |
| Frequency | integer field | plain-language preset | `ScheduleFrequencyField` |

---

## 10. Missing features, screens and components

Ranked by user value per hour of work.

### Screens missing

| Screen | Why it matters | Reference |
|---|---|---|
| **Pet detail** (`/pets/:id`) | A pet is a bottom sheet today; its care, vet and weight history have no home | Fi |
| **Care item detail** (`/care/:id`) | History of a vaccine, next due, notes, "mark done on date" | 11pets |
| **Vet visit detail** (`/care/vet/:id`) | Reason, diagnosis, cost, attachments, follow-up date | PetDesk |
| **Weight trend** (`/daily/weight`) | The core health signal is currently a list | Pawtrack |
| **Pet switcher sheet** | Switching is the most repeated action and lives behind a form control | Linktree |

### Features missing

- **Bulk "who am I editing" guard** — the §5 CRITICAL; no surface proves the target pet.
- **Species/age care templates** with a veterinary disclaimer.
- **Expiry due-ness** on documents (expired / expiring soon), matching the care model.
- **Weight delta + target range** ("+0.4 kg in 30 days, within breed range").
- **Undo** on every delete (pet cascade, schedule, log, document).
- **Weight range validation inside the dialog** (`daily_screen.dart:175-181` only checks parse).
- **Share/export of a pet's record** (the app already exports a full backup in Settings, but not a
  single pet's health card).

### Components missing

`PetContextBar` · `DueChip` · `WeightTrend` · `ConfirmDeleteSheet` · `UndoBar` ·
`SkeletonList` (`FleetShimmerCard` exists, unused) · `EmptyAction` variant (icon + CTA, not bare
text) · `ScheduleFrequencyField`.

---

## 11. Improvement plan

Effort in engineer-hours for one developer who knows the codebase.

### P0 — broken (blocks the A grade, 14–16 h)

| # | Change | Files | Effort | Score delta |
|---|---|---|---|---|
| P0-1 | Persistent pet context: avatar + name + chevron in the app bar on Home/Care/Daily/Docs; same selector as `home:56` | `navigation_shell.dart`, `care:35`, `daily:31`, `docs:29`, new `PetContextBar` | 5 h | Hierarchy +6, A11y +4 — removes the wrong-pet CRITICAL |
| P0-2 | `DueChip`: tonal background, icon, 13sp/w700 ink ≥4.5:1, dark variants; replace raw `success/warning/danger` text | `care:83-91`, `home:120-133`, `app_colors.dart` | 3 h | Color 50 → 72 (lifts the cap), A11y +4 |
| P0-3 | Confirmation + undo on every destructive path (pet delete, long-press deletes) | `settings:87-104`, `care:107,155`, `daily:96`, `docs:75` | 3 h | Touch 55 → 68 |
| P0-4 | Loading/error/offline via `FleetStateSwitcher` for backup export/import and both pickers | `settings:126-162`, `home:231`, `docs:174` | 3 h | Content states 40 → 62 |
| P0-5 | Semantics on rows and every icon button; `tooltip` on the 4 unnamed controls | `home:97,155`, `settings:90`, `daily:117`, row builders | 2 h | A11y 36 → 58 |

### P1 — system (14–18 h)

| # | Change | Files | Effort | Delta |
|---|---|---|---|---|
| P1-1 | `app_typography.dart` (11/13/15/17/22/28), replace 17 raw `TextStyle` and 43 `fontSize` | `lib/core/theme`, all screens | 3 h | Typography 50 → 72 |
| P1-2 | Species/age care template + "reminder, not veterinary advice" disclaimer | `care:180-318`, `l10n`, `onboarding` | 4 h | Domain; Hierarchy +3 |
| P1-3 | `WeightTrend` (90-day line, kg ticks, delta, period pill) | `daily:101-124`, new widget | 3 h | Hierarchy +4, Content +4 |
| P1-4 | Due-ness everywhere: Home sort, document expiry countdown, "late by N days" | `home:113-136`, `docs:66-73`, `pet.dart:145-150` | 1.5 h | Hierarchy +3 |
| P1-5 | Vet visit detail sheet: reason, diagnosis, cost (validated), attachments, follow-up | `care:320-452`, new sheet | 3 h | Content +3, Hierarchy +3 |
| P1-6 | Motion + haptics on mark-done and log: `AppMotion.resolve` fade, `selectionClick` | `care:94-103`, `daily:52-67` | 1.5 h | Motion 50 → 68 |

### P2 — polish (10–12 h)

| # | Change | Effort | Delta |
|---|---|---|---|
| P2-1 | Tablet: `maxWidth: 720` + `NavigationRail` at ≥840dp | 3 h | Responsive 55 → 72 |
| P2-2 | Replace `AppColors.primary` with `colorScheme.primary` in 21 widget sites | 1.5 h | Color +3, platform consistency |
| P2-3 | Home consolidation: one identity band, remove the duplicate "All pets" card | 2 h | Hierarchy +3 |
| P2-4 | Age instead of DOB ("2 yr 1 mo"), with birthday caption | 1 h | Typography/domain +2 |
| P2-5 | Day-grouped timeline headers on Daily | 1.5 h | Hierarchy +2 |
| P2-6 | Empty states: icon + one-line + action, not bare sentences | 1 h | Content +3 |
| P2-7 | Entity routes `/pets/:id`, `/care/:id` with platform push transitions | 2.5 h | Navigation +5 |

**Projected after P0+P1:** 56.7 → ~76 (C). After P2: ~86 (B). A true **A** additionally needs the
missing screens (§10) and a semantics density of ≥1 per screen with a real screen-reader pass.

---

## 12. Definition of done

- [ ] Every pet-scoped screen shows the active pet's avatar + name; a session log proves no write
      can target an unseen pet.
- [ ] `grep -rc "Color(0x" lib/features` → **0** (already true; keep it).
- [ ] `grep -rc "TextStyle(" lib/features` → **0** outside `app_typography`.
- [ ] Status text/pills measure ≥4.5:1 on light **and** dark surfaces (verified with the
      `#10B981 / #F59E0B / #EF4444` pairs, not assumed).
- [ ] `Semantics`/`MergeSemantics` ≥ 1 per interactive row; all 4 unnamed icon buttons have a
      `tooltip`.
- [ ] Every delete has a confirmation and an undo affordance.
- [ ] Backup import, export and both file pickers have loading + error + success states.
- [ ] Documents show a countdown, not a raw date; Home's due list is sorted by urgency.
- [ ] Weight shows a trend with a stated period and kg axis.
- [ ] iPad ≥840dp is not a stretched phone column; 320dp + 1.6× text render with zero overflow.
- [ ] Scorecard re-run ≥ 90 with evidence.

---

## Appendix — method and reproduction

- **Sitemap:** parsed from `lib/core/router/app_router.dart` — 8 `GoRoute` nodes, one
  `StatefulShellRoute.indexedStack` with 5 branches. Route-line count above = JSON count = **8**.
- **Counts:** `grep -o` over `lib`; per-directory splits from `grep -rc`. Measured: `Color(0x` =
  50 (0 in `lib/features`, 27 in `lib/core/ui`, 23 in `app_colors.dart`), `TextStyle(` = 52 (17 in
  features), `fontSize:` = 43, `Semantics(` = 9 (incl. 3 `ExcludeSemantics`), `semanticLabel` = 7, `MergeSemantics` = 0,
  `tooltip:` = 1, `RefreshIndicator` = 0, `Navigator.push` = 0, `HapticFeedback` = 8 (0 in
  features), `AppMotion.` = 0 in features, `TapTarget(` = 0 in features.
- **Renders:** `docs/store/metadata/ios-screenshots/en-US/iphone69-{1..4}.png` (1290×2796) and
  `ipad13-1.png` (2064×2752), produced by `test/store_screens/store_screens_test.dart`.
- **Contrast:** computed with the WCAG 2.x relative-luminance formula against the literal hex in
  `app_colors.dart:11-13` and the card/scaffold surfaces.
- **Mobbin:** `mobbin screens "<query>" --platform ios --deep` × 6 queries (`pet care tracker`,
  `pet health records`, `dog care schedule`, `vaccination reminder`, `pet profile`,
  `multi-profile switcher`); six references downloaded as `.webp` and read as images.
- **Read but not executed** (no build/test in audit mode): the 10 files under `test/`, including
  `store_screens_test.dart`, `store_landscape_test.dart`, `store_overflow.dart` and
  `trace_cases_test.dart`.
