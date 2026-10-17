import 'package:flutter/material.dart';

/// Supported media resource classifications for curated and user-saved links
enum ResourceMediaType {
  youTube,
  drivePdf,
  googleKeep,
  substack,
  socialMedia,
  webLink;

  String get displayName {
    switch (this) {
      case ResourceMediaType.youTube:
        return 'YouTube Video';
      case ResourceMediaType.drivePdf:
        return 'Google Drive PDF';
      case ResourceMediaType.googleKeep:
        return 'Google Keep';
      case ResourceMediaType.substack:
        return 'Substack Publication';
      case ResourceMediaType.socialMedia:
        return 'Social Media Post';
      case ResourceMediaType.webLink:
        return 'Web Article / Archive';
    }
  }

  String get badgeLabel {
    switch (this) {
      case ResourceMediaType.youTube:
        return 'YOUTUBE';
      case ResourceMediaType.drivePdf:
        return 'DRIVE PDF';
      case ResourceMediaType.googleKeep:
        return 'KEEP NOTE';
      case ResourceMediaType.substack:
        return 'SUBSTACK';
      case ResourceMediaType.socialMedia:
        return 'SOCIAL';
      case ResourceMediaType.webLink:
        return 'WEB LINK';
    }
  }

  IconData get iconData {
    switch (this) {
      case ResourceMediaType.youTube:
        return Icons.play_circle_fill_rounded;
      case ResourceMediaType.drivePdf:
        return Icons.picture_as_pdf_rounded;
      case ResourceMediaType.googleKeep:
        return Icons.note_alt_rounded;
      case ResourceMediaType.substack:
        return Icons.newspaper_rounded;
      case ResourceMediaType.socialMedia:
        return Icons.public_rounded;
      case ResourceMediaType.webLink:
        return Icons.language_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case ResourceMediaType.youTube:
        return const Color(0xFFEF4444); // Red
      case ResourceMediaType.drivePdf:
        return const Color(0xFF3B82F6); // Blue
      case ResourceMediaType.googleKeep:
        return const Color(0xFFF59E0B); // Amber / Yellow
      case ResourceMediaType.substack:
        return const Color(0xFFFF6719); // Substack iconic Orange
      case ResourceMediaType.socialMedia:
        return const Color(0xFF8B5CF6); // Violet / Purple
      case ResourceMediaType.webLink:
        return const Color(0xFF10B981); // Emerald / Green
    }
  }

  static ResourceMediaType fromString(String? value) {
    if (value == null) return ResourceMediaType.webLink;
    switch (value.toLowerCase()) {
      case 'youtube':
        return ResourceMediaType.youTube;
      case 'drivepdf':
      case 'drive_pdf':
      case 'pdf':
        return ResourceMediaType.drivePdf;
      case 'googlekeep':
      case 'google_keep':
      case 'keep':
        return ResourceMediaType.googleKeep;
      case 'substack':
        return ResourceMediaType.substack;
      case 'socialmedia':
      case 'social_media':
      case 'social':
        return ResourceMediaType.socialMedia;
      default:
        return ResourceMediaType.webLink;
    }
  }

  String toStorageString() {
    switch (this) {
      case ResourceMediaType.youTube:
        return 'YouTube';
      case ResourceMediaType.drivePdf:
        return 'DrivePDF';
      case ResourceMediaType.googleKeep:
        return 'GoogleKeep';
      case ResourceMediaType.substack:
        return 'Substack';
      case ResourceMediaType.socialMedia:
        return 'SocialMedia';
      case ResourceMediaType.webLink:
        return 'WebLink';
    }
  }
}

/// ResourceLink represents an external classical text, public-domain video/audio,
/// or user's personal Google Drive/Keep resource for executive sanctuary.
class ResourceLink {
  final String id;
  final String title;
  final String category;
  final ResourceMediaType mediaType;
  final String url;
  final bool isUserAdded;
  final String? notes;
  final DateTime createdAt;

  const ResourceLink({
    required this.id,
    required this.title,
    required this.category,
    required this.mediaType,
    required this.url,
    this.isUserAdded = false,
    this.notes,
    required this.createdAt,
  });

