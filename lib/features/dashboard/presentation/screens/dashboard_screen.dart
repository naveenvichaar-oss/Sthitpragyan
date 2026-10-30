import 'package:flutter/material.dart';

import 'package:sthitaprajna/core/constants/app_colors.dart';
import 'package:sthitaprajna/core/constants/app_dimens.dart';
import 'package:sthitaprajna/core/constants/app_text_styles.dart';
import 'package:sthitaprajna/core/database/hive_storage.dart';
import 'package:sthitaprajna/core/localization/app_localizations.dart';
import 'package:sthitaprajna/core/notifications/notification_service.dart';
import 'package:sthitaprajna/core/notifications/notifications_dataset_service.dart';
import 'package:sthitaprajna/core/utils/haptic_service.dart';
import 'package:sthitaprajna/features/dashboard/data/daily_rules_vault.dart';
import 'package:sthitaprajna/features/dashboard/data/models/daily_rule.dart';
import 'package:sthitaprajna/features/dashboard/data/models/streak_data.dart';
import 'package:sthitaprajna/features/dashboard/presentation/widgets/core_rule_card.dart';
import 'package:sthitaprajna/features/dashboard/presentation/widgets/executive_header.dart';
import 'package:sthitaprajna/features/dashboard/presentation/widgets/streak_badge.dart';
import 'package:sthitaprajna/features/execution_trigger/presentation/screens/execution_trigger_screen.dart';
import 'package:sthitaprajna/features/execution_trigger/presentation/widgets/micro_ignition_timer_dialog.dart';
import 'package:sthitaprajna/features/journal/data/models/journal_models.dart';
import 'package:sthitaprajna/features/journal/data/models/reflection_entry.dart';
import 'package:sthitaprajna/features/journal/data/repositories/journal_repository.dart';
import 'package:sthitaprajna/features/joy_reservoir/data/models/joy_item.dart';
import 'package:sthitaprajna/features/joy_reservoir/data/services/joy_audio_service.dart';
import 'package:sthitaprajna/features/joy_reservoir/presentation/screens/joy_reservoir_screen.dart';
import 'package:sthitaprajna/features/joy_reservoir/presentation/widgets/add_joy_item_modal_sheet.dart';
import 'package:sthitaprajna/features/wisdom/utils/resource_launcher_service.dart';
import 'package:sthitaprajna/core/services/gong_audio_service.dart';
import 'package:sthitaprajna/core/utils/date_helpers.dart';
import 'package:sthitaprajna/features/settings/presentation/screens/settings_screen.dart';
import 'package:sthitaprajna/features/sos/presentation/screens/sos_modal_sheet.dart';
import 'package:sthitaprajna/shared/widgets/voice_dictation_button.dart';

