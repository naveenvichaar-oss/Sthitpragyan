import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/journal_entry.dart';

/// PastDebriefsList renders historical 3-Index evening logs.
class PastDebriefsList extends StatelessWidget {
  final List<JournalEntry> entries;
  final Function(String dateKey) onDelete;

  const PastDebriefsList({
    super.key,
    required this.entries,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimens.space24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.history_rounded,
              size: 28,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 8),
            Text(
              'NO HISTORICAL DEBRIEFS LOGGED YET',
              style: AppTextStyles.labelBadge.copyWith(letterSpacing: 1.5),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete your first 60-second evening debrief above.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DEBRIEF AUDIT LOG (${entries.length})',
              style: AppTextStyles.labelBadge.copyWith(letterSpacing: 1.5),
            ),
            Text(
              'STORED LOCALLY ON-DEVICE',
              style: AppTextStyles.labelBadge.copyWith(
                fontSize: 9.0,
                color: AppColors.emeraldSuccess,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _buildEntryCard(context, entry);
          },
        ),
      ],
    );
  }

  Widget _buildEntryCard(BuildContext context, JournalEntry entry) {
    final composite = entry.compositeScore;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & Composite Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateHelpers.formatExecutiveDate(entry.timestamp).toUpperCase(),
                style: AppTextStyles.labelBadge.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10.0,
                  letterSpacing: 1.2,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      'EQUANIMITY: $composite%',
                      style: AppTextStyles.metricSmall.copyWith(
                        fontSize: 10.5,
                        color: composite >= 80
                            ? AppColors.emeraldSuccess
                            : (composite >= 50
                                  ? AppColors.shieldPrimary
                                  : AppColors.amberWarning),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      HapticService.lightImpact();
                      onDelete(entry.dateKey);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    color: AppColors.textDisabled,
                    splashRadius: 16,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Delete log',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Two Indices Side by Side
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REACTION CONTROL',
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 8.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${entry.reactionControl.toStringAsFixed(1)} / 10',
                            style: AppTextStyles.metricSmall.copyWith(
                              color: AppColors.shieldPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            entry.reactionLabel,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BOUNDARY RETAINED',
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 8.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${entry.boundaryRetained.toStringAsFixed(1)} / 10',
                            style: AppTextStyles.metricSmall.copyWith(
                              color: AppColors.emeraldSuccess,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            entry.boundaryLabel,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Core Output Quote
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  size: 14,
                  color: AppColors.shieldPrimary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    entry.coreOutput,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
