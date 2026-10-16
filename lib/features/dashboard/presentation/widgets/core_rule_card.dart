import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/daily_rule.dart';

/// CoreRuleCard showcases the designated executive Stoic rule for today.
class CoreRuleCard extends StatelessWidget {
  final DailyRule rule;
  final VoidCallback onNextRule;

  const CoreRuleCard({super.key, required this.rule, required this.onNextRule});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Tactical Tag and Cycle Button
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.space16,
              AppDimens.space16,
              AppDimens.space8,
              AppDimens.space8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusSmall,
                        ),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Text(
                        'TODAY\'S CORE RULE',
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 9.5,
                          color: AppColors.shieldPrimary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.space8),
                    Text(
                      '#${rule.id.toString().padLeft(2, '0')}',
                      style: AppTextStyles.metricSmall.copyWith(fontSize: 10),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    HapticService.selectionClick();
                    onNextRule();
                  },
                  icon: const Icon(Icons.sync_rounded, size: 18),
                  color: AppColors.textSecondary,
                  tooltip: 'Cycle to Next Stoic Rule',
                  splashRadius: 18,
                ),
              ],
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16),
            child: Text(
              rule.title,
              style: AppTextStyles.heading.copyWith(
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.space8),

          // Aphorism
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16),
            child: Text(
              '"${rule.aphorism}"',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.space8),

          // Source attribution
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16),
            child: Text(
              rule.source.toUpperCase(),
              style: AppTextStyles.labelBadge.copyWith(
                color: AppColors.textMuted,
                fontSize: 10,
                letterSpacing: 1.3,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.space16),

          // Tactical Corporate Action Box
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(AppDimens.space12),
            padding: const EdgeInsets.all(AppDimens.space12),
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
                const SizedBox(height: AppDimens.space6),
                Text(
                  rule.tacticalAction,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppDimens.space8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VECTORS: ',
                      style: AppTextStyles.labelBadge.copyWith(
                        fontSize: 9.0,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        rule.corporateContext,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
