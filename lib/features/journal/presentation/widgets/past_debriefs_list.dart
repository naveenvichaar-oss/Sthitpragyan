import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/journal_models.dart';

/// PastDebriefsList renders historical 3-Index evening logs based on the official schema.
class PastDebriefsList extends StatelessWidget {
  final List<DailyJournalEntry> entries;
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
              'कोई पूर्व दैनिक हिसाब उपलब्ध नहीं (NO LOGS YET)',
              style: AppTextStyles.labelBadge.copyWith(letterSpacing: 1.5),
            ),
            const SizedBox(height: 4),
            Text(
              'आज का 60-सेकंड हिसाब ऊपर पूरा करें।',
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
              'दैनिक हिसाब इतिहास (${entries.length})',
              style: AppTextStyles.labelBadge.copyWith(letterSpacing: 1.5),
            ),
            Text(
              '100% OFFLINE • ON-DEVICE HIVE',
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

  Widget _buildEntryCard(BuildContext context, DailyJournalEntry entry) {
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
                DateHelpers.formatExecutiveDate(entry.createdAt).toUpperCase(),
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
                      onDelete(entry.entryDate);
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
                        'REACTION SCORE',
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
                            '${entry.reactionControlScore} / 5',
                            style: AppTextStyles.metricSmall.copyWith(
                              color: entry.reactionControlScore >= 4
                                  ? AppColors.emeraldSuccess
                                  : (entry.reactionControlScore >= 3
                                        ? AppColors.shieldPrimary
                                        : AppColors.amberWarning),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              entry.reactionLabel,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 9.5,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                        'BOUNDARY CHECK',
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
                            entry.boundaryMaintained
                                ? 'हाँ (YES)'
                                : 'नहीं (NO)',
                            style: AppTextStyles.metricSmall.copyWith(
                              color: entry.boundaryMaintained
                                  ? AppColors.emeraldSuccess
                                  : AppColors.roseDanger,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              entry.boundaryLabel,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 9.5,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 13,
                      color: AppColors.shieldPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ठोस मौलिक आउटपुट (CORE DELIVERABLE)',
                      style: AppTextStyles.labelBadge.copyWith(
                        fontSize: 8.5,
                        color: AppColors.shieldPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.coreOutputSummary,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (entry.provocationHandled != null &&
                    entry.provocationHandled!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  const Divider(color: AppColors.borderSubtle),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 12,
                        color: AppColors.amberWarning,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'रणनीतिक सीख: ${entry.provocationHandled}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (entry.audioMemoPath != null ||
                    entry.videoReflectionPath != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (entry.audioMemoPath != null)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldSuccess.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.mic_rounded,
                                size: 10,
                                color: AppColors.emeraldSuccess,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'AUDIO MEMO',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: AppColors.emeraldSuccess,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (entry.videoReflectionPath != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.shieldPrimary.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.videocam_rounded,
                                size: 10,
                                color: AppColors.shieldPrimary,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'VIDEO DRILL',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: AppColors.shieldPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
