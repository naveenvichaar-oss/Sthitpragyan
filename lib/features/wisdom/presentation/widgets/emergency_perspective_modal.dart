import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../shared/widgets/voice_tts_button.dart';
import '../../data/models/wisdom_entry.dart';
import '../../data/services/wisdom_vault_service.dart';

/// EmergencyPerspectiveModal displays a rapid 60-second stoic cognitive reset
/// focused on de-escalating shame, detaching ego, and regaining emotional sovereignty.
class EmergencyPerspectiveModal extends StatefulWidget {
  const EmergencyPerspectiveModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusLarge),
        ),
      ),
      builder: (context) => const EmergencyPerspectiveModal(),
    );
  }

  @override
  State<EmergencyPerspectiveModal> createState() =>
      _EmergencyPerspectiveModalState();
}

class _EmergencyPerspectiveModalState extends State<EmergencyPerspectiveModal> {
  int _currentIndex = 0;
  late List<WisdomEntry> _perspectives;

  @override
  void initState() {
    super.initState();
    final allEmergencies = WisdomVaultService().getEmergencyPerspectives();
    if (allEmergencies.isNotEmpty) {
      _perspectives = allEmergencies;
    } else {
      _perspectives = WisdomVaultService().getAllEntries();
    }
  }

  void _next() {
    HapticService.selectionClick();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _perspectives.length;
    });
  }

  void _previous() {
    HapticService.selectionClick();
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _perspectives.length) % _perspectives.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_perspectives.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text('No entries')));
    }

    final entry = _perspectives[_currentIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: AppDimens.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.amberWarning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: AppColors.amberWarning,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.loc.emergencyPerspectiveBadge,
                        style: AppTextStyles.labelBadge.copyWith(
                          color: AppColors.amberWarning,
                          letterSpacing: 1.5,
                          fontSize: 9.0,
                        ),
                      ),
                      Text(
                        context.loc.detachEgoRegainFrame,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VoiceTtsButton(
                    textToSpeak:
                        '${entry.getTitle(context.loc.isHindi)}. ${entry.originalText}. ${entry.getTranslation(context.loc.isHindi)}. ${entry.getExecutiveTakeaway(context.loc.isHindi)}',
                    audioTopicKey: 'wisdom_${entry.id}',
                    size: 20,
                    tooltip: context.loc.listenToEmergencyPerspective,
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress indicator dots / chips
          Row(
            children: List.generate(_perspectives.length, (index) {
              final isActive = index == _currentIndex;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.amberWarning
                        : AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // Main Card Content
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimens.space16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                border: Border.all(
                  color: AppColors.amberWarning.withOpacity(0.3),
                  width: 1.0,
                ),
              ),
              child: ListView(
                children: [
                  // Source & Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          entry.categoryName.toUpperCase(),
                          style: AppTextStyles.labelBadge.copyWith(
                            fontSize: 8.5,
                            color: AppColors.shieldPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${_currentIndex + 1} OF ${_perspectives.length}',
                        style: AppTextStyles.metricSmall.copyWith(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    entry.getTitle(context.loc.isHindi),
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.getSubtitle(context.loc.isHindi),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Original Quote Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.amberWarning.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      '"${entry.originalText}"',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 13.5,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Translation
                  Text(
                    context.loc.essenceTranslation,
                    style: AppTextStyles.labelBadge.copyWith(
                      fontSize: 8.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.getTranslation(context.loc.isHindi),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.5,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Executive Application Takeaway
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.psychology_rounded,
                              size: 14,
                              color: AppColors.shieldPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              context.loc.executiveActionTakeaway,
                              style: AppTextStyles.labelBadge.copyWith(
                                color: AppColors.shieldPrimary,
                                fontSize: 8.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.getExecutiveTakeaway(context.loc.isHindi),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Bottom Controls: Prev / Next / Reclaim
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _previous,
                icon: const Icon(Icons.arrow_back_rounded, size: 14),
                label: Text(context.loc.prevAction),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.borderSubtle),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _next,
                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                label: Text(context.loc.nextAction),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.borderSubtle),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticService.success();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text(context.loc.frameRestoredAction),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.amberWarning,
                    foregroundColor: AppColors.background,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
