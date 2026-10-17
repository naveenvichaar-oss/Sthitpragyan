import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/features/joy_reservoir/data/models/joy_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JoyCategory Enum Tests', () {
    test('JoyCategory parses case-insensitively and maps correctly', () {
      expect(JoyCategory.fromString('music'), JoyCategory.music);
      expect(JoyCategory.fromString('audio'), JoyCategory.music);
      expect(JoyCategory.fromString('sound'), JoyCategory.music);

      expect(JoyCategory.fromString('visual'), JoyCategory.visual);
      expect(JoyCategory.fromString('image'), JoyCategory.visual);
      expect(JoyCategory.fromString('photo'), JoyCategory.visual);

      expect(JoyCategory.fromString('quote'), JoyCategory.quote);
      expect(JoyCategory.fromString('words'), JoyCategory.quote);

      expect(JoyCategory.fromString('memory'), JoyCategory.memory);
      expect(JoyCategory.fromString('anchor'), JoyCategory.memory);

      expect(JoyCategory.fromString('unknown'), JoyCategory.quote);
    });

    test('JoyCategory badge labels and storage strings are valid', () {
      expect(JoyCategory.music.badgeLabel, 'MUSIC & SOUND');
      expect(JoyCategory.visual.badgeLabel, 'VISUAL ANCHOR');
      expect(JoyCategory.quote.badgeLabel, 'COMFORT WORDS');
      expect(JoyCategory.memory.badgeLabel, 'SOUL MEMORY');

      expect(JoyCategory.music.toStorageString(), 'music');
      expect(JoyCategory.visual.toStorageString(), 'visual');
      expect(JoyCategory.quote.toStorageString(), 'quote');
      expect(JoyCategory.memory.toStorageString(), 'memory');
    });
  });

  group('JoyItem Model & Serialization Tests', () {
    test('JoyItem serializes toMap and fromMap bidirectionally', () {
      final original = JoyItem(
        id: 'joy_test_1',
        title: 'Morning Forest Flute',
        category: JoyCategory.music,
        mediaUrlOrPath: 'https://youtube.com/watch?v=sample123',
        note: 'Deep grounding before board meeting.',
        timestamp: DateTime(2026, 10, 17, 8, 30),
      );

      final map = original.toMap();
      final reconstituted = JoyItem.fromMap(map);

      expect(reconstituted.id, equals(original.id));
      expect(reconstituted.title, equals(original.title));
      expect(reconstituted.category, equals(JoyCategory.music));
      expect(reconstituted.mediaUrlOrPath, equals(original.mediaUrlOrPath));
      expect(reconstituted.note, equals(original.note));
      expect(reconstituted.timestamp, equals(original.timestamp));
    });

    test('JoyItem copyWith enables immutable updates', () {
      final original = JoyItem(
        id: 'joy_test_2',
        title: 'Ocean Sunset',
        category: JoyCategory.visual,
        mediaUrlOrPath: 'https://example.com/sunset.jpg',
        note: 'Stillness',
        timestamp: DateTime(2026, 10, 17),
      );

      final updated = original.copyWith(
        title: 'Golden Sunset at Kanyakumari',
        note: 'Deep peace and gratitude.',
      );

      expect(updated.id, equals(original.id));
      expect(updated.title, equals('Golden Sunset at Kanyakumari'));
      expect(updated.category, equals(JoyCategory.visual));
      expect(updated.mediaUrlOrPath, equals(original.mediaUrlOrPath));
      expect(updated.note, equals('Deep peace and gratitude.'));
    });

    test('starterAnchors contains pre-seeded calming resources across categories', () {
      final starters = JoyItem.starterAnchors();
      expect(starters.length, greaterThanOrEqualTo(4));

      final hasMusic = starters.any((i) => i.category == JoyCategory.music);
      final hasVisual = starters.any((i) => i.category == JoyCategory.visual);
      final hasQuote = starters.any((i) => i.category == JoyCategory.quote);
      final hasMemory = starters.any((i) => i.category == JoyCategory.memory);

      expect(hasMusic, isTrue);
      expect(hasVisual, isTrue);
      expect(hasQuote, isTrue);
      expect(hasMemory, isTrue);

      for (final item in starters) {
        expect(item.id, isNotEmpty);
        expect(item.title, isNotEmpty);
      }
    });
  });
}
