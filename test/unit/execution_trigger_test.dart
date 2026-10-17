import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/features/execution_trigger/data/models/execution_trigger.dart';

void main() {
  group('ExecutionTrigger Model Tests', () {
    final trigger = ExecutionTrigger(
      id: 'block_test_1',
      title: 'Deep Work Sprint',
      devanagariSubtitle: 'तीव्र एकाग्रता काल',
      timeOfDay: '09:30',
      intent: 'Zero context switching. Uncompromising cognitive leverage.',
      category: 'Deep Work',
      isEnabled: true,
      streakCount: 3,
      lastExecutedAt: DateTime(2026, 10, 17, 10, 0),
    );

    test('Serializes toMap and fromMap bidirectionally', () {
      final map = trigger.toMap();
      final reconstructed = ExecutionTrigger.fromMap(map);

      expect(reconstructed.id, equals(trigger.id));
      expect(reconstructed.title, equals(trigger.title));
      expect(reconstructed.devanagariSubtitle, equals(trigger.devanagariSubtitle));
      expect(reconstructed.timeOfDay, equals(trigger.timeOfDay));
      expect(reconstructed.intent, equals(trigger.intent));
      expect(reconstructed.category, equals(trigger.category));
      expect(reconstructed.isEnabled, isTrue);
      expect(reconstructed.streakCount, equals(3));
      expect(reconstructed.lastExecutedAt, equals(DateTime(2026, 10, 17, 10, 0)));
    });

    test('copyWith updates specified fields', () {
      final updated = trigger.copyWith(
        streakCount: 4,
        isEnabled: false,
      );

      expect(updated.streakCount, equals(4));
      expect(updated.isEnabled, isFalse);
      expect(updated.title, equals(trigger.title));
      expect(updated.id, equals(trigger.id));
    });

    test('defaultTriggers contains 4 non-negotiable blocks', () {
      final defaults = ExecutionTrigger.defaultTriggers();
      expect(defaults.length, equals(4));

      final titles = defaults.map((d) => d.title).toList();
      expect(titles, contains('Morning Grounding & Strategy'));
      expect(titles, contains('Deep Work Sprint I'));
      expect(titles, contains('Friction Clear / Hard Task'));
      expect(titles, contains('Evening Audit & Closure'));

      for (final item in defaults) {
        expect(item.id.isNotEmpty, isTrue);
        expect(item.timeOfDay.isNotEmpty, isTrue);
        expect(item.devanagariSubtitle.isNotEmpty, isTrue);
        expect(item.intent.isNotEmpty, isTrue);
        expect(item.isEnabled, isTrue);
      }
    });

    test('isExecutedToday evaluates correctly', () {
      final todayTrigger = ExecutionTrigger(
        id: 'today_1',
        title: 'Today Block',
        devanagariSubtitle: 'आज',
        timeOfDay: '10:00',
        intent: 'Test',
        category: 'Deep Work',
        lastExecutedAt: DateTime.now(),
      );
      expect(todayTrigger.isExecutedToday, isTrue);

      final yesterdayTrigger = ExecutionTrigger(
        id: 'yesterday_1',
        title: 'Yesterday Block',
        devanagariSubtitle: 'कल',
        timeOfDay: '10:00',
        intent: 'Test',
        category: 'Deep Work',
        lastExecutedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(yesterdayTrigger.isExecutedToday, isFalse);
    });
  });
}
