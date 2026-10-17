import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../shared/widgets/voice_tts_button.dart';
import '../../data/models/wisdom_entry.dart';
import '../../data/services/wisdom_vault_service.dart';

/// DailyWisdomCard displays the rotating "Wisdom of the Day" on the Dashboard
/// with a 1-tap "Set as Today's Affirmation" action.
class DailyWisdomCard extends StatefulWidget {
  final VoidCallback? onOpenVault;

  const DailyWisdomCard({
    super.key,
    this.onOpenVault,
  });

  @override
  State<DailyWisdomCard> createState() => _DailyWisdomCardState();
}

class _DailyWisdomCardState extends State<DailyWisdomCard> {
  final HiveStorage _storage = HiveStorage();
  late WisdomEntry _currentWisdom;
  int _wisdomIndex = 0;
  String? _activeAffirmationId;

  @override
  void initState() {
    super.initState();
    _loadInitialWisdom();
  }

  void _loadInitialWisdom() {
    final service = WisdomVaultService();
    _currentWisdom = service.getDailyWisdom();
    _activeAffirmationId = _storage.getDailyAffirmationId();
  }

  void _cycleNext() {
    HapticService.selectionClick();
    final entries = WisdomVaultService().getAllEntries();
    if (entries.isNotEmpty) {
      setState(() {
        _wisdomIndex = (_wisdomIndex + 1) % entries.length;
        _currentWisdom = entries[_wisdomIndex];
      });
    }
  }

  Future<void> _setAsAffirmation() async {
    HapticService.success();
    await _storage.setDailyAffirmation(
      id: _currentWisdom.id,
      title: _currentWisdom.title,
      text: _currentWisdom.translation,
      source: _currentWisdom.source,
    );

    setState(() {
      _activeAffirmationId = _currentWisdom.id;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.emeraldSuccess,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.loc.setAffirmationSuccess(_currentWisdom.title),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAffirmation = _activeAffirmationId == _currentWisdom.id;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: isAffirmation
              ? AppColors.emeraldSuccess.withOpacity(0.5)
              : AppColors.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      context.loc.wisdomOfTheDayTitle,
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.shieldPrimary,
                        fontSize: 8.5,
                      ),
                    ),
                  ),
                  if (isAffirmation) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldMuted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 11,
                            color: AppColors.emeraldSuccess,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            context.loc.todaysAffirmationTitle,
                            style: AppTextStyles.labelBadge.copyWith(
                              fontSize: 7.5,
                              color: AppColors.emeraldSuccess,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  VoiceTtsButton(
                    textToSpeak: '${_currentWisdom.title}. ${_currentWisdom.originalText}. ${_currentWisdom.translation}. Executive Takeaway: ${_currentWisdom.executiveTakeaway}',
                    audioTopicKey: 'wisdom_${_currentWisdom.id}',
                    tooltip: context.loc.listenWisdomReadout,
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    onPressed: _cycleNext,
                    visualDensity: VisualDensity.compact,
                    tooltip: context.loc.cycleNextWisdom,
                  ),
                  if (widget.onOpenVault != null)
                    IconButton(
                      icon: const Icon(
                        Icons.open_in_new_rounded,
                        size: 15,
                        color: AppColors.textMuted,
                      ),
                      onPressed: widget.onOpenVault,
                      visualDensity: VisualDensity.compact,
                      tooltip: context.loc.openWisdomVault,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Title & Source
          Text(
            _currentWisdom.title,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _currentWisdom.source,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),

          // Original Text / Shloka
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle.withOpacity(0.5)),
            ),
            child: Text(
              _currentWisdom.originalText,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                height: 1.4,
                color: AppColors.textPrimary.withOpacity(0.9),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Translation / Takeaway
          Text(
            _currentWisdom.executiveTakeaway,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Action Button: Set as Today's Affirmation
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isAffirmation ? null : _setAsAffirmation,
              icon: Icon(
                isAffirmation ? Icons.check_circle_rounded : Icons.star_border_rounded,
                size: 14,
                color: isAffirmation ? AppColors.emeraldSuccess : AppColors.shieldPrimary,
              ),
              label: Text(
                isAffirmation ? context.loc.affirmedForToday : context.loc.setAsTodaysAffirmation,
                style: AppTextStyles.button.copyWith(
                  fontSize: 10.5,
                  color: isAffirmation ? AppColors.emeraldSuccess : AppColors.shieldPrimary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isAffirmation
                      ? AppColors.emeraldSuccess.withOpacity(0.5)
                      : AppColors.shieldPrimary.withOpacity(0.5),
                ),
                backgroundColor: isAffirmation
                    ? AppColors.emeraldMuted.withOpacity(0.2)
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 8),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
