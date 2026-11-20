import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the SDK's Roboto under the family name Material uses on Android, so
/// widget tests measure text like a real phone. The default test font draws
/// every glyph as a 1em square, which reports RenderFlex overflows that do not
/// happen on devices (and hides how wide real text is).
Future<void> loadRealRoboto() async {
  final sdk = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final dir = '$sdk/bin/cache/artifacts/material_fonts';
  final loader = FontLoader('Roboto');
  var any = false;
  for (final f in ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf']) {
    final file = File('$dir/$f');
    if (file.existsSync()) {
      any = true;
      loader.addFont(Future.value(ByteData.view(Uint8List.fromList(file.readAsBytesSync()).buffer)));
    }
  }
  if (any) await loader.load();
}
