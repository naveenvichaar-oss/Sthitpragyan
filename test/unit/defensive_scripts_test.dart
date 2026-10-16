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
  });
}
