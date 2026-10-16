import 'package:hive/hive.dart';

/// DailyJournalEntry implements the 3-Index Evening Debrief schema (Hive typeId: 1).
/// 100% offline, zero-leak, high-performance local persistence.
@HiveType(typeId: 1)
class DailyJournalEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String entryDate; // YYYY-MM-DD

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final int reactionControlScore; // 1 to 5 (1 = भड़का, 5 = स्थितप्रज्ञ)

  @HiveField(4)
  final bool boundaryMaintained; // true = मर्यादा बची रही (Yes), false = नहीं (No)

  @HiveField(5)
  final String coreOutputSummary; // Text description of the solid deliverable

  @HiveField(6)
  final String? provocationHandled; // Micro-reflection / strategic resolution

  DailyJournalEntry({
    required this.id,
    required this.entryDate,
    required this.createdAt,
    required this.reactionControlScore,
    required this.boundaryMaintained,
    required this.coreOutputSummary,
    this.provocationHandled,
  });

  /// Qualitative Hindi & English state label
  String get reactionLabel {
    switch (reactionControlScore) {
      case 1:
        return 'भड़का (Lost Control)';
      case 2:
        return 'तनाव में बोला (Under Strain)';
      case 3:
        return 'न्यूट्रल रहा (Neutral)';
      case 4:
        return 'पूर्ण नियंत्रण (High Poise)';
      case 5:
        return 'स्थितप्रज्ञ (Absolute Stoic)';
      default:
        return 'न्यूट्रल रहा (Neutral)';
    }
  }

  /// Boundary status label
  String get boundaryLabel {
    return boundaryMaintained
        ? 'मर्यादा अक्षुण्ण (Boundary Intact)'
        : 'सीमा खंडित (Boundary Compromised)';
  }

  /// Composite Equanimity Score (0% to 100%)
  int get compositeScore {
    // 60% weight on Reaction Control (1-5 scaled to 60) + 40% on Boundary Maintained (40 if true)
    final reactionComponent = (reactionControlScore / 5.0) * 60;
    final boundaryComponent = boundaryMaintained ? 40 : 0;
    return (reactionComponent + boundaryComponent).round().clamp(0, 100);
  }

  // Aliases for legacy UI compatibility
  String get dateKey => entryDate;
  DateTime get timestamp => createdAt;
  double get reactionControl =>
      reactionControlScore.toDouble() * 2.0; // scale 1-5 to 2-10
  double get boundaryRetained => boundaryMaintained ? 10.0 : 2.0;
  String get coreOutput => coreOutputSummary;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entryDate': entryDate,
      'createdAt': createdAt.toIso8601String(),
      'reactionControlScore': reactionControlScore,
      'boundaryMaintained': boundaryMaintained,
      'coreOutputSummary': coreOutputSummary,
      'provocationHandled': provocationHandled,
    };
  }

  factory DailyJournalEntry.fromMap(Map<String, dynamic> map) {
    return DailyJournalEntry(
      id: map['id'] as String? ?? '',
      entryDate: map['entryDate'] as String? ?? map['dateKey'] as String? ?? '',
      createdAt:
          DateTime.tryParse(
            map['createdAt'] as String? ?? map['timestamp'] as String? ?? '',
          ) ??
          DateTime.now(),
      reactionControlScore:
          (map['reactionControlScore'] as num?)?.toInt() ??
          (((map['reactionControl'] as num?)?.toDouble() ?? 6.0) / 2.0)
              .round()
              .clamp(1, 5),
      boundaryMaintained:
          map['boundaryMaintained'] as bool? ??
          (((map['boundaryRetained'] as num?)?.toDouble() ?? 5.0) >= 5.0),
      coreOutputSummary:
          map['coreOutputSummary'] as String? ??
          map['coreOutput'] as String? ??
          '',
      provocationHandled: map['provocationHandled'] as String?,
    );
  }
}

/// TypeAdapter for DailyJournalEntry (typeId: 1)
class DailyJournalEntryAdapter extends TypeAdapter<DailyJournalEntry> {
  @override
  final int typeId = 1;

  @override
  DailyJournalEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyJournalEntry(
      id: fields[0] as String? ?? '',
      entryDate: fields[1] as String? ?? '',
      createdAt: fields[2] as DateTime? ?? DateTime.now(),
      reactionControlScore: fields[3] as int? ?? 3,
      boundaryMaintained: fields[4] as bool? ?? true,
      coreOutputSummary: fields[5] as String? ?? '',
      provocationHandled: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyJournalEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.entryDate)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.reactionControlScore)
      ..writeByte(4)
      ..write(obj.boundaryMaintained)
      ..writeByte(5)
      ..write(obj.coreOutputSummary)
      ..writeByte(6)
      ..write(obj.provocationHandled);
  }
}

/// SosIncidentLog represents an incident captured by the SOS Shield (Hive typeId: 2).
@HiveType(typeId: 2)
class SosIncidentLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String threatType; // VagueCritique, Dominance, ImpossibleDeadline, Other

  @HiveField(3)
  final String? scriptSelected;

  @HiveField(4)
  final bool lockCompleted; // Did user wait out the full 3-second mandatory lock?

  @HiveField(5)
  final int? outcomeRating; // 1 to 5

  SosIncidentLog({
    required this.id,
    required this.timestamp,
    required this.threatType,
    this.scriptSelected,
    required this.lockCompleted,
    this.outcomeRating = 5,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'threatType': threatType,
      'scriptSelected': scriptSelected,
      'lockCompleted': lockCompleted,
      'outcomeRating': outcomeRating,
    };
  }

  factory SosIncidentLog.fromMap(Map<String, dynamic> map) {
    return SosIncidentLog(
      id: map['id'] as String? ?? '',
      timestamp:
          DateTime.tryParse(map['timestamp'] as String? ?? '') ??
          DateTime.now(),
      threatType:
          map['threatType'] as String? ?? map['category'] as String? ?? 'Other',
      scriptSelected:
          map['scriptSelected'] as String? ?? map['scriptText'] as String?,
      lockCompleted: map['lockCompleted'] as bool? ?? true,
      outcomeRating: (map['outcomeRating'] as num?)?.toInt() ?? 5,
    );
  }
}

/// TypeAdapter for SosIncidentLog (typeId: 2)
class SosIncidentLogAdapter extends TypeAdapter<SosIncidentLog> {
  @override
  final int typeId = 2;

  @override
  SosIncidentLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SosIncidentLog(
      id: fields[0] as String? ?? '',
      timestamp: fields[1] as DateTime? ?? DateTime.now(),
      threatType: fields[2] as String? ?? 'Other',
      scriptSelected: fields[3] as String?,
      lockCompleted: fields[4] as bool? ?? true,
      outcomeRating: fields[5] as int? ?? 5,
    );
  }

  @override
  void write(BinaryWriter writer, SosIncidentLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.threatType)
      ..writeByte(3)
      ..write(obj.scriptSelected)
      ..writeByte(4)
      ..write(obj.lockCompleted)
      ..writeByte(5)
      ..write(obj.outcomeRating);
  }
}

/// Type alias for seamless backward compatibility
typedef JournalEntry = DailyJournalEntry;
