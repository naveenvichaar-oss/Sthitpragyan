/// SQLite DDL & Relational Schema definitions for Sthitaprajna.
/// Provides 100% offline, zero-telemetry schema for SQLite/Drift or encrypted backups.
abstract class SqliteSchema {
  static const String createDailyJournalTable = '''
CREATE TABLE IF NOT EXISTS daily_journal_entries (
    id TEXT PRIMARY KEY NOT NULL, -- UUID v4
    entry_date TEXT NOT NULL UNIQUE, -- Format: YYYY-MM-DD (Indexed)
    timestamp INTEGER NOT NULL, -- Unix Epoch Milliseconds
    
    -- Index 1: Reaction & Composure Score (1 = Lost control, 5 = Absolute Stoic)
    reaction_control_score INTEGER NOT NULL CHECK (reaction_control_score BETWEEN 1 AND 5),
    
    -- Index 2: Boundary Integrity Check (Did you say 'No' without over-explaining?)
    boundary_maintained INTEGER NOT NULL CHECK (boundary_maintained IN (0, 1)),
    
    -- Index 3: Core Solid Output (The human-crafted, high-impact deliverable)
    core_output_summary TEXT NOT NULL,
    
    -- Strategic Reflection (Optional 1-liner)
    provocation_handled TEXT,
    
    -- Metrics
    streak_count INTEGER DEFAULT 1,
    is_synced INTEGER DEFAULT 0 -- For optional encrypted backup
);
''';

  static const String createJournalDateIndex = '''
CREATE INDEX IF NOT EXISTS idx_journal_date ON daily_journal_entries(entry_date);
''';

  static const String createSosIncidentTable = '''
CREATE TABLE IF NOT EXISTS sos_incident_logs (
    id TEXT PRIMARY KEY NOT NULL,
    timestamp INTEGER NOT NULL,
    day_of_week TEXT NOT NULL,
    
    -- Category of Threat Trigger
    threat_type TEXT NOT NULL, -- 'VagueCritique', 'Dominance', 'ImpossibleDeadline', 'Other'
    
    -- Which script was copied or selected
    script_selected TEXT,
    
    -- Did user wait out the full 3-second mandatory lock?
    lock_completed INTEGER NOT NULL CHECK (lock_completed IN (0, 1)),
    
    -- Outcome noted by user
    outcome_rating INTEGER CHECK (outcome_rating BETWEEN 1 AND 5)
);
''';

  static const String createSosTimestampIndex = '''
CREATE INDEX IF NOT EXISTS idx_sos_timestamp ON sos_incident_logs(timestamp);
''';
}
