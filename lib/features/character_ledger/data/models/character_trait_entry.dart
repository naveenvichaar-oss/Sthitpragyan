import 'package:flutter/material.dart';

/// Categories of dignified character traits in Sthitaprajna
enum CharacterTraitCategory {
  magnanimity, // उदारता - Big-Hearted Composure
  gravitas,    // गांभीर्य - Unshakable Response & Stillness
  joy,         // प्रसन्नता - Genuine Joy & Internal Grounding
  restraint,   // संयम - Tactical Restraint & Strategic Silence
  custom;      // व्यक्तिगत गुण - Custom Virtue

  String get displayName {
    switch (this) {
      case CharacterTraitCategory.magnanimity:
        return 'Magnanimity';
      case CharacterTraitCategory.gravitas:
        return 'Gravitas & Stillness';
      case CharacterTraitCategory.joy:
        return 'Genuine Joy & Grace';
      case CharacterTraitCategory.restraint:
        return 'Tactical Restraint';
      case CharacterTraitCategory.custom:
        return 'Custom Virtue';
    }
  }

  String get devanagari {
    switch (this) {
      case CharacterTraitCategory.magnanimity:
        return 'उदारता';
      case CharacterTraitCategory.gravitas:
        return 'गांभीर्य';
      case CharacterTraitCategory.joy:
        return 'प्रसन्नता';
      case CharacterTraitCategory.restraint:
        return 'संयम';
      case CharacterTraitCategory.custom:
        return 'व्यक्तिगत गुण';
    }
  }

  String get subtitle {
    switch (this) {
      case CharacterTraitCategory.magnanimity:
        return 'Big-Hearted Composure • Rising above pettiness';
      case CharacterTraitCategory.gravitas:
        return 'Unshakable Response • Physical & vocal stillness';
      case CharacterTraitCategory.joy:
        return 'Internal Grounding • Radiant inner serenity';
      case CharacterTraitCategory.restraint:
        return 'Strategic Silence • Deliberate non-reaction';
      case CharacterTraitCategory.custom:
        return 'User-Defined Virtue • Personal trait mastery';
    }
  }

  Color get accentColor {
    switch (this) {
      case CharacterTraitCategory.magnanimity:
        return const Color(0xFFF59E0B); // Amber
      case CharacterTraitCategory.gravitas:
        return const Color(0xFF38BDF8); // Sky
      case CharacterTraitCategory.joy:
        return const Color(0xFF10B981); // Emerald
      case CharacterTraitCategory.restraint:
        return const Color(0xFF818CF8); // Indigo
      case CharacterTraitCategory.custom:
        return const Color(0xFFA855F7); // Purple
    }
  }

  IconData get icon {
    switch (this) {
      case CharacterTraitCategory.magnanimity:
        return Icons.volunteer_activism_rounded;
      case CharacterTraitCategory.gravitas:
        return Icons.anchor_rounded;
      case CharacterTraitCategory.joy:
        return Icons.spa_rounded;
      case CharacterTraitCategory.restraint:
        return Icons.shield_outlined;
      case CharacterTraitCategory.custom:
        return Icons.auto_awesome_rounded;
    }
  }

  static CharacterTraitCategory fromString(String? value) {
    if (value == null) return CharacterTraitCategory.gravitas;
    final lower = value.toLowerCase().trim();
    if (lower.contains('magnan') || lower.contains('उदारता')) {
      return CharacterTraitCategory.magnanimity;
    }
    if (lower.contains('gravitas') || lower.contains('गांभीर्य') || lower.contains('stillness')) {
      return CharacterTraitCategory.gravitas;
    }
    if (lower.contains('joy') || lower.contains('grace') || lower.contains('प्रसन्नता')) {
      return CharacterTraitCategory.joy;
    }
    if (lower.contains('restraint') || lower.contains('संयम') || lower.contains('silence')) {
      return CharacterTraitCategory.restraint;
    }
    return CharacterTraitCategory.custom;
  }
}

/// Represents an individual virtue or trait log in the Character Ledger.
class CharacterTraitEntry {
  final String id;
  final CharacterTraitCategory category;
  final String title;
  final String situation;
  final String behaviorObservation;
  final String? reflection;
  final List<String> tags;
  final int gravitasRating; // 1 to 5
  final DateTime timestamp;

