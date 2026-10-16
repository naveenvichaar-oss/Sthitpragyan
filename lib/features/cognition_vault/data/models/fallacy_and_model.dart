enum CognitionType { fallacy, mentalModel, rulesOfEngagement }

/// Micro-card model representing either a corporate Logical Fallacy
/// or a classic Stoic Mental Model.
class CognitionItem {
  final String id;
  final CognitionType type;
  final String title;
  final String subtitle;
  final String latinName;
  final String definition;
  final String corporateManifestation;
  final String antidoteProtocol;
  final String quickMaxim;
  final List<String> tags;

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
}
