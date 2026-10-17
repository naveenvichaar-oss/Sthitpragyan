import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../shared/widgets/voice_tts_button.dart';
import '../../data/models/wisdom_entry.dart';

/// WisdomCard displays a structured entry from the Wisdom Vault with
/// Sanskrit shloka/original text, translation, and executive takeaway.
class WisdomCard extends StatefulWidget {
  final WisdomEntry entry;
  final bool isAffirmation;
  final VoidCallback? onSetAffirmation;

  const WisdomCard({
    super.key,
    required this.entry,
    this.isAffirmation = false,
    this.onSetAffirmation,
  });

  @override
  State<WisdomCard> createState() => _WisdomCardState();
}

class _WisdomCardState extends State<WisdomCard> {
  bool _isExpanded = false;

  void _copyToClipboard(BuildContext context) {
    HapticService.selectionClick();
    final isHi = context.loc.isHindi;
    final text =
        '${widget.entry.getTitle(isHi)}\n${widget.entry.getSubtitle(isHi)}\n\n"${widget.entry.originalText}"\n\n${context.loc.essenceTranslation}: ${widget.entry.getTranslation(isHi)}\n\n${context.loc.executiveActionTakeaway}: ${widget.entry.getExecutiveTakeaway(isHi)}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.emeraldSuccess, size: 16),
            const SizedBox(width: 8),
            Text(isHi ? 'प्रज्ञा क्लिपबोर्ड पर कॉपी की गई' : 'Copied wisdom to clipboard', style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: AppColors.surfaceElevated,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (widget.entry.category) {
      case 'gita':
        return const Color(0xFFF59E0B); // Amber / Gold
      case 'western_stoicism':
        return const Color(0xFF38BDF8); // Sky blue
      case 'psychology_behavioral':
        return const Color(0xFFA78BFA); // Purple
      default:
        return AppColors.shieldPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: widget.isAffirmation
              ? AppColors.emeraldSuccess.withOpacity(0.6)
              : AppColors.borderSubtle,
          width: widget.isAffirmation ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          onTap: () {
            HapticService.selectionClick();
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.space14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Category Pill & Affirmation Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: catColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        widget.entry.categoryName.toUpperCase(),
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 8.5,
                          color: catColor,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (widget.isAffirmation)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(right: 6),
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
                                  'AFFIRMATION',
                                  style: AppTextStyles.labelBadge.copyWith(
                                    fontSize: 8,
                                    color: AppColors.emeraldSuccess,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        VoiceTtsButton(
                          textToSpeak:
                              '${widget.entry.getTitle(context.loc.isHindi)}. ${widget.entry.originalText}. ${widget.entry.getTranslation(context.loc.isHindi)}. ${widget.entry.getExecutiveTakeaway(context.loc.isHindi)}',
                          audioTopicKey: 'wisdom_${widget.entry.id}',
                          size: 16,
                          tooltip: context.loc.listenWisdomReadout,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.copy_rounded,
                            size: 15,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () => _copyToClipboard(context),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Title & Source
                Text(
                  widget.entry.getTitle(context.loc.isHindi),
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.entry.getSubtitle(context.loc.isHindi),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),

                // Original Shloka / Text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderSubtle.withOpacity(0.5)),
                  ),
                  child: Text(
                    widget.entry.originalText,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      height: 1.45,
                      color: AppColors.textPrimary.withOpacity(0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Executive Takeaway Preview / Full
                Text(
                  widget.entry.getExecutiveTakeaway(context.loc.isHindi),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: _isExpanded ? null : 2,
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),

                // Expanded Section: Translation & Tags & Action Button
                if (_isExpanded) ...[
                  const SizedBox(height: 10),
                  Text(
                    context.loc.essenceTranslation,
                    style: AppTextStyles.labelBadge.copyWith(
                      fontSize: 8.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.entry.getTranslation(context.loc.isHindi),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tags
                  if (widget.entry.tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: widget.entry.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Text(
                            '#$tag',
                            style: AppTextStyles.labelBadge.copyWith(
                              fontSize: 8.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 12),

                  // "Set as Today's Affirmation" Action Button
                  if (widget.onSetAffirmation != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticService.success();
                          widget.onSetAffirmation!();
                        },
                        icon: Icon(
                          widget.isAffirmation
                              ? Icons.check_circle_rounded
                              : Icons.bookmark_add_outlined,
                          size: 15,
                          color: widget.isAffirmation
                              ? AppColors.emeraldSuccess
                              : AppColors.shieldPrimary,
                        ),
                        label: Text(
                          widget.isAffirmation
                              ? 'ACTIVE DAILY AFFIRMATION'
                              : 'SET AS TODAY\'S AFFIRMATION',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 10.5,
                            color: widget.isAffirmation
                                ? AppColors.emeraldSuccess
                                : AppColors.shieldPrimary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: widget.isAffirmation
                                ? AppColors.emeraldSuccess
                                : AppColors.shieldPrimary.withOpacity(0.5),
                          ),
                          backgroundColor: widget.isAffirmation
                              ? AppColors.emeraldMuted.withOpacity(0.3)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
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
