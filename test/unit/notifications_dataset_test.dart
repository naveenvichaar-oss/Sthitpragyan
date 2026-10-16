import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/core/notifications/notifications_dataset_service.dart';

void main() {
  group('NotificationsDatasetService Tests', () {
    test(
      'getTriggersForDay returns 4 slots for Monday with Devanagari titles',
      () {
        final service = NotificationsDatasetService();
        final mondaySlots = service.getTriggersForDay('Monday');

        expect(mondaySlots.length, equals(4));

        // Slot 1: 05:45 Morning Grounding
        expect(mondaySlots[0].hour, equals(5));
        expect(mondaySlots[0].minute, equals(45));
        expect(mondaySlots[0].title, contains('प्रातःकालीन लंगर'));

        // Slot 2: 09:00 Work Entry Shield
        expect(mondaySlots[1].hour, equals(9));
        expect(mondaySlots[1].minute, equals(0));
        expect(mondaySlots[1].title, contains('द 3-सेकंड पॉज'));

        // Slot 3: 14:00 Mid-Day Audit
        expect(mondaySlots[2].hour, equals(14));
        expect(mondaySlots[2].minute, equals(0));
        expect(mondaySlots[2].title, contains('पारखी दृष्टि'));

        // Slot 4: 21:30 Night Closure
        expect(mondaySlots[3].hour, equals(21));
        expect(mondaySlots[3].minute, equals(30));
        expect(mondaySlots[3].title, contains('3-इंडेक्स डायरी'));
      },
    );

    test('getTodayTriggers returns 4 slots for any given DateTime anchor', () {
      final service = NotificationsDatasetService();
      // Monday anchor
      final mondayDate = DateTime(2026, 10, 19); // Oct 19, 2026 is Monday
      final triggers = service.getTodayTriggers(mondayDate);

      expect(triggers.length, equals(4));
      expect(triggers[0].title, contains('प्रातःकालीन लंगर'));
    });
  });
}
