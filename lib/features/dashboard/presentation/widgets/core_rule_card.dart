import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/services/gong_audio_service.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../shared/widgets/voice_tts_button.dart';
import '../../../wisdom/data/models/wisdom_entry.dart';
import '../../../wisdom/data/services/wisdom_vault_service.dart';
import '../../data/models/daily_rule.dart';

/// CoreRuleCard unifies the three core daily wisdom pillars into a single seamless tabbed container:
/// 1. My day today (आज का दिन) - customizable time, prompt, and functional reminder chime
/// 2. Wisdom of the day (प्रज्ञा सूत्र) - rotating philosophical shloka and daily affirmation setter
/// 3. Core stoic rule (स्थितप्रज्ञ नियम) - tactical executive directive and sovereign mindset
class CoreRuleCard extends StatefulWidget {
  final NotificationTrigger? datasetTrigger;
  final DailyRule rule;
  final VoidCallback onNextRule;
  final VoidCallback onNextDatasetTrigger;
  final VoidCallback? onOpenVault;
  final ValueChanged<NotificationTrigger>? onTriggerUpdated;

  const CoreRuleCard({
    super.key,
    required this.datasetTrigger,
    required this.rule,
    required this.onNextRule,
    required this.onNextDatasetTrigger,
    this.onOpenVault,
    this.onTriggerUpdated,
  });

  @override
  State<CoreRuleCard> createState() => _CoreRuleCardState();
}

class _CoreRuleCardState extends State<CoreRuleCard> {
  int _activeTabIndex = 0; // 0: My Day Today, 1: Wisdom of the Day, 2: Core Stoic Rule
  NotificationTrigger? _customTrigger;

  // Wisdom of the Day state
  late WisdomEntry _currentWisdom;
  int _wisdomIndex = 0;
  String? _activeAffirmationId;

  @override
  void initState() {
    super.initState();
    _loadInitialWisdom();
  }

  void _loadInitialWisdom() {
    final service = WisdomVaultService();
    _currentWisdom = service.getDailyWisdom();
    if (HiveStorage().isInitialized) {
      _activeAffirmationId = HiveStorage().getDailyAffirmationId();
    }
  }

  void _cycleNextWisdom() {
    HapticService.selectionClick();
    final entries = WisdomVaultService().getAllEntries();
    if (entries.isNotEmpty) {
      setState(() {
        _wisdomIndex = (_wisdomIndex + 1) % entries.length;
        _currentWisdom = entries[_wisdomIndex];
      });
    }
  }

