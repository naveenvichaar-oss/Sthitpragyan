import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';

/// GroundingBanner provides the core physiological reset instructions
/// mandated to break the acute amygdala hijacking reflex during corporate conflict.
class GroundingBanner extends StatelessWidget {
  const GroundingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderMedium, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.accessibility_new_rounded,
                size: 16,
                color: AppColors.shieldPrimary,
              ),
              const SizedBox(width: AppDimens.space8),
              Text(
                'SOMATIC GROUNDING ANCHOR',
                style: AppTextStyles.labelBadge.copyWith(
                  color: AppColors.shieldPrimary,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space12),

          // Primary Mandate Callout
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 20,
                  color: AppColors.emeraldSuccess,
                ),
                const SizedBox(width: AppDimens.space12),
                Expanded(
                  child: Text(
                    'Feet flat. Tongue on roof of mouth.',
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space12),

          // 4-Point Vagal Checklist
          _buildCheckItem(
            '1. FEET FLAT:',
            'Press soles firmly into the floor. Connect with gravity.',
          ),
          const SizedBox(height: AppDimens.space6),
          _buildCheckItem(
            '2. TONGUE PLACEMENT:',
            'Press tongue gently against the roof of mouth behind upper teeth. Disables throat constriction.',
          ),
          const SizedBox(height: AppDimens.space6),
          _buildCheckItem(
            '3. DROP SHOULDERS:',
            'Release neck and shoulder trapezius tension by 2 inches.',
          ),
          const SizedBox(height: AppDimens.space6),
          _buildCheckItem(
            '4. UNCLENCH JAW:',
            'Part teeth slightly. Release the bite reflex.',
          ),

          const SizedBox(height: AppDimens.space12),
          Text(
            'BIO-MECHANISM: Stimulates the vagal nerve complex, signaling the brainstem that you are physically safe, terminating adrenaline release.',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10.5,
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String label, String detail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelBadge.copyWith(
            color: AppColors.textPrimary,
            fontSize: 10.0,
          ),
        ),
        const SizedBox(width: AppDimens.space6),
        Expanded(
          child: Text(
            detail,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12.0,
            ),
          ),
        ),
      ],
    );
  }
}
