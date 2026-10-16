/// DailyRule encapsulates an executive Stoic imperative for the day,
/// pairing classical wisdom with a precise tactical corporate behavior.
class DailyRule {
  final int id;
  final String title;
  final String aphorism;
  final String source;
  final String tacticalAction;
  final String corporateContext;

  const DailyRule({
    required this.id,
    required this.title,
    required this.aphorism,
    required this.source,
    required this.tacticalAction,
    required this.corporateContext,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'aphorism': aphorism,
      'source': source,
      'tacticalAction': tacticalAction,
      'corporateContext': corporateContext,
    };
  }

  factory DailyRule.fromMap(Map<String, dynamic> map) {
    return DailyRule(
      id: map['id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      aphorism: map['aphorism'] as String? ?? '',
      source: map['source'] as String? ?? '',
      tacticalAction: map['tacticalAction'] as String? ?? '',
      corporateContext: map['corporateContext'] as String? ?? '',
    );
  }
}
