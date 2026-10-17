import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../joy_reservoir/data/models/joy_item.dart';
import '../../../recovery/data/models/incident_slip_up_log.dart';
import '../../../wisdom/data/models/resource_link.dart';

/// Supported target destinations when content is shared into Sthitaprajna
enum ShareDestination {
  cognitionVault,
  joyReservoir,
  recoveryReference;

  String get displayName {
    switch (this) {
      case ShareDestination.cognitionVault:
        return 'Cognition Vault';
      case ShareDestination.joyReservoir:
        return 'Joy Reservoir';
      case ShareDestination.recoveryReference:
        return 'Recovery Reference';
    }
  }

  String get badgeLabel {
    switch (this) {
      case ShareDestination.cognitionVault:
        return 'COGNITION VAULT';
      case ShareDestination.joyReservoir:
        return 'JOY RESERVOIR';
      case ShareDestination.recoveryReference:
        return 'RECOVERY REFERENCE';
    }
  }

  IconData get iconData {
    switch (this) {
      case ShareDestination.cognitionVault:
        return Icons.psychology_rounded;
      case ShareDestination.joyReservoir:
        return Icons.spa_rounded;
      case ShareDestination.recoveryReference:
        return Icons.shield_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case ShareDestination.cognitionVault:
        return const Color(0xFF38BDF8); // Sky Blue
      case ShareDestination.joyReservoir:
        return const Color(0xFFF43F5E); // Rose Serenity
      case ShareDestination.recoveryReference:
        return const Color(0xFFF59E0B); // Amber Warning / Defense
    }
  }
}

/// Contextual bottom sheet dialog when sharing text, links, or media into Sthitaprajna
class IncomingShareModalSheet extends StatefulWidget {
  final String rawContent;
  final String? mediaPath;
  final VoidCallback? onSaved;

  const IncomingShareModalSheet({
    super.key,
    required this.rawContent,
    this.mediaPath,
    this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required String rawContent,
    String? mediaPath,
    VoidCallback? onSaved,
  }) {
    HapticService.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusLarge),
        ),
      ),
      builder: (context) => IncomingShareModalSheet(
        rawContent: rawContent,
        mediaPath: mediaPath,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<IncomingShareModalSheet> createState() => _IncomingShareModalSheetState();
}

