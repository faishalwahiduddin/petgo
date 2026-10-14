# Maskot Tori — kandidat anchor

**rubah mekanik (fennec fox)** · peran Sidekick

Fennec fox bertelinga besar peka mendengar bunyi mesin halus — teliti merawat kondisi kendaraan.

Spesifikasi dan prompt: [`docs/mascots/prompts/petgo.md`](../../../docs/mascots/prompts/petgo.md)

| File | Uji terukur | Catatan |
|---|---|---|
| `anchor-candidate-01.png` | pending | Belum digenerate |

Uji terukur hanya menyaring rasio, transparansi, palet, dominasi aksen, outline,
dan pemisahan grayscale. **Tiga hal ini tetap butuh mata:**

- Signature detail: topi mekanik datar slate #334155 beremblem speedometer emas #F59E0B di depan
- Siluet: kepala rubah mungil dengan dua telinga segitiga besar menjulang, moncong runcing lembut
- Selalu: tanpa hidung, satu highlight per mata, tanpa cast shadow

Regenerate: `bash docs/mascots/generate_anchors.sh petgo`

Dibuat via Gemini "Gambar" (Pro Mendalam), dikendalikan `gstack browse`.
