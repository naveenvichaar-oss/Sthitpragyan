import 'package:flutter/foundation.dart';

import '../../../core/database/hive_storage.dart';
import '../../../core/utils/date_helpers.dart';
import '../../dashboard/data/models/streak_data.dart';
import '../models/journal_models.dart';

/// JournalRepository orchestrates storage and metric derivations for 3-Index Debriefs.
class JournalRepository {
  final HiveStorage _storage;

  JournalRepository({HiveStorage? storage})
    : _storage = storage ?? HiveStorage();

  /// Saves today's debrief and calculates updated streak
  Future<void> saveEntry(DailyJournalEntry entry) async {
    // 1. Save entry to Hive
    await _storage.saveDailyJournalEntry(entry);

    // 2. Update streak
    await _updateStreakOnSubmission(entry.entryDate);

    debugPrint('[JournalRepository] Saved debrief for ${entry.entryDate}');
  }

  /// Retrieves entry for a specific day
  DailyJournalEntry? getEntryByDate(String dateKey) {
    return _storage.getDailyJournalEntry(dateKey);
  }

  /// Retrieves today's entry if logged
  DailyJournalEntry? getTodayEntry() {
    final todayKey = DateHelpers.toStorageKey(DateTime.now());
    return getEntryByDate(todayKey);
  }

  /// Returns all historical debriefs sorted chronologically descending
  List<DailyJournalEntry> getAllEntries() {
    return _storage.getAllDailyJournalEntries();
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
    int boundariesMaintainedCount = 0;
    int reactionScoreSum = 0;
    int daysCounted = 0;

    for (final day in last7Days) {
      final key = DateHelpers.toStorageKey(day);
      final entry = getEntryByDate(key);
      if (entry != null) {
        if (entry.boundaryMaintained) boundariesMaintainedCount++;
        reactionScoreSum += entry.reactionControlScore;
        daysCounted++;
      }
    }

    final weeklyBoundaryRate = daysCounted > 0
        ? (boundariesMaintainedCount / daysCounted) * 100
        : 0.0;
    final weeklyReactionAvg = daysCounted > 0
        ? (reactionScoreSum / daysCounted) *
              2.0 // scale 1-5 to 10
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

  /// Populates initial onboarding entries if cold start
  Future<void> seedInitialDataIfEmpty() async {
    if (getAllEntries().isEmpty) {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));

      final sample1 = DailyJournalEntry(
        id: 'seed_01',
        entryDate: DateHelpers.toStorageKey(twoDaysAgo),
        createdAt: twoDaysAgo.add(const Duration(hours: 21, minutes: 15)),
        reactionControlScore: 4,
        boundaryMaintained: true,
        coreOutputSummary:
            'कॉर्पोरेट टैक्स पर 800 शब्दों का एक्सक्लूसिव विश्लेषण',
        provocationHandled: 'मीटिंग में 4 सेकंड पॉज देकर बात संभाली',
      );

      final sample2 = DailyJournalEntry(
        id: 'seed_02',
        entryDate: DateHelpers.toStorageKey(yesterday),
        createdAt: yesterday.add(const Duration(hours: 21, minutes: 40)),
        reactionControlScore: 5,
        boundaryMaintained: true,
        coreOutputSummary: 'अग्रिम प्रोजेक्ट आर्किटेक्चर डॉक्यूमेंट और कोड बेस रिव्यू पूरा किया',
        provocationHandled:
            'शुक्रवार देर शाम का गैर-योजित स्कोप बिना सफाई दिए अस्वीकार किया',
      );

      await saveEntry(sample1);
      await saveEntry(sample2);
    }
  }
}
