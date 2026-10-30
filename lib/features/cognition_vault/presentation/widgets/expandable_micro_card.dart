import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../journal/presentation/widgets/audio_memo_recorder_modal.dart';
import '../../../journal/presentation/widgets/video_reflection_drill_modal.dart';
import '../../data/models/fallacy_and_model.dart';
import 'add_cognition_item_modal_sheet.dart';

/// ExpandableMicroCard renders a collapsible executive card
/// detailing either a Logical Fallacy or a classic Mental Model.
/// Supports complete CRUD, audio voice attachments, and video drill attachments.
class ExpandableMicroCard extends StatefulWidget {
  final CognitionItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final void Function(CognitionItem updated)? onItemUpdated;

  const ExpandableMicroCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
    this.onItemUpdated,
  });

  @override
  State<ExpandableMicroCard> createState() => _ExpandableMicroCardState();
}

class _ExpandableMicroCardState extends State<ExpandableMicroCard> {
  bool _isExpanded = false;
  AudioPlayer? _audioPlayer;
  bool _isPlayingAudio = false;

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    HapticService.selectionClick();
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Future<void> _toggleAudioPlayback() async {
    final audioPath = widget.item.audioAttachmentPath;
    if (audioPath == null) return;
    HapticService.selectionClick();

    _audioPlayer ??= AudioPlayer();

    if (_isPlayingAudio) {
      await _audioPlayer!.pause();
      setState(() => _isPlayingAudio = false);
    } else {
      _audioPlayer!.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlayingAudio = false);
      });
      await _audioPlayer!.play(DeviceFileSource(audioPath));
      setState(() => _isPlayingAudio = true);
    }
  }

  Future<void> _recordAudioAttachment() async {
    HapticService.selectionClick();
    final result = await AudioMemoRecorderModal.show(
      context,
      existingPath: widget.item.audioAttachmentPath,
    );
    if (result != null) {
      final updated = widget.item.copyWith(audioAttachmentPath: result);
      await HiveStorage().saveCognitionItem(updated);
      widget.onItemUpdated?.call(updated);
      setState(() {});
    }
  }

  Future<void> _recordVideoAttachment() async {
    HapticService.selectionClick();
    final result = await VideoReflectionDrillModal.show(context);
    if (result != null) {
      final updated = widget.item.copyWith(videoAttachmentPath: result);
      await HiveStorage().saveCognitionItem(updated);
      widget.onItemUpdated?.call(updated);
      setState(() {});
    }
  }

  void _openEditModal() {
    HapticService.selectionClick();
    AddCognitionItemModalSheet.show(
      context,
      initialType: widget.item.type,
      itemToEdit: widget.item,
      onSaved: (saved) {
        widget.onItemUpdated?.call(saved);
        setState(() {});
      },
    );
  }

  void _confirmDelete() {
    HapticService.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: Text(
          context.loc.deleteFrameworkCardTitle,
          style: AppTextStyles.heading.copyWith(fontSize: 16),
        ),
        content: Text(
          context.loc.removeVaultItemConfirm(widget.item.title),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              context.loc.cancelButton,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.roseDanger,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await HiveStorage().deleteCognitionItem(widget.item.id);
              widget.onDelete?.call();
            },
            child: Text(context.loc.deleteAction),
          ),
        ],
      ),
    );
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
        ? context.loc.logicalFallacyBadge
        : isRoe
            ? context.loc.rulesOfEngagementBadge
            : context.loc.mentalModelBadge;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: _isExpanded
              ? typeBadgeColor.withValues(alpha: 0.5)
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
                // Top Row: Type Tag, Latin Name & Actions
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
                              color: typeBadgeColor.withValues(alpha: 0.4),
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
                            fontSize: 9.0,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: AppColors.surfaceElevated,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: AppColors.borderSubtle),
                          ),
                          onSelected: (val) {
                            if (val == 'edit') {
                              _openEditModal();
                            } else if (val == 'delete') {
                              _confirmDelete();
                            }
                          },
                          itemBuilder: (ctx) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_outlined, size: 15, color: AppColors.shieldPrimary),
                                  const SizedBox(width: 8),
                                  Text(context.loc.editAction, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_outline_rounded, size: 15, color: AppColors.roseDanger),
                                  const SizedBox(width: 8),
                                  Text(context.loc.deleteAction, style: const TextStyle(fontSize: 12, color: AppColors.roseDanger)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _isExpanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ],
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
                  const SizedBox(height: AppDimens.space14),
                  const Divider(color: AppColors.borderSubtle),
                  const SizedBox(height: AppDimens.space10),

                  // 1. Definition / Core Principle
                  Text(
                    context.loc.corePrincipleBadge,
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

                  // 2. Real Life Scenario
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
                              ? context.loc.realLifeScenarioBadge
                              : context.loc.practicalApplicationBadge,
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

                  // 3. Counter-Strategy / Action Protocol
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimens.space12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(
                        AppDimens.radiusSmall,
                      ),
                      border: Border.all(
                        color: AppColors.emeraldSuccess.withValues(alpha: 0.3),
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
                                  ? context.loc.counterStrategyBadge
                                  : context.loc.actionProtocolBadge,
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
                  const SizedBox(height: AppDimens.space12),

                  // 5. Multimodal Attachments Bar (Audio & Video)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        // Audio memo explainer
                        if (widget.item.audioAttachmentPath != null) ...[
                          IconButton(
                            icon: Icon(
                              _isPlayingAudio ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                              color: AppColors.shieldPrimary,
                              size: 24,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _toggleAudioPlayback,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            context.loc.audioNoteLabel,
                            style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                          ),
                          const Spacer(),
                        ] else ...[
                          OutlinedButton.icon(
                            onPressed: _recordAudioAttachment,
                            icon: const Icon(Icons.mic_none_rounded, size: 14),
                            label: Text(context.loc.addVoiceNoteAction),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.borderSubtle),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              visualDensity: VisualDensity.compact,
                              textStyle: const TextStyle(fontSize: 10.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Video drill explainer
                        if (widget.item.videoAttachmentPath != null) ...[
                          const Icon(Icons.videocam_rounded, size: 16, color: Color(0xFF10B981)),
                          const SizedBox(width: 4),
                          Text(
                            context.loc.videoAttachedLabel,
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF10B981)),
                          ),
                        ] else ...[
                          OutlinedButton.icon(
                            onPressed: _recordVideoAttachment,
                            icon: const Icon(Icons.videocam_outlined, size: 14),
                            label: Text(context.loc.addVideoDrillAction),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.borderSubtle),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              visualDensity: VisualDensity.compact,
                              textStyle: const TextStyle(fontSize: 10.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.space10),

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
