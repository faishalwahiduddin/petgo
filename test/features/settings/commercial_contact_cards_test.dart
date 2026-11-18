import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petgo/features/settings/commercial_contact_cards.dart';
import 'package:petgo/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _FakeLauncher extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  _FakeLauncher(this.result, {this.throws = false});
  final bool result;
  final bool throws;
  final List<String> urls = [];

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    urls.add(url);
    if (throws) throw PlatformException(code: 'NO_HANDLER');
    return result;
  }
}

Widget _app() => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Column(
      children: [
        UsageLicenseCard(),
        CommercialContactCards(appName: 'PetGo'),
      ],
    ),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'petgo',
      packageName: 'id.faishal.petgo',
      version: '1.2.3',
      buildNumber: '45',
      buildSignature: '',
    );
  });

  testWidgets('renders both titles', (tester) async {
    await tester.pumpWidget(_app());
    expect(find.text('Usage License'), findsOneWidget);
    expect(find.text('Commercial use'), findsOneWidget);
    expect(find.text('Acquire this app'), findsOneWidget);
  });

  testWidgets('commercial tap launches mailto with subject', (tester) async {
    final fake = _FakeLauncher(true);
    UrlLauncherPlatform.instance = fake;
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Commercial use'));
    await tester.pumpAndSettle();
    expect(fake.urls, hasLength(1));
    final uri = Uri.parse(fake.urls.single);
    expect(uri.scheme, 'mailto');
    expect(uri.path, 'contact@faishal.id');
    expect(fake.urls.single, contains('%20'));
    expect(uri.queryParameters['subject'], '[Commercial] PetGo');
    expect(uri.queryParameters['body'], contains('Platform:'));
    expect(uri.queryParameters['body'], contains('v1.2.3+45'));
  });

  testWidgets('acquisition tap launches mailto with subject', (tester) async {
    final fake = _FakeLauncher(true);
    UrlLauncherPlatform.instance = fake;
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Acquire this app'));
    await tester.pumpAndSettle();
    expect(fake.urls, hasLength(1));
    final uri = Uri.parse(fake.urls.single);
    expect(uri.queryParameters['subject'], '[Acquisition] PetGo');
  });

  testWidgets('launch failure copies email and shows snackbar', (tester) async {
    UrlLauncherPlatform.instance = _FakeLauncher(false);
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Acquire this app'));
    await tester.pumpAndSettle();
    expect(copied, 'contact@faishal.id');
    expect(
      find.text('Email address copied: contact@faishal.id'),
      findsOneWidget,
    );
  });

  testWidgets(
    'launcher throwing PlatformException copies email and shows snackbar',
    (tester) async {
      UrlLauncherPlatform.instance = _FakeLauncher(false, throws: true);
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(_app());
      await tester.tap(find.text('Acquire this app'));
      await tester.pumpAndSettle();
      expect(copied, 'contact@faishal.id');
      expect(
        find.text('Email address copied: contact@faishal.id'),
        findsOneWidget,
      );
    },
  );
}
