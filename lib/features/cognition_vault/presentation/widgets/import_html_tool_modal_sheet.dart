import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/local_html_tool.dart';

/// ImportHtmlToolModalSheet lets users pick an .html / .htm file from device storage,
/// securely copies it to the app's persistent documents directory, prompts for metadata,
/// and registers it in the offline HTML Tools repository.
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
  final HiveStorage _storage = HiveStorage();

  String? _pickedFileName;
  String? _pickedFilePath;
  Uint8List? _pickedFileBytes;
  int _pickedFileSize = 0;
  String? _htmlString;
  bool _isPicking = false;

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
    // Auto-open file picker when sheet opens for zero friction
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
        String? content;

        try {
          content = utf8.decode(bytes);
        } catch (_) {
          content = String.fromCharCodes(bytes);
        }

        // Clean default title from filename
        var cleanTitle = file.name;
        if (cleanTitle.toLowerCase().endsWith('.html')) {
          cleanTitle = cleanTitle.substring(0, cleanTitle.length - 5);
        } else if (cleanTitle.toLowerCase().endsWith('.htm')) {
          cleanTitle = cleanTitle.substring(0, cleanTitle.length - 4);
        }
        cleanTitle = cleanTitle.replaceAll('_', ' ').replaceAll('-', ' ');

        setState(() {
          _pickedFileName = file.name;
          _pickedFilePath = file.path;
          _pickedFileBytes = bytes;
          _pickedFileSize = size;
          _htmlString = content;
          _titleController.text = cleanTitle;
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
            content: Text('File picker error: $e'),
            backgroundColor: AppColors.roseDanger,
          ),
        );
      }
    }
  }

  Future<void> _saveImportedTool() async {
    if (_pickedFileName == null || _pickedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an HTML file to import.'),
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
      return;
    }

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please specify a title for this tool.'),
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
      return;
    }

    HapticService.heavyImpact();

    String persistentPath = '';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedFileName = '${timestamp}_$_pickedFileName';

    if (!kIsWeb) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final toolsDir = Directory('${appDir.path}/html_tools');
        if (!await toolsDir.exists()) {
          await toolsDir.create(recursive: true);
        }

        final targetFile = File('${toolsDir.path}/$sanitizedFileName');
        await targetFile.writeAsBytes(_pickedFileBytes!);
        persistentPath = targetFile.path;
      } catch (e) {
        debugPrint('[ImportHtmlTool] File copy error: $e');
        persistentPath = _pickedFilePath ?? '';
      }
    } else {
      persistentPath = 'web_storage/$sanitizedFileName';
    }

    final tool = LocalHtmlTool(
      id: 'tool_$timestamp',
      title: title,
      localFilePath: persistentPath,
      htmlContent: _htmlString,
      addedDate: DateTime.now(),
      category: _categoryController.text.trim().isEmpty
          ? 'Personal Tool'
          : _categoryController.text.trim(),
      fileName: _pickedFileName!,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      fileSizeBytes: _pickedFileSize,
    );

    await _storage.saveHtmlTool(tool);

    if (mounted) {
      Navigator.of(context).pop();
      widget.onImported?.call(tool);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported "${tool.title}" into Offline HTML Tools.',
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = _pickedFileName != null;
    final fileSizeKb = hasFile ? (_pickedFileSize / 1024).toStringAsFixed(1) : '0';

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
            // Drag handle
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

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OFFLINE ARCHITECTURE • स्थानीय उपकरण',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: const Color(0xFF10B981),
                        fontSize: 9.5,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text('Import HTML Tool / Dashboard', style: AppTextStyles.heading),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // File Selection Box
            Container(
              padding: const EdgeInsets.all(AppDimens.space14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                border: Border.all(
                  color: hasFile
                      ? const Color(0xFF10B981).withValues(alpha: 0.4)
                      : AppColors.borderSubtle,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: hasFile
                          ? const Color(0xFF10B981).withValues(alpha: 0.12)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      hasFile ? Icons.html_rounded : Icons.file_open_outlined,
                      size: 24,
                      color: hasFile
                          ? const Color(0xFF10B981)
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasFile ? _pickedFileName! : 'No HTML File Selected',
                          style: AppTextStyles.titleSmall.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasFile
                              ? '$fileSizeKb KB • Permanent Local Copy'
                              : 'Select any standalone .html / .htm file',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _isPicking ? null : _pickHtmlFile,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.shieldPrimary,
                      side: const BorderSide(color: AppColors.shieldPrimary),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(_isPicking ? 'PICKING...' : (hasFile ? 'CHANGE' : 'BROWSE')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title Field
            TextField(
              controller: _titleController,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Tool Title',
                hintText: 'e.g., Executive Decision Matrix',
                filled: true,
                fillColor: AppColors.surfaceElevated,
              ),
            ),
            const SizedBox(height: 12),

            // Category Field
            TextField(
              controller: _categoryController,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Category / Tag',
                hintText: 'e.g., Dashboard, Calculator, Matrix',
                filled: true,
                fillColor: AppColors.surfaceElevated,
              ),
            ),
            const SizedBox(height: 8),

            // Quick Category Chips
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _suggestedCategories.map((cat) {
                return ActionChip(
                  label: Text(cat, style: const TextStyle(fontSize: 10)),
                  backgroundColor: AppColors.surfaceElevated,
                  side: const BorderSide(color: AppColors.borderSubtle),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  onPressed: () {
                    HapticService.selectionClick();
                    setState(() => _categoryController.text = cat);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Description Field
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Description / Purpose (Optional)',
                hintText: 'What cognitive friction or workflow does this offline dashboard solve?',
                filled: true,
                fillColor: AppColors.surfaceElevated,
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.check, size: 18),
                label: const Text(
                  'IMPORT & SAVE OFFLINE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                onPressed: _saveImportedTool,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
