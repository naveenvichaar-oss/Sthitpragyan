import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/fallacy_and_model.dart';

/// Modal sheet for adding or editing a Mental Model or Logical Fallacy in Vault
class AddCognitionItemModalSheet extends StatefulWidget {
  final CognitionType initialType;
  final CognitionItem? itemToEdit;
  final void Function(CognitionItem savedItem)? onSaved;

  const AddCognitionItemModalSheet({
    super.key,
    required this.initialType,
    this.itemToEdit,
    this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required CognitionType initialType,
    CognitionItem? itemToEdit,
    void Function(CognitionItem savedItem)? onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddCognitionItemModalSheet(
        initialType: initialType,
        itemToEdit: itemToEdit,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<AddCognitionItemModalSheet> createState() =>
      _AddCognitionItemModalSheetState();
}

class _AddCognitionItemModalSheetState
    extends State<AddCognitionItemModalSheet> {
  final HiveStorage _storage = HiveStorage();

  late CognitionType _selectedType;
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _latinController;
  late TextEditingController _definitionController;
  late TextEditingController _scenarioController;
  late TextEditingController _antidoteController;
  late TextEditingController _maximController;
  late TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    _selectedType = item?.type ?? widget.initialType;
    _titleController = TextEditingController(text: item?.title ?? '');
    _subtitleController = TextEditingController(text: item?.subtitle ?? '');
    _latinController = TextEditingController(text: item?.latinName ?? '');
    _definitionController = TextEditingController(text: item?.definition ?? '');
    _scenarioController =
        TextEditingController(text: item?.corporateManifestation ?? '');
    _antidoteController =
        TextEditingController(text: item?.antidoteProtocol ?? '');
    _maximController = TextEditingController(text: item?.quickMaxim ?? '');
    _tagsController = TextEditingController(text: item?.tags.join(', ') ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _latinController.dispose();
    _definitionController.dispose();
    _scenarioController.dispose();
    _antidoteController.dispose();
    _maximController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      HapticService.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.titleRequiredError,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.roseDanger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticService.mediumImpact();
    final isEditing = widget.itemToEdit != null;
    final id = isEditing
        ? widget.itemToEdit!.id
        : 'custom_${DateTime.now().millisecondsSinceEpoch}';

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final item = CognitionItem(
      id: id,
      type: _selectedType,
      title: title,
      subtitle: _subtitleController.text.trim(),
      latinName: _latinController.text.trim().isEmpty
          ? (_selectedType == CognitionType.fallacy
              ? 'Logical Fallacy'
              : 'Mental Model')
          : _latinController.text.trim(),
      definition: _definitionController.text.trim(),
      corporateManifestation: _scenarioController.text.trim(),
      antidoteProtocol: _antidoteController.text.trim(),
      quickMaxim: _maximController.text.trim(),
      tags: tags.isEmpty ? ['Custom', 'Framework'] : tags,
      audioAttachmentPath: widget.itemToEdit?.audioAttachmentPath,
      videoAttachmentPath: widget.itemToEdit?.videoAttachmentPath,
      isCustom: true,
    );

    await _storage.saveCognitionItem(item);
    widget.onSaved?.call(item);
    HapticService.success();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.savedToVaultSuccess,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.emeraldSuccess,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemToEdit != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusLarge),
        ),
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppDimens.space16,
            AppDimens.space12,
            AppDimens.space16,
            bottomInset + AppDimens.space16,
          ),
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
              const SizedBox(height: 12),

              // Title Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing
                        ? context.loc.editFrameworkCard
                        : context.loc.addToVaultCard,
                    style: AppTextStyles.heading.copyWith(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Type Selector (Mental Model vs Logical Fallacy)
              Row(
                children: [
                  _buildTypeChoice(
                    CognitionType.mentalModel,
                    context.loc.typeChoiceMentalModel,
                  ),
                  const SizedBox(width: 8),
                  _buildTypeChoice(
                    CognitionType.fallacy,
                    context.loc.typeChoiceFallacy,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Form fields scrollable
              Expanded(
                child: ListView(
                  children: [
                    _buildTextField(
                      controller: _titleController,
                      label: context.loc.frameworkTitleLabel,
                      hint: context.loc.frameworkTitleHint,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _subtitleController,
                      label: context.loc.frameworkSubtitleLabel,
                      hint: context.loc.frameworkSubtitleHint,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _definitionController,
                      label: context.loc.frameworkMechanismLabel,
                      hint: context.loc.frameworkMechanismHint,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _scenarioController,
                      label: context.loc.frameworkScenarioLabel,
                      hint: context.loc.frameworkScenarioHint,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _antidoteController,
                      label: context.loc.frameworkAntidoteLabel,
                      hint: context.loc.frameworkAntidoteHint,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _maximController,
                      label: context.loc.frameworkMaximLabel,
                      hint: context.loc.frameworkMaximHint,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _tagsController,
                      label: context.loc.frameworkTagsLabel,
                      hint: context.loc.frameworkTagsHint,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Save Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text(
                    context.loc.saveToVaultButton,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.shieldPrimary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildTypeChoice(CognitionType type, String label) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticService.selectionClick();
          setState(() => _selectedType = type);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? AppColors.shieldPrimary : AppColors.borderSubtle,
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.shieldPrimary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelBadge.copyWith(
            color: AppColors.textSecondary,
            fontSize: 9.5,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
