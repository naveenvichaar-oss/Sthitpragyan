import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../shared/widgets/voice_dictation_button.dart';
import '../../data/defensive_scripts_vault.dart';

/// DefensiveScriptEditSheet enables executives to add, edit, or delete
/// verbal deflection response scripts to handle hostile workplace situations.
class DefensiveScriptEditSheet extends StatefulWidget {
  final DefensiveScript? script;
  final String? initialCategory;
  final VoidCallback? onSaved;

  const DefensiveScriptEditSheet({
    super.key,
    this.script,
    this.initialCategory,
    this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    DefensiveScript? script,
    String? initialCategory,
    VoidCallback? onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusLarge),
        ),
      ),
      builder: (context) => DefensiveScriptEditSheet(
        script: script,
        initialCategory: initialCategory,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<DefensiveScriptEditSheet> createState() =>
      _DefensiveScriptEditSheetState();
}

class _DefensiveScriptEditSheetState extends State<DefensiveScriptEditSheet> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedCategory;
  bool _isCustomCategory = false;
  final TextEditingController _customCategoryController =
      TextEditingController();
  final TextEditingController _hostileTriggerController =
      TextEditingController();
  final TextEditingController _executiveScriptController =
      TextEditingController();
  final TextEditingController _tacticalRationaleController =
      TextEditingController();
  final TextEditingController _toneGuidanceController = TextEditingController();

  static const List<String> _standardCategories = [
    'Unjust Accusation',
    'Intimidation',
    'Impossible Deadlines',
    'Rules of Engagement',
    'Interruption',
    'Gaslighting',
    'Blame Shifting',
    'Passive Aggression',
    'Scope Creep',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.script;
    if (s != null) {
      if (_standardCategories.contains(s.category)) {
        _selectedCategory = s.category;
        _isCustomCategory = false;
      } else {
        _selectedCategory = 'Custom';
        _isCustomCategory = true;
        _customCategoryController.text = s.category;
      }
      _hostileTriggerController.text = s.hostileTrigger;
      _executiveScriptController.text = s.executiveScript;
      _tacticalRationaleController.text = s.tacticalRationale;
      _toneGuidanceController.text = s.toneGuidance;
    } else {
      final initial = widget.initialCategory;
      if (initial != null &&
          initial != 'All' &&
          initial != 'Pinned' &&
          _standardCategories.contains(initial)) {
        _selectedCategory = initial;
      } else {
        _selectedCategory = 'Unjust Accusation';
      }
      _isCustomCategory = false;
      _toneGuidanceController.text = '';
    }
  }

  @override
  void dispose() {
    _customCategoryController.dispose();
    _hostileTriggerController.dispose();
    _executiveScriptController.dispose();
    _tacticalRationaleController.dispose();
    _toneGuidanceController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final category = _isCustomCategory
        ? _customCategoryController.text.trim()
        : _selectedCategory;

    final scriptId = widget.script?.id ??
        'custom_script_${DateTime.now().millisecondsSinceEpoch}';

    final updatedScript = DefensiveScript(
      id: scriptId,
      category: category.isNotEmpty ? category : 'General',
      scenario: widget.script?.scenario ?? 'Custom workplace defense scenario.',
      hostileTrigger: _hostileTriggerController.text.trim(),
      executiveScript: _executiveScriptController.text.trim(),
      tacticalRationale: _tacticalRationaleController.text.trim(),
      toneGuidance: _toneGuidanceController.text.trim().isNotEmpty
          ? _toneGuidanceController.text.trim()
          : (mounted ? context.loc.defaultNeutralTone : 'Neutral, flat monotone, zero panic or over-explaining.'),
      isCustom: true,
    );

    await HiveStorage().saveDefensiveScript(updatedScript);
    HapticService.selectionClick();

    if (mounted) {
      widget.onSaved?.call();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.script == null
                ? context.loc.scriptSavedMsg
                : context.loc.scriptUpdatedMsg,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.background,
            ),
          ),
          backgroundColor: AppColors.shieldPrimary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: Text(
          context.loc.deleteScript,
          style: AppTextStyles.heading.copyWith(fontSize: 16),
        ),
        content: Text(
          context.loc.confirmDeleteScriptMsg,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              context.loc.cancel,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.roseDanger,
              foregroundColor: Colors.white,
            ),
            child: Text(context.loc.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.script != null) {
      await HiveStorage().deleteDefensiveScript(widget.script!.id);
      HapticService.selectionClick();

      if (mounted) {
        widget.onSaved?.call();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.loc.scriptDeletedMsg,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.background,
              ),
            ),
            backgroundColor: AppColors.roseDanger,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.script != null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space12,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderBright,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header Title & Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isEditing
                            ? Icons.edit_note_rounded
                            : Icons.add_moderator_rounded,
                        size: 20,
                        color: AppColors.shieldPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEditing
                            ? context.loc.editDefensiveScript
                            : context.loc.addDefensiveScript,
                        style: AppTextStyles.brandHeader.copyWith(
                          fontSize: 13,
                          letterSpacing: 1.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (isEditing)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 19,
                            color: AppColors.roseDanger,
                          ),
                          tooltip: context.loc.deleteScript,
                          onPressed: _handleDelete,
                        ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: AppColors.borderSubtle, height: 16),

              // Scrollable Fields
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Selector
                      Text(
                        context.loc.categoryHeaderLabel,
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 9.5,
                          color: AppColors.shieldPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ..._standardCategories.map((cat) {
                            final isSel = !_isCustomCategory &&
                                _selectedCategory == cat;
                            return ChoiceChip(
                              label: Text(cat),
                              selected: isSel,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategory = cat;
                                    _isCustomCategory = false;
                                  });
                                }
                              },
                              selectedColor: AppColors.surfaceElevated,
                              backgroundColor: AppColors.background,
                              side: BorderSide(
                                color: isSel
                                    ? AppColors.shieldPrimary
                                    : AppColors.borderSubtle,
                              ),
                              labelStyle: TextStyle(
                                fontSize: 11,
                                color: isSel
                                    ? AppColors.shieldPrimary
                                    : AppColors.textSecondary,
                                fontWeight: isSel
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              visualDensity: VisualDensity.compact,
                            );
                          }),
                          ChoiceChip(
                            label: Text(
                              context.loc.customCategoryOption,
                            ),
                            selected: _isCustomCategory,
                            onSelected: (selected) {
                              setState(() {
                                _isCustomCategory = true;
                                _selectedCategory = 'Custom';
                              });
                            },
                            selectedColor: AppColors.surfaceElevated,
                            backgroundColor: AppColors.background,
                            side: BorderSide(
                              color: _isCustomCategory
                                  ? AppColors.shieldPrimary
                                  : AppColors.borderSubtle,
                            ),
                            labelStyle: TextStyle(
                              fontSize: 11,
                              color: _isCustomCategory
                                  ? AppColors.shieldPrimary
                                  : AppColors.textSecondary,
                              fontWeight: _isCustomCategory
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      if (_isCustomCategory) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _customCategoryController,
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            hintText: context.loc.enterCustomCategoryHint,
                            hintStyle: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusSmall,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.borderSubtle,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          validator: (val) {
                            if (_isCustomCategory &&
                                (val == null || val.trim().isEmpty)) {
                              return context.loc.pleaseEnterCategoryError;
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Hostile Trigger
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.loc.hostileTriggerLabel.toUpperCase(),
                            style: AppTextStyles.labelBadge.copyWith(
                              fontSize: 9.5,
                              color: AppColors.roseDanger,
                            ),
                          ),
                          VoiceDictationButton(
                            controller: _hostileTriggerController,
                            onDictated: (_) => setState(() {}),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _hostileTriggerController,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: context.loc.provocationExampleHint,
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusSmall,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.borderSubtle,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return context.loc.pleaseEnterProvocationError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Defensive Response Script
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.loc.defensiveScriptLabel.toUpperCase(),
                            style: AppTextStyles.labelBadge.copyWith(
                              fontSize: 9.5,
                              color: AppColors.shieldPrimary,
                            ),
                          ),
                          VoiceDictationButton(
                            controller: _executiveScriptController,
                            onDictated: (_) => setState(() {}),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _executiveScriptController,
                        style: AppTextStyles.heading.copyWith(
                          fontSize: 15,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: context.loc.scriptExactWordsHint,
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusSmall,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.shieldPrimary,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return context.loc.pleaseEnterScriptError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Subtext / Tactical Rationale
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.loc.subtextLabel.toUpperCase(),
                            style: AppTextStyles.labelBadge.copyWith(
                              fontSize: 9.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          VoiceDictationButton(
                            controller: _tacticalRationaleController,
                            onDictated: (_) => setState(() {}),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _tacticalRationaleController,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: context.loc.subtextExampleHint,
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusSmall,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.borderSubtle,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Tone & Posture Guidance
                      Text(
                        context.loc.toneGuidanceLabel.toUpperCase(),
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 9.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _toneGuidanceController,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: context.loc.toneExampleHint,
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusSmall,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.borderSubtle,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Action Buttons: Cancel and Save
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderMedium),
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusSmall,
                          ),
                        ),
                      ),
                      child: Text(context.loc.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.shieldPrimary,
                        foregroundColor: AppColors.background,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusSmall,
                          ),
                        ),
                      ),
                      child: Text(
                        context.loc.save,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
