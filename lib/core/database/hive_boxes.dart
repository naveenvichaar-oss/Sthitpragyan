/// Hive box identifiers used across Sthitaprajna.
abstract class HiveBoxes {
  /// Box containing all 3-Index evening journal debrief entries
  static const String journalEntries = 'sthitaprajna_journal_entries';

  /// Box containing streak calculations, history map, and records
  static const String streak = 'sthitaprajna_streak';

  /// Box containing user configurations, custom pinned scripts, and notification flags
  static const String settings = 'sthitaprajna_settings';

  /// Box containing saved or bookmarked defensive scripts
  static const String pinnedScripts = 'sthitaprajna_pinned_scripts';

  /// Box containing logged SOS defensive incidents
  static const String sosIncidents = 'sthitaprajna_sos_incidents';

  /// Box containing logged slip-up post-incident recovery events
  static const String incidentLogs = 'sthitaprajna_incident_logs';

  /// Box containing saved public-domain and user-added external resource links
  static const String resourceVault = 'sthitaprajna_resource_vault';

  /// Box containing user's daily affirmations and active wisdom selections
  static const String affirmations = 'sthitaprajna_affirmations';

  /// Box containing audio memos and video reflection recordings with stealth metadata
  static const String mediaVault = 'sthitaprajna_media_vault';

  /// Box containing personal anchors, serene music, visual reflections, and comfort words
  static const String joyReservoir = 'sthitaprajna_joy_reservoir';

  /// Box containing structured virtue & magnetic trait notes for personal gravitas
  static const String characterLedger = 'sthitaprajna_character_ledger';

  /// Box containing execution commitment blocks and action trigger configurations
  static const String executionTriggers = 'sthitaprajna_execution_triggers';

  /// Box containing imported offline HTML tools, interactive dashboards, and standalone calculators
  static const String htmlTools = 'sthitaprajna_html_tools';

  /// Box containing customizable and user-authored tactical defensive response scripts
  static const String defensiveScripts = 'sthitaprajna_defensive_scripts';
}
