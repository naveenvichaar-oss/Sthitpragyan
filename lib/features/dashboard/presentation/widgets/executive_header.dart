import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../shared/widgets/language_switcher_widget.dart';

/// ExecutiveHeader presents a high-status, austere brand marker,
/// instant language switcher (EN | HI), and real-time operational status.
class ExecutiveHeader extends StatelessWidget {
  final VoidCallback? onSettingsTap;

  const ExecutiveHeader({super.key, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final loc = context.loc;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space20,
        vertical: AppDimens.space12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Brand title & date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.0,
                    height: 7.0,
                    decoration: const BoxDecoration(
                      color: AppColors.shieldPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shieldGlow,
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.space8),
                  Text(loc.brandMarker, style: AppTextStyles.brandHeader),
                ],
              ),
              const SizedBox(height: AppDimens.space4),
              Text(
                DateHelpers.formatExecutiveDate(today).toUpperCase(),
                style: AppTextStyles.labelBadge.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
          // Action Controls: Compact Language Switcher + Settings Icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LanguageSwitcherWidget(isCompact: true),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onSettingsTap,
                icon: const Icon(Icons.tune_rounded, size: 20),
                color: AppColors.textSecondary,
                tooltip: loc.navSettings,
                splashRadius: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
