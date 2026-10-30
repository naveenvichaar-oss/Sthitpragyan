import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../wisdom/data/models/resource_link.dart';
import '../../../wisdom/data/models/wisdom_entry.dart';
import '../../../wisdom/data/services/wisdom_vault_service.dart';
import '../../../wisdom/presentation/widgets/add_resource_modal_sheet.dart';
import '../../../wisdom/presentation/widgets/resource_hub_card.dart';
import '../../../wisdom/presentation/widgets/wisdom_card.dart';
import '../../data/models/fallacy_and_model.dart';
import '../../data/models/local_html_tool.dart';
import '../../data/services/html_tool_storage_service.dart';
import '../widgets/cognition_search_bar.dart';
import '../widgets/expandable_micro_card.dart';
import '../widgets/html_tool_card.dart';
import '../widgets/import_html_tool_modal_sheet.dart';
import '../widgets/add_cognition_item_modal_sheet.dart';
import '../../../joy_reservoir/data/models/joy_item.dart';
import '../../../joy_reservoir/data/services/joy_audio_service.dart';
import '../../../joy_reservoir/presentation/widgets/add_joy_item_modal_sheet.dart';
import '../../../joy_reservoir/presentation/widgets/joy_item_card.dart';

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
  State<CognitionVaultScreen> createState() => CognitionVaultScreenState();
}

class CognitionVaultScreenState extends State<CognitionVaultScreen> {
  final HiveStorage _storage = HiveStorage();
  final WisdomVaultService _wisdomService = WisdomVaultService();

  // Top Segment Control: 0 = Mental Models, 1 = Wisdom Cards, 2 = Resource Hub, 3 = HTML Tools, 4 = Joy Box
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
  int _selectedModelFilterIndex = 0; // 0: All, 1: Stoic Models, 2: Rules of Engagement, 3: Case Studies
  String _selectedFallacyTag = 'all';

  // Offline HTML Tools State
  List<LocalHtmlTool> _htmlTools = [];
  String _selectedHtmlCategoryFilter = 'all';

  @override
  void initState() {
    super.initState();
    _selectedMainSegment = widget.initialSegment;
    _loadAllData();
  }

