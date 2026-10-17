import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../shared/widgets/voice_tts_button.dart';
import '../../data/defensive_scripts_vault.dart';

/// ResponseScriptCard renders an actionable verbatim executive deflection script.
class ResponseScriptCard extends StatefulWidget {
  final DefensiveScript script;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;

  const ResponseScriptCard({
    super.key,
    required this.script,
    required this.isBookmarked,
    required this.onToggleBookmark,
  });

  @override
  State<ResponseScriptCard> createState() => _ResponseScriptCardState();
}

class _ResponseScriptCardState extends State<ResponseScriptCard> {
  bool _justCopied = false;

  Future<void> _copyScriptToClipboard() async {
    HapticService.lightImpact();
    await Clipboard.setData(ClipboardData(text: widget.script.executiveScript));

    if (mounted) {
      setState(() {
        _justCopied = true;
      });

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Script copied to clipboard: "${widget.script.category}"',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.background,
            ),
          ),
          backgroundColor: AppColors.textPrimary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) {
          setState(() {
            _justCopied = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category Tag, Bookmark & Copy
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.space16,
              AppDimens.space12,
              AppDimens.space8,
              0,
            ),
            child: Row(
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
                    widget.script.category.toUpperCase(),
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.shieldPrimary,
                      fontSize: 9.5,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VoiceTtsButton(
                      textToSpeak: widget.script.executiveScript,
                      size: 19,
                      color: AppColors.textMuted,
                      tooltip: 'Listen to deflection script',
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () {
                        HapticService.selectionClick();
                        widget.onToggleBookmark();
                      },
                      icon: Icon(
                        widget.isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 20,
                        color: widget.isBookmarked
                            ? AppColors.shieldPrimary
                            : AppColors.textMuted,
                      ),
                      splashRadius: 18,
                      tooltip: 'Bookmark Script',
                    ),
                    IconButton(
                      onPressed: _copyScriptToClipboard,
                      icon: Icon(
                        _justCopied
                            ? Icons.check_circle_rounded
                            : Icons.copy_rounded,
                        size: 18,
                        color: _justCopied
                            ? AppColors.emeraldSuccess
                            : AppColors.textSecondary,
                      ),
                      splashRadius: 18,
                      tooltip: 'Copy Script',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Hostile Trigger / Context
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HOSTILE TRIGGER',
                  style: AppTextStyles.labelBadge.copyWith(
                    color: AppColors.roseDanger,
                    fontSize: 9.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.script.hostileTrigger,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space12),

          // The Verbatim Executive Script
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: AppDimens.space12),
            padding: const EdgeInsets.all(AppDimens.space14),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              border: Border.all(color: AppColors.borderMedium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'VERBATIM SCRIPT',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.shieldPrimary,
                        fontSize: 9.0,
                      ),
                    ),
                    if (_justCopied)
                      Text(
                        'COPIED TO CLIPBOARD',
                        style: AppTextStyles.labelBadge.copyWith(
                          color: AppColors.emeraldSuccess,
                          fontSize: 9.0,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '"${widget.script.executiveScript}"',
                  style: AppTextStyles.scriptVerbatim,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space12),

          // Rationale & Tone Guidance
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.space16,
              0,
              AppDimens.space16,
              AppDimens.space16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WHY IT WORKS: ',
                      style: AppTextStyles.labelBadge.copyWith(
                        fontSize: 9.5,
                        color: AppColors.shieldPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.script.tacticalRationale,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DELIVERY: ',
                      style: AppTextStyles.labelBadge.copyWith(
                        fontSize: 9.0,
                        color: AppColors.amberWarning,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.script.toneGuidance,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
