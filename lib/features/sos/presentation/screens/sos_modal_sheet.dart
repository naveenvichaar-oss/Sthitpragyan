import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/defensive_scripts_vault.dart';
import '../widgets/breathing_pulse_visualizer.dart';
import '../widgets/grounding_banner.dart';
import '../widgets/response_script_card.dart';

/// SOSModalSheet is the primary emergency modal launched by the SOS Shield button.
class SOSModalSheet extends StatefulWidget {
  const SOSModalSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticService.heavyImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (context) => const SOSModalSheet(),
    );
  }

  @override
  State<SOSModalSheet> createState() => _SOSModalSheetState();
}

class _SOSModalSheetState extends State<SOSModalSheet> {
  String _selectedCategory = 'All';
  late final HiveStorage _storage;
  List<String> _pinnedScriptIds = [];

  @override
  void initState() {
    super.initState();
    _storage = HiveStorage();
    if (_storage.isInitialized) {
      _pinnedScriptIds = _storage.getPinnedScriptIds();
    }
  }

  void _toggleBookmark(String scriptId) async {
    if (_storage.isInitialized) {
      await _storage.togglePinnedScript(scriptId);
      setState(() {
        _pinnedScriptIds = _storage.getPinnedScriptIds();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scripts = DefensiveScriptsVault.getByCategory(_selectedCategory);
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      height: size.height * 0.94,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderBright,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Modal Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.roseDanger,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'SHIELD ACTIVE • DETACH',
                      style: AppTextStyles.brandHeader,
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    HapticService.lightImpact();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close_rounded, size: 22),
                  color: AppColors.textSecondary,
                  splashRadius: 20,
                  tooltip: 'Dismiss Shield',
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.borderSubtle),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: [
                // 1. 3-Second Breathing Pulse Visualizer
                const BreathingPulseVisualizer(),
                const SizedBox(height: 16),

                // 2. Vagal Grounding Reminder Banner
                const GroundingBanner(),
                const SizedBox(height: 24),

                // 3. Defensive Response Scripts Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DEFENSIVE REBUTTAL SCRIPTS',
                          style: AppTextStyles.labelBadge.copyWith(
                            letterSpacing: 1.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Swipeable tactical responses to corporate hostility',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${scripts.length} LOADED',
                      style: AppTextStyles.metricSmall.copyWith(fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Category Chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: DefensiveScriptsVault.categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = DefensiveScriptsVault.categories[index];
                      final isSelected = cat == _selectedCategory;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            HapticService.selectionClick();
                            setState(() {
                              _selectedCategory = cat;
                            });
                          }
                        },
                        selectedColor: AppColors.surfaceElevated,
                        backgroundColor: AppColors.surface,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.shieldPrimary
                              : AppColors.borderSubtle,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.shieldPrimary
                              : AppColors.textSecondary,
                        ),
                        visualDensity: VisualDensity.compact,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Horizontal Carousel / Swipeable Cards
                SizedBox(
                  height: 330,
                  child: PageView.builder(
                    itemCount: scripts.length,
                    controller: PageController(viewportFraction: 0.95),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = scripts[index];
                      final isBookmarked = _pinnedScriptIds.contains(item.id);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ResponseScriptCard(
                          script: item,
                          isBookmarked: isBookmarked,
                          onToggleBookmark: () => _toggleBookmark(item.id),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    '← SWIPE FOR ADDITIONAL STRATEGIC SCRIPTS →',
                    style: AppTextStyles.labelBadge.copyWith(
                      fontSize: 9.5,
                      letterSpacing: 1.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
