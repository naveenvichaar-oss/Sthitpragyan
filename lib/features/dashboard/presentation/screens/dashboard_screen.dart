import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/notifications/notifications_dataset_service.dart';
import '../../../../shared/widgets/executive_notification_tester.dart';
import '../../journal/data/models/journal_models.dart';
import '../../journal/data/repositories/journal_repository.dart';
import '../../sos/presentation/screens/sos_modal_sheet.dart';
import '../data/daily_rules_vault.dart';
import '../data/models/daily_rule.dart';
import '../data/models/streak_data.dart';
import '../widgets/core_rule_card.dart';
import '../widgets/executive_header.dart';
import '../widgets/sos_shield_button.dart';
import '../widgets/streak_badge.dart';

/// DashboardScreen serves as the command center for Sthitaprajna.
/// Features:
/// 1. Minimalist dark theme (Zinc-950/900)
/// 2. Big floating "SOS Shield" button at the center
/// 3. Daily quote/rule from notifications_dataset.json (and Stoic rules)
/// 4. Direct navigation to 3-Index Journal and Cognition Vault
class DashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToJournal;
  final VoidCallback? onNavigateToVault;

  const DashboardScreen({
    super.key,
    required this.onNavigateToJournal,
    this.onNavigateToVault,
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

  void _openNotificationSettings() {
    ExecutiveNotificationTester.show(context);
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
                  const SizedBox(height: 20),

                  // 4. Daily Quote/Rule from notifications_dataset.json
                  CoreRuleCard(
                    datasetTrigger: currentTrigger,
                    rule: _currentRule,
                    onNextRule: _cycleNextRule,
                    onNextDatasetTrigger: _cycleNextDatasetTrigger,
                  ),
                  const SizedBox(height: 16),

                  // 5. Direct Quick Navigation Row: Journal Debrief & Cognition Vault
                  Row(
                    children: [
                      // Navigation to 3-Index Journal Screen
                      Expanded(
                        child: _buildNavigationCard(
                          icon: Icons.edit_note_rounded,
                          accentColor: isDebriefCompleted
                              ? AppColors.emeraldSuccess
                              : AppColors.shieldPrimary,
                          title: '3-INDEX DEBRIEF',
                          subtitle: isDebriefCompleted
                              ? 'Logged (${_todayEntry!.compositeScore}%)'
                              : '60s Evening Audit',
                          onTap: widget.onNavigateToJournal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Navigation to Cognition Vault Screen
                      Expanded(
                        child: _buildNavigationCard(
                          icon: Icons.psychology_rounded,
                          accentColor: const Color(0xFF818CF8),
                          title: 'COGNITION VAULT',
                          subtitle: 'Fallacies & Models',
                          onTap: widget.onNavigateToVault,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 6. Evening Debrief Status Bar
                  _buildDebriefStatusCard(isDebriefCompleted),
                ],
              ),
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
                      'दैनिक हिसाब (EVENING LOG)',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: isCompleted
                            ? AppColors.emeraldSuccess
                            : AppColors.textPrimary,
                        fontSize: 9.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCompleted ? '• बंद (LOCKED)' : '• लंबित (PENDING)',
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
                      ? 'स्कोर: ${_todayEntry!.compositeScore}% • "${_todayEntry!.coreOutputSummary}"'
                      : 'उकसावे पर चित्त की स्थिरता व मर्यादा का 60-सेकंड ऑडिट करें।',
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
              isCompleted ? 'VIEW' : 'START',
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
