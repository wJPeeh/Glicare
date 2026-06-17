import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'medication_schedule.dart';

class MedicationNotifications {
  MedicationNotifications._();

  static final MedicationNotifications instance = MedicationNotifications._();

  static const String _channelId = 'medication_reminders';
  static const String _channelName = 'Lembretes de Medicação';
  static const String _channelDesc =
      'Notificações de horário das medicações cadastradas no Glicare.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings:
          const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      ),
    );
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    await ensureInitialized();
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    final androidOk =
        await androidImpl?.requestNotificationsPermission() ?? true;
    final iosOk = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;
    return androidOk && iosOk;
  }

  Future<void> syncSchedule(MedicationSchedule schedule) async {
    await ensureInitialized();
    await cancelSchedule(schedule.id);
    if (!schedule.active || !schedule.pushEnabled) return;
    if (schedule.timesOfDay.isEmpty || schedule.daysOfWeek.isEmpty) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final dosageSuffix =
        schedule.dosage.trim().isEmpty ? '' : ' (${schedule.dosage.trim()})';
    final body = 'Está na hora da sua dose${dosageSuffix}.';

    for (final weekday in schedule.daysOfWeek) {
      for (final minute in schedule.timesOfDay) {
        final id = _notificationIdFor(schedule.id, weekday, minute);
        try {
          await _plugin.zonedSchedule(
            id: id,
            title: 'Hora da medicação',
            body: body,
            scheduledDate: _nextInstance(weekday, minute),
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: 'schedule:${schedule.id}',
          );
        } catch (e, st) {
          debugPrint('Falha ao agendar notificação $id: $e\n$st');
        }
      }
    }
  }

  Future<void> cancelSchedule(String scheduleId) async {
    await ensureInitialized();
    final pending = await _plugin.pendingNotificationRequests();
    final prefix = 'schedule:$scheduleId';
    for (final req in pending) {
      if (req.payload == prefix) {
        await _plugin.cancel(id: req.id);
      }
    }
  }

  Future<void> cancelAll() async {
    await ensureInitialized();
    await _plugin.cancelAll();
  }

  tz.TZDateTime _nextInstance(int weekday, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minute ~/ 60,
      minute % 60,
    );
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  int _notificationIdFor(String scheduleId, int weekday, int minute) {
    final base = scheduleId.hashCode & 0x0FFFFFFF;
    return base ^ (weekday * 10000 + minute);
  }
}