  /// Automatically infers the ResourceMediaType from common URL patterns
  static ResourceMediaType detectMediaTypeFromUrl(String url) {
    final lower = url.trim().toLowerCase();
    if (lower.isEmpty) return ResourceMediaType.webLink;
    if (lower.contains('youtube.com') ||
        lower.contains('youtu.be') ||
        lower.contains('m.youtube.com')) {
      return ResourceMediaType.youTube;
    }
    if (lower.contains('drive.google.com') ||
        lower.contains('docs.google.com') ||
        lower.endsWith('.pdf')) {
      return ResourceMediaType.drivePdf;
    }
    if (lower.contains('keep.google.com')) {
      return ResourceMediaType.googleKeep;
    }
    if (lower.contains('substack.com')) {
      return ResourceMediaType.substack;
    }
    if (lower.contains('x.com') ||
        lower.contains('twitter.com') ||
        lower.contains('linkedin.com') ||
        lower.contains('reddit.com') ||
        lower.contains('instagram.com') ||
        lower.contains('threads.net') ||
        lower.contains('facebook.com') ||
        lower.contains('bsky.app')) {
      return ResourceMediaType.socialMedia;
    }
    return ResourceMediaType.webLink;
  }

  /// Returns the effective media type, resolving webLink to youTube / drivePdf / googleKeep
  /// if the underlying URL matches those services.
  ResourceMediaType get effectiveMediaType {
    if (mediaType == ResourceMediaType.webLink) {
      final detected = detectMediaTypeFromUrl(url);
      if (detected != ResourceMediaType.webLink) {
        return detected;
      }
    }
    return mediaType;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'mediaType': effectiveMediaType.toStorageString(),
      'url': url,
      'isUserAdded': isUserAdded,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ResourceLink.fromMap(Map<String, dynamic> map) {
    final rawMediaType = map['mediaType'] as String?;
    final url = map['url'] as String? ?? '';

    var type = ResourceMediaType.fromString(rawMediaType);
    if (type == ResourceMediaType.webLink) {
      final detected = detectMediaTypeFromUrl(url);
      if (detected != ResourceMediaType.webLink) {
        type = detected;
      }
    }

    return ResourceLink(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled Resource',
      category: map['category'] as String? ?? 'General Stoicism',
      mediaType: type,
      url: url,
      isUserAdded: map['isUserAdded'] as bool? ?? false,
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Curated classic pre-seeded resources verified in public domain
  static List<ResourceLink> preSeededResources() {
    return [
      ResourceLink(
        id: 'seed_meditations_mit',
        title: 'Marcus Aurelius - Meditations',
        category: 'Western Stoicism',
        mediaType: ResourceMediaType.webLink,
        url: 'https://classics.mit.edu/Antoninus/meditations.html',
        isUserAdded: false,
        notes: 'Complete unabridged George Long translation at MIT Classics Archive.',
        createdAt: DateTime(2026, 1, 1),
      ),
      ResourceLink(
        id: 'seed_enchiridion_mit',
        title: 'Epictetus - The Enchiridion (Handbook)',
        category: 'Western Stoicism',
        mediaType: ResourceMediaType.webLink,
        url: 'https://classics.mit.edu/Epictetus/epicench.html',
        isUserAdded: false,
        notes: 'Direct handbook of stoic discipline and cognitive detachment from external opinions.',
        createdAt: DateTime(2026, 1, 1),
      ),
      ResourceLink(
        id: 'seed_gita_ch2_breakdown',
        title: 'Bhagavad Gita Chapter 2 Analytical Breakdown',
        category: 'Gita & Sthitaprajna',
        mediaType: ResourceMediaType.webLink,
        url: 'https://gitaseva.org/',
        isUserAdded: false,
        notes: 'In-depth breakdown of Sthitaprajna lakshana (qualities of the steady-minded executive) via GitaSeva.',
        createdAt: DateTime(2026, 1, 1),
      ),
      ResourceLink(
        id: 'seed_stoic_crisis_regulation',
        title: 'Stoic Emotional Regulation in Crisis',
        category: 'Psychology & Stoicism',
        mediaType: ResourceMediaType.youTube,
        url: 'https://www.youtube.com/watch?v=R9OCA6UFE-0',
        isUserAdded: false,
        notes: 'Guided neuro-stoic perspective on managing workplace adrenal surges and panic.',
        createdAt: DateTime(2026, 1, 1),
      ),
    ];
  }
}
