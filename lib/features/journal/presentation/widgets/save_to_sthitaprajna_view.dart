import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../joy_reservoir/data/models/joy_item.dart';
import '../../../recovery/data/models/incident_slip_up_log.dart';
import '../../../sharing/presentation/widgets/incoming_share_modal_sheet.dart';
import '../../../wisdom/data/models/resource_link.dart';
import '../../data/models/reflection_entry.dart';

/// SaveToSthitaprajnaView implements the complete system share & resource ingestion
/// workflow directly inside Pillar 3 (संज्ञान / Cognition) authoring space.
/// Replaces the legacy Planning tab with universal multi-vault ingestion.
class SaveToSthitaprajnaView extends StatefulWidget {
  final VoidCallback? onSaved;

  const SaveToSthitaprajnaView({super.key, this.onSaved});

  @override
  State<SaveToSthitaprajnaView> createState() => _SaveToSthitaprajnaViewState();
}

class _SaveToSthitaprajnaViewState extends State<SaveToSthitaprajnaView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  ShareDestination _selectedDestination = ShareDestination.recoveryReference;

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

  // Training & Recovery sub-tags
  String _recoveryTag = 'De-Escalation';
  final List<String> _recoveryTags = [
    'De-Escalation',
    'Damage Control',
    'Emotional Detachment',
    'Boardroom Manipulation',
    'Boundary Enforcement',
    'Stoic Composure',
  ];

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _resetForm() {
    HapticService.selectionClick();
    setState(() {
      _contentController.clear();
      _titleController.clear();
      _noteController.clear();
      _selectedDestination = ShareDestination.recoveryReference;
      _recoveryTag = 'De-Escalation';
      _cognitionCategory = 'Gita & Sthitaprajna';
      _joyCategory = JoyCategory.music;
    });
  }

  Future<void> _pasteFromClipboard() async {
    HapticService.selectionClick();
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (text.isNotEmpty) {
        _contentController.text = text;
        _autoConfigureFromContent(text);
        if (_titleController.text.trim().isEmpty) {
          _titleController.text = _deriveInitialTitle(text);
        }
        setState(() {});
      }
    } catch (_) {}
  }

  void _autoConfigureFromContent(String content) {
    final detectedType = ResourceLink.detectMediaTypeFromUrl(content);
    _selectedMediaType = detectedType;

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
        lower.contains('manipulation') ||
        lower.contains('argument')) {
      _selectedDestination = ShareDestination.recoveryReference;
    }
  }

  String _deriveInitialTitle(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '';

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

    if (trimmed.length > 40) {
      return '${trimmed.substring(0, 40).trim()}...';
    }
    return trimmed;
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
          mediaUrlOrPath: content,
          note: note,
          timestamp: DateTime.now(),
        );
        await storage.saveJoyItem(joy);
        break;

      case ShareDestination.recoveryReference:
        final recoveryResource = ResourceLink(
          id: 'rec_ref_${DateTime.now().millisecondsSinceEpoch}',
          title: '[$_recoveryTag] $title',
          category: 'Training / अभ्यास',
          mediaType: ResourceLink.detectMediaTypeFromUrl(content),
          url: content,
          isUserAdded: true,
          notes: note != null
              ? 'Tactical Tag: $_recoveryTag\n\nIntent / Notes:\n$note'
              : 'Tactical Tag: $_recoveryTag',
          createdAt: DateTime.now(),
        );
        await storage.saveResourceLink(recoveryResource);

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

    // Also persist as a reflection entry for the timeline view in Pillar 3
    final reflection = ReflectionEntry(
      id: 'saved_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: '[$_destinationTitle] $content\n\nPersonal Context / Note:\n${note ?? "Saved directly to vault."}',
      category: ReflectionCategory.saveToVault,
      createdAt: DateTime.now(),
      tags: [_recoveryTag, _selectedDestination.name],
    );
    await storage.saveReflection(reflection);

    widget.onSaved?.call();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.emeraldSuccess, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Saved to ${_selectedDestination.displayName} & Reflection Timeline.',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: const Duration(seconds: 3),
        ),
      );
      _resetForm();
    }
  }

  String get _destinationTitle {
    switch (_selectedDestination) {
      case ShareDestination.recoveryReference:
        return 'RECOVERY REFERENCE';
      case ShareDestination.cognitionVault:
        return 'COGNITION VAULT';
      case ShareDestination.joyReservoir:
        return 'JOY BOX';
    }
  }

  @override
  Widget build(BuildContext context) {
    final destColor = _selectedDestination.accentColor;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.loc.systemShareInterceptorBadge,
                        style: AppTextStyles.labelBadge.copyWith(
                          color: AppColors.shieldPrimary,
                          letterSpacing: 1.5,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.loc.saveToSthitaprajna,
                        style: AppTextStyles.heading.copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.textMuted),
                  tooltip: context.loc.resetFormTooltip,
                  onPressed: _resetForm,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Select Destination
            Text(
              context.loc.selectDestinationBadge,
              style: AppTextStyles.labelBadge.copyWith(fontSize: 8.5),
            ),
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
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                dest.getBadgeLabel(context.loc.isHindi),
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? color : AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              ),
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

            // Shared Content / URL Field with Paste Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.loc.sharedContentUrlBadge,
                  style: AppTextStyles.labelBadge.copyWith(fontSize: 8.5),
                ),
                GestureDetector(
                  onTap: _pasteFromClipboard,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.content_paste_rounded, size: 12, color: AppColors.shieldPrimary),
                      const SizedBox(width: 4),
                      Text(
                        context.loc.pasteAction,
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 8.5,
                          color: AppColors.shieldPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _contentController,
              maxLines: 2,
              style: AppTextStyles.bodySmall.copyWith(fontFamily: 'monospace', fontSize: 11),
              onChanged: (text) {
                if (_titleController.text.trim().isEmpty) {
                  _titleController.text = _deriveInitialTitle(text);
                }
                _autoConfigureFromContent(text);
              },
              decoration: InputDecoration(
                hintText: 'https://youtube.com/... or text content',
                hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
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
                  return context.loc.contentOrLinkRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Resource / Anchor Title
            Text(
              context.loc.resourceAnchorTitleBadge,
              style: AppTextStyles.labelBadge.copyWith(fontSize: 8.5),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleController,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: context.loc.enterDescriptiveTitleHint,
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
                  return context.loc.titleRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Dynamic Category / Sub-tag Selector based on Destination
            if (_selectedDestination == ShareDestination.cognitionVault) ...[
              Text(
                context.loc.cognitionClusterBadge,
                style: AppTextStyles.labelBadge.copyWith(fontSize: 8.5),
              ),
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
              const SizedBox(height: 14),
            ] else if (_selectedDestination == ShareDestination.joyReservoir) ...[
              Text(
                context.loc.joyAnchorTypeBadge,
                style: AppTextStyles.labelBadge.copyWith(fontSize: 8.5),
              ),
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
              const SizedBox(height: 14),
            ] else ...[
              Text(
                context.loc.recoverySituationalTagBadge,
                style: AppTextStyles.labelBadge.copyWith(fontSize: 8.5),
              ),
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
              const SizedBox(height: 14),
            ],

            // Comment Note Field
            Text(
              context.loc.whySavingCommentBadge,
              style: AppTextStyles.labelBadge.copyWith(fontSize: 8.5),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              style: AppTextStyles.bodySmall,
              decoration: InputDecoration(
                hintText: _selectedDestination == ShareDestination.cognitionVault
                    ? 'e.g., Key mental model for overcoming friction or cognitive bias...'
                    : _selectedDestination == ShareDestination.joyReservoir
                        ? 'e.g., Listen when feeling overwhelmed; reset state...'
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
            const SizedBox(height: 18),

            // Save Action Button (Min 48dp touch target)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleSave,
                icon: const Icon(Icons.save_rounded, size: 18),
                label: Text(
                  context.loc.saveToDestinationButton(_selectedDestination.getBadgeLabel(context.loc.isHindi)),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: destColor,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
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
