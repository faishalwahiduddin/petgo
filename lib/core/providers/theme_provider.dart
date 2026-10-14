import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_providers.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final storage = ref.watch(localStorageServiceProvider);
    return storage.getThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveThemeMode(mode);
    state = mode;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
