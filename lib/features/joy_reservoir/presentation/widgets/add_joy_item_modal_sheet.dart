import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/joy_item.dart';

/// Modal sheet allowing executives to add personal serenity and joy anchors
/// (Music/Playlists, Local Offline Audio, Visual Anchors, Comfort Words, Memories)
class AddJoyItemModalSheet extends StatefulWidget {
  final JoyCategory? initialCategory;
  final String? initialTitle;
  final String? initialUrlOrPath;
  final VoidCallback onSaved;

  const AddJoyItemModalSheet({
    super.key,
    this.initialCategory,
    this.initialTitle,
    this.initialUrlOrPath,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    JoyCategory? initialCategory,
    String? initialTitle,
    String? initialUrlOrPath,
    required VoidCallback onSaved,
  }) {
    HapticService.selectionClick();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusLarge),
        ),
      ),
      builder: (context) => AddJoyItemModalSheet(
        initialCategory: initialCategory,
        initialTitle: initialTitle,
        initialUrlOrPath: initialUrlOrPath,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<AddJoyItemModalSheet> createState() => _AddJoyItemModalSheetState();
}

class _AddJoyItemModalSheetState extends State<AddJoyItemModalSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _mediaUrlController;
  final TextEditingController _noteController = TextEditingController();

  late JoyCategory _selectedCategory;
  String? _pickedAudioFileName;
  int? _pickedAudioFileSize;
  bool _isPickingAudio = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? JoyCategory.music;
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _mediaUrlController = TextEditingController(text: widget.initialUrlOrPath ?? '');

    if (widget.initialUrlOrPath != null && _isLocalPath(widget.initialUrlOrPath!)) {
      _pickedAudioFileName = widget.initialUrlOrPath!.split(Platform.pathSeparator).last;
    }
  }

  bool _isLocalPath(String path) {
    final trimmed = path.trim();
    return trimmed.isNotEmpty &&
        !trimmed.startsWith('http://') &&
        !trimmed.startsWith('https://');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _mediaUrlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickLocalAudioFile() async {
    HapticService.selectionClick();
    setState(() => _isPickingAudio = true);

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'flac', 'ogg'],
      );

      if (files.isNotEmpty) {
        final platformFile = files.first;
        String finalPath = platformFile.path ?? '';
        final size = await platformFile.length() ?? 0;

        if (!kIsWeb && platformFile.path != null) {
          // Copy to app's secure persistent audio directory
          final appDir = await getApplicationDocumentsDirectory();
          final audioDir = Directory('${appDir.path}/joy_audio');
          if (!await audioDir.exists()) {
            await audioDir.create(recursive: true);
          }

          final cleanFileName = platformFile.name.replaceAll(' ', '_');
          final destination =
              '${audioDir.path}/${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';
          final saved = await File(platformFile.path!).copy(destination);
          finalPath = saved.path;
        }

        // Clean default title from file name if title is currently empty
        var cleanTitle = platformFile.name;
        cleanTitle = cleanTitle.replaceAll(
          RegExp(r'\.(mp3|m4a|wav|aac|flac|ogg)$', caseSensitive: false),
          '',
        );
        cleanTitle = cleanTitle.replaceAll('_', ' ').replaceAll('-', ' ').trim();

        setState(() {
          _mediaUrlController.text = finalPath;
          _pickedAudioFileName = platformFile.name;
          _pickedAudioFileSize = size;
          if (_titleController.text.trim().isEmpty && cleanTitle.isNotEmpty) {
            _titleController.text = cleanTitle;
          }
          _isPickingAudio = false;
        });

        HapticService.success();
      } else {
        setState(() => _isPickingAudio = false);
      }
    } catch (e) {
      debugPrint('[AddJoyItemModalSheet] Audio pick error: $e');
      setState(() => _isPickingAudio = false);
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

  void _clearPickedAudio() {
    HapticService.selectionClick();
    setState(() {
      _pickedAudioFileName = null;
      _pickedAudioFileSize = null;
      _mediaUrlController.clear();
    });
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
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.spa_rounded, color: AppColors.emeraldSuccess, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.loc.joyAnchorSaved,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final catColor = _selectedCategory.accentColor;
    final isMusic = _selectedCategory == JoyCategory.music;
    final hasPickedAudio = _pickedAudioFileName != null ||
        (_mediaUrlController.text.isNotEmpty && _isLocalPath(_mediaUrlController.text));

    return SafeArea(
      bottom: true,
      child: Padding(
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
                        context.loc.soulSanctuaryBadge,
                        style: AppTextStyles.labelBadge.copyWith(
                          color: AppColors.shieldPrimary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.loc.addToJoyReservoir,
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
              Text(
                context.loc.anchorClassification,
                style: AppTextStyles.labelBadge.copyWith(fontSize: 9),
              ),
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
              Text(
                context.loc.anchorTitle,
                style: AppTextStyles.labelBadge.copyWith(fontSize: 9),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: _selectedCategory == JoyCategory.music
                      ? context.loc.anchorTitleHint
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
                    return context.loc.anchorTitleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Local Audio File Picker Section (for Music category)
              if (isMusic) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.loc.localAudioFile.toUpperCase(),
                      style: AppTextStyles.labelBadge.copyWith(fontSize: 9),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isPickingAudio ? null : _pickLocalAudioFile,
                      icon: _isPickingAudio
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 1.5),
                            )
                          : const Icon(Icons.audio_file_rounded, size: 14),
                      label: Text(
                        context.loc.selectLocalAudio,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.shieldPrimary,
                        side: const BorderSide(color: AppColors.shieldPrimary, width: 0.8),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                    ),
                  ],
                ),
                if (hasPickedAudio) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                      border: Border.all(
                        color: AppColors.shieldPrimary.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: AppColors.emeraldSuccess,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _pickedAudioFileName ??
                                    _mediaUrlController.text.split(Platform.pathSeparator).last,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_pickedAudioFileSize != null)
                                Text(
                                  '${context.loc.fileSizeLabel}: ${_formatFileSize(_pickedAudioFileSize!)} • ${context.loc.localAudioAnchor}',
                                  style: AppTextStyles.labelBadge.copyWith(
                                    fontSize: 8.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                          onPressed: _clearPickedAudio,
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Clear',
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],

              // Media Link / Image URL Field
              Text(
                isMusic
                    ? context.loc.anchorMediaOptional
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
                  hintText: isMusic
                      ? context.loc.musicLinkHint
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
                    : context.loc.anchorNoteLabel,
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
                      : context.loc.anchorNoteHint,
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
                  label: Text(context.loc.addToJoyReservoir),
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
    ),
  );
}
}
