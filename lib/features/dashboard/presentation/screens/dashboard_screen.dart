import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
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
/// Features the prominent central SOS Shield, Today's Core Rule, and Daily Streak tracker.
class DashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToJournal;

  const DashboardScreen({super.key, required this.onNavigateToJournal});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final JournalRepository _journalRepo = JournalRepository();
  final HiveStorage _storage = HiveStorage();

  late DailyRule _currentRule;
  int _activeRuleIndex = 0;
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
    refreshData();
  }

  /// Exposed method to refresh dashboard metrics when tab switches or debrief saves
  void refreshData() {
    if (!mounted) return;
    setState(() {
      _streakData = _journalRepo.getStreakData();
      _todayEntry = _journalRepo.getTodayEntry();
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

  void _openSOSModal() {
    SOSModalSheet.show(context);
  }

  void _openNotificationSettings() {
    ExecutiveNotificationTester.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDebriefCompleted = _todayEntry != null;

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

                  // 4. Today's Core Stoic Rule Card
                  CoreRuleCard(rule: _currentRule, onNextRule: _cycleNextRule),
                  const SizedBox(height: 16),

                  // 5. Evening Debrief Status Card
                  _buildDebriefStatusCard(isDebriefCompleted),
                ],
              ),
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
                      'EVENING DEBRIEF (60s)',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: isCompleted
                            ? AppColors.emeraldSuccess
                            : AppColors.textPrimary,
                        fontSize: 9.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCompleted ? '• COMPLETED' : '• PENDING',
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
                      ? 'Score: ${_todayEntry!.compositeScore}% • "${_todayEntry!.coreOutput}"'
                      : 'Audit today\'s Reaction Control & Boundary Retained before bed.',
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
