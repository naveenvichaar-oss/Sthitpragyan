import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/features/dashboard/data/daily_rules_vault.dart';
import 'package:sthitaprajna/features/dashboard/data/models/daily_rule.dart';

void main() {
  group('DailyRulesVault Tests', () {
    test('DailyRulesVault contains curated Stoic executive rules', () {
      expect(DailyRulesVault.rules.isNotEmpty, isTrue);
      expect(DailyRulesVault.rules.length, greaterThanOrEqualTo(10));
    });

    test('getTodayRule returns valid rule with non-empty fields', () {
      final rule = DailyRulesVault.getTodayRule();
      expect(rule.id, greaterThan(0));
      expect(rule.title.isNotEmpty, isTrue);
      expect(rule.aphorism.isNotEmpty, isTrue);
      expect(rule.source.isNotEmpty, isTrue);
      expect(rule.tacticalAction.isNotEmpty, isTrue);
      expect(rule.corporateContext.isNotEmpty, isTrue);
    });

    test('getNextRule cycles deterministically through rules', () {
      final first = DailyRulesVault.rules[0];
      final next = DailyRulesVault.getNextRule(0);
      expect(next.id, equals(2));

      final last = DailyRulesVault.rules.last;
      final looped = DailyRulesVault.getNextRule(
        DailyRulesVault.rules.length - 1,
      );
      expect(looped.id, equals(first.id));
    });

    test('DailyRule serialization works seamlessly', () {
      const original = DailyRule(
        id: 99,
        title: 'TEST RULE',
        aphorism: 'Test Aphorism',
        source: 'Marcus Aurelius',
        tacticalAction: 'Wait 4 seconds',
        corporateContext: 'Hostile Q&A',
      );

      final map = original.toMap();
      final restored = DailyRule.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.title, equals(original.title));
      expect(restored.aphorism, equals(original.aphorism));
      expect(restored.source, equals(original.source));
      expect(restored.tacticalAction, equals(original.tacticalAction));
      expect(restored.corporateContext, equals(original.corporateContext));
    });
  });
}
