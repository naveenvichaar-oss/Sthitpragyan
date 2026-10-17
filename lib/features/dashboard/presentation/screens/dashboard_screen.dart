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
import 'package:sthitaprajna/features/dashboard/presentation/widgets/sos_shield_button.dart';
import 'package:sthitaprajna/features/dashboard/presentation/widgets/streak_badge.dart';
import 'package:sthitaprajna/features/character_ledger/presentation/screens/character_ledger_screen.dart';
import 'package:sthitaprajna/features/execution_trigger/presentation/screens/execution_trigger_screen.dart';
import 'package:sthitaprajna/features/execution_trigger/presentation/widgets/micro_ignition_timer_dialog.dart';
import 'package:sthitaprajna/features/journal/data/models/journal_models.dart';
import 'package:sthitaprajna/features/journal/data/repositories/journal_repository.dart';
import 'package:sthitaprajna/features/joy_reservoir/presentation/screens/joy_reservoir_screen.dart';
import 'package:sthitaprajna/features/recovery/presentation/screens/post_incident_recovery_screen.dart';
import 'package:sthitaprajna/features/settings/presentation/screens/settings_screen.dart';
import 'package:sthitaprajna/features/sos/presentation/screens/sos_modal_sheet.dart';
import 'package:sthitaprajna/features/wisdom/presentation/widgets/daily_wisdom_card.dart';

