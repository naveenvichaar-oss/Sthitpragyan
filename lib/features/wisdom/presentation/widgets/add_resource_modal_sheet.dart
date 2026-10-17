import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/resource_link.dart';

/// AddResourceModalSheet lets executives save verified personal links (YouTube,
/// Google Drive PDFs, Google Keep notes) directly to Hive with zero telemetry.
class AddResourceModalSheet extends StatefulWidget {
  final VoidCallback onSaved;

  const AddResourceModalSheet({
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
      builder: (context) => AddResourceModalSheet(onSaved: onSaved),
    );
  }

  @override
  State<AddResourceModalSheet> createState() => _AddResourceModalSheetState();
}

class _AddResourceModalSheetState extends State<AddResourceModalSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  ResourceMediaType _selectedMediaType = ResourceMediaType.webLink;
  String _selectedCategory = 'Gita & Sthitaprajna';
  bool _userExplicitlySelectedMediaType = false;
  String? _autoDetectionBadge;

  final List<String> _categories = [
    'Gita & Sthitaprajna',
    'Western Stoicism',
    'Psychology & Models',
    'Executive Protocols',
    'Personal Sanctuaries',
  ];

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_onUrlChanged);
  }

  void _onUrlChanged() {
    final text = _urlController.text.trim();
    if (text.isEmpty) {
      if (!_userExplicitlySelectedMediaType && _autoDetectionBadge != null) {
        setState(() {
          _autoDetectionBadge = null;
          _selectedMediaType = ResourceMediaType.webLink;
        });
      }
      return;
    }

    final detected = ResourceLink.detectMediaTypeFromUrl(text);
    if (!_userExplicitlySelectedMediaType) {
      if (_selectedMediaType != detected) {
        setState(() {
          _selectedMediaType = detected;
          _autoDetectionBadge = detected != ResourceMediaType.webLink
              ? 'Auto-detected: ${detected.displayName}'
              : null;
        });
      }
    } else {
      // User picked a chip manually, but if it now matches detected, we can still show badge
      if (detected != ResourceMediaType.webLink && _selectedMediaType == detected) {
        if (_autoDetectionBadge == null) {
          setState(() {
            _autoDetectionBadge = 'Auto-detected: ${detected.displayName}';
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _titleController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      HapticService.error();
      return;
    }

    final rawUrl = _urlController.text.trim();
    // Auto-customize media type if left as default webLink or if matching YouTube/Drive/Keep
    var finalMediaType = _selectedMediaType;
    if (finalMediaType == ResourceMediaType.webLink || !_userExplicitlySelectedMediaType) {
      final detected = ResourceLink.detectMediaTypeFromUrl(rawUrl);
      if (detected != ResourceMediaType.webLink) {
        finalMediaType = detected;
      }
    }

    HapticService.success();
    final newResource = ResourceLink(
      id: 'res_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      category: _selectedCategory,
      mediaType: finalMediaType,
      url: rawUrl,
      isUserAdded: true,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    await HiveStorage().saveResourceLink(newResource);
    widget.onSaved();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.emeraldSuccess, size: 16),
              SizedBox(width: 8),
              Text('Resource link saved to offline Sanctuary', style: TextStyle(fontSize: 12)),
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
                        'RESOURCE SANCTUARY',
                        style: AppTextStyles.labelBadge.copyWith(
                          color: AppColors.shieldPrimary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'ADD PERSONAL RESOURCE',
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

              // Media Type Selector
              Text('MEDIA CLASSIFICATION', style: AppTextStyles.labelBadge.copyWith(fontSize: 9)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ResourceMediaType.values.map((type) {
                  final isSelected = _selectedMediaType == type;
                  final color = type.accentColor;
                  return ChoiceChip(
                    avatar: Icon(
                      type.iconData,
                      size: 14,
                      color: isSelected ? color : AppColors.textMuted,
                    ),
                    label: Text(type.badgeLabel),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        HapticService.selectionClick();
                        setState(() {
                          _selectedMediaType = type;
                          _userExplicitlySelectedMediaType = true;
                          _autoDetectionBadge = null;
                        });
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
              if (_autoDetectionBadge != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _selectedMediaType.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    border: Border.all(
                      color: _selectedMediaType.accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 13, color: _selectedMediaType.accentColor),
                      const SizedBox(width: 6),
                      Text(
                        _autoDetectionBadge!,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: _selectedMediaType.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // Title Field
              Text('RESOURCE TITLE', style: AppTextStyles.labelBadge.copyWith(fontSize: 9)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'e.g., Executive Crisis Protocol Note / Video',
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

              // URL Field
              Text('RESOURCE URL / LINK', style: AppTextStyles.labelBadge.copyWith(fontSize: 9)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _urlController,
                style: AppTextStyles.bodyMedium,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: 'https://youtube.com/... or https://drive.google.com/...',
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
                    return 'URL is required';
                  }
                  final trimmed = val.trim();
                  if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
                    return 'URL must start with https:// or http://';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Category Selector
              Text('CATEGORY CLUSTER', style: AppTextStyles.labelBadge.copyWith(fontSize: 9)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    style: AppTextStyles.bodyMedium,
                    items: _categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat, style: const TextStyle(fontSize: 12.5)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategory = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Optional Notes Field
              Text('KEY TAKEAWAYS / NOTES (OPTIONAL)', style: AppTextStyles.labelBadge.copyWith(fontSize: 9)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                style: AppTextStyles.bodySmall,
                decoration: InputDecoration(
                  hintText: 'Quick summary or why this resource resets your frame...',
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
                  icon: const Icon(Icons.bookmark_add_rounded, size: 18),
                  label: const Text('SAVE TO PERSONAL SANCTUARY'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.shieldPrimary,
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
