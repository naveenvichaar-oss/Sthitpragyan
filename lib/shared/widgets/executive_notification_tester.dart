import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/notifications/notifications_dataset_service.dart';
import '../../core/utils/haptic_service.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

/// ExecutiveNotificationTester allows immediate testing and inspection
/// of the 4 scheduled daily Stoic triggers.
class ExecutiveNotificationTester extends StatelessWidget {
  const ExecutiveNotificationTester({super.key});

  static void show(BuildContext context) {
    HapticService.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (context) => const ExecutiveNotificationTester(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final datasetTriggers = NotificationsDatasetService().getTodayTriggers();
    final triggers = datasetTriggers.isNotEmpty
        ? datasetTriggers
        : NotificationService.dailyTriggers;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderBright,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DISPATCH SCHEDULE',
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.shieldPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'DAILY NOTIFICATION TRIGGERS',
                    style: AppTextStyles.heading,
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '4 local daily stoic triggers scheduled directly into OS alarm service. Zero cloud dependencies.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: triggers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = triggers[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Text(
                        '${item.hour.toString().padLeft(2, '0')}:${item.minute.toString().padLeft(2, '0')}',
                        style: AppTextStyles.metricSmall.copyWith(
                          fontSize: 12,
                          color: AppColors.shieldPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.body,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () async {
                        HapticService.lightImpact();
                        await NotificationService().fireTestNotification(item);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Fired immediate test: ${item.title}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.background,
                                ),
                              ),
                              backgroundColor: AppColors.textPrimary,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderMedium),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: Text(
                        'TEST',
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 9.5,
                          color: AppColors.shieldPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.tune_rounded, size: 16),
            label: const Text('CUSTOMIZE SLOTS & SCHEDULE IN SETTINGS'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.shieldPrimary,
              side: const BorderSide(color: AppColors.shieldPrimary),
              minimumSize: const Size(double.infinity, 42),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '100% OFFLINE • TIMEZONE SYNCHRONIZED',
              style: AppTextStyles.labelBadge.copyWith(
                fontSize: 9.0,
                letterSpacing: 1.5,
                color: AppColors.textDisabled,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
