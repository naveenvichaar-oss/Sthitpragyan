import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../data/models/streak_data.dart';

/// StreakBadge displays consecutive days of strategic equanimity,
/// a 7-day visual dot matrix, and boundary retention metrics.
class StreakBadge extends StatelessWidget {
  final StreakData streakData;

  const StreakBadge({super.key, required this.streakData});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final last7Days = DateHelpers.getLast7Days(now);

    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${streakData.currentStreak}',
                    style: AppTextStyles.metricLarge.copyWith(
                      color: AppColors.shieldPrimary,
                    ),
                  ),
                  const SizedBox(width: AppDimens.space8),
                  Text(
                    streakData.currentStreak == 1
                        ? (context.loc.isHindi ? 'दिवस समत्व' : 'DAY STREAK')
                        : (context.loc.isHindi ? 'दिवसीय समत्व' : 'DAYS STREAK'),
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(
                  context.loc.isHindi
                      ? 'सर्वश्रेष्ठ: ${streakData.longestStreak} दिन'
                      : 'BEST: ${streakData.longestStreak} D',
                  style: AppTextStyles.metricSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space16),
          // 7-Day Dot Matrix
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(last7Days.length, (index) {
              final date = last7Days[index];
              final dateKey = DateHelpers.toStorageKey(date);
              final isCompleted = streakData.historyMap[dateKey] == true;
              final isToday = DateHelpers.isSameDay(date, now);
              final dayLetter = [
                'M',
                'T',
                'W',
                'T',
                'F',
                'S',
                'S',
              ][date.weekday - 1];

              return Column(
                children: [
                  Text(
                    dayLetter,
                    style: AppTextStyles.labelBadge.copyWith(
                      fontSize: 10,
                      color: isToday
                          ? AppColors.shieldPrimary
                          : AppColors.textMuted,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.emeraldSuccess
                          : (isToday
                                ? AppColors.surfaceHover
                                : AppColors.surfaceElevated),
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.emeraldSuccess
                            : (isToday
                                  ? AppColors.shieldPrimary
                                  : AppColors.borderSubtle),
                        width: isToday ? 1.5 : 1.0,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 13,
                            color: AppColors.background,
                          )
                        : (isToday
                              ? Container(
                                  margin: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.shieldPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: AppDimens.space12),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: AppDimens.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RETENTION INDEX',
                style: AppTextStyles.labelBadge.copyWith(fontSize: 9.5),
              ),
              Text(
                streakData.weeklyBoundaryRetentionRate > 0
                    ? '${streakData.weeklyBoundaryRetentionRate.toStringAsFixed(0)}% BOUNDARY INTACT'
                    : 'AWAITING TODAY\'S DEBRIEF',
                style: AppTextStyles.metricSmall.copyWith(
                  fontSize: 11,
                  color: streakData.weeklyBoundaryRetentionRate >= 80
                      ? AppColors.emeraldSuccess
                      : (streakData.weeklyBoundaryRetentionRate >= 50
                            ? AppColors.amberWarning
                            : AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
