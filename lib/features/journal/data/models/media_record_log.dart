import 'package:hive/hive.dart';

/// MediaRecordLog models an offline audio memo or front-camera video composure review.
/// Supports custom display renaming, file-level isolation, and stealth hiding.
@HiveType(typeId: 3)
class MediaRecordLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String filePath; // Absolute path on device storage

  @HiveField(2)
  final String displayName; // User customizable display name

  @HiveField(3)
  final String mediaType; // 'audio' or 'video'

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final int durationSeconds;

  @HiveField(6)
  final bool isHidden; // True if isolated in stealth .hidden_vault with .nomedia

  @HiveField(7)
  final String originalFileName;

  @HiveField(8)
  final String? parentJournalDateKey; // Link to DailyJournalEntry YYYY-MM-DD

  @HiveField(9)
  final int? fileSizeBytes;

  MediaRecordLog({
    required this.id,
    required this.filePath,
    required this.displayName,
    required this.mediaType,
    required this.createdAt,
    this.durationSeconds = 0,
    this.isHidden = false,
    required this.originalFileName,
    this.parentJournalDateKey,
    this.fileSizeBytes,
  });

  bool get isAudio => mediaType.toLowerCase() == 'audio';
  bool get isVideo => mediaType.toLowerCase() == 'video';

  String get fileExtension {
    if (filePath.contains('.')) {
      return filePath.split('.').last.toLowerCase();
    }
    return isAudio ? 'm4a' : 'mp4';
  }

  MediaRecordLog copyWith({
    String? id,
    String? filePath,
    String? displayName,
    String? mediaType,
    DateTime? createdAt,
    int? durationSeconds,
    bool? isHidden,
    String? originalFileName,
    String? parentJournalDateKey,
    int? fileSizeBytes,
  }) {
    return MediaRecordLog(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      displayName: displayName ?? this.displayName,
      mediaType: mediaType ?? this.mediaType,
      createdAt: createdAt ?? this.createdAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isHidden: isHidden ?? this.isHidden,
      originalFileName: originalFileName ?? this.originalFileName,
      parentJournalDateKey: parentJournalDateKey ?? this.parentJournalDateKey,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'displayName': displayName,
      'mediaType': mediaType,
      'createdAt': createdAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'isHidden': isHidden,
      'originalFileName': originalFileName,
      'parentJournalDateKey': parentJournalDateKey,
      'fileSizeBytes': fileSizeBytes,
    };
  }

  factory MediaRecordLog.fromMap(Map<String, dynamic> map) {
    return MediaRecordLog(
      id: map['id'] as String? ?? '',
      filePath: map['filePath'] as String? ?? '',
      displayName: map['displayName'] as String? ?? map['originalFileName'] as String? ?? 'Media Recording',
      mediaType: map['mediaType'] as String? ?? 'audio',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      isHidden: map['isHidden'] as bool? ?? false,
      originalFileName: map['originalFileName'] as String? ?? '',
      parentJournalDateKey: map['parentJournalDateKey'] as String?,
      fileSizeBytes: (map['fileSizeBytes'] as num?)?.toInt(),
    );
  }
}

/// Hive TypeAdapter for MediaRecordLog (typeId: 3)
class MediaRecordLogAdapter extends TypeAdapter<MediaRecordLog> {
  @override
  final int typeId = 3;

  @override
  MediaRecordLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaRecordLog(
      id: fields[0] as String? ?? '',
      filePath: fields[1] as String? ?? '',
      displayName: fields[2] as String? ?? 'Media Recording',
      mediaType: fields[3] as String? ?? 'audio',
      createdAt: fields[4] as DateTime? ?? DateTime.now(),
      durationSeconds: fields[5] as int? ?? 0,
      isHidden: fields[6] as bool? ?? false,
      originalFileName: fields[7] as String? ?? '',
      parentJournalDateKey: fields[8] as String?,
      fileSizeBytes: fields[9] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, MediaRecordLog obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.mediaType)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.durationSeconds)
      ..writeByte(6)
      ..write(obj.isHidden)
      ..writeByte(7)
      ..write(obj.originalFileName)
      ..writeByte(8)
      ..write(obj.parentJournalDateKey)
      ..writeByte(9)
      ..write(obj.fileSizeBytes);
  }
}
