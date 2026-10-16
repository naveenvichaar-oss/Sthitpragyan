import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/core/notifications/notification_service.dart';

void main() {
  group('Notification Schedule Tests', () {
    test('Contains exactly 4 scheduled daily triggers as mandated', () {
      final triggers = NotificationService.dailyTriggers;
      expect(triggers.length, equals(4));
    });

    test('Trigger 1 is scheduled at 05:45 AM (Dawn Premeditatio Malorum)', () {
      final t = NotificationService.dailyTriggers[0];
      expect(t.hour, equals(5));
      expect(t.minute, equals(45));
      expect(t.title, contains('05:45 AM'));
      expect(t.category, equals('DAWN_ARMOR'));
    });

    test('Trigger 2 is scheduled at 09:30 AM (Pre-Battle Equanimity)', () {
      final t = NotificationService.dailyTriggers[1];
      expect(t.hour, equals(9));
      expect(t.minute, equals(30));
      expect(t.title, contains('09:30 AM'));
      expect(t.category, equals('TACTICAL_SHIELD'));
    });

    test('Trigger 3 is scheduled at 02:00 PM (Midday Cortisol Reset)', () {
      final t = NotificationService.dailyTriggers[2];
      expect(t.hour, equals(14));
      expect(t.minute, equals(0));
      expect(t.title, contains('02:00 PM'));
      expect(t.category, equals('MIDDAY_RESET'));
    });

    test(
      'Trigger 4 is scheduled at 09:30 PM (Evening Sthitaprajna Debrief)',
      () {
        final t = NotificationService.dailyTriggers[3];
        expect(t.hour, equals(21));
        expect(t.minute, equals(30));
        expect(t.title, contains('09:30 PM'));
        expect(t.category, equals('EVENING_DEBRIEF'));
      },
    );
  });
}
