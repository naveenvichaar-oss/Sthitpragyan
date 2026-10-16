import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';

/// SingleLineOutputInput implements the strict single-line constraint for
/// Index 3: "Core Output". Prohibits rambling or doom-journaling.
class SingleLineOutputInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const SingleLineOutputInput({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
            children: [
              Row(
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
                    child: Text(
                      'INDEX 03',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.shieldPrimary,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CORE OUTPUT',
                    style: AppTextStyles.heading.copyWith(fontSize: 14.5),
                  ),
                ],
              ),
              Text(
                'SINGLE-LINE ONLY',
                style: AppTextStyles.labelBadge.copyWith(
                  fontSize: 9.0,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space6),
          Text(
            'The single decisive win, lesson, or boundary preserved today (max 140 chars).',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12.0,
            ),
          ),
          const SizedBox(height: AppDimens.space12),

          // High-precision Single Line Field
          TextField(
            controller: controller,
            maxLines: 1,
            maxLength: 140,
            onChanged: onChanged,
            textInputAction: TextInputAction.done,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'e.g., Paused 4s in VP meeting; refused unpaid weekend scope.',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
              counterStyle: AppTextStyles.metricSmall.copyWith(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
              prefixIcon: const Icon(
                Icons.bolt_rounded,
                size: 18,
                color: AppColors.shieldPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
