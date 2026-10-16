/// StreakData encapsulates consistency metrics across daily debriefs.
class StreakData {
  final int currentStreak;
  final int longestStreak;
  final String? lastDebriefDate;
  final Map<String, bool> historyMap;
  final double weeklyBoundaryRetentionRate;
  final double weeklyReactionControlAverage;

  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    this.lastDebriefDate,
    required this.historyMap,
    this.weeklyBoundaryRetentionRate = 0.0,
    this.weeklyReactionControlAverage = 0.0,
  });

  bool isCompletedToday(String todayKey) {
    return historyMap[todayKey] == true;
  }
}
