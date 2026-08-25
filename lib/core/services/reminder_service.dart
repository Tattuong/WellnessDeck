import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_strings.dart';

class ReminderService {
  ReminderService._();
  static final instance = ReminderService._();

  static const _channelId = 'wd_reminders';
  static const _ids = [100, 101, 102];
  static const _hours = [8, 13, 20];
  static const _minutes = [0, 0, 30];
  static const _titleKeys = ['reminderMorning', 'reminderMidday', 'reminderEvening'];
  static const _bodyKeys = ['reminderMorningBody', 'reminderMiddayBody', 'reminderEveningBody'];

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool alertsAllowed = false;

  Future<void> init() async {
    if (_ready) return;
    try {
      tzdata.initializeTimeZones();
      await _setLocalTz();
      const init = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _plugin.initialize(settings: init);
      alertsAllowed = await _permissionGranted();
      _ready = true;
    } catch (e) {
      debugPrint('ReminderService init: $e');
    }
  }

  Future<bool> requestPermission() async {
    await init();
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        alertsAllowed = await android?.requestNotificationsPermission() ?? true;
      } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        alertsAllowed = await ios?.requestPermissions(alert: true, sound: true) ?? false;
      } else {
        alertsAllowed = false;
      }
    } catch (e) {
      debugPrint('ReminderService permission: $e');
      alertsAllowed = false;
    }
    return alertsAllowed;
  }

  Future<void> sync(List<bool> on) async {
    await init();
    if (!_ready) return;
    for (final id in _ids) {
      await _plugin.cancel(id: id);
    }
    if (!alertsAllowed) {
      alertsAllowed = await _permissionGranted();
    }
    if (!alertsAllowed) return;
    for (var i = 0; i < _ids.length; i++) {
      if (i >= on.length || !on[i]) continue;
      await _schedule(i);
    }
  }

  Future<void> _schedule(int i) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        AppStrings.tCode('reminders'),
        channelDescription: AppStrings.tCode('remindersHint'),
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true, presentBadge: false),
    );
    await _plugin.zonedSchedule(
      id: _ids[i],
      title: AppStrings.tCode(_titleKeys[i]),
      body: AppStrings.tCode(_bodyKeys[i]),
      scheduledDate: _next(_hours[i], _minutes[i]),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _next(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var at = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
    return at;
  }

  Future<void> _setLocalTz() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(_location(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  tz.Location _location(String id) {
    try {
      return tz.getLocation(id);
    } catch (_) {
      const aliases = {'Asia/Saigon': 'Asia/Ho_Chi_Minh'};
      final mapped = aliases[id];
      if (mapped != null) {
        try {
          return tz.getLocation(mapped);
        } catch (_) {}
      }
      return tz.UTC;
    }
  }

  Future<bool> _permissionGranted() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        return await android?.areNotificationsEnabled() ?? false;
      }
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        final opts = await ios?.checkPermissions();
        return opts?.isEnabled == true || opts?.isAlertEnabled == true;
      }
    } catch (_) {}
    return false;
  }
}
