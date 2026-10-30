import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/defensive_scripts_vault.dart';
import '../widgets/breathing_pulse_visualizer.dart';
import '../widgets/defensive_script_edit_sheet.dart';
import '../widgets/response_script_card.dart';
import '../../../recovery/presentation/screens/post_incident_recovery_screen.dart';

/// Stage states of the Somatic 3-Second Neural Brake
enum SomaticPauseStage {
  idle,       // Large tactile button: "3-सेकंड ठहराव / Pause Now"
  countdown,  // Step 1: Tongue to palate banner + Step 2: Smooth 3s countdown with haptics
  completed,  // Step 3: Reveal core armor rule + Reset/Recovery actions
}

/// SOSScreen serves as Primary Tab 1 (ठहराव / SOS).
/// Features:
/// 1. Ultra-clean, serene, and distraction-free environment.
/// 2. Core Central Trigger: High-contrast circular button ("3-सेकंड ठहराव / Pause Now").
/// 3. Immediate 3-step somatic sequence:
///    - Step 1: Instruction banner ("जीभ को तालू से सटाएं और जबड़ा ढीला छोड़ें।")
///    - Step 2: Smooth 3-second animated countdown with subtle haptic ticks (Western Arabic numerals 3, 2, 1)
///    - Step 3: Core armor rule revelation ("प्रतिक्रिया देकर अपनी शक्ति मत गंवाओ। मौन ही तुम्हारा नियंत्रण है।")
/// 4. Secondary Quick Tool: Box-Breathing (4-4-4-4) circle guide for physical de-escalation.
/// 5. Collapsible / quick-access tactical defensive scripts and incident slip-up logging.
class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> with TickerProviderStateMixin {
  final HiveStorage _storage = HiveStorage();
  final TextEditingController _searchController = TextEditingController();

  // Somatic Pause Stage & Controllers
  SomaticPauseStage _pauseStage = SomaticPauseStage.idle;
  late AnimationController _ambientPulseController;
  late Animation<double> _ambientScaleAnimation;

  late AnimationController _countdownController;
  int _remainingCountdown = 3;
  Timer? _countdownTimer;

  // Defensive Scripts State
  String _selectedCategory = 'All';
  List<DefensiveScript> _allScripts = [];
  List<String> _pinnedScriptIds = [];

