import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/notification_slot_config.dart';

/// Modal sheet for creating or editing a reminder slot with day-wise scheduling
class SlotEditModalSheet extends StatefulWidget {
  final NotificationSlotConfig? existingSlot;
  final VoidCallback onSaved;

  const SlotEditModalSheet({
    super.key,
    this.existingSlot,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    NotificationSlotConfig? existingSlot,
    required VoidCallback onSaved,
  }) async {
    HapticService.selectionClick();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SlotEditModalSheet(existingSlot: existingSlot, onSaved: onSaved),
      ),
    );
  }

  @override
  State<SlotEditModalSheet> createState() => _SlotEditModalSheetState();
}

class _SlotEditModalSheetState extends State<SlotEditModalSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  late int _selectedHour;
  late int _selectedMinute;
  late String _selectedCategory;
  late List<int> _selectedDays;
  late bool _isEnabled;

  final List<String> _categories = [
    'Morning Grounding',
    'Work Entry Shield',
    'Mid-Day Audit',
    'Night Closure',
    'Tactical Reset',
    'Deep Work',
    'Custom Focus',
  ];

  @override
  void initState() {
    super.initState();
    final slot = widget.existingSlot;
    _nameController = TextEditingController(text: slot?.slotName ?? '');
    _titleController = TextEditingController(text: slot?.title ?? '');
    _bodyController = TextEditingController(text: slot?.body ?? '');

    _selectedHour = slot?.hour ?? 9;
    _selectedMinute = slot?.minute ?? 0;
    _selectedCategory = slot?.category ?? 'Custom Focus';
    _selectedDays = slot != null
        ? List<int>.from(slot.activeDays)
        : [1, 2, 3, 4, 5];
    _isEnabled = slot?.isEnabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  String _formatTime(int hour, int minute) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:$m $period';
  }

  Future<void> _pickTime() async {
    HapticService.selectionClick();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.shieldPrimary,
              onPrimary: AppColors.background,
              surface: AppColors.surfaceElevated,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedHour = picked.hour;
        _selectedMinute = picked.minute;
      });
      HapticService.lightImpact();
    }
  }

  void _applyDayPreset(List<int> days) {
    HapticService.selectionClick();
    setState(() {
      _selectedDays = List<int>.from(days);
    });
  }

  void _toggleDay(int day) {
    HapticService.selectionClick();
    setState(() {
      if (_selectedDays.contains(day)) {
        if (_selectedDays.length > 1) {
          _selectedDays.remove(day);
        }
      } else {
        _selectedDays.add(day);
        _selectedDays.sort();
      }
    });
  }

  Future<void> _saveSlot() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a slot name (e.g. "Work Entry Shield")'),
          backgroundColor: AppColors.roseDanger,
        ),
      );
      return;
    }

    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : name;

    final body = _bodyController.text.trim();

    final id =
        widget.existingSlot?.id ??
        'slot_${DateTime.now().millisecondsSinceEpoch}';
    final numericId =
        widget.existingSlot?.numericId ?? (id.hashCode.abs() % 10000);

    final updatedSlot = NotificationSlotConfig(
      id: id,
      numericId: numericId,
      slotName: name,
      title: title,
      body: body,
      category: _selectedCategory,
      hour: _selectedHour,
      minute: _selectedMinute,
      isEnabled: _isEnabled,
      activeDays: _selectedDays,
      isCustom: widget.existingSlot?.isCustom ?? true,
    );

    if (HiveStorage().isInitialized) {
      await HiveStorage().updateNotificationSlot(updatedSlot);
    }

    // Reschedule in background
    await NotificationService().scheduleAllConfiguredTriggers();

    HapticService.success();
    if (mounted) {
      widget.onSaved();
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteSlot() async {
    if (widget.existingSlot == null) return;
    HapticService.heavyImpact();

    if (HiveStorage().isInitialized) {
      await HiveStorage().deleteNotificationSlot(widget.existingSlot!.id);
    }
    await NotificationService().scheduleAllConfiguredTriggers();

    if (mounted) {
      widget.onSaved();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingSlot != null;
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top pull handle
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
            const SizedBox(height: 14),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'EDIT CHECKPOINT' : 'NEW CHECKPOINT',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.shieldPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEditing
                          ? 'Customize Reminder Slot'
                          : 'Add Strategic Reminder',
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
            const SizedBox(height: 16),
            const Divider(color: AppColors.borderSubtle),
            const SizedBox(height: 14),

            // Slot Name Input
            Text('CHECKPOINT NAME', style: AppTextStyles.labelBadge),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'e.g. Work Entry Shield, Deep Work Anchor',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  borderSide: const BorderSide(color: AppColors.borderMedium),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  borderSide: const BorderSide(color: AppColors.borderMedium),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  borderSide: const BorderSide(
                    color: AppColors.shieldPrimary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dispatch Time Selector
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DISPATCH TIME', style: AppTextStyles.labelBadge),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusSmall,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusSmall,
                            ),
                            border: Border.all(color: AppColors.borderMedium),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatTime(_selectedHour, _selectedMinute),
                                style: AppTextStyles.heading.copyWith(
                                  color: AppColors.shieldPrimary,
                                  fontSize: 16,
                                ),
                              ),
                              const Icon(
                                Icons.access_time_rounded,
                                size: 18,
                                color: AppColors.shieldPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Active Toggle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ACTIVE STATUS', style: AppTextStyles.labelBadge),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusSmall,
                        ),
                        border: Border.all(color: AppColors.borderMedium),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _isEnabled ? 'ACTIVE' : 'MUTED',
                            style: AppTextStyles.labelBadge.copyWith(
                              color: _isEnabled
                                  ? AppColors.shieldPrimary
                                  : AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Switch(
                            value: _isEnabled,
                            onChanged: (val) {
                              HapticService.selectionClick();
                              setState(() => _isEnabled = val);
                            },
                            activeColor: AppColors.shieldPrimary,
                            activeTrackColor: AppColors.surfaceElevated,
                            inactiveTrackColor: AppColors.surface,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category Chips
            Text('CATEGORY / THEME', style: AppTextStyles.labelBadge),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      HapticService.selectionClick();
                      setState(() => _selectedCategory = cat);
                    }
                  },
                  selectedColor: AppColors.surfaceElevated,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.shieldPrimary
                        : AppColors.borderSubtle,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.shieldPrimary
                        : AppColors.textSecondary,
                  ),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Day-Wise Schedule & Weekend Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ACTIVE DAYS (SCHEDULE)', style: AppTextStyles.labelBadge),
                Text(
                  '${_selectedDays.length} OF 7 DAYS',
                  style: AppTextStyles.labelBadge.copyWith(
                    color: AppColors.shieldPrimary,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Quick Filter Presets
            Row(
              children: [
                _buildPresetButton(
                  'EVERY DAY',
                  isActive: _selectedDays.length == 7,
                  onTap: () => _applyDayPreset([1, 2, 3, 4, 5, 6, 7]),
                ),
                const SizedBox(width: 8),
                _buildPresetButton(
                  'WEEKDAYS (M–F)',
                  isActive:
                      _selectedDays.length == 5 &&
                      !_selectedDays.contains(6) &&
                      !_selectedDays.contains(7),
                  onTap: () => _applyDayPreset([1, 2, 3, 4, 5]),
                ),
                const SizedBox(width: 8),
                _buildPresetButton(
                  'WEEKENDS (S–S)',
                  isActive:
                      _selectedDays.length == 2 &&
                      _selectedDays.contains(6) &&
                      _selectedDays.contains(7),
                  onTap: () => _applyDayPreset([6, 7]),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Day Selector Circles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (idx) {
                final dayNumber = idx + 1; // 1 = Mon ... 7 = Sun
                final isSelected = _selectedDays.contains(dayNumber);
                final isWeekend = dayNumber == 6 || dayNumber == 7;

                return InkWell(
                  onTap: () => _toggleDay(dayNumber),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.surfaceElevated
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.shieldPrimary
                            : AppColors.borderSubtle,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dayNames[idx],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? (isWeekend
                                  ? AppColors.shieldPrimary
                                  : AppColors.textPrimary)
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),

            // Custom Notification Title (Optional)
            Text(
              'CUSTOM NOTIFICATION TITLE (OPTIONAL)',
              style: AppTextStyles.labelBadge,
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Defaults to slot name or daily Hindi rule',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  borderSide: const BorderSide(color: AppColors.borderMedium),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  borderSide: const BorderSide(color: AppColors.borderMedium),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  borderSide: const BorderSide(
                    color: AppColors.shieldPrimary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Custom Body (Optional)
            Text(
              'CUSTOM NOTIFICATION MESSAGE (OPTIONAL)',
              style: AppTextStyles.labelBadge,
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _bodyController,
              maxLines: 2,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Defaults to day-wise Stoic prompt or custom mantra',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  borderSide: const BorderSide(color: AppColors.borderMedium),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  borderSide: const BorderSide(color: AppColors.borderMedium),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  borderSide: const BorderSide(
                    color: AppColors.shieldPrimary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                if (isEditing) ...[
                  IconButton(
                    onPressed: _deleteSlot,
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: AppColors.roseDanger,
                    tooltip: 'Delete Checkpoint',
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.borderMedium),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusSmall,
                        ),
                      ),
                    ),
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveSlot,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.shieldPrimary,
                      foregroundColor: AppColors.background,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusSmall,
                        ),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'SAVE CHANGES' : 'CREATE CHECKPOINT',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(
    String label, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surfaceElevated : AppColors.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive
                  ? AppColors.shieldPrimary
                  : AppColors.borderSubtle,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelBadge.copyWith(
              fontSize: 9,
              color: isActive ? AppColors.shieldPrimary : AppColors.textMuted,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
