import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/features/recovery/data/models/incident_slip_up_log.dart';
import 'package:sthitaprajna/features/recovery/presentation/widgets/damage_control_card.dart';

void main() {
  group('Post-Incident Recovery Tests', () {
    test('IncidentSlipUpLog creates and preserves all fields', () {
      final now = DateTime.now();
      final log = IncidentSlipUpLog(
        id: 'slip_1001',
        timestamp: now,
        trigger: 'Toxic Boss',
        mistakeType: 'Gave unnecessary explanation',
        physicalState: 'Shallow breathing',
        archetype: 'The Stoic (स्थितप्रज्ञ)',
        idealResponse:
            'Detached, zero emotional reaction, sticks to objective reality.',
        revisedScript: 'भाषा या एंगल में क्या विशिष्ट फैक्चुअल बदलाव चाहिए?',
        damageControlScriptUsed:
            'Regarding our earlier exchange: let\'s calibrate in writing.',
        boxBreathingCompleted: true,
      );

      expect(log.id, equals('slip_1001'));
      expect(log.trigger, equals('Toxic Boss'));
      expect(log.mistakeType, equals('Gave unnecessary explanation'));
      expect(log.physicalState, equals('Shallow breathing'));
      expect(log.archetype, equals('The Stoic (स्थितप्रज्ञ)'));
      expect(log.boxBreathingCompleted, isTrue);
    });

    test(
      'IncidentSlipUpLog serialization toMap and fromMap works seamlessly',
      () {
        final now = DateTime.now();
        final original = IncidentSlipUpLog(
          id: 'slip_2002',
          timestamp: now,
          trigger: 'Unrealistic Deadline',
          mistakeType: 'Agreed impulsively',
          physicalState: 'Jaw clenched',
          archetype: 'The Strategist (रणनीतिकार)',
          idealResponse: 'Puts the burden of proof back on the agitator.',
          revisedScript: 'High quality execution requires 6 business hours.',
          boxBreathingCompleted: false,
        );

        final map = original.toMap();
        final restored = IncidentSlipUpLog.fromMap(map);

        expect(restored.id, equals(original.id));
        expect(restored.trigger, equals(original.trigger));
        expect(restored.mistakeType, equals(original.mistakeType));
        expect(restored.physicalState, equals(original.physicalState));
        expect(restored.archetype, equals(original.archetype));
        expect(restored.idealResponse, equals(original.idealResponse));
        expect(restored.revisedScript, equals(original.revisedScript));
        expect(restored.boxBreathingCompleted, isFalse);
      },
    );

    test(
      'IncidentSlipUpLog copyWith enables completing box breathing drill',
      () {
        final log = IncidentSlipUpLog(
          id: 'slip_3003',
          timestamp: DateTime.now(),
          trigger: 'Passive Aggression',
          mistakeType: 'Defended defensively',
          physicalState: 'Tense posture',
          archetype: 'The Executive (प्रशासक)',
          idealResponse: 'Demands written clarity.',
          revisedScript: 'Please outline the deliverables in writing.',
          boxBreathingCompleted: false,
        );

        final updated = log.copyWith(boxBreathingCompleted: true);
        expect(updated.boxBreathingCompleted, isTrue);
        expect(updated.trigger, equals(log.trigger));
      },
    );

    test('Default DamageControlScripts are vetted and complete', () {
      const scripts = DamageControlCard.defaultScripts;
      expect(scripts.length, greaterThanOrEqualTo(4));

      for (final s in scripts) {
        expect(s.id.isNotEmpty, isTrue);
        expect(s.title.isNotEmpty, isTrue);
        expect(s.scenario.isNotEmpty, isTrue);
        expect(s.verbatimScript.isNotEmpty, isTrue);
        expect(s.tacticalNote.isNotEmpty, isTrue);
      }
    });
  });
}
