/// NotificationSlotConfig represents a fully customizable reminder slot
/// in Sthitaprajna. Supports custom times, active days (weekend filter),
/// active/inactive toggles, and offline Hive persistence.
class NotificationSlotConfig {
  final String id;
  final int numericId;
  final String slotName;
  final String title;
  final String body;
  final String category;
  final int hour;
  final int minute;
  final bool isEnabled;
  final List<int> activeDays; // 1 = Monday ... 7 = Sunday
  final bool isCustom;

  const NotificationSlotConfig({
    required this.id,
    required this.numericId,
    required this.slotName,
    required this.title,
    required this.body,
    required this.category,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    required this.activeDays,
    this.isCustom = false,
  });

  /// Formatted 12-hour time string (e.g. "05:45 AM", "02:00 PM")
  String get formattedTime {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:$m $period';
  }

  /// Human-readable schedule summary (e.g., "Every day", "Weekdays only")
  String get daysSummary {
    if (activeDays.isEmpty) return 'No active days';
    if (activeDays.length == 7) return 'Every day';

    final sorted = List<int>.from(activeDays)..sort();
    final isWeekdaysOnly =
        sorted.length == 5 &&
        sorted[0] == 1 &&
        sorted[1] == 2 &&
        sorted[2] == 3 &&
        sorted[3] == 4 &&
        sorted[4] == 5;
    if (isWeekdaysOnly) return 'Weekdays (Mon–Fri)';

    final isWeekendsOnly =
        sorted.length == 2 && sorted[0] == 6 && sorted[1] == 7;
    if (isWeekendsOnly) return 'Weekends (Sat–Sun)';

    const dayLabels = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };

    return sorted
        .map((d) => dayLabels[d] ?? '')
        .where((s) => s.isNotEmpty)
        .join(', ');
  }

  /// Whether a specific weekday (1..7) is enabled
  bool isDayActive(int weekday) => activeDays.contains(weekday);

  NotificationSlotConfig copyWith({
    String? id,
    int? numericId,
    String? slotName,
    String? title,
    String? body,
    String? category,
    int? hour,
    int? minute,
    bool? isEnabled,
    List<int>? activeDays,
    bool? isCustom,
  }) {
    return NotificationSlotConfig(
      id: id ?? this.id,
      numericId: numericId ?? this.numericId,
      slotName: slotName ?? this.slotName,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      activeDays: activeDays ?? List<int>.from(this.activeDays),
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numericId': numericId,
      'slotName': slotName,
      'title': title,
      'body': body,
      'category': category,
      'hour': hour,
      'minute': minute,
      'isEnabled': isEnabled,
      'activeDays': activeDays,
      'isCustom': isCustom,
    };
  }

  factory NotificationSlotConfig.fromMap(Map<String, dynamic> map) {
    return NotificationSlotConfig(
      id:
          map['id'] as String? ??
          'slot_${DateTime.now().millisecondsSinceEpoch}',
      numericId:
          map['numericId'] as int? ??
          (map['id'].toString().hashCode.abs() % 10000),
      slotName: map['slotName'] as String? ?? 'Stoic Checkpoint',
      title: map['title'] as String? ?? 'Strategic Grounding',
      body: map['body'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      hour: map['hour'] as int? ?? 9,
      minute: map['minute'] as int? ?? 0,
      isEnabled: map['isEnabled'] as bool? ?? true,
      activeDays:
          (map['activeDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1, 2, 3, 4, 5, 6, 7],
      isCustom: map['isCustom'] as bool? ?? false,
    );
  }

  /// Initial factory default slots mirroring the 4 canonical checkpoints
  static List<NotificationSlotConfig> defaultSlots() {
    return [
      const NotificationSlotConfig(
        id: 'slot_morning',
        numericId: 101,
        slotName: 'Morning Grounding',
        title: 'Morning Grounding (प्रातःकालीन लंगर)',
        body: 'आज की घटनाओं पर आपका वश नहीं, अपनी प्रतिक्रिया पर शत-प्रतिशत नियंत्रण है।',
        category: 'Morning Grounding',
        hour: 5,
        minute: 45,
        isEnabled: true,
        activeDays: [1, 2, 3, 4, 5, 6, 7],
        isCustom: false,
      ),
      const NotificationSlotConfig(
        id: 'slot_work_entry',
        numericId: 102,
        slotName: 'Work Entry Shield',
        title: 'Work Entry Shield (द 3-सेकंड पॉज)',
        body: 'उकसावे पर रुकें। कोई सफाई नहीं, केवल तटस्थ अवलोकन।',
        category: 'Work Entry Shield',
        hour: 9,
        minute: 0,
        isEnabled: true,
        activeDays: [1, 2, 3, 4, 5], // Weekdays by default
        isCustom: false,
      ),
      const NotificationSlotConfig(
        id: 'slot_midday',
        numericId: 103,
        slotName: 'Mid-Day Audit',
        title: 'Mid-Day Audit (पारखी दृष्टि)',
        body: 'आपके \'ना\' कहने पर लोगों का व्यवहार बदला? बिना प्रतिक्रिया के केवल नोट करें।',
        category: 'Mid-Day Audit',
        hour: 14,
        minute: 0,
        isEnabled: true,
        activeDays: [1, 2, 3, 4, 5], // Weekdays by default
        isCustom: false,
      ),
      const NotificationSlotConfig(
        id: 'slot_night_closure',
        numericId: 104,
        slotName: 'Night Closure',
        title: 'Night Closure (3-इंडेक्स डायरी)',
        body: 'आज का हिसाब बंद करें। 60 सेकंड में 3-इंडेक्स एंट्री पूरी करें।',
        category: 'Night Closure',
        hour: 21,
        minute: 30,
        isEnabled: true,
        activeDays: [1, 2, 3, 4, 5, 6, 7],
        isCustom: false,
      ),
    ];
  }
}
