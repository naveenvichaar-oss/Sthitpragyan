import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../joy_reservoir/presentation/screens/joy_reservoir_screen.dart';
import '../../../joy_reservoir/presentation/widgets/add_joy_item_modal_sheet.dart';
import '../../../wisdom/data/models/resource_link.dart';
import '../../../wisdom/data/models/wisdom_entry.dart';
import '../../../wisdom/data/services/wisdom_vault_service.dart';
import '../../../wisdom/presentation/widgets/add_resource_modal_sheet.dart';
import '../../../wisdom/presentation/widgets/resource_hub_card.dart';
import '../../../wisdom/presentation/widgets/wisdom_card.dart';
import '../../data/cognition_data_source.dart';
import '../../data/models/fallacy_and_model.dart';
import '../../data/models/local_html_tool.dart';
import '../widgets/cognition_search_bar.dart';
import '../widgets/expandable_micro_card.dart';
import '../widgets/html_tool_card.dart';
import '../widgets/import_html_tool_modal_sheet.dart';

/// CognitionVaultScreen hosts the unified Wisdom Vault & Resource Sanctuary:
/// 1. Wisdom Cards: Gita & Sthitaprajna, Western Stoicism, Behavioral Psychology.
/// 2. Resource Hub: Pre-seeded public-domain classics + personal Drive/Keep/YouTube links.
/// 3. Mental Models: Logical fallacies and cognitive defense mechanisms.
class CognitionVaultScreen extends StatefulWidget {
  final int initialSegment;

  const CognitionVaultScreen({
    super.key,
    this.initialSegment = 0,
  });

  @override
  State<CognitionVaultScreen> createState() => _CognitionVaultScreenState();
}

class _CognitionVaultScreenState extends State<CognitionVaultScreen> {
  final HiveStorage _storage = HiveStorage();
  final WisdomVaultService _wisdomService = WisdomVaultService();

  // Top Segment Control: 0 = Wisdom Cards, 1 = Resource Hub, 2 = Mental Models
  int _selectedMainSegment = 0;

  // Search controllers
  final TextEditingController _wisdomSearchController = TextEditingController();
  final TextEditingController _modelSearchController = TextEditingController();

  // Wisdom Tab State
  String _selectedWisdomCategory = 'all';
  List<WisdomEntry> _filteredWisdom = [];
  String? _activeAffirmationId;

  // Resource Hub State
  List<ResourceLink> _resources = [];
  String _selectedResourceFilter = 'all';

  // Mental Models Tab State
  int _selectedModelFilterIndex = 0; // 0: All, 1: Fallacies, 2: Stoic Models
  List<CognitionItem> _filteredModels = [];

  // Offline HTML Tools State
  List<LocalHtmlTool> _htmlTools = [];
  String _selectedHtmlCategoryFilter = 'all';

  @override
  void initState() {
    super.initState();
    _selectedMainSegment = widget.initialSegment;
    _loadAllData();
  }

  void _loadAllData() {
    // 1. Wisdom entries
    _applyWisdomFilters();
    _activeAffirmationId = _storage.getDailyAffirmationId();

    // 2. Resource links
    _loadResources();

    // 3. Mental models
    _applyModelFilters();

    // 4. Offline HTML Tools
    _loadHtmlTools();
  }

  void _loadHtmlTools() {
    setState(() {
      _htmlTools = _storage.getAllHtmlTools();
    });
  }

  void _openImportHtmlSheet() {
    HapticService.selectionClick();
    ImportHtmlToolModalSheet.show(
      context,
      onImported: (tool) {
        _loadHtmlTools();
      },
    );
  }

  void _loadResources() {
    setState(() {
      _resources = _storage.getAllResourceLinks();
    });
  }

  void _applyWisdomFilters() {
    final query = _wisdomSearchController.text.trim();
    setState(() {
      _filteredWisdom = _wisdomService.search(
        query,
        category: _selectedWisdomCategory,
      );
    });
  }

  void _applyModelFilters() {
    final query = _modelSearchController.text.trim();
    CognitionType? filterType;
    if (_selectedModelFilterIndex == 1) {
      filterType = CognitionType.rulesOfEngagement;
    } else if (_selectedModelFilterIndex == 2) {
      filterType = CognitionType.fallacy;
    } else if (_selectedModelFilterIndex == 3) {
      filterType = CognitionType.mentalModel;
    }

    setState(() {
      _filteredModels = CognitionDataSource.search(query, filterType);
    });
  }

  @override
  void dispose() {
    _wisdomSearchController.dispose();
    _modelSearchController.dispose();
    super.dispose();
  }

