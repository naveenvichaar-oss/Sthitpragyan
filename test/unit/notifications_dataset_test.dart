import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/core/notifications/notifications_dataset_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await NotificationsDatasetService().loadDataset();
  });

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

    test(
      'getTriggersForDay returns bilingual English and Hindi strings for Saturday slot',
      () {
        final service = NotificationsDatasetService();
        final saturdaySlots = service.getTriggersForDay('Saturday');

        expect(saturdaySlots.length, equals(4));

        final morningSlot = saturdaySlots[0];
        // Hindi mode
        expect(morningSlot.localizedTitle(true), equals('सप्ताहांत स्थिरता'));
        expect(
          morningSlot.localizedBody(true),
          contains('प्रकृति के साथ समय, अपनों के साथ उपस्थिति। मन पूर्ण शांत।'),
        );
        expect(morningSlot.localizedCategory(true), equals('प्रातःकालीन लंगर'));

        // English mode
        expect(morningSlot.localizedTitle(false), equals('Weekend Equanimity'));
        expect(
          morningSlot.localizedBody(false),
          contains(
            'Time in nature, pure presence with loved ones. Mind in complete stillness.',
          ),
        );
        expect(morningSlot.localizedCategory(false), equals('MORNING GROUNDING'));
      },
    );

    test('All 7 days have non-empty bilingual English and Hindi content for all 4 slots', () {
      final service = NotificationsDatasetService();
      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];

      for (final day in days) {
        final slots = service.getTriggersForDay(day);
        expect(slots.length, equals(4), reason: 'Day $day must have 4 slots');
        for (final slot in slots) {
          expect(slot.title.trim().isNotEmpty, isTrue);
          expect(slot.body.trim().isNotEmpty, isTrue);
          expect(slot.localizedTitle(true).trim().isNotEmpty, isTrue);
          expect(slot.localizedBody(true).trim().isNotEmpty, isTrue);
          expect(slot.localizedTitle(false).trim().isNotEmpty, isTrue);
          expect(slot.localizedBody(false).trim().isNotEmpty, isTrue);
          // In English mode, title should not be Devanagari
          expect(
            slot.localizedTitle(false),
            isNot(equals(slot.localizedTitle(true))),
            reason: 'Slot ${slot.category} on $day should have distinct English title',
          );
        }
      }
    });
  });
}
