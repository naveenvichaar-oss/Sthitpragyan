import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_controller.dart';
import '../../core/utils/haptic_service.dart';

/// LanguageSwitcherWidget renders a discreet, high-status bilingual toggle (EN | HI).
/// Supports both compact pill mode (for App Header) and full card mode (for Settings).
class LanguageSwitcherWidget extends StatelessWidget {
  final bool isCompact;

  const LanguageSwitcherWidget({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleController.instance,
      builder: (context, _) {
        final isHindi = LocaleController.instance.isHindi;

        if (isCompact) {
          return _buildCompactToggle(context, isHindi);
        }
        return _buildSettingsCard(context, isHindi);
      },
    );
  }

  /// Compact segmented pill for ExecutiveHeader
  Widget _buildCompactToggle(BuildContext context, bool isHindi) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegmentButton(
            label: 'EN',
            isActive: !isHindi,
            onTap: () {
              if (isHindi) {
                HapticService.selectionClick();
                LocaleController.instance.setLocale(const Locale('en'));
              }
            },
          ),
          Container(
            width: 1,
            height: 16,
            color: AppColors.borderSubtle,
          ),
          _buildSegmentButton(
            label: 'HI',
            isActive: isHindi,
            onTap: () {
              if (!isHindi) {
                HapticService.selectionClick();
                LocaleController.instance.setLocale(const Locale('hi'));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.shieldPrimary.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.shieldPrimary : AppColors.textMuted,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  /// Full-width settings section card
  Widget _buildSettingsCard(BuildContext context, bool isHindi) {
    final loc = context.loc;

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
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(
                      Icons.translate_rounded,
                      color: AppColors.shieldPrimary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.languageSectionTitle,
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 10.5,
                          color: AppColors.shieldPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        loc.activeLanguageLabel,
                        style: AppTextStyles.heading.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              _buildCompactToggle(context, isHindi),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            loc.languageSectionSub,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLanguageOptionCard(
                  title: 'English (US)',
                  subtitle: 'Stoic Executive Shield',
                  isSelected: !isHindi,
                  onTap: () {
                    HapticService.selectionClick();
                    LocaleController.instance.setLocale(const Locale('en'));
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildLanguageOptionCard(
                  title: 'हिन्दी (Hindi)',
                  subtitle: 'स्थितप्रज्ञ निष्काम कवच',
                  isSelected: isHindi,
                  onTap: () {
                    HapticService.selectionClick();
                    LocaleController.instance.setLocale(const Locale('hi'));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOptionCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.shieldPrimary.withValues(alpha: 0.12)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.shieldPrimary : AppColors.borderSubtle,
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 14,
                  color: isSelected
                      ? AppColors.shieldPrimary
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.shieldPrimary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