class _IncomingShareModalSheetState extends State<IncomingShareModalSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _contentController;
  late TextEditingController _titleController;
  late TextEditingController _noteController;

  ShareDestination _selectedDestination = ShareDestination.cognitionVault;

  // Cognition Vault fields
  ResourceMediaType _selectedMediaType = ResourceMediaType.webLink;
  String _cognitionCategory = 'Gita & Sthitaprajna';
  final List<String> _cognitionCategories = [
    'Gita & Sthitaprajna',
    'Western Stoicism',
    'Psychology & Models',
    'Executive Protocols',
    'Personal Sanctuaries',
  ];

  // Joy Reservoir fields
  JoyCategory _joyCategory = JoyCategory.music;

  // Recovery Reference sub-tags
  String _recoveryTag = 'De-Escalation';
  final List<String> _recoveryTags = [
    'De-Escalation',
    'Damage Control',
    'Emotional Detachment',
    'Boardroom Manipulation',
    'Boundary Enforcement',
  ];

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.rawContent);
    _titleController = TextEditingController(text: _deriveInitialTitle(widget.rawContent));
    _noteController = TextEditingController();

    // Auto-detect media type and pre-select destination if matching music/joy
    _autoConfigureFromContent(widget.rawContent);
  }

  void _autoConfigureFromContent(String content) {
    final detectedType = ResourceLink.detectMediaTypeFromUrl(content);
    _selectedMediaType = detectedType;

    // If it's a YouTube music or ambient audio, suggest Joy Reservoir
    final lower = content.toLowerCase();
    if (lower.contains('music.youtube.com') ||
        lower.contains('spotify.com') ||
        lower.contains('ambient') ||
        lower.contains('raga') ||
        lower.contains('relax')) {
      _selectedDestination = ShareDestination.joyReservoir;
      _joyCategory = JoyCategory.music;
    } else if (lower.contains('crisis') ||
        lower.contains('apology') ||
        lower.contains('conflict') ||
        lower.contains('manipulation')) {
      _selectedDestination = ShareDestination.recoveryReference;
    }
  }

  String _deriveInitialTitle(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'Shared Item';

    // If it is a URL, derive a clean title
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      try {
        final uri = Uri.parse(trimmed);
        final host = uri.host.replaceAll('www.', '');
        final lastSegment = uri.pathSegments.isNotEmpty
            ? uri.pathSegments.last.replaceAll(RegExp(r'[-_]'), ' ')
            : '';
        if (lastSegment.isNotEmpty && lastSegment.length > 2) {
          return '${lastSegment[0].toUpperCase()}${lastSegment.substring(1)} ($host)';
        }
        return 'Saved from $host';
      } catch (_) {}
    }

    // If it's plain text, take the first 40 characters
    if (trimmed.length > 40) {
      return '${trimmed.substring(0, 40).trim()}...';
    }
    return trimmed;
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      HapticService.error();
      return;
    }

    final content = _contentController.text.trim();
    final title = _titleController.text.trim();
    final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();
    final storage = HiveStorage();

    HapticService.success();

    switch (_selectedDestination) {
      case ShareDestination.cognitionVault:
        final resource = ResourceLink(
          id: 'shared_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          category: _cognitionCategory,
          mediaType: _selectedMediaType,
          url: content,
          isUserAdded: true,
          notes: note,
          createdAt: DateTime.now(),
        );
        await storage.saveResourceLink(resource);
        break;

      case ShareDestination.joyReservoir:
        final joy = JoyItem(
          id: 'joy_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          category: _joyCategory,
          mediaUrlOrPath: content.isEmpty ? widget.mediaPath : content,
          note: note,
          timestamp: DateTime.now(),
        );
        await storage.saveJoyItem(joy);
        break;

      case ShareDestination.recoveryReference:
        // Save as a tactical reference resource with full URL launch support
        final recoveryResource = ResourceLink(
          id: 'rec_ref_${DateTime.now().millisecondsSinceEpoch}',
          title: '[$_recoveryTag] $title',
          category: 'Recovery Reference',
          mediaType: ResourceLink.detectMediaTypeFromUrl(content),
          url: content,
          isUserAdded: true,
          notes: note != null
              ? 'Tactical Tag: $_recoveryTag\n\nIntent / Notes:\n$note'
              : 'Tactical Tag: $_recoveryTag',
          createdAt: DateTime.now(),
        );
        await storage.saveResourceLink(recoveryResource);

        // Also record a situational reference log entry
        final slipLog = IncidentSlipUpLog(
          id: 'slip_ref_${DateTime.now().millisecondsSinceEpoch}',
          timestamp: DateTime.now(),
          trigger: title,
          mistakeType: 'Tactical Reference Saved',
          physicalState: 'Strategic Review',
          archetype: 'The Stoic',
          idealResponse: note ?? 'Saved tactical guidance',
          revisedScript: content,
          damageControlScriptUsed: _recoveryTag,
          boxBreathingCompleted: false,
        );
        await storage.saveSlipUpIncident(slipLog);
        break;
    }

    widget.onSaved?.call();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.emeraldSuccess, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Successfully saved to ${_selectedDestination.displayName} with notes.',
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
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final destColor = _selectedDestination.accentColor;

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
                        context.loc.systemShareInterceptor,
                        style: AppTextStyles.labelBadge.copyWith(
                          color: AppColors.shieldPrimary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'SAVE TO STHITAPRAJNA',
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

              // Destination Selection Chips
              Text('SELECT DESTINATION', style: AppTextStyles.labelBadge.copyWith(fontSize: 9)),
              const SizedBox(height: 8),
              Row(
                children: ShareDestination.values.map((dest) {
                  final isSelected = _selectedDestination == dest;
                  final color = dest.accentColor;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () {
                          HapticService.selectionClick();
                          setState(() => _selectedDestination = dest);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                            border: Border.all(
                              color: isSelected ? color : AppColors.borderSubtle,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(dest.iconData, size: 16, color: isSelected ? color : AppColors.textMuted),
                              const SizedBox(height: 4),
                              Text(
                                dest.badgeLabel,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? color : AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Shared Content Preview Field
              Text('SHARED CONTENT / URL', style: AppTextStyles.labelBadge.copyWith(fontSize: 9)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contentController,
                maxLines: 2,
                style: AppTextStyles.bodySmall.copyWith(fontFamily: 'monospace', fontSize: 11),
                decoration: InputDecoration(
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
                  contentPadding: const EdgeInsets.all(10),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Shared content is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Title Field
              Text('RESOURCE / ANCHOR TITLE', style: AppTextStyles.labelBadge.copyWith(fontSize: 9)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Enter a descriptive title...',
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

              // Dynamic Category / Sub-tag Selector based on Destination
              if (_selectedDestination == ShareDestination.cognitionVault) ...[
                Text('COGNITION CATEGORY CLUSTER', style: AppTextStyles.labelBadge.copyWith(fontSize: 9)),
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
                      value: _cognitionCategory,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceElevated,
                      style: AppTextStyles.bodyMedium,
                      items: _cognitionCategories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat, style: const TextStyle(fontSize: 12.5)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _cognitionCategory = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ] else if (_selectedDestination == ShareDestination.joyReservoir) ...[
                Text('JOY RESERVOIR ANCHOR TYPE', style: AppTextStyles.labelBadge.copyWith(fontSize: 9)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: JoyCategory.values.map((cat) {
                    final isSel = _joyCategory == cat;
                    final color = cat.accentColor;
                    return ChoiceChip(
                      avatar: Icon(cat.iconData, size: 12, color: isSel ? color : AppColors.textMuted),
                      label: Text(cat.badgeLabel),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) {
                          HapticService.selectionClick();
                          setState(() => _joyCategory = cat);
                        }
                      },
                      selectedColor: color.withValues(alpha: 0.15),
                      backgroundColor: AppColors.surfaceElevated,
                      side: BorderSide(color: isSel ? color : AppColors.borderSubtle),
                      labelStyle: TextStyle(
                        fontSize: 9.5,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel ? color : AppColors.textSecondary,
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ] else ...[
                Text('RECOVERY SITUATIONAL TAG', style: AppTextStyles.labelBadge.copyWith(fontSize: 9)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _recoveryTags.map((tag) {
                    final isSel = _recoveryTag == tag;
                    return ChoiceChip(
                      label: Text(tag),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) {
                          HapticService.selectionClick();
                          setState(() => _recoveryTag = tag);
                        }
                      },
                      selectedColor: destColor.withValues(alpha: 0.15),
                      backgroundColor: AppColors.surfaceElevated,
                      side: BorderSide(color: isSel ? destColor : AppColors.borderSubtle),
                      labelStyle: TextStyle(
                        fontSize: 9.5,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel ? destColor : AppColors.textSecondary,
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Comment Note: "Why I am saving this / Personal Note"
              Text(
                'WHY I AM SAVING THIS / PERSONAL CONTEXT (COMMENT FIELD)',
                style: AppTextStyles.labelBadge.copyWith(fontSize: 9),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                style: AppTextStyles.bodySmall,
                decoration: InputDecoration(
                  hintText: _selectedDestination == ShareDestination.cognitionVault
                      ? 'e.g., Key mental model for countering boardroom gaslighting...'
                      : _selectedDestination == ShareDestination.joyReservoir
                          ? 'e.g., Listen when acute panic spikes; immediate heartbeat reset...'
                          : 'e.g., De-escalation script to use when a toxic manager shifts blame...',
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
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: Text('SAVE TO ${_selectedDestination.badgeLabel}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: destColor,
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
