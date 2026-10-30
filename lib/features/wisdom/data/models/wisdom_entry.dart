/// WisdomEntry represents an immutable wisdom shloka, philosophical quote,
/// or behavioral psychology model curated for executive composure.
class WisdomEntry {
  final String id;
  final String category; // 'gita', 'western_stoicism', 'psychology_behavioral'
  final String categoryName;
  final String title;
  final String? titleHi;
  final String source;
  final String? sourceHi;
  final String originalText;
  final String? romanizedText;
  final String translation;
  final String? translationHi;
  final String executiveTakeaway;
  final String? executiveTakeawayHi;
  final List<String> tags;
  final bool isEmergencyPerspective;

  const WisdomEntry({
    required this.id,
    required this.category,
    required this.categoryName,
    required this.title,
    this.titleHi,
    required this.source,
    this.sourceHi,
    required this.originalText,
    this.romanizedText,
    required this.translation,
    this.translationHi,
    required this.executiveTakeaway,
    this.executiveTakeawayHi,
    this.tags = const [],
    this.isEmergencyPerspective = false,
  });

  /// Alias for authentic Sanskrit shloka or classical original text
  String get shlokaText => originalText;

  /// Returns localized shloka or original text based on active language:
  /// In English mode (isHindi == false), returns Roman transliteration when available.
  /// In Hindi mode (isHindi == true), returns original Devanagari Sanskrit text.
  String getLocalizedOriginalText([bool isHindi = false]) {
    if (!isHindi && romanizedText != null && romanizedText!.trim().isNotEmpty) {
      return romanizedText!;
    }
    return originalText;
  }

  /// Returns localized title based on active language
  String getTitle([bool isHindi = false]) {
    if (isHindi && titleHi != null && titleHi!.trim().isNotEmpty) {
      return titleHi!;
    }
    return title;
  }

  /// Returns localized source / subtitle based on active language
  String getSubtitle([bool isHindi = false]) {
    if (isHindi && sourceHi != null && sourceHi!.trim().isNotEmpty) {
      return sourceHi!;
    }
    return source;
  }

  /// Returns localized translation based on active language
  String getTranslation([bool isHindi = false]) {
    if (isHindi && translationHi != null && translationHi!.trim().isNotEmpty) {
      return translationHi!;
    }
    return translation;
  }

  /// Returns localized executive takeaway based on active language
  String getExecutiveTakeaway([bool isHindi = false]) {
    if (isHindi &&
        executiveTakeawayHi != null &&
        executiveTakeawayHi!.trim().isNotEmpty) {
      return executiveTakeawayHi!;
    }
    return executiveTakeaway;
  }

  factory WisdomEntry.fromJson(Map<String, dynamic> json) {
    String parseEn(dynamic value, [String fallback = '']) {
      if (value is Map) {
        return value['en']?.toString() ?? fallback;
      }
      return value?.toString() ?? fallback;
    }

    String? parseHi(dynamic value) {
      if (value is Map) {
        return value['hi']?.toString();
      }
      return null;
    }

    final rawTitle = json['title'];
    final rawSubtitle = json['subtitle'] ?? json['source'];
    final rawTranslation = json['translation'];
    final rawTakeaway = json['executiveTakeaway'];

    final titleEn = parseEn(rawTitle, json['titleEn']?.toString() ?? '');
    final titleHi = parseHi(rawTitle) ?? json['titleHi']?.toString();

    final sourceEn = parseEn(
      rawSubtitle,
      json['sourceEn']?.toString() ?? json['subtitleEn']?.toString() ?? '',
    );
    final sourceHi = parseHi(rawSubtitle) ??
        json['sourceHi']?.toString() ??
        json['subtitleHi']?.toString();

    final transEn =
        parseEn(rawTranslation, json['translationEn']?.toString() ?? '');
    final transHi =
        parseHi(rawTranslation) ?? json['translationHi']?.toString();

    final takeEn =
        parseEn(rawTakeaway, json['executiveTakeawayEn']?.toString() ?? '');
    final takeHi =
        parseHi(rawTakeaway) ?? json['executiveTakeawayHi']?.toString();

    final romanized = json['romanizedText']?.toString() ??
        json['originalTextEn']?.toString() ??
        json['shlokaTextEn']?.toString();

    return WisdomEntry(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      categoryName: json['categoryName'] as String? ?? 'Wisdom',
      title: titleEn,
      titleHi: titleHi,
      source: sourceEn,
      sourceHi: sourceHi,
      originalText:
          (json['shlokaText'] ?? json['originalText']) as String? ?? '',
      romanizedText: romanized,
      translation: transEn,
      translationHi: transHi,
      executiveTakeaway: takeEn,
      executiveTakeawayHi: takeHi,
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
      'title': {
        'en': title,
        if (titleHi != null) 'hi': titleHi,
      },
      'source': source,
      'subtitle': {
        'en': source,
        if (sourceHi != null) 'hi': sourceHi,
      },
      'originalText': originalText,
      'shlokaText': originalText,
      if (romanizedText != null) 'romanizedText': romanizedText,
      if (romanizedText != null) 'originalTextEn': romanizedText,
      'translation': {
        'en': translation,
        if (translationHi != null) 'hi': translationHi,
      },
      'executiveTakeaway': {
        'en': executiveTakeaway,
        if (executiveTakeawayHi != null) 'hi': executiveTakeawayHi,
      },
      'tags': tags,
      'isEmergencyPerspective': isEmergencyPerspective,
    };
  }
}
