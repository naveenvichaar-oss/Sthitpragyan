import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/features/journal/data/models/journal_entry.dart';

void main() {
  group('JournalEntry Model Tests', () {
    test('Calculates composite equanimity score correctly', () {
      final perfect = JournalEntry(
        id: '1',
        dateKey: '2026-10-17',
        timestamp: DateTime.now(),
        reactionControl: 10.0,
        boundaryRetained: 10.0,
        coreOutput: 'Perfect day',
      );
      expect(perfect.compositeScore, equals(100));

      final mid = JournalEntry(
        id: '2',
        dateKey: '2026-10-17',
        timestamp: DateTime.now(),
        reactionControl: 5.0,
        boundaryRetained: 5.0,
        coreOutput: 'Average day',
      );
      expect(mid.compositeScore, equals(50));

      final zero = JournalEntry(
        id: '3',
        dateKey: '2026-10-17',
        timestamp: DateTime.now(),
        reactionControl: 0.0,
        boundaryRetained: 0.0,
        coreOutput: 'Rough day',
      );
      expect(zero.compositeScore, equals(0));
    });

    test('Derives qualitative reaction labels properly', () {
      final high = JournalEntry(
        id: '1',
        dateKey: '2026-10-17',
        timestamp: DateTime.now(),
        reactionControl: 9.5,
        boundaryRetained: 8.0,
        coreOutput: 'Composed',
      );
      expect(high.reactionLabel, equals('Absolute Sthitaprajna'));

      final low = JournalEntry(
        id: '2',
        dateKey: '2026-10-17',
        timestamp: DateTime.now(),
        reactionControl: 2.0,
        boundaryRetained: 8.0,
        coreOutput: 'Hijacked',
      );
      expect(low.reactionLabel, equals('Amygdala Hijacked'));
    });

    test('Derives qualitative boundary labels properly', () {
      final fortress = JournalEntry(
        id: '1',
        dateKey: '2026-10-17',
        timestamp: DateTime.now(),
        reactionControl: 8.0,
        boundaryRetained: 9.5,
        coreOutput: 'Firm boundaries',
      );
      expect(fortress.boundaryLabel, equals('Impenetrable Fortress'));

      final breach = JournalEntry(
        id: '2',
        dateKey: '2026-10-17',
        timestamp: DateTime.now(),
        reactionControl: 8.0,
        boundaryRetained: 1.5,
        coreOutput: 'Overworked',
      );
      expect(breach.boundaryLabel, equals('Total Boundary Breach'));
    });

    test('Map serialization roundtrip is loss-free', () {
      final original = JournalEntry(
        id: 'test_roundtrip',
        dateKey: '2026-10-17',
        timestamp: DateTime(2026, 10, 17, 21, 30),
        reactionControl: 8.5,
        boundaryRetained: 7.5,
        coreOutput: 'Refused unplanned weekend scope without apologizing.',
      );

      final map = original.toMap();
      final restored = JournalEntry.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.dateKey, equals(original.dateKey));
      expect(restored.reactionControl, equals(original.reactionControl));
      expect(restored.boundaryRetained, equals(original.boundaryRetained));
      expect(restored.coreOutput, equals(original.coreOutput));
    });
  });
}
