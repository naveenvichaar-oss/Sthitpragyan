import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/character_trait_entry.dart';
import '../widgets/add_character_entry_modal_sheet.dart';
import '../widgets/character_card.dart';

/// CharacterLedgerScreen provides a dedicated, structured virtue & trait journal
/// focused strictly on building magnetic, dignified personal traits and gravitas.
class CharacterLedgerScreen extends StatefulWidget {
  final CharacterTraitCategory? initialCategory;

  const CharacterLedgerScreen({
    super.key,
    this.initialCategory,
  });

  static void open(BuildContext context, {CharacterTraitCategory? initialCategory}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CharacterLedgerScreen(initialCategory: initialCategory),
      ),
    );
  }

  @override
  State<CharacterLedgerScreen> createState() => _CharacterLedgerScreenState();
}

class _CharacterLedgerScreenState extends State<CharacterLedgerScreen> {
  final HiveStorage _storage = HiveStorage();
  List<CharacterTraitEntry> _allEntries = [];
  List<CharacterTraitEntry> _filteredEntries = [];

  CharacterTraitCategory? _selectedCategoryFilter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategoryFilter = widget.initialCategory;
    _searchController.addListener(_applyFilters);
    _loadEntries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadEntries() {
    setState(() {
      _allEntries = _storage.getAllCharacterTraits();
      _applyFilters();
    });
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredEntries = _allEntries.where((entry) {
        // Category filter
        if (_selectedCategoryFilter != null && entry.category != _selectedCategoryFilter) {
          return false;
        }
        // Search query filter
        if (query.isNotEmpty) {
          final matchesTitle = entry.title.toLowerCase().contains(query);
          final matchesSituation = entry.situation.toLowerCase().contains(query);
          final matchesObservation = entry.behaviorObservation.toLowerCase().contains(query);
          final matchesReflection = entry.reflection?.toLowerCase().contains(query) ?? false;
          final matchesTags = entry.tags.any((t) => t.toLowerCase().contains(query));
          return matchesTitle || matchesSituation || matchesObservation || matchesReflection || matchesTags;
        }
        return true;
      }).toList();
    });
  }

  void _openAddModal([CharacterTraitCategory? category]) {
    HapticService.selectionClick();
    AddCharacterEntryModalSheet.show(
      context,
      initialCategory: category ?? _selectedCategoryFilter,
      onSaved: _loadEntries,
    );
  }

  void _deleteEntry(CharacterTraitEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(context.loc.deleteTraitTitle, style: AppTextStyles.heading),
        content: Text(
          context.loc.deleteTraitRecordConfirm(entry.title),
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.loc.cancelButton, style: const TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.roseDanger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.loc.deleteButton, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      HapticService.selectionClick();
      await _storage.deleteCharacterTrait(entry.id);
      _loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    final magnanimityCount = _allEntries.where((e) => e.category == CharacterTraitCategory.magnanimity).length;
    final gravitasCount = _allEntries.where((e) => e.category == CharacterTraitCategory.gravitas).length;
    final joyCount = _allEntries.where((e) => e.category == CharacterTraitCategory.joy).length;
    final restraintCount = _allEntries.where((e) => e.category == CharacterTraitCategory.restraint).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.loc.sovereignTraitsBadge,
              style: AppTextStyles.labelBadge.copyWith(
                color: const Color(0xFFF59E0B),
                fontSize: 9.5,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              context.loc.characterLedgerTitle,
              style: AppTextStyles.heading,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.shieldPrimary),
            tooltip: context.loc.recordTraitAction,
            onPressed: () => _openAddModal(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.shieldPrimary,
        foregroundColor: Colors.black,
        elevation: 2,
        icon: const Icon(Icons.edit_note_rounded, size: 20),
        label: Text(
          context.loc.recordTraitAction.toUpperCase(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8),
        ),
        onPressed: () => _openAddModal(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.space16),
        children: [
          // 1. Virtue Distribution Metric Cards (Interactive Category Filter)
          Container(
            padding: const EdgeInsets.all(AppDimens.space14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        if (_selectedCategoryFilter != null) {
                          HapticService.selectionClick();
                          setState(() {
                            _selectedCategoryFilter = null;
                            _applyFilters();
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.loc.totalVirtueRecords(_allEntries.length),
                              style: AppTextStyles.labelBadge.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 9.5,
                                letterSpacing: 1.1,
                              ),
                            ),
                            if (_selectedCategoryFilter != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppColors.shieldPrimary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.shieldPrimary.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  context.loc.allClearFilter,
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.shieldPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Text(
                      _selectedCategoryFilter != null
                          ? _selectedCategoryFilter!.localizedName(context.loc.isHindi).toUpperCase()
                          : context.loc.sovereignEquanimityBadge,
                      style: AppTextStyles.labelBadge.copyWith(
                        color: _selectedCategoryFilter != null
                            ? _selectedCategoryFilter!.accentColor
                            : const Color(0xFFF59E0B),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatPill(
                      category: CharacterTraitCategory.magnanimity,
                      devanagari: context.loc.virtueMagnanimity,
                      name: context.loc.virtueSubMagnanimity,
                      count: magnanimityCount,
                      color: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 6),
                    _buildStatPill(
                      category: CharacterTraitCategory.gravitas,
                      devanagari: context.loc.virtueGravitas,
                      name: context.loc.virtueSubGravitas,
                      count: gravitasCount,
                      color: const Color(0xFF38BDF8),
                    ),
                    const SizedBox(width: 6),
                    _buildStatPill(
                      category: CharacterTraitCategory.joy,
                      devanagari: context.loc.virtueJoy,
                      name: context.loc.virtueSubJoy,
                      count: joyCount,
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 6),
                    _buildStatPill(
                      category: CharacterTraitCategory.restraint,
                      devanagari: context.loc.virtueRestraint,
                      name: context.loc.virtueSubRestraint,
                      count: restraintCount,
                      color: const Color(0xFF818CF8),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Search Bar
          TextField(
            controller: _searchController,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: context.loc.searchCharacterLedgerHint,
              hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16, color: AppColors.textMuted),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceElevated,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4. Entries List or Empty State
          if (_filteredEntries.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppDimens.space32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.shield_outlined, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(context.loc.noCharacterRecordsFound, style: AppTextStyles.heading),
                  const SizedBox(height: 6),
                  Text(
                    context.loc.recordEverydayArenasSub,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.shieldPrimary,
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(context.loc.recordFirstTrait),
                    onPressed: () => _openAddModal(),
                  ),
                ],
              ),
            )
          else
            ..._filteredEntries.map(
              (entry) => CharacterCard(
                entry: entry,
                onDelete: () => _deleteEntry(entry),
              ),
            ),
          const SizedBox(height: 60), // Padding for FAB
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required CharacterTraitCategory category,
    required String devanagari,
    required String name,
    required int count,
    required Color color,
  }) {
    final isSelected = _selectedCategoryFilter == category;
    final isAnySelected = _selectedCategoryFilter != null;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticService.selectionClick();
            setState(() {
              if (_selectedCategoryFilter == category) {
                _selectedCategoryFilter = null; // Toggle off -> Show All
              } else {
                _selectedCategoryFilter = category; // Select
              }
              _applyFilters();
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.24)
                  : (isAnySelected
                      ? color.withValues(alpha: 0.04)
                      : color.withValues(alpha: 0.10)),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? color
                    : color.withValues(alpha: isAnySelected ? 0.15 : 0.35),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        devanagari,
                        style: TextStyle(
                          color: isSelected ? Colors.white : color,
                          fontSize: 9.0,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 3),
                      Icon(Icons.check_circle_rounded, size: 10, color: color),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: TextStyle(
                    color: isSelected ? color.withValues(alpha: 0.95) : AppColors.textMuted,
                    fontSize: 8.0,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
