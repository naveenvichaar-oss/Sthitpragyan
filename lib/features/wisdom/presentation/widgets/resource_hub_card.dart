import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/resource_link.dart';
import '../../utils/resource_launcher_service.dart';

/// ResourceHubCard displays curated classic literature or personal Drive/Keep notes
/// with in-app YouTube player and in-app Web/PDF viewer support.
class ResourceHubCard extends StatelessWidget {
  final ResourceLink resource;
  final VoidCallback? onDelete;

  const ResourceHubCard({
    super.key,
    required this.resource,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final mediaColor = resource.mediaType.accentColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          onTap: () => ResourceLauncherService.openResource(context, resource: resource),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.space14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media Type Icon Indicator
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: mediaColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    border: Border.all(color: mediaColor.withValues(alpha: 0.25)),
                  ),
                  child: Icon(
                    resource.mediaType.iconData,
                    size: 22,
                    color: mediaColor,
                  ),
                ),
                const SizedBox(width: 12),

                // Content Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: mediaColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              resource.mediaType.badgeLabel,
                              style: AppTextStyles.labelBadge.copyWith(
                                fontSize: 8.0,
                                color: mediaColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            resource.category.toUpperCase(),
                            style: AppTextStyles.labelBadge.copyWith(
                              fontSize: 8.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                          if (resource.isUserAdded) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Text(
                                'CUSTOM',
                                style: AppTextStyles.labelBadge.copyWith(
                                  fontSize: 7.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Title
                      Text(
                        resource.title,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Notes or URL snippet
                      if (resource.notes != null && resource.notes!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          resource.notes!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.open_in_new_rounded,
                            size: 11,
                            color: AppColors.shieldPrimary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              resource.url,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.shieldPrimary.withValues(alpha: 0.8),
                                fontSize: 10,
                                decoration: TextDecoration.underline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Delete button for user-added items or chevron
                if (resource.isUserAdded && onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppColors.textDisabled,
                    ),
                    onPressed: () {
                      HapticService.selectionClick();
                      onDelete!();
                    },
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.textDisabled,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
