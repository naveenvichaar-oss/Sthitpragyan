import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/features/sos/data/defensive_scripts_vault.dart';

void main() {
  group('DefensiveScriptsVault Tests', () {
    test(
      'Vault has all core categories including FSM specification categories',
      () {
        final categories = DefensiveScriptsVault.categories;
        expect(categories, contains('All'));
        expect(categories, contains('Unjust Accusation'));
        expect(categories, contains('Intimidation'));
        expect(categories, contains('Impossible Deadlines'));
        expect(categories, contains('Interruption'));
        expect(categories, contains('Gaslighting'));
        expect(categories, contains('Blame Shifting'));
        expect(categories, contains('Passive Aggression'));
        expect(categories, contains('Scope Creep'));
      },
    );

    test('Scripts vault contains high quality entries with executive tone guidance', () {
      const all = DefensiveScriptsVault.scripts;
      expect(all.length, greaterThanOrEqualTo(10));

      for (final script in all) {
        expect(script.id.isNotEmpty, isTrue);
        expect(script.category.isNotEmpty, isTrue);
        expect(script.hostileTrigger.isNotEmpty, isTrue);
        expect(script.executiveScript.isNotEmpty, isTrue);
        expect(script.tacticalRationale.isNotEmpty, isTrue);
        expect(script.toneGuidance.isNotEmpty, isTrue);
      }
    });

    test('Category filtering functions correctly for core specification categories', () {
      final unjust = DefensiveScriptsVault.getByCategory('Unjust Accusation');
      expect(unjust.isNotEmpty, isTrue);
      expect(unjust.first.executiveScript, contains('विशिष्ट फैक्चुअल बदलाव'));

      final intimidation = DefensiveScriptsVault.getByCategory('Intimidation');
      expect(intimidation.isNotEmpty, isTrue);
      expect(intimidation.first.executiveScript, contains('नोट कर लिया है'));

      final deadlines = DefensiveScriptsVault.getByCategory(
        'Impossible Deadlines',
      );
      expect(deadlines.isNotEmpty, isTrue);
      expect(
        deadlines.first.executiveScript,
        contains('प्राथमिकता तय कर दीजिए'),
      );
    });

    test('DefensiveScript serializes toMap and fromMap bidirectionally', () {
      const original = DefensiveScript(
        id: 'test_custom_01',
        category: 'Micromanagement',
        scenario: 'Manager asks for hourly updates',
        hostileTrigger: '"I need an update on your progress every hour"',
        executiveScript:
            'I will provide comprehensive morning and end-of-day summaries to preserve uninterrupted deep execution blocks.',
        tacticalRationale: 'Prevents constant context switching while offering structured visibility.',
        toneGuidance: 'Calm, steady, matter-of-fact.',
        isCustom: true,
      );

      final map = original.toMap();
      expect(map['id'], equals('test_custom_01'));
      expect(map['category'], equals('Micromanagement'));
      expect(map['isCustom'], isTrue);

      final deserialized = DefensiveScript.fromMap(map);
      expect(deserialized.id, equals(original.id));
      expect(deserialized.category, equals(original.category));
      expect(deserialized.hostileTrigger, equals(original.hostileTrigger));
      expect(deserialized.executiveScript, equals(original.executiveScript));
      expect(deserialized.tacticalRationale, equals(original.tacticalRationale));
      expect(deserialized.toneGuidance, equals(original.toneGuidance));
      expect(deserialized.isCustom, isTrue);
    });

    test('DefensiveScript copyWith creates accurate immutable copies', () {
      const script = DefensiveScript(
        id: 'test_script',
        category: 'Gaslighting',
        scenario: 'Initial scenario',
        hostileTrigger: 'Initial trigger',
        executiveScript: 'Initial script',
        tacticalRationale: 'Initial rationale',
        toneGuidance: 'Initial tone',
      );

      final updated = script.copyWith(
        executiveScript: 'Modified defensive response',
        toneGuidance: 'Flatter, slower cadence',
        isCustom: true,
      );

      expect(updated.id, equals('test_script'));
      expect(updated.category, equals('Gaslighting'));
      expect(updated.executiveScript, equals('Modified defensive response'));
      expect(updated.toneGuidance, equals('Flatter, slower cadence'));
      expect(updated.isCustom, isTrue);
      expect(updated.hostileTrigger, equals('Initial trigger'));
    });

    test('DefensiveScriptsVault dynamically extracts categories including custom additions', () {
      const customScript = DefensiveScript(
        id: 'cust_01',
        category: 'Toxic Gossip',
        scenario: 'Colleague talks behind others',
        hostileTrigger: 'Did you hear what happened?',
        executiveScript: 'I focus strictly on engineering output rather than hallway rumors.',
        tacticalRationale: 'Neutralizes drama immediately.',
        toneGuidance: 'Flat, uninterested.',
        isCustom: true,
      );

      final customList = [...DefensiveScriptsVault.scripts, customScript];
      final categories = DefensiveScriptsVault.getCategories(customList);

      expect(categories, contains('Toxic Gossip'));
      expect(categories.first, equals('All'));

      final filtered = DefensiveScriptsVault.getByCategory('Toxic Gossip', customList);
      expect(filtered.length, equals(1));
      expect(filtered.first.id, equals('cust_01'));
    });

    test('DefensiveScript supports bilingual getters for English and Hindi', () {
      final fam01 = DefensiveScriptsVault.scripts.firstWhere((s) => s.id == 'fam_01');

      // In Hindi mode, returns native Hindi script
      expect(fam01.getLocalizedHostileTrigger(true), contains('सुनते ही नहीं'));
      expect(fam01.getLocalizedExecutiveScript(true), contains('सोचने का समय'));
      expect(fam01.getLocalizedTacticalRationale(true), contains('भावनात्मक बहस'));
      expect(fam01.getLocalizedToneGuidance(true), contains('सम्मानजनक'));

      // In English mode, returns calibrated English translation
      expect(fam01.getLocalizedHostileTrigger(false), contains('never listen'));
      expect(fam01.getLocalizedExecutiveScript(false), contains('give me some time to think'));
      expect(fam01.getLocalizedTacticalRationale(false), contains('emotional escalation'));
      expect(fam01.getLocalizedToneGuidance(false), contains('Respectful yet firm'));
    });
  });
}
