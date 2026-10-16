import 'package:flutter/foundation.dart';

import '../../../core/database/hive_storage.dart';
import '../../../core/utils/date_helpers.dart';
import '../../dashboard/data/models/streak_data.dart';
import '../models/journal_entry.dart';

/// JournalRepository orchestrates storage and metric derivations for 3-Index Debriefs.
class JournalRepository {
  final HiveStorage _storage;

  JournalRepository({HiveStorage? storage})
    : _storage = storage ?? HiveStorage();

  /// Saves today's debrief and calculates updated streak
  Future<void> saveEntry(JournalEntry entry) async {
    // 1. Save entry to Hive
    await _storage.saveJournalEntry(entry.dateKey, entry.toMap());

    // 2. Update streak
    await _updateStreakOnSubmission(entry.dateKey);

    debugPrint('[JournalRepository] Saved debrief for ${entry.dateKey}');
  }

  /// Retrieves entry for a specific day
  JournalEntry? getEntryByDate(String dateKey) {
    final raw = _storage.getJournalEntry(dateKey);
    if (raw == null) return null;
    return JournalEntry.fromMap(raw);
  }

  /// Retrieves today's entry if logged
  JournalEntry? getTodayEntry() {
    final todayKey = DateHelpers.toStorageKey(DateTime.now());
    return getEntryByDate(todayKey);
  }

  /// Returns all historical debriefs sorted chronologically descending
  List<JournalEntry> getAllEntries() {
    final list = _storage.getAllJournalEntries();
    return list.map((m) => JournalEntry.fromMap(m)).toList();
  }

  /// Calculates aggregated streak metrics and past 7 days completion
  StreakData getStreakData() {
    final now = DateTime.now();
    final todayKey = DateHelpers.toStorageKey(now);
    final yesterdayKey = DateHelpers.toStorageKey(
      now.subtract(const Duration(days: 1)),
    );

    int currentStreak = _storage.getStreakCount();
    final longestStreak = _storage.getLongestStreak();
    final lastDebrief = _storage.getLastDebriefDate();
    final historyMap = _storage.getStreakHistoryMap();

    // Verify streak continuity: if last debrief wasn't today or yesterday, streak has reset to 0
    if (lastDebrief != null &&
        lastDebrief != todayKey &&
        lastDebrief != yesterdayKey) {
      currentStreak = 0;
      _storage.setStreakCount(0);
    }

    // Calculate weekly metrics over the last 7 days
    final last7Days = DateHelpers.getLast7Days(now);
    double boundarySum = 0;
    double reactionSum = 0;
    int daysCounted = 0;

    for (final day in last7Days) {
      final key = DateHelpers.toStorageKey(day);
      final entry = getEntryByDate(key);
      if (entry != null) {
        boundarySum += entry.boundaryRetained;
        reactionSum += entry.reactionControl;
        daysCounted++;
      }
    }

    final weeklyBoundaryRate = daysCounted > 0
        ? (boundarySum / (daysCounted * 10)) * 100
        : 0.0;
    final weeklyReactionAvg = daysCounted > 0
        ? (reactionSum / daysCounted)
        : 0.0;

    return StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastDebriefDate: lastDebrief,
      historyMap: historyMap,
      weeklyBoundaryRetentionRate: weeklyBoundaryRate,
      weeklyReactionControlAverage: weeklyReactionAvg,
    );
  }

  Future<void> _updateStreakOnSubmission(String dateKey) async {
    final now = DateTime.now();
    final todayKey = DateHelpers.toStorageKey(now);
    final yesterdayKey = DateHelpers.toStorageKey(
      now.subtract(const Duration(days: 1)),
    );

    int current = _storage.getStreakCount();
    int longest = _storage.getLongestStreak();
    final lastDate = _storage.getLastDebriefDate();

    // Check if this is the first submission for today
    if (lastDate != dateKey) {
      if (lastDate == yesterdayKey || current == 0) {
        current += 1;
      } else if (lastDate == null) {
        current = 1;
      } else {
        // Gap of more than 1 day
        current = 1;
      }

      if (current > longest) {
        longest = current;
      }

      await _storage.setStreakCount(current);
      await _storage.setLongestStreak(longest);
      await _storage.setLastDebriefDate(dateKey);
      await _storage.recordStreakDay(dateKey);
    }
  }

  /// Deletes an entry
  Future<void> deleteEntry(String dateKey) async {
    await _storage.deleteJournalEntry(dateKey);
  }

  /// Populates initial onboarding entries if the user is launching for the first time
  Future<void> seedInitialDataIfEmpty() async {
    if (getAllEntries().isEmpty) {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));

      final sample1 = JournalEntry(
        id: 'seed_01',
        dateKey: DateHelpers.toStorageKey(twoDaysAgo),
        timestamp: twoDaysAgo.add(const Duration(hours: 21, minutes: 15)),
        reactionControl: 8.5,
        boundaryRetained: 9.0,
        coreOutput: 'Paused 5 seconds during VP ambush. Delivered data audit without panic.',
      );

      final sample2 = JournalEntry(
        id: 'seed_02',
        dateKey: DateHelpers.toStorageKey(yesterday),
        timestamp: yesterday.add(const Duration(hours: 21, minutes: 40)),
        reactionControl: 9.0,
        boundaryRetained: 8.0,
        coreOutput: 'Rejected Friday evening scope increase. Preserved weekend perimeter.',
      );

      await saveEntry(sample1);
      await saveEntry(sample2);
    }
  }
}
