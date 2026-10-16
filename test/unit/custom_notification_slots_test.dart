import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/features/settings/data/models/notification_slot_config.dart';

void main() {
  group('NotificationSlotConfig Tests', () {
    test('defaultSlots returns 4 canonical checkpoints', () {
      final slots = NotificationSlotConfig.defaultSlots();
      expect(slots.length, equals(4));

      final morning = slots[0];
      expect(morning.id, equals('slot_morning'));
      expect(morning.hour, equals(5));
      expect(morning.minute, equals(45));
      expect(morning.formattedTime, equals('05:45 AM'));
      expect(morning.daysSummary, equals('Every day'));

      final workEntry = slots[1];
      expect(workEntry.id, equals('slot_work_entry'));
      expect(workEntry.hour, equals(9));
      expect(workEntry.minute, equals(0));
      expect(workEntry.formattedTime, equals('09:00 AM'));
      expect(workEntry.daysSummary, equals('Weekdays (Mon–Fri)'));

      final midday = slots[2];
      expect(midday.id, equals('slot_midday'));
      expect(midday.hour, equals(14));
      expect(midday.minute, equals(0));
      expect(midday.formattedTime, equals('02:00 PM'));
      expect(midday.daysSummary, equals('Weekdays (Mon–Fri)'));

      final night = slots[3];
      expect(night.id, equals('slot_night_closure'));
      expect(night.hour, equals(21));
      expect(night.minute, equals(30));
      expect(night.formattedTime, equals('09:30 PM'));
      expect(night.daysSummary, equals('Every day'));
    });

    test('Weekend filter accurately identifies weekdays vs weekends', () {
      const weekdayOnly = NotificationSlotConfig(
        id: 'slot_weekday',
        numericId: 901,
        slotName: 'Weekday Focus',
        title: 'Focus',
        body: 'Observe without reaction',
        category: 'Focus',
        hour: 10,
        minute: 0,
        activeDays: [1, 2, 3, 4, 5],
      );

      expect(weekdayOnly.daysSummary, equals('Weekdays (Mon–Fri)'));
      expect(weekdayOnly.isDayActive(1), isTrue); // Mon
      expect(weekdayOnly.isDayActive(5), isTrue); // Fri
      expect(weekdayOnly.isDayActive(6), isFalse); // Sat
      expect(weekdayOnly.isDayActive(7), isFalse); // Sun

      const weekendOnly = NotificationSlotConfig(
        id: 'slot_weekend',
        numericId: 902,
        slotName: 'Weekend Equanimity',
        title: 'Weekend',
        body: 'Disconnect from office pressure',
        category: 'Rest',
        hour: 11,
        minute: 30,
        activeDays: [6, 7],
      );

      expect(weekendOnly.daysSummary, equals('Weekends (Sat–Sun)'));
      expect(weekendOnly.isDayActive(6), isTrue);
      expect(weekendOnly.isDayActive(7), isTrue);
      expect(weekendOnly.isDayActive(1), isFalse);
    });

    test('Custom days summary correctly formats subsets', () {
      const customSlot = NotificationSlotConfig(
        id: 'slot_custom_mwf',
        numericId: 903,
        slotName: 'Mon Wed Fri Check',
        title: 'Tri-Weekly',
        body: 'Audit boundary',
        category: 'Custom',
        hour: 15,
        minute: 15,
        activeDays: [1, 3, 5],
      );

      expect(customSlot.daysSummary, equals('Mon, Wed, Fri'));
      expect(customSlot.formattedTime, equals('03:15 PM'));
    });

    test('Serialization toMap and fromMap preserves all fields', () {
      const original = NotificationSlotConfig(
        id: 'slot_deep_work_44',
        numericId: 888,
        slotName: 'Deep Work Reset',
        title: 'Mute Distractions',
        body: 'Silence notifications and focus on single output',
        category: 'Deep Work',
        hour: 16,
        minute: 45,
        isEnabled: false,
        activeDays: [2, 4],
        isCustom: true,
      );

      final map = original.toMap();
      final restored = NotificationSlotConfig.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.numericId, equals(original.numericId));
      expect(restored.slotName, equals(original.slotName));
      expect(restored.title, equals(original.title));
      expect(restored.body, equals(original.body));
      expect(restored.category, equals(original.category));
      expect(restored.hour, equals(original.hour));
      expect(restored.minute, equals(original.minute));
      expect(restored.isEnabled, equals(false));
      expect(restored.activeDays, equals([2, 4]));
      expect(restored.isCustom, isTrue);
    });

    test('copyWith enables immutable state updates', () {
      final base = NotificationSlotConfig.defaultSlots()[0];
      final toggled = base.copyWith(isEnabled: false);
      expect(toggled.isEnabled, isFalse);
      expect(toggled.hour, equals(base.hour));

      final rescheduled = base.copyWith(hour: 6, minute: 30);
      expect(rescheduled.hour, equals(6));
      expect(rescheduled.minute, equals(30));
      expect(rescheduled.formattedTime, equals('06:30 AM'));
    });
  });
}
