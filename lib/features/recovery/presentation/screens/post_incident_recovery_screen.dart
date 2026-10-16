import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/incident_slip_up_log.dart';
import 'package:sthitaprajna/features/wisdom/data/models/wisdom_entry.dart';
import 'package:sthitaprajna/features/wisdom/data/services/wisdom_vault_service.dart';
import 'package:sthitaprajna/features/wisdom/presentation/widgets/emergency_perspective_modal.dart';
import '../widgets/box_breathing_drill_modal.dart';
import '../widgets/damage_control_card.dart';

/// ArchetypeGuidance defines the mindset of high-intellect stoic executive archetypes
class ArchetypeGuidance {
  final String title;
  final String subtitleHindi;
  final String coreDoctrine;
  final String sampleResponse;
  final IconData icon;

  const ArchetypeGuidance({
    required this.title,
    required this.subtitleHindi,
    required this.coreDoctrine,
    required this.sampleResponse,
    required this.icon,
  });
}

/// PostIncidentRecoveryScreen enables a rapid 30-second post-mortem,
/// archetype reflection, 2-minute box breathing, and damage control re-write.
class PostIncidentRecoveryScreen extends StatefulWidget {
  const PostIncidentRecoveryScreen({super.key});

  @override
  State<PostIncidentRecoveryScreen> createState() =>
      _PostIncidentRecoveryScreenState();
}

