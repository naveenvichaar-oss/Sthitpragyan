/// JournalEntry represents the 60-second evening debrief.
/// Composed strictly of 3 indices:
/// 1. Reaction Control (0.0 - 10.0)
/// 2. Boundary Retained (0.0 - 10.0)
/// 3. Core Output (single-line concise takeaway)
class JournalEntry {
  final String id;
  final String dateKey; // yyyy-MM-dd
  final DateTime timestamp;
  final double reactionControl; // 0.0 - 10.0
  final double boundaryRetained; // 0.0 - 10.0
  final String coreOutput; // Single-line concise takeaway

  const JournalEntry({
    required this.id,
    required this.dateKey,
    required this.timestamp,
    required this.reactionControl,
    required this.boundaryRetained,
    required this.coreOutput,
  });

  /// Evaluates qualitative state based on Reaction Control
  String get reactionLabel {
    if (reactionControl >= 9.0) return 'Absolute Sthitaprajna';
    if (reactionControl >= 7.0) return 'High Executive Poise';
    if (reactionControl >= 5.0) return 'Controlled Grounding';
    if (reactionControl >= 3.0) return 'Internal Turbulence';
    return 'Amygdala Hijacked';
  }

  /// Evaluates qualitative state based on Boundary Retained
  String get boundaryLabel {
    if (boundaryRetained >= 9.0) return 'Impenetrable Fortress';
    if (boundaryRetained >= 7.0) return 'Firm Professional Pushback';
    if (boundaryRetained >= 5.0) return 'Contained Compromise';
    if (boundaryRetained >= 3.0) return 'Permeable Perimeter';
    return 'Total Boundary Breach';
  }

  /// Calculates composite equanimity score (0-100%)
  int get compositeScore {
    final composite = ((reactionControl + boundaryRetained) / 20.0) * 100;
    return composite.round().clamp(0, 100);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateKey': dateKey,
      'timestamp': timestamp.toIso8601String(),
      'reactionControl': reactionControl,
      'boundaryRetained': boundaryRetained,
      'coreOutput': coreOutput,
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String? ?? '',
      dateKey: map['dateKey'] as String? ?? '',
      timestamp:
          DateTime.tryParse(map['timestamp'] as String? ?? '') ??
          DateTime.now(),
      reactionControl: (map['reactionControl'] as num?)?.toDouble() ?? 5.0,
      boundaryRetained: (map['boundaryRetained'] as num?)?.toDouble() ?? 5.0,
      coreOutput: map['coreOutput'] as String? ?? '',
    );
  }
}
