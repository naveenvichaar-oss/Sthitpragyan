/// Universal reflection categories for Pillar 3 (संज्ञान / Cognition)
enum ReflectionCategory {
  dailyReview, // दैनिक समीक्षा (Daily Review & Reflection)
  personalJournal, // व्यक्तिगत डायरी व उद्गार (Personal Journal / Freeform Thoughts)
  planning, // योजना व रणनीति (Planning & Strategy - legacy)
  selfTalk, // आत्म-संवाद (Self-Talk / Calming Scripts - legacy)
  inputOutput1to3, // 1:3 आउटपुट लॉगर (1:3 Input-Output Logger)
  saveToVault, // सामग्री संचयन (Save to Sthitaprajna / Vault Ingest)
}

/// Universal Reflection Model for User-Authored Outflows & Audits
class ReflectionEntry {
  final String id;
  final String title;
  final String content;
  final ReflectionCategory category;
  final DateTime createdAt;
  final String? audioMemoPath;
  final String? videoReflectionPath;
  final int? reactionScore; // 1 to 5 for dailyReview
  final bool? boundaryMaintained; // true/false for dailyReview
  final String? distractionAvoided; // 1-liner on how distraction was prevented
  final List<String> tags;

  // Dedicated fields for 1:3 Input-Output Logger
  final String? sourceTitle;
  final String? takeaway1;
  final String? takeaway2;
  final String? takeaway3;

  const ReflectionEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    this.audioMemoPath,
    this.videoReflectionPath,
    this.reactionScore,
    this.boundaryMaintained,
    this.distractionAvoided,
    this.tags = const [],
    this.sourceTitle,
    this.takeaway1,
    this.takeaway2,
    this.takeaway3,
  });

  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        content.toLowerCase().contains(q) ||
        (distractionAvoided != null &&
            distractionAvoided!.toLowerCase().contains(q)) ||
        (sourceTitle != null && sourceTitle!.toLowerCase().contains(q)) ||
        (takeaway1 != null && takeaway1!.toLowerCase().contains(q)) ||
        (takeaway2 != null && takeaway2!.toLowerCase().contains(q)) ||
        (takeaway3 != null && takeaway3!.toLowerCase().contains(q)) ||
        tags.any((t) => t.toLowerCase().contains(q));
  }

  ReflectionEntry copyWith({
    String? id,
    String? title,
    String? content,
    ReflectionCategory? category,
    DateTime? createdAt,
    String? audioMemoPath,
    String? videoReflectionPath,
    int? reactionScore,
    bool? boundaryMaintained,
    String? distractionAvoided,
    List<String>? tags,
    String? sourceTitle,
    String? takeaway1,
    String? takeaway2,
    String? takeaway3,
  }) {
    return ReflectionEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      audioMemoPath: audioMemoPath ?? this.audioMemoPath,
      videoReflectionPath: videoReflectionPath ?? this.videoReflectionPath,
      reactionScore: reactionScore ?? this.reactionScore,
      boundaryMaintained: boundaryMaintained ?? this.boundaryMaintained,
      distractionAvoided: distractionAvoided ?? this.distractionAvoided,
      tags: tags ?? this.tags,
      sourceTitle: sourceTitle ?? this.sourceTitle,
      takeaway1: takeaway1 ?? this.takeaway1,
      takeaway2: takeaway2 ?? this.takeaway2,
      takeaway3: takeaway3 ?? this.takeaway3,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
      'audioMemoPath': audioMemoPath,
      'videoReflectionPath': videoReflectionPath,
      'reactionScore': reactionScore,
      'boundaryMaintained': boundaryMaintained,
      'distractionAvoided': distractionAvoided,
      'tags': tags,
      'sourceTitle': sourceTitle,
      'takeaway1': takeaway1,
      'takeaway2': takeaway2,
      'takeaway3': takeaway3,
    };
  }

  factory ReflectionEntry.fromMap(Map<String, dynamic> map) {
    return ReflectionEntry(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      category: ReflectionCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => ReflectionCategory.dailyReview,
      ),
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      audioMemoPath: map['audioMemoPath'] as String?,
      videoReflectionPath: map['videoReflectionPath'] as String?,
      reactionScore: (map['reactionScore'] as num?)?.toInt(),
      boundaryMaintained: map['boundaryMaintained'] as bool?,
      distractionAvoided: map['distractionAvoided'] as String?,
      tags: (map['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      sourceTitle: map['sourceTitle'] as String?,
      takeaway1: map['takeaway1'] as String?,
      takeaway2: map['takeaway2'] as String?,
      takeaway3: map['takeaway3'] as String?,
    );
  }
}
