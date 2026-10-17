/// Model representing a non-negotiable execution block and commitment chime.
class ExecutionTrigger {
  final String id;
  final String title;
  final String devanagariSubtitle;
  final String timeOfDay; // Format "HH:mm" or "hh:mm a"
  final String intent;
  final String category;
  final bool isEnabled;
  final int streakCount;
  final DateTime? lastExecutedAt;

  const ExecutionTrigger({
    required this.id,
    required this.title,
    required this.devanagariSubtitle,
    required this.timeOfDay,
    required this.intent,
    required this.category,
    this.isEnabled = true,
    this.streakCount = 0,
    this.lastExecutedAt,
  });

  bool get isExecutedToday {
    if (lastExecutedAt == null) return false;
    final now = DateTime.now();
    return lastExecutedAt!.year == now.year &&
        lastExecutedAt!.month == now.month &&
        lastExecutedAt!.day == now.day;
  }

  ExecutionTrigger copyWith({
    String? id,
    String? title,
    String? devanagariSubtitle,
    String? timeOfDay,
    String? intent,
    String? category,
    bool? isEnabled,
    int? streakCount,
    DateTime? lastExecutedAt,
  }) {
    return ExecutionTrigger(
      id: id ?? this.id,
      title: title ?? this.title,
      devanagariSubtitle: devanagariSubtitle ?? this.devanagariSubtitle,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      intent: intent ?? this.intent,
      category: category ?? this.category,
      isEnabled: isEnabled ?? this.isEnabled,
      streakCount: streakCount ?? this.streakCount,
      lastExecutedAt: lastExecutedAt ?? this.lastExecutedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'devanagariSubtitle': devanagariSubtitle,
      'timeOfDay': timeOfDay,
      'intent': intent,
      'category': category,
      'isEnabled': isEnabled,
      'streakCount': streakCount,
      'lastExecutedAt': lastExecutedAt?.toIso8601String(),
    };
  }

  factory ExecutionTrigger.fromMap(Map<String, dynamic> map) {
    return ExecutionTrigger(
      id: map['id'] as String? ?? 'trigger_${DateTime.now().millisecondsSinceEpoch}',
      title: map['title'] as String? ?? 'Execution Block',
      devanagariSubtitle: map['devanagariSubtitle'] as String? ?? 'तात्कालिक निष्पादन',
      timeOfDay: map['timeOfDay'] as String? ?? '09:00',
      intent: map['intent'] as String? ?? 'Zero hesitation. Execute with composure.',
      category: map['category'] as String? ?? 'Deep Work',
      isEnabled: map['isEnabled'] as bool? ?? true,
      streakCount: map['streakCount'] as int? ?? 0,
      lastExecutedAt: map['lastExecutedAt'] != null
          ? DateTime.tryParse(map['lastExecutedAt'] as String)
          : null,
    );
  }

  /// Default Non-Negotiable Commitment Blocks
  static List<ExecutionTrigger> defaultTriggers() {
    return const [
      ExecutionTrigger(
        id: 'block_morning_grounding',
        title: 'Morning Grounding & Strategy',
        devanagariSubtitle: 'प्रातः कालीन चित्त स्थिरता',
        timeOfDay: '06:00',
        intent: 'Set the mental citadel before entering the arena. Prime the day with stoic clarity.',
        category: 'Grounding',
      ),
      ExecutionTrigger(
        id: 'block_deep_work_1',
        title: 'Deep Work Sprint I',
        devanagariSubtitle: 'तीव्र एकाग्रता काल',
        timeOfDay: '09:30',
        intent: 'Zero context switching. Uncompromising cognitive leverage on the critical deliverable.',
        category: 'Deep Work',
      ),
      ExecutionTrigger(
        id: 'block_friction_breaker',
        title: 'Friction Clear / Hard Task',
        devanagariSubtitle: 'प्रतिरोध निवारण',
        timeOfDay: '14:30',
        intent: 'Attack the deferred item that causes the most resistance. Done is better than perfect.',
        category: 'Friction Clear',
      ),
      ExecutionTrigger(
        id: 'block_evening_audit',
        title: 'Evening Audit & Closure',
        devanagariSubtitle: 'सायंकालीन आत्म-परीक्षण',
        timeOfDay: '21:00',
        intent: 'Close the books. Reclaim equanimity. Zero leftover anxiety before sleep.',
        category: 'Evening Audit',
      ),
    ];
  }
}
