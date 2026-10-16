import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../shared/widgets/voice_tts_button.dart';
import '../../data/models/daily_rule.dart';

/// CoreRuleCard showcases the designated daily quote/rule from notifications_dataset.json
/// as well as classical Stoic executive maxims.
class CoreRuleCard extends StatefulWidget {
  final NotificationTrigger? datasetTrigger;
  final DailyRule rule;
  final VoidCallback onNextRule;
  final VoidCallback onNextDatasetTrigger;

  const CoreRuleCard({
    super.key,
    required this.datasetTrigger,
    required this.rule,
    required this.onNextRule,
    required this.onNextDatasetTrigger,
  });

  @override
  State<CoreRuleCard> createState() => _CoreRuleCardState();
}

class _CoreRuleCardState extends State<CoreRuleCard> {
  bool _showDataset = true; // Default to notifications_dataset.json quote

  @override
  Widget build(BuildContext context) {
    final trigger = widget.datasetTrigger;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Toggle between Dataset Trigger & Classical Stoic Rule
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.space16,
              AppDimens.space14,
              AppDimens.space8,
              AppDimens.space8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticService.selectionClick();
                        setState(() => _showDataset = true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _showDataset
                              ? AppColors.shieldGlow
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusSmall,
                          ),
                          border: Border.all(
                            color: _showDataset
                                ? AppColors.shieldPrimary
                                : AppColors.borderSubtle,
                          ),
                        ),
                        child: Text(
                          'DAILY TRIGGER (DATASET)',
                          style: AppTextStyles.labelBadge.copyWith(
                            fontSize: 9.0,
                            color: _showDataset
                                ? AppColors.shieldPrimary
                                : AppColors.textMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        HapticService.selectionClick();
                        setState(() => _showDataset = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: !_showDataset
                              ? AppColors.shieldGlow
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusSmall,
                          ),
                          border: Border.all(
                            color: !_showDataset
                                ? AppColors.shieldPrimary
                                : AppColors.borderSubtle,
                          ),
                        ),
                        child: Text(
                          'STOIC RULE',
                          style: AppTextStyles.labelBadge.copyWith(
                            fontSize: 9.0,
                            color: !_showDataset
                                ? AppColors.shieldPrimary
                                : AppColors.textMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VoiceTtsButton(
                      textToSpeak: _showDataset && trigger != null
                          ? '${trigger.title}. ${trigger.body}'
                          : '${widget.rule.title}. ${widget.rule.aphorism}. Tactical Action: ${widget.rule.tacticalAction}',
                      tooltip: 'Listen to rule in calm executive voice',
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () {
                        HapticService.selectionClick();
                        if (_showDataset) {
                          widget.onNextDatasetTrigger();
                        } else {
                          widget.onNextRule();
                        }
                      },
                      icon: const Icon(Icons.sync_rounded, size: 18),
                      color: AppColors.textSecondary,
                      tooltip: _showDataset
                          ? 'Cycle through today\'s 4 dataset slots'
                          : 'Cycle to next Stoic rule',
                      splashRadius: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content body based on selection
          if (_showDataset && trigger != null) ...[
            // Slot metadata (e.g. "05:45 • Morning Grounding")
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${trigger.hour.toString().padLeft(2, '0')}:${trigger.minute.toString().padLeft(2, '0')}',
                      style: AppTextStyles.metricSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.shieldPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    trigger.category.toUpperCase(),
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 9.5,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Devanagari Title (e.g. "प्रातःकालीन लंगर")
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
              ),
              child: Text(
                trigger.title,
                style: AppTextStyles.heading.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Devanagari Stoic Quote / Body
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
              ),
              child: Text(
                '"${trigger.body}"',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 15.5,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Dataset provenance badge
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active_outlined,
                    size: 14,
                    color: AppColors.shieldPrimary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Scheduled daily trigger from notifications_dataset.json',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Classical Stoic Rule
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
              ),
              child: Text(
                widget.rule.title,
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
                '"${widget.rule.aphorism}"',
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
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
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
                        'TACTICAL DIRECTIVE',
                        style: AppTextStyles.labelBadge.copyWith(
                          color: AppColors.shieldPrimary,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.rule.tacticalAction,
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
