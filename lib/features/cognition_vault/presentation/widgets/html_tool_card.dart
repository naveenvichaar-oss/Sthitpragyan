import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/local_html_tool.dart';
import '../screens/local_html_viewer_screen.dart';

/// HtmlToolCard renders an offline HTML tool item with metadata,
/// file size badge, launch action, and discreet deletion capability.
class HtmlToolCard extends StatelessWidget {
  final LocalHtmlTool tool;
  final VoidCallback? onDelete;
  final ValueChanged<LocalHtmlTool>? onUpdated;

  const HtmlToolCard({
    super.key,
    required this.tool,
    this.onDelete,
    this.onUpdated,
  });

  void _confirmDelete(BuildContext context) {
    HapticService.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(context.loc.deleteToolTitle, style: AppTextStyles.heading),
        content: Text(
          '${context.loc.deleteToolConfirm}\n\n"${tool.title}" (${tool.fileName})',
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
              Navigator.of(ctx).pop();
              onDelete?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.roseDanger,
              foregroundColor: Colors.white,
            ),
            child: Text(context.loc.deleteAction),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, yyyy').format(tool.addedDate);
    final sizeKb = tool.fileSizeBytes != null
        ? '${(tool.fileSizeBytes! / 1024).toStringAsFixed(1)} KB'
        : 'HTML';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          onTap: () {
            HapticService.selectionClick();
            LocalHtmlViewerScreen.open(
              context,
              tool: tool,
              onToolDeleted: onDelete,
              onToolUpdated: onUpdated,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.space14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Category, Size, Discreet Delete Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF10B981).withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            tool.category.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            sizeKb,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 8.5,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (onDelete != null)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textMuted,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 15,
                          color: AppColors.textMuted,
                        ),
                        label: Text(
                          context.loc.deleteAction,
                          style: const TextStyle(fontSize: 10),
                        ),
                        onPressed: () => _confirmDelete(context),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Row(
                  children: [
                    const Icon(
                      Icons.dashboard_customize_outlined,
                      size: 18,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tool.title,
                        style: AppTextStyles.heading.copyWith(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Description
                if (tool.description != null && tool.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    tool.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                // Footer: File name & Date & Tap prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${tool.fileName} • $formattedDate',
                        style: AppTextStyles.labelBadge.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 8.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.loc.launchAction,
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
