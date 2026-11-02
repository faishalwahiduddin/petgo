const EXACT = {
  '/ar/blog/consistent-daily-care-schedules/': '/ar/blog/jdwl-raaya-ywmy-thabt/',
  '/ar/blog/pet-profiles-in-one-place/': '/ar/blog/mlfat-alhywanat-alalyfa-fy-mkan-wahd/',
  '/ar/blog/vet-visit-notes-ready-to-bring/': '/ar/blog/mlahzat-jahza-lzyara-altbyb-albytry/',
  '/en/blog/catatan-kunjungan-vet': '/en/blog/vet-visit-notes-ready-to-bring/',
  '/en/blog/jadwal-perawatan-harian': '/en/blog/consistent-daily-care-schedules/',
  '/en/blog/profil-hewan-peliharaan': '/en/blog/pet-profiles-in-one-place/',
  '/id/blog/catatan-kunjungan-vet/': '/id/blog/catatan-kunjungan-vet-yang-siap-dibawa/',
  '/id/blog/jadwal-perawatan-harian/': '/id/blog/jadwal-perawatan-harian-yang-konsisten/',
  '/id/blog/profil-hewan-peliharaan/': '/id/blog/profil-hewan-peliharaan-dalam-satu-tempat/',
  '/ja/blog/consistent-daily-care-schedules/': '/ja/blog/mainichi-no-kea-wo-tsuzuke-ru-sukejuuru/',
  '/ja/blog/pet-profiles-in-one-place/': '/ja/blog/petto-no-purofiiru-wo-ichi-ka-tokoro-ni/',
  '/ja/blog/vet-visit-notes-ready-to-bring/': '/ja/blog/doubutsubyouin-ni-motsu-te-iku-kiroku-no-junbi/',
  '/jv/blog/catatan-kunjungan-vet-yang-siap-dibawa/': '/jv/blog/cathetan-kunjungan-vet-sing-siap-digawa/',
  '/jv/blog/jadwal-perawatan-harian-yang-konsisten/': '/jv/blog/jadwal-perawatan-saben-dina-sing-konsisten/',
  '/jv/blog/profil-hewan-peliharaan': '/jv/blog/profil-hewan-peliharaan-dalam-satu-tempat/',
  '/su/blog/catatan-kunjungan-vet-yang-siap-dibawa/': '/su/blog/catetan-kunjungan-vet-anu-siap-dibawa/',
  '/su/blog/jadwal-perawatan-harian-yang-konsisten/': '/su/blog/jadwal-perawatan-sapopoe-anu-konsisten/',
  '/su/blog/profil-hewan-peliharaan': '/su/blog/profil-hewan-peliharaan-dalam-satu-tempat/',
  '/zh/blog/consistent-daily-care-schedules/': '/zh/blog/wen-ding-de-mei-ri-zhao-hu-shi-jian-biao/',
  '/zh/blog/pet-profiles-in-one-place/': '/zh/blog/chong-wu-dang-an-ji-zhong-zai-yi-chu/',
  '/zh/blog/vet-visit-notes-ready-to-bring/': '/zh/blog/dai-chong-wu-kan-zhen-qian-zhun-bei-hao-de-ji-lu/'
};

const BLOG_PATH = /^\/(id|en|ar|zh|ja|jv|su)\/blog\/./;

export async function onRequest(context) {
  const url = new URL(context.request.url);
  const decoded = decodeURIComponent(url.pathname);
  const mapped = EXACT[decoded];
  if (mapped) return Response.redirect(url.origin + mapped, 301);

  const response = await context.next();
  if (response.status !== 404) return response;

  // Anything still unresolved under a blog path goes to its locale index rather
  // than a dead end.
  if (BLOG_PATH.test(decoded)) {
    const locale = decoded.split("/")[1];
    return Response.redirect(`${url.origin}/${locale}/blog/`, 301);
  }
  return response;
}
