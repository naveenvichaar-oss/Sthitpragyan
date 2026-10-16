import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/features/sos/data/defensive_scripts_vault.dart';

void main() {
  group('DefensiveScriptsVault Tests', () {
    test('Vault has all core categories', () {
      final categories = DefensiveScriptsVault.categories;
      expect(categories, contains('All'));
      expect(categories, contains('Interruption'));
      expect(categories, contains('Gaslighting'));
      expect(categories, contains('Blame Shifting'));
      expect(categories, contains('Passive Aggression'));
      expect(categories, contains('Scope Creep'));
      expect(categories, contains('Emotional Baiting'));
    });

    test('Scripts vault contains high quality entries with executive tone guidance', () {
      final all = DefensiveScriptsVault.scripts;
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

    test('Category filtering functions correctly', () {
      final gaslighting = DefensiveScriptsVault.getByCategory('Gaslighting');
      expect(gaslighting.isNotEmpty, isTrue);
      for (final item in gaslighting) {
        expect(item.category, equals('Gaslighting'));
      }

      final interruption = DefensiveScriptsVault.getByCategory('Interruption');
      expect(interruption.isNotEmpty, isTrue);
      for (final item in interruption) {
        expect(item.category, equals('Interruption'));
      }
    });
  });
}
