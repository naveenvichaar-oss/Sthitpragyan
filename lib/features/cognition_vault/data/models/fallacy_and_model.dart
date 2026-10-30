enum CognitionType { fallacy, mentalModel, rulesOfEngagement }

/// Universal micro-card model representing either a Logical Fallacy
/// or a classic Mental Model / Decision Framework.
class CognitionItem {
  final String id;
  final CognitionType type;
  final String title;
  final String subtitle;
  final String latinName;
  final String definition;
  final String corporateManifestation; // Real Life Scenario / व्यावहारिक उदाहरण
  final String antidoteProtocol; // Counter-strategy / समाधान
  final String quickMaxim;
  final List<String> tags;
  final String? audioAttachmentPath; // Multimodal audio explainer
  final String? videoAttachmentPath; // Multimodal video explainer
  final bool isCustom;

  const CognitionItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.latinName,
    required this.definition,
    required this.corporateManifestation,
    required this.antidoteProtocol,
    required this.quickMaxim,
    required this.tags,
    this.audioAttachmentPath,
    this.videoAttachmentPath,
    this.isCustom = false,
  });

  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        latinName.toLowerCase().contains(q) ||
        definition.toLowerCase().contains(q) ||
        corporateManifestation.toLowerCase().contains(q) ||
        antidoteProtocol.toLowerCase().contains(q) ||
        tags.any((t) => t.toLowerCase().contains(q));
  }

  CognitionItem copyWith({
    String? id,
    CognitionType? type,
    String? title,
    String? subtitle,
    String? latinName,
    String? definition,
    String? corporateManifestation,
    String? antidoteProtocol,
    String? quickMaxim,
    List<String>? tags,
    String? audioAttachmentPath,
    String? videoAttachmentPath,
    bool? isCustom,
  }) {
    return CognitionItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      latinName: latinName ?? this.latinName,
      definition: definition ?? this.definition,
      corporateManifestation:
          corporateManifestation ?? this.corporateManifestation,
      antidoteProtocol: antidoteProtocol ?? this.antidoteProtocol,
      quickMaxim: quickMaxim ?? this.quickMaxim,
      tags: tags ?? this.tags,
      audioAttachmentPath: audioAttachmentPath ?? this.audioAttachmentPath,
      videoAttachmentPath: videoAttachmentPath ?? this.videoAttachmentPath,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'latinName': latinName,
      'definition': definition,
      'corporateManifestation': corporateManifestation,
      'antidoteProtocol': antidoteProtocol,
      'quickMaxim': quickMaxim,
      'tags': tags,
      'audioAttachmentPath': audioAttachmentPath,
      'videoAttachmentPath': videoAttachmentPath,
      'isCustom': isCustom,
    };
  }

  factory CognitionItem.fromMap(Map<String, dynamic> map) {
    return CognitionItem(
      id: map['id'] as String? ?? '',
      type: CognitionType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => CognitionType.mentalModel,
      ),
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      latinName: map['latinName'] as String? ?? '',
      definition: map['definition'] as String? ?? '',
      corporateManifestation: map['corporateManifestation'] as String? ?? '',
      antidoteProtocol: map['antidoteProtocol'] as String? ?? '',
      quickMaxim: map['quickMaxim'] as String? ?? '',
      tags: (map['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      audioAttachmentPath: map['audioAttachmentPath'] as String?,
      videoAttachmentPath: map['videoAttachmentPath'] as String?,
      isCustom: map['isCustom'] as bool? ?? false,
    );
  }
}
