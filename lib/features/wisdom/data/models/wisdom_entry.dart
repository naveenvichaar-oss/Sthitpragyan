/// WisdomEntry represents an immutable wisdom shloka, philosophical quote,
/// or behavioral psychology model curated for executive composure.
class WisdomEntry {
  final String id;
  final String category; // 'gita', 'western_stoicism', 'psychology_behavioral'
  final String categoryName;
  final String title;
  final String source;
  final String originalText;
  final String translation;
  final String executiveTakeaway;
  final List<String> tags;
  final bool isEmergencyPerspective;

  const WisdomEntry({
    required this.id,
    required this.category,
    required this.categoryName,
    required this.title,
    required this.source,
    required this.originalText,
    required this.translation,
    required this.executiveTakeaway,
    this.tags = const [],
    this.isEmergencyPerspective = false,
  });

  factory WisdomEntry.fromJson(Map<String, dynamic> json) {
    return WisdomEntry(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      categoryName: json['categoryName'] as String? ?? 'Wisdom',
      title: json['title'] as String? ?? '',
      source: json['source'] as String? ?? '',
      originalText: json['originalText'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      executiveTakeaway: json['executiveTakeaway'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isEmergencyPerspective: json['isEmergencyPerspective'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'categoryName': categoryName,
      'title': title,
      'source': source,
      'originalText': originalText,
      'translation': translation,
      'executiveTakeaway': executiveTakeaway,
      'tags': tags,
      'isEmergencyPerspective': isEmergencyPerspective,
    };
  }
}