/// DashboardScreen serves as the command center for Sthitaprajna.
/// Features:
/// 1. Minimalist dark theme (Zinc-950/900)
/// 2. Big floating "SOS Shield" button at the center
/// 3. Daily quote/rule from notifications_dataset.json (and Stoic rules)
/// 4. Direct navigation to 3-Index Journal, Cognition Vault, and Settings
class DashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToJournal;
  final VoidCallback? onNavigateToVault;
  final VoidCallback? onNavigateToSettings;

  const DashboardScreen({
    super.key,
    required this.onNavigateToJournal,
    this.onNavigateToVault,
    this.onNavigateToSettings,
  });

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final JournalRepository _journalRepo = JournalRepository();
  final HiveStorage _storage = HiveStorage();

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

  void _initDashboard() {
    _activeRuleIndex = _storage.getActiveRuleIndex();
    _currentRule = DailyRulesVault.getTodayRule(_activeRuleIndex);

    _todayTriggers = NotificationsDatasetService().getTodayTriggers();
    if (_todayTriggers.isEmpty) {
      _todayTriggers = NotificationService.defaultTriggers;
    }

    refreshData();
  }

  /// Exposed method to refresh dashboard metrics when tab switches or debrief saves
  void refreshData() {
    if (!mounted) return;
    setState(() {
      _streakData = _journalRepo.getStreakData();
      _todayEntry = _journalRepo.getTodayEntry();
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

  void _openSOSModal() {
    SOSModalSheet.show(context);
  }

  void _openSlipUpRecovery() {
    HapticService.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PostIncidentRecoveryScreen(),
      ),
    );
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
                  // 2. Daily Streak Tracker Card
                  StreakBadge(streakData: _streakData),
                  const SizedBox(height: 20),

                  // 3. Centerpiece: Big Floating "SOS Shield" Button
                  SOSShieldButton(onPressed: _openSOSModal),
                  const SizedBox(height: 10),

                  // Secondary Button: 'Log a Slip-Up / Reset'
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _openSlipUpRecovery,
                      icon: const Icon(
                        Icons.restart_alt_rounded,
                        size: 16,
                        color: AppColors.amberWarning,
                      ),
                      label: Text(context.loc.slipUpRecoveryButton),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(
                          color: AppColors.amberWarning.withOpacity(0.5),
                          width: 1.0,
                        ),
                        backgroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusSmall,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Daily Quote/Rule from notifications_dataset.json
                  CoreRuleCard(
                    datasetTrigger: currentTrigger,
                    rule: _currentRule,
                    onNextRule: _cycleNextRule,
                    onNextDatasetTrigger: _cycleNextDatasetTrigger,
                  ),
                  const SizedBox(height: 14),

                  // 5. Daily Rotating "Wisdom of the Day" Card
                  DailyWisdomCard(onOpenVault: widget.onNavigateToVault),
                  const SizedBox(height: 16),

                  // 6. Direct Quick Navigation Row: Journal Debrief & Cognition Vault
                  Row(
                    children: [
                      // Navigation to 3-Index Journal Screen
                      Expanded(
                        child: _buildNavigationCard(
                          icon: Icons.edit_note_rounded,
                          accentColor: isDebriefCompleted
                              ? AppColors.emeraldSuccess
                              : AppColors.shieldPrimary,
                          title: context.loc.dailyJournalTitle.toUpperCase(),
                          subtitle: isDebriefCompleted
                              ? '${context.loc.debriefLoggedScore} (${_todayEntry!.compositeScore}%)'
                              : context.loc.eveningAuditSubtitle,
                          onTap: widget.onNavigateToJournal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Navigation to Cognition Vault Screen
                      Expanded(
                        child: _buildNavigationCard(
                          icon: Icons.psychology_rounded,
                          accentColor: const Color(0xFF818CF8),
                          title: context.loc.cognitionVaultTitle,
                          subtitle: context.loc.segmentFallacies,
                          onTap: widget.onNavigateToVault,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 7. Joy Reservoir (Soul Sanctuary / आनंद कोष) Card
                  _buildJoyReservoirCard(),
                  const SizedBox(height: 12),

                  // 8. Action-Trigger (Commitment Chime & Micro-Ignition)
                  _buildExecutionTriggerCard(),
                  const SizedBox(height: 12),

                  // 9. Character Ledger (Virtue & Trait Notepad)
                  _buildCharacterLedgerCard(),
                  const SizedBox(height: 16),

                  // 10. Evening Debrief Status Bar
                  _buildDebriefStatusCard(isDebriefCompleted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoyReservoirCard() {
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        JoyReservoirScreen.open(context);
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          border: Border.all(
            color: const Color(0xFFF43F5E).withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.spa_rounded,
                size: 20,
                color: Color(0xFFF43F5E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        context.loc.joyReservoirSubtitle.toUpperCase(),
                        style: AppTextStyles.labelBadge.copyWith(
                          color: const Color(0xFFF43F5E),
                          fontSize: 8.5,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.loc.joyReservoirTitle.toUpperCase(),
                    style: AppTextStyles.heading,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.loc.joyReservoirDesc,
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
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionTriggerCard() {
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        ExecutionTriggerScreen.open(context);
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                size: 20,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        context.loc.executionChimesSubtitle.toUpperCase(),
                        style: AppTextStyles.labelBadge.copyWith(
                          color: const Color(0xFF10B981),
                          fontSize: 8.5,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.loc.executionChimesTitle.toUpperCase(),
                    style: AppTextStyles.heading,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.loc.microIgnitionDesc,
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
            GestureDetector(
              onTap: () {
                HapticService.selectionClick();
                MicroIgnitionTimerDialog.show(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 13,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      context.loc.microIgnitionAction.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterLedgerCard() {
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        CharacterLedgerScreen.open(context);
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.anchor_rounded,
                size: 20,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        context.loc.characterLedgerSubtitle.toUpperCase(),
                        style: AppTextStyles.labelBadge.copyWith(
                          color: const Color(0xFFF59E0B),
                          fontSize: 8.5,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.loc.characterLedgerTitle.toUpperCase(),
                    style: AppTextStyles.heading,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.loc.characterLedgerDesc,
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
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard({
    required IconData icon,
    required Color accentColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          border: Border.all(color: AppColors.borderSubtle, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 18, color: accentColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 9.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebriefStatusCard(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: isCompleted
              ? AppColors.emeraldSuccess.withOpacity(0.4)
              : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.emeraldMuted
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.hourglass_empty_rounded,
              size: 20,
              color: isCompleted
                  ? AppColors.emeraldSuccess
                  : AppColors.amberWarning,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      context.loc.eveningDebriefStatusTitle,
                      style: AppTextStyles.labelBadge.copyWith(
                        color: isCompleted
                            ? AppColors.emeraldSuccess
                            : AppColors.textPrimary,
                        fontSize: 9.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCompleted ? context.loc.statusCompleted : context.loc.statusPending,
                      style: AppTextStyles.labelBadge.copyWith(
                        color: isCompleted
                            ? AppColors.emeraldSuccess
                            : AppColors.amberWarning,
                        fontSize: 9.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isCompleted
                      ? '${context.loc.scoreLabel}: ${_todayEntry!.compositeScore}% • "${_todayEntry!.coreOutputSummary}"'
                      : context.loc.eveningAuditPrompt,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: widget.onNavigateToJournal,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: Text(
              isCompleted ? context.loc.viewAction : context.loc.startAction,
              style: AppTextStyles.button.copyWith(
                fontSize: 12,
                color: AppColors.shieldPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
