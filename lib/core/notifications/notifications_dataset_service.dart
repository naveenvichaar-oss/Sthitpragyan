import 'dart:convert';

import 'package:flutter/services.dart';

import 'notification_service.dart';

/// NotificationsDatasetService parses and provides daily scheduled triggers
/// from notifications_dataset.json.
class NotificationsDatasetService {
  static final NotificationsDatasetService _instance =
      NotificationsDatasetService._internal();
  factory NotificationsDatasetService() => _instance;
  NotificationsDatasetService._internal();

  List<Map<String, dynamic>> _dataset = [];
  bool _isLoaded = false;

  Future<void> loadDataset() async {
    if (_isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString(
        'notifications_dataset.json',
      );
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is List) {
        _dataset = List<Map<String, dynamic>>.from(decoded);
        _isLoaded = true;
      }
    } catch (_) {
      // Fallback in-memory dataset if bundle isn't available during testing
      _dataset = _fallbackDataset;
      _isLoaded = true;
    }
  }

  /// Returns triggers for a specific weekday (e.g. "Monday", "Tuesday")
  List<NotificationTrigger> getTriggersForDay(String dayName) {
    final dayObj = _dataset.firstWhere(
      (d) => (d['day'] as String).toLowerCase() == dayName.toLowerCase(),
      orElse: () => _dataset.isNotEmpty ? _dataset.first : {},
    );

    final slots = dayObj['slots'] as List<dynamic>? ?? [];
    return slots.map((slot) {
      final timeStr = slot['time'] as String? ?? '05:45';
      final parts = timeStr.split(':');
      final hour = int.tryParse(parts[0]) ?? 5;
      final minute = int.tryParse(parts[1]) ?? 45;

      return NotificationTrigger(
        id: hour * 100 + minute,
        hour: hour,
        minute: minute,
        title: slot['title'] as String? ?? '',
        body: slot['body'] as String? ?? '',
        category: slot['slot_name'] as String? ?? 'DEFENSIVE_SLOT',
      );
    }).toList();
  }

  /// Returns the 4 triggers for today's current weekday
  List<NotificationTrigger> getTodayTriggers([DateTime? date]) {
    final now = date ?? DateTime.now();
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dayName = days[now.weekday - 1];
    return getTriggersForDay(dayName);
  }

  static const List<Map<String, dynamic>> _fallbackDataset = [
    {
      "day": "Monday",
      "slots": [
        {
          "time": "05:45",
          "slot_name": "Morning Grounding",
          "title": "प्रातःकालीन लंगर",
          "body": "आज की घटनाओं पर आपका वश नहीं, अपनी प्रतिक्रिया पर शत-प्रतिशत नियंत्रण है।",
        },
        {
          "time": "09:00",
          "slot_name": "Work Entry Shield",
          "title": "द 3-सेकंड पॉज",
          "body": "उकसावे पर रुकें। कोई सफाई नहीं, केवल तटस्थ अवलोकन।",
        },
        {
          "time": "14:00",
          "slot_name": "Mid-Day Audit",
          "title": "पारखी दृष्टि",
          "body": "आपके 'ना' कहने पर लोगों का व्यवहार बदला? बिना प्रतिक्रिया के केवल नोट करें।",
        },
        {
          "time": "21:30",
          "slot_name": "Night Closure",
          "title": "3-इंडेक्स डायरी",
          "body":
              "आज का हिसाब बंद करें। 60 सेकंड में 3-इंडेक्स एंट्री पूरी करें।",
        },
      ],
    },
  ];
}
