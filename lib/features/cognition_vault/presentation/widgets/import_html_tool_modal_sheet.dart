import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/local_html_tool.dart';
import '../../data/services/html_tool_storage_service.dart';

/// ImportHtmlToolModalSheet lets executives pick an .html / .htm file from device storage,
/// permanently embeds it inside the app's persistent `app_html_tools/` sandbox,
/// checks for safe overwrites to prevent duplicate cards, and registers it in Hive.
class ImportHtmlToolModalSheet extends StatefulWidget {
  final ValueChanged<LocalHtmlTool>? onImported;

  const ImportHtmlToolModalSheet({
    super.key,
    this.onImported,
  });

  static Future<void> show(
    BuildContext context, {
    ValueChanged<LocalHtmlTool>? onImported,
  }) {
    HapticService.selectionClick();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLarge)),
      ),
      builder: (context) => ImportHtmlToolModalSheet(onImported: onImported),
    );
  }

  @override
  State<ImportHtmlToolModalSheet> createState() => _ImportHtmlToolModalSheetState();
}

class _ImportHtmlToolModalSheetState extends State<ImportHtmlToolModalSheet> {
  final HtmlToolStorageService _storageService = HtmlToolStorageService();

  String? _pickedFileName;
  String? _pickedFilePath;
  Uint8List? _pickedFileBytes;
  int _pickedFileSize = 0;
  bool _isPicking = false;
  bool _isSaving = false;
  bool _isOverwriteMode = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController(text: 'Dashboard');
  final TextEditingController _descriptionController = TextEditingController();

