# Sthitaprajna (स्थितप्रज्ञ) — Stoic Executive Shield

> **Ultra-minimalist, offline-first mobile shield for executives and engineers navigating workplace toxicity, passive aggression, and acute anxiety.**

---

## 🏛 Philosophy & Etymology

**Sthitaprajna** (*Sanskrit*: स्थितप्रज्ञ) denotes the person whose intellect is firmly rooted, immovable in the face of calamity, unelated by victory, immune to corporate toxicity, and anchored in tranquil clarity.

Combined with Roman Stoicism (*Marcus Aurelius, Seneca, Epictetus*), this app serves as a pocket **Executive Armor**:
- **Zero Cloud / Zero Telemetry**: 100% private. No trackers, no Firebase, no network pings. All data stays in encrypted, memory-mapped local storage via Hive.
- **Strict Dark Mode Only**: Designed with an austere Slate/Zinc palette (Zinc-950/Zinc-900) to minimize visual stimulation, lower cortisol, and deliver instant sub-100ms render speeds.
- **Tactile Physiological Anchoring**: Harnesses vagal nerve stimulation, synchronized 3-second breathing pacing, and haptic impact patterns to break the amygdala fight-or-flight cascade during hostile meetings.

---

## 📱 Core Features & Screens

### 1. Dashboard (The Command Center)
- **Big Floating "SOS Shield" Button**: Positioned centrally with a pulsing breathing glow and heavy tactile haptic response. One tap triggers immediate emergency equanimity (<50ms response).
- **Today's Core Rule Card**: Features daily actionable Stoic imperatives curated from Epictetus, Marcus Aurelius, Seneca, and the Bhagavad Gita, paired with direct corporate action directives (e.g., *"Wait 4 full seconds before answering any hostile question"*). Rules cycle deterministically by day-of-year or on demand.
- **Daily Streak Tracker**: Tracks consecutive days of evening audits, features a 7-day visual dot matrix, and reports your weekly Boundary Retention Index.
- **Evening Debrief Status Bar**: Real-time indicator showing if today's 60-second debrief is logged or pending.

### 2. SOS Screen (Emergency Equanimity Modal)
Triggered instantaneously by the SOS Shield button:
- **3-Second Breathing Pulse Visualizer**:
  - Paced cycle: **Inhale (3s)** $\rightarrow$ **Hold & Detach (3s)** $\rightarrow$ **Exhale Cortisol (3s)**.
  - Concentric pulsing rings with fluid easing curves and synchronized tactile haptic taps on each transition.
  - Grounding duration timer (*Seconds Grounded*).
- **Somatic Grounding Anchor**:
  - *"Feet flat on floor. Tongue on roof of mouth behind upper teeth. Drop shoulders 2 inches. Unclench jaw."*
  - Neuro-biological vagal stimulation rationale that halts adrenaline dumping.
- **Swipeable Defensive Response Scripts**:
  - Battle-tested, non-reactive executive deflections across 6 corporate hostility categories:
    1. *Interruption & Over-talking*
    2. *Gaslighting & Reality Inversion*
    3. *Blame Shifting & Scapegoating*
    4. *Passive Aggression & Sarcasm*
    5. *Scope Creep & Manufactured Urgency*
    6. *Emotional Baiting & Derailment*
  - Each card provides the **Hostile Trigger**, the verbatim **Executive Script**, the **Tactical Rationale**, **Tone Guidance**, and a one-touch **Copy to Clipboard** button.

### 3. 3-Index Journal (60-Second Evening Debrief)
Designed for high-tempo executives with zero tolerance for friction or rambling:
- **Index 01 — Reaction Control Slider (0.0 to 10.0)**:
  - *"How well did you refrain from impulsive emotional reactions when provoked?"*
  - Dynamic status indicator (*Absolute Sthitaprajna*, *High Executive Poise*, *Controlled Grounding*, *Internal Turbulence*, *Amygdala Hijacked*).
- **Index 02 — Boundary Retained Slider (0.0 to 10.0)**:
  - *"How firmly did you protect your calendar, personal hours, and professional scope?"*
  - Dynamic status indicator (*Impenetrable Fortress*, *Firm Professional Pushback*, *Contained Compromise*, *Permeable Perimeter*, *Total Boundary Breach*).
- **Index 03 — Core Output (Single-Line Text Input)**:
  - Strict single-line input capped at 140 characters. Prohibits rumination and forces the extraction of one decisive win, lesson, or boundary preserved today.
- **Audit History**: Chronological log of past debriefs with composite equanimity percentage calculations and instant deletion.

### 4. Cognition Vault (Intellectual Defense)
Expandable micro-cards partitioned into two strategic tabs:
- **Logical Fallacies in Corporate Warfare**:
  - *Ad Hominem (Personal Attack)*
  - *Strawman Distortion*
  - *False Dilemma / Hobson's Trap*
  - *Moving Goalposts*
  - *Kafka-Trapping*
  - *Sunk Cost Guilt-Trip*
  - *Motte-and-Bailey Maneuver*
  - Each card details the Latin origin, mechanism, boardroom trap, and the exact step-by-step **Counter-Move Protocol**.