  void _openAddResourceSheet() {
    HapticService.selectionClick();
    AddResourceModalSheet.show(
      context,
      onSaved: () {
        _loadResources();
      },
    );
  }

  Future<void> _deleteResource(String id) async {
    HapticService.selectionClick();
    await _storage.deleteResourceLink(id);
    _loadResources();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resource removed from Sanctuary.', style: TextStyle(fontSize: 12)),
          backgroundColor: AppColors.surfaceElevated,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _selectedMainSegment == 1
          ? FloatingActionButton.extended(
              onPressed: _openAddResourceSheet,
              backgroundColor: AppColors.shieldPrimary,
              foregroundColor: AppColors.background,
              icon: const Icon(Icons.add_link_rounded, size: 20),
              label: Text(
                'ADD LINK',
                style: AppTextStyles.labelBadge.copyWith(
                  color: AppColors.background,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            )
          : _selectedMainSegment == 3
              ? FloatingActionButton.extended(
                  onPressed: () => AddJoyItemModalSheet.show(
                    context,
                    onSaved: () => setState(() {}),
                  ),
                  backgroundColor: AppColors.shieldPrimary,
                  foregroundColor: AppColors.background,
                  icon: const Icon(Icons.favorite_rounded, size: 20),
                  label: Text(
                    'ADD ANCHOR',
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.background,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                )
              : _selectedMainSegment == 4
                  ? FloatingActionButton.extended(
                      onPressed: _openImportHtmlSheet,
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.black,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text(
                        'IMPORT HTML',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    )
                  : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space16,
            vertical: AppDimens.space16,
          ),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INTELLECTUAL DEFENSE & SANCTUARY',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.shieldPrimary,
                        letterSpacing: 1.5,
                        fontSize: 9.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'WISDOM & COGNITION',
                      style: AppTextStyles.displayMedium,
                    ),
                  ],
                ),
                if (_selectedMainSegment == 1)
                  IconButton(
                    onPressed: _openAddResourceSheet,
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.shieldPrimary,
                      size: 24,
                    ),
                    tooltip: 'Add Custom Resource',
                  )
                else if (_selectedMainSegment == 3)
                  IconButton(
                    onPressed: () => AddJoyItemModalSheet.show(
                      context,
                      onSaved: () => setState(() {}),
                    ),
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.shieldPrimary,
                      size: 24,
                    ),
                    tooltip: 'Add Personal Anchor',
                  )
                else if (_selectedMainSegment == 4)
                  IconButton(
                    onPressed: _openImportHtmlSheet,
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                    tooltip: 'Import Offline HTML Tool',
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _selectedMainSegment == 0
                  ? 'Classic Sthitaprajna shlokas, Western Stoicism, and Behavioral Psychology for unflinching executive composure.'
                  : _selectedMainSegment == 1
                      ? 'Curated public-domain literature, audio/video breakdowns, and your personal Google Drive & Keep notes.'
                      : _selectedMainSegment == 2
                          ? 'Dissect boardroom manipulation tactics and deploy classical Stoic mental models to neutralize bad actors.'
                          : _selectedMainSegment == 3
                              ? 'Your personal soul sanctuary (आनंद कोष): uplifting music, visual anchors, serene memories, and comfort words.'
                              : 'Personal standalone HTML dashboards, decision calculators, and interactive tools rendered with full local JavaScript.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Top Segmented Switcher (Wisdom Cards / Resource Hub / Mental Models / Joy Reservoir / HTML Tools)
            _buildMainSegmentBar(),
            const SizedBox(height: 16),

            // Body based on selected segment
            if (_selectedMainSegment == 0)
              _buildWisdomCardsView()
            else if (_selectedMainSegment == 1)
              _buildResourceHubView()
            else if (_selectedMainSegment == 2)
              _buildMentalModelsView()
            else if (_selectedMainSegment == 3)
              const JoyReservoirScreen(isEmbedded: true)
            else
              _buildHtmlToolsView(),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // Main Segment Bar (Wisdom Cards / Resource Hub / Models / Joy / HTML Tools)
  // ---------------------------------------------------------
  Widget _buildMainSegmentBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSegmentButton(0, 'WISDOM CARDS', Icons.auto_stories_rounded),
            const SizedBox(width: 4),
            _buildSegmentButton(1, 'RESOURCE HUB', Icons.hub_rounded),
            const SizedBox(width: 4),
            _buildSegmentButton(2, 'MENTAL MODELS', Icons.psychology_rounded),
            const SizedBox(width: 4),
            _buildSegmentButton(3, 'JOY RESERVOIR', Icons.spa_rounded),
            const SizedBox(width: 4),
            _buildSegmentButton(4, 'HTML TOOLS', Icons.html_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton(int index, String label, IconData icon) {
    final isSelected = _selectedMainSegment == index;
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        setState(() {
          _selectedMainSegment = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.shieldPrimary : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? AppColors.shieldPrimary : AppColors.textMuted,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyles.labelBadge.copyWith(
                fontSize: 9.0,
                color: isSelected
                    ? AppColors.shieldPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // View 1: Wisdom Cards
  // ---------------------------------------------------------
  Widget _buildWisdomCardsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        CognitionSearchBar(
          controller: _wisdomSearchController,
          hintText: 'Search shlokas, Marcus, Seneca, Kahneman...',
          onChanged: (_) => _applyWisdomFilters(),
          onClear: () {
            _wisdomSearchController.clear();
            _applyWisdomFilters();
          },
        ),
        const SizedBox(height: 12),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildWisdomCategoryChip('all', 'ALL WISDOM'),
              const SizedBox(width: 6),
              _buildWisdomCategoryChip('gita', 'GITA & STHITAPRAJNA'),
              const SizedBox(width: 6),
              _buildWisdomCategoryChip('western_stoicism', 'WESTERN STOICISM'),
              const SizedBox(width: 6),
              _buildWisdomCategoryChip('psychology_behavioral', 'BEHAVIORAL PSYCHOLOGY'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Wisdom Cards List
        if (_filteredWisdom.isEmpty)
          _buildEmptyPlaceholder('NO WISDOM ENTRIES FOUND', 'Try adjusting your search terms.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredWisdom.length,
            itemBuilder: (context, index) {
              final entry = _filteredWisdom[index];
              final isAffirmation = _activeAffirmationId == entry.id;
              return WisdomCard(
                entry: entry,
                isAffirmation: isAffirmation,
                onSetAffirmation: () async {
                  await _storage.setDailyAffirmation(
                    id: entry.id,
                    title: entry.title,
                    text: entry.translation,
                    source: entry.source,
                  );
                  setState(() {
                    _activeAffirmationId = entry.id;
                  });
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildWisdomCategoryChip(String catKey, String label) {
    final isSelected = _selectedWisdomCategory == catKey;
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        setState(() {
          _selectedWisdomCategory = catKey;
          _applyWisdomFilters();
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

  // ---------------------------------------------------------
  // View 2: Resource Hub (Public Domain & Personal Links)
  // ---------------------------------------------------------
  Widget _buildResourceHubView() {
    var displayList = _resources;
    if (_selectedResourceFilter != 'all') {
      displayList = displayList.where((r) {
        return r.effectiveMediaType.toStorageString().toLowerCase() ==
            _selectedResourceFilter.toLowerCase();
      }).toList();
    }

    final ytCount =
        _resources.where((r) => r.effectiveMediaType == ResourceMediaType.youTube).length;
    final driveCount =
        _resources.where((r) => r.effectiveMediaType == ResourceMediaType.drivePdf).length;
    final keepCount =
        _resources.where((r) => r.effectiveMediaType == ResourceMediaType.googleKeep).length;
    final substackCount =
        _resources.where((r) => r.effectiveMediaType == ResourceMediaType.substack).length;
    final socialCount =
        _resources.where((r) => r.effectiveMediaType == ResourceMediaType.socialMedia).length;
    final webCount =
        _resources.where((r) => r.effectiveMediaType == ResourceMediaType.webLink).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resource Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildResourceFilterChip('all', 'ALL RESOURCES (${_resources.length})'),
              const SizedBox(width: 6),
              _buildResourceFilterChip('YouTube', 'YOUTUBE ($ytCount)'),
              const SizedBox(width: 6),
              _buildResourceFilterChip('DrivePDF', 'DRIVE PDF ($driveCount)'),
              const SizedBox(width: 6),
              _buildResourceFilterChip('GoogleKeep', 'GOOGLE KEEP ($keepCount)'),
              const SizedBox(width: 6),
              _buildResourceFilterChip('Substack', 'SUBSTACK ($substackCount)'),
              const SizedBox(width: 6),
              _buildResourceFilterChip('SocialMedia', 'SOCIAL MEDIA ($socialCount)'),
              const SizedBox(width: 6),
              _buildResourceFilterChip('WebLink', 'WEB ARCHIVE ($webCount)'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Quick Add Banner
        Container(
          padding: const EdgeInsets.all(AppDimens.space12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_moon_rounded, size: 20, color: AppColors.shieldPrimary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tap any resource to open classical texts, Drive PDFs, or YouTube videos seamlessly inside the app.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _openAddResourceSheet,
                icon: const Icon(Icons.add_rounded, size: 14),
                label: const Text('ADD', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.shieldPrimary,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // List
        if (displayList.isEmpty)
          _buildEmptyPlaceholder(
            'NO RESOURCES IN THIS CLUSTER',
            'Tap "+ ADD LINK" to add custom YouTube, Drive, or Keep notes.',
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final res = displayList[index];
              return ResourceHubCard(
                resource: res,
                onDelete: res.isUserAdded ? () => _deleteResource(res.id) : null,
              );
            },
          ),
      ],
    );
  }

  Widget _buildResourceFilterChip(String filterKey, String label) {
    final isSelected = _selectedResourceFilter == filterKey;
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        setState(() {
          _selectedResourceFilter = filterKey;
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

  // ---------------------------------------------------------
  // View 3: Mental Models & Fallacies
  // ---------------------------------------------------------
  Widget _buildMentalModelsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CognitionSearchBar(
          controller: _modelSearchController,
          hintText: 'Search strawman, gaslighting, ad hominem...',
          onChanged: (_) => _applyModelFilters(),
          onClear: () {
            _modelSearchController.clear();
            _applyModelFilters();
          },
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildModelFilterChip(0, 'ALL (${CognitionDataSource.items.length})'),
              const SizedBox(width: 6),
              _buildModelFilterChip(1, 'RULES OF ENGAGEMENT (${CognitionDataSource.getRulesOfEngagement().length})'),
              const SizedBox(width: 6),
              _buildModelFilterChip(2, 'FALLACIES (${CognitionDataSource.getFallacies().length})'),
              const SizedBox(width: 6),
              _buildModelFilterChip(3, 'STOIC MODELS (${CognitionDataSource.getMentalModels().length})'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_filteredModels.isEmpty)
          _buildEmptyPlaceholder('NO COGNITION MODELS FOUND', 'Try adjusting your search terms.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredModels.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return ExpandableMicroCard(item: _filteredModels[index]);
            },
          ),
      ],
    );
  }

  Widget _buildModelFilterChip(int index, String label) {
    final isSelected = _selectedModelFilterIndex == index;
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        setState(() {
          _selectedModelFilterIndex = index;
          _applyModelFilters();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        alignment: Alignment.center,
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 32, color: AppColors.textDisabled),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyles.labelBadge.copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // HTML Tools & Dashboards Tab (Segment 4)
  // ---------------------------------------------------------
  Widget _buildHtmlToolsView() {
    final categories = <String>{'all'};
    for (final t in _htmlTools) {
      categories.add(t.category);
    }

    final filtered = _selectedHtmlCategoryFilter == 'all'
        ? _htmlTools
        : _htmlTools.where((t) => t.category == _selectedHtmlCategoryFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Sandbox Info Card
        Container(
          padding: const EdgeInsets.all(AppDimens.space14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.html_rounded,
                          size: 18,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'OFFLINE SOVEREIGN SANDBOX',
                        style: AppTextStyles.labelBadge.copyWith(
                          color: const Color(0xFF10B981),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_htmlTools.length} TOOLS',
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Personal HTML Tools & Dashboards',
                style: AppTextStyles.heading,
              ),
              const SizedBox(height: 4),
              Text(
                'Import your private single-page tools, calculators, and interactive decision matrices. Stored 100% offline with zero cloud telemetry and full JavaScript execution.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openImportHtmlSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    'IMPORT HTML FILE (+)',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Category Filter Chips
        if (categories.length > 1) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedHtmlCategoryFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    selected: isSelected,
                    label: Text(cat.toUpperCase()),
                    selectedColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                    backgroundColor: AppColors.surfaceElevated,
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF10B981)
                          : AppColors.borderSubtle,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF10B981)
                          : AppColors.textSecondary,
                    ),
                    onSelected: (val) {
                      if (val) {
                        HapticService.selectionClick();
                        setState(() => _selectedHtmlCategoryFilter = cat);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // 3. Tool Cards List
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppDimens.space24),
            alignment: Alignment.center,
            child: Column(
              children: [
                const Icon(Icons.code_off_rounded, size: 36, color: AppColors.textMuted),
                const SizedBox(height: 8),
                const Text('No HTML tools found in this category', style: AppTextStyles.bodyMedium),
              ],
            ),
          )
        else
          ...filtered.map((tool) {
            return HtmlToolCard(
              tool: tool,
              onDelete: () async {
                await _storage.deleteHtmlTool(tool.id);
                _loadHtmlTools();
              },
              onUpdated: (_) => _loadHtmlTools(),
            );
          }),
      ],
    );
  }
}
