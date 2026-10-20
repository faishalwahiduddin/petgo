// BAST capture (standards §TRACE, profil Flutter) — jalankan dari akar app: node test/bast/bast_flows.mjs
import { runFlutterBast } from "/Users/rumah/projects/scripts/trace-graph/kit/flutter-web.mjs";

const ID = { "flutter.locale": '"id"' };
const READY = { ...ID, "flutter.petgo_disclaimer_accepted": "true", "flutter.onboarding_completed": "true" };

/** Muat ulang app dengan preferensi lokal (bahasa Indonesia, onboarding selesai) dan aktifkan semantics. */
async function boot(page, prefs = READY) {
  await page.evaluate((p) => { localStorage.clear(); for (const [k, v] of Object.entries(p)) localStorage.setItem(k, v); }, prefs);
  await page.goto(new URL(page.url()).origin + "/", { waitUntil: "load" });
  const ph = page.locator("flt-semantics-placeholder");
  await ph.waitFor({ state: "attached", timeout: 30000 }).catch(() => {});
  await ph.dispatchEvent("click").catch(() => {});
  await page.waitForTimeout(2500);
}
const btn = (page, name) => page.getByRole("button", { name }).first();
const card = (page, name) => page.getByRole("group", { name }).first();

/** Fokuskan kolom (locator) sampai input Flutter benar-benar aktif, lalu sisipkan teks. */
async function fill(page, loc, text) {
  await loc.waitFor({ state: "attached", timeout: 15000 });
  for (let i = 0; i < 6; i++) {
    await loc.click({ force: true });
    const ok = await page.waitForFunction(() => document.activeElement?.tagName === "INPUT" || document.activeElement?.tagName === "TEXTAREA", null, { timeout: 1500 }).then(() => true, () => false);
    if (ok) break;
  }
  await page.waitForTimeout(300);
  await page.keyboard.press("ControlOrMeta+A");
  await page.keyboard.insertText(text);
  await page.waitForTimeout(500);
}
const field = (page, label) => page.getByRole("textbox", { name: label }).first();

const tab = (page, name) => page.getByRole("tab", { name }).first();

