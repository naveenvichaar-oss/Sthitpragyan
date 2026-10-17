import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/constants/app_colors.dart';
import 'core/database/hive_storage.dart';
import 'core/localization/locale_controller.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/notifications_dataset_service.dart';
import 'features/journal/data/repositories/journal_repository.dart';
import 'features/journal/data/services/media_vault_service.dart';
import 'features/wisdom/data/services/wisdom_vault_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pure dark mode status bar & navigation bar overlays
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Load 7-day scheduled Stoic triggers from notifications_dataset.json
  await NotificationsDatasetService().loadDataset();

  // Load offline wisdom vault entries (Gita, Stoicism, Behavioral Psychology)
  await WisdomVaultService().init();

  // Initialize offline-first zero-telemetry local storage
  await HiveStorage().init();

  // Initialize dynamic language & locale preference
  LocaleController.instance.init();

  // Initialize stealth media vault and .nomedia folder security
  await MediaVaultService().init();

  // Populate initial demonstration/onboarding data if cold start
  await JournalRepository().seedInitialDataIfEmpty();

  // Initialize and schedule local daily Stoic notifications
  // (05:45 AM, 09:30 AM / 09:00 AM, 02:00 PM, 09:30 PM)
  await NotificationService().init();

  runApp(const SthitaprajnaApp());
}
