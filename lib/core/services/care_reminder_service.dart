import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/pet.dart';

class CareReminderService {
  CareReminderService._();
  static final instance = CareReminderService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      tzdata.initializeTimeZones();
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _plugin.initialize(
        settings: const InitializationSettings(android: android, iOS: ios),
      );
      _ready = true;
    } catch (e) {
      debugPrint('CareReminderService.init failed: $e');
      _ready = false;
    }
  }

  Future<void> cancelAll() async {
    if (!_ready) return;
    await _plugin.cancelAll();
  }

  Future<void> reschedule(List<CareSchedule> schedules, {required bool enabled}) async {
    if (!_ready || !enabled) {
      await cancelAll();
      return;
    }
    await cancelAll();
    var id = 42000;
    for (final s in schedules) {
      if (s.urgency == ScheduleUrgency.safe && s.daysRemaining > 3) continue;
      final whenDate = s.dueDate.isBefore(DateTime.now().toUtc())
          ? DateTime.now().toUtc().add(const Duration(hours: 1))
          : s.dueDate;
      if (!whenDate.isAfter(DateTime.now().toUtc())) continue;
      try {
        final when = tz.TZDateTime.from(whenDate, tz.UTC);
        await _plugin.zonedSchedule(
          id: id++,
          title: 'PetGo',
          body: '${s.title} — jatuh tempo perawatan',
          scheduledDate: when,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'petgo_care',
              'Care reminders',
              channelDescription: 'Reminders for pet care schedules',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (e) {
        debugPrint('CareReminderService.schedule failed: $e');
      }
    }
  }
}
