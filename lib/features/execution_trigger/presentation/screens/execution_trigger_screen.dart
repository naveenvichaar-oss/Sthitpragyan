import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/execution_trigger.dart';
import '../widgets/micro_ignition_timer_dialog.dart';
import '../widgets/zero_snooze_anchor_modal.dart';

/// ExecutionTriggerScreen manages non-negotiable daily commitment blocks,
/// zero-snooze philosophy anchors, and 5-minute micro-ignition friction breakers.
class ExecutionTriggerScreen extends StatefulWidget {
  const ExecutionTriggerScreen({super.key});

  static void open(BuildContext context) {
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
  int _microIgnitionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _triggers = _storage.getAllExecutionTriggers();
      _microIgnitionCount = _storage.getMicroIgnitionCount();
    });
  }

  void _toggleTrigger(ExecutionTrigger trigger, bool enabled) async {
    HapticService.selectionClick();
    final updated = trigger.copyWith(isEnabled: enabled);
    await _storage.saveExecutionTrigger(updated);
    _loadData();
  }

  void _triggerChimeNow(ExecutionTrigger trigger) {
    HapticService.selectionClick();
    ZeroSnoozeAnchorModal.show(context, trigger).then((_) {
      _loadData();
    });
  }

  void _openMicroIgnition() {
    HapticService.selectionClick();
    MicroIgnitionTimerDialog.show(context).then((_) {
      _loadData();
    });
  }

  void _showAddCustomBlockDialog() {
    HapticService.selectionClick();
    final titleController = TextEditingController();
    final timeController = TextEditingController(text: '11:00');
    final intentController = TextEditingController();
    String category = 'Deep Work';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLarge)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppDimens.space20,
                right: AppDimens.space20,
                top: AppDimens.space20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + AppDimens.space24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Add Execution Block', style: AppTextStyles.heading),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    style: AppTextStyles.bodyMedium,
                    decoration: const InputDecoration(
                      labelText: 'Block Title (e.g., Strategic Review)',
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: timeController,
                          style: AppTextStyles.bodyMedium,
                          decoration: const InputDecoration(
                            labelText: 'Scheduled Time (HH:mm)',
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: category,
                          dropdownColor: AppColors.surfaceElevated,
                          style: AppTextStyles.bodyMedium,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Deep Work', child: Text('Deep Work')),
                            DropdownMenuItem(value: 'Grounding', child: Text('Grounding')),
                            DropdownMenuItem(value: 'Friction Clear', child: Text('Friction Clear')),
                            DropdownMenuItem(value: 'Evening Audit', child: Text('Evening Audit')),
                          ],
                          onChanged: (val) {
                            if (val != null) setModalState(() => category = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: intentController,
                    maxLines: 2,
                    style: AppTextStyles.bodyMedium,
                    decoration: const InputDecoration(
                      labelText: 'Stoic Intent / Mandate',
                      hintText: 'What is the non-negotiable standard for this block?',
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.shieldPrimary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;
                        final newBlock = ExecutionTrigger(
                          id: 'exec_${DateTime.now().millisecondsSinceEpoch}',
                          title: title,
                          devanagariSubtitle: 'संकल्पित कर्म',
                          timeOfDay: timeController.text.trim(),
                          intent: intentController.text.trim().isEmpty
                              ? 'Zero hesitation. Execute with pure presence.'
                              : intentController.text.trim(),
                          category: category,
                        );
                        await _storage.saveExecutionTrigger(newBlock);
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        _loadData();
                      },
                      child: const Text(
                        'SAVE NON-NEGOTIABLE BLOCK',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACTION-TRIGGER • प्रतिबद्धता ध्वनि',
              style: AppTextStyles.labelBadge.copyWith(
                color: const Color(0xFF10B981),
                fontSize: 9.5,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'EXECUTION CHIME',
              style: AppTextStyles.heading,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.shieldPrimary),
            tooltip: 'Add Execution Block',
            onPressed: _showAddCustomBlockDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.space16),
        children: [
          // 1. Philosophy & Friction Breaker Banner
          _buildFrictionBreakerCard(),
          const SizedBox(height: 20),

          // 2. Non-Negotiable Blocks Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NON-NEGOTIABLE DAILY BLOCKS (${_triggers.length})',
                style: AppTextStyles.labelBadge.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'ZERO-SNOOZE MANDATE',
                style: AppTextStyles.labelBadge.copyWith(
                  color: const Color(0xFF10B981),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3. Execution Trigger Blocks List
          ..._triggers.map((trigger) => _buildTriggerCard(trigger)),
        ],
      ),
    );
  }

  Widget _buildFrictionBreakerCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'FRICTION-BREAKER',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: const Color(0xFFF59E0B),
                        fontSize: 9,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$_microIgnitionCount COMPLETED',
                style: AppTextStyles.labelBadge.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '5-Minute Micro-Ignition Timer',
            style: AppTextStyles.heading,
          ),
          const SizedBox(height: 4),
          Text(
            'Procrastination is merely cognitive friction at the start threshold. Single-tap to begin a discrete 5-minute countdown and dissolve resistance immediately.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.bolt_rounded, size: 20),
              label: const Text(
                'LAUNCH 5-MIN MICRO-IGNITION NOW',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              onPressed: _openMicroIgnition,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerCard(ExecutionTrigger trigger) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: trigger.isEnabled
              ? AppColors.borderSubtle
              : AppColors.borderSubtle.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      trigger.timeOfDay,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      trigger.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              Switch(
                value: trigger.isEnabled,
                activeThumbColor: const Color(0xFF10B981),
                onChanged: (val) => _toggleTrigger(trigger, val),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trigger.devanagariSubtitle,
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 8.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trigger.title,
                      style: AppTextStyles.heading.copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
              if (trigger.streakCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '🔥 ${trigger.streakCount} STREAK',
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            trigger.intent,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF10B981),
                side: const BorderSide(
                  color: Color(0xFF10B981),
                  width: 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.notifications_active_outlined, size: 16),
              label: const Text(
                'TEST CHIME / EXECUTE NOW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              onPressed: () => _triggerChimeNow(trigger),
            ),
          ),
        ],
      ),
    );
  }
}