/// DashboardScreen serves as the command center for Sthitaprajna.
/// Features:
/// 1. Minimalist dark theme (Zinc-950/900)
/// 2. Big floating "SOS Shield" button at the center
/// 3. Daily quote/rule from notifications_dataset.json (and Stoic rules)
/// 4. Direct navigation to 3-Index Journal, Cognition Vault, and Settings
class DashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToJournal;
  final VoidCallback? onNavigateToVault;
  final void Function(int segmentIndex)? onNavigateToVaultSegment;
  final VoidCallback? onNavigateToSettings;
  final VoidCallback? onNavigateToSos;

  const DashboardScreen({
    super.key,
    required this.onNavigateToJournal,
    this.onNavigateToVault,
    this.onNavigateToVaultSegment,
    this.onNavigateToSettings,
    this.onNavigateToSos,
  });

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final JournalRepository _journalRepo = JournalRepository();
  final HiveStorage _storage = HiveStorage();
  final TextEditingController _focusInputController = TextEditingController();
  final TextEditingController _distractionInputController = TextEditingController();
  bool _isEditingFocus = false;

  // Morning Grounding Routine Protocol State (morning_routine_box)
  bool _step1Completed = false;
  bool _step2Completed = false;
  bool _step3Completed = false;
  bool _isMorningRoutineCollapsed = false;

  // Morning Grounding Commitments State
  bool _pauseRuleCommitted = false;
  bool _unapologeticNoCommitted = false;

  // Night Debrief State
  int _debriefReactionScore = 4;
  bool _debriefBoundaryMaintained = true;
  final TextEditingController _debriefDecisionController = TextEditingController();
  bool _isEditingDebrief = false;

  late DailyRule _currentRule;
  int _activeRuleIndex = 0;

  List<NotificationTrigger> _todayTriggers = [];
  int _activeTriggerIndex = 0;

  StreakData _streakData = const StreakData(
    currentStreak: 0,
    longestStreak: 0,
    historyMap: {},
  );
  DailyJournalEntry? _todayEntry;

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  @override
  void dispose() {
    _focusInputController.dispose();
    _distractionInputController.dispose();
    _debriefDecisionController.dispose();
    super.dispose();
  }

  void _initDashboard() {
    _activeRuleIndex = _storage.getActiveRuleIndex();
    _currentRule = DailyRulesVault.getTodayRule(_activeRuleIndex);

    _todayTriggers = NotificationsDatasetService().getTodayTriggers();
    if (_todayTriggers.isEmpty) {
      _todayTriggers = NotificationService.defaultTriggers;
    }

    _step1Completed = _storage.isMorningRoutineStepCompleted(1);
    _step2Completed = _storage.isMorningRoutineStepCompleted(2);
    _step3Completed = _storage.isMorningRoutineStepCompleted(3);
    _isMorningRoutineCollapsed = _storage.isMorningRoutineCollapsed();

    _pauseRuleCommitted = _storage.isTodayPauseRuleCommitted();
    _unapologeticNoCommitted = _storage.isTodayUnapologeticNoCommitted();

    refreshData();
  }

  /// Exposed method to refresh dashboard metrics when tab switches or debrief saves
  void refreshData() {
    if (!mounted) return;
    setState(() {
      _streakData = _journalRepo.getStreakData();
      _todayEntry = _journalRepo.getTodayEntry();

      _step1Completed = _storage.isMorningRoutineStepCompleted(1);
      _step2Completed = _storage.isMorningRoutineStepCompleted(2);
      _step3Completed = _storage.isMorningRoutineStepCompleted(3);
      _isMorningRoutineCollapsed = _storage.isMorningRoutineCollapsed();

      _pauseRuleCommitted = _storage.isTodayPauseRuleCommitted();
      _unapologeticNoCommitted = _storage.isTodayUnapologeticNoCommitted();

      if (_todayEntry != null) {
        if (!_isEditingFocus) {
          _focusInputController.text = _todayEntry!.coreOutputSummary;
          _distractionInputController.text = _todayEntry!.provocationHandled ?? '';
        }
        if (!_isEditingDebrief) {
          _debriefReactionScore = _todayEntry!.reactionControlScore;
          _debriefBoundaryMaintained = _todayEntry!.boundaryMaintained;
          _debriefDecisionController.text = _todayEntry!.coreOutputSummary;
        }
      }
      _todayTriggers = NotificationsDatasetService().getTodayTriggers();
      if (_todayTriggers.isEmpty) {
        _todayTriggers = NotificationService.defaultTriggers;
      }
    });
  }

  void _cycleNextRule() {
    final nextRule = DailyRulesVault.getNextRule(_currentRule.id - 1);
    setState(() {
      _currentRule = nextRule;
      _activeRuleIndex = nextRule.id - 1;
    });
    _storage.setActiveRuleIndex(_activeRuleIndex);
  }

  void _cycleNextDatasetTrigger() {
    if (_todayTriggers.isNotEmpty) {
      setState(() {
        _activeTriggerIndex = (_activeTriggerIndex + 1) % _todayTriggers.length;
      });
    }
  }


  void _openNotificationSettings() {
    HapticService.selectionClick();
    if (widget.onNavigateToSettings != null) {
      widget.onNavigateToSettings!();
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDebriefCompleted = _todayEntry != null;
    final currentTrigger = _todayTriggers.isNotEmpty
        ? _todayTriggers[_activeTriggerIndex % _todayTriggers.length]
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            // 1. Executive Brand & Date Header
            ExecutiveHeader(onSettingsTap: _openNotificationSettings),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 5-Minute Kickstart Timer (minimal top bar)
                  _buildTopKickstartBar(),
                  const SizedBox(height: 12),

                  // Joy Box (Soul Sanctuary / जॉय बॉक्स) - Promoted to the very top!
                  _buildJoyReservoirCard(),
                  const SizedBox(height: 12),

                  // 1. Morning Grounding Protocol Card (05:30 – 07:00 AM)
                  _buildMorningGroundingCard(),
                  const SizedBox(height: 12),

                  // 2. Day Focus Block (09:30 AM) with Single Task & 5-Min Kickstart
                  _buildDailyFocusCard(),
                  const SizedBox(height: 12),

                  // 3. Daily Focus Blocks (Customizable user schedules with chime)
                  _buildDailyBlocksCard(),
                  const SizedBox(height: 12),

                  // 4. SOS Trigger (Calming box breathing)
                  _buildSOSTriggerCard(),
                  const SizedBox(height: 14),

                  // 6. Unified Daily Wisdom & Trigger Card (My Day Today, Wisdom of the Day, Core Stoic Rule)
                  CoreRuleCard(
                    datasetTrigger: currentTrigger,
                    rule: _currentRule,
                    onNextRule: _cycleNextRule,
                    onNextDatasetTrigger: _cycleNextDatasetTrigger,
                    onOpenVault: widget.onNavigateToVault,
                    onTriggerUpdated: (_) => refreshData(),
                  ),
                  const SizedBox(height: 14),

                  // 7. Daily Streak Tracker Card
                  StreakBadge(streakData: _streakData),
                  const SizedBox(height: 14),

                  // 8. Night Debrief Card (09:30 - 10:30 PM with 3 Stoic Questions)
                  _buildNightDebriefCard(isDebriefCompleted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // PILLAR 1: 5-Minute Kickstart Timer (Minimal Top Bar)
  // -------------------------------------------------------------
  Widget _buildTopKickstartBar() {
    return GestureDetector(
      onTap: () {
        HapticService.mediumImpact();
        final currentTask = _todayEntry?.coreOutputSummary.isNotEmpty == true
            ? _todayEntry!.coreOutputSummary
            : (_focusInputController.text.trim().isNotEmpty
                ? _focusInputController.text.trim()
                : null);
        MicroIgnitionTimerDialog.show(context, initialTask: currentTask);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
          border: Border.all(
            color: AppColors.shieldPrimary.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.shieldPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.timer_outlined,
                size: 16,
                color: AppColors.shieldPrimary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        context.loc.kickstartTimerBadge,
                        style: AppTextStyles.labelBadge.copyWith(
                          color: AppColors.shieldPrimary,
                          fontSize: 9.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.loc.kickstartFrictionBreaker,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    context.loc.kickstartDescription,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.shieldPrimary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow_rounded, size: 14, color: AppColors.background),
                  const SizedBox(width: 2),
                  Text(
                    context.loc.kickstartStart,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.background,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // PILLAR 1: Morning Grounding Protocol Card (05:30 – 07:00 AM)
  // -------------------------------------------------------------
  Widget _buildMorningGroundingCard() {
    final completedSteps = (_step1Completed ? 1 : 0) +
        (_step2Completed ? 1 : 0) +
        (_step3Completed ? 1 : 0);
    final allStepsCompleted = completedSteps == 3;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: allStepsCompleted
              ? AppColors.emeraldSuccess.withValues(alpha: 0.4)
              : const Color(0xFFF59E0B).withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row (Tap to expand/collapse)
          InkWell(
            onTap: () async {
              HapticService.selectionClick();
              final nextState = !_isMorningRoutineCollapsed;
              await _storage.setMorningRoutineCollapsed(nextState);
              setState(() => _isMorningRoutineCollapsed = nextState);
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (allStepsCompleted
                              ? AppColors.emeraldSuccess
                              : const Color(0xFFF59E0B))
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      allStepsCompleted
                          ? Icons.verified_rounded
                          : Icons.wb_sunny_rounded,
                      size: 18,
                      color: allStepsCompleted
                          ? AppColors.emeraldSuccess
                          : const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.loc.morningGroundingHeaderTitle,
                      style: AppTextStyles.heading.copyWith(fontSize: 13.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: allStepsCompleted
                          ? AppColors.emeraldSuccess.withValues(alpha: 0.15)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      context.loc.stepsCompletedFraction(completedSteps, 3),
                      style: TextStyle(
                        fontSize: 9.0,
                        fontWeight: FontWeight.w700,
                        color: allStepsCompleted
                            ? AppColors.emeraldSuccess
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isMorningRoutineCollapsed
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 2. Core Neuro-Protocol Banner (Always Visible on Card)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.shield_rounded,
                    size: 15,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.loc.coreNeuroProtocolBadge,
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF59E0B),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '“${context.loc.morningNeuroProtocolBanner}”',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Expandable Action Anchors & Commitments Section
          if (!_isMorningRoutineCollapsed) ...[
            const SizedBox(height: 12),
            Text(
              context.loc.actionAnchorsHeader,
              style: AppTextStyles.labelBadge.copyWith(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            // Step 1: Zero Digital Screen (0–15 Min)
            _buildActionAnchorRow(
              stepNumber: 1,
              title: context.loc.morningStep1Title,
              desc: context.loc.morningStep1Desc,
              isCompleted: _step1Completed,
              onToggle: (val) async {
                await _storage.setMorningRoutineStepCompleted(1, val);
                setState(() => _step1Completed = val);
              },
            ),
            const SizedBox(height: 6),

            // Step 2: Brisk Walk & Socratic Dialogue (15 Min)
            _buildActionAnchorRow(
              stepNumber: 2,
              title: context.loc.morningStep2Title,
              desc: context.loc.morningStep2Desc,
              isCompleted: _step2Completed,
              onToggle: (val) async {
                await _storage.setMorningRoutineStepCompleted(2, val);
                setState(() => _step2Completed = val);
              },
            ),
            const SizedBox(height: 6),

            // Step 3: The Anchor of Calm (Tea Time)
            _buildActionAnchorRow(
              stepNumber: 3,
              title: context.loc.morningStep3Title,
              desc: context.loc.morningStep3Desc,
              isCompleted: _step3Completed,
              onToggle: (val) async {
                await _storage.setMorningRoutineStepCompleted(3, val);
                setState(() => _step3Completed = val);
              },
            ),
            const SizedBox(height: 10),

            // Foundational Mental Commitments
            _buildGroundingRuleRow(
              title: context.loc.pauseRuleTitle,
              desc: context.loc.pauseRuleDesc,
              isCommitted: _pauseRuleCommitted,
              onToggle: (val) async {
                HapticService.selectionClick();
                await _storage.setTodayPauseRuleCommitted(val);
                setState(() => _pauseRuleCommitted = val);
              },
            ),
            const SizedBox(height: 6),

            _buildGroundingRuleRow(
              title: context.loc.unapologeticNoTitle,
              desc: context.loc.unapologeticNoDesc,
              isCommitted: _unapologeticNoCommitted,
              onToggle: (val) async {
                HapticService.selectionClick();
                await _storage.setTodayUnapologeticNoCommitted(val);
                setState(() => _unapologeticNoCommitted = val);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionAnchorRow({
    required int stepNumber,
    required String title,
    required String desc,
    required bool isCompleted,
    required ValueChanged<bool> onToggle,
  }) {
    return InkWell(
      onTap: () {
        HapticService.selectionClick();
        onToggle(!isCompleted);
      },
      borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
          border: Border.all(
            color: isCompleted
                ? AppColors.emeraldSuccess.withValues(alpha: 0.35)
                : AppColors.borderSubtle,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                isCompleted
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: 18,
                color: isCompleted ? AppColors.emeraldSuccess : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroundingRuleRow({
    required String title,
    required String desc,
    required bool isCommitted,
    required ValueChanged<bool> onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        border: Border.all(
          color: isCommitted
              ? AppColors.emeraldSuccess.withValues(alpha: 0.3)
              : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCommitted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 14,
                      color: isCommitted ? AppColors.emeraldSuccess : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isCommitted ? AppColors.emeraldSuccess : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.72,
            child: Switch(
              value: isCommitted,
              activeThumbColor: AppColors.emeraldSuccess,
              onChanged: onToggle,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // PILLAR 1: Day Focus Block (09:30 AM) — Single Task + Kickstart
  // -------------------------------------------------------------
  Widget _buildDailyFocusCard() {
    final hasFocus = _todayEntry != null &&
        _todayEntry!.coreOutputSummary.trim().isNotEmpty;
    final isEditing = _isEditingFocus || !hasFocus;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: hasFocus
              ? AppColors.shieldPrimary.withValues(alpha: 0.35)
              : AppColors.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  size: 16,
                  color: AppColors.shieldPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.loc.index03Title,
                  style: AppTextStyles.heading.copyWith(fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(
                  context.loc.dayFocusTimeBadge,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.shieldPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  HapticService.mediumImpact();
                  final currentTask = _todayEntry?.coreOutputSummary.isNotEmpty == true
                      ? _todayEntry!.coreOutputSummary
                      : (_focusInputController.text.trim().isNotEmpty
                          ? _focusInputController.text.trim()
                          : null);
                  MicroIgnitionTimerDialog.show(context, initialTask: currentTask);
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.shieldPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.shieldPrimary.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 12, color: AppColors.shieldPrimary),
                      const SizedBox(width: 3),
                      Text(
                        context.loc.fiveMinKickstart,
                        style: const TextStyle(
                          fontSize: 9.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.shieldPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (hasFocus && !_isEditingFocus) ...[
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    HapticService.selectionClick();
                    setState(() {
                      _isEditingFocus = true;
                      _focusInputController.text = _todayEntry!.coreOutputSummary;
                      _distractionInputController.text =
                          _todayEntry!.provocationHandled ?? '';
                    });
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          if (isEditing) ...[
            Text(
              context.loc.index03OutputQuestion,
              style: AppTextStyles.labelBadge.copyWith(
                color: AppColors.shieldPrimary,
                fontSize: 9.0,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _focusInputController,
              maxLines: 1,
              maxLength: 140,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: context.loc.index03OutputHint,
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11.5,
                ),
                counterStyle: AppTextStyles.metricSmall.copyWith(fontSize: 8.5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.loc.index03ProvocationQuestion,
              style: AppTextStyles.labelBadge.copyWith(
                color: const Color(0xFF10B981),
                fontSize: 9.0,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _distractionInputController,
              maxLines: 1,
              maxLength: 140,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: context.loc.index03ProvocationHint,
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11.5,
                ),
                counterStyle: AppTextStyles.metricSmall.copyWith(fontSize: 8.5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              onSubmitted: (_) => _saveDailyFocus(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (hasFocus)
                  TextButton(
                    onPressed: () {
                      HapticService.selectionClick();
                      setState(() {
                        _isEditingFocus = false;
                        _focusInputController.text = _todayEntry!.coreOutputSummary;
                        _distractionInputController.text =
                            _todayEntry!.provocationHandled ?? '';
                      });
                    },
                    child: Text(
                      context.loc.cancel,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _saveDailyFocus,
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text(
                    context.loc.save,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.shieldPrimary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppColors.emeraldSuccess,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _todayEntry!.coreOutputSummary,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_todayEntry!.provocationHandled != null &&
                _todayEntry!.provocationHandled!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.loc.distractionAvoidedLabel,
                            style: AppTextStyles.labelBadge.copyWith(
                              fontSize: 8.5,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _todayEntry!.provocationHandled!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticService.mediumImpact();
                  MicroIgnitionTimerDialog.show(
                    context,
                    initialTask: _todayEntry!.coreOutputSummary,
                  );
                },
                icon: const Icon(Icons.timer_outlined, size: 14),
                label: Text(
                  context.loc.fiveMinKickstart,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.shieldPrimary,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _saveDailyFocus() async {
    final text = _focusInputController.text.trim();
    if (text.isEmpty) {
      HapticService.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.enterFocusPrompt,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFD97706),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    final distraction = _distractionInputController.text.trim();
    HapticService.selectionClick();

    final now = DateTime.now();
    final todayKey = DateHelpers.toStorageKey(now);
    final entry = _todayEntry != null
        ? DailyJournalEntry(
            id: _todayEntry!.id,
            entryDate: _todayEntry!.entryDate,
            createdAt: _todayEntry!.createdAt,
            reactionControlScore: _todayEntry!.reactionControlScore,
            boundaryMaintained: _todayEntry!.boundaryMaintained,
            coreOutputSummary: text,
            provocationHandled: distraction.isEmpty ? null : distraction,
            audioMemoPath: _todayEntry!.audioMemoPath,
            videoReflectionPath: _todayEntry!.videoReflectionPath,
          )
        : DailyJournalEntry(
            id: 'entry_$todayKey',
            entryDate: todayKey,
            createdAt: now,
            reactionControlScore: 4,
            boundaryMaintained: true,
            coreOutputSummary: text,
            provocationHandled: distraction.isEmpty ? null : distraction,
          );

    await _journalRepo.saveEntry(entry);
    if (mounted) {
      setState(() {
        _todayEntry = entry;
        _isEditingFocus = false;
      });
      HapticService.success();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.focusSavedNotice,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.emeraldSuccess,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // -------------------------------------------------------------
  // PILLAR 1: SOS Trigger (Calming Box Breathing)
  // -------------------------------------------------------------
  Widget _buildSOSTriggerCard() {
    return GestureDetector(
      onTap: () {
        HapticService.heavyImpact();
        if (widget.onNavigateToSos != null) {
          widget.onNavigateToSos!();
        } else {
          SOSModalSheet.show(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.space12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          border: Border.all(
            color: AppColors.roseDanger.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.roseDanger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shield_rounded,
                size: 20,
                color: AppColors.roseDanger,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        context.loc.sosEmergencyBadge,
                        style: AppTextStyles.labelBadge.copyWith(
                          color: AppColors.roseDanger,
                          fontSize: 8.5,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.loc.boxBreathingDrillCardTitle,
                    style: AppTextStyles.heading.copyWith(fontSize: 13.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.loc.boxBreathingDrillCardSub,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                HapticService.heavyImpact();
                if (widget.onNavigateToSos != null) {
                  widget.onNavigateToSos!();
                } else {
                  SOSModalSheet.show(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.roseDanger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(
                context.loc.calmButtonLabel,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // PILLAR 1: Daily Focus Blocks (Customizable schedules with chime)
  // -------------------------------------------------------------
  Widget _buildDailyBlocksCard() {
    final blocks = _storage
        .getAllExecutionTriggers()
        .where((t) => t.id != 'block_morning_grounding' && t.timeOfDay != '06:00')
        .toList();

    return Container(
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    context.loc.dailyFocusBlocks,
                    style: AppTextStyles.heading.copyWith(fontSize: 13.5),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  HapticService.selectionClick();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ExecutionTriggerScreen(),
                    ),
                  ).then((_) => setState(() {}));
                },
                child: Text(
                  context.loc.manageActionLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (blocks.isEmpty) ...[
            Text(
              context.loc.noDailyBlocksSub,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
                fontSize: 11.5,
              ),
            ),
          ] else ...[
            ...blocks.take(3).map((trigger) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Text(
                        trigger.timeOfDay,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trigger.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: trigger.isEnabled
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_active_outlined,
                        size: 15,
                        color: Color(0xFF10B981),
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      onPressed: () {
                        HapticService.mediumImpact();
                        GongAudioService().playDeepGong();
                      },
                    ),
                    Transform.scale(
                      scale: 0.68,
                      child: Switch(
                        value: trigger.isEnabled,
                        activeThumbColor: const Color(0xFF10B981),
                        onChanged: (val) {
                          HapticService.selectionClick();
                          _storage.saveExecutionTrigger(
                            trigger.copyWith(isEnabled: val),
                          );
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // 7. Joy Box (Soul Sanctuary / जॉय बॉक्स) Full Function Card
  Widget _buildJoyReservoirCard() {
    final joyItems = _storage.getAllJoyItems();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: const Color(0xFFF43F5E).withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Tapping header opens full JoyReservoirScreen)
          InkWell(
            onTap: () {
              HapticService.selectionClick();
              JoyReservoirScreen.open(context).then((_) {
                if (mounted) setState(() {});
              });
            },
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusMedium),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      size: 18,
                      color: Color(0xFFF43F5E),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              context.loc.joyBoxTitle,
                              style: AppTextStyles.heading.copyWith(fontSize: 13.5),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                context.loc.joyAnchorsCount(joyItems.length),
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFF43F5E),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          context.loc.joyBoxSubtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Header Quick Buttons
                  IconButton(
                    icon: const Icon(Icons.audio_file_rounded, size: 20, color: AppColors.shieldPrimary),
                    tooltip: context.loc.addAudioFileTooltip,
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      HapticService.selectionClick();
                      AddJoyItemModalSheet.show(
                        context,
                        initialCategory: JoyCategory.music,
                        onSaved: () => setState(() {}),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 20, color: AppColors.shieldPrimary),
                    tooltip: context.loc.addJoyAnchorTooltip,
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      HapticService.selectionClick();
                      AddJoyItemModalSheet.show(
                        context,
                        onSaved: () => setState(() {}),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.textMuted),
                    tooltip: context.loc.openFullSanctuaryTooltip,
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      HapticService.selectionClick();
                      JoyReservoirScreen.open(context).then((_) {
                        if (mounted) setState(() {});
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Divider(
              color: AppColors.borderSubtle.withValues(alpha: 0.5),
              height: 1,
            ),
          ),

          // 2. Body: Either empty state with quick actions OR horizontal carousel of items
          if (joyItems.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.loc.emptyJoyReservoirDesc,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticService.selectionClick();
                            AddJoyItemModalSheet.show(
                              context,
                              initialCategory: JoyCategory.music,
                              onSaved: () => setState(() {}),
                            );
                          },
                          icon: const Icon(Icons.audio_file_rounded, size: 14),
                          label: Text(
                            context.loc.selectLocalAudioButton,
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.shieldPrimary,
                            side: const BorderSide(color: AppColors.shieldPrimary, width: 0.8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticService.selectionClick();
                            AddJoyItemModalSheet.show(
                              context,
                              initialCategory: JoyCategory.music,
                              onSaved: () => setState(() {}),
                            );
                          },
                          icon: const Icon(Icons.music_note_rounded, size: 14),
                          label: Text(
                            context.loc.addMusicLinkButton,
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF43F5E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: AnimatedBuilder(
                animation: JoyAudioService(),
                builder: (context, _) {
                  return SizedBox(
                    height: 82,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: joyItems.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        if (index == joyItems.length) {
                          // "+ Add More" trailing card
                          return InkWell(
                            onTap: () {
                              HapticService.selectionClick();
                              AddJoyItemModalSheet.show(
                                context,
                                onSaved: () => setState(() {}),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.borderSubtle,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_rounded, size: 20, color: AppColors.shieldPrimary),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.loc.addTextButton,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final item = joyItems[index];
                        final isPlayingThis = JoyAudioService().isPlaying(item.id);
                        final isLocal = item.isLocalAudio;
                        final isYt = item.isYouTube;

                        return Container(
                          width: 170,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isPlayingThis
                                ? AppColors.emeraldSuccess.withValues(alpha: 0.12)
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isPlayingThis
                                  ? AppColors.emeraldSuccess
                                  : item.category.accentColor.withValues(alpha: 0.3),
                              width: isPlayingThis ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    item.category.iconData,
                                    size: 13,
                                    color: item.category.accentColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isPlayingThis ? AppColors.emeraldSuccess : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isLocal
                                        ? (isPlayingThis
                                            ? context.loc.playingStatus
                                            : context.loc.localAudioStatus)
                                        : (isYt
                                            ? 'YouTube'
                                            : item.category.badgeLabel),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: isPlayingThis ? AppColors.emeraldSuccess : AppColors.textMuted,
                                    ),
                                  ),
                                  if (isLocal)
                                    InkWell(
                                      onTap: () async {
                                        HapticService.selectionClick();
                                        if (isPlayingThis) {
                                          await JoyAudioService().pause();
                                        } else {
                                          await JoyAudioService().playLocal(
                                            joyId: item.id,
                                            filePath: item.mediaUrlOrPath!,
                                          );
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isPlayingThis
                                              ? AppColors.emeraldSuccess
                                              : AppColors.shieldPrimary,
                                        ),
                                        child: Icon(
                                          isPlayingThis
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          size: 16,
                                          color: AppColors.background,
                                        ),
                                      ),
                                    )
                                  else if (item.mediaUrlOrPath != null && item.mediaUrlOrPath!.isNotEmpty)
                                    InkWell(
                                      onTap: () {
                                        HapticService.selectionClick();
                                        ResourceLauncherService.openUrl(
                                          context,
                                          url: item.mediaUrlOrPath!,
                                          title: item.title,
                                          category: item.category.displayName,
                                          notes: item.note,
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: item.category.accentColor.withValues(alpha: 0.2),
                                        ),
                                        child: Icon(
                                          Icons.open_in_new_rounded,
                                          size: 14,
                                          color: item.category.accentColor,
                                        ),
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.favorite_rounded,
                                      size: 14,
                                      color: const Color(0xFFF43F5E).withValues(alpha: 0.6),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // Bottom action link
            InkWell(
              onTap: () {
                HapticService.selectionClick();
                JoyReservoirScreen.open(context).then((_) {
                  if (mounted) setState(() {});
                });
              },
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppDimens.radiusMedium),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.loc.viewAllAnchorsAction(joyItems.length),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.shieldPrimary,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: AppColors.shieldPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }


  // -------------------------------------------------------------
  // PILLAR 1: Night Debrief Card (09:30 - 10:30 PM with 3 Stoic Questions)
  // -------------------------------------------------------------
  Widget _buildNightDebriefCard(bool isCompleted) {
    final showEditor = !isCompleted || _isEditingDebrief;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: isCompleted
              ? AppColors.emeraldSuccess.withValues(alpha: 0.35)
              : const Color(0xFF6366F1).withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (isCompleted ? AppColors.emeraldSuccess : const Color(0xFF6366F1))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle_rounded : Icons.nights_stay_rounded,
                  size: 18,
                  color: isCompleted ? AppColors.emeraldSuccess : const Color(0xFF818CF8),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.loc.nightDebriefTitle,
                      style: AppTextStyles.heading.copyWith(fontSize: 13.5),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      context.loc.nightDebriefDesc,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(
                  context.loc.nightDebriefTime,
                  style: const TextStyle(
                    fontSize: 9.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF818CF8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (!showEditor) ...[
            // Read-only completed summary view
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Q1 Result
                  Row(
                    children: [
                      const Icon(Icons.psychology_outlined, size: 14, color: AppColors.shieldPrimary),
                      const SizedBox(width: 6),
                      Text(
                        context.loc.composureScoreLabel,
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 9.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.shieldPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_todayEntry!.reactionControlScore} / 5',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.shieldPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Q2 Result
                  Row(
                    children: [
                      Icon(
                        _todayEntry!.boundaryMaintained
                            ? Icons.verified_user_rounded
                            : Icons.warning_amber_rounded,
                        size: 14,
                        color: _todayEntry!.boundaryMaintained
                            ? AppColors.emeraldSuccess
                            : AppColors.amberWarning,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.loc.boundaryLabel,
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 9.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _todayEntry!.boundaryMaintained
                            ? context.loc.stoicQ2Maintained
                            : context.loc.stoicQ2Compromised,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _todayEntry!.boundaryMaintained
                              ? AppColors.emeraldSuccess
                              : AppColors.amberWarning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Q3 Result
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.lightbulb_outline_rounded, size: 14, color: Color(0xFFF59E0B)),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.loc.rationalDecisionCoreOutputLabel,
                              style: AppTextStyles.labelBadge.copyWith(
                                fontSize: 9.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _todayEntry!.coreOutputSummary,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Action row for completed debrief
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    HapticService.selectionClick();
                    setState(() {
                      _isEditingDebrief = true;
                      _debriefReactionScore = _todayEntry!.reactionControlScore;
                      _debriefBoundaryMaintained = _todayEntry!.boundaryMaintained;
                      _debriefDecisionController.text = _todayEntry!.coreOutputSummary;
                    });
                  },
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: Text(
                    context.loc.editDebriefButton,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: widget.onNavigateToJournal,
                  icon: const Icon(Icons.auto_stories_rounded, size: 14),
                  label: Text(
                    context.loc.cognitionTimelineAction,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ] else ...[
            // Inline Interactive Form for 3 Stoic Questions

            // Question 1: Reaction score 1-5
            Text(
              context.loc.stoicQ1Header,
              style: AppTextStyles.labelBadge.copyWith(
                color: const Color(0xFF818CF8),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              context.loc.composureScoreScaleSub,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: List.generate(5, (index) {
                final score = index + 1;
                final isSelected = _debriefReactionScore == score;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index < 4 ? 6.0 : 0),
                    child: InkWell(
                      onTap: () {
                        HapticService.selectionClick();
                        setState(() => _debriefReactionScore = score);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF818CF8)
                                : AppColors.borderSubtle,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$score', // Strictly Western Arabic 1, 2, 3, 4, 5
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),

            // Question 2: Boundary Maintained vs Excuses/Complaints
            Text(
              context.loc.stoicQ2Header,
              style: AppTextStyles.labelBadge.copyWith(
                color: const Color(0xFF818CF8),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticService.selectionClick();
                      setState(() => _debriefBoundaryMaintained = true);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: _debriefBoundaryMaintained
                            ? AppColors.emeraldSuccess.withValues(alpha: 0.15)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _debriefBoundaryMaintained
                              ? AppColors.emeraldSuccess
                              : AppColors.borderSubtle,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: _debriefBoundaryMaintained
                                ? AppColors.emeraldSuccess
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              context.loc.stoicQ2Maintained,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: _debriefBoundaryMaintained
                                    ? AppColors.emeraldSuccess
                                    : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticService.selectionClick();
                      setState(() => _debriefBoundaryMaintained = false);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: !_debriefBoundaryMaintained
                            ? AppColors.roseDanger.withValues(alpha: 0.15)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: !_debriefBoundaryMaintained
                              ? AppColors.roseDanger
                              : AppColors.borderSubtle,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cancel_rounded,
                            size: 14,
                            color: !_debriefBoundaryMaintained
                                ? AppColors.roseDanger
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              context.loc.stoicQ2Compromised,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: !_debriefBoundaryMaintained
                                    ? AppColors.roseDanger
                                    : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Question 3: Rational Decision / Core Milestone
            Text(
              context.loc.stoicQ3Header,
              style: AppTextStyles.labelBadge.copyWith(
                color: const Color(0xFF818CF8),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _debriefDecisionController,
              maxLines: 2,
              maxLength: 200,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontSize: 12.5,
              ),
              decoration: InputDecoration(
                hintText: context.loc.stoicQ3Hint,
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
                counterStyle: AppTextStyles.metricSmall.copyWith(fontSize: 8.5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                suffixIcon: VoiceDictationButton(controller: _debriefDecisionController),
              ),
            ),
            const SizedBox(height: 8),

            // Save Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isCompleted)
                  TextButton(
                    onPressed: () {
                      HapticService.selectionClick();
                      setState(() {
                        _isEditingDebrief = false;
                        _debriefReactionScore = _todayEntry!.reactionControlScore;
                        _debriefBoundaryMaintained = _todayEntry!.boundaryMaintained;
                        _debriefDecisionController.text = _todayEntry!.coreOutputSummary;
                      });
                    },
                    child: Text(
                      context.loc.cancel,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                    ),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _saveNightDebrief,
                  icon: const Icon(Icons.check_rounded, size: 15),
                  label: Text(
                    context.loc.saveDebriefButton,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _saveNightDebrief() async {
    final decision = _debriefDecisionController.text.trim();
    if (decision.isEmpty) {
      HapticService.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.enterRationalDecisionPrompt,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFD97706),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    HapticService.success();
    final now = DateTime.now();
    final todayKey = DateHelpers.toStorageKey(now);
    final entryId = 'entry_$todayKey';

    // 1. Update DailyJournalEntry
    final updatedDailyEntry = _todayEntry != null
        ? _todayEntry!.copyWith(
            reactionControlScore: _debriefReactionScore,
            boundaryMaintained: _debriefBoundaryMaintained,
            coreOutputSummary: decision,
          )
        : DailyJournalEntry(
            id: entryId,
            entryDate: todayKey,
            createdAt: now,
            reactionControlScore: _debriefReactionScore,
            boundaryMaintained: _debriefBoundaryMaintained,
            coreOutputSummary: decision,
          );

    await _journalRepo.saveEntry(updatedDailyEntry);

    // 2. Persist to ReflectionEntry for Cognition Timeline sync
    final reflection = ReflectionEntry(
      id: entryId,
      title: context.loc.dailyReviewDateTitle(todayKey),
      content: decision,
      category: ReflectionCategory.dailyReview,
      createdAt: now,
      reactionScore: _debriefReactionScore,
      boundaryMaintained: _debriefBoundaryMaintained,
      distractionAvoided: _todayEntry?.provocationHandled,
      tags: const ['दैनिक समीक्षा', 'समत्व'],
    );
    await _storage.saveReflection(reflection);

    if (mounted) {
      setState(() {
        _todayEntry = updatedDailyEntry;
        _isEditingDebrief = false;
        _streakData = _journalRepo.getStreakData();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.nightDebriefSavedNotice,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.emeraldSuccess,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
