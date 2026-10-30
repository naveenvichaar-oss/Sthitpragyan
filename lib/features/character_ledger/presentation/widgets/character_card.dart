import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/models/character_trait_entry.dart';

/// CharacterCard renders an individual virtue/trait record in the Character Ledger.
class CharacterCard extends StatelessWidget {
  final CharacterTraitEntry entry;
  final VoidCallback? onDelete;

  const CharacterCard({
    super.key,
    required this.entry,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = entry.category;
    final accent = category.accentColor;
    final formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(entry.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: accent.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Category Badge & Devanagari & Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(category.icon, size: 13, color: accent),
                    const SizedBox(width: 6),
                    Text(
                      '${category.displayName.toUpperCase()} • ${category.devanagari}',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: accent,
                        fontSize: 8.5,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  tooltip: context.loc.deleteEntryTooltip,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDelete,
                ),
            ],
          ),
          const SizedBox(height: 10),

          // 2. Title
          Text(
            entry.title,
            style: AppTextStyles.heading.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),

          // 3. Situation Arena
          if (entry.situation.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.loc.arenaLabel,
                  style: AppTextStyles.labelBadge.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 8.5,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.situation,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // 4. Behavior Observation & Restraint
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(
              entry.behaviorObservation,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),

          // 5. Key Realization / Lesson (if present)
          if (entry.reflection != null && entry.reflection!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    entry.reflection!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: accent,
                      fontStyle: FontStyle.italic,
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // 6. Tags & Gravitas Rating Footer
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tags
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: entry.tags.map((tag) {
                    final cleanTag = tag.startsWith('#') ? tag : '#$tag';
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        cleanTag,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 8),
              // Gravitas Rating & Timestamp
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      entry.gravitasRating.clamp(1, 5),
                      (_) => const Icon(
                        Icons.shield_rounded,
                        size: 12,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
