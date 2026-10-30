import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../shared/widgets/voice_dictation_button.dart';
import '../../data/models/character_trait_entry.dart';

/// AddCharacterEntryModalSheet provides a structured, austere notepad
/// for recording virtue and personal gravitas observations with speech-to-text support.
class AddCharacterEntryModalSheet extends StatefulWidget {
  final VoidCallback? onSaved;
  final CharacterTraitCategory? initialCategory;

  const AddCharacterEntryModalSheet({
    super.key,
    this.onSaved,
    this.initialCategory,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onSaved,
    CharacterTraitCategory? initialCategory,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLarge)),
      ),
      builder: (context) => AddCharacterEntryModalSheet(
        onSaved: onSaved,
        initialCategory: initialCategory,
      ),
    );
  }

  @override
  State<AddCharacterEntryModalSheet> createState() =>
      _AddCharacterEntryModalSheetState();
}

class _AddCharacterEntryModalSheetState extends State<AddCharacterEntryModalSheet> {
  final HiveStorage _storage = HiveStorage();

  late CharacterTraitCategory _selectedCategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _situationController = TextEditingController();
  final TextEditingController _behaviorController = TextEditingController();
  final TextEditingController _reflectionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  int _gravitasRating = 5;

  static const List<String> _suggestedTags = [
    '#StrategicSilence',
    '#ExecutiveVoice',
    '#Magnanimity',
    '#Stillness',
    '#NonDefensive',
    '#InnerGrace',
    '#Patience',
    '#Posture',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? CharacterTraitCategory.gravitas;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _situationController.dispose();
    _behaviorController.dispose();
    _reflectionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _addSuggestedTag(String tag) {
    HapticService.selectionClick();
    final current = _tagsController.text.trim();
    if (current.isEmpty) {
      _tagsController.text = tag;
    } else if (!current.contains(tag)) {
      _tagsController.text = '$current, $tag';
    }
    setState(() {});
  }

  void _saveEntry() async {
    final title = _titleController.text.trim();
    final behavior = _behaviorController.text.trim();

    if (behavior.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.loc.describeTraitPrompt),
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
      return;
    }

    HapticService.heavyImpact();

    // Parse tags
    final rawTags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final entry = CharacterTraitEntry(
      id: 'trait_${DateTime.now().millisecondsSinceEpoch}',
      category: _selectedCategory,
      title: title.isEmpty ? _selectedCategory.displayName : title,
      situation: _situationController.text.trim(),
      behaviorObservation: behavior,
      reflection: _reflectionController.text.trim().isEmpty
          ? null
          : _reflectionController.text.trim(),
      tags: rawTags,
      gravitasRating: _gravitasRating,
      timestamp: DateTime.now(),
    );

    await _storage.saveCharacterTrait(entry);

    if (mounted) {
      Navigator.of(context).pop();
      widget.onSaved?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.traitRecordedNotice(entry.title, _selectedCategory.displayName),
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _selectedCategory.accentColor;

    return Padding(
      padding: EdgeInsets.only(
        left: AppDimens.space16,
        right: AppDimens.space16,
        top: AppDimens.space16,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.space24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Drag Handle & Header
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.loc.sovereignTraitsBadge,
                      style: AppTextStyles.labelBadge.copyWith(
                        color: accent,
                        fontSize: 9.5,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(context.loc.recordCharacterTraitTitle, style: AppTextStyles.heading),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Category Selector Chips
            Text(
              context.loc.selectVirtueCategoryBadge,
              style: AppTextStyles.labelBadge.copyWith(
                color: AppColors.textMuted,
                fontSize: 9,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: CharacterTraitCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final catColor = cat.accentColor;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      selectedColor: catColor.withValues(alpha: 0.2),
                      backgroundColor: AppColors.surfaceElevated,
                      side: BorderSide(
                        color: isSelected ? catColor : AppColors.borderSubtle,
                        width: 1.0,
                      ),
                      avatar: Icon(
                        cat.icon,
                        size: 14,
                        color: isSelected ? catColor : AppColors.textMuted,
                      ),
                      label: Text(
                        '${cat.displayName} (${cat.devanagari})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? catColor : AppColors.textSecondary,
                        ),
                      ),
                      onSelected: (val) {
                        if (val) {
                          HapticService.selectionClick();
                          setState(() => _selectedCategory = cat);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Category Subtitle
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accent.withValues(alpha: 0.25)),
              ),
              child: Text(
                _selectedCategory.subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: accent,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Short Title / Key Summary
            TextField(
              controller: _titleController,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                labelText: context.loc.headlineTraitSummaryLabel,
                hintText: context.loc.headlineTraitSummaryHint,
                filled: true,
                fillColor: AppColors.surfaceElevated,
              ),
            ),
            const SizedBox(height: 12),

            // 4. Arena Context
            TextField(
              controller: _situationController,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                labelText: context.loc.arenaTriggerContextLabel,
                hintText: context.loc.arenaTriggerContextHint,
                filled: true,
                fillColor: AppColors.surfaceElevated,
              ),
            ),
            const SizedBox(height: 12),

            // 5. Behavior Observation & Restraint (With Voice Dictation!)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.loc.observationEmbodiedActionBadge,
                  style: AppTextStyles.labelBadge.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 9,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.loc.voiceDictateLabel,
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(width: 4),
                    VoiceDictationButton(
                      controller: _behaviorController,
                      onDictated: (_) => setState(() {}),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _behaviorController,
              maxLines: 4,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: context.loc.behaviorObservationHint,
                filled: true,
                fillColor: AppColors.surfaceElevated,
              ),
            ),
            const SizedBox(height: 12),

            // 6. Reflection / Lesson
            TextField(
              controller: _reflectionController,
              maxLines: 2,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                labelText: context.loc.keyRealizationAnchorLabel,
                hintText: context.loc.keyRealizationAnchorHint,
                filled: true,
                fillColor: AppColors.surfaceElevated,
              ),
            ),
            const SizedBox(height: 14),

            // 7. Custom Virtue Tags
            TextField(
              controller: _tagsController,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                labelText: context.loc.customTagsLabel,
                hintText: '#StrategicSilence, #ExecutiveVoice',
                filled: true,
                fillColor: AppColors.surfaceElevated,
              ),
            ),
            const SizedBox(height: 8),

            // Quick Tag Chips
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _suggestedTags.map((tag) {
                return ActionChip(
                  label: Text(tag, style: const TextStyle(fontSize: 10)),
                  backgroundColor: AppColors.surfaceElevated,
                  side: const BorderSide(color: AppColors.borderSubtle),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  onPressed: () => _addSuggestedTag(tag),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // 8. Gravitas Rating (1-5 Shields)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.loc.gravitasRatingBadge,
                  style: AppTextStyles.labelBadge.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 9,
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    final ratingVal = index + 1;
                    final isActive = ratingVal <= _gravitasRating;
                    return IconButton(
                      icon: Icon(
                        isActive ? Icons.shield_rounded : Icons.shield_outlined,
                        size: 20,
                        color: isActive
                            ? const Color(0xFFF59E0B)
                            : AppColors.textMuted,
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      onPressed: () {
                        HapticService.selectionClick();
                        setState(() => _gravitasRating = ratingVal);
                      },
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 9. Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.check, size: 18),
                label: Text(
                  context.loc.saveToCharacterLedgerButton,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                onPressed: _saveEntry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
