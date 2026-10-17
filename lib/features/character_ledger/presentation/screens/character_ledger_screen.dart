import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
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
        title: const Text('Delete Trait Record?', style: AppTextStyles.heading),
        content: Text(
          'Are you sure you want to remove "${entry.title}" from your Character Ledger?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.roseDanger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
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
              'SOVEREIGN TRAITS • चरित्र कोष',
              style: AppTextStyles.labelBadge.copyWith(
                color: const Color(0xFFF59E0B),
                fontSize: 9.5,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'CHARACTER LEDGER',
              style: AppTextStyles.heading,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.shieldPrimary),
            tooltip: 'Record Character Trait',
            onPressed: () => _openAddModal(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.shieldPrimary,
        foregroundColor: Colors.black,
        elevation: 2,
        icon: const Icon(Icons.edit_note_rounded, size: 20),
        label: const Text(
          'RECORD TRAIT',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8),
        ),
        onPressed: () => _openAddModal(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.space16),
        children: [
          // 1. Virtue Distribution Metric Cards
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
                    Text(
                      'TOTAL VIRTUE RECORDS: ${_allEntries.length}',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 9.5,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'SOVEREIGN EQUANAMITY',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: const Color(0xFFF59E0B),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatPill('उदारता', 'Magnanimity', magnanimityCount, const Color(0xFFF59E0B)),
                    const SizedBox(width: 6),
                    _buildStatPill('गांभीर्य', 'Gravitas', gravitasCount, const Color(0xFF38BDF8)),
                    const SizedBox(width: 6),
                    _buildStatPill('प्रसन्नता', 'Joy', joyCount, const Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    _buildStatPill('संयम', 'Restraint', restraintCount, const Color(0xFF818CF8)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Search Bar
          TextField(
            controller: _searchController,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search situations, tags (#Silence), or reflections...',
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
          const SizedBox(height: 12),

          // 3. Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('ALL (${_allEntries.length})', null),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'उदारता • Magnanimity',
                  CharacterTraitCategory.magnanimity,
                  const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'गांभीर्य • Gravitas',
                  CharacterTraitCategory.gravitas,
                  const Color(0xFF38BDF8),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'प्रसन्नता • Joy',
                  CharacterTraitCategory.joy,
                  const Color(0xFF10B981),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'संयम • Restraint',
                  CharacterTraitCategory.restraint,
                  const Color(0xFF818CF8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Entries List or Empty State
          if (_filteredEntries.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppDimens.space32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.shield_outlined, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text('No Character Records Found', style: AppTextStyles.heading),
                  const SizedBox(height: 6),
                  Text(
                    'Record everyday arenas where you embodied composure, strategic silence, or big-hearted magnanimity.',
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
                    label: const Text('RECORD FIRST TRAIT'),
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

  Widget _buildStatPill(String devanagari, String name, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              devanagari,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$count',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              name,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 7.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, CharacterTraitCategory? category, [Color? color]) {
    final isSelected = _selectedCategoryFilter == category;
    final chipColor = color ?? AppColors.shieldPrimary;

    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: chipColor.withValues(alpha: 0.2),
      backgroundColor: AppColors.surfaceElevated,
      side: BorderSide(
        color: isSelected ? chipColor : AppColors.borderSubtle,
      ),
      labelStyle: TextStyle(
        fontSize: 10.5,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? chipColor : AppColors.textSecondary,
      ),
      onSelected: (val) {
        HapticService.selectionClick();
        setState(() {
          _selectedCategoryFilter = val ? category : null;
          _applyFilters();
        });
      },
    );
  }
}
