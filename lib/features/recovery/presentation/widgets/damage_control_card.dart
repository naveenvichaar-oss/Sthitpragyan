import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/haptic_service.dart';

/// Model representing a damage control script for de-escalating after a slip-up
class DamageControlScript {
  final String id;
  final String title;
  final String scenario;
  final String verbatimScript;
  final String tacticalNote;

  const DamageControlScript({
    required this.id,
    required this.title,
    required this.scenario,
    required this.verbatimScript,
    required this.tacticalNote,
  });
}

/// DamageControlCard displays vetted executive scripts to neutralize conversational friction.
class DamageControlCard extends StatelessWidget {
  final DamageControlScript script;
  final bool isSelected;
  final VoidCallback onSelect;

  const DamageControlCard({
    super.key,
    required this.script,
    required this.isSelected,
    required this.onSelect,
  });

  static const List<DamageControlScript> defaultScripts = [
    DamageControlScript(
      id: 'dc_01',
      title: 'Written Recalibration (The Pivot)',
      scenario: 'After defending yourself verbally or sending a slightly reactive email.',
      verbatimScript: 'Regarding our earlier exchange: let\'s calibrate solely on documented deliverables and verified milestones. I will summarize the next concrete steps in writing.',
      tacticalNote: 'Stops verbal back-and-forth immediately and forces the agitator into the factual accountability of writing.',
    ),
    DamageControlScript(
      id: 'dc_02',
      title: 'Tone Neutralizer (De-escalation)',
      scenario: 'When tension peaked or voices were raised in a meeting.',
      verbatimScript: 'I want to ensure complete alignment without conversational noise. Let\'s step back, review the specific data points in our sync, and proceed from there.',
      tacticalNote: 'Acknowledges tension without accepting personal blame or apologizing for having a boundary.',
    ),
    DamageControlScript(
      id: 'dc_03',
      title: 'Manufactured Urgency Cooler',
      scenario:
          'When pressured into an impulsive commitment you need to walk back.',
      verbatimScript: 'Following an audit of our milestone capacity, executing this scope without compromising quality requires 2 business days. Let\'s formalize the priority order in our tracker.',
      tacticalNote: 'Reclaims time and replaces emotional urgency with objective capacity constraints.',
    ),
    DamageControlScript(
      id: 'dc_04',
      title: 'Public Interruption Reset',
      scenario:
          'After an uncomfortable confrontation in front of stakeholders.',
      verbatimScript: 'To keep this meeting strictly focused on executive priorities, let\'s document all secondary queries and address them asynchronously.',
      tacticalNote:
          'Protects your frame and refocuses the room on strategic objectives.',
    ),
  ];

  void _copyToClipboard(BuildContext context) {
    HapticService.selectionClick();
    Clipboard.setData(ClipboardData(text: script.verbatimScript));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.emeraldSuccess,
              size: 18,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Damage Control Script copied to clipboard.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceElevated,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppDimens.space14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: isSelected ? AppColors.shieldPrimary : AppColors.borderSubtle,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(
                  script.title.toUpperCase(),
                  style: AppTextStyles.labelBadge.copyWith(
                    color: AppColors.shieldPrimary,
                    fontSize: 9.0,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _copyToClipboard(context),
                icon: const Icon(Icons.copy_rounded, size: 16),
                color: AppColors.shieldPrimary,
                tooltip: 'Copy Script',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            script.scenario,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.shieldPrimary.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
            child: Text(
              '"${script.verbatimScript}"',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Tactical: ${script.tacticalNote}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onSelect,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  isSelected ? 'SELECTED ✓' : 'USE THIS SCRIPT',
                  style: AppTextStyles.labelBadge.copyWith(
                    fontSize: 9.5,
                    color: isSelected
                        ? AppColors.emeraldSuccess
                        : AppColors.shieldPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
