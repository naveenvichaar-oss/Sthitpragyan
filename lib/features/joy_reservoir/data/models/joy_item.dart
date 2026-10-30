import 'package:flutter/material.dart';

/// Categories of personal anchors in the Joy Reservoir
enum JoyCategory {
  music,
  visual,
  quote,
  memory;

  String get displayName {
    switch (this) {
      case JoyCategory.music:
        return 'Music & Ambient Sound';
      case JoyCategory.visual:
        return 'Visual Anchor';
      case JoyCategory.quote:
        return 'Comfort Words & Reads';
      case JoyCategory.memory:
        return 'Serene Memory & Milestone';
    }
  }

  String get badgeLabel {
    switch (this) {
      case JoyCategory.music:
        return 'MUSIC & SOUND';
      case JoyCategory.visual:
        return 'VISUAL ANCHOR';
      case JoyCategory.quote:
        return 'COMFORT WORDS';
      case JoyCategory.memory:
        return 'SOUL MEMORY';
    }
  }

  IconData get iconData {
    switch (this) {
      case JoyCategory.music:
        return Icons.music_note_rounded;
      case JoyCategory.visual:
        return Icons.photo_library_rounded;
      case JoyCategory.quote:
        return Icons.format_quote_rounded;
      case JoyCategory.memory:
        return Icons.spa_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case JoyCategory.music:
        return const Color(0xFF38BDF8); // Serene Sky Blue
      case JoyCategory.visual:
        return const Color(0xFF10B981); // Emerald Serenity
      case JoyCategory.quote:
        return const Color(0xFFF59E0B); // Golden Amber
      case JoyCategory.memory:
        return const Color(0xFFA855F7); // Amethyst Purple
    }
  }

  static JoyCategory fromString(String? value) {
    if (value == null) return JoyCategory.quote;
    switch (value.toLowerCase()) {
      case 'music':
      case 'audio':
      case 'sound':
        return JoyCategory.music;
      case 'visual':
      case 'image':
      case 'photo':
        return JoyCategory.visual;
      case 'quote':
      case 'words':
      case 'reading':
        return JoyCategory.quote;
      case 'memory':
      case 'milestone':
      case 'anchor':
        return JoyCategory.memory;
      default:
        return JoyCategory.quote;
    }
  }

  String toStorageString() {
    switch (this) {
      case JoyCategory.music:
        return 'music';
      case JoyCategory.visual:
        return 'visual';
      case JoyCategory.quote:
        return 'quote';
      case JoyCategory.memory:
        return 'memory';
    }
  }
}

/// JoyItem represents a personal source of joy, serenity, and emotional grounding.
class JoyItem {
  final String id;
  final String title;
  final JoyCategory category;
  final String? mediaUrlOrPath;
  final String? note;
  final DateTime timestamp;

  const JoyItem({
    required this.id,
    required this.title,
    required this.category,
    this.mediaUrlOrPath,
    this.note,
    required this.timestamp,
  });

  /// True if the media path references an offline audio file stored on device
  bool get isLocalAudio {
    if (mediaUrlOrPath == null) return false;
    final trimmed = mediaUrlOrPath!.trim();
    if (trimmed.isEmpty) return false;
    return !trimmed.startsWith('http://') && !trimmed.startsWith('https://');
  }

  /// True if the media URL points to YouTube or YouTube Music
  bool get isYouTube {
    if (mediaUrlOrPath == null) return false;
    final lower = mediaUrlOrPath!.toLowerCase();
    return lower.contains('youtube.com') ||
        lower.contains('youtu.be') ||
        lower.contains('music.youtube.com');
  }

  /// True specifically if the media URL is from YouTube Music
  bool get isYouTubeMusic {
    if (mediaUrlOrPath == null) return false;
    final lower = mediaUrlOrPath!.toLowerCase();
    return lower.contains('music.youtube.com');
  }

  JoyItem copyWith({
    String? id,
    String? title,
    JoyCategory? category,
    String? mediaUrlOrPath,
    String? note,
    DateTime? timestamp,
  }) {
    return JoyItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      mediaUrlOrPath: mediaUrlOrPath ?? this.mediaUrlOrPath,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category.toStorageString(),
      'mediaUrlOrPath': mediaUrlOrPath,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory JoyItem.fromMap(Map<String, dynamic> map) {
    return JoyItem(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled Anchor',
      category: JoyCategory.fromString(map['category'] as String?),
      mediaUrlOrPath: map['mediaUrlOrPath'] as String?,
      note: map['note'] as String?,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Curated default anchors to give first-time users an inspiring, grounded starter space
  static List<JoyItem> starterAnchors() {
    return [
      JoyItem(
        id: 'seed_joy_ambient_flute',
        title: 'Bansuri & Forest Rain Equanimity',
        category: JoyCategory.music,
        mediaUrlOrPath: 'https://www.youtube.com/watch?v=R9OCA6UFE-0',
        note: 'Deep resonant Indian classical bamboo flute and gentle rain for instant cortisol reduction and heart rate slowing.',
        timestamp: DateTime(2026, 1, 1),
      ),
      JoyItem(
        id: 'seed_joy_himalayan_anchor',
        title: 'Morning Sunlight over Eternal Peaks',
        category: JoyCategory.visual,
        mediaUrlOrPath: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
        note: 'Silent, unchanging majesty. When worldly chaos surges, remember the eternal mountain peak remains completely undisturbed.',
        timestamp: DateTime(2026, 1, 2),
      ),
      JoyItem(
        id: 'seed_joy_inner_citadel',
        title: 'Marcus Aurelius - The Inner Citadel',
        category: JoyCategory.quote,
        mediaUrlOrPath: null,
        note: '“Nowhere can man find a quieter or more untroubled retreat than in his own soul. Constantly then give to yourself this retreat, and renew yourself.”',
        timestamp: DateTime(2026, 1, 3),
      ),
      JoyItem(
        id: 'seed_joy_pre_dawn_coffee',
        title: 'The 5:30 AM Unhurried Silence',
        category: JoyCategory.memory,
        mediaUrlOrPath: null,
        note: 'No emails, no Slack pings, no expectations. Just steam rising from the cup and the pure peace of pre-dawn consciousness.',
        timestamp: DateTime(2026, 1, 4),
      ),
    ];
  }
}
