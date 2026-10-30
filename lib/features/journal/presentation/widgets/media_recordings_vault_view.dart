import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/media_record_log.dart';
import '../../data/services/media_vault_service.dart';
import 'rename_media_dialog.dart';
import 'stealth_pin_dialog.dart';

/// MediaRecordingsVaultView renders the unified media journal and stealth vault.
/// Features file renaming, .nomedia storage isolation, and discreet stealth unlocking.
class MediaRecordingsVaultView extends StatefulWidget {
  final VoidCallback? onMediaChanged;

  const MediaRecordingsVaultView({super.key, this.onMediaChanged});

  @override
  State<MediaRecordingsVaultView> createState() => _MediaRecordingsVaultViewState();
}

class _MediaRecordingsVaultViewState extends State<MediaRecordingsVaultView> {
  final MediaVaultService _vaultService = MediaVaultService();
  bool _isStealthUnlocked = false;
  String _selectedFilter = 'all'; // 'all', 'audio', 'video', 'hidden'
  final TextEditingController _searchController = TextEditingController();
  List<MediaRecordLog> _mediaList = [];

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMedia() {
    final list = _vaultService.getAllMedia(includeHidden: _isStealthUnlocked);
    setState(() {
      _mediaList = list;
    });
  }

  void _toggleStealthUnlock() async {
    if (_isStealthUnlocked) {
      HapticService.selectionClick();
      setState(() {
        _isStealthUnlocked = false;
        if (_selectedFilter == 'hidden') _selectedFilter = 'all';
      });
      _loadMedia();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Stealth Vault locked. Hidden files concealed.',
            style: TextStyle(fontSize: 12),
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final unlocked = await StealthPinDialog.show(context);
    if (unlocked == true && mounted) {
      setState(() {
        _isStealthUnlocked = true;
      });
      _loadMedia();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.lock_open_rounded, color: AppColors.emeraldSuccess, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Stealth Vault unlocked. Isolated files revealed.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// Bypass toggle via 800ms long press on the stealth shield icon
  void _onShieldLongPress() {
    HapticService.heavyImpact();
    setState(() {
      _isStealthUnlocked = !_isStealthUnlocked;
      if (!_isStealthUnlocked && _selectedFilter == 'hidden') {
        _selectedFilter = 'all';
      }
    });
    _loadMedia();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isStealthUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
              color: _isStealthUnlocked ? AppColors.emeraldSuccess : AppColors.amberWarning,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _isStealthUnlocked
                    ? 'Stealth Vault Discretion Override Unlocked.'
                    : 'Stealth Vault Concealed & Locked.',
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

  Future<void> _handleRename(MediaRecordLog record) async {
    HapticService.selectionClick();
    final updated = await RenameMediaDialog.show(context, record: record);
    if (updated != null) {
      _loadMedia();
      widget.onMediaChanged?.call();
    }
  }

  Future<void> _handleToggleHide(MediaRecordLog record) async {
    HapticService.heavyImpact();
    try {
      if (record.isHidden) {
        await _vaultService.unhideMedia(record.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${record.displayName}" restored to regular journal list.'),
              backgroundColor: AppColors.surfaceElevated,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        await _vaultService.hideMedia(record.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Moved "${record.displayName}" to .hidden_vault (.nomedia protected).',
              ),
              backgroundColor: AppColors.surfaceElevated,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
      _loadMedia();
      widget.onMediaChanged?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action failed: $e'),
            backgroundColor: AppColors.roseDanger,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(MediaRecordLog record) async {
    HapticService.selectionClick();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          side: const BorderSide(color: AppColors.borderMedium),
        ),
        title: Text(context.loc.deleteRecordingTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        content: Text(
          'Permanently deletes "${record.displayName}" from local storage. This action cannot be reversed.',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.loc.cancel, style: const TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.roseDanger,
              foregroundColor: Colors.white,
            ),
            child: Text(context.loc.deleteAction),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _vaultService.deleteMedia(record.id);
      _loadMedia();
      widget.onMediaChanged?.call();
    }
  }

  Future<void> _openFileLocally(MediaRecordLog record) async {
    HapticService.lightImpact();
    try {
      final file = File(record.filePath);
      if (await file.exists()) {
        final uri = Uri.file(record.filePath);
        final canLaunch = await canLaunchUrl(uri);
        if (canLaunch) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showFileDetailModal(record);
        }
      } else {
        _showFileDetailModal(record);
      }
    } catch (_) {
      _showFileDetailModal(record);
    }
  }

  void _showFileDetailModal(MediaRecordLog record) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLarge)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppDimens.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Row(
              children: [
                Icon(
                  record.isAudio ? Icons.mic_rounded : Icons.videocam_rounded,
                  color: AppColors.shieldPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    record.displayName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Storage Path: ${record.filePath}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 6),
            Text('Created: ${DateFormat('dd MMM yyyy, HH:mm').format(record.createdAt)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text('Status: ${record.isHidden ? "Hidden (.nomedia isolated)" : "Normal storage"}', style: TextStyle(fontSize: 11, color: record.isHidden ? AppColors.amberWarning : AppColors.emeraldSuccess)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null || bytes <= 0) return 'Local file';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    // Filter list
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _mediaList.where((item) {
      if (_selectedFilter == 'audio' && !item.isAudio) return false;
      if (_selectedFilter == 'video' && !item.isVideo) return false;
      if (_selectedFilter == 'hidden' && !item.isHidden) return false;
      if (query.isNotEmpty) {
        return item.displayName.toLowerCase().contains(query) ||
            item.originalFileName.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    final hiddenCount = _vaultService.getHiddenMedia().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Security Banner & Stealth Controls
        Container(
          padding: const EdgeInsets.all(AppDimens.space14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            border: Border.all(
              color: _isStealthUnlocked
                  ? AppColors.emeraldSuccess.withValues(alpha: 0.4)
                  : AppColors.borderSubtle,
            ),
          ),
          child: Row(
            children: [
              // Discreet Shield with Tap & Long-Press
              GestureDetector(
                onTap: _toggleStealthUnlock,
                onLongPress: _onShieldLongPress,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isStealthUnlocked
                        ? AppColors.emeraldSuccess.withValues(alpha: 0.15)
                        : AppColors.surfaceElevated,
                    border: Border.all(
                      color: _isStealthUnlocked
                          ? AppColors.emeraldSuccess
                          : AppColors.shieldPrimary,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _isStealthUnlocked ? Icons.lock_open_rounded : Icons.shield_rounded,
                    color: _isStealthUnlocked ? AppColors.emeraldSuccess : AppColors.shieldPrimary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _isStealthUnlocked ? 'STEALTH VAULT UNLOCKED' : 'ISOLATED MEDIA VAULT',
                          style: AppTextStyles.labelBadge.copyWith(
                            color: _isStealthUnlocked ? AppColors.emeraldSuccess : AppColors.shieldPrimary,
                            fontSize: 9.5,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (hiddenCount > 0 && !_isStealthUnlocked) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.amberWarning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '$hiddenCount HIDDEN',
                              style: const TextStyle(
                                fontSize: 8.5,
                                color: AppColors.amberWarning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isStealthUnlocked
                          ? 'Showing .nomedia isolated files. Tap shield to lock.'
                          : 'Hidden files are isolated from Gallery. Long-press shield or tap to enter PIN.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: _toggleStealthUnlock,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _isStealthUnlocked ? AppColors.emeraldSuccess : AppColors.textPrimary,
                  side: BorderSide(
                    color: _isStealthUnlocked ? AppColors.emeraldSuccess : AppColors.borderMedium,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  _isStealthUnlocked ? 'LOCK' : 'UNLOCK',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Search Bar
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Search recording title or date...',
            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 16),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('all', 'ALL (${_mediaList.length})'),
              const SizedBox(width: 6),
              _buildFilterChip('audio', 'AUDIO MEMOS (${_mediaList.where((m) => m.isAudio).length})'),
              const SizedBox(width: 6),
              _buildFilterChip('video', 'VIDEO COMPOSURE (${_mediaList.where((m) => m.isVideo).length})'),
              if (_isStealthUnlocked) ...[
                const SizedBox(width: 6),
                _buildFilterChip('hidden', 'STEALTH VAULT ($hiddenCount 🔒)'),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Media List
        if (filtered.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                Icon(
                  _selectedFilter == 'hidden' ? Icons.lock_outline_rounded : Icons.folder_open_rounded,
                  size: 32,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 10),
                Text(
                  _selectedFilter == 'hidden'
                      ? 'No stealth recordings hidden.'
                      : (query.isNotEmpty ? 'No recordings match "$query".' : 'No media recordings logged yet.'),
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedFilter == 'hidden'
                      ? 'Use "Hide File" from any recording menu to isolate it in .hidden_vault.'
                      : 'Capture audio memos or video composure reviews in the evening debrief.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = filtered[index];
              return _buildMediaItemCard(record);
            },
          ),
      ],
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    final isHiddenFilter = filterKey == 'hidden';

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          HapticService.selectionClick();
          setState(() => _selectedFilter = filterKey);
        }
      },
      selectedColor: isHiddenFilter
          ? AppColors.amberWarning.withValues(alpha: 0.2)
          : AppColors.surfaceElevated,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected
            ? (isHiddenFilter ? AppColors.amberWarning : AppColors.shieldPrimary)
            : AppColors.borderSubtle,
      ),
      labelStyle: TextStyle(
        fontSize: 10.5,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
        color: isSelected
            ? (isHiddenFilter ? AppColors.amberWarning : AppColors.shieldPrimary)
            : AppColors.textSecondary,
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildMediaItemCard(MediaRecordLog record) {
    final dateStr = DateFormat('dd MMM yyyy • HH:mm').format(record.createdAt);
    final sizeStr = _formatFileSize(record.fileSizeBytes);

    return InkWell(
      onTap: () => _openFileLocally(record),
      borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          border: Border.all(
            color: record.isHidden
                ? AppColors.amberWarning.withValues(alpha: 0.35)
                : AppColors.borderSubtle,
          ),
        ),
        child: Row(
          children: [
            // Media Type Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: record.isHidden
                    ? AppColors.amberWarning.withValues(alpha: 0.15)
                    : (record.isAudio
                        ? AppColors.emeraldSuccess.withValues(alpha: 0.15)
                        : AppColors.shieldPrimary.withValues(alpha: 0.15)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                record.isAudio ? Icons.mic_rounded : Icons.videocam_rounded,
                size: 20,
                color: record.isHidden
                    ? AppColors.amberWarning
                    : (record.isAudio ? AppColors.emeraldSuccess : AppColors.shieldPrimary),
              ),
            ),
            const SizedBox(width: 12),

            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          record.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (record.isHidden)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.amberWarning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.visibility_off_rounded, size: 9, color: AppColors.amberWarning),
                              SizedBox(width: 3),
                              Text(
                                '.NOMEDIA',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: AppColors.amberWarning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        record.isAudio ? 'AUDIO • M4A' : 'VIDEO • MP4',
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 8.5,
                          color: AppColors.shieldPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• $sizeStr',
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Contextual Three-Dots Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textMuted),
              color: AppColors.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
              onSelected: (action) {
                switch (action) {
                  case 'rename':
                    _handleRename(record);
                    break;
                  case 'hide':
                    _handleToggleHide(record);
                    break;
                  case 'delete':
                    _handleDelete(record);
                    break;
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 16, color: AppColors.shieldPrimary),
                      const SizedBox(width: 10),
                      Text(context.loc.renameToolAction, style: const TextStyle(fontSize: 12.5)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'hide',
                  child: Row(
                    children: [
                      Icon(
                        record.isHidden ? Icons.visibility_rounded : Icons.visibility_off_outlined,
                        size: 16,
                        color: AppColors.amberWarning,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        record.isHidden ? 'Unhide File' : 'Hide in Stealth Vault',
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.roseDanger),
                      const SizedBox(width: 10),
                      Text(context.loc.deleteAction, style: const TextStyle(fontSize: 12.5, color: AppColors.roseDanger)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
