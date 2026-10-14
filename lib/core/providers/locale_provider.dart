import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_providers.dart';

const supportedLocales = [
  Locale('id'),
  Locale('en'),
  Locale('ar'),
  Locale('jv'),
  Locale('su'),
  Locale('zh'),
  Locale('ja'),
  Locale('es'),
];

class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'locale';

  @override
  Locale build() {
    final storage = ref.read(localStorageServiceProvider);
    final saved = storage.prefs.getString(_key);
    if (saved != null) {
      return Locale(saved);
    }
    final deviceLocale = ui.PlatformDispatcher.instance.locale;
    final isSupported = supportedLocales.any((l) => l.languageCode == deviceLocale.languageCode);
    return isSupported ? Locale(deviceLocale.languageCode) : const Locale('id');
  }

  Future<void> setLocale(Locale locale) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.prefs.setString(_key, locale.languageCode);
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  () => LocaleNotifier(),
);
