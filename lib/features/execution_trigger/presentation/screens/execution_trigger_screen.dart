import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/gong_audio_service.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/execution_trigger.dart';
import '../widgets/micro_ignition_timer_dialog.dart';

/// ExecutionTriggerScreen provides a minimal, compact, and fully customizable dashboard
/// for daily focus blocks, instant 108Hz chime testing, and 5-minute kickstarts.
class ExecutionTriggerScreen extends StatefulWidget {
  const ExecutionTriggerScreen({super.key});

  static void open(BuildContext context) {
    HapticService.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ExecutionTriggerScreen(),
      ),
    );
  }

  @override
  State<ExecutionTriggerScreen> createState() => _ExecutionTriggerScreenState();
}

class _ExecutionTriggerScreenState extends State<ExecutionTriggerScreen> {
  final HiveStorage _storage = HiveStorage();
  List<ExecutionTrigger> _triggers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _triggers = _storage.getAllExecutionTriggers();
    });
  }

  void _toggleTrigger(ExecutionTrigger trigger, bool enabled) async {
    HapticService.selectionClick();
    final updated = trigger.copyWith(isEnabled: enabled);
    await _storage.saveExecutionTrigger(updated);
    _loadData();
  }

  void _testChime(ExecutionTrigger trigger) {
    HapticService.heavyImpact();
    GongAudioService().playDeepGong();
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${trigger.title}: ${context.loc.chimeTriggeredNotice}',
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openMicroIgnition() {
    HapticService.selectionClick();
    MicroIgnitionTimerDialog.show(context).then((_) {
      _loadData();
    });
  }

  void _showAddBlockDialog() {
    _showBlockFormDialog(null);
  }

  void _showEditBlockDialog(ExecutionTrigger trigger) {
    _showBlockFormDialog(trigger);
  }

  void _showBlockFormDialog(ExecutionTrigger? existing) {
    HapticService.selectionClick();
    final isEditing = existing != null;

    final titleController = TextEditingController(text: existing?.title ?? '');
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 30);

    if (existing != null) {
      final parsed = _parseTimeOfDay(existing.timeOfDay);
      if (parsed != null) selectedTime = parsed;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        TimeOfDay modalTime = selectedTime;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final formattedTime = _formatTimeOfDay(dialogContext, modalTime);

            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
              title: Text(
                isEditing
                    ? context.loc.editTimeBlock
                    : context.loc.addTimeBlock,
                style: AppTextStyles.heading.copyWith(fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    Text(
                      context.loc.blockTitleLabel,
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 9.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      style: AppTextStyles.bodyMedium,
                      autofocus: !isEditing,
                      decoration: InputDecoration(
                        hintText: context.loc.blockTitleHint,
                        hintStyle: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF10B981)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Time Picker row
                    Text(
                      context.loc.scheduledTimeLabel,
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 9.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        HapticService.selectionClick();
                        final picked = await showTimePicker(
                          context: dialogContext,
                          initialTime: modalTime,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFF10B981),
                                  onPrimary: Colors.black,
                                  surface: AppColors.surface,
                                  onSurface: AppColors.textPrimary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() {
                            modalTime = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF10B981)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                formattedTime,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              context.loc.changeTimeButton,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    context.loc.cancelButton,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    final timeString = formattedTime;
                    final block = ExecutionTrigger(
                      id: existing?.id ?? 'block_${DateTime.now().millisecondsSinceEpoch}',
                      title: title,
                      devanagariSubtitle: context.loc.dailyBlockSubtitle,
                      timeOfDay: timeString,
                      intent: existing?.intent ?? '',
                      category: existing?.category ?? 'Deep Work',
                      isEnabled: existing?.isEnabled ?? true,
                      streakCount: existing?.streakCount ?? 0,
                      lastExecutedAt: existing?.lastExecutedAt,
                    );

                    await _storage.saveExecutionTrigger(block);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    _loadData();
                  },
                  child: Text(
                    context.loc.saveAction,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteBlock(ExecutionTrigger trigger) {
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
          context.loc.deleteTimeBlock,
          style: AppTextStyles.heading.copyWith(fontSize: 16),
        ),
        content: Text(
          context.loc.removeTimeBlockConfirm(trigger.title),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              context.loc.cancelButton,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.roseDanger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () async {
              await _storage.deleteExecutionTrigger(trigger.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
              _loadData();
            },
            child: Text(
              context.loc.removeButton,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  TimeOfDay? _parseTimeOfDay(String timeStr) {
    try {
      final trimmed = timeStr.trim().toUpperCase();
      final isPM = trimmed.contains('PM');
      final isAM = trimmed.contains('AM');
      final clean = trimmed.replaceAll('AM', '').replaceAll('PM', '').trim();
      final parts = clean.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0].trim());
        final int minute = int.parse(parts[1].trim());
        if (isPM && hour < 12) hour += 12;
        if (isAM && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }

  String _formatTimeOfDay(BuildContext context, TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hourStr = hour.toString().padLeft(2, '0');
    return '$hourStr:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = context.loc.isHindi;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          context.loc.executionChimeHeader,
          style: AppTextStyles.heading.copyWith(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Color(0xFF10B981), size: 24),
            tooltip: context.loc.addTimeBlock,
            onPressed: _showAddBlockDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space14,
          vertical: AppDimens.space12,
        ),
        children: [
          // 1. Compact 5-Minute Kickstart Widget (One-line card)
          _buildCompactKickstartWidget(isHindi),
          const SizedBox(height: 12),

          // 2. Section Header: Daily Focus Blocks / दैनिक कार्य ब्लॉक
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${context.loc.dailyFocusBlocks} (${_triggers.length})',
                style: AppTextStyles.labelBadge.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton.icon(
                onPressed: _showAddBlockDialog,
                icon: const Icon(Icons.add_rounded, size: 14, color: Color(0xFF10B981)),
                label: Text(
                  context.loc.addTimeBlock,
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 3. Blocks List (Single slim row per block)
          if (_triggers.isEmpty)
            _buildEmptyBlocksCard(isHindi)
          else
            ..._triggers.map((trigger) => _buildSlimBlockRow(trigger, isHindi)),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCompactKickstartWidget(bool isHindi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              size: 18,
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(
                  context.loc.fiveMinKickstart,
                  style: AppTextStyles.labelBadge.copyWith(
                    color: const Color(0xFFF59E0B),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '• ${context.loc.fiveMinTimerSubtitle}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: _openMicroIgnition,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              context.loc.startAction,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlimBlockRow(ExecutionTrigger trigger, bool isHindi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        border: Border.all(
          color: trigger.isEnabled
              ? AppColors.borderSubtle
              : AppColors.borderSubtle.withValues(alpha: 0.4),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Left: Time badge (e.g., "09:30 AM")
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(
              trigger.timeOfDay,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Editable Block Title
          Expanded(
            child: Text(
              trigger.title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: trigger.isEnabled ? AppColors.textPrimary : AppColors.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Middle: Quick bell/test chime icon
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, size: 17),
            color: trigger.isEnabled ? const Color(0xFF10B981) : AppColors.textMuted,
            tooltip: context.loc.testChimeTooltip,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => _testChime(trigger),
          ),
          const SizedBox(width: 2),

          // Right: Toggle switch (On/Off)
          Transform.scale(
            scale: 0.72,
            child: Switch(
              value: trigger.isEnabled,
              activeTrackColor: const Color(0xFF10B981).withValues(alpha: 0.5),
              activeThumbColor: const Color(0xFF10B981),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (val) => _toggleTrigger(trigger, val),
            ),
          ),

          // Popup menu (Edit / Delete)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 17, color: AppColors.textMuted),
            color: AppColors.surfaceElevated,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onSelected: (action) {
              if (action == 'edit') {
                _showEditBlockDialog(trigger);
              } else if (action == 'delete') {
                _confirmDeleteBlock(trigger);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'edit',
                height: 36,
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(context.loc.editTimeBlock, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                height: 36,
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, size: 15, color: AppColors.roseDanger),
                    const SizedBox(width: 8),
                    Text(
                      context.loc.deleteTimeBlock,
                      style: const TextStyle(fontSize: 12, color: AppColors.roseDanger),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBlocksCard(bool isHindi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 32,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            context.loc.noDailyBlocks,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.loc.noDailyBlocksSub,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _showAddBlockDialog,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text(context.loc.addTimeBlock, style: const TextStyle(fontSize: 11.5)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF10B981),
              side: const BorderSide(color: Color(0xFF10B981)),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}
