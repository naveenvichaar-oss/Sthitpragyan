import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/features/cognition_vault/data/cognition_data_source.dart';

void main() {
  group('Cognition Vault Tests', () {
    test('DataSource provides fallacies, mental models, and rules of engagement', () {
      final fallacies = CognitionDataSource.getFallacies();
      final models = CognitionDataSource.getMentalModels();
      final rules = CognitionDataSource.getRulesOfEngagement();

      expect(fallacies.isNotEmpty, isTrue);
      expect(models.isNotEmpty, isTrue);
      expect(rules.isNotEmpty, isTrue);
      expect(fallacies.length, greaterThanOrEqualTo(6));
      expect(models.length, greaterThanOrEqualTo(6));
      expect(rules.length, greaterThanOrEqualTo(3));
    });

    test('All items have complete fields for micro-card rendering', () {
      for (final item in CognitionDataSource.items) {
        expect(item.id.isNotEmpty, isTrue);
        expect(item.title.isNotEmpty, isTrue);
        expect(item.latinName.isNotEmpty, isTrue);
        expect(item.definition.isNotEmpty, isTrue);
        expect(item.corporateManifestation.isNotEmpty, isTrue);
        expect(item.antidoteProtocol.isNotEmpty, isTrue);
        expect(item.quickMaxim.isNotEmpty, isTrue);
        expect(item.tags.isNotEmpty, isTrue);
      }
    });

    test(
      'Real-time search filters correctly by title, latin name, or tags',
      () {
        final controlSearch = CognitionDataSource.search('Control');
        expect(controlSearch.any((i) => i.title.contains('Control')), isTrue);

        final adHominemSearch = CognitionDataSource.search('Ad Hominem');
        expect(adHominemSearch.length, equals(1));
        expect(adHominemSearch.first.title, contains('Ad Hominem'));

        final emptySearch = CognitionDataSource.search('');
        expect(emptySearch.length, equals(CognitionDataSource.items.length));
      },
    );
  });
}
