import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/haptic_service.dart';

/// IndexSlider is a high-precision executive evaluation slider
/// with dynamic qualitative status feedback and haptic feedback.
class IndexSlider extends StatelessWidget {
  final String indexNumber;
  final String title;
  final String description;
  final double value;
  final ValueChanged<double> onChanged;
  final String statusLabel;
  final Color statusColor;

  const IndexSlider({
    super.key,
    required this.indexNumber,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
    required this.statusLabel,
    required this.statusColor,
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
          // Header with Index Tag and Numeric Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
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
                      indexNumber,
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.shieldPrimary,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppTextStyles.heading.copyWith(fontSize: 14.5),
                  ),
                ],
              ),
              Text(
                '${value.toStringAsFixed(1)} / 10',
                style: AppTextStyles.metricMedium.copyWith(
                  color: statusColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space6),

          // Question Prompt
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12.0,
            ),
          ),
          const SizedBox(height: AppDimens.space12),

          // Slider Track
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: statusColor,
              thumbColor: AppColors.textPrimary,
              overlayColor: statusColor.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 10.0,
              divisions: 20, // 0.5 increments
              onChanged: (newValue) {
                if (newValue != value) {
                  HapticService.lightImpact();
                  onChanged(newValue);
                }
              },
            ),
          ),

          // Qualitative Dynamic Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0.0: COMPROMISED',
                style: AppTextStyles.labelBadge.copyWith(
                  fontSize: 9.0,
                  color: AppColors.textDisabled,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  statusLabel.toUpperCase(),
                  style: AppTextStyles.labelBadge.copyWith(
                    color: statusColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '10.0: IMPASSIVE',
                style: AppTextStyles.labelBadge.copyWith(
                  fontSize: 9.0,
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
