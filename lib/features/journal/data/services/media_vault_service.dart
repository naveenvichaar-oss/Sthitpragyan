import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/hive_storage.dart';
import '../models/journal_models.dart';
import '../models/media_record_log.dart';

/// MediaVaultService coordinates device storage operations, file renaming,
/// and stealth isolation with .nomedia protection for audio and video media.
class MediaVaultService {
  static final MediaVaultService _instance = MediaVaultService._internal();
  factory MediaVaultService() => _instance;
  MediaVaultService._internal();

  final HiveStorage _storage = HiveStorage();
  bool _initialized = false;

  /// Initializes the stealth hidden vault directory and .nomedia flag file.
  Future<void> init() async {
    if (_initialized) return;

    try {
      if (!kIsWeb) {
        final docsDir = await getApplicationDocumentsDirectory();
        final hiddenVaultDir = Directory('${docsDir.path}/.hidden_vault');
        if (!await hiddenVaultDir.exists()) {
          await hiddenVaultDir.create(recursive: true);
        }

        final noMediaFile = File('${hiddenVaultDir.path}/.nomedia');
        if (!await noMediaFile.exists()) {
          await noMediaFile.writeAsString('');
        }
      }

      // Automatically sync any media attached to DailyJournalEntry logs into MediaVault
      _syncJournalMediaEntries();

      _initialized = true;
    } catch (e) {
      debugPrint('[MediaVaultService] init error: $e');
    }
  }

  void _syncJournalMediaEntries() {
    try {
      final entries = _storage.getAllDailyJournalEntries();
      for (final entry in entries) {
        if (entry.audioMemoPath != null && entry.audioMemoPath!.isNotEmpty) {
          final existing = _findRecordByPath(entry.audioMemoPath!);
          if (existing == null) {
            final file = File(entry.audioMemoPath!);
            final name = 'Audio Memo • ${DateFormat('dd MMM yyyy').format(entry.createdAt)}';
            final id = 'audio_${entry.entryDate}';
            final record = MediaRecordLog(
              id: id,
              filePath: entry.audioMemoPath!,
              displayName: name,
              mediaType: 'audio',
              createdAt: entry.createdAt,
              originalFileName: file.uri.pathSegments.isNotEmpty ? file.uri.pathSegments.last : 'memo.m4a',
              parentJournalDateKey: entry.entryDate,
              fileSizeBytes: file.existsSync() ? file.lengthSync() : null,
            );
            _storage.saveMediaRecord(record);
          }
        }

        if (entry.videoReflectionPath != null && entry.videoReflectionPath!.isNotEmpty) {
          final existing = _findRecordByPath(entry.videoReflectionPath!);
          if (existing == null) {
            final file = File(entry.videoReflectionPath!);
            final name = 'Composure Review • ${DateFormat('dd MMM yyyy').format(entry.createdAt)}';
            final id = 'video_${entry.entryDate}';
            final record = MediaRecordLog(
              id: id,
              filePath: entry.videoReflectionPath!,
              displayName: name,
              mediaType: 'video',
              createdAt: entry.createdAt,
              originalFileName: file.uri.pathSegments.isNotEmpty ? file.uri.pathSegments.last : 'composure.mp4',
              parentJournalDateKey: entry.entryDate,
              fileSizeBytes: file.existsSync() ? file.lengthSync() : null,
            );
            _storage.saveMediaRecord(record);
          }
        }
      }
    } catch (e) {
      debugPrint('[MediaVaultService] Sync error: $e');
    }
  }

  MediaRecordLog? _findRecordByPath(String path) {
    for (final rec in _storage.getAllMediaRecords()) {
      if (rec.filePath == path) return rec;
    }
    return null;
  }

  /// Returns media records. If [includeHidden] is false, stealth records are completely omitted.
  List<MediaRecordLog> getAllMedia({bool includeHidden = false}) {
    final all = _storage.getAllMediaRecords();
    if (includeHidden) {
      return all;
    }
    return all.where((m) => !m.isHidden).toList();
  }

  /// Returns only the items currently locked in the Stealth Vault.
  List<MediaRecordLog> getHiddenMedia() {
    return _storage.getAllMediaRecords().where((m) => m.isHidden).toList();
  }