  @override
  void initState() {
    super.initState();

    // 1. Gentle ambient breathing glow for the idle circular button
    _ambientPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _ambientScaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _ambientPulseController, curve: Curves.easeInOut),
    );

    // 2. Exact 3-second progress controller for countdown
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _loadData();
  }

  void _loadData() {
    _allScripts = _storage.getAllDefensiveScripts();
    _pinnedScriptIds = _storage.getPinnedScriptIds();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _ambientPulseController.dispose();
    _countdownController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Trigger the 3-second emergency somatic brake (<50ms zero-lag response)
  void _triggerSomaticBrake() {
    if (_pauseStage == SomaticPauseStage.countdown) return;

    // Instant heavy tactile feedback
    HapticService.heavyImpact();

    setState(() {
      _pauseStage = SomaticPauseStage.countdown;
      _remainingCountdown = 3;
    });

    _countdownController.reset();
    _countdownController.forward();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingCountdown > 1) {
        setState(() {
          _remainingCountdown--;
        });
        // Subtle haptic tick for each passing second
        HapticService.selectionClick();
      } else {
        timer.cancel();
        // Solid haptic landing pulse on completion
        HapticService.heavyImpact();
        setState(() {
          _pauseStage = SomaticPauseStage.completed;
          _remainingCountdown = 0;
        });
      }
    });
  }

  /// Reset the somatic pause to idle state
  void _resetSomaticBrake() {
    HapticService.selectionClick();
    _countdownTimer?.cancel();
    _countdownController.reset();
    setState(() {
      _pauseStage = SomaticPauseStage.idle;
      _remainingCountdown = 3;
    });
  }

  void _openSlipUpRecovery() {
    HapticService.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PostIncidentRecoveryScreen(),
      ),
    );
  }

  void _openAddScriptSheet() {
    HapticService.selectionClick();
    DefensiveScriptEditSheet.show(
      context,
      onSaved: () => _loadData(),
    );
  }

  void _openEditScriptSheet(DefensiveScript script) {
    HapticService.selectionClick();
    DefensiveScriptEditSheet.show(
      context,
      script: script,
      onSaved: () => _loadData(),
    );
  }

  Future<void> _deleteScript(String id) async {
    HapticService.selectionClick();
    await _storage.deleteDefensiveScript(id);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.loc.scriptRemovedNotice, style: const TextStyle(fontSize: 12)),
          backgroundColor: AppColors.surfaceElevated,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  List<DefensiveScript> _getFilteredScripts() {
    final query = _searchController.text.trim().toLowerCase();

    return _allScripts.where((script) {
      final matchesCategory = _selectedCategory == 'All' ||
          (_selectedCategory == 'Pinned'
              ? _pinnedScriptIds.contains(script.id)
              : script.category.toLowerCase() == _selectedCategory.toLowerCase());

      final matchesSearch = query.isEmpty ||
          script.hostileTrigger.toLowerCase().contains(query) ||
          script.scenario.toLowerCase().contains(query) ||
          script.executiveScript.toLowerCase().contains(query) ||
          script.tacticalRationale.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = context.loc.isHindi;
    final filteredScripts = _getFilteredScripts();
    final categories = [
      'All',
      if (_pinnedScriptIds.isNotEmpty) 'Pinned',
      ...DefensiveScriptsVault.getCategories(_allScripts).where((c) => c != 'All'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space16,
            vertical: AppDimens.space16,
          ),
          children: [
            // 1. Serene Minimalist Header
            _buildScreenHeader(isHindi),
            const SizedBox(height: 18),

            // 2. Core Central Trigger: 3-Second Somatic Pause
            _buildCentralSomaticBrakeTrigger(isHindi),
            const SizedBox(height: 24),

            // 3. Secondary Quick Tool: Box-Breathing (4-4-4-4) Circle Guide
            _buildBoxBreathingSection(isHindi),
            const SizedBox(height: 24),

            // 4. Tactical Defensive Scripts Section
            _buildDefensiveScriptsSection(isHindi, categories, filteredScripts),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Serene Minimalist Header
  // ---------------------------------------------------------------------------
  Widget _buildScreenHeader(bool isHindi) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.loc.somaticPauseHeader,
                style: AppTextStyles.labelBadge.copyWith(
                  color: AppColors.roseDanger,
                  letterSpacing: 2.0,
                  fontSize: 9.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                context.loc.somaticScreenTitle,
                style: AppTextStyles.displayMedium.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                context.loc.somaticPauseSubtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Recovery Shortcut Badge Button
        InkWell(
          onTap: _openSlipUpRecovery,
          borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              border: Border.all(
                color: AppColors.amberWarning.withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.restart_alt_rounded, size: 14, color: AppColors.amberWarning),
                const SizedBox(width: 4),
                Text(
                  context.loc.slipUpResetBadge,
                  style: AppTextStyles.labelBadge.copyWith(
                    color: AppColors.amberWarning,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Core Central Trigger: 3-Second Somatic Pause
  // ---------------------------------------------------------------------------
  Widget _buildCentralSomaticBrakeTrigger(bool isHindi) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        border: Border.all(
          color: _pauseStage == SomaticPauseStage.completed
              ? AppColors.emeraldSuccess.withValues(alpha: 0.6)
              : AppColors.roseDanger.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _pauseStage == SomaticPauseStage.completed
                ? AppColors.emeraldSuccess.withValues(alpha: 0.12)
                : AppColors.roseDanger.withValues(alpha: 0.10),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Step 1: Immediate Instruction Banner (Visible during countdown & completed)
          if (_pauseStage == SomaticPauseStage.countdown) ...[
            _buildStep1InstructionBanner(isHindi),
            const SizedBox(height: 20),
          ],

          // Step 3: Core Armor Rule Banner (Visible when completed)
          if (_pauseStage == SomaticPauseStage.completed) ...[
            _buildStep3CoreArmorCard(isHindi),
            const SizedBox(height: 20),
          ],

          // Central Tactile Circular Button / Countdown Visualizer
          Center(
            child: _buildTactileCircularButton(isHindi),
          ),

          const SizedBox(height: 14),

          // Subtext Guidance / Action Buttons
          if (_pauseStage == SomaticPauseStage.idle)
            Text(
              context.loc.somaticIdleGuidance,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            )
          else if (_pauseStage == SomaticPauseStage.countdown)
            Text(
              context.loc.somaticCountdownStayStill,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.roseDanger,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            )
          else if (_pauseStage == SomaticPauseStage.completed) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _resetSomaticBrake,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    context.loc.somaticResetButton,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _openSlipUpRecovery,
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  label: Text(
                    context.loc.logIncidentAction,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceElevated,
                    foregroundColor: AppColors.amberWarning,
                    side: BorderSide(color: AppColors.amberWarning.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Step 1: Instruction Banner
  Widget _buildStep1InstructionBanner(bool isHindi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1115),
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: AppColors.roseDanger.withValues(alpha: 0.7),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.roseDanger.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.self_improvement_rounded,
              color: AppColors.roseDanger,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.loc.somaticInstructionBanner,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.loc.somaticInstructionSub,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.roseDanger.withValues(alpha: 0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Step 3: Core Armor Rule Card
  Widget _buildStep3CoreArmorCard(bool isHindi) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: AppColors.shieldPrimary,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shieldPrimary.withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.shieldPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  context.loc.coreArmorRuleHeader,
                  style: AppTextStyles.labelBadge.copyWith(
                    color: AppColors.shieldPrimary,
                    fontSize: 9.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.verified_user_rounded,
                size: 16,
                color: AppColors.emeraldSuccess,
              ),
              const SizedBox(width: 4),
              Text(
                context.loc.somaticAnchoredBadge,
                style: AppTextStyles.labelBadge.copyWith(
                  color: AppColors.emeraldSuccess,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            context.loc.coreArmorRuleText,
            style: AppTextStyles.heading.copyWith(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.loc.coreArmorRuleSubText,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 14, color: AppColors.shieldPrimary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context.loc.coreArmorRuleSub,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.shieldPrimary,
                      fontSize: 11,
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

  // Central Circular Tactile Button / Countdown
  Widget _buildTactileCircularButton(bool isHindi) {
    const double circleSize = 184.0;

    if (_pauseStage == SomaticPauseStage.countdown) {
      // Step 2: Clear, smooth 3-second animated countdown
      return AnimatedBuilder(
        animation: _countdownController,
        builder: (context, child) {
          final progress = _countdownController.value;

          return SizedBox(
            width: circleSize,
            height: circleSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Circular Progress Track
                SizedBox(
                  width: circleSize,
                  height: circleSize,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6.0,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.roseDanger),
                    backgroundColor: AppColors.surfaceElevated,
                  ),
                ),
                // Center Countdown Circle
                Container(
                  width: circleSize - 16,
                  height: circleSize - 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF190F13),
                    border: Border.all(
                      color: AppColors.roseDanger.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_remainingCountdown',
                        style: const TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontFamily: 'Noto Sans Devanagari',
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.loc.secondsRemaining,
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.roseDanger,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    if (_pauseStage == SomaticPauseStage.completed) {
      // Completed Anchored Seal
      return Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceElevated,
          border: Border.all(
            color: AppColors.emeraldSuccess,
            width: 3.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.emeraldSuccess.withValues(alpha: 0.25),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified_user_rounded,
              size: 44,
              color: AppColors.emeraldSuccess,
            ),
            const SizedBox(height: 6),
            Text(
              context.loc.somaticAnchoredBadge,
              style: AppTextStyles.labelBadge.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.emeraldSuccess,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      );
    }

    // Idle State: Large tactile circular button ("3-सेकंड ठहराव / Pause Now")
    return AnimatedBuilder(
      animation: _ambientScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _ambientScaleAnimation.value,
          child: GestureDetector(
            onTap: _triggerSomaticBrake,
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF261318),
                    Color(0xFF13090C),
                  ],
                ),
                border: Border.all(
                  color: AppColors.roseDanger,
                  width: 3.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.roseDanger.withValues(alpha: 0.28),
                    blurRadius: 28,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.roseDanger.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pause_rounded,
                      color: AppColors.roseDanger,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.loc.threeSecondPause,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Noto Sans Devanagari',
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    context.loc.pauseNowAction,
                    style: AppTextStyles.labelBadge.copyWith(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.roseDanger,
                      letterSpacing: 1.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Secondary Quick Tool: Box-Breathing (4-4-4-4) Circle Guide
  // ---------------------------------------------------------------------------
  Widget _buildBoxBreathingSection(bool isHindi) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.shieldPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.air_rounded,
                      size: 16,
                      color: AppColors.shieldPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.loc.boxBreathingSectionTitle,
                    style: AppTextStyles.heading.copyWith(fontSize: 14.5),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.shieldPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '4-4-4-4',
                  style: AppTextStyles.labelBadge.copyWith(
                    color: AppColors.shieldPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.loc.boxBreathingSectionSubtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 16),

          // Visualizer Container (Hosts upgraded 4-4-4-4 box breathing visualizer)
          Container(
            height: 240,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF070B12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: const BreathingPulseVisualizer(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Tactical Defensive Response Scripts Section
  // ---------------------------------------------------------------------------
  Widget _buildDefensiveScriptsSection(
    bool isHindi,
    List<String> categories,
    List<DefensiveScript> scripts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.loc.defensiveScriptsSectionTitle,
                  style: AppTextStyles.labelBadge.copyWith(
                    color: AppColors.shieldPrimary,
                    fontSize: 9.0,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.loc.calmResponseProtocols,
                  style: AppTextStyles.heading.copyWith(fontSize: 16),
                ),
              ],
            ),
            IconButton(
              onPressed: _openAddScriptSheet,
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.shieldPrimary,
                size: 22,
              ),
              tooltip: context.loc.addCustomScriptTooltip,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Search Bar
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: context.loc.searchDefensiveScriptsHint,
            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 16),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () {
                    HapticService.selectionClick();
                    setState(() => _selectedCategory = cat);
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
                      context.loc.getDefensiveCategoryName(cat).toUpperCase(),
                      style: AppTextStyles.labelBadge.copyWith(
                        fontSize: 9.0,
                        color: isSelected ? AppColors.shieldPrimary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Scripts List
        if (scripts.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppDimens.space24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                const Icon(Icons.search_off_rounded, size: 28, color: AppColors.textMuted),
                const SizedBox(height: 6),
                Text(
                  context.loc.noScriptsFound,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: scripts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final script = scripts[index];
              final isBookmarked = _pinnedScriptIds.contains(script.id);

              return ResponseScriptCard(
                script: script,
                isBookmarked: isBookmarked,
                onToggleBookmark: () async {
                  await _storage.togglePinnedScript(script.id);
                  _loadData();
                },
                onEdit: () => _openEditScriptSheet(script),
                onDelete: script.isCustom ? () => _deleteScript(script.id) : null,
              );
            },
          ),
      ],
    );
  }
}
