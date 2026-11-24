import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petgo/core/services/quick_action_config.dart';
import 'package:petgo/core/services/quick_action_notification.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('id.faishal.fleet/quick_notif');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    QuickActionNotificationService.debugPlatformOverride = TargetPlatform.android;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'show') return true;
      if (call.method == 'isEnabled') return true;
      if (call.method == 'getInitialActionRoute') {
        return kQuickNotifActions.first.route;
      }
      return null;
    });
  });

  tearDown(() {
    QuickActionNotificationService.debugPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('kQuickNotifActions has 4 non-empty actions', () {
    expect(kQuickNotifActions.length, 4);
    for (final a in kQuickNotifActions) {
      expect(a.id, isNotEmpty);
      expect(a.label, isNotEmpty);
      expect(a.route, startsWith('/'));
      expect(a.iconRes, startsWith('ic_qa_'));
    }
  });

  test('setQuickActionNotificationEnabled(true) invokes show with 4 actions', () async {
    final ok = await setQuickActionNotificationEnabled(true);
    expect(ok, isTrue);
    expect(calls.length, 1);
    expect(calls.first.method, 'show');
    final args = calls.first.arguments as Map<dynamic, dynamic>;
    expect((args['actions'] as List).length, 4);
  });

  test('setQuickActionNotificationEnabled(false) invokes hide', () async {
    await setQuickActionNotificationEnabled(false);
    expect(calls.length, 1);
    expect(calls.first.method, 'hide');
  });

  test('isEnabled & getInitialActionRoute return platform values', () async {
    expect(await QuickActionNotificationService.isEnabled(), isTrue);
    expect(
      await QuickActionNotificationService.getInitialActionRoute(),
      kQuickNotifActions.first.route,
    );
  });
}
