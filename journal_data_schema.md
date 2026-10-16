# Local Storage Schema: 3-Index Journal & SOS Incident Telemetry

## 1. Overview
यह स्कीमा 100% ऑफलाइन, ज़ीरो-लीक और हाई-परफॉर्मेंस लोकल परसिस्टेंस के लिए डिज़ाइन किया गया है। इसे **Hive** (NoSQL Key-Value / TypeAdapter) या **SQLite/Drift** (Relational) दोनों में सीधे प्लग किया जा सकता है।

---

## 2. SQLite DDL (Relational Schema)

```sql
-- 1. Daily 3-Index Journal Table
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

CREATE INDEX IF NOT EXISTS idx_journal_date ON daily_journal_entries(entry_date);

-- 2. SOS Panic Shield Telemetry (For personal audit & pattern detection)
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

CREATE INDEX IF NOT EXISTS idx_sos_timestamp ON sos_incident_logs(timestamp);
```

---

## 3. Hive Data Models & TypeAdapters (Dart / Flutter)

```dart
import 'package:hive/hive.dart';

part 'journal_models.g.dart';

@HiveType(typeId: 1)
class DailyJournalEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String entryDate; // YYYY-MM-DD

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final int reactionControlScore; // 1 to 5

  @HiveField(4)
  final bool boundaryMaintained; // Yes / No

  @HiveField(5)
  final String coreOutputSummary; // Text description of the solid deliverable

  @HiveField(6)
  final String? provocationHandled; // Micro-reflection

  DailyJournalEntry({
    required this.id,
    required this.entryDate,
    required this.createdAt,
    required this.reactionControlScore,
    required this.boundaryMaintained,
    required this.coreOutputSummary,
    this.provocationHandled,
  });
}

@HiveType(typeId: 2)
class SosIncidentLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String threatType; // VagueCritique, Dominance, UnrealisticDeadline

  @HiveField(3)
  final String? scriptSelected;

  @HiveField(4)
  final bool lockCompleted;

  SosIncidentLog({
    required this.id,
    required this.timestamp,
    required this.threatType,
    this.scriptSelected,
    required this.lockCompleted,
  });
}
```

---

## 4. UI 60-Second Debrief Mapping

```
[SCREEN: 3-INDEX EVENING LOG]
 ├── Title: "दैनिक हिसाब (Daily Closure)"
 ├── Slider 1 (Reaction Score):
 │     Label: "आज उकसावे पर चित्त कितना स्थिर रहा?"
 │     Values: [1: भड़का | 2: तनाव में बोला | 3: न्यूट्रल रहा | 4: पूर्ण नियंत्रण | 5: स्थितप्रज्ञ]
 ├── Switch/Toggle (Boundary Check):
 │     Label: "क्या आज बिना सफाई दिए 'ना' कहने की मर्यादा बची रही?"
 │     Values: [हाँ / नहीं]
 ├── Single-Line Input (Output):
 │     Label: "आज का सबसे ठोस, मौलिक (Zero-AI) आउटपुट:"
 │     Placeholder: "उदा. कॉर्पोरेट टैक्स पर 800 शब्दों का एक्सक्लूसिव विश्लेषण"
 └── Action Button:
       Text: "हिसाब बंद करें (Lock Day)"
       OnClick: 
         - Save to Hive Box: 'journal_box'
         - Clear anxiety buffer
         - Flash: "आज का हिसाब पूरा हुआ। तनाव यहीं विसर्जित है।"
```
