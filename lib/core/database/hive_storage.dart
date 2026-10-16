import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'hive_boxes.dart';

/// HiveStorage provides zero-telemetry, offline-first local persistence.
/// All user data stays strictly on-device with instant memory-mapped lookups.
class HiveStorage {
  static final HiveStorage _instance = HiveStorage._internal();
  factory HiveStorage() => _instance;
  HiveStorage._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  late Box<Map> _journalBox;
  late Box _streakBox;
  late Box _settingsBox;
  late Box<String> _pinnedScriptsBox;

  /// Initializes Hive and opens required boxes
  Future<void> init() async {
    if (_initialized) return;

    try {
      await Hive.initFlutter();

      _journalBox = await Hive.openBox<Map>(HiveBoxes.journalEntries);
      _streakBox = await Hive.openBox(HiveBoxes.streak);
      _settingsBox = await Hive.openBox(HiveBoxes.settings);
      _pinnedScriptsBox = await Hive.openBox<String>(HiveBoxes.pinnedScripts);

      _initialized = true;
      debugPrint('[HiveStorage] Successfully initialized offline database.');
    } catch (e, stack) {
      debugPrint('[HiveStorage] Initialization failure: $e\n$stack');
      rethrow;
    }
  }

  // ---------------------------------------------------------
  // Journal Storage Operations
  // ---------------------------------------------------------

  /// Saves or updates a journal entry by its storage key or ID
  Future<void> saveJournalEntry(String key, Map<String, dynamic> data) async {
    await _journalBox.put(key, data);
  }

  /// Retrieves a journal entry for a given day key (yyyy-MM-dd)
  Map<String, dynamic>? getJournalEntry(String key) {
    final entry = _journalBox.get(key);
    if (entry == null) return null;
    return Map<String, dynamic>.from(entry);
  }

  /// Returns all journal entries sorted chronologically descending
  List<Map<String, dynamic>> getAllJournalEntries() {
    final entries = <Map<String, dynamic>>[];
    for (final raw in _journalBox.values) {
      entries.add(Map<String, dynamic>.from(raw));
    }
    entries.sort((a, b) {
      final aDate = a['timestamp'] as String? ?? '';
      final bDate = b['timestamp'] as String? ?? '';
      return bDate.compareTo(aDate);
    });
    return entries;
  }

  /// Deletes a journal entry
  Future<void> deleteJournalEntry(String key) async {
    await _journalBox.delete(key);
  }

  // ---------------------------------------------------------
  // Streak Storage Operations
  // ---------------------------------------------------------

  int getStreakCount() {
    return _streakBox.get('current_streak', defaultValue: 0) as int;
  }

  Future<void> setStreakCount(int count) async {
    await _streakBox.put('current_streak', count);
  }

  int getLongestStreak() {
    return _streakBox.get('longest_streak', defaultValue: 0) as int;
  }

  Future<void> setLongestStreak(int count) async {
    await _streakBox.put('longest_streak', count);
  }

  String? getLastDebriefDate() {
    return _streakBox.get('last_debrief_date') as String?;
  }

  Future<void> setLastDebriefDate(String dateKey) async {
    await _streakBox.put('last_debrief_date', dateKey);
  }

  Map<String, bool> getStreakHistoryMap() {
    final raw = _streakBox.get(
      'history_map',
      defaultValue: <dynamic, dynamic>{},
    );
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v == true));
    }
    return {};
  }

  Future<void> recordStreakDay(String dateKey) async {
    final history = getStreakHistoryMap();
    history[dateKey] = true;
    await _streakBox.put('history_map', history);
  }

  // ---------------------------------------------------------
  // Pinned Scripts & Favorites
  // ---------------------------------------------------------

  List<String> getPinnedScriptIds() {
    return _pinnedScriptsBox.values.toList();
  }

  Future<void> togglePinnedScript(String scriptId) async {
    if (_pinnedScriptsBox.containsKey(scriptId)) {
      await _pinnedScriptsBox.delete(scriptId);
    } else {
      await _pinnedScriptsBox.put(scriptId, scriptId);
    }
  }

  bool isScriptPinned(String scriptId) {
    return _pinnedScriptsBox.containsKey(scriptId);
  }

  // ---------------------------------------------------------
  // Settings & Flags
  // ---------------------------------------------------------

  bool getNotificationsEnabled() {
    return _settingsBox.get('notifications_enabled', defaultValue: true)
        as bool;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _settingsBox.put('notifications_enabled', enabled);
  }

  int getActiveRuleIndex() {
    return _settingsBox.get('active_rule_index', defaultValue: 0) as int;
  }

  Future<void> setActiveRuleIndex(int index) async {
    await _settingsBox.put('active_rule_index', index);
  }
}
