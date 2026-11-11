import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'store_status_bar.dart';

// GENERATED COPY of tools/gen-store-scaffold/flutter_harness/lib/ - edit there,
// then re-run install-harness.sh.
//
// Host font files (macOS only). Roboto ships with the Flutter SDK, SF and
// Apple emoji with macOS, CJK/Arabic/Noto emoji with the fleet font folder.
final _flutterRoot =
    Platform.environment['FLUTTER_ROOT'] ?? '/usr/local/share/flutter';
final _material = '$_flutterRoot/bin/cache/artifacts/material_fonts';
const _fleetDefine = String.fromEnvironment('STORE_FONTS_DIR');
const _fleet =
    _fleetDefine == '' ? '../tools/gen-store-scaffold/fonts' : _fleetDefine;
const _sys = '/System/Library/Fonts';

List<String> get _roboto => [
      '$_material/Roboto-Regular.ttf',
      '$_material/Roboto-Medium.ttf',
      '$_material/Roboto-Bold.ttf',
    ];
const _sf = ['$_sys/SFNS.ttf'];

/// family -> files. Theme families (Roboto / CupertinoSystem*) are the names
/// Material typography asks for; Store* are used by [StoreTextStyle].
Map<String, List<String>> get _families => {
      'Roboto': _roboto,
      'CupertinoSystemText': _sf,
      'CupertinoSystemDisplay': _sf,
      '.AppleSystemUIFont': _sf,
      'StoreDefault_android': _roboto,
      'StoreDefault_ios': _sf,
      'StoreArabic_ios': ['$_sys/SFArabic.ttf'],
      'StoreArabic_android': [
        '$_fleet/NotoNaskhArabicUI-Regular.ttf',
        '$_fleet/NotoNaskhArabicUI-Bold.ttf',
      ],
      'StoreJP': ['$_fleet/NotoSansJP-VF.ttf'],
      'StoreSC': ['$_fleet/NotoSansSC-VF.ttf'],
      'StoreEmoji_ios': ['$_sys/Apple Color Emoji.ttc'],
      // NotoColorEmoji is CBDT bitmap, which the test renderer cannot draw
      // (renders tofu). Apple Color Emoji (sbix) renders; glyph style differs.
      'StoreEmoji_android': ['$_sys/Apple Color Emoji.ttc'],
      'MaterialIcons': ['$_material/MaterialIcons-Regular.otf'],
    };

bool _loaded = false;

Future<ByteData> _read(String path) async =>
    ByteData.sublistView(Uint8List.fromList(await File(path).readAsBytes()));

/// Registers every font once per test process. Must run inside runAsync.
Future<void> loadStoreFonts() async {
  if (_loaded) return;
  _loaded = true;
  for (final e in _families.entries) {
    for (final f in e.value) {
      if (!File(f).existsSync()) {
        throw StateError('store harness font missing: $f (run from the app root '
            'or pass --dart-define=STORE_FONTS_DIR=<fleet fonts dir>)');
      }
    }
    final loader = FontLoader(e.key);
    for (final f in e.value) {
      loader.addFont(_read(f));
    }
    await loader.load();
  }
  await _loadAppFonts();
}

/// flutter_test only registers its box font, not the app's pubspec fonts
/// (nor package fonts such as CupertinoIcons). Load everything listed in the
/// asset FontManifest so app typography and icon fonts render as on device.
Future<void> _loadAppFonts() async {
  final String manifest;
  try {
    manifest = await rootBundle.loadString('FontManifest.json');
  } on FlutterError {
    return; // app declares no fonts
  }
  for (final fam in (json.decode(manifest) as List).cast<Map<String, dynamic>>()) {
    final family = fam['family'] as String;
    if (family == 'MaterialIcons') continue; // loaded from the SDK above
    final loader = FontLoader(family);
    for (final f in (fam['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(f['asset'] as String));
    }
    await loader.load();
  }
}

/// The test engine resolves a null fontFamily to its box font and has no
/// per-glyph system fallback. On a device both come from the OS, so emulate
/// them: give every text span the platform default family (when unset) plus a
/// script/emoji fallback chain.
class StoreTextStyle {
  StoreTextStyle(StoreDevice device, String lang)
      : family = 'StoreDefault_${device.fontKey}',
        fallback = List.unmodifiable([
          if (lang == 'zh') 'StoreSC',
          'StoreJP',
          if (lang != 'zh') 'StoreSC',
          'StoreArabic_${device.fontKey}',
          'StoreEmoji_${device.fontKey}',
        ]);

  final String family;
  final List<String> fallback;

  // Package fonts (e.g. 'packages/cupertino_icons/CupertinoIcons') are icon or
  // asset fonts loaded under their full name: leave them untouched. Re-applying
  // copyWith to them re-prefixes the family on every patch pass.
  static bool _isPackageFont(TextStyle? s) =>
      s?.fontFamily?.startsWith('packages/') ?? false;

  TextStyle? _style(TextStyle? s) => _isPackageFont(s)
      ? s
      : (s ?? const TextStyle()).copyWith(
          fontFamily: s?.fontFamily ?? family,
          fontFamilyFallback: fallback,
        );

  // Compare by content: the fontFamilyFallback getter may return a new list.
  bool _done(InlineSpan s) {
    if (_isPackageFont(s.style)) return true;
    final f = s.style?.fontFamilyFallback;
    return f != null && listEquals(f, fallback);
  }

  InlineSpan _span(InlineSpan s) {
    if (s is! TextSpan) return s;
    return TextSpan(
      text: s.text,
      style: _style(s.style),
      children: s.children?.map(_span).toList(),
      recognizer: s.recognizer,
      mouseCursor: s.mouseCursor,
      onEnter: s.onEnter,
      onExit: s.onExit,
      semanticsLabel: s.semanticsLabel,
      locale: s.locale,
      spellOut: s.spellOut,
    );
  }

  /// Patches the render tree in place and returns how many paragraphs changed.
  /// Rebuilt widgets reset their text, so patch + pump until it returns 0.
  int patch(RenderObject root) {
    var changed = 0;
    void visit(RenderObject o) {
      if (o is RenderParagraph && !_done(o.text)) {
        o.text = _span(o.text);
        changed++;
      } else if (o is RenderEditable && o.text != null && !_done(o.text!)) {
        o.text = _span(o.text!);
        changed++;
      }
      o.visitChildren(visit);
    }

    visit(root);
    return changed;
  }
}
