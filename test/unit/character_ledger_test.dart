import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/features/character_ledger/data/models/character_trait_entry.dart';

void main() {
  group('CharacterTraitCategory Enum Tests', () {
    test('CharacterTraitCategory parses case-insensitively and maps correctly', () {
      expect(
        CharacterTraitCategory.fromString('Magnanimity'),
        equals(CharacterTraitCategory.magnanimity),
      );
      expect(
        CharacterTraitCategory.fromString('उदारता'),
        equals(CharacterTraitCategory.magnanimity),
      );
      expect(
        CharacterTraitCategory.fromString('gravitas'),
        equals(CharacterTraitCategory.gravitas),
      );
      expect(
        CharacterTraitCategory.fromString('गांभीर्य'),
        equals(CharacterTraitCategory.gravitas),
      );
      expect(
        CharacterTraitCategory.fromString('genuine joy & grace'),
        equals(CharacterTraitCategory.joy),
      );
      expect(
        CharacterTraitCategory.fromString('tactical restraint'),
        equals(CharacterTraitCategory.restraint),
      );
      expect(
        CharacterTraitCategory.fromString('arbitrary_unknown'),
        equals(CharacterTraitCategory.custom),
      );
    });

    test('All categories have valid Devanagari, accentColor, and icons', () {
      for (final cat in CharacterTraitCategory.values) {
        expect(cat.displayName.isNotEmpty, isTrue);
        expect(cat.devanagari.isNotEmpty, isTrue);
        expect(cat.subtitle.isNotEmpty, isTrue);
        expect(cat.accentColor, isA<Color>());
        expect(cat.icon, isA<IconData>());
      }
    });
  });

  group('CharacterTraitEntry Model & Serialization Tests', () {
    final now = DateTime(2026, 10, 17, 14, 30);
    final entry = CharacterTraitEntry(
      id: 'trait_test_1',
      category: CharacterTraitCategory.restraint,
      title: 'Maintained 4-second pause during board critique',
      situation: 'Executive Standup',
      behaviorObservation: 'Refrained from immediate defense. Counted 4 seconds and spoke in low monotone.',
      reflection: 'Silence shifted leverage back to our team.',
      tags: ['#StrategicSilence', '#ExecutiveVoice'],
      gravitasRating: 5,
      timestamp: now,
    );

    test('Serializes toMap and fromMap bidirectionally without loss', () {
      final map = entry.toMap();
      final reconstructed = CharacterTraitEntry.fromMap(map);

      expect(reconstructed.id, equals(entry.id));
      expect(reconstructed.category, equals(entry.category));
      expect(reconstructed.title, equals(entry.title));
      expect(reconstructed.situation, equals(entry.situation));
      expect(reconstructed.behaviorObservation, equals(entry.behaviorObservation));
      expect(reconstructed.reflection, equals(entry.reflection));
      expect(reconstructed.tags, equals(['#StrategicSilence', '#ExecutiveVoice']));
      expect(reconstructed.gravitasRating, equals(5));
      expect(reconstructed.timestamp, equals(now));
    });

    test('copyWith enables immutable updates', () {
      final updated = entry.copyWith(
        title: 'Updated Title',
        gravitasRating: 4,
        category: CharacterTraitCategory.magnanimity,
      );

      expect(updated.title, equals('Updated Title'));
      expect(updated.gravitasRating, equals(4));
      expect(updated.category, equals(CharacterTraitCategory.magnanimity));
      expect(updated.situation, equals(entry.situation));
      expect(updated.id, equals(entry.id));
    });

    test('starterEntries provides vetted entries across all 4 core virtues', () {
      final starters = CharacterTraitEntry.starterEntries();
      expect(starters.length, equals(4));

      final categories = starters.map((e) => e.category).toSet();
      expect(categories.contains(CharacterTraitCategory.restraint), isTrue);
      expect(categories.contains(CharacterTraitCategory.magnanimity), isTrue);
      expect(categories.contains(CharacterTraitCategory.gravitas), isTrue);
      expect(categories.contains(CharacterTraitCategory.joy), isTrue);

      for (final item in starters) {
        expect(item.id.isNotEmpty, isTrue);
        expect(item.title.isNotEmpty, isTrue);
        expect(item.situation.isNotEmpty, isTrue);
        expect(item.behaviorObservation.isNotEmpty, isTrue);
        expect(item.tags.isNotEmpty, isTrue);
        expect(item.gravitasRating, equals(5));
      }
    });
  });
}