const flows = [
  {
    flow: "FLOW-PET-01", tc: "FLOW-PET-01-T01", role: "ROL-001",
    title: "Menambah profil hewan",
    summary: "Pemilik menyetujui penafian, lalu menambah profil hewan (nama, spesies, ras, berat) dan memilihnya sebagai hewan aktif.",
    async run(page, g) {
      await boot(page, ID);
      await g.step("Baca penafian", "Saat pertama dibuka, PetGo menegaskan data tersimpan lokal dan **bukan diagnosis dokter hewan**. Ketuk **Saya mengerti — lanjut**.");
      await g.tap(btn(page, /^Saya mengerti/));
      await page.waitForTimeout(1200);
      await g.step("Daftar hewan", "Tab **Hewan** menampilkan **Hewan aktif**, jadwal yang jatuh tempo, dan **Semua hewan**.");
      await g.tap(btn(page, /^Tambah hewan/));
      await page.waitForTimeout(900);
      await fill(page, field(page, "Nama"), "Kopi");
      await fill(page, field(page, "Ras"), "Domestik");
      await fill(page, field(page, "Berat (kg)"), "4.2");
      await g.step("Isi profil", "Ketuk **Tambah hewan**, isi **Nama** (2–50 karakter), **Spesies**, **Ras**, dan **Berat (kg)** (0–500).");
      await g.tap(btn(page, /^Simpan$/));
      await page.waitForTimeout(1200);
      await g.step("Simpan", "Ketuk **Simpan**. Hewan baru muncul di **Semua hewan** dan bisa dipilih sebagai **Hewan aktif**.");
    },
  },
  {
    flow: "FLOW-CAR-01", tc: "FLOW-CAR-01-T01", role: "ROL-001",
    title: "Mengelola jadwal perawatan",
    summary: "Pemilik melihat jadwal vaksin/obat cacing beserta sisa hari, menandai selesai, dan menambah jadwal baru.",
    async run(page, g) {
      await boot(page);
      await g.tap(tab(page, /^Perawatan/));
      await page.waitForTimeout(900);
      await g.step("Buka Perawatan", "Ketuk tab **Perawatan**: setiap jadwal menampilkan interval dan sisa hari menuju jatuh tempo.");
      await g.tap(btn(page, /^Tandai selesai/));
      await page.waitForTimeout(1000);
      await g.step("Tandai selesai", "Ketuk **Tandai selesai** setelah perawatan dilakukan; tanggal hari ini tercatat dan jatuh tempo berikutnya dihitung ulang.");
      await g.tap(btn(page, /^Tambah jadwal/));
      await page.waitForTimeout(900);
      await fill(page, field(page, "Judul"), "Anti kutu");
      await g.step("Tambah jadwal", "Ketuk **Tambah jadwal**, isi **Judul**, jenis, dan **Interval (bulan)** (minimal 1).");
      await g.tap(btn(page, /^Simpan$/));
      await page.waitForTimeout(1200);
      await g.step("Jadwal tersimpan", "Ketuk **Simpan**. Jadwal baru masuk ke daftar perawatan.");
    },
  },
  {
    flow: "FLOW-VET-01", tc: "FLOW-VET-01-T01", role: "ROL-001",
    title: "Mencatat kunjungan dokter hewan",
    summary: "Pemilik mencatat kunjungan ke dokter hewan beserta klinik, obat, dan biaya.",
    async run(page, g) {
      await boot(page);
      await g.tap(tab(page, /^Perawatan/));
      await page.waitForTimeout(900);
      await g.tap(btn(page, /^Catat vet/));
      await page.waitForTimeout(900);
      await fill(page, field(page, "Judul"), "Vaksin tahunan");
      await fill(page, field(page, "Klinik"), "Klinik Hewan Sehat");
      await fill(page, field(page, "Obat"), "Vitamin");
      await g.step("Isi kunjungan", "Di tab **Perawatan**, ketuk **Catat vet**. Isi **Judul** (wajib), **Klinik**, **Obat**, dan **Biaya**.");
      await g.tap(btn(page, /^Simpan$/));
      await page.waitForTimeout(1200);
      await g.step("Simpan", "Ketuk **Simpan**. Kunjungan tampil di **Kunjungan & obat**, terbaru di atas.");
    },
  },
  {
    flow: "FLOW-DAY-01", tc: "FLOW-DAY-01-T01", role: "ROL-001",
    title: "Mencatat log harian dan berat",
    summary: "Pemilik mencatat makan/jalan/litter dengan satu ketukan dan menimbang berat hewan.",
    async run(page, g) {
      await boot(page);
      await g.tap(tab(page, /^Harian/));
      await page.waitForTimeout(900);
      await g.step("Buka Harian", "Ketuk tab **Harian**: **Catat cepat** dan **Timeline** aktivitas hewan aktif.");
      await g.tap(page.getByRole("checkbox", { name: "Makan" }));
      await page.waitForTimeout(800);
      await g.step("Catat cepat", "Ketuk **Makan**, **Jalan**, atau **Litter**; aktivitas langsung masuk ke **Timeline**.");
      await g.tap(btn(page, /^Catat berat/));
      await page.waitForTimeout(900);
      await fill(page, field(page, "Berat (kg)"), "12.8");
      await g.step("Catat berat", "Ketuk **Catat berat** dan isi **Berat (kg)** (0–500). Berat terbaru memperbarui profil hewan.");
      await g.tap(btn(page, /^Simpan$/));
      await page.waitForTimeout(1200);
      await g.step("Berat tersimpan", "Setelah **Simpan**, berat tercatat di riwayat dan profil hewan aktif.");
    },
  },
  {
    flow: "FLOW-DOC-01", tc: "FLOW-DOC-01-T01", role: "ROL-001",
    title: "Menyimpan dokumen hewan",
    summary: "Pemilik mencatat dokumen penting (kartu vaksin, resep, asuransi) per hewan.",
    async run(page, g) {
      await boot(page);
      await g.tap(tab(page, /^Dokumen/));
      await page.waitForTimeout(900);
      await g.step("Buka Dokumen", "Ketuk tab **Dokumen**: daftar dokumen hewan aktif.");
      await g.tap(btn(page, /^Tambah dokumen/));
      await page.waitForTimeout(900);
      await fill(page, field(page, "Judul"), "Resep antibiotik");
      await g.step("Tambah dokumen", "Ketuk **Tambah dokumen**, isi **Judul** (wajib), jenis, dan masa berlaku bila ada.");
      await g.tap(btn(page, /^Simpan$/));
      await page.waitForTimeout(1200);
      await g.step("Dokumen tersimpan", "Ketuk **Simpan**. Dokumen muncul di daftar.");
    },
  },
  {
    flow: "FLOW-SET-01", tc: "FLOW-SET-01-T01", role: "ROL-001",
    title: "Mencadangkan data dan mengatur pengingat",
    summary: "Pemilik membuka **Pengaturan** untuk bahasa, pengingat perawatan, serta ekspor/impor cadangan.",
    async run(page, g) {
      await boot(page);
      await g.tap(tab(page, /^Pengaturan/));
      await page.waitForTimeout(900);
      await g.step("Buka Pengaturan", "Ketuk tab **Pengaturan**: **Bahasa**, **Profil hewan**, **Pengingat perawatan**, **Ekspor cadangan**, dan **Impor cadangan**.");
    },
  },
];

// BAST_NO_BUILD=1 memakai build/web yang sudah ada; BAST_ONLY=FLOW-A,FLOW-B merekam ulang sebagian flow.
const only = process.env.BAST_ONLY?.split(",");
await runFlutterBast(import.meta.dirname + "/../..", flows.filter((f) => !only || only.includes(f.flow)), { build: !process.env.BAST_NO_BUILD });
