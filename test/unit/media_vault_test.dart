import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/features/journal/data/models/media_record_log.dart';

void main() {
  group('MediaRecordLog Model & Persistence Tests', () {
    test('Correctly identifies audio vs video media types', () {
      final audioLog = MediaRecordLog(
        id: 'audio_1',
        filePath: '/data/user/0/app/audio_memos/memo_123.m4a',
        displayName: 'Board Meeting Prep',
        mediaType: 'audio',
        createdAt: DateTime(2026, 10, 17, 10, 30),
        durationSeconds: 45,
        originalFileName: 'memo_123.m4a',
      );

      expect(audioLog.isAudio, isTrue);
      expect(audioLog.isVideo, isFalse);
      expect(audioLog.fileExtension, equals('m4a'));
      expect(audioLog.isHidden, isFalse);

      final videoLog = MediaRecordLog(
        id: 'video_1',
        filePath: '/data/user/0/app/video_reflections/composure_456.mp4',
        displayName: 'Evening Composure Drill',
        mediaType: 'video',
        createdAt: DateTime(2026, 10, 17, 21, 0),
        durationSeconds: 60,
        originalFileName: 'composure_456.mp4',
        isHidden: true,
      );

      expect(videoLog.isAudio, isFalse);
      expect(videoLog.isVideo, isTrue);
      expect(videoLog.fileExtension, equals('mp4'));
      expect(videoLog.isHidden, isTrue);
    });

    test('Serializes toMap and deserializes fromMap bidirectionally', () {
      final original = MediaRecordLog(
        id: 'rec_999',
        filePath: '/storage/emulated/0/app/.hidden_vault/.sec_rec_999.m4a',
        displayName: 'Confidential Disciplinary Audit',
        mediaType: 'audio',
        createdAt: DateTime(2026, 10, 17, 14, 15),
        durationSeconds: 120,
        isHidden: true,
        originalFileName: 'disciplinary_notes.m4a',
        parentJournalDateKey: '2026-10-17',
        fileSizeBytes: 2048576,
      );

      final map = original.toMap();
      expect(map['id'], equals('rec_999'));
      expect(map['displayName'], equals('Confidential Disciplinary Audit'));
      expect(map['mediaType'], equals('audio'));
      expect(map['isHidden'], isTrue);
      expect(map['parentJournalDateKey'], equals('2026-10-17'));
      expect(map['fileSizeBytes'], equals(2048576));

      final deserialized = MediaRecordLog.fromMap(map);
      expect(deserialized.id, equals(original.id));
      expect(deserialized.filePath, equals(original.filePath));
      expect(deserialized.displayName, equals(original.displayName));
      expect(deserialized.mediaType, equals(original.mediaType));
      expect(deserialized.durationSeconds, equals(original.durationSeconds));
      expect(deserialized.isHidden, equals(original.isHidden));
      expect(deserialized.originalFileName, equals(original.originalFileName));
      expect(deserialized.parentJournalDateKey, equals(original.parentJournalDateKey));
      expect(deserialized.fileSizeBytes, equals(original.fileSizeBytes));
    });

    test('copyWith updates specified fields while preserving unedited metadata', () {
      final base = MediaRecordLog(
        id: 'rec_base',
        filePath: '/data/user/0/app/audio_memos/voice.m4a',
        displayName: 'Voice Memo #1',
        mediaType: 'audio',
        createdAt: DateTime(2026, 10, 17, 8, 0),
        originalFileName: 'voice.m4a',
      );

      final renamed = base.copyWith(
        displayName: 'Project Kickoff Remarks',
        filePath: '/data/user/0/app/audio_memos/Project_Kickoff.m4a',
      );

      expect(renamed.id, equals('rec_base'));
      expect(renamed.displayName, equals('Project Kickoff Remarks'));
      expect(renamed.filePath, equals('/data/user/0/app/audio_memos/Project_Kickoff.m4a'));
      expect(renamed.mediaType, equals('audio'));
      expect(renamed.createdAt, equals(base.createdAt));
      expect(renamed.isHidden, isFalse);

      final hidden = renamed.copyWith(
        isHidden: true,
        filePath: '/data/user/0/app/.hidden_vault/.sec_rec_base.m4a',
      );

      expect(hidden.isHidden, isTrue);
      expect(hidden.filePath, contains('.hidden_vault'));
    });

    test('MediaRecordLogAdapter registers with typeId 3', () {
      final adapter = MediaRecordLogAdapter();
      expect(adapter.typeId, equals(3));
    });

    test('Media filtering correctly isolates hidden files from default views', () {
      final records = [
        MediaRecordLog(
          id: '1',
          filePath: '/path/1.m4a',
          displayName: 'Daily Memo',
          mediaType: 'audio',
          createdAt: DateTime.now(),
          originalFileName: '1.m4a',
          isHidden: false,
        ),
        MediaRecordLog(
          id: '2',
          filePath: '/path/2.m4a',
          displayName: 'Confidential Audit',
          mediaType: 'audio',
          createdAt: DateTime.now(),
          originalFileName: '2.m4a',
          isHidden: true,
        ),
        MediaRecordLog(
          id: '3',
          filePath: '/path/3.mp4',
          displayName: 'Front Composure',
          mediaType: 'video',
          createdAt: DateTime.now(),
          originalFileName: '3.mp4',
          isHidden: false,
        ),
      ];

      final defaultPublicList = records.where((r) => !r.isHidden).toList();
      expect(defaultPublicList.length, equals(2));
      expect(defaultPublicList.any((r) => r.id == '2'), isFalse);

      final stealthList = records.where((r) => r.isHidden).toList();
      expect(stealthList.length, equals(1));
      expect(stealthList.first.id, equals('2'));
      expect(stealthList.first.displayName, equals('Confidential Audit'));
    });
  });
}
