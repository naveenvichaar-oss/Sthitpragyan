import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/journal/data/models/journal_models.dart';
import '../../features/journal/data/models/media_record_log.dart';
import '../../features/recovery/data/models/incident_slip_up_log.dart';
import '../../features/settings/data/models/notification_slot_config.dart';
import '../../features/wisdom/data/models/resource_link.dart';
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
  late Box<Map> _sosIncidentsBox;
  late Box<Map> _incidentLogsBox;
  late Box<Map> _resourceVaultBox;
  late Box _affirmationsBox;
  late Box<Map> _mediaVaultBox;

  /// Initializes Hive and registers custom TypeAdapters
  Future<void> init() async {
    if (_initialized) return;

    try {
      await Hive.initFlutter();

      // Register Hive TypeAdapters
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(DailyJournalEntryAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SosIncidentLogAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(MediaRecordLogAdapter());
      }

      _journalBox = await Hive.openBox<Map>(HiveBoxes.journalEntries);
      _streakBox = await Hive.openBox(HiveBoxes.streak);
      _settingsBox = await Hive.openBox(HiveBoxes.settings);
      _pinnedScriptsBox = await Hive.openBox<String>(HiveBoxes.pinnedScripts);
      _sosIncidentsBox = await Hive.openBox<Map>(HiveBoxes.sosIncidents);
      _incidentLogsBox = await Hive.openBox<Map>(HiveBoxes.incidentLogs);
      _resourceVaultBox = await Hive.openBox<Map>(HiveBoxes.resourceVault);
      _affirmationsBox = await Hive.openBox(HiveBoxes.affirmations);
      _mediaVaultBox = await Hive.openBox<Map>(HiveBoxes.mediaVault);

      // Pre-seed verified public-domain resources on first launch
      if (_resourceVaultBox.isEmpty) {
        for (final item in ResourceLink.preSeededResources()) {
          await _resourceVaultBox.put(item.id, item.toMap());
        }
      }

      _initialized = true;
      debugPrint(
        '[HiveStorage] Successfully initialized offline database with TypeAdapters.',
      );
    } catch (e, stack) {
      debugPrint('[HiveStorage] Initialization failure: $e\n$stack');
      rethrow;
    }
  }

  // ---------------------------------------------------------
  // 3-Index Journal Storage Operations (DailyJournalEntry)
  // ---------------------------------------------------------

  Future<void> saveJournalEntry(String key, Map<String, dynamic> data) async {
    await _journalBox.put(key, data);
  }

  Future<void> saveDailyJournalEntry(DailyJournalEntry entry) async {
    await _journalBox.put(entry.entryDate, entry.toMap());
  }

  DailyJournalEntry? getDailyJournalEntry(String dateKey) {
    final entry = _journalBox.get(dateKey);
    if (entry == null) return null;
    return DailyJournalEntry.fromMap(Map<String, dynamic>.from(entry));
  }

  Map<String, dynamic>? getJournalEntry(String key) {
    final entry = _journalBox.get(key);
    if (entry == null) return null;
    return Map<String, dynamic>.from(entry);
  }

  List<DailyJournalEntry> getAllDailyJournalEntries() {
    final entries = <DailyJournalEntry>[];
    for (final raw in _journalBox.values) {
      entries.add(DailyJournalEntry.fromMap(Map<String, dynamic>.from(raw)));
    }
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  List<Map<String, dynamic>> getAllJournalEntries() {
    final entries = <Map<String, dynamic>>[];
    for (final raw in _journalBox.values) {
      entries.add(Map<String, dynamic>.from(raw));
    }
    entries.sort((a, b) {
      final aDate =
          a['createdAt'] as String? ?? a['timestamp'] as String? ?? '';
      final bDate =
          b['createdAt'] as String? ?? b['timestamp'] as String? ?? '';
      return bDate.compareTo(aDate);
    });
    return entries;
  }

  Future<void> deleteJournalEntry(String key) async {
    await _journalBox.delete(key);
  }

  // ---------------------------------------------------------
  // SOS Incident Telemetry Operations (SosIncidentLog)
  // ---------------------------------------------------------

  Future<void> saveSosIncidentLog(SosIncidentLog incident) async {
    await _sosIncidentsBox.put(incident.id, incident.toMap());
  }

  Future<void> logSOSIncident(Map<String, dynamic> incident) async {
    final id =
        incident['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _sosIncidentsBox.put(id, incident);
  }

  List<SosIncidentLog> getAllSosIncidentLogs() {
    final list = <SosIncidentLog>[];
    for (final raw in _sosIncidentsBox.values) {
      list.add(SosIncidentLog.fromMap(Map<String, dynamic>.from(raw)));
    }
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  List<Map<String, dynamic>> getAllSOSIncidents() {
    final list = <Map<String, dynamic>>[];
    for (final raw in _sosIncidentsBox.values) {
      list.add(Map<String, dynamic>.from(raw));
    }
    list.sort((a, b) {
      final aDate = a['timestamp'] as String? ?? '';
      final bDate = b['timestamp'] as String? ?? '';
      return bDate.compareTo(aDate);
    });
    return list;
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

  // ---------------------------------------------------------
  // Custom Dynamic Notification Slots
  // ---------------------------------------------------------

  List<NotificationSlotConfig> getNotificationSlots() {
    final raw = _settingsBox.get('custom_notification_slots');
    if (raw is List && raw.isNotEmpty) {
      try {
        final list = <NotificationSlotConfig>[];
        for (final item in raw) {
          if (item is Map) {
            list.add(
              NotificationSlotConfig.fromMap(Map<String, dynamic>.from(item)),
            );
          }
        }
        if (list.isNotEmpty) return list;
      } catch (e) {
        debugPrint('[HiveStorage] Error parsing custom slots: $e');
      }
    }
    return NotificationSlotConfig.defaultSlots();
  }

  Future<void> saveNotificationSlots(List<NotificationSlotConfig> slots) async {
    final serialized = slots.map((s) => s.toMap()).toList();
    await _settingsBox.put('custom_notification_slots', serialized);
  }

  Future<void> updateNotificationSlot(NotificationSlotConfig slot) async {
    final slots = getNotificationSlots();
    final index = slots.indexWhere((s) => s.id == slot.id);
    if (index != -1) {
      slots[index] = slot;
    } else {
      slots.add(slot);
    }
    await saveNotificationSlots(slots);
  }

  Future<void> addNotificationSlot(NotificationSlotConfig slot) async {
    final slots = getNotificationSlots();
    slots.add(slot);
    await saveNotificationSlots(slots);
  }

  Future<void> deleteNotificationSlot(String slotId) async {
    final slots = getNotificationSlots();
    slots.removeWhere((s) => s.id == slotId);
    await saveNotificationSlots(slots);
  }

  Future<void> resetNotificationSlotsToDefault() async {
    await saveNotificationSlots(NotificationSlotConfig.defaultSlots());
  }

  // ---------------------------------------------------------
  // Slip-Up / Post-Incident Recovery Operations
  // ---------------------------------------------------------

  Future<void> saveSlipUpIncident(IncidentSlipUpLog incident) async {
    await _incidentLogsBox.put(incident.id, incident.toMap());
  }

  List<IncidentSlipUpLog> getAllSlipUpIncidents() {
    final list = <IncidentSlipUpLog>[];
    for (final raw in _incidentLogsBox.values) {
      list.add(IncidentSlipUpLog.fromMap(Map<String, dynamic>.from(raw)));
    }
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> deleteSlipUpIncident(String id) async {
    await _incidentLogsBox.delete(id);
  }

  // ---------------------------------------------------------
  // Resource Vault Operations (ResourceLink)
  // ---------------------------------------------------------

  List<ResourceLink> getAllResourceLinks() {
    final list = <ResourceLink>[];
    for (final raw in _resourceVaultBox.values) {
      try {
        list.add(ResourceLink.fromMap(Map<String, dynamic>.from(raw)));
      } catch (e) {
        debugPrint('[HiveStorage] Error parsing resource: $e');
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> saveResourceLink(ResourceLink resource) async {
    await _resourceVaultBox.put(resource.id, resource.toMap());
  }

  Future<void> deleteResourceLink(String id) async {
    await _resourceVaultBox.delete(id);
  }

  Future<void> resetResourceLinksToDefault() async {
    await _resourceVaultBox.clear();
    for (final item in ResourceLink.preSeededResources()) {
      await _resourceVaultBox.put(item.id, item.toMap());
    }
  }

  // ---------------------------------------------------------
  // Affirmation & Daily Wisdom Anchor Operations
  // ---------------------------------------------------------

  String? getDailyAffirmationId() {
    return _affirmationsBox.get('active_affirmation_id') as String?;
  }

  String? getDailyAffirmationTitle() {
    return _affirmationsBox.get('active_affirmation_title') as String?;
  }

  String? getDailyAffirmationText() {
    return _affirmationsBox.get('active_affirmation_text') as String?;
  }

  String? getDailyAffirmationSource() {
    return _affirmationsBox.get('active_affirmation_source') as String?;
  }

  Future<void> setDailyAffirmation({
    required String id,
    required String title,
    required String text,
    required String source,
  }) async {
    await _affirmationsBox.put('active_affirmation_id', id);
    await _affirmationsBox.put('active_affirmation_title', title);
    await _affirmationsBox.put('active_affirmation_text', text);
    await _affirmationsBox.put('active_affirmation_source', source);
    await _affirmationsBox.put('active_affirmation_date', DateTime.now().toIso8601String());
  }

  Future<void> clearDailyAffirmation() async {
    await _affirmationsBox.delete('active_affirmation_id');
    await _affirmationsBox.delete('active_affirmation_title');
    await _affirmationsBox.delete('active_affirmation_text');
    await _affirmationsBox.delete('active_affirmation_source');
  }

  // ---------------------------------------------------------
  // Media Vault & Stealth Media Operations (MediaRecordLog)
  // ---------------------------------------------------------

  Future<void> saveMediaRecord(MediaRecordLog record) async {
    await _mediaVaultBox.put(record.id, record.toMap());
  }

  MediaRecordLog? getMediaRecord(String id) {
    final raw = _mediaVaultBox.get(id);
    if (raw == null) return null;
    return MediaRecordLog.fromMap(Map<String, dynamic>.from(raw));
  }

  List<MediaRecordLog> getAllMediaRecords() {
    final list = <MediaRecordLog>[];
    for (final raw in _mediaVaultBox.values) {
      list.add(MediaRecordLog.fromMap(Map<String, dynamic>.from(raw)));
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> deleteMediaRecord(String id) async {
    await _mediaVaultBox.delete(id);
  }

  // ---------------------------------------------------------
  // Stealth Vault Security & PIN Settings
  // ---------------------------------------------------------

  String getStealthPin() {
    return _settingsBox.get('stealth_vault_pin', defaultValue: '0000') as String;
  }

  Future<void> setStealthPin(String pin) async {
    await _settingsBox.put('stealth_vault_pin', pin);
  }
}