  /// Registers a newly recorded media file.
  Future<MediaRecordLog> registerMedia({
    required String filePath,
    required String mediaType,
    int durationSeconds = 0,
    String? parentJournalDateKey,
    String? customDisplayName,
  }) async {
    final file = File(filePath);
    final now = DateTime.now();
    final defaultName = mediaType == 'video'
        ? 'Composure Review • ${DateFormat('dd MMM yyyy, HH:mm').format(now)}'
        : 'Audio Memo • ${DateFormat('dd MMM yyyy, HH:mm').format(now)}';

    final id = 'media_${now.millisecondsSinceEpoch}';
    final fileName = file.uri.pathSegments.isNotEmpty ? file.uri.pathSegments.last : 'media_file';

    int? size;
    try {
      if (!kIsWeb && await file.exists()) {
        size = await file.length();
      }
    } catch (_) {}

    final record = MediaRecordLog(
      id: id,
      filePath: filePath,
      displayName: (customDisplayName != null && customDisplayName.trim().isNotEmpty)
          ? customDisplayName.trim()
          : defaultName,
      mediaType: mediaType,
      createdAt: now,
      durationSeconds: durationSeconds,
      isHidden: false,
      originalFileName: fileName,
      parentJournalDateKey: parentJournalDateKey,
      fileSizeBytes: size,
    );

    await _storage.saveMediaRecord(record);
    return record;
  }

  /// Renames a media file on local storage and updates Hive metadata.
  Future<MediaRecordLog> renameMedia({
    required String id,
    required String newDisplayName,
  }) async {
    final record = _storage.getMediaRecord(id);
    if (record == null) {
      throw Exception('Media record not found with id: $id');
    }

    final trimmed = newDisplayName.trim();
    if (trimmed.isEmpty) {
      throw Exception('Display name cannot be empty');
    }

    String updatedFilePath = record.filePath;

    if (!kIsWeb) {
      try {
        final currentFile = File(record.filePath);
        if (await currentFile.exists()) {
          final parentDir = currentFile.parent;
          final extension = currentFile.path.contains('.')
              ? currentFile.path.split('.').last
              : (record.isAudio ? 'm4a' : 'mp4');

          final safeName = trimmed
              .replaceAll(RegExp(r'[^\w\s\-]'), '')
              .trim()
              .replaceAll(RegExp(r'\s+'), '_');

          final newFileName = '${safeName}_$id.$extension';
          final newPath = '${parentDir.path}/$newFileName';

          final renamedFile = await currentFile.rename(newPath);
          updatedFilePath = renamedFile.path;
        }
      } catch (e) {
        debugPrint('[MediaVaultService] Physical file rename failed, continuing with metadata update: $e');
      }
    }

    final updatedRecord = record.copyWith(
      displayName: trimmed,
      filePath: updatedFilePath,
    );

    await _storage.saveMediaRecord(updatedRecord);

    // Sync path with linked DailyJournalEntry if applicable
    if (record.parentJournalDateKey != null) {
      final journalEntry = _storage.getDailyJournalEntry(record.parentJournalDateKey!);
      if (journalEntry != null) {
        final updatedJournal = DailyJournalEntry(
          id: journalEntry.id,
          entryDate: journalEntry.entryDate,
          createdAt: journalEntry.createdAt,
          reactionControlScore: journalEntry.reactionControlScore,
          boundaryMaintained: journalEntry.boundaryMaintained,
          coreOutputSummary: journalEntry.coreOutputSummary,
          provocationHandled: journalEntry.provocationHandled,
          audioMemoPath: record.isAudio ? updatedFilePath : journalEntry.audioMemoPath,
          videoReflectionPath: record.isVideo ? updatedFilePath : journalEntry.videoReflectionPath,
        );
        await _storage.saveDailyJournalEntry(updatedJournal);
      }
    }

    return updatedRecord;
  }

  /// Hides a file by moving it into the isolated .hidden_vault folder with a .nomedia lock.
  Future<MediaRecordLog> hideMedia(String id) async {
    final record = _storage.getMediaRecord(id);
    if (record == null) {
      throw Exception('Media record not found with id: $id');
    }

    if (record.isHidden) return record;

    String hiddenFilePath = record.filePath;

    if (!kIsWeb) {
      try {
        final currentFile = File(record.filePath);
        final docsDir = await getApplicationDocumentsDirectory();
        final hiddenVaultDir = Directory('${docsDir.path}/.hidden_vault');
        if (!await hiddenVaultDir.exists()) {
          await hiddenVaultDir.create(recursive: true);
        }

        final noMediaFile = File('${hiddenVaultDir.path}/.nomedia');
        if (!await noMediaFile.exists()) {
          await noMediaFile.writeAsString('');
        }

        if (await currentFile.exists()) {
          final extension = currentFile.path.contains('.')
              ? currentFile.path.split('.').last
              : (record.isAudio ? 'm4a' : 'mp4');

          final stealthFileName = '.sec_${id}_${DateTime.now().millisecondsSinceEpoch}.$extension';
          final targetDest = '${hiddenVaultDir.path}/$stealthFileName';

          final moved = await currentFile.rename(targetDest);
          hiddenFilePath = moved.path;
        }
      } catch (e) {
        debugPrint('[MediaVaultService] Physical stealth move error: $e');
      }
    }

    final updated = record.copyWith(
      isHidden: true,
      filePath: hiddenFilePath,
    );

    await _storage.saveMediaRecord(updated);

    // Sync path with DailyJournalEntry
    if (record.parentJournalDateKey != null) {
      final journalEntry = _storage.getDailyJournalEntry(record.parentJournalDateKey!);
      if (journalEntry != null) {
        final updatedJournal = DailyJournalEntry(
          id: journalEntry.id,
          entryDate: journalEntry.entryDate,
          createdAt: journalEntry.createdAt,
          reactionControlScore: journalEntry.reactionControlScore,
          boundaryMaintained: journalEntry.boundaryMaintained,
          coreOutputSummary: journalEntry.coreOutputSummary,
          provocationHandled: journalEntry.provocationHandled,
          audioMemoPath: record.isAudio ? hiddenFilePath : journalEntry.audioMemoPath,
          videoReflectionPath: record.isVideo ? hiddenFilePath : journalEntry.videoReflectionPath,
        );
        await _storage.saveDailyJournalEntry(updatedJournal);
      }
    }

    return updated;
  }

