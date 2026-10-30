import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/joy_item.dart';
import '../../data/services/joy_audio_service.dart';
import '../widgets/add_joy_item_modal_sheet.dart';
import '../widgets/joy_item_card.dart';

/// JoyReservoirScreen houses the user's Soul Sanctuary (आनंद कोष):
/// Personal music, local offline audio anchors, visual memories,
/// favorite reads, and grounding milestones.
class JoyReservoirScreen extends StatefulWidget {
  final bool isEmbedded;
  final JoyCategory? initialCategory;
  final String? initialTitle;
  final String? initialUrlOrPath;

  const JoyReservoirScreen({
    super.key,
    this.isEmbedded = false,
    this.initialCategory,
    this.initialTitle,
    this.initialUrlOrPath,
  });

  static Future<void> open(
    BuildContext context, {
    JoyCategory? initialCategory,
    String? initialTitle,
    String? initialUrlOrPath,
  }) {
    HapticService.selectionClick();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => JoyReservoirScreen(
          isEmbedded: false,
          initialCategory: initialCategory,
          initialTitle: initialTitle,
          initialUrlOrPath: initialUrlOrPath,
        ),
      ),
    );
  }

  @override
  State<JoyReservoirScreen> createState() => _JoyReservoirScreenState();
}

class _JoyReservoirScreenState extends State<JoyReservoirScreen> {
  final HiveStorage _storage = HiveStorage();
  List<JoyItem> _items = [];
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadItems();

    if (widget.initialTitle != null || widget.initialUrlOrPath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openAddSheet(
          category: widget.initialCategory ?? JoyCategory.music,
          title: widget.initialTitle,
          urlOrPath: widget.initialUrlOrPath,
        );
      });
    }
  }

  void _loadItems() {
    setState(() {
      _items = _storage.getAllJoyItems();
    });
  }

  void _openAddSheet({
    JoyCategory? category,
    String? title,
    String? urlOrPath,
  }) {
    HapticService.selectionClick();
    AddJoyItemModalSheet.show(
      context,
      initialCategory: category,
      initialTitle: title,
      initialUrlOrPath: urlOrPath,
      onSaved: _loadItems,
    );
  }

  Future<void> _deleteItem(String id) async {
    HapticService.mediumImpact();
    if (JoyAudioService().isActive(id)) {
      await JoyAudioService().stop();
    }
    await _storage.deleteJoyItem(id);
    _loadItems();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.anchorRemovedNotice,
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        setState(() {
          _selectedFilter = filterKey;
        });
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

  @override
  Widget build(BuildContext context) {
    var displayList = _items;
    if (_selectedFilter != 'all') {
      displayList = displayList.where((item) {
        return item.category.toStorageString().toLowerCase() ==
            _selectedFilter.toLowerCase();
      }).toList();
    }

    final musicCount =
        _items.where((i) => i.category == JoyCategory.music).length;
    final visualCount =
        _items.where((i) => i.category == JoyCategory.visual).length;
    final quoteCount =
        _items.where((i) => i.category == JoyCategory.quote).length;
    final memoryCount =
        _items.where((i) => i.category == JoyCategory.memory).length;

    final content = ListView(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isEmbedded ? 0 : AppDimens.space16,
        vertical: widget.isEmbedded ? 0 : AppDimens.space16,
      ),
      children: [
        if (!widget.isEmbedded) ...[
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
                      fontSize: 9.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.loc.joyReservoirTitle.toUpperCase(),
                    style: AppTextStyles.displayMedium,
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _openAddSheet(category: JoyCategory.music),
                    icon: const Icon(
                      Icons.audio_file_rounded,
                      color: AppColors.shieldPrimary,
                      size: 22,
                    ),
                    tooltip: context.loc.selectLocalAudio,
                  ),
                  IconButton(
                    onPressed: () => _openAddSheet(),
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.shieldPrimary,
                      size: 24,
                    ),
                    tooltip: context.loc.addJoyAnchor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            context.loc.joyReservoirDesc,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('all', '${context.loc.allAnchors} (${_items.length})'),
              const SizedBox(width: 6),
              _buildFilterChip('music', '${context.loc.musicCategory} ($musicCount)'),
              const SizedBox(width: 6),
              _buildFilterChip('visual', '${context.loc.visualCategory} ($visualCount)'),
              const SizedBox(width: 6),
              _buildFilterChip('quote', '${context.loc.quoteCategory} ($quoteCount)'),
              const SizedBox(width: 6),
              _buildFilterChip('memory', '${context.loc.memoryCategory} ($memoryCount)'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Quick Add Banner with Local Audio Option
        Container(
          padding: const EdgeInsets.all(AppDimens.space12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    size: 18,
                    color: Color(0xFFF43F5E),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.loc.quickAddBannerText,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _openAddSheet(category: JoyCategory.music),
                    icon: const Icon(Icons.audio_file_rounded, size: 14),
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
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _openAddSheet(),
                    icon: const Icon(Icons.add_rounded, size: 14),
                    label: Text(
                      context.loc.addButton,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.shieldPrimary,
                      foregroundColor: AppColors.background,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Items List
        if (displayList.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.spa_rounded,
                  size: 36,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 10),
                Text(
                  context.loc.noAnchorsInCategory,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.loc.tapAddPrompt,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final joy = displayList[index];
              return JoyItemCard(
                item: joy,
                onDelete: () => _deleteItem(joy.id),
              );
            },
          ),

        const SizedBox(height: 40),
      ],
    );

    if (widget.isEmbedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.loc.joyReservoirTitle.toUpperCase(),
          style: AppTextStyles.heading.copyWith(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.audio_file_rounded, color: AppColors.shieldPrimary),
            onPressed: () => _openAddSheet(category: JoyCategory.music),
            tooltip: context.loc.selectLocalAudio,
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.shieldPrimary),
            onPressed: () => _openAddSheet(),
            tooltip: context.loc.addJoyAnchor,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(),
        backgroundColor: AppColors.shieldPrimary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.favorite_rounded, size: 20),
        label: Text(
          context.loc.addJoyAnchor.toUpperCase(),
          style: AppTextStyles.labelBadge.copyWith(
            color: AppColors.background,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
      body: SafeArea(child: content),
    );
  }
}
