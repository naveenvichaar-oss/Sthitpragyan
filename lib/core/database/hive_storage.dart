import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/character_ledger/data/models/character_trait_entry.dart';
import '../../features/cognition_vault/data/cognition_data_source.dart';
import '../../features/cognition_vault/data/models/fallacy_and_model.dart';
import '../../features/cognition_vault/data/models/local_html_tool.dart';
import '../../features/execution_trigger/data/models/execution_trigger.dart';
import '../../features/journal/data/models/journal_models.dart';
import '../../features/journal/data/models/media_record_log.dart';
import '../../features/journal/data/models/reflection_entry.dart';
import '../../features/joy_reservoir/data/models/joy_item.dart';
import '../../features/recovery/data/models/incident_slip_up_log.dart';
import '../../features/settings/data/models/notification_slot_config.dart';
import '../../features/sos/data/defensive_scripts_vault.dart';
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
  late Box<Map> _joyReservoirBox;
  late Box<Map> _characterLedgerBox;
  late Box<Map> _executionTriggersBox;
  late Box<Map> _htmlToolsBox;
  late Box<Map> _defensiveScriptsBox;
  late Box<Map> _cognitionItemsBox;
  late Box<Map> _reflectionsBox;
  late Box _morningRoutineBox;

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
       _joyReservoirBox = await Hive.openBox<Map>(HiveBoxes.joyReservoir);
      _characterLedgerBox = await Hive.openBox<Map>(HiveBoxes.characterLedger);
      _executionTriggersBox = await Hive.openBox<Map>(HiveBoxes.executionTriggers);
      _htmlToolsBox = await Hive.openBox<Map>(HiveBoxes.htmlTools);
      _defensiveScriptsBox =
          await Hive.openBox<Map>(HiveBoxes.defensiveScripts);
      _cognitionItemsBox =
          await Hive.openBox<Map>(HiveBoxes.cognitionItems);
      _reflectionsBox =
          await Hive.openBox<Map>(HiveBoxes.reflections);
      _morningRoutineBox =
          await Hive.openBox(HiveBoxes.morningRoutine);

      // Pre-seed default cognition items (fallacies & mental models) if not present
      for (final item in CognitionDataSource.items) {
        if (!_cognitionItemsBox.containsKey(item.id)) {
          await _cognitionItemsBox.put(item.id, item.toMap());
        }
      }

      // Pre-seed default defensive scripts if not present or upgrade with bilingual fields
      for (final script in DefensiveScriptsVault.scripts) {
        if (!_defensiveScriptsBox.containsKey(script.id)) {
          await _defensiveScriptsBox.put(script.id, script.toMap());
        } else {
          final existing = _defensiveScriptsBox.get(script.id);
          if (existing != null && existing['hostileTriggerEn'] == null) {
            await _defensiveScriptsBox.put(script.id, script.toMap());
          }
        }
      }

      // Pre-seed starter anchors for Joy Reservoir if not present
      for (final item in JoyItem.starterAnchors()) {
        if (!_joyReservoirBox.containsKey(item.id)) {
          await _joyReservoirBox.put(item.id, item.toMap());
        }
      }

      // Pre-seed starter virtue entries for Character Ledger if not present
      for (final item in CharacterTraitEntry.starterEntries()) {
        if (!_characterLedgerBox.containsKey(item.id)) {
          await _characterLedgerBox.put(item.id, item.toMap());
        }
      }

      // User-defined Daily Focus Blocks (daily_blocks_box)
      // Dynamic user-controlled schedule (no hardcoded routines)

      // Pre-seed starter interactive HTML dashboard if empty
      if (_htmlToolsBox.isEmpty) {
        final starter = LocalHtmlTool.starterDashboard();
        await _htmlToolsBox.put(starter.id, starter.toMap());
      }

      // Pre-seed or sync verified public-domain resources
      if (_resourceVaultBox.isEmpty) {
        for (final item in ResourceLink.preSeededResources()) {
          await _resourceVaultBox.put(item.id, item.toMap());
        }
      } else {
        // Automatically sync updated default system links (without modifying custom user entries)
        for (final item in ResourceLink.preSeededResources()) {
          final existing = _resourceVaultBox.get(item.id);
          if (existing == null) {
            await _resourceVaultBox.put(item.id, item.toMap());
          } else {
            final isUserAdded = existing['isUserAdded'] as bool? ?? false;
            if (!isUserAdded && existing['url'] != item.url) {
              await _resourceVaultBox.put(item.id, item.toMap());
            }
          }
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

  String getLanguageCode() {
    if (!_initialized) return 'en';
    return _settingsBox.get('language_code', defaultValue: 'en') as String;
  }

  Future<void> setLanguageCode(String code) async {
    await _settingsBox.put('language_code', code);
  }

  // ---------------------------------------------------------
  // Custom Audio Recording Overrides (Voice Memos)
  // ---------------------------------------------------------

  String? getCustomAudioOverride(String topicKey) {
    final path = _settingsBox.get('custom_audio_$topicKey') as String?;
    return (path != null && path.trim().isNotEmpty) ? path : null;
  }

  Future<void> setCustomAudioOverride(String topicKey, String? audioFilePath) async {
    if (audioFilePath == null || audioFilePath.isEmpty) {
      await _settingsBox.delete('custom_audio_$topicKey');
    } else {
      await _settingsBox.put('custom_audio_$topicKey', audioFilePath);
    }
  }

  bool hasCustomAudioOverride(String topicKey) {
    return getCustomAudioOverride(topicKey) != null;
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
  // Daily Trigger Overrides (My Day Today / आज का दिन)
  // ---------------------------------------------------------

  Map<String, dynamic>? getCustomTriggerOverride(int triggerId) {
    final raw = _settingsBox.get('trigger_override_$triggerId');
    if (raw != null) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  Future<void> saveCustomTriggerOverride(
    int triggerId,
    Map<String, dynamic> data,
  ) async {
    await _settingsBox.put('trigger_override_$triggerId', data);
  }

  Future<void> clearCustomTriggerOverride(int triggerId) async {
    await _settingsBox.delete('trigger_override_$triggerId');
  }

  bool isTriggerReminderEnabled(int triggerId) {
    return _settingsBox.get('trigger_reminder_enabled_$triggerId', defaultValue: true) as bool;
  }

  Future<void> setTriggerReminderEnabled(int triggerId, bool enabled) async {
    await _settingsBox.put('trigger_reminder_enabled_$triggerId', enabled);
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
        final map = Map<String, dynamic>.from(raw);
        final link = ResourceLink.fromMap(map);
        // Self-heal: If stored mediaType was 'WebLink' or inconsistent with the URL, auto-migrate record in Hive
        final effectiveTypeString = link.effectiveMediaType.toStorageString();
        if (map['mediaType'] != effectiveTypeString) {
          map['mediaType'] = effectiveTypeString;
          _resourceVaultBox.put(link.id, map);
        }
        list.add(link);
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

  // ---------------------------------------------------------
  // Joy Reservoir Operations (JoyItem - आनंद कोष)
  // ---------------------------------------------------------

  List<JoyItem> getAllJoyItems() {
    final list = <JoyItem>[];
    for (final raw in _joyReservoirBox.values) {
      try {
        final map = Map<String, dynamic>.from(raw);
        list.add(JoyItem.fromMap(map));
      } catch (e) {
        debugPrint('[HiveStorage] Error parsing JoyItem: $e');
      }
    }
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> saveJoyItem(JoyItem item) async {
    await _joyReservoirBox.put(item.id, item.toMap());
  }

  Future<void> deleteJoyItem(String id) async {
    await _joyReservoirBox.delete(id);
  }

  Future<void> resetJoyItemsToDefault() async {
    await _joyReservoirBox.clear();
    for (final item in JoyItem.starterAnchors()) {
      await _joyReservoirBox.put(item.id, item.toMap());
    }
  }

  // ---------------------------------------------------------
  // Character Ledger Operations (CharacterTraitEntry - चरित्र कोष)
  // ---------------------------------------------------------

  List<CharacterTraitEntry> getAllCharacterTraits() {
    final list = <CharacterTraitEntry>[];
    for (final raw in _characterLedgerBox.values) {
      try {
        final map = Map<String, dynamic>.from(raw);
        list.add(CharacterTraitEntry.fromMap(map));
      } catch (e) {
        debugPrint('[HiveStorage] Error parsing CharacterTraitEntry: $e');
      }
    }
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> saveCharacterTrait(CharacterTraitEntry entry) async {
    await _characterLedgerBox.put(entry.id, entry.toMap());
  }

  Future<void> deleteCharacterTrait(String id) async {
    await _characterLedgerBox.delete(id);
  }

  Future<void> resetCharacterTraitsToDefault() async {
    await _characterLedgerBox.clear();
    for (final item in CharacterTraitEntry.starterEntries()) {
      await _characterLedgerBox.put(item.id, item.toMap());
    }
  }

  // ---------------------------------------------------------
  // Execution Triggers & Micro-Ignition Operations
  // ---------------------------------------------------------

  List<ExecutionTrigger> getAllExecutionTriggers() {
    final list = <ExecutionTrigger>[];
    for (final raw in _executionTriggersBox.values) {
      try {
        final map = Map<String, dynamic>.from(raw);
        list.add(ExecutionTrigger.fromMap(map));
      } catch (e) {
        debugPrint('[HiveStorage] Error parsing ExecutionTrigger: $e');
      }
    }
    list.sort((a, b) => a.timeOfDay.compareTo(b.timeOfDay));
    return list;
  }

  Future<void> saveExecutionTrigger(ExecutionTrigger trigger) async {
    await _executionTriggersBox.put(trigger.id, trigger.toMap());
  }

  Future<void> deleteExecutionTrigger(String id) async {
    await _executionTriggersBox.delete(id);
  }

  Future<void> recordExecutionCompletion(String id) async {
    final raw = _executionTriggersBox.get(id);
    if (raw != null) {
      final current = ExecutionTrigger.fromMap(Map<String, dynamic>.from(raw));
      final updated = current.copyWith(
        lastExecutedAt: DateTime.now(),
        streakCount: current.streakCount + 1,
      );
      await _executionTriggersBox.put(id, updated.toMap());
    }
  }

  int getMicroIgnitionCount() {
    return _settingsBox.get('micro_ignition_completed_count', defaultValue: 0) as int;
  }

  Future<void> incrementMicroIgnitionCount() async {
    final current = getMicroIgnitionCount();
    await _settingsBox.put('micro_ignition_completed_count', current + 1);
  }

  // ---------------------------------------------------------
  // Offline HTML Tools & Dashboards Operations (LocalHtmlTool)
  // ---------------------------------------------------------

  List<LocalHtmlTool> getAllHtmlTools() {
    final list = <LocalHtmlTool>[];
    for (final raw in _htmlToolsBox.values) {
      try {
        final map = Map<String, dynamic>.from(raw);
        list.add(LocalHtmlTool.fromMap(map));
      } catch (e) {
        debugPrint('[HiveStorage] Error parsing LocalHtmlTool: $e');
      }
    }
    list.sort((a, b) => b.addedDate.compareTo(a.addedDate));
    return list;
  }

  Future<void> saveHtmlTool(LocalHtmlTool tool) async {
    await _htmlToolsBox.put(tool.id, tool.toMap());
  }

  Future<void> deleteHtmlTool(String id) async {
    await _htmlToolsBox.delete(id);
  }

  Future<void> resetHtmlToolsToDefault() async {
    await _htmlToolsBox.clear();
    final starter = LocalHtmlTool.starterDashboard();
    await _htmlToolsBox.put(starter.id, starter.toMap());
  }

  // ---------------------------------------------------------
  // Defensive Scripts Operations (DefensiveScript)
  // ---------------------------------------------------------

  List<DefensiveScript> getAllDefensiveScripts() {
    if (!_initialized) return DefensiveScriptsVault.scripts;
    final list = <DefensiveScript>[];
    final defaultScriptMap = {for (final s in DefensiveScriptsVault.scripts) s.id: s};

    for (final raw in _defensiveScriptsBox.values) {
      try {
        final map = Map<String, dynamic>.from(raw);
        var script = DefensiveScript.fromMap(map);

        // Auto-upgrade built-in scripts with latest bilingual translations if missing
        if (!script.isCustom && defaultScriptMap.containsKey(script.id)) {
          final def = defaultScriptMap[script.id]!;
          if (script.hostileTriggerEn == null || script.hostileTriggerEn!.isEmpty) {
            script = script.copyWith(
              hostileTriggerEn: def.hostileTriggerEn,
              executiveScriptEn: def.executiveScriptEn,
              tacticalRationaleEn: def.tacticalRationaleEn,
              toneGuidanceEn: def.toneGuidanceEn,
            );
            _defensiveScriptsBox.put(script.id, script.toMap());
          }
        }

        list.add(script);
      } catch (e) {
        debugPrint('[HiveStorage] Error parsing DefensiveScript: $e');
      }
    }
    if (list.isEmpty) return DefensiveScriptsVault.scripts;
    return list;
  }

  Future<void> saveDefensiveScript(DefensiveScript script) async {
    if (!_initialized) return;
    await _defensiveScriptsBox.put(script.id, script.toMap());
  }

  Future<void> deleteDefensiveScript(String id) async {
    if (!_initialized) return;
    await _defensiveScriptsBox.delete(id);
  }

  Future<void> resetDefensiveScriptsToDefault() async {
    if (!_initialized) return;
    await _defensiveScriptsBox.clear();
    for (final script in DefensiveScriptsVault.scripts) {
      await _defensiveScriptsBox.put(script.id, script.toMap());
    }
  }

  // ---------------------------------------------------------
  // Cognition Items (Mental Models & Fallacies) CRUD & Attachments
  // ---------------------------------------------------------

  List<CognitionItem> getAllCognitionItems({CognitionType? type}) {
    if (!_initialized) return CognitionDataSource.items;
    // Auto-sync any newly added default items (Case studies, new fallacies)
    for (final def in CognitionDataSource.items) {
      if (!_cognitionItemsBox.containsKey(def.id)) {
        _cognitionItemsBox.put(def.id, def.toMap());
      }
    }
    final list = <CognitionItem>[];
    for (final raw in _cognitionItemsBox.values) {
      try {
        final map = Map<String, dynamic>.from(raw);
        final item = CognitionItem.fromMap(map);
        if (type != null && item.type != type) continue;
        list.add(item);
      } catch (e) {
        debugPrint('[HiveStorage] Error parsing CognitionItem: $e');
      }
    }
    if (list.isEmpty && _cognitionItemsBox.isEmpty) {
      return type != null
          ? CognitionDataSource.items.where((i) => i.type == type).toList()
          : CognitionDataSource.items;
    }
    return list;
  }

  // ---------------------------------------------------------
  // Morning Grounding Commitments (3-Second Pause & Unapologetic No)
  // ---------------------------------------------------------

  bool isTodayPauseRuleCommitted() {
    if (!_initialized) return false;
    final today = DateTime.now().toIso8601String().split('T').first;
    return _affirmationsBox.get('pause_rule_$today', defaultValue: false) as bool;
  }

  Future<void> setTodayPauseRuleCommitted(bool committed) async {
    if (!_initialized) return;
    final today = DateTime.now().toIso8601String().split('T').first;
    await _affirmationsBox.put('pause_rule_$today', committed);
  }

  bool isTodayUnapologeticNoCommitted() {
    if (!_initialized) return false;
    final today = DateTime.now().toIso8601String().split('T').first;
    return _affirmationsBox.get('unapologetic_no_$today', defaultValue: false) as bool;
  }

  Future<void> setTodayUnapologeticNoCommitted(bool committed) async {
    if (!_initialized) return;
    final today = DateTime.now().toIso8601String().split('T').first;
    await _affirmationsBox.put('unapologetic_no_$today', committed);
  }

  // ---------------------------------------------------------
  // Morning Grounding Routine Protocol (morning_routine_box)
  // ---------------------------------------------------------

  bool isMorningRoutineStepCompleted(int stepIndex, [String? dateKey]) {
    if (!_initialized) return false;
    final today = dateKey ?? DateTime.now().toIso8601String().split('T').first;
    return _morningRoutineBox.get('step_${stepIndex}_$today', defaultValue: false) as bool;
  }

  Future<void> setMorningRoutineStepCompleted(int stepIndex, bool completed, [String? dateKey]) async {
    if (!_initialized) return;
    final today = dateKey ?? DateTime.now().toIso8601String().split('T').first;
    await _morningRoutineBox.put('step_${stepIndex}_$today', completed);
    await _morningRoutineBox.flush();
  }

  bool isMorningRoutineCollapsed([String? dateKey]) {
    if (!_initialized) return false;
    final today = dateKey ?? DateTime.now().toIso8601String().split('T').first;
    return _morningRoutineBox.get('collapsed_$today', defaultValue: false) as bool;
  }

  Future<void> setMorningRoutineCollapsed(bool collapsed, [String? dateKey]) async {
    if (!_initialized) return;
    final today = dateKey ?? DateTime.now().toIso8601String().split('T').first;
    await _morningRoutineBox.put('collapsed_$today', collapsed);
    await _morningRoutineBox.flush();
  }

  int getCompletedMorningStepsCount([String? dateKey]) {
    int count = 0;
    if (isMorningRoutineStepCompleted(1, dateKey)) count++;
    if (isMorningRoutineStepCompleted(2, dateKey)) count++;
    if (isMorningRoutineStepCompleted(3, dateKey)) count++;
    return count;
  }

  Future<void> saveCognitionItem(CognitionItem item) async {
    if (!_initialized) return;
    await _cognitionItemsBox.put(item.id, item.toMap());
    await _cognitionItemsBox.flush();
  }

  Future<void> deleteCognitionItem(String id) async {
    if (!_initialized) return;
    await _cognitionItemsBox.delete(id);
    await _cognitionItemsBox.flush();
  }

  // ---------------------------------------------------------
  // Universal Categorized Reflections (Pillar 3: Cognition)
  // ---------------------------------------------------------

  List<ReflectionEntry> getAllReflections({
    ReflectionCategory? category,
    String? searchQuery,
  }) {
    if (!_initialized) return [];
    final list = <ReflectionEntry>[];
    for (final raw in _reflectionsBox.values) {
      try {
        final map = Map<String, dynamic>.from(raw);
        final entry = ReflectionEntry.fromMap(map);
        if (category != null && entry.category != category) continue;
        if (searchQuery != null && !entry.matchesQuery(searchQuery)) continue;
        list.add(entry);
      } catch (e) {
        debugPrint('[HiveStorage] Error parsing ReflectionEntry: $e');
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> saveReflection(ReflectionEntry entry) async {
    if (!_initialized) return;
    await _reflectionsBox.put(entry.id, entry.toMap());
    await _reflectionsBox.flush();
  }

  Future<void> deleteReflection(String id) async {
    if (!_initialized) return;
    await _reflectionsBox.delete(id);
    await _reflectionsBox.flush();
  }

  // ---------------------------------------------------------
  // Composure Counter (Today's 3-Second Pause Tally)
  // ---------------------------------------------------------

  /// Returns the number of successful 3-second pauses logged today.
  int getTodayComposureCount([String? dateKey]) {
    if (!_initialized) return 0;
    final today = dateKey ?? DateTime.now().toIso8601String().split('T').first;
    return _morningRoutineBox.get('composure_count_$today', defaultValue: 0) as int;
  }

  /// Increments today's composure pause count by 1.
  Future<void> incrementTodayComposureCount([String? dateKey]) async {
    if (!_initialized) return;
    final today = dateKey ?? DateTime.now().toIso8601String().split('T').first;
    final current = getTodayComposureCount(today);
    await _morningRoutineBox.put('composure_count_$today', current + 1);
    await _morningRoutineBox.flush();
  }
}



