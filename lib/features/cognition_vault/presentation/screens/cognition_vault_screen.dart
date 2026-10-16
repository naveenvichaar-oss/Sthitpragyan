import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/cognition_data_source.dart';
import '../../data/models/fallacy_and_model.dart';
import '../widgets/cognition_search_bar.dart';
import '../widgets/expandable_micro_card.dart';

/// CognitionVaultScreen hosts micro-cards on Logical Fallacies and Stoic Mental Models.
class CognitionVaultScreen extends StatefulWidget {
  const CognitionVaultScreen({super.key});

  @override
  State<CognitionVaultScreen> createState() => _CognitionVaultScreenState();
}

class _CognitionVaultScreenState extends State<CognitionVaultScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0; // 0: All, 1: Fallacies, 2: Stoic Models

  List<CognitionItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = _searchController.text.trim();
    CognitionType? filterType;

    if (_selectedFilterIndex == 1) {
      filterType = CognitionType.fallacy;
    } else if (_selectedFilterIndex == 2) {
      filterType = CognitionType.mentalModel;
    }

    setState(() {
      _filteredItems = CognitionDataSource.search(query, filterType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                      'INTELLECTUAL DEFENSE',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.shieldPrimary,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'COGNITION VAULT',
                      style: AppTextStyles.displayMedium,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    '${_filteredItems.length} MODELS',
                    style: AppTextStyles.metricSmall.copyWith(fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Dissect boardroom manipulation tactics and deploy classical Stoic mental models to neutralize bad actors.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            CognitionSearchBar(
              controller: _searchController,
              onChanged: (_) => _applyFilters(),
              onClear: () {
                _searchController.clear();
                _applyFilters();
              },
            ),
            const SizedBox(height: 12),

            // Filter Tabs (All / Fallacies / Mental Models)
            Row(
              children: [
                _buildFilterChip(
                  0,
                  'ALL (${CognitionDataSource.items.length})',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  1,
                  'FALLACIES (${CognitionDataSource.getFallacies().length})',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  2,
                  'STOIC MODELS (${CognitionDataSource.getMentalModels().length})',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Micro-Cards List
            if (_filteredItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppDimens.space32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.search_off_rounded,
                      size: 32,
                      color: AppColors.textDisabled,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'NO COGNITION MODELS FOUND',
                      style: AppTextStyles.labelBadge.copyWith(
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try adjusting your search terms.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return ExpandableMicroCard(item: _filteredItems[index]);
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilterIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticService.selectionClick();
          setState(() {
            _selectedFilterIndex = index;
            _applyFilters();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceElevated : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            border: Border.all(
              color: isSelected
                  ? AppColors.shieldPrimary
                  : AppColors.borderSubtle,
              width: 1.0,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelBadge.copyWith(
              fontSize: 9.0,
              color: isSelected
                  ? AppColors.shieldPrimary
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
