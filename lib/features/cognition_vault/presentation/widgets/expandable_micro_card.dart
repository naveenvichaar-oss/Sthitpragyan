import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/fallacy_and_model.dart';

/// ExpandableMicroCard renders a collapsible executive card
/// detailing either a Logical Fallacy or a Stoic Mental Model.
class ExpandableMicroCard extends StatefulWidget {
  final CognitionItem item;

  const ExpandableMicroCard({super.key, required this.item});

  @override
  State<ExpandableMicroCard> createState() => _ExpandableMicroCardState();
}

class _ExpandableMicroCardState extends State<ExpandableMicroCard> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    HapticService.selectionClick();
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFallacy = widget.item.type == CognitionType.fallacy;
    final isRoe = widget.item.type == CognitionType.rulesOfEngagement;
    final typeBadgeColor = isFallacy
        ? AppColors.roseDanger
        : isRoe
            ? AppColors.amberWarning
            : AppColors.shieldPrimary;
    final typeBadgeMuted = isFallacy
        ? AppColors.roseMuted
        : isRoe
            ? AppColors.amberMuted
            : AppColors.shieldGlow;
    final typeBadgeText = isFallacy
        ? 'LOGICAL FALLACY'
        : isRoe
            ? 'RULES OF ENGAGEMENT'
            : 'STOIC MODEL';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: _isExpanded
              ? typeBadgeColor.withOpacity(0.5)
              : AppColors.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleExpanded,
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Type Tag, Latin Name & Expand Indicator
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
                            color: typeBadgeMuted,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: typeBadgeColor.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            typeBadgeText,
                            style: AppTextStyles.labelBadge.copyWith(
                              color: typeBadgeColor,
                              fontSize: 9.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.item.latinName.toUpperCase(),
                          style: AppTextStyles.labelBadge.copyWith(
                            fontSize: 9.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.space8),

                // Main Title
                Text(
                  widget.item.title,
                  style: AppTextStyles.heading.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),

                // Subtitle
                Text(
                  widget.item.subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                // Expanded Details
                if (_isExpanded) ...[
                  const SizedBox(height: AppDimens.space16),
                  const Divider(color: AppColors.borderSubtle),
                  const SizedBox(height: AppDimens.space12),

                  // 1. Definition / Mechanism
                  Text(
                    'MECHANISM',
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 9.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.definition,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space12),

                  // 2. Corporate Manifestation
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimens.space12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(
                        AppDimens.radiusSmall,
                      ),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isFallacy
                              ? 'BOARDROOM TRAP'
                              : 'WORKPLACE MANIFESTATION',
                          style: AppTextStyles.labelBadge.copyWith(
                            color: isFallacy
                                ? AppColors.roseDanger
                                : AppColors.shieldPrimary,
                            fontSize: 9.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.item.corporateManifestation,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                            fontStyle: FontStyle.italic,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.space12),

                  // 3. Antidote Protocol
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimens.space12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(
                        AppDimens.radiusSmall,
                      ),
                      border: Border.all(
                        color: AppColors.emeraldSuccess.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              size: 13,
                              color: AppColors.emeraldSuccess,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isFallacy
                                  ? 'COUNTER-MOVE PROTOCOL'
                                  : '30-SECOND RESET DRILL',
                              style: AppTextStyles.labelBadge.copyWith(
                                color: AppColors.emeraldSuccess,
                                fontSize: 9.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.item.antidoteProtocol,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.space12),

                  // 4. Quick Maxim Banner
                  Row(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        size: 14,
                        color: AppColors.amberWarning,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.item.quickMaxim,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.space8),

                  // Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: widget.item.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#$tag',
                          style: AppTextStyles.labelBadge.copyWith(
                            fontSize: 8.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
