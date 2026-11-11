// Per-app hook for the store screen harness (store_screens_test.dart).
// install-harness.sh never overwrites this file. Checklist:
// tools/gen-store-scaffold/flutter_harness/README.md.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:petgo/core/constants/app_constants.dart';
import 'package:petgo/core/providers/app_providers.dart';
import 'package:petgo/core/router/app_router.dart';
import 'package:petgo/core/storage/local_storage_service.dart';
import 'package:petgo/core/utils/app_timezone.dart';
import 'package:petgo/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Splash hands off after 750 ms.
const kStoreSplash = Duration(seconds: 1);

Future<void> storeSetUpAll() async {
  AppTimeZone.initAppTimeZones();
  AppTimeZone.cachedDeviceZone = 'Asia/Jakarta';
  PackageInfo.setMockInitialValues(
    appName: 'PetGo',
    packageName: 'id.faishal.petgo',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
}

/// Same state main() produces under STORE_DEMO (init seeds the demo data),
/// with onboarding and the disclaimer gate already cleared. The reminder
/// service needs a notification plugin, so it is skipped.
Future<Widget> storeBuildApp(String lang) async {
  SharedPreferences.setMockInitialValues({
    'locale': lang,
    'onboarding_completed': true,
    AppConstants.keyDisclaimer: true,
  });
  final storage = await LocalStorageService.init();
  return ProviderScope(
    overrides: [localStorageServiceProvider.overrideWithValue(storage)],
    child: const PetGoApp(),
  );
}

Future<void> storeGo(WidgetTester tester, String route) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(PetGoApp)),
  );
  container.read(appRouterProvider).go(route);
}

Future<void> storeAfterNavigate(
    WidgetTester tester, int slide, String action) async {
  if (action.isNotEmpty) {
    throw UnimplementedError('petgo has no slide actions (got "$action")');
  }
}
