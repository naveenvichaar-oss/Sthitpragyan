import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../shared/widgets/language_switcher_widget.dart';
import '../../data/models/notification_slot_config.dart';
import 'package:sthitaprajna/features/character_ledger/presentation/screens/character_ledger_screen.dart';
import 'package:sthitaprajna/features/execution_trigger/presentation/screens/execution_trigger_screen.dart';
import 'package:sthitaprajna/features/sharing/presentation/widgets/incoming_share_modal_sheet.dart';
import '../widgets/slot_edit_modal_sheet.dart';

/// SettingsScreen provides 100% customizable reminder slot management,
/// weekend/day filters, master switches, and offline telemetry-free settings.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final HiveStorage _storage;
  List<NotificationSlotConfig> _slots = [];
  bool _masterEnabled = true;

  @override
  void initState() {
    super.initState();
    _storage = HiveStorage();
    _loadSettings();
  }

  void _loadSettings() {
    if (_storage.isInitialized) {
      setState(() {
        _masterEnabled = _storage.getNotificationsEnabled();
        _slots = _storage.getNotificationSlots();
      });
    } else {
      setState(() {
        _slots = NotificationSlotConfig.defaultSlots();
      });
    }
  }

  Future<void> _toggleMasterSwitch(bool value) async {
    HapticService.selectionClick();
    setState(() {
      _masterEnabled = value;
    });

    await NotificationService().toggleMasterNotifications(value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Executive Shield Notifications activated.'
                : 'All background notifications paused.',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: value
              ? AppColors.surfaceElevated
              : AppColors.surface,
        ),
      );
    }
  }

  Future<void> _toggleSlotEnabled(
    NotificationSlotConfig slot,
    bool value,
  ) async {
    HapticService.selectionClick();
    final updated = slot.copyWith(isEnabled: value);
    if (_storage.isInitialized) {
      await _storage.updateNotificationSlot(updated);
    }
    await NotificationService().scheduleAllConfiguredTriggers();
    _loadSettings();
  }

  Future<void> _openSlotEditor({NotificationSlotConfig? slot}) async {
    await SlotEditModalSheet.show(
      context,
      existingSlot: slot,
      onSaved: _loadSettings,
    );
  }

  Future<void> _dispatchTestNotification(NotificationSlotConfig slot) async {
    HapticService.lightImpact();
    await NotificationService().fireTestNotificationForSlot(slot);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                color: AppColors.shieldPrimary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Dispatched test push for "${slot.slotName}" (${slot.formattedTime})',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _confirmDeleteSlot(NotificationSlotConfig slot) async {
    HapticService.heavyImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        ),
        title: Text(
          'Delete Checkpoint?',
          style: AppTextStyles.heading.copyWith(fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to remove "${slot.slotName}"? Its scheduled notifications will be cancelled.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.roseDanger,
              foregroundColor: Colors.white,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (_storage.isInitialized) {
        await _storage.deleteNotificationSlot(slot.id);
      }
      await NotificationService().scheduleAllConfiguredTriggers();
      _loadSettings();
    }
  }

  Future<void> _resetToFactoryDefaults() async {
    HapticService.heavyImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        ),
        title: Text(
          'Reset to Factory Blueprint?',
          style: AppTextStyles.heading.copyWith(fontSize: 18),
        ),
        content: Text(
          'This will restore the 4 default checkpoints (05:45 AM Morning Grounding, 09:00 AM Work Entry Shield, 02:00 PM Mid-Day Audit, and 09:30 PM Night Closure) from the dataset.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.shieldPrimary,
              foregroundColor: AppColors.background,
            ),
            child: const Text('RESET SCHEDULE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (_storage.isInitialized) {
        await _storage.resetNotificationSlotsToDefault();
      }
      await NotificationService().scheduleAllConfiguredTriggers();
      _loadSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Factory notification schedule restored.'),
            backgroundColor: AppColors.surfaceElevated,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _slots.where((s) => s.isEnabled).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.loc.executiveSettings,
              style: AppTextStyles.labelBadge.copyWith(
                color: AppColors.shieldPrimary,
                fontSize: 9.5,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              context.loc.shieldNotificationTiming,
              style: AppTextStyles.heading.copyWith(fontSize: 17),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _openSlotEditor(),
            icon: const Icon(Icons.add_rounded, color: AppColors.shieldPrimary),
            tooltip: 'Add Custom Checkpoint',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Language Switcher Section (EN | HI)
          const LanguageSwitcherWidget(),
          const SizedBox(height: 16),

          // Master Switch Card
          _buildMasterSwitchCard(),
          const SizedBox(height: 20),

          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.loc.configuredCheckpoints,
                style: AppTextStyles.labelBadge.copyWith(fontSize: 10.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(
                  _masterEnabled
                      ? '$activeCount OF ${_slots.length} ACTIVE'
                      : 'ALL MUTED (MASTER OFF)',
                  style: AppTextStyles.labelBadge.copyWith(
                    color: _masterEnabled
                        ? AppColors.shieldPrimary
                        : AppColors.roseDanger,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Checkpoint Cards
          if (_slots.isEmpty)
            _buildEmptyPlaceholder()
          else
            ...List.generate(_slots.length, (index) {
              final slot = _slots[index];
              return _buildSlotCard(slot);
            }),

          const SizedBox(height: 16),

          // Add Slot Action Button
          OutlinedButton.icon(
            onPressed: () => _openSlotEditor(),
            icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
            label: Text(context.loc.addCustomCheckpoint),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.shieldPrimary,
              side: const BorderSide(
                color: AppColors.shieldPrimary,
                width: 1.2,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Reset Section
          Center(
            child: TextButton.icon(
              onPressed: _resetToFactoryDefaults,
              icon: const Icon(Icons.restart_alt_rounded, size: 16),
              label: Text(
                context.loc.resetToFactoryBlueprint,
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Share Sheet Interceptor Preview
          _buildShareSheetSimulatorCard(),
          const SizedBox(height: 16),

          // Action-Trigger & Character Ledger Settings Card
          _buildExecutionAndCharacterLedgerCard(),
          const SizedBox(height: 20),

          // Zero Telemetry Privacy Card
          _buildPrivacyCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildShareSheetSimulatorCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.shieldPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.share_rounded, size: 18, color: AppColors.shieldPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SYSTEM SHARE SHEET (RECEIVE INTENT)',
                      style: AppTextStyles.labelBadge.copyWith(fontSize: 8.5),
                    ),
                    const SizedBox(height: 2),
                    const Text('Save from Browser, YouTube & Notes', style: AppTextStyles.heading),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sthitaprajna appears directly in your system Share menu. You can share links, classical articles, or calming music and save them with personal trigger notes.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticService.selectionClick();
                IncomingShareModalSheet.show(
                  context,
                  rawContent: 'https://youtube.com/watch?v=R9OCA6UFE-0',
                );
              },
              icon: const Icon(Icons.open_in_browser_rounded, size: 14),
              label: const Text('TEST SHARE INTERCEPTOR MODAL', style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.shieldPrimary,
                side: const BorderSide(color: AppColors.shieldPrimary),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionAndCharacterLedgerCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  size: 18,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXECUTION & CHARACTER LEDGER',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: const Color(0xFF10B981),
                        fontSize: 8.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text('Action-Triggers & Virtue Journal', style: AppTextStyles.heading),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Replace standard snooze-prone alarms with non-negotiable Execution Chimes (calm 108Hz gong), 5-minute micro-ignitions, and sovereign trait logs (Magnanimity, Gravitas, Joy, Restraint).',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticService.selectionClick();
                    ExecutionTriggerScreen.open(context);
                  },
                  icon: const Icon(Icons.bolt_rounded, size: 14),
                  label: const Text('EXECUTION CHIME', style: TextStyle(fontSize: 10.5)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    side: const BorderSide(color: Color(0xFF10B981)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticService.selectionClick();
                    CharacterLedgerScreen.open(context);
                  },
                  icon: const Icon(Icons.anchor_rounded, size: 14),
                  label: const Text('CHARACTER LEDGER', style: TextStyle(fontSize: 10.5)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF59E0B),
                    side: const BorderSide(color: Color(0xFFF59E0B)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMasterSwitchCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: _masterEnabled
              ? AppColors.borderMedium
              : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _masterEnabled
                  ? AppColors.surfaceElevated
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _masterEnabled
                    ? AppColors.shieldPrimary
                    : AppColors.borderSubtle,
              ),
            ),
            child: Icon(
              _masterEnabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: _masterEnabled
                  ? AppColors.shieldPrimary
                  : AppColors.textMuted,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Global Notification Shield',
                  style: AppTextStyles.heading.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  _masterEnabled
                      ? 'Local scheduled alarms active across configured days'
                      : 'All reminders silenced',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _masterEnabled,
            onChanged: _toggleMasterSwitch,
            activeColor: AppColors.shieldPrimary,
            activeTrackColor: AppColors.surfaceElevated,
            inactiveTrackColor: AppColors.surface,
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(NotificationSlotConfig slot) {
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final isSlotActive = _masterEnabled && slot.isEnabled;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppDimens.space14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: isSlotActive
              ? AppColors.borderMedium
              : AppColors.borderSubtle.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Badges, Title, Time, and Active Switch
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Custom Badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Text(
                            slot.category.toUpperCase(),
                            style: AppTextStyles.labelBadge.copyWith(
                              fontSize: 8.5,
                              color: isSlotActive
                                  ? AppColors.shieldPrimary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                        if (slot.isCustom) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'CUSTOM',
                              style: AppTextStyles.labelBadge.copyWith(
                                fontSize: 8.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Slot Name
                    Text(
                      slot.slotName,
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 16,
                        color: isSlotActive
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Formatted Time
                    Text(
                      slot.formattedTime,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isSlotActive
                            ? AppColors.shieldPrimary
                            : AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Active / Inactive Switch
              Switch(
                value: slot.isEnabled,
                onChanged: _masterEnabled
                    ? (val) => _toggleSlotEnabled(slot, val)
                    : null,
                activeColor: AppColors.shieldPrimary,
                activeTrackColor: AppColors.surfaceElevated,
                inactiveTrackColor: AppColors.surface,
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 10),

          // Bottom Row: Schedule Days Indicators and Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Day Chips & Summary
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(7, (idx) {
                      final dayNum = idx + 1;
                      final isActiveDay = slot.isDayActive(dayNum);
                      return Container(
                        margin: const EdgeInsets.only(right: 3),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isActiveDay && isSlotActive
                              ? AppColors.shieldPrimary.withOpacity(0.18)
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: isActiveDay && isSlotActive
                                ? AppColors.shieldPrimary
                                : AppColors.borderSubtle,
                            width: 0.8,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          dayNames[idx],
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: isActiveDay
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isActiveDay && isSlotActive
                                ? AppColors.shieldPrimary
                                : AppColors.textMuted,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    slot.daysSummary,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),

              // Quick Actions: Test, Edit, Delete
              Row(
                children: [
                  IconButton(
                    onPressed: () => _dispatchTestNotification(slot),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    color: AppColors.shieldPrimary,
                    tooltip: 'Send Test Notification Now',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: () => _openSlotEditor(slot: slot),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    color: AppColors.textSecondary,
                    tooltip: 'Edit Checkpoint',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: () => _confirmDeleteSlot(slot),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    color: AppColors.roseDanger.withOpacity(0.8),
                    tooltip: 'Delete Checkpoint',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(
            Icons.alarm_off_rounded,
            color: AppColors.textMuted,
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            'No Reminder Slots Configured',
            style: AppTextStyles.heading,
          ),
          const SizedBox(height: 4),
          Text(
            'Add a custom checkpoint or tap "Reset to Factory Blueprint" below.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.shieldPrimary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '100% OFFLINE • ZERO TELEMETRY',
                  style: AppTextStyles.labelBadge.copyWith(
                    color: AppColors.shieldPrimary,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'All reminder schedules reside in the device hardware alarm manager. Zero cloud pings.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
