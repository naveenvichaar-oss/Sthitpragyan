import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/reflection_entry.dart';
import 'video_reflection_drill_modal.dart';

/// ReflectionTimelineView renders the dynamic history timeline for Pillar 3 (संज्ञान / Cognition).
/// Supports searching, category filters, date filters, audio playback, and video drills.
class ReflectionTimelineView extends StatefulWidget {
  final List<ReflectionEntry> entries;
  final Future<void> Function(String id) onDelete;
  final void Function(ReflectionEntry entry)? onEdit;

  const ReflectionTimelineView({
    super.key,
    required this.entries,
    required this.onDelete,
    this.onEdit,
  });

  @override
  State<ReflectionTimelineView> createState() => _ReflectionTimelineViewState();
}

class _ReflectionTimelineViewState extends State<ReflectionTimelineView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all'; // 'all', 'dailyReview', 'personalJournal', 'planning', 'selfTalk'
  String _selectedDateRange = 'all'; // 'all', 'today', 'week', 'month'

  AudioPlayer? _activeAudioPlayer;
  String? _currentlyPlayingPath;
  bool _isPlaying = false;

  @override
  void dispose() {
    _searchController.dispose();
    _activeAudioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio(String path) async {
    HapticService.selectionClick();
    if (_currentlyPlayingPath == path && _isPlaying) {
      await _activeAudioPlayer?.pause();
      setState(() => _isPlaying = false);
      return;
    }

    _activeAudioPlayer ??= AudioPlayer();
    _activeAudioPlayer!.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentlyPlayingPath = null;
        });
      }
    });

    await _activeAudioPlayer!.play(DeviceFileSource(path));
    setState(() {
      _currentlyPlayingPath = path;
      _isPlaying = true;
    });
  }

  void _openVideo(String path) async {
    HapticService.selectionClick();
    final file = File(path);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.loc.videoFileNotFound, style: const TextStyle(fontSize: 12)),
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
      return;
    }

    try {
      final uri = Uri.file(path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await VideoReflectionDrillModal.show(context, existingPath: path);
      }
    } catch (_) {
      await VideoReflectionDrillModal.show(context, existingPath: path);
    }
  }

  void _copyToClipboard(ReflectionEntry entry) {
    HapticService.selectionClick();
    final buffer = StringBuffer();
    if (entry.title.isNotEmpty) buffer.writeln(entry.title);
    buffer.writeln(entry.content);
    if (entry.distractionAvoided != null && entry.distractionAvoided!.isNotEmpty) {
      buffer.writeln('\nDistraction Avoided: ${entry.distractionAvoided}');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.loc.reflectionCopiedNotice, style: const TextStyle(fontSize: 12)),
        backgroundColor: AppColors.surfaceElevated,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<ReflectionEntry> _getFilteredEntries() {
    final query = _searchController.text.trim().toLowerCase();
    final now = DateTime.now();

    return widget.entries.where((entry) {
      // 1. Search query
      if (query.isNotEmpty && !entry.matchesQuery(query)) {
        return false;
      }

      // 2. Category filter
      if (_selectedCategory != 'all' && entry.category.name != _selectedCategory) {
        return false;
      }

      // 3. Date range filter
      if (_selectedDateRange == 'today') {
        if (entry.createdAt.year != now.year ||
            entry.createdAt.month != now.month ||
            entry.createdAt.day != now.day) {
          return false;
        }
      } else if (_selectedDateRange == 'week') {
        final diff = now.difference(entry.createdAt).inDays;
        if (diff > 7) return false;
      } else if (_selectedDateRange == 'month') {
        final diff = now.difference(entry.createdAt).inDays;
        if (diff > 30) return false;
      }

      return true;
    }).toList();
  }

  Color _getCategoryColor(ReflectionCategory category) {
    switch (category) {
      case ReflectionCategory.dailyReview:
        return AppColors.shieldPrimary;
      case ReflectionCategory.personalJournal:
        return const Color(0xFF38BDF8); // Sky blue
      case ReflectionCategory.planning:
        return const Color(0xFF10B981); // Emerald
      case ReflectionCategory.selfTalk:
        return const Color(0xFFA78BFA); // Purple
      case ReflectionCategory.inputOutput1to3:
        return const Color(0xFFF59E0B); // Amber
      case ReflectionCategory.saveToVault:
        return const Color(0xFFF59E0B); // Amber / Gold
    }
  }

  String _getCategoryLabel(ReflectionCategory category) {
    switch (category) {
      case ReflectionCategory.dailyReview:
        return context.loc.catDailyReview.toUpperCase();
      case ReflectionCategory.personalJournal:
        return context.loc.catPersonalJournal.toUpperCase();
      case ReflectionCategory.planning:
        return context.loc.catPlanning.toUpperCase();
      case ReflectionCategory.selfTalk:
        return context.loc.catSelfTalk.toUpperCase();
      case ReflectionCategory.inputOutput1to3:
        return context.loc.catInputOutput1to3.toUpperCase();
      case ReflectionCategory.saveToVault:
        return context.loc.catSaveToVault.toUpperCase();
    }
  }

  IconData _getCategoryIcon(ReflectionCategory category) {
    switch (category) {
      case ReflectionCategory.dailyReview:
        return Icons.rate_review_rounded;
      case ReflectionCategory.personalJournal:
        return Icons.auto_stories_rounded;
      case ReflectionCategory.planning:
        return Icons.alt_route_rounded;
      case ReflectionCategory.selfTalk:
        return Icons.record_voice_over_rounded;
      case ReflectionCategory.inputOutput1to3:
        return Icons.menu_book_rounded;
      case ReflectionCategory.saveToVault:
        return Icons.bookmark_add_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = context.loc.isHindi;
    final filtered = _getFilteredEntries();

    final dailyCount = widget.entries
        .where((e) => e.category == ReflectionCategory.dailyReview)
        .length;
    final journalCount = widget.entries
        .where((e) => e.category == ReflectionCategory.personalJournal)
        .length;
    final saveToVaultCount = widget.entries
        .where((e) => e.category == ReflectionCategory.saveToVault)
        .length;
    final planningCount = widget.entries
        .where((e) => e.category == ReflectionCategory.planning)
        .length;
    final selfTalkCount = widget.entries
        .where((e) => e.category == ReflectionCategory.selfTalk)
        .length;
    final inputOutputCount = widget.entries
        .where((e) => e.category == ReflectionCategory.inputOutput1to3)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Search Box
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: context.loc.searchReflectionsHint,
            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              borderSide: const BorderSide(color: AppColors.shieldPrimary),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 2. Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip('all', context.loc.categoryFilterAll(widget.entries.length)),
              const SizedBox(width: 6),
              _buildCategoryChip('saveToVault', context.loc.categoryFilterVault(saveToVaultCount)),
              const SizedBox(width: 6),
              _buildCategoryChip('inputOutput1to3', context.loc.categoryFilter1to3(inputOutputCount)),
              const SizedBox(width: 6),
              _buildCategoryChip('dailyReview', context.loc.categoryFilterDaily(dailyCount)),
              const SizedBox(width: 6),
              _buildCategoryChip('personalJournal', context.loc.categoryFilterJournal(journalCount)),
              if (planningCount > 0) ...[
                const SizedBox(width: 6),
                _buildCategoryChip('planning', context.loc.categoryFilterPlanning(planningCount)),
              ],
              if (selfTalkCount > 0) ...[
                const SizedBox(width: 6),
                _buildCategoryChip('selfTalk', context.loc.categoryFilterSelfTalk(selfTalkCount)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 3. Date Range Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildDateChip('all', context.loc.allTimeLabel),
              const SizedBox(width: 6),
              _buildDateChip('today', context.loc.todayLabel),
              const SizedBox(width: 6),
              _buildDateChip('week', context.loc.thisWeekLabel),
              const SizedBox(width: 6),
              _buildDateChip('month', context.loc.thisMonthLabel),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. Entries Count Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.loc.reflectionEntriesCount(filtered.length),
              style: AppTextStyles.labelBadge.copyWith(
                fontSize: 9.5,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              context.loc.offlineHiveBadge,
              style: AppTextStyles.labelBadge.copyWith(
                fontSize: 8.5,
                color: AppColors.emeraldSuccess,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 5. Entries List
        if (filtered.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.space32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                const Icon(Icons.auto_stories_outlined, size: 36, color: AppColors.textDisabled),
                const SizedBox(height: 10),
                Text(
                  context.loc.noReflectionsFound,
                  style: AppTextStyles.labelBadge.copyWith(letterSpacing: 1.5),
                ),
                const SizedBox(height: 4),
                Text(
                  context.loc.noReflectionsSub,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildEntryCard(filtered[index], isHindi);
            },
          ),
      ],
    );
  }

  Widget _buildCategoryChip(String catKey, String label) {
    final isSelected = _selectedCategory == catKey;
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        setState(() => _selectedCategory = catKey);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceElevated : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.shieldPrimary : AppColors.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelBadge.copyWith(
            fontSize: 9.0,
            color: isSelected ? AppColors.shieldPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip(String dateKey, String label) {
    final isSelected = _selectedDateRange == dateKey;
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        setState(() => _selectedDateRange = dateKey);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.borderMedium : AppColors.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTakeawayItem(int index, String? text, bool isHindi) {
    if (text == null || text.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 12.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(ReflectionEntry entry, bool isHindi) {
    final catColor = _getCategoryColor(entry.category);
    final catLabel = _getCategoryLabel(entry.category);
    final catIcon = _getCategoryIcon(entry.category);
    final formattedDate = DateFormat('dd MMM yyyy • hh:mm a').format(entry.createdAt);

    return Container(
      padding: const EdgeInsets.all(AppDimens.space14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Category Badge, Timestamp & More Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(catIcon, size: 14, color: catColor),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    catLabel,
                    style: AppTextStyles.labelBadge.copyWith(
                      color: catColor,
                      fontSize: 9.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    formattedDate,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textMuted),
                    padding: EdgeInsets.zero,
                    color: AppColors.surfaceElevated,
                    onSelected: (val) async {
                      if (val == 'edit') {
                        widget.onEdit?.call(entry);
                      } else if (val == 'copy') {
                        _copyToClipboard(entry);
                      } else if (val == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                              side: const BorderSide(color: AppColors.borderSubtle),
                            ),
                            title: Text(
                              context.loc.deleteReflectionTitle,
                              style: AppTextStyles.heading.copyWith(fontSize: 15),
                            ),
                            content: Text(
                              context.loc.deleteReflectionConfirm,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: Text(context.loc.cancelButton),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.roseDanger,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: Text(context.loc.deleteAction),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await widget.onDelete(entry.id);
                        }
                      }
                    },
                    itemBuilder: (ctx) => [
                      if (widget.onEdit != null)
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_outlined, size: 14, color: AppColors.shieldPrimary),
                              const SizedBox(width: 8),
                              Text(context.loc.editAction, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'copy',
                        child: Row(
                          children: [
                            const Icon(Icons.copy_rounded, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(context.loc.copyAction, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline_rounded, size: 14, color: AppColors.roseDanger),
                            const SizedBox(width: 8),
                            Text(context.loc.deleteAction, style: const TextStyle(fontSize: 12, color: AppColors.roseDanger)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Title
          if (entry.title.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              entry.title,
              style: AppTextStyles.heading.copyWith(fontSize: 14.5),
            ),
          ],

          if (entry.category == ReflectionCategory.inputOutput1to3) ...[
            if (entry.sourceTitle != null && entry.sourceTitle!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.menu_book_rounded, size: 12, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      context.loc.sourceLabel(entry.sourceTitle!),
                      style: const TextStyle(fontSize: 10, color: Color(0xFFF59E0B), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
            if (entry.takeaway1 != null || entry.takeaway2 != null || entry.takeaway3 != null) ...[
              const SizedBox(height: 6),
              _buildTakeawayItem(1, entry.takeaway1, isHindi),
              _buildTakeawayItem(2, entry.takeaway2, isHindi),
              _buildTakeawayItem(3, entry.takeaway3, isHindi),
            ],
            if (entry.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.bolt_rounded, size: 12, color: Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  Text(
                    context.loc.practicalApplicationLabel,
                    style: AppTextStyles.labelBadge.copyWith(fontSize: 9.0, color: const Color(0xFF10B981)),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                entry.content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
            ],
          ] else ...[
            // Content
            const SizedBox(height: 6),
            Text(
              entry.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
                fontSize: 13,
              ),
            ),
          ],

          // Daily Review Specific Metrics (Reaction Score & Boundary)
          if (entry.category == ReflectionCategory.dailyReview) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (entry.reactionScore != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_outlined, size: 12, color: AppColors.shieldPrimary),
                        const SizedBox(width: 5),
                        Text(
                          context.loc.composureScoreBadge(entry.reactionScore!),
                          style: AppTextStyles.labelBadge.copyWith(
                            color: AppColors.shieldPrimary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (entry.boundaryMaintained != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (entry.boundaryMaintained!
                              ? AppColors.emeraldSuccess
                              : AppColors.roseDanger)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: (entry.boundaryMaintained!
                                ? AppColors.emeraldSuccess
                                : AppColors.roseDanger)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          entry.boundaryMaintained!
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 12,
                          color: entry.boundaryMaintained!
                              ? AppColors.emeraldSuccess
                              : AppColors.roseDanger,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          entry.boundaryMaintained!
                              ? context.loc.boundaryHeld
                              : context.loc.boundaryCompromised,
                          style: AppTextStyles.labelBadge.copyWith(
                            color: entry.boundaryMaintained!
                                ? AppColors.emeraldSuccess
                                : AppColors.roseDanger,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (entry.distractionAvoided != null && entry.distractionAvoided!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 14, color: AppColors.amberWarning),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${context.loc.distractionControlLabel}: ${entry.distractionAvoided}',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],

          // Multimodal Media Attachments (Audio & Video)
          if (entry.audioMemoPath != null || entry.videoReflectionPath != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (entry.audioMemoPath != null) ...[
                  Expanded(
                    child: InkWell(
                      onTap: () => _toggleAudio(entry.audioMemoPath!),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: (_currentlyPlayingPath == entry.audioMemoPath && _isPlaying)
                              ? AppColors.emeraldSuccess.withValues(alpha: 0.15)
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: (_currentlyPlayingPath == entry.audioMemoPath && _isPlaying)
                                ? AppColors.emeraldSuccess
                                : AppColors.borderSubtle,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              (_currentlyPlayingPath == entry.audioMemoPath && _isPlaying)
                                  ? Icons.pause_circle_rounded
                                  : Icons.play_circle_fill_rounded,
                              size: 16,
                              color: (_currentlyPlayingPath == entry.audioMemoPath && _isPlaying)
                                  ? AppColors.emeraldSuccess
                                  : AppColors.shieldPrimary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                (_currentlyPlayingPath == entry.audioMemoPath && _isPlaying)
                                    ? context.loc.audioPlayingLabel
                                    : context.loc.audioMemoLabel,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: (_currentlyPlayingPath == entry.audioMemoPath && _isPlaying)
                                      ? AppColors.emeraldSuccess
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (entry.videoReflectionPath != null) const SizedBox(width: 8),
                ],
                if (entry.videoReflectionPath != null) ...[
                  Expanded(
                    child: InkWell(
                      onTap: () => _openVideo(entry.videoReflectionPath!),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.videocam_rounded,
                              size: 16,
                              color: AppColors.shieldPrimary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                context.loc.videoDrillLabel,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
