# Maskot Pego — kandidat anchor

**anak anjing corgi ramah (corgi pup)** · peran Companion

Corgi yang setia, lincah, dan penuh kasih sayang mewakili ikatan tulus antara pemilik dan hewan peliharaan dalam perawatan harian.

Spesifikasi dan prompt: [`docs/mascots/prompts/petgo.md`](../../../docs/mascots/prompts/petgo.md)

| File | Uji terukur | Catatan |
|---|---|---|
| `anchor-candidate-01.png` | lolos | Backup anchor fennec fox lama |
| `anchor.png` | lolos | Anchor resmi: 100% Golden Rules compliant (Pego si corgi ramah) |

Uji terukur hanya menyaring rasio, transparansi, palet, dominasi aksen, outline,
dan pemisahan grayscale. **Tiga hal ini tetap butuh mata:**

- Signature detail: bandana leher sage green #5B7F5A dengan liontin jejak kaki emas #D4A373, telinga tegak membulat khas corgi
- Siluet: kepala corgi bulat dengan telinga besar tegak membulat, tubuh gembul berkaki pendek, senyum kawaii ramah
- Selalu: tanpa hidung, satu highlight per mata, tanpa cast shadow

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
