import 'package:flutter/material.dart';

class FleetSlideItem {
  final String headline;
  final String subtext;
  final IconData? icon;
  final String? badgeText;

  const FleetSlideItem({
    required this.headline,
    required this.subtext,
    this.icon,
    this.badgeText,
  });
}

class FleetAppConfig {
  final String appName;
  final String tagline;
  final Color primaryColor;
  final Color darkColor;
  final Color accentColor;
  final IconData fallbackIcon;
  final String skipLabel;
  final String nextLabel;
  final String getStartedLabel;
  final String defaultBadgeText;
  final String privacyHeadline;
  final String privacyDetail;
  final List<FleetSlideItem> slides;

  const FleetAppConfig({
    required this.appName,
    required this.tagline,
    required this.primaryColor,
    required this.darkColor,
    required this.accentColor,
    required this.fallbackIcon,
    this.skipLabel = 'Lewati',
    this.nextLabel = 'Lanjut',
    this.getStartedLabel = 'Mulai Sekarang',
    this.defaultBadgeText = '100% Offline & Cepat',
    this.privacyHeadline = 'Privasi & Offline Terjamin',
    this.privacyDetail =
        'Semua data tersimpan aman di perangkat Anda tanpa pelacak.',
    required this.slides,
  });

  static final FleetAppConfig current = FleetAppConfig(
    appName: 'PetGo',
    tagline: 'Profil hewan, jadwal perawatan, dan log harian — offline.',
    primaryColor: const Color(0xFF5B7F5A),
    darkColor: const Color(0xFF3E5A3D),
    accentColor: const Color(0xFFD4A373),
    fallbackIcon: Icons.pets_rounded,
    slides: const [
      FleetSlideItem(
        headline: 'Profil hewan',
        subtext: 'Anjing, kucing, dan lainnya',
        icon: Icons.pets_rounded,
        badgeText: '100% Offline & Privat',
      ),
      FleetSlideItem(
        headline: 'Jadwal perawatan',
        subtext: 'Vaksin, cacing, flea, grooming',
        icon: Icons.medical_services_rounded,
        badgeText: 'Pengingat lokal',
      ),
      FleetSlideItem(
        headline: 'Log harian',
        subtext: 'Makan, jalan, litter',
        icon: Icons.today_rounded,
        badgeText: 'Tanpa Iklan & Tanpa Akun',
      ),
      FleetSlideItem(
        headline: 'Dokumen lokal',
        subtext: 'Kartu vaksin & resep',
        icon: Icons.folder_rounded,
        badgeText: 'Data di perangkat',
      ),
    ],
  );
}