  static const List<String> _suggestedCategories = [
    'Dashboard',
    'Decision Matrix',
    'Calculator',
    'Mental Model',
    'Personal Tool',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickHtmlFile();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickHtmlFile() async {
    setState(() => _isPicking = true);
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['html', 'htm'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();
        final size = await file.length() ?? bytes.length;

        // Clean default title from filename
        var cleanTitle = file.name;
        if (cleanTitle.toLowerCase().endsWith('.html')) {
          cleanTitle = cleanTitle.substring(0, cleanTitle.length - 5);
        } else if (cleanTitle.toLowerCase().endsWith('.htm')) {
          cleanTitle = cleanTitle.substring(0, cleanTitle.length - 4);
        }
        cleanTitle = cleanTitle.replaceAll('_', ' ').replaceAll('-', ' ').trim();

        // Check if a tool with this sanitized file name already exists in sandbox
        final sanitized = _storageService.sanitizeFileName(file.name);
        final existing = await _storageService.findExistingTool(sanitized);

        setState(() {
          _pickedFileName = file.name;
          _pickedFilePath = file.path;
          _pickedFileBytes = bytes;
          _pickedFileSize = size;
          _isOverwriteMode = existing != null;

          if (existing != null) {
            _titleController.text = existing.title;
            _categoryController.text = existing.category;
            _descriptionController.text = existing.description ?? '';
          } else {
            _titleController.text = cleanTitle;
          }
          _isPicking = false;
        });

        HapticService.selectionClick();
      } else {
        setState(() => _isPicking = false);
      }
    } catch (e) {
      debugPrint('[ImportHtmlTool] File pick error: $e');
      setState(() => _isPicking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.loc.audioPickingError}: $e'),
            backgroundColor: AppColors.roseDanger,
          ),
        );
      }
    }
  }

  Future<void> _saveImportedTool() async {
    if (_pickedFileName == null || _pickedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.loc.selectHtmlFileFirst),
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
      return;
    }

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.loc.specifyTitleFirst),
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticService.heavyImpact();

    try {
      final result = await _storageService.importOrOverwriteTool(
        sourceFilePath: _pickedFilePath,
        originalFileName: _pickedFileName!,
        bytes: _pickedFileBytes!,
        title: title,
        category: _categoryController.text.trim().isEmpty
            ? 'Personal Tool'
            : _categoryController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onImported?.call(result.tool);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.emeraldSuccess, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.isOverwrite
                        ? '${context.loc.toolOverwrittenNotice} ("${result.tool.title}")'
                        : '${context.loc.toolImportedNotice} ("${result.tool.title}")',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.surfaceElevated,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('[ImportHtmlTool] Save error: $e');
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save tool: $e'),
            backgroundColor: AppColors.roseDanger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = _pickedFileName != null;
    final fileSizeKb = hasFile ? (_pickedFileSize / 1024).toStringAsFixed(1) : '0';
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppDimens.space16,
        right: AppDimens.space16,
        top: AppDimens.space16,
        bottom: bottomInset + AppDimens.space24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
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
                      context.loc.localHtmlSandbox.toUpperCase(),
                      style: AppTextStyles.labelBadge.copyWith(
                        color: const Color(0xFF10B981),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.loc.importHtmlToolTitle,
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

            // Safe Overwrite vs New Tool Status Banner
            if (hasFile) ...[
              Container(
                padding: const EdgeInsets.all(AppDimens.space12),
                decoration: BoxDecoration(
                  color: _isOverwriteMode
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                      : const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  border: Border.all(
                    color: _isOverwriteMode
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                        : const Color(0xFF10B981).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _isOverwriteMode
                          ? Icons.published_with_changes_rounded
                          : Icons.verified_rounded,
                      size: 18,
                      color: _isOverwriteMode
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOverwriteMode
                                ? context.loc.safeOverwriteMode
                                : 'PERSISTENT SANDBOX STORAGE',
                            style: AppTextStyles.labelBadge.copyWith(
                              fontSize: 9,
                              color: _isOverwriteMode
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF10B981),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isOverwriteMode
                                ? context.loc.safeOverwriteNotice
                                : context.loc.newToolImportMode,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // File Selector Box
            GestureDetector(
              onTap: _isPicking ? null : _pickHtmlFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  border: Border.all(
                    color: hasFile ? const Color(0xFF10B981) : AppColors.borderSubtle,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.html_rounded, color: Color(0xFF10B981), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasFile ? _pickedFileName! : 'Tap to Select .html / .htm File',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: hasFile ? AppColors.textPrimary : AppColors.shieldPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasFile
                                ? '$fileSizeKb KB • app_html_tools/'
                                : 'Pure offline dashboard, calculator, or decision matrix',
                            style: AppTextStyles.labelBadge.copyWith(
                              fontSize: 9,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isPicking)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(
                        hasFile ? Icons.swap_horiz_rounded : Icons.folder_open_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Title Field
            Text(context.loc.toolTitleLabel, style: AppTextStyles.labelBadge.copyWith(fontSize: 9)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'e.g., Executive Decision Matrix / Stress Calculator',
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

            // Category Field & Suggestion Chips
            Text(context.loc.toolCategoryLabel, style: AppTextStyles.labelBadge.copyWith(fontSize: 9)),
            const SizedBox(height: 6),
            TextField(
              controller: _categoryController,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'e.g., Dashboard, Calculator, Mental Model',
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
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _suggestedCategories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      label: Text(cat, style: const TextStyle(fontSize: 10)),
                      backgroundColor: AppColors.surfaceElevated,
                      side: const BorderSide(color: AppColors.borderSubtle),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        HapticService.selectionClick();
                        setState(() => _categoryController.text = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Description Field
            Text(context.loc.toolDescriptionLabel, style: AppTextStyles.labelBadge.copyWith(fontSize: 9)),
            const SizedBox(height: 6),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              style: AppTextStyles.bodySmall,
              decoration: InputDecoration(
                hintText: 'What cognitive, operational, or psychological problem does this tool solve?',
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

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (!hasFile || _isSaving) ? null : _saveImportedTool,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(
                        _isOverwriteMode
                            ? Icons.published_with_changes_rounded
                            : Icons.save_rounded,
                        size: 18,
                      ),
                label: Text(
                  _isOverwriteMode
                      ? context.loc.updateHtmlTool
                      : context.loc.saveHtmlTool,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isOverwriteMode
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF10B981),
                  foregroundColor: Colors.black,
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
    );
  }
}