  Future<void> _setAsAffirmation() async {
    HapticService.success();
    await HiveStorage().setDailyAffirmation(
      id: _currentWisdom.id,
      title: _currentWisdom.title,
      text: _currentWisdom.translation,
      source: _currentWisdom.source,
    );

    setState(() {
      _activeAffirmationId = _currentWisdom.id;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.emeraldSuccess,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.loc.setAffirmationSuccess(_currentWisdom.title),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant CoreRuleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.datasetTrigger?.id != widget.datasetTrigger?.id) {
      _customTrigger = null;
    }
  }

  NotificationTrigger? get _effectiveTrigger => _customTrigger ?? widget.datasetTrigger;

  void _openEditTriggerSheet(NotificationTrigger trigger) {
    HapticService.selectionClick();
    final isHindi = context.loc.isHindi;
    final titleController = TextEditingController(
      text: trigger.localizedTitle(isHindi),
    );
    final bodyController = TextEditingController(
      text: trigger.localizedBody(isHindi),
    );
    int selectedHour = trigger.hour;
    int selectedMinute = trigger.minute;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLarge)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final mediaQuery = MediaQuery.of(sheetContext);
          final bottomInset = mediaQuery.viewInsets.bottom;
          final bottomPadding = mediaQuery.padding.bottom;
          return SafeArea(
            bottom: true,
            child: Padding(
              padding: EdgeInsets.only(
                left: AppDimens.space16,
                right: AppDimens.space16,
                top: AppDimens.space16,
                bottom: bottomInset + (bottomPadding > 0 ? bottomPadding + 14 : 28),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderSubtle,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.loc.myDayTodayEditTitle,
                            style: AppTextStyles.labelBadge.copyWith(
                              color: AppColors.shieldPrimary,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.loc.editTodaysFocusAndTrigger,
                            style: AppTextStyles.heading.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                        onPressed: () => Navigator.of(sheetContext).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Slot Time & Category
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: sheetContext,
                            initialTime: TimeOfDay(hour: selectedHour, minute: selectedMinute),
                          );
                          if (picked != null) {
                            setSheetState(() {
                              selectedHour = picked.hour;
                              selectedMinute = picked.minute;
                            });
                          }
                        },
                        icon: const Icon(Icons.schedule_rounded, size: 16, color: AppColors.shieldPrimary),
                        label: Text(
                          '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.shieldPrimary,
                          side: const BorderSide(color: AppColors.shieldPrimary),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          trigger.localizedCategory(isHindi),
                          style: AppTextStyles.labelBadge.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Title Field
                  Text(
                    context.loc.titleCoreThemeLabel,
                    style: AppTextStyles.labelBadge.copyWith(fontSize: 9),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: context.loc.titleCoreThemeHint,
                      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                        borderSide: const BorderSide(color: AppColors.borderSubtle),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Body / Maxim Field
                  Text(
                    context.loc.dailyThoughtMaximLabel,
                    style: AppTextStyles.labelBadge.copyWith(fontSize: 9),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: bodyController,
                    maxLines: 3,
                    style: AppTextStyles.bodySmall,
                    decoration: InputDecoration(
                      hintText: context.loc.dailyThoughtMaximHint,
                      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                        borderSide: const BorderSide(color: AppColors.borderSubtle),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons: Reset & Save
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              HapticService.selectionClick();
                              await HiveStorage().clearCustomTriggerOverride(trigger.id);
                              await NotificationService().scheduleAllConfiguredTriggers();
                              setState(() {
                                _customTrigger = null;
                              });
                              widget.onNextDatasetTrigger();
                              if (mounted) Navigator.of(sheetContext).pop();
                            },
                            icon: const Icon(Icons.restart_alt_rounded, size: 16),
                            label: Text(
                              context.loc.resetDefaultButton,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.roseDanger,
                              side: BorderSide(
                                color: AppColors.roseDanger.withValues(alpha: 0.6),
                                width: 1.2,
                              ),
                              backgroundColor: AppColors.roseDanger.withValues(alpha: 0.08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final newTitle = titleController.text.trim();
                              final newBody = bodyController.text.trim();
                              if (newTitle.isEmpty && newBody.isEmpty) return;

                              HapticService.success();
                              final overrideData = {
                                'hour': selectedHour,
                                'minute': selectedMinute,
                                'title': isHindi ? newTitle : trigger.title,
                                'body': isHindi ? newBody : trigger.body,
                                'titleEn': isHindi ? trigger.titleEn : newTitle,
                                'bodyEn': isHindi ? trigger.bodyEn : newBody,
                              };
                              await HiveStorage().saveCustomTriggerOverride(trigger.id, overrideData);

                              final updatedTrigger = trigger.copyWith(
                                hour: selectedHour,
                                minute: selectedMinute,
                                title: overrideData['title'] as String?,
                                body: overrideData['body'] as String?,
                                titleEn: overrideData['titleEn'] as String?,
                                bodyEn: overrideData['bodyEn'] as String?,
                              );

                              await NotificationService().scheduleAllConfiguredTriggers();

                              setState(() {
                                _customTrigger = updatedTrigger;
                              });
                              widget.onTriggerUpdated?.call(updatedTrigger);

                              if (mounted) {
                                Navigator.of(sheetContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: AppColors.emeraldSuccess, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            context.loc.todaysTriggerUpdatedNotice,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppColors.surfaceElevated,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: Text(
                              context.loc.saveChangesButton,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: 0.3,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.shieldPrimary,
                              foregroundColor: AppColors.background,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _activeTabIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticService.selectionClick();
            setState(() => _activeTabIndex = index);
          },
          borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
          child: Container(
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              border: isSelected
                  ? Border.all(color: AppColors.shieldPrimary, width: 1.2)
                  : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelBadge.copyWith(
                fontSize: 9.5,
                color: isSelected ? AppColors.shieldPrimary : AppColors.textSecondary,
                letterSpacing: 0.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trigger = _effectiveTrigger;
    final isReminderActive = trigger != null && HiveStorage().isTriggerReminderEnabled(trigger.id);
    final isAffirmation = _activeAffirmationId == _currentWisdom.id;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Full-Width 3-Tab Header Bar: [आज का दिन] | [प्रज्ञा सूत्र] | [स्थितप्रज्ञ नियम]
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.space12,
              AppDimens.space12,
              AppDimens.space12,
              AppDimens.space6,
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  _buildTabItem(0, context.loc.dailyTriggerDatasetBadge), // My Day Today / आज का दिन
                  const SizedBox(width: 4),
                  _buildTabItem(1, context.loc.wisdomOfTheDayBadge),       // Wisdom of the Day / प्रज्ञा सूत्र
                  const SizedBox(width: 4),
                  _buildTabItem(2, context.loc.coreStoicRuleBadge),         // Core Stoic Rule / स्थितप्रज्ञ नियम
                ],
              ),
            ),
          ),

          // 2. Contextual Sub-Action Strip with full touch targets
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.space16,
              AppDimens.space4,
              AppDimens.space12,
              AppDimens.space8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Context badge
                if (_activeTabIndex == 0 && trigger != null)
                  InkWell(
                    onTap: () => _openEditTriggerSheet(trigger),
                    borderRadius: BorderRadius.circular(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Text(
                            '${trigger.hour.toString().padLeft(2, '0')}:${trigger.minute.toString().padLeft(2, '0')}',
                            style: AppTextStyles.metricSmall.copyWith(
                              fontSize: 11,
                              color: AppColors.shieldPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          trigger.localizedCategory(context.loc.isHindi),
                          style: AppTextStyles.labelBadge.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 9.5,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_activeTabIndex == 1)
                  Text(
                    _currentWisdom.source.toUpperCase(),
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 9.5,
                      letterSpacing: 1.2,
                    ),
                  )
                else
                  Text(
                    context.loc.isHindi
                        ? 'नियम ${widget.rule.id.toString().padLeft(2, '0')} / 07'
                        : 'RULE ${widget.rule.id.toString().padLeft(2, '0')} OF 07',
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 9.5,
                      letterSpacing: 1.2,
                    ),
                  ),

                // Contextual Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_activeTabIndex == 0 && trigger != null) ...[
                      IconButton(
                        onPressed: () => _openEditTriggerSheet(trigger),
                        icon: const Icon(Icons.edit_outlined, size: 17),
                        color: AppColors.textSecondary,
                        tooltip: context.loc.editTodayTriggerTooltip,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        padding: const EdgeInsets.all(8),
                      ),
                      VoiceTtsButton(
                        textToSpeak:
                            '${trigger.localizedTitle(context.loc.isHindi)}. ${trigger.localizedBody(context.loc.isHindi)}',
                        audioTopicKey: 'trigger_${trigger.id}',
                        tooltip: context.loc.listenWithCalmVoice,
                      ),
                      IconButton(
                        onPressed: () {
                          HapticService.selectionClick();
                          widget.onNextDatasetTrigger();
                        },
                        icon: const Icon(Icons.sync_rounded, size: 18),
                        color: AppColors.textSecondary,
                        tooltip: context.loc.cycleDatasetSlotsTooltip,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        padding: const EdgeInsets.all(8),
                      ),
                    ] else if (_activeTabIndex == 1) ...[
                      VoiceTtsButton(
                        textToSpeak:
                            '${_currentWisdom.getTitle(context.loc.isHindi)}. ${_currentWisdom.originalText}. ${_currentWisdom.getTranslation(context.loc.isHindi)}. ${_currentWisdom.getExecutiveTakeaway(context.loc.isHindi)}',
                        audioTopicKey: 'wisdom_${_currentWisdom.id}',
                        tooltip: context.loc.listenWisdomReadout,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        color: AppColors.textSecondary,
                        onPressed: _cycleNextWisdom,
                        tooltip: context.loc.cycleNextWisdom,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        padding: const EdgeInsets.all(8),
                      ),
                      if (widget.onOpenVault != null)
                        IconButton(
                          icon: const Icon(Icons.open_in_new_rounded, size: 16),
                          color: AppColors.textSecondary,
                          onPressed: widget.onOpenVault,
                          tooltip: context.loc.openWisdomVault,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          padding: const EdgeInsets.all(8),
                        ),
                    ] else ...[
                      VoiceTtsButton(
                        textToSpeak:
                            '${context.loc.getRuleTitle(widget.rule.id, widget.rule.title)}. ${context.loc.getRuleAphorism(widget.rule.id, widget.rule.aphorism)}. ${context.loc.tacticalDirectiveLabel} ${context.loc.getRuleTacticalAction(widget.rule.id, widget.rule.tacticalAction)}',
                        audioTopicKey: 'rule_${widget.rule.id}',
                        tooltip: context.loc.listenWithCalmVoice,
                      ),
                      IconButton(
                        onPressed: () {
                          HapticService.selectionClick();
                          widget.onNextRule();
                        },
                        icon: const Icon(Icons.sync_rounded, size: 18),
                        color: AppColors.textSecondary,
                        tooltip: context.loc.cycleStoicRuleTooltip,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        padding: const EdgeInsets.all(8),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // -------------------------------------------------------------
          // TAB 0: MY DAY TODAY (आज का दिन)
          // -------------------------------------------------------------
          if (_activeTabIndex == 0 && trigger != null) ...[
            // Slot metadata (e.g. "05:45 • Morning Grounding") with tap-to-edit
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
              ),
              child: InkWell(
                onTap: () => _openEditTriggerSheet(trigger),
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${trigger.hour.toString().padLeft(2, '0')}:${trigger.minute.toString().padLeft(2, '0')}',
                            style: AppTextStyles.metricSmall.copyWith(
                              fontSize: 11,
                              color: AppColors.shieldPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit_outlined, size: 10, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      trigger.localizedCategory(context.loc.isHindi),
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 9.5,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Localized Title with tap-to-edit
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
              ),
              child: InkWell(
                onTap: () => _openEditTriggerSheet(trigger),
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        trigger.localizedTitle(context.loc.isHindi),
                        style: AppTextStyles.heading.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Localized Stoic Quote / Body
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
              ),
              child: InkWell(
                onTap: () => _openEditTriggerSheet(trigger),
                borderRadius: BorderRadius.circular(4),
                child: Text(
                  '"${trigger.localizedBody(context.loc.isHindi)}"',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 15.5,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Fully Functional Reminder Bell & Chime Bar
            InkWell(
              onTap: () async {
                HapticService.mediumImpact();
                await GongAudioService().playDeepGong();
                await NotificationService().fireTestNotification(trigger);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.notifications_active_rounded,
                            color: AppColors.emeraldSuccess,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.loc.chimeSoundedNotice(
                                '${trigger.hour.toString().padLeft(2, '0')}:${trigger.minute.toString().padLeft(2, '0')}',
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.surfaceElevated,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  border: Border.all(
                    color: isReminderActive
                        ? AppColors.shieldPrimary.withValues(alpha: 0.4)
                        : AppColors.borderSubtle,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isReminderActive
                            ? AppColors.shieldPrimary.withValues(alpha: 0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        isReminderActive
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_outlined,
                        size: 16,
                        color: isReminderActive
                            ? AppColors.shieldPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.loc.dailyReminderTimeBadge(
                              '${trigger.hour.toString().padLeft(2, '0')}:${trigger.minute.toString().padLeft(2, '0')}',
                            ),
                            style: AppTextStyles.labelBadge.copyWith(
                              fontSize: 9.5,
                              color: isReminderActive
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.loc.reminderChimeSubtitle,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.volume_up_rounded, size: 16),
                          color: AppColors.shieldPrimary,
                          tooltip: context.loc.soundChimeTooltip,
                          onPressed: () async {
                            HapticService.mediumImpact();
                            await GongAudioService().playDeepGong();
                          },
                          splashRadius: 16,
                        ),
                        Switch.adaptive(
                          value: isReminderActive,
                          activeThumbColor: AppColors.shieldPrimary,
                          activeTrackColor: AppColors.shieldPrimary.withValues(alpha: 0.5),
                          onChanged: (val) async {
                            HapticService.selectionClick();
                            await HiveStorage().setTriggerReminderEnabled(trigger.id, val);
                            setState(() {});
                            if (val) {
                              await NotificationService().scheduleAllConfiguredTriggers();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]

          // -------------------------------------------------------------
          // TAB 1: WISDOM OF THE DAY (प्रज्ञा सूत्र)
          // -------------------------------------------------------------
          else if (_activeTabIndex == 1) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Source
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _currentWisdom.getTitle(context.loc.isHindi),
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (isAffirmation) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldMuted,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 11, color: AppColors.emeraldSuccess),
                              const SizedBox(width: 3),
                              Text(
                                context.loc.todaysAffirmationTitle,
                                style: AppTextStyles.labelBadge.copyWith(
                                  fontSize: 8.0,
                                  color: AppColors.emeraldSuccess,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _currentWisdom.getSubtitle(context.loc.isHindi),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Original Text / Shloka in styled container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      _currentWisdom.originalText,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.45,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Translation / Executive Takeaway
                  Text(
                    _currentWisdom.getExecutiveTakeaway(context.loc.isHindi),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Action Button: Set as Today's Affirmation
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isAffirmation ? null : _setAsAffirmation,
                      icon: Icon(
                        isAffirmation ? Icons.check_circle_rounded : Icons.star_border_rounded,
                        size: 15,
                        color: isAffirmation ? AppColors.emeraldSuccess : AppColors.shieldPrimary,
                      ),
                      label: Text(
                        isAffirmation ? context.loc.affirmedForToday : context.loc.setAsTodaysAffirmation,
                        style: AppTextStyles.button.copyWith(
                          fontSize: 11,
                          color: isAffirmation ? AppColors.emeraldSuccess : AppColors.shieldPrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isAffirmation
                              ? AppColors.emeraldSuccess.withValues(alpha: 0.5)
                              : AppColors.shieldPrimary.withValues(alpha: 0.5),
                        ),
                        backgroundColor: isAffirmation
                            ? AppColors.emeraldMuted.withValues(alpha: 0.2)
                            : Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ]

          // -------------------------------------------------------------
          // TAB 2: CORE STOIC RULE (स्थितप्रज्ञ नियम)
          // -------------------------------------------------------------
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
              ),
              child: Text(
                context.loc.getRuleTitle(widget.rule.id, widget.rule.title),
                style: AppTextStyles.heading.copyWith(
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
              ),
              child: Text(
                '"${context.loc.getRuleAphorism(widget.rule.id, widget.rule.aphorism)}"',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontStyle: FontStyle.italic,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
              ),
              child: Text(
                widget.rule.source.toUpperCase(),
                style: AppTextStyles.labelBadge.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  letterSpacing: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: AppColors.shieldPrimary,
                      ),
                      const SizedBox(width: AppDimens.space6),
                      Text(
                        context.loc.tacticalDirectiveBadge,
                        style: AppTextStyles.labelBadge.copyWith(
                          color: AppColors.shieldPrimary,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.loc.getRuleTacticalAction(
                      widget.rule.id,
                      widget.rule.tacticalAction,
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
