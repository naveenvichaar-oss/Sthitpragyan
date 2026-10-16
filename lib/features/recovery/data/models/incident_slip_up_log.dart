/// IncidentSlipUpLog represents a post-incident recovery entry when an executive
/// experiences an emotional slip-up, reactive defense, or lost composure.
/// Fully offline, zero telemetry, stored locally in Hive.
class IncidentSlipUpLog {
  final String id;
  final DateTime timestamp;
  final String trigger;
  final String mistakeType;
  final String physicalState;
  final String archetype;
  final String idealResponse;
  final String revisedScript;
  final String? damageControlScriptUsed;
  final bool boxBreathingCompleted;

  const IncidentSlipUpLog({
    required this.id,
    required this.timestamp,
    required this.trigger,
    required this.mistakeType,
    required this.physicalState,
    required this.archetype,
    required this.idealResponse,
    required this.revisedScript,
    this.damageControlScriptUsed,
    this.boxBreathingCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'trigger': trigger,
      'mistakeType': mistakeType,
      'physicalState': physicalState,
      'archetype': archetype,
      'idealResponse': idealResponse,
      'revisedScript': revisedScript,
      'damageControlScriptUsed': damageControlScriptUsed,
      'boxBreathingCompleted': boxBreathingCompleted,
    };
  }

  factory IncidentSlipUpLog.fromMap(Map<String, dynamic> map) {
    return IncidentSlipUpLog(
      id:
          map['id'] as String? ??
          'slip_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      trigger: map['trigger'] as String? ?? 'Unspecified Trigger',
      mistakeType: map['mistakeType'] as String? ?? 'Lost Composure',
      physicalState: map['physicalState'] as String? ?? 'Tense Posture',
      archetype: map['archetype'] as String? ?? 'The Stoic (स्थितप्रज्ञ)',
      idealResponse: map['idealResponse'] as String? ?? '',
      revisedScript: map['revisedScript'] as String? ?? '',
      damageControlScriptUsed: map['damageControlScriptUsed'] as String?,
      boxBreathingCompleted: map['boxBreathingCompleted'] as bool? ?? false,
    );
  }

  IncidentSlipUpLog copyWith({
    String? id,
    DateTime? timestamp,
    String? trigger,
    String? mistakeType,
    String? physicalState,
    String? archetype,
    String? idealResponse,
    String? revisedScript,
    String? damageControlScriptUsed,
    bool? boxBreathingCompleted,
  }) {
    return IncidentSlipUpLog(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      trigger: trigger ?? this.trigger,
      mistakeType: mistakeType ?? this.mistakeType,
      physicalState: physicalState ?? this.physicalState,
      archetype: archetype ?? this.archetype,
      idealResponse: idealResponse ?? this.idealResponse,
      revisedScript: revisedScript ?? this.revisedScript,
      damageControlScriptUsed:
          damageControlScriptUsed ?? this.damageControlScriptUsed,
      boxBreathingCompleted:
          boxBreathingCompleted ?? this.boxBreathingCompleted,
    );
  }
}