  @override
  void didUpdateWidget(CognitionVaultScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSegment != oldWidget.initialSegment) {
      _selectedMainSegment = widget.initialSegment;
    }
  }

  /// Public method to seamlessly switch tabs from external controllers (e.g. Dashboard)
  void switchToSegment(int segmentIndex) {
    if (mounted && _selectedMainSegment != segmentIndex) {
      HapticService.selectionClick();
      setState(() {
        _selectedMainSegment = segmentIndex;
      });
    }
  }

  void _loadAllData() {
    // 1. Wisdom entries
    _applyWisdomFilters();
    _activeAffirmationId = _storage.getDailyAffirmationId();

    // 2. Resource links
    _loadResources();

    // 3. Offline HTML Tools
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
              onPressed: () => AddCognitionItemModalSheet.show(
                context,
                initialType: CognitionType.mentalModel,
                onSaved: (item) => setState(() {}),
              ),
              backgroundColor: AppColors.shieldPrimary,
              foregroundColor: AppColors.background,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(
                context.loc.addModelAction,
                style: AppTextStyles.labelBadge.copyWith(
                  color: AppColors.background,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            )
          : _selectedMainSegment == 2
              ? FloatingActionButton.extended(
                  onPressed: () => AddCognitionItemModalSheet.show(
                    context,
                    initialType: CognitionType.fallacy,
                    onSaved: (item) => setState(() {}),
                  ),
                  backgroundColor: AppColors.shieldPrimary,
                  foregroundColor: AppColors.background,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(
                    context.loc.addFallacyAction,
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.background,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                )
              : _selectedMainSegment == 3
                  ? FloatingActionButton.extended(
                      onPressed: _openImportHtmlSheet,
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.black,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(
                        context.loc.importHtmlAction,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    )
                  : _selectedMainSegment == 4
                      ? FloatingActionButton.extended(
                          onPressed: () => AddJoyItemModalSheet.show(
                            context,
                            onSaved: () => setState(() {}),
                          ),
                          backgroundColor: const Color(0xFFF43F5E),
                          foregroundColor: Colors.white,
                          icon: const Icon(Icons.favorite_rounded, size: 20),
                          label: Text(
                            context.loc.addAnchorAction,
                            style: AppTextStyles.labelBadge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        )
                      : _selectedMainSegment == 5
                          ? FloatingActionButton.extended(
                              onPressed: _openAddResourceSheet,
                              backgroundColor: AppColors.shieldPrimary,
                              foregroundColor: AppColors.background,
                              icon: const Icon(Icons.add_link_rounded, size: 20),
                              label: Text(
                                context.loc.addResourceAction,
                                style: AppTextStyles.labelBadge.copyWith(
                                  color: AppColors.background,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
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
                      context.loc.cognitionVaultSubtitle.toUpperCase(),
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.shieldPrimary,
                        letterSpacing: 1.5,
                        fontSize: 9.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.loc.cognitionVaultTitle,
                      style: AppTextStyles.displayMedium,
                    ),
                  ],
                ),
                if (_selectedMainSegment == 1)
                  IconButton(
                    onPressed: () => AddCognitionItemModalSheet.show(
                      context,
                      initialType: CognitionType.mentalModel,
                      onSaved: (item) => setState(() {}),
                    ),
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.shieldPrimary,
                      size: 24,
                    ),
                    tooltip: 'Add Mental Model',
                  )
                else if (_selectedMainSegment == 2)
                  IconButton(
                    onPressed: () => AddCognitionItemModalSheet.show(
                      context,
                      initialType: CognitionType.fallacy,
                      onSaved: (item) => setState(() {}),
                    ),
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.shieldPrimary,
                      size: 24,
                    ),
                    tooltip: 'Add Logical Fallacy',
                  )
                else if (_selectedMainSegment == 3)
                  IconButton(
                    onPressed: _openImportHtmlSheet,
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                    tooltip: 'Import Offline HTML Tool',
                  )
                else if (_selectedMainSegment == 4)
                  IconButton(
                    onPressed: () => AddJoyItemModalSheet.show(
                      context,
                      onSaved: () => setState(() {}),
                    ),
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: Color(0xFFF43F5E),
                      size: 24,
                    ),
                    tooltip: 'Add Joy Anchor',
                  )
                else if (_selectedMainSegment == 5)
                  IconButton(
                    onPressed: _openAddResourceSheet,
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.shieldPrimary,
                      size: 24,
                    ),
                    tooltip: 'Add Custom Resource',
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.loc.cognitionVaultDesc(_selectedMainSegment),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Top Segmented Switcher (Wisdom Cards / Mental Models / Logical Fallacies / HTML Tools / Joy Box / Resources)
            _buildMainSegmentBar(),
            const SizedBox(height: 16),

            // Body based on selected segment
            if (_selectedMainSegment == 0)
              _buildWisdomCardsView()
            else if (_selectedMainSegment == 1)
              _buildMentalModelsOnlyView()
            else if (_selectedMainSegment == 2)
              _buildLogicalFallaciesOnlyView()
            else if (_selectedMainSegment == 3)
              _buildHtmlToolsView()
            else if (_selectedMainSegment == 4)
              _buildJoyBoxView()
            else if (_selectedMainSegment == 5)
              _buildResourceHubView()
            else
              _buildWisdomCardsView(),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // Main Segment Bar (Wisdom Cards / Mental Models / Fallacies / HTML Tools / Joy Box / Resource Hub)
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
            _buildSegmentButton(0, context.loc.segmentWisdom, Icons.auto_stories_rounded),
            const SizedBox(width: 4),
            _buildSegmentButton(1, context.loc.segmentMentalModels, Icons.psychology_rounded),
            const SizedBox(width: 4),
            _buildSegmentButton(2, context.loc.segmentLogicalFallacies, Icons.rule_folder_rounded),
            const SizedBox(width: 4),
            _buildSegmentButton(3, context.loc.segmentHtmlTools, Icons.html_rounded),
            const SizedBox(width: 4),
            _buildSegmentButton(4, context.loc.joyBoxSegmentTitle, Icons.spa_rounded),
            const SizedBox(width: 4),
            _buildSegmentButton(5, context.loc.resourceHubTab, Icons.hub_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton(int index, String label, IconData icon) {
    final isSelected = _selectedMainSegment == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticService.selectionClick();
          setState(() {
            _selectedMainSegment = index;
          });
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? AppColors.shieldPrimary : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.shieldPrimary : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelBadge.copyWith(
                  fontSize: 10.0,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticService.selectionClick();
          setState(() {
            _selectedWisdomCategory = catKey;
            _applyWisdomFilters();
          });
        },
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceElevated : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            border: Border.all(
              color: isSelected ? AppColors.shieldPrimary : AppColors.borderSubtle,
              width: isSelected ? 1.2 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelBadge.copyWith(
              fontSize: 9.5,
              color: isSelected ? AppColors.shieldPrimary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // View 4: Joy Box / Soul Sanctuary (आनंद कोष)
  // ---------------------------------------------------------
  Widget _buildJoyBoxView() {
    final joyItems = _storage.getAllJoyItems();

    final musicCount = joyItems.where((i) => i.category == JoyCategory.music).length;
    final visualCount = joyItems.where((i) => i.category == JoyCategory.visual).length;
    final quoteCount = joyItems.where((i) => i.category == JoyCategory.quote).length;
    final memoryCount = joyItems.where((i) => i.category == JoyCategory.memory).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Action Banner
        Container(
          padding: const EdgeInsets.all(AppDimens.space12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.loc.soulSanctuaryHeader,
                      style: AppTextStyles.heading.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.loc.joyItemsSummary(
                        joyItems.length,
                        musicCount,
                        visualCount,
                        quoteCount + memoryCount,
                      ),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      HapticService.selectionClick();
                      AddJoyItemModalSheet.show(
                        context,
                        initialCategory: JoyCategory.music,
                        onSaved: () => setState(() {}),
                      );
                    },
                    icon: const Icon(Icons.audio_file_rounded, size: 14),
                    label: Text(
                      context.loc.localAudioStatus,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.shieldPrimary,
                      side: const BorderSide(color: AppColors.shieldPrimary, width: 0.8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticService.selectionClick();
                      AddJoyItemModalSheet.show(
                        context,
                        onSaved: () => setState(() {}),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 14),
                    label: Text(
                      context.loc.addTextButton,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF43F5E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (joyItems.isEmpty)
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
                  color: Color(0xFFF43F5E),
                ),
                const SizedBox(height: 10),
                Text(
                  context.loc.noAnchorsInCategory,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
            itemCount: joyItems.length,
            itemBuilder: (context, index) {
              final joy = joyItems[index];
              return JoyItemCard(
                item: joy,
                onDelete: () async {
                  HapticService.mediumImpact();
                  if (JoyAudioService().isActive(joy.id)) {
                    await JoyAudioService().stop();
                  }
                  await _storage.deleteJoyItem(joy.id);
                  if (mounted) setState(() {});
                },
              );
            },
          ),
      ],
    );
  }

  // ---------------------------------------------------------
  // View 5: Resource Hub (Public Domain & Personal Links)
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
              _buildResourceFilterChip(
                'all',
                context.loc.allResourcesCategory(_resources.length),
              ),
              const SizedBox(width: 6),
              _buildResourceFilterChip('YouTube', 'YouTube ($ytCount)'),
              const SizedBox(width: 6),
              _buildResourceFilterChip('DrivePDF', 'Drive PDF ($driveCount)'),
              const SizedBox(width: 6),
              _buildResourceFilterChip('GoogleKeep', 'Google Keep ($keepCount)'),
              const SizedBox(width: 6),
              _buildResourceFilterChip('Substack', 'Substack ($substackCount)'),
              const SizedBox(width: 6),
              _buildResourceFilterChip(
                'SocialMedia',
                context.loc.socialMediaCategory(socialCount),
              ),
              const SizedBox(width: 6),
              _buildResourceFilterChip(
                'WebLink',
                context.loc.webArchiveCategory(webCount),
              ),
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
                  context.loc.sanctuaryResourceTapBanner,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _openAddResourceSheet,
                icon: const Icon(Icons.add_rounded, size: 14),
                label: Text(context.loc.addTextButton, style: const TextStyle(fontSize: 11)),
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
            context.loc.noResourcesInCluster,
            context.loc.emptyJoyReservoirDesc,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticService.selectionClick();
          setState(() {
            _selectedResourceFilter = filterKey;
          });
        },
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceElevated : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            border: Border.all(
              color: isSelected ? AppColors.shieldPrimary : AppColors.borderSubtle,
              width: isSelected ? 1.2 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelBadge.copyWith(
              fontSize: 9.5,
              color: isSelected ? AppColors.shieldPrimary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // View 1: Mental Models (Timeless frameworks & systems thinking)
  // ---------------------------------------------------------
  Widget _buildMentalModelsOnlyView() {
    final query = _modelSearchController.text.trim();
    var allItems = _storage.getAllCognitionItems().where((i) =>
        i.type == CognitionType.mentalModel ||
        i.type == CognitionType.rulesOfEngagement).toList();

    if (query.isNotEmpty) {
      allItems = allItems.where((i) => i.matchesQuery(query)).toList();
    }

    final caseStudyItems = allItems.where((i) =>
        i.tags.any((t) => t.toLowerCase() == 'case study') ||
        i.id.startsWith('case_')).toList();
    final caseCount = caseStudyItems.length;

    final roeCount = allItems.where((i) => i.type == CognitionType.rulesOfEngagement).length;
    final stoicModelCount = allItems.where((i) =>
        i.type == CognitionType.mentalModel &&
        !i.tags.any((t) => t.toLowerCase() == 'case study') &&
        !i.id.startsWith('case_')).length;

    var items = allItems;
    if (_selectedModelFilterIndex == 1) {
      items = allItems.where((i) =>
          i.type == CognitionType.mentalModel &&
          !i.tags.any((t) => t.toLowerCase() == 'case study') &&
          !i.id.startsWith('case_')).toList();
    } else if (_selectedModelFilterIndex == 2) {
      items = allItems.where((i) => i.type == CognitionType.rulesOfEngagement).toList();
    } else if (_selectedModelFilterIndex == 3) {
      items = caseStudyItems;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CognitionSearchBar(
          controller: _modelSearchController,
          hintText: context.loc.searchMentalModelsHint,
          onChanged: (_) => setState(() {}),
          onClear: () {
            _modelSearchController.clear();
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMentalModelFilterChip(
                0,
                context.loc.allModelsCategory(allItems.length),
              ),
              const SizedBox(width: 6),
              _buildMentalModelFilterChip(
                1,
                context.loc.stoicModelsCategory(stoicModelCount),
              ),
              const SizedBox(width: 6),
              _buildMentalModelFilterChip(
                2,
                context.loc.rulesOfEngagementCategory(roeCount),
              ),
              const SizedBox(width: 6),
              _buildMentalModelFilterChip(
                3,
                context.loc.caseStudiesCategory(caseCount),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          _buildEmptyPlaceholder(
            context.loc.noMentalModelsFound,
            context.loc.tryAdjustingSearch,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final model = items[index];
              return ExpandableMicroCard(
                item: model,
                onItemUpdated: (_) => setState(() {}),
                onDelete: () => setState(() {}),
              );
            },
          ),
      ],
    );
  }

  Widget _buildMentalModelFilterChip(int index, String label) {
    final isSelected = _selectedModelFilterIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticService.selectionClick();
          setState(() {
            _selectedModelFilterIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceElevated : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            border: Border.all(
              color: isSelected ? AppColors.shieldPrimary : AppColors.borderSubtle,
              width: isSelected ? 1.2 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelBadge.copyWith(
              fontSize: 9.5,
              color: isSelected ? AppColors.shieldPrimary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // View 2: Logical Fallacies & Cognitive Biases
  // ---------------------------------------------------------
  Widget _buildLogicalFallaciesOnlyView() {
    final query = _modelSearchController.text.trim();
    var allItems = _storage.getAllCognitionItems().where((i) =>
        i.type == CognitionType.fallacy).toList();

    if (query.isNotEmpty) {
      allItems = allItems.where((i) => i.matchesQuery(query)).toList();
    }

    var items = allItems;
    if (_selectedFallacyTag != 'all') {
      final tagMatch = _selectedFallacyTag.replaceAll('_', ' ').toLowerCase();
      items = allItems.where((i) {
        final title = i.title.toLowerCase();
        final tags = i.tags.map((t) => t.toLowerCase()).toList();
        return title.contains(tagMatch) ||
            tags.any((t) => t.contains(tagMatch)) ||
            i.latinName.toLowerCase().contains(tagMatch);
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CognitionSearchBar(
          controller: _modelSearchController,
          hintText: context.loc.searchFallaciesHint,
          onChanged: (_) => setState(() {}),
          onClear: () {
            _modelSearchController.clear();
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
        // Fallacy Tracker Quick-Reference Tag Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFallacyTagChip('all', context.loc.filterAllFallacies),
              const SizedBox(width: 6),
              _buildFallacyTagChip('ad_hominem', 'Ad Hominem'),
              const SizedBox(width: 6),
              _buildFallacyTagChip('straw_man', 'Straw Man'),
              const SizedBox(width: 6),
              _buildFallacyTagChip('appeal_to_emotion', context.loc.appealToEmotionTag),
              const SizedBox(width: 6),
              _buildFallacyTagChip('false_dilemma', 'False Dilemma'),
              const SizedBox(width: 6),
              _buildFallacyTagChip('sunk_cost', 'Sunk Cost'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          _buildEmptyPlaceholder(
            context.loc.noLogicalFallaciesFound,
            context.loc.tryAdjustingSearch,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final model = items[index];
              return ExpandableMicroCard(
                item: model,
                onItemUpdated: (_) => setState(() {}),
                onDelete: () => setState(() {}),
              );
            },
          ),
      ],
    );
  }

  Widget _buildFallacyTagChip(String tagKey, String label) {
    final isSelected = _selectedFallacyTag == tagKey;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticService.selectionClick();
          setState(() {
            _selectedFallacyTag = tagKey;
          });
        },
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        child: Container(
          constraints: const BoxConstraints(minHeight: 38),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceElevated : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            border: Border.all(
              color: isSelected ? AppColors.shieldPrimary : AppColors.borderSubtle,
              width: isSelected ? 1.2 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelBadge.copyWith(
              fontSize: 9.5,
              color: isSelected ? AppColors.shieldPrimary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
                        context.loc.offlineSovereignSandboxBadge,
                        style: AppTextStyles.labelBadge.copyWith(
                          color: const Color(0xFF10B981),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    context.loc.toolsCountBadge(_htmlTools.length),
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                context.loc.htmlToolsTitle,
                style: AppTextStyles.heading,
              ),
              const SizedBox(height: 4),
              Text(
                context.loc.offlineToolsDescription,
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
                  label: Text(
                    context.loc.importHtmlButton.toUpperCase(),
                    style: const TextStyle(
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
                Text(context.loc.noHtmlToolsFound, style: AppTextStyles.bodyMedium),
              ],
            ),
          )
        else
          ...filtered.map((tool) {
            return HtmlToolCard(
              tool: tool,
              onDelete: () async {
                await HtmlToolStorageService().deleteTool(tool);
                _loadHtmlTools();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${context.loc.toolDeletedNotice} ("${tool.title}")'),
                      backgroundColor: AppColors.surfaceElevated,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              onUpdated: (_) => _loadHtmlTools(),
            );
          }),
      ],
    );
  }
}
