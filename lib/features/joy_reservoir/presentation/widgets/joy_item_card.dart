import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../wisdom/utils/resource_launcher_service.dart';
import '../../data/models/joy_item.dart';

/// JoyItemCard renders a personal emotional anchor:
/// - Music tracks with embedded play action (YouTube/Web)
/// - Visual memories with tap-to-expand image viewer
/// - Comfort words and quotes in serene typography
/// - Soul milestones and grounding memories
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

  bool get _isYoutube =>
      _hasMedia && ResourceLauncherService.isYoutubeUrl(item.mediaUrlOrPath!);

  void _handleMediaAction(BuildContext context) {
    if (!_hasMedia) return;
    HapticService.selectionClick();
    ResourceLauncherService.openUrl(
      context,
      url: item.mediaUrlOrPath!,
      title: item.title,
      category: item.category.displayName,
      notes: item.note,
    );
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
                  child: const Text('Unable to load image anchor.', style: TextStyle(color: Colors.white70)),
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
        title: const Text('Remove Anchor?', style: AppTextStyles.heading),
        content: Text(
          'Remove "${item.title}" from your Joy Reservoir?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.roseDanger,
              foregroundColor: Colors.white,
            ),
            child: const Text('REMOVE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catColor = item.category.accentColor;

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
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textMuted),
                  onPressed: () => _confirmDelete(context),
                  tooltip: 'Remove Anchor',
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
                          child: const Icon(Icons.broken_image_rounded, color: AppColors.textMuted),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fullscreen_rounded, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text('VIEW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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

            // Music / Media Action Button
            if (item.category == JoyCategory.music && _hasMedia) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleMediaAction(context),
                  icon: Icon(
                    _isYoutube ? Icons.play_arrow_rounded : Icons.headphones_rounded,
                    size: 16,
                  ),
                  label: Text(
                    _isYoutube ? 'PLAY SERENITY AUDIO / VIDEO' : 'LISTEN TO AUDIO ANCHOR',
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
            ] else if (_hasMedia && item.category != JoyCategory.visual) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _handleMediaAction(context),
                  icon: const Icon(Icons.open_in_new_rounded, size: 13),
                  label: const Text('OPEN LINK', style: TextStyle(fontSize: 11)),
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
