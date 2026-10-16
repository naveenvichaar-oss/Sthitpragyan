import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../database/hive_storage.dart';
import '../../features/settings/data/models/notification_slot_config.dart';
import 'notifications_dataset_service.dart';

/// NotificationTrigger represents a scheduled strategic stoic prompt
class NotificationTrigger {
  final int id;
  final int hour;
  final int minute;
  final String title;
  final String body;
  final String category;

  const NotificationTrigger({
    required this.id,
    required this.hour,
    required this.minute,
    required this.title,
    required this.body,
    required this.category,
  });
}

/// NotificationService coordinates local scheduled notifications at 4 executive checkpoints.
/// Fully offline, zero cloud servers, zero tracking.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Default fallback triggers if dataset is not yet loaded
  static const List<NotificationTrigger> defaultTriggers = [
    NotificationTrigger(
      id: 101,
      hour: 5,
      minute: 45,
      title: '05:45 AM • Morning Grounding (प्रातःकालीन लंगर)',
      body: 'आज की घटनाओं पर आपका वश नहीं, अपनी प्रतिक्रिया पर शत-प्रतिशत नियंत्रण है।',
      category: 'Morning Grounding',
    ),
    NotificationTrigger(
      id: 102,
      hour: 9,
      minute: 0,
      title: '09:00 AM • Work Entry Shield (द 3-सेकंड पॉज)',
      body: 'उकसावे पर रुकें। कोई सफाई नहीं, केवल तटस्थ अवलोकन।',
      category: 'Work Entry Shield',
    ),
    NotificationTrigger(
      id: 103,
      hour: 14,
      minute: 0,
      title: '02:00 PM • Mid-Day Audit (पारखी दृष्टि)',
      body: 'आपके \'ना\' कहने पर लोगों का व्यवहार बदला? बिना प्रतिक्रिया के केवल नोट करें।',
      category: 'Mid-Day Audit',
    ),
    NotificationTrigger(
      id: 104,
      hour: 21,
      minute: 30,
      title: '09:30 PM • Night Closure (3-इंडेक्स डायरी)',
      body: 'आज का हिसाब बंद करें। 60 सेकंड में 3-इंडेक्स एंट्री पूरी करें।',
      category: 'Night Closure',
    ),
  ];

  /// Returns today's active triggers from notifications_dataset.json
  static List<NotificationTrigger> get dailyTriggers {
    final datasetTriggers = NotificationsDatasetService().getTodayTriggers();
    if (datasetTriggers.isNotEmpty) {
      return datasetTriggers;
    }
    return defaultTriggers;
  }

  /// Initialize notifications and schedule recurring daily triggers
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint(
            '[Notification] User engaged notification: ${response.payload}',
          );
        },
      );

      _isInitialized = true;
      debugPrint('[NotificationService] Local notifications initialized.');

      // Request permissions
      await requestPermissions();

      // Schedule all 7-day recurring triggers from notifications_dataset.json
      await scheduleAllDailyTriggers();
    } catch (e, stack) {
      debugPrint('[NotificationService] Initialization error: $e\n$stack');
    }
  }

  /// Request runtime permissions on Android 13+ and iOS
  Future<bool> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation != null) {
        final granted = await androidImplementation
            .requestNotificationsPermission();
        return granted ?? false;
      }

      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('[NotificationService] Permission request exception: $e');
    }
    return true;
  }

  /// Schedules all stoic notifications according to the customizable slots saved in Hive.
  /// Automatically accounts for enabled/disabled slots and day-of-week active filters.
  Future<void> scheduleAllConfiguredTriggers() async {
    // 1. Cancel all existing scheduled triggers first to avoid orphaned alarms
    await cancelAll();

    // 2. Check master switch
    if (HiveStorage().isInitialized &&
        !HiveStorage().getNotificationsEnabled()) {
      debugPrint(
        '[NotificationService] Master notifications switch is OFF. All notifications cancelled.',
      );
      return;
    }

    // 3. Retrieve configured slots from local storage
    final slots = HiveStorage().isInitialized
        ? HiveStorage().getNotificationSlots()
        : NotificationSlotConfig.defaultSlots();

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    int scheduledCount = 0;

    for (final slot in slots) {
      if (!slot.isEnabled) continue;

      for (final weekday in slot.activeDays) {
        if (weekday < 1 || weekday > 7) continue;
        final dayName = days[weekday - 1];

        // Determine title & body
        String notificationTitle = slot.title;
        String notificationBody = slot.body;

        // If it's a standard/base slot, pull rich day-specific Devanagari text from dataset!
        if (!slot.isCustom) {
          final dayTriggers = NotificationsDatasetService().getTriggersForDay(
            dayName,
          );
          NotificationTrigger? match;
          for (final t in dayTriggers) {
            final catA = t.category.toLowerCase().replaceAll(' ', '');
            final catB = slot.category.toLowerCase().replaceAll(' ', '');
            final nameB = slot.slotName.toLowerCase().replaceAll(' ', '');
            if (catA == catB ||
                catA == nameB ||
                t.title.toLowerCase().contains(slot.category.toLowerCase())) {
              match = t;
              break;
            }
          }

          if (match != null) {
            notificationTitle = '${slot.formattedTime} • ${match.title}';
            notificationBody = match.body;
          }
        }

        final scheduleId = (slot.numericId % 1000) * 10 + weekday;

        await _scheduleWeeklyTrigger(
          weekday: weekday,
          scheduleId: scheduleId,
          hour: slot.hour,
          minute: slot.minute,
          title: notificationTitle,
          body: notificationBody,
          category: slot.category,
        );
        scheduledCount++;
      }
    }

    debugPrint(
      '[NotificationService] Successfully scheduled $scheduledCount reminders across ${slots.where((s) => s.isEnabled).length} active slots.',
    );
  }

  /// Alias for backward compatibility
  Future<void> scheduleAllDailyTriggers() => scheduleAllConfiguredTriggers();

  /// Schedules a weekly recurring trigger for a specific weekday and time
  Future<void> _scheduleWeeklyTrigger({
    required int weekday,
    required int scheduleId,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String category,
  }) async {
    try {
      final scheduledDate = _nextInstanceOfDayAndTime(weekday, hour, minute);

      const androidDetails = AndroidNotificationDetails(
        'sthitaprajna_scheduled_channel',
        'Stoic Strategic Triggers',
        channelDescription: 'Critical executive grounding and stoic reminders at scheduled intervals',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        color: Color(0xFF090D16),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        scheduleId,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: category,
      );
    } catch (e) {
      debugPrint(
        '[NotificationService] Failed to schedule trigger $scheduleId: $e',
      );
    }
  }

  /// Calculates the next TZDateTime for a specific weekday, hour, and minute
  tz.TZDateTime _nextInstanceOfDayAndTime(int weekday, int hour, int minute) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Calculates the next TZDateTime for the given hour and minute
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Fires an instant test notification for a configured reminder slot
  Future<void> fireTestNotificationForSlot(NotificationSlotConfig slot) async {
    const androidDetails = AndroidNotificationDetails(
      'sthitaprajna_immediate_test',
      'Stoic Test Triggers',
      channelDescription: 'Immediate test dispatch for stoic notifications',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final title = '[TEST] ${slot.formattedTime} • ${slot.title}';
    final body = slot.body.isNotEmpty
        ? slot.body
        : 'Strategic grounding reminder for ${slot.slotName}.';

    await _notificationsPlugin.show(
      slot.numericId + 9000,
      title,
      body,
      details,
      payload: 'TEST_${slot.category}',
    );
  }

  /// Fires an instant test notification for any trigger so the executive can inspect it immediately
  Future<void> fireTestNotification(NotificationTrigger trigger) async {
    const androidDetails = AndroidNotificationDetails(
      'sthitaprajna_immediate_test',
      'Stoic Test Triggers',
      channelDescription: 'Immediate test dispatch for stoic notifications',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      trigger.id + 5000,
      '[TEST] ${trigger.title}',
      trigger.body,
      details,
      payload: 'TEST_${trigger.category}',
    );
  }

  /// Toggles the master notification switch and immediately reschedules or cancels all alarms
  Future<void> toggleMasterNotifications(bool enabled) async {
    if (HiveStorage().isInitialized) {
      await HiveStorage().setNotificationsEnabled(enabled);
    }
    await scheduleAllConfiguredTriggers();
  }

  /// Cancels all scheduled notifications
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
