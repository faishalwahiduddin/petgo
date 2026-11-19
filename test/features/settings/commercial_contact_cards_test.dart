import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petgo/core/constants/app_colors.dart';
import 'package:petgo/core/theme/app_theme.dart';
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

Widget _app([ThemeData? theme]) => MaterialApp(
  theme: theme,
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

double _lum(Color c) => c.computeLuminance();

double _contrast(Color a, Color b) {
  final hi = _lum(a) > _lum(b) ? a : b;
  final lo = identical(hi, a) ? b : a;
  return (_lum(hi) + 0.05) / (_lum(lo) + 0.05);
}

final _themes = [
  ('light', AppTheme.lightTheme, AppColors.bgLightSurface),
  ('dark', AppTheme.darkTheme, AppColors.bgCard),
];

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

  testWidgets('commercial card is announced once as title + description', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app());
    expect(find.bySemanticsLabel(RegExp('Commercial use')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('tap target is at least 48dp tall', (tester) async {
    await tester.pumpWidget(_app());
    final size = tester.getSize(
      find.ancestor(
        of: find.text('Acquire this app'),
        matching: find.byType(InkWell),
      ),
    );
    expect(size.height, greaterThanOrEqualTo(48));
  });

  for (final (name, theme, surface) in _themes) {
    testWidgets('description and email text meet 4.5:1 and size floor ($name)', (
      tester,
    ) async {
      await tester.pumpWidget(_app(theme));
      for (final text in [
        'Need a commercial license, white-label, or customization? Get in touch.',
        'Interested in acquiring this app, including source code and assets? Let\'s talk.',
        'contact@faishal.id',
      ]) {
        final style = tester.widget<Text>(find.text(text)).style!;
        expect(
          _contrast(style.color!, surface),
          greaterThanOrEqualTo(4.5),
          reason: '$text ($name)',
        );
        expect(style.fontSize, greaterThanOrEqualTo(12), reason: text);
      }
      final title = tester.widget<Text>(find.text('Commercial use')).style!;
      expect(title.fontSize, greaterThanOrEqualTo(14));
      expect(_contrast(title.color!, surface), greaterThanOrEqualTo(4.5));
    });
  }

  for (final (name, theme, surface) in _themes) {
    testWidgets('license badge >=12px, 4.5:1 on blended bg ($name)', (
      tester,
    ) async {
      await tester.pumpWidget(_app(theme));
      final style = tester
          .widget<Text>(find.text('Personal & Non-Profit'))
          .style!;
      final bg = Color.alphaBlend(
        AppColors.primary.withValues(alpha: 0.12),
        surface,
      );
      expect(style.fontSize, greaterThanOrEqualTo(12));
      expect(_contrast(style.color!, bg), greaterThanOrEqualTo(4.5));
    });
  }
}