  const CharacterTraitEntry({
    required this.id,
    required this.category,
    required this.title,
    required this.situation,
    required this.behaviorObservation,
    this.reflection,
    required this.tags,
    this.gravitasRating = 5,
    required this.timestamp,
  });

  CharacterTraitEntry copyWith({
    String? id,
    CharacterTraitCategory? category,
    String? title,
    String? situation,
    String? behaviorObservation,
    String? reflection,
    List<String>? tags,
    int? gravitasRating,
    DateTime? timestamp,
  }) {
    return CharacterTraitEntry(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      situation: situation ?? this.situation,
      behaviorObservation: behaviorObservation ?? this.behaviorObservation,
      reflection: reflection ?? this.reflection,
      tags: tags ?? this.tags,
      gravitasRating: gravitasRating ?? this.gravitasRating,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category.name,
      'title': title,
      'situation': situation,
      'behaviorObservation': behaviorObservation,
      'reflection': reflection,
      'tags': tags,
      'gravitasRating': gravitasRating,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CharacterTraitEntry.fromMap(Map<String, dynamic> map) {
    return CharacterTraitEntry(
      id: map['id'] as String? ?? 'trait_${DateTime.now().millisecondsSinceEpoch}',
      category: CharacterTraitCategory.fromString(map['category'] as String?),
      title: map['title'] as String? ?? 'Virtue Observation',
      situation: map['situation'] as String? ?? '',
      behaviorObservation: map['behaviorObservation'] as String? ?? '',
      reflection: map['reflection'] as String?,
      tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      gravitasRating: (map['gravitasRating'] as num?)?.toInt() ?? 5,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Initial starter reflections demonstrating the four core virtues
  static List<CharacterTraitEntry> starterEntries() {
    final now = DateTime.now();
    return [
      CharacterTraitEntry(
        id: 'starter_trait_1',
        category: CharacterTraitCategory.restraint,
        title: 'Withheld immediate counter-argument during budget dispute',
        situation: 'VP of Finance abruptly dismissed our quarterly timeline in the leadership standup.',
        behaviorObservation: 'Counted 4 seconds before speaking. Refrained from taking the bait. Lowered my vocal register and responded with data instead of indignation.',
        reflection: 'The room respected the 4-second silence more than any witty retort. Silence is leverage.',
        tags: ['#StrategicSilence', '#ExecutiveVoice', '#Restraint'],
        gravitasRating: 5,
        timestamp: now.subtract(const Duration(hours: 4)),
      ),
      CharacterTraitEntry(
        id: 'starter_trait_2',
        category: CharacterTraitCategory.magnanimity,
        title: 'Generously attributed code refactor breakthrough to junior peer',
        situation: 'Architecture review meeting where executives praised the newly stabilized database pipeline.',
        behaviorObservation: 'Explicitly pointed out the junior engineer\'s sleepless effort and foundational groundwork, refusing to hoard credit.',
        reflection: 'Pettiness starves leadership; magnanimity creates unshakeable loyalty and inner freedom.',
        tags: ['#Magnanimity', '#Leadership', '#NoEgo'],
        gravitasRating: 5,
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      CharacterTraitEntry(
        id: 'starter_trait_3',
        category: CharacterTraitCategory.gravitas,
        title: 'Maintained total physical stillness during client escalation',
        situation: 'Client was visibly agitated due to a partner API downtime outside our control.',
        behaviorObservation: 'Did not fidget, touch my face, or shift in my chair. Kept eyes level and breathed at 4 seconds inhale, 6 seconds exhale.',
        reflection: 'My physical immobility de-escalated the client within 3 minutes without a single defensive word.',
        tags: ['#Stillness', '#Grounded', '#BodyLanguage'],
        gravitasRating: 5,
        timestamp: now.subtract(const Duration(days: 2)),
      ),
      CharacterTraitEntry(
        id: 'starter_trait_4',
        category: CharacterTraitCategory.joy,
        title: 'Found tranquil amusement during commute traffic gridlock',
        situation: 'Stranded in bumper-to-bumper traffic before an important keynote presentation.',
        behaviorObservation: 'Smiled gently, accepted the unchangeable circumstance, listened to meditative drone, and rehearsed my opening hook mentally.',
        reflection: 'Circumstances have no power to disrupt my tranquility unless I concede permission.',
        tags: ['#InnerGrace', '#Equanimity', '#AmorFati'],
        gravitasRating: 5,
        timestamp: now.subtract(const Duration(days: 3)),
      ),
    ];
  }
}
