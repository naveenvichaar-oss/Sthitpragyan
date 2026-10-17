import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/joy_item.dart';

/// Modal sheet allowing executives to add personal serenity and joy anchors
class AddJoyItemModalSheet extends StatefulWidget {
  final VoidCallback onSaved;

  const AddJoyItemModalSheet({
    super.key,
    required this.onSaved,
  });

  static Future<void> show(BuildContext context, {required VoidCallback onSaved}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusLarge),
        ),
      ),
      builder: (context) => AddJoyItemModalSheet(onSaved: onSaved),
    );
  }

  @override
  State<AddJoyItemModalSheet> createState() => _AddJoyItemModalSheetState();
}

class _AddJoyItemModalSheetState extends State<AddJoyItemModalSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _mediaUrlController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  JoyCategory _selectedCategory = JoyCategory.music;

  @override
  void dispose() {
    _titleController.dispose();
    _mediaUrlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      HapticService.error();
      return;
    }

    HapticService.success();
    final item = JoyItem(
      id: 'joy_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      category: _selectedCategory,
      mediaUrlOrPath: _mediaUrlController.text.trim().isEmpty
          ? null
          : _mediaUrlController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      timestamp: DateTime.now(),
    );

    await HiveStorage().saveJoyItem(item);
    widget.onSaved();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.spa_rounded, color: AppColors.emeraldSuccess, size: 16),
              SizedBox(width: 8),
              Text('Joy anchor added to Soul Sanctuary', style: TextStyle(fontSize: 12)),
            ],
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final catColor = _selectedCategory.accentColor;

    return Padding(
      padding: EdgeInsets.only(
        left: AppDimens.space16,
        right: AppDimens.space16,
        top: AppDimens.space16,
        bottom: bottomInset + AppDimens.space24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SOUL SANCTUARY • आनंद कोष',
                        style: AppTextStyles.labelBadge.copyWith(
                          color: AppColors.shieldPrimary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'ADD TO JOY RESERVOIR',
                        style: AppTextStyles.heading,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Category Selector
              Text('ANCHOR CLASSIFICATION', style: AppTextStyles.labelBadge.copyWith(fontSize: 9)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: JoyCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final color = cat.accentColor;
                  return ChoiceChip(
                    avatar: Icon(
                      cat.iconData,
                      size: 14,
                      color: isSelected ? color : AppColors.textMuted,
                    ),
                    label: Text(cat.badgeLabel),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        HapticService.selectionClick();
                        setState(() => _selectedCategory = cat);
                      }
                    },
                    selectedColor: color.withValues(alpha: 0.15),
                    backgroundColor: AppColors.surfaceElevated,
                    side: BorderSide(
                      color: isSelected ? color : AppColors.borderSubtle,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Title Field
              Text('ANCHOR TITLE', style: AppTextStyles.labelBadge.copyWith(fontSize: 9)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: _selectedCategory == JoyCategory.music
                      ? 'e.g., Morning Raga Bhairav / Rain Sounds'
                      : _selectedCategory == JoyCategory.visual
                          ? 'e.g., Evening Sunlight on Ocean / Mountain Peak'
                          : _selectedCategory == JoyCategory.quote
                              ? 'e.g., Marcus Aurelius on the Inner Citadel'
                              : 'e.g., Quiet Sunday Morning with Family',
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Media Link / Image URL Field
              Text(
                _selectedCategory == JoyCategory.music
                    ? 'YOUTUBE OR AUDIO LINK (OPTIONAL)'
                    : _selectedCategory == JoyCategory.visual
                        ? 'IMAGE URL (OPTIONAL)'
                        : 'EXTERNAL LINK (OPTIONAL)',
                style: AppTextStyles.labelBadge.copyWith(fontSize: 9),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _mediaUrlController,
                style: AppTextStyles.bodyMedium,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: _selectedCategory == JoyCategory.music
                      ? 'https://youtube.com/watch?v=... or audio URL'
                      : _selectedCategory == JoyCategory.visual
                          ? 'https://images.unsplash.com/... or image link'
                          : 'https://...',
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),

              // Note / Reflection Field
              Text(
                _selectedCategory == JoyCategory.quote
                    ? 'THE QUOTE / COMFORT WORDS'
                    : 'WHY THIS BRINGS YOU SERENITY / NOTES',
                style: AppTextStyles.labelBadge.copyWith(fontSize: 9),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                style: AppTextStyles.bodySmall,
                decoration: InputDecoration(
                  hintText: _selectedCategory == JoyCategory.quote
                      ? '“Nowhere can man find a quieter retreat than in his own soul...”'
                      : 'Reminds me to breathe, pause, and step back into quiet composure...',
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 20),

              // Save Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.favorite_rounded, size: 18),
                  label: const Text('ADD TO JOY RESERVOIR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: catColor,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
