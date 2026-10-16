import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// NotificationItem represents a scheduled strategic stoic prompt
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

  // The 4 Daily Strategic Triggers mandated by Sthitaprajna
  static const List<NotificationTrigger> dailyTriggers = [
    NotificationTrigger(
      id: 101,
      hour: 5,
      minute: 45,
      title: '05:45 AM • Morning Premeditatio Malorum',
      body: 'You will face the arrogant, ungrateful, and deceitful today. They act from ignorance. Armor your mind; retain your calm.',
      category: 'DAWN_ARMOR',
    ),
    NotificationTrigger(
      id: 102,
      hour: 9,
      minute: 30,
      title: '09:30 AM • Pre-Battle Equanimity',
      body: 'Dichotomy of Control: You do not control boardroom noise or passive aggression. You only control your pause and response.',
      category: 'TACTICAL_SHIELD',
    ),
    NotificationTrigger(
      id: 103,
      hour: 14,
      minute: 0,
      title: '02:00 PM • Physiological Cortisol Reset',
      body: 'Drop your shoulders. Tongue on the roof of mouth. Deep breath. Do not absorb corporate panic.',
      category: 'MIDDAY_RESET',
    ),
    NotificationTrigger(
      id: 104,
      hour: 21,
      minute: 30,
      title: '09:30 PM • 60-Second Sthitaprajna Debrief',
      body: 'Close the perimeter. Log your Reaction Control and Boundary Retained. Discharge today\'s residue.',
      category: 'EVENING_DEBRIEF',
    ),
  ];

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

      // Request permissions where necessary
      await requestPermissions();

      // Schedule all 4 daily notifications
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

  /// Schedules all 4 daily recurring stoic notifications
  Future<void> scheduleAllDailyTriggers() async {
    for (final trigger in dailyTriggers) {
      await scheduleDailyTrigger(trigger);
    }
    debugPrint(
      '[NotificationService] Scheduled all 4 strategic notifications.',
    );
  }

  /// Schedules an individual recurring daily notification at its exact time
  Future<void> scheduleDailyTrigger(NotificationTrigger trigger) async {
    try {
      final scheduledDate = _nextInstanceOfTime(trigger.hour, trigger.minute);

      const androidDetails = AndroidNotificationDetails(
        'sthitaprajna_scheduled_channel',
        'Stoic Strategic Triggers',
        channelDescription: 'Critical executive grounding and stoic reminders at scheduled intervals',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        color: Color(0xFF09090B),
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
        trigger.id,
        trigger.title,
        trigger.body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: trigger.category,
      );
    } catch (e) {
      debugPrint(
        '[NotificationService] Failed to schedule trigger ${trigger.id}: $e',
      );
    }
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
      trigger.id + 1000,
      '[TEST] ${trigger.title}',
      trigger.body,
      details,
      payload: 'TEST_${trigger.category}',
    );
  }

  /// Cancels all scheduled notifications
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
