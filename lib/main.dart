import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/a11y/text_scale.dart';
import 'core/providers/app_providers.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/timezone_provider.dart';
import 'core/router/app_router.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_timezone.dart';
import 'l10n/app_localizations.dart';
import 'l10n/fallback_framework_delegates.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppTimeZone.initAppTimeZones();
  AppTimeZone.cachedDeviceZone = await AppTimeZone.getDeviceZoneName();
  final storageService = await LocalStorageService.init();

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(storageService),
      ],
      child: const PetGoApp(),
    ),
  );
}

class PetGoApp extends ConsumerStatefulWidget {
  const PetGoApp({super.key});

  @override
  ConsumerState<PetGoApp> createState() => _PetGoAppState();
}

class _PetGoAppState extends ConsumerState<PetGoApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ref.read(timezoneProvider) == null) {
      ref.read(deviceZoneProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'PetGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) => AppTextScale(child: child!),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FallbackMaterialLocalizationsDelegate(),
        FallbackWidgetsLocalizationsDelegate(),
        FallbackCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: supportedLocales,
      locale: locale,
    );
  }
}