- **Stoic Mental Models for Executive Equanimity**:
  - *Dichotomy of Control (Epictetus)*
  - *Premeditatio Malorum (Seneca)*
  - *The View from Above (Marcus Aurelius)*
  - *Amor Fati (Transmuting the Obstacle)*
  - *Cognitive Distancing / Solomon's Paradox*
  - *The Inner Citadel (Apatheia)*
  - Each card provides the Core Maxim, Workplace Manifestation, and a **30-Second Reset Drill**.
- **Instant Search & Filter Bar**: Real-time query execution across titles, Latin terms, mechanisms, and tags with zero perceptible latency (<5ms).

---

## ⏰ Scheduled Daily Notifications

Predefined local notification triggers scheduled directly into the device's exact alarm manager via `flutter_local_notifications` and `timezone`:

| Time | Title | Tactical Intent |
|---|---|---|
| **05:45 AM** | *Morning Premeditatio Malorum* | Armor your mind before the workday begins. Inoculates against difficult, deceptive, and arrogant individuals. |
| **09:30 AM** | *Pre-Battle Equanimity* | Dichotomy of Control checkpoint before the morning meeting onslaught. Reminds you to own only your pause and tone. |
| **02:00 PM** | *Physiological Cortisol Reset* | Midday vagal grounding reminder: tongue on roof of mouth, drop shoulders, disconnect urgency from panic. |
| **09:30 PM** | *60-Second Sthitaprajna Debrief* | Evening perimeter closure reminder: log your 3 indices and discharge corporate residue. |

> *A built-in Notification Tester panel allows executives to trigger and verify each of the 4 notifications immediately on-device.*

---

## 📐 Architecture & Project Structure

Organized following a clean, feature-first modular architecture:

```
lib/
├── main.dart                          # App bootstrap & offline services initialization
├── app.dart                           # MaterialApp root with pure dark theme configuration
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Slate/Zinc 950 palette & semantic signals
│   │   ├── app_dimens.dart            # Standardized dimensional grid & breakpoints
│   │   └── app_text_styles.dart       # Executive typography & monospace metrics
│   ├── database/
│   │   ├── hive_boxes.dart            # Local storage box constants
│   │   └── hive_storage.dart          # Typed, offline-first local storage engine
│   ├── notifications/
│   │   └── notification_service.dart  # 4 daily recurring triggers & test dispatches
│   ├── theme/
│   │   └── app_theme.dart             # Pure Dark ThemeData with zinc components
│   └── utils/
│       ├── date_helpers.dart          # Temporal keys, streak validation, formatting
│       └── haptic_service.dart        # Tactile haptic feedback patterns
├── features/
│   ├── dashboard/
│   │   ├── data/
│   │   │   ├── daily_rules_vault.dart # 10 curated Stoic executive rules & actions
│   │   │   └── models/
│   │   │       ├── daily_rule.dart
│   │   │       └── streak_data.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── dashboard_screen.dart
│   │       └── widgets/
│   │           ├── core_rule_card.dart
│   │           ├── executive_header.dart
│   │           ├── sos_shield_button.dart
│   │           └── streak_badge.dart
│   ├── sos/
│   │   ├── data/
│   │   │   └── defensive_scripts_vault.dart # 10+ categorized corporate defensive scripts
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── sos_modal_sheet.dart
│   │       └── widgets/
│   │           ├── breathing_pulse_visualizer.dart # 3s Inhale-Hold-Exhale animation
│   │           ├── grounding_banner.dart           # Vagus nerve physiological reminder
│   │           └── response_script_card.dart       # Swipeable verbatim script with copy
│   ├── journal/
│   │   ├── data/
│   │   │   ├── models/journal_entry.dart
│   │   │   └── repositories/journal_repository.dart
│   │   └── presentation/
│   │       ├── screens/journal_screen.dart
│   │       └── widgets/
│   │           ├── index_slider.dart
│   │           ├── past_debriefs_list.dart
│   │           └── single_line_output_input.dart
│   └── cognition_vault/
│       ├── data/
│       │   ├── cognition_data_source.dart
│       │   └── models/fallacy_and_model.dart
│       └── presentation/
│           ├── screens/cognition_vault_screen.dart
│           └── widgets/
│               ├── cognition_search_bar.dart
│               └── expandable_micro_card.dart
└── shared/
    └── widgets/
        ├── executive_notification_tester.dart # On-device notification inspection panel
        └── responsive_scaffold.dart          # Mobile BottomNav vs Tablet NavigationRail
```

---

## 💻 Responsive Layout (Mobile & Tablet)

- **Mobile Viewport (<680px)**: Compact, thumb-optimized interface with tactile bottom navigation bar and full-height modal bottom sheet for SOS triggers.
- **Tablet / Large Viewport ($\ge$680px)**: Adaptive horizontal layout with an executive `NavigationRail` on the left, persistent quick-access SOS shield button, and constrained 860px max-width body ensuring zero line-length fatigue on iPad, Samsung Tab, and foldable devices.

---

## 🚀 Running the App

### Prerequisites
- Flutter SDK `^3.10.0` or higher
- Android SDK (API 21+) or iOS (iOS 12+)

### Commands
```bash
# Get dependencies
flutter pub get

# Run all unit and integration tests
flutter test

# Run app on connected device or emulator
flutter run
```

---

## 🔒 Security & Privacy Guarantee
Sthitaprajna adheres strictly to the **Zero Telemetry Doctrine**:
- No user accounts required.
- No remote analytics or session tracking.
- No data leaves the physical device.
- Hive database files are stored locally in the application's private document directory.