class _PostIncidentRecoveryScreenState
    extends State<PostIncidentRecoveryScreen> {
  final HiveStorage _storage = HiveStorage();

  // Screen Tab State: 0 = Post-Mortem Audit & Drills, 1 = Emergency Perspective (60s Read)
  int _selectedRecoveryTab = 0;
  int _selectedPerspectiveIndex = 0;

  // 1. Post-Mortem selections
  String _selectedTrigger = 'Toxic Boss';
  String _selectedMistake = 'Gave unnecessary explanation';
  String _selectedPhysicalState = 'Shallow breathing';

  // 2. Archetype & Reflection
  int _selectedArchetypeIndex = 0;
  final TextEditingController _reflectionController = TextEditingController();
  final TextEditingController _rewriteController = TextEditingController();

  // 3. Drills state
  bool _boxBreathingCompleted = false;
  String? _selectedDamageControlScript;

  final List<String> _triggers = [
    'Toxic Boss',
    'Unrealistic Deadline',
    'Passive Aggression',
    'Public Put-Down',
    'Micro-Management',
    'Interruption',
    'Scope Creep',
    'Broken Agreement',
  ];

  final List<String> _mistakes = [
    'Gave unnecessary explanation',
    'Raised voice / showed anger',
    'Agreed impulsively',
    'Defended defensively',
    'Sent reactive email',
    'Lost frame / validated drama',
  ];

  final List<String> _physicalStates = [
    'Shallow breathing',
    'Tense posture',
    'Jaw clenched',
    'Racing heart',
    'Clenched fists',
    'Restlessness',
  ];

  final List<ArchetypeGuidance> _archetypes = const [
    ArchetypeGuidance(
      title: 'The Stoic',
      subtitleHindi: 'स्थितप्रज्ञ',
      coreDoctrine: 'Detached, zero emotional reaction, sticks strictly to objective reality. External events cannot disturb internal peace unless judged as harm.',
      sampleResponse: 'भाषा या एंगल में क्या विशिष्ट फैक्चुअल बदलाव चाहिए? कृपया बिंदु स्पष्ट करें।',
      icon: Icons.shield_rounded,
    ),
    ArchetypeGuidance(
      title: 'The Strategist',
      subtitleHindi: 'रणनीतिकार',
      coreDoctrine: 'Puts the burden of proof back on the agitator, minimal words, strategic silence. Does not explain or defend.',
      sampleResponse: 'इस दावे का आधार क्या डेटा है? जब आप बिंदुवार विश्लेषण साझा करेंगे, तब मैं समीक्षा करूँगा।',
      icon: Icons.psychology_rounded,
    ),
    ArchetypeGuidance(
      title: 'The Executive',
      subtitleHindi: 'प्रशासक',
      coreDoctrine: 'Demands written clarity/specifics, ignores passive-aggressive tone completely. Aligns solely on verified deliverables.',
      sampleResponse: 'Regarding deliverables: let\'s calibrate milestone expectations in writing before allocating engineering capacity.',
      icon: Icons.account_balance_rounded,
    ),
  ];

  @override
  void dispose() {
    _reflectionController.dispose();
    _rewriteController.dispose();
    super.dispose();
  }

  void _applyArchetypeDoctrine(ArchetypeGuidance arch) {
    HapticService.selectionClick();
    setState(() {
      if (_reflectionController.text.trim().isEmpty) {
        _reflectionController.text =
            'As ${arch.title} (${arch.subtitleHindi}): ${arch.coreDoctrine}';
      }
      if (_rewriteController.text.trim().isEmpty) {
        _rewriteController.text = arch.sampleResponse;
      }
    });
  }

  Future<void> _openBoxBreathingDrill() async {
    final completed = await BoxBreathingDrillModal.show(
      context,
      onCompleted: () {
        setState(() {
          _boxBreathingCompleted = true;
        });
      },
    );

    if (completed == true) {
      setState(() {
        _boxBreathingCompleted = true;
      });
    }
  }

  Future<void> _saveRecoveryLog() async {
    HapticService.success();

    final activeArch = _archetypes[_selectedArchetypeIndex];
    final log = IncidentSlipUpLog(
      id: 'slip_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      trigger: _selectedTrigger,
      mistakeType: _selectedMistake,
      physicalState: _selectedPhysicalState,
      archetype: '${activeArch.title} (${activeArch.subtitleHindi})',
      idealResponse: _reflectionController.text.trim(),
      revisedScript: _rewriteController.text.trim(),
      damageControlScriptUsed: _selectedDamageControlScript,
      boxBreathingCompleted: _boxBreathingCompleted,
    );

    if (_storage.isInitialized) {
      await _storage.saveSlipUpIncident(log);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.emeraldSuccess,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Post-Incident Logged. Composure and frame restored.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeArch = _archetypes[_selectedArchetypeIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SLIP-UP AUDIT & RECOVERY',
              style: AppTextStyles.labelBadge.copyWith(
                color: AppColors.amberWarning,
                fontSize: 9.5,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              'Post-Incident Equanimity Reset',
              style: AppTextStyles.heading.copyWith(fontSize: 17),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.auto_stories_rounded,
              color: AppColors.amberWarning,
              size: 20,
            ),
            tooltip: '60s Emergency Read Modal',
            onPressed: () => EmergencyPerspectiveModal.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Tab Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  _buildTabButton(0, 'POST-MORTEM & DRILLS', Icons.assignment_outlined),
                  const SizedBox(width: 4),
                  _buildTabButton(1, 'EMERGENCY PERSPECTIVE (60s)', Icons.auto_stories_rounded),
                ],
              ),
            ),
          ),
          Expanded(
            child: _selectedRecoveryTab == 0
                ? _buildPostMortemListView(activeArch)
                : _buildEmergencyPerspectiveView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedRecoveryTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticService.selectionClick();
          setState(() {
            _selectedRecoveryTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? AppColors.amberWarning : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? AppColors.amberWarning : AppColors.textMuted,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelBadge.copyWith(
                    fontSize: 8.5,
                    color: isSelected
                        ? AppColors.amberWarning
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostMortemListView(ArchetypeGuidance activeArch) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      children: [
        // Banner
        Container(
          padding: const EdgeInsets.all(AppDimens.space14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            border: Border.all(
              color: AppColors.amberWarning.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.psychology_alt_rounded,
                color: AppColors.amberWarning,
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NO SELF-FLAGELATION • ONLY COGNITIVE CALIBRATION',
                      style: AppTextStyles.labelBadge.copyWith(
                        fontSize: 8.5,
                        color: AppColors.amberWarning,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'A slip-up is data, not defeat. Extract the trigger, lower adrenaline, and lock in the correct verbal frame.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 60-Second Emergency Read Shortcut
        GestureDetector(
          onTap: () {
            HapticService.selectionClick();
            setState(() => _selectedRecoveryTab = 1);
          },
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              border: Border.all(color: AppColors.amberWarning.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded, size: 16, color: AppColors.amberWarning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Spike in adrenaline? Take a 60-second Stoic perspective read first.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.amberWarning,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.amberWarning),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

          // -----------------------------------------------------------
          // STEP 1: 30-SECOND POST-MORTEM
          // -----------------------------------------------------------
          Text(
            '1. 30-SECOND POST-MORTEM',
            style: AppTextStyles.labelBadge.copyWith(
              color: AppColors.shieldPrimary,
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 10),

          // Trigger
          _buildChipSection(
            label: 'THE AGITATOR / TRIGGER',
            options: _triggers,
            selectedValue: _selectedTrigger,
            onSelected: (val) => setState(() => _selectedTrigger = val),
          ),
          const SizedBox(height: 14),

          // Mistake Type
          _buildChipSection(
            label: 'MISTAKE TYPE (HOW YOU REACTED)',
            options: _mistakes,
            selectedValue: _selectedMistake,
            onSelected: (val) => setState(() => _selectedMistake = val),
          ),
          const SizedBox(height: 14),

          // Physical State
          _buildChipSection(
            label: 'PHYSICAL BODILY STATE',
            options: _physicalStates,
            selectedValue: _selectedPhysicalState,
            onSelected: (val) => setState(() => _selectedPhysicalState = val),
          ),
          const SizedBox(height: 24),

          // -----------------------------------------------------------
          // STEP 2: IDEAL INTELLECTUAL RESPONSE & ARCHETYPES
          // -----------------------------------------------------------
          Text(
            '2. IDEAL INTELLECTUAL RESPONSE & ARCHETYPES',
            style: AppTextStyles.labelBadge.copyWith(
              color: AppColors.shieldPrimary,
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How would a deeply grounded, high-intellect, stoic figure respond to this exact situation?',
            style: AppTextStyles.heading.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 10),

          // Archetype Selector Cards
          Row(
            children: List.generate(_archetypes.length, (idx) {
              final arch = _archetypes[idx];
              final isSelected = _selectedArchetypeIndex == idx;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: idx < _archetypes.length - 1 ? 8 : 0,
                  ),
                  child: InkWell(
                    onTap: () {
                      HapticService.selectionClick();
                      setState(() => _selectedArchetypeIndex = idx);
                      _applyArchetypeDoctrine(arch);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.surfaceElevated
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.shieldPrimary
                              : AppColors.borderSubtle,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            arch.icon,
                            size: 20,
                            color: isSelected
                                ? AppColors.shieldPrimary
                                : AppColors.textMuted,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            arch.title,
                            style: AppTextStyles.labelBadge.copyWith(
                              fontSize: 9.5,
                              color: isSelected
                                  ? AppColors.shieldPrimary
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            arch.subtitleHindi,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 9,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),

          // Active Archetype Doctrine Callout
          Container(
            padding: const EdgeInsets.all(AppDimens.space12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: AppColors.shieldPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${activeArch.title} Doctrine: ${activeArch.coreDoctrine}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Reflection Textarea
          TextField(
            controller: _reflectionController,
            maxLines: 3,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Analyze without ego: what was the high-intellect formulation?',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                borderSide: const BorderSide(color: AppColors.borderMedium),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                borderSide: const BorderSide(color: AppColors.borderMedium),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                borderSide: const BorderSide(
                  color: AppColors.shieldPrimary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // -----------------------------------------------------------
          // STEP 3: CORRECTIVE DRILLS
          // -----------------------------------------------------------
          Text(
            '3. CORRECTIVE DRILLS',
            style: AppTextStyles.labelBadge.copyWith(
              color: AppColors.shieldPrimary,
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 10),

          // Drill 1: 2-Minute Box Breathing Card
          Container(
            padding: const EdgeInsets.all(AppDimens.space14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              border: Border.all(
                color: _boxBreathingCompleted
                    ? AppColors.emeraldSuccess
                    : AppColors.borderMedium,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _boxBreathingCompleted
                        ? AppColors.emeraldSuccess.withOpacity(0.15)
                        : AppColors.surfaceElevated,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _boxBreathingCompleted
                        ? Icons.check_rounded
                        : Icons.air_rounded,
                    color: _boxBreathingCompleted
                        ? AppColors.emeraldSuccess
                        : AppColors.shieldPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2-MINUTE BOX BREATHING DRILL',
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 9.5,
                          color: _boxBreathingCompleted
                              ? AppColors.emeraldSuccess
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _boxBreathingCompleted
                            ? 'Physiological reset complete. Adrenaline lowered.'
                            : '4s Inhale • 4s Hold • 4s Exhale • 4s Hold',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _openBoxBreathingDrill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _boxBreathingCompleted
                        ? AppColors.surfaceElevated
                        : AppColors.shieldPrimary,
                    foregroundColor: _boxBreathingCompleted
                        ? AppColors.textPrimary
                        : AppColors.background,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    _boxBreathingCompleted ? 'RE-RUN' : 'START DRILL',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Drill 2: Re-Write Drill
          Text(
            'RE-WRITE DRILL (THE REVISED VERBATIM FORMULATION)',
            style: AppTextStyles.labelBadge.copyWith(fontSize: 9.5),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _rewriteController,
            maxLines: 2,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'What exact words will you deliver next time?',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                borderSide: const BorderSide(color: AppColors.borderMedium),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                borderSide: const BorderSide(color: AppColors.borderMedium),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                borderSide: const BorderSide(
                  color: AppColors.shieldPrimary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Drill 3: Damage Control Scripts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DAMAGE CONTROL SCRIPTS (OPTIONAL)',
                style: AppTextStyles.labelBadge.copyWith(fontSize: 9.5),
              ),
              Text(
                '1-TAP COPY',
                style: AppTextStyles.labelBadge.copyWith(
                  color: AppColors.shieldPrimary,
                  fontSize: 8.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...DamageControlCard.defaultScripts.map((sc) {
            return DamageControlCard(
              script: sc,
              isSelected: _selectedDamageControlScript == sc.verbatimScript,
              onSelect: () {
                HapticService.selectionClick();
                setState(() {
                  _selectedDamageControlScript = sc.verbatimScript;
                  _rewriteController.text = sc.verbatimScript;
                });
              },
            );
          }),
          const SizedBox(height: 24),

          // Commit Button
          ElevatedButton.icon(
            onPressed: _saveRecoveryLog,
            icon: const Icon(Icons.check_circle_rounded, size: 18),
            label: const Text('SAVE & RECLAIM COMPOSURE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.shieldPrimary,
              foregroundColor: AppColors.background,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      );
  }

  Widget _buildChipSection({
    required String label,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelBadge.copyWith(fontSize: 9)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.map((opt) {
            final isSelected = opt == selectedValue;
            return ChoiceChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  HapticService.selectionClick();
                  onSelected(opt);
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
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.shieldPrimary
                    : AppColors.textSecondary,
              ),
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // 60-Second Emergency Perspective Inline View
  // ---------------------------------------------------------
  Widget _buildEmergencyPerspectiveView() {
    final service = WisdomVaultService();
    var perspectives = service.getEmergencyPerspectives();
    if (perspectives.isEmpty) {
      perspectives = service.getAllEntries();
    }

    if (perspectives.isEmpty) {
      return const Center(child: Text('No emergency perspectives available'));
    }

    final safeIndex = _selectedPerspectiveIndex % perspectives.length;
    final activePerspective = perspectives[safeIndex];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Top 60-Sec Reset Header Banner
        Container(
          padding: const EdgeInsets.all(AppDimens.space14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            border: Border.all(color: AppColors.amberWarning.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.amberWarning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  color: AppColors.amberWarning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '60-SECOND EMERGENCY PERSPECTIVE',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.amberWarning,
                        fontSize: 8.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Detach your ego from praise and blame. Ground yourself in timeless stoic sovereignty before taking action.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Perspective Selection Chips
        Text(
          'SELECT EMERGENCY PROTOCOL',
          style: AppTextStyles.labelBadge.copyWith(fontSize: 9),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(perspectives.length, (index) {
              final item = perspectives[index];
              final isSelected = safeIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(item.title),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      HapticService.selectionClick();
                      setState(() {
                        _selectedPerspectiveIndex = index;
                      });
                    }
                  },
                  selectedColor: AppColors.amberWarning.withOpacity(0.15),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.amberWarning
                        : AppColors.borderSubtle,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.amberWarning
                        : AppColors.textSecondary,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),

        // Main Perspective Card
        Container(
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            border: Border.all(
              color: AppColors.amberWarning.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source & Category Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      activePerspective.categoryName.toUpperCase(),
                      style: AppTextStyles.labelBadge.copyWith(
                        fontSize: 8.5,
                        color: AppColors.shieldPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${safeIndex + 1} OF ${perspectives.length}',
                    style: AppTextStyles.metricSmall.copyWith(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title & Source
              Text(
                activePerspective.title,
                style: AppTextStyles.heading.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                activePerspective.source,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 12),

              // Quote Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.amberWarning.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  '"${activePerspective.originalText}"',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Translation
              Text(
                'ESSENCE / अनुवाद:',
                style: AppTextStyles.labelBadge.copyWith(
                  fontSize: 8.5,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                activePerspective.translation,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),

              // Executive Action Takeaway Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.shield_rounded,
                          size: 14,
                          color: AppColors.shieldPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'EXECUTIVE TAKEAWAY • EGO DETACHMENT',
                          style: AppTextStyles.labelBadge.copyWith(
                            color: AppColors.shieldPrimary,
                            fontSize: 8.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      activePerspective.executiveTakeaway,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.5,
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quick Action Buttons: Box Breathing & Return to Post-Mortem
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _openBoxBreathingDrill,
                icon: const Icon(Icons.air_rounded, size: 16),
                label: const Text('BOX BREATHING (2M)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.shieldPrimary,
                  side: const BorderSide(color: AppColors.shieldPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticService.selectionClick();
                  setState(() {
                    _selectedRecoveryTab = 0;
                  });
                },
                icon: const Icon(Icons.edit_note_rounded, size: 16),
                label: const Text('DAMAGE CONTROL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amberWarning,
                  foregroundColor: AppColors.background,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