  /// Unhides a file by moving it back to the public media folders (audio_memos / video_reflections).
  Future<MediaRecordLog> unhideMedia(String id) async {
    final record = _storage.getMediaRecord(id);
    if (record == null) {
      throw Exception('Media record not found with id: $id');
    }

    if (!record.isHidden) return record;

    String publicFilePath = record.filePath;

    if (!kIsWeb) {
      try {
        final currentFile = File(record.filePath);
        final docsDir = await getApplicationDocumentsDirectory();
        final folderName = record.isAudio ? 'audio_memos' : 'video_reflections';
        final destDir = Directory('${docsDir.path}/$folderName');
        if (!await destDir.exists()) {
          await destDir.create(recursive: true);
        }

        if (await currentFile.exists()) {
          final extension = currentFile.path.contains('.')
              ? currentFile.path.split('.').last
              : (record.isAudio ? 'm4a' : 'mp4');

          final publicFileName = '${record.isAudio ? "memo" : "composure"}_${DateTime.now().millisecondsSinceEpoch}.$extension';
          final targetDest = '${destDir.path}/$publicFileName';

          final moved = await currentFile.rename(targetDest);
          publicFilePath = moved.path;
        }
      } catch (e) {
        debugPrint('[MediaVaultService] Physical unhide move error: $e');
      }
    }

    final updated = record.copyWith(
      isHidden: false,
      filePath: publicFilePath,
    );

    await _storage.saveMediaRecord(updated);

    // Sync path with DailyJournalEntry
    if (record.parentJournalDateKey != null) {
      final journalEntry = _storage.getDailyJournalEntry(record.parentJournalDateKey!);
      if (journalEntry != null) {
        final updatedJournal = DailyJournalEntry(
          id: journalEntry.id,
          entryDate: journalEntry.entryDate,
          createdAt: journalEntry.createdAt,
          reactionControlScore: journalEntry.reactionControlScore,
          boundaryMaintained: journalEntry.boundaryMaintained,
          coreOutputSummary: journalEntry.coreOutputSummary,
          provocationHandled: journalEntry.provocationHandled,
          audioMemoPath: record.isAudio ? publicFilePath : journalEntry.audioMemoPath,
          videoReflectionPath: record.isVideo ? publicFilePath : journalEntry.videoReflectionPath,
        );
        await _storage.saveDailyJournalEntry(updatedJournal);
      }
    }

    return updated;
  }

  /// Deletes a media file physically and cleans up its Hive records.
  Future<void> deleteMedia(String id) async {
    final record = _storage.getMediaRecord(id);
    if (record == null) return;

    if (!kIsWeb) {
      try {
        final file = File(record.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('[MediaVaultService] Error deleting physical file: $e');
      }
    }

    await _storage.deleteMediaRecord(id);

    // Clear link in DailyJournalEntry if attached
    if (record.parentJournalDateKey != null) {
      final journalEntry = _storage.getDailyJournalEntry(record.parentJournalDateKey!);
      if (journalEntry != null) {
        final updatedJournal = DailyJournalEntry(
          id: journalEntry.id,
          entryDate: journalEntry.entryDate,
          createdAt: journalEntry.createdAt,
          reactionControlScore: journalEntry.reactionControlScore,
          boundaryMaintained: journalEntry.boundaryMaintained,
          coreOutputSummary: journalEntry.coreOutputSummary,
          provocationHandled: journalEntry.provocationHandled,
          audioMemoPath: record.isAudio ? null : journalEntry.audioMemoPath,
          videoReflectionPath: record.isVideo ? null : journalEntry.videoReflectionPath,
        );
        await _storage.saveDailyJournalEntry(updatedJournal);
      }
    }
  }

  /// Stealth PIN validation (default: 0000)
  bool verifyStealthPin(String enteredPin) {
    final saved = _storage.getStealthPin();
    return enteredPin.trim() == saved.trim();
  }

  Future<void> updateStealthPin(String newPin) async {
    await _storage.setStealthPin(newPin.trim());
  }
}
