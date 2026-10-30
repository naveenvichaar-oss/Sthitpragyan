import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/joy_item.dart';
import '../../data/services/joy_audio_service.dart';

/// JoyItemCard renders a personal emotional anchor:
/// - Offline local audio files with inline playback controls (Play, Pause, Stop, Seek)
/// - YouTube and YouTube Music tracks with one-tap native app launching
/// - Visual memories with tap-to-expand image viewer
/// - Comfort words and quotes in serene typography
class JoyItemCard extends StatelessWidget {
  final JoyItem item;
  final VoidCallback onDelete;

  const JoyItemCard({
    super.key,
    required this.item,
    required this.onDelete,
  });

  bool get _hasMedia =>
      item.mediaUrlOrPath != null && item.mediaUrlOrPath!.trim().isNotEmpty;

  Future<void> _launchExternalMedia(BuildContext context) async {
    if (!_hasMedia) return;
    HapticService.selectionClick();

    final rawUrl = item.mediaUrlOrPath!.trim();
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.loc.invalidResourceUrl),
            backgroundColor: AppColors.roseDanger,
          ),
        );
      }
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('[JoyItemCard] External launch error: $e');
      if (context.mounted) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    }
  }

  void _showImageDialog(BuildContext context) {
    if (!_hasMedia) return;
    HapticService.selectionClick();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppDimens.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              child: Image.network(
                item.mediaUrlOrPath!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  padding: const EdgeInsets.all(24),
                  color: AppColors.surfaceElevated,
                  child: Text(
                    context.loc.unableToLoadImage,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ),
            if (item.title.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (item.note != null && item.note!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                item.note!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    HapticService.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(context.loc.removeAnchorTitle, style: AppTextStyles.heading),
        content: Text(
          '${context.loc.removeAnchorConfirm}\n\n"${item.title}"',
          style: AppTextStyles.bodyMedium,
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
            onPressed: () {
              // Stop audio if currently playing this item
              if (JoyAudioService().isActive(item.id)) {
                JoyAudioService().stop();
              }
              Navigator.of(ctx).pop();
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.roseDanger,
              foregroundColor: Colors.white,
            ),
            child: Text(context.loc.removeButton),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalAudioPlayer(BuildContext context, Color catColor) {
    return ListenableBuilder(
      listenable: JoyAudioService(),
      builder: (context, _) {
        final audioService = JoyAudioService();
        final isPlaying = audioService.isPlaying(item.id);
        final isPaused = audioService.isPaused(item.id);
        final isActive = audioService.isActive(item.id);

        final currentPos = isActive ? audioService.position : Duration.zero;
        final totalDuration = isActive ? audioService.duration : Duration.zero;

        final posSec = currentPos.inSeconds.toDouble();
        final maxSec = totalDuration.inSeconds.toDouble() > 0
            ? totalDuration.inSeconds.toDouble()
            : 1.0;
        final sliderValue = posSec.clamp(0.0, maxSec);

        final fileName = item.mediaUrlOrPath != null
            ? item.mediaUrlOrPath!.split(Platform.pathSeparator).last
            : '';

        return Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(AppDimens.space12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            border: Border.all(
              color: isActive
                  ? AppColors.shieldPrimary.withValues(alpha: 0.6)
                  : AppColors.borderSubtle,
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Audio File Info Row
              Row(
                children: [
                  Icon(
                    isPlaying
                        ? Icons.graphic_eq_rounded
                        : Icons.audiotrack_rounded,
                    size: 16,
                    color: isPlaying ? AppColors.shieldPrimary : catColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName.isNotEmpty ? fileName : context.loc.localAudioFile,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.shieldPrimary.withValues(alpha: 0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      isPlaying
                          ? context.loc.nowPlaying.toUpperCase()
                          : isPaused
                              ? context.loc.pausedStatus.toUpperCase()
                              : context.loc.localAudioAnchor.toUpperCase(),
                      style: AppTextStyles.labelBadge.copyWith(
                        fontSize: 8,
                        color: isPlaying
                            ? AppColors.shieldPrimary
                            : AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Seek Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3.0,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                  activeTrackColor: AppColors.shieldPrimary,
                  inactiveTrackColor: AppColors.borderSubtle,
                  thumbColor: AppColors.shieldPrimary,
                  overlayColor: AppColors.shieldPrimary.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: sliderValue,
                  max: maxSec,
                  onChanged: isActive && totalDuration.inSeconds > 0
                      ? (val) {
                          audioService.seek(Duration(seconds: val.toInt()));
                        }
                      : null,
                ),
              ),

              // Controls & Timers Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    JoyAudioService.formatDuration(currentPos),
                    style: AppTextStyles.labelBadge.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      // Play / Pause Button
                      IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_filled_rounded,
                          size: 32,
                          color: AppColors.shieldPrimary,
                        ),
                        tooltip: isPlaying
                            ? context.loc.pauseAudio
                            : context.loc.playAudio,
                        onPressed: () {
                          HapticService.selectionClick();
                          if (isPlaying) {
                            audioService.pause();
                          } else {
                            audioService.playLocal(
                              joyId: item.id,
                              filePath: item.mediaUrlOrPath!,
                            );
                          }
                        },
                      ),
                      // Stop Button
                      if (isActive)
                        IconButton(
                          icon: const Icon(
                            Icons.stop_circle_outlined,
                            size: 26,
                            color: AppColors.textMuted,
                          ),
                          tooltip: context.loc.stopAudio,
                          onPressed: () {
                            HapticService.selectionClick();
                            audioService.stop();
                          },
                        ),
                    ],
                  ),
                  Text(
                    totalDuration.inSeconds > 0
                        ? JoyAudioService.formatDuration(totalDuration)
                        : '--:--',
                    style: AppTextStyles.labelBadge.copyWith(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final catColor = item.category.accentColor;
    final isMusic = item.category == JoyCategory.music;
    final isLocalAudio = isMusic && item.isLocalAudio;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: catColor.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge & Category Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.category.iconData, size: 12, color: catColor),
                      const SizedBox(width: 5),
                      Text(
                        item.category.badgeLabel,
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 8.5,
                          color: catColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => _confirmDelete(context),
                  tooltip: context.loc.removeButton,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              item.title,
              style: AppTextStyles.heading.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            // Visual Image Thumbnail if visual category and URL exists
            if (item.category == JoyCategory.visual && _hasMedia) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _showImageDialog(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Image.network(
                        item.mediaUrlOrPath!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 100,
                          color: AppColors.surfaceElevated,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_rounded,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.fullscreen_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.loc.viewImage,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Note / Reflection Body
            if (item.note != null && item.note!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  border: Border.all(
                    color: item.category == JoyCategory.quote
                        ? catColor.withValues(alpha: 0.3)
                        : AppColors.borderSubtle,
                  ),
                ),
                child: Text(
                  item.note!,
                  style: item.category == JoyCategory.quote
                      ? AppTextStyles.bodyMedium.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textPrimary,
                          height: 1.45,
                        )
                      : AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                ),
              ),
            ],

            // Local Audio Player Section
            if (isLocalAudio) ...[
              _buildLocalAudioPlayer(context, catColor),
            ]
            // Online Music / YouTube / YouTube Music Action Button
            else if (isMusic && _hasMedia) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchExternalMedia(context),
                  icon: Icon(
                    item.isYouTubeMusic
                        ? Icons.music_note_rounded
                        : item.isYouTube
                            ? Icons.play_arrow_rounded
                            : Icons.headphones_rounded,
                    size: 16,
                  ),
                  label: Text(
                    item.isYouTubeMusic
                        ? context.loc.openInYoutubeMusic
                        : item.isYouTube
                            ? context.loc.openInYoutube
                            : context.loc.externalPlayer,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: catColor,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    ),
                  ),
                ),
              ),
            ]
            // General external link for non-visual anchors
            else if (_hasMedia && item.category != JoyCategory.visual) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _launchExternalMedia(context),
                  icon: const Icon(Icons.open_in_new_rounded, size: 13),
                  label: Text(
                    context.loc.openLink,
                    style: const TextStyle(fontSize: 11),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: catColor,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
