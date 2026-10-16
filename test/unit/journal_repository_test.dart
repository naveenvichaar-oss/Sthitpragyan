import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/features/journal/data/models/journal_models.dart';

void main() {
  group('DailyJournalEntry Schema & Model Tests', () {
    test('Calculates composite equanimity score correctly', () {
      final perfect = DailyJournalEntry(
        id: '1',
        entryDate: '2026-10-17',
        createdAt: DateTime.now(),
        reactionControlScore: 5, // 60%
        boundaryMaintained: true, // 40%
        coreOutputSummary:
            'कॉर्पोरेट टैक्स पर 800 शब्दों का एक्सक्लूसिव विश्लेषण',
      );
      expect(perfect.compositeScore, equals(100));

      final mid = DailyJournalEntry(
        id: '2',
        entryDate: '2026-10-17',
        createdAt: DateTime.now(),
        reactionControlScore: 3, // (3/5)*60 = 36%
        boundaryMaintained: false, // 0%
        coreOutputSummary: 'Average day',
      );
      expect(mid.compositeScore, equals(36));

      final zero = DailyJournalEntry(
        id: '3',
        entryDate: '2026-10-17',
        createdAt: DateTime.now(),
        reactionControlScore: 1, // (1/5)*60 = 12%
        boundaryMaintained: false, // 0%
        coreOutputSummary: 'Rough day',
      );
      expect(zero.compositeScore, equals(12));
    });

    test('Derives qualitative Hindi reaction labels properly', () {
      final stoic = DailyJournalEntry(
        id: '1',
        entryDate: '2026-10-17',
        createdAt: DateTime.now(),
        reactionControlScore: 5,
        boundaryMaintained: true,
        coreOutputSummary: 'Composed',
      );
      expect(stoic.reactionLabel, contains('स्थितप्रज्ञ'));

      final poised = DailyJournalEntry(
        id: '2',
        entryDate: '2026-10-17',
        createdAt: DateTime.now(),
        reactionControlScore: 4,
        boundaryMaintained: true,
        coreOutputSummary: 'Composed',
      );
      expect(poised.reactionLabel, contains('पूर्ण नियंत्रण'));

      final lost = DailyJournalEntry(
        id: '3',
        entryDate: '2026-10-17',
        createdAt: DateTime.now(),
        reactionControlScore: 1,
        boundaryMaintained: false,
        coreOutputSummary: 'Hijacked',
      );
      expect(lost.reactionLabel, contains('भड़का'));
    });

    test('Derives boundary check labels properly', () {
      final maintained = DailyJournalEntry(
        id: '1',
        entryDate: '2026-10-17',
        createdAt: DateTime.now(),
        reactionControlScore: 4,
        boundaryMaintained: true,
        coreOutputSummary: 'Firm boundaries',
      );
      expect(maintained.boundaryLabel, contains('मर्यादा अक्षुण्ण'));

      final breached = DailyJournalEntry(
        id: '2',
        entryDate: '2026-10-17',
        createdAt: DateTime.now(),
        reactionControlScore: 4,
        boundaryMaintained: false,
        coreOutputSummary: 'Overworked',
      );
      expect(breached.boundaryLabel, contains('सीमा खंडित'));
    });

    test('Map serialization roundtrip is loss-free for DailyJournalEntry', () {
      final original = DailyJournalEntry(
        id: 'test_roundtrip',
        entryDate: '2026-10-17',
        createdAt: DateTime(2026, 10, 17, 21, 30),
        reactionControlScore: 4,
        boundaryMaintained: true,
        coreOutputSummary:
            'कॉर्पोरेट टैक्स पर 800 शब्दों का एक्सक्लूसिव विश्लेषण',
        provocationHandled: 'मीटिंग में 4 सेकंड पॉज देकर बात संभाली',
        audioMemoPath: '/data/user/0/audio_memos/memo_123.m4a',
        videoReflectionPath: '/data/user/0/video_reflections/video_123.mp4',
      );

      final map = original.toMap();
      final restored = DailyJournalEntry.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.entryDate, equals(original.entryDate));
      expect(
        restored.reactionControlScore,
        equals(original.reactionControlScore),
      );
      expect(restored.boundaryMaintained, equals(original.boundaryMaintained));
      expect(restored.coreOutputSummary, equals(original.coreOutputSummary));
      expect(restored.provocationHandled, equals(original.provocationHandled));
      expect(restored.audioMemoPath, equals(original.audioMemoPath));
      expect(restored.videoReflectionPath, equals(original.videoReflectionPath));
    });

    test('SosIncidentLog serialization roundtrip preserves telemetry', () {
      final incident = SosIncidentLog(
        id: 'sos_123',
        timestamp: DateTime(2026, 10, 17, 14, 15),
        threatType: 'Unjust Accusation',
        scriptSelected: 'भाषा या एंगल में क्या विशिष्ट फैक्चुअल बदलाव चाहिए?',
        lockCompleted: true,
        outcomeRating: 5,
      );

      final map = incident.toMap();
      final restored = SosIncidentLog.fromMap(map);

      expect(restored.id, equals(incident.id));
      expect(restored.threatType, equals(incident.threatType));
      expect(restored.scriptSelected, equals(incident.scriptSelected));
      expect(restored.lockCompleted, equals(true));
      expect(restored.outcomeRating, equals(5));
    });
  });
}
