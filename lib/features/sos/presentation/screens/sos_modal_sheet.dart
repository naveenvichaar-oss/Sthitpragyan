import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/defensive_scripts_vault.dart';
import '../widgets/defensive_script_edit_sheet.dart';
import '../../../journal/data/models/journal_models.dart';

/// The 4 states of the SOS Finite State Machine (FSM)
enum SOSState {
  grounding, // STATE 1: Tactile Grounding (0.0s - 0.5s)
  countdown, // STATE 2: 3-Second Mandatory Lock (0.5s - 3.5s)
  carousel, // STATE 3: Defensive Scripts Active (Indefinite)
  exitLog, // STATE 4: Exit & Incident Logged
}

/// SOSModalSheet implements the complete SOS Screen UI State-Flow & Logic Architecture.
class SOSModalSheet extends StatefulWidget {
  const SOSModalSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticService.heavyImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false, // Drag disabled during initial mandatory lock
      backgroundColor: const Color(0xFF090D16),
      builder: (context) => const SOSModalSheet(),
    );
  }

  @override
  State<SOSModalSheet> createState() => _SOSModalSheetState();
}

class _SOSModalSheetState extends State<SOSModalSheet>
    with TickerProviderStateMixin {
  SOSState _currentState = SOSState.grounding;

  // State 2 Countdown & Pulse Controllers
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _pulseScaleAnimation;

  int _countdownSeconds = 3;
  Timer? _countdownTimer;

  // State 3 Carousel state
  String _selectedCategory = 'All';
  int _activeScriptIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.92);

  late final HiveStorage _storage;
  List<String> _pinnedScriptIds = [];

  @override
  void initState() {
    super.initState();
    _storage = HiveStorage();
    if (_storage.isInitialized) {
      _pinnedScriptIds = _storage.getPinnedScriptIds();
    }

    // 3-second mandatory lock progress controller (runs 0.0 -> 1.0 in 3000ms)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Pulse breathing animation for the circle
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseScaleAnimation = Tween<double>(begin: 0.88, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);

    // Kick off FSM
    _startFSMWorkflow();
  }

  void _startFSMWorkflow() {
    // STATE 1: Immediate Tactile Grounding (0.0s - 0.5s)
    HapticService.heavyImpact();

    // Transition from State 1 to State 2 after 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _currentState = SOSState.countdown;
      });

      // Start 3-second circular progress & countdown
      _progressController.forward();

      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        if (_countdownSeconds > 1) {
          setState(() {
            _countdownSeconds--;
          });
          HapticService.breathingStepPulse();
        } else {
          timer.cancel();
          _transitionToCarousel();
        }
      });
    });
  }

  void _transitionToCarousel() {
    HapticService.heavyImpact();
    if (!mounted) return;

    setState(() {
      _currentState = SOSState.carousel;
      _countdownSeconds = 0;
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleCopyScript(String text) async {
    HapticService.lightImpact();
    await Clipboard.setData(ClipboardData(text: text));

    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Script copied to clipboard: "$text"',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.background,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: AppColors.textPrimary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _handleHandledNeutral(DefensiveScript script) async {
    HapticService.heavyImpact();

    // Log incident to Hive for the evening review
    if (_storage.isInitialized) {
      final now = DateTime.now();
      final incident = SosIncidentLog(
        id: 'sos_${now.millisecondsSinceEpoch}',
        timestamp: now,
        threatType: script.category,
        scriptSelected: script.executiveScript,
        lockCompleted: true,
        outcomeRating: 5,
      );
      await _storage.saveSosIncidentLog(incident);
    }

    if (mounted) {
      setState(() {
        _currentState = SOSState.exitLog;
      });

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
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
              Text(
                'Incident Handled • Logged to evening review',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.background,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.textPrimary,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  void _openScriptEditor(DefensiveScript? script) {
    HapticService.selectionClick();
    DefensiveScriptEditSheet.show(
      context,
      script: script,
      initialCategory: _selectedCategory,
      onSaved: () {
        setState(() {});
      },
    );
  }

  Future<void> _confirmDeleteScript(DefensiveScript script) async {
    HapticService.selectionClick();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: Text(
          context.loc.deleteScript,
          style: AppTextStyles.heading.copyWith(fontSize: 16),
        ),
        content: Text(
          context.loc.confirmDeleteScriptMsg,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              context.loc.cancel,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.roseDanger,
              foregroundColor: Colors.white,
            ),
            child: Text(context.loc.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.deleteDefensiveScript(script.id);
      HapticService.selectionClick();
      if (mounted) {
        setState(() {
          _activeScriptIndex = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.loc.scriptDeletedMsg,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.background),
            ),
            backgroundColor: AppColors.roseDanger,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _confirmResetScripts() async {
    HapticService.selectionClick();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: Text(
          context.loc.resetToDefaultScripts,
          style: AppTextStyles.heading.copyWith(fontSize: 16),
        ),
        content: Text(
          context.loc.confirmResetAllScriptsMsg,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.loc.cancel, style: const TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amberWarning,
              foregroundColor: Colors.black,
            ),
            child: Text(context.loc.reset),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.resetDefensiveScriptsToDefault();
      HapticService.selectionClick();
      if (mounted) {
        setState(() {
          _activeScriptIndex = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.loc.allScriptsResetMsg,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.background),
            ),
            backgroundColor: AppColors.shieldPrimary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Strict dismissal lock during State 1 and State 2
    final canPop =
        _currentState == SOSState.carousel || _currentState == SOSState.exitLog;
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: canPop,
      child: Container(
        height: size.height * 0.94,
        decoration: const BoxDecoration(
          color: Color(0xFF090D16), // Deep Slate / Pitch Black 95% opacity
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

            // Top Status Bar
            _buildTopBar(canPop),
            const Divider(color: AppColors.borderSubtle),

            // FSM State-Driven Body
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStateContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool canPop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: canPop
                      ? AppColors.shieldPrimary
                      : AppColors.amberWarning,
                  boxShadow: [
                    BoxShadow(
                      color: canPop
                          ? AppColors.shieldGlow
                          : AppColors.amberWarning.withValues(alpha: 0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                canPop
                    ? 'SHIELD ACTIVE • EQUANIMITY'
                    : 'DEFENSIVE LOCK ENGAGED',
                style: AppTextStyles.brandHeader.copyWith(
                  color: canPop
                      ? AppColors.textPrimary
                      : AppColors.amberWarning,
                  letterSpacing: 2.2,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (canPop)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _openScriptEditor(null),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  color: AppColors.shieldPrimary,
                  splashRadius: 20,
                  tooltip: context.loc.addDefensiveScript,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  color: AppColors.surfaceElevated,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    side: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  onSelected: (val) {
                    if (val == 'reset') {
                      _confirmResetScripts();
                    } else if (val == 'add') {
                      _openScriptEditor(null);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'add',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add_moderator_rounded,
                            size: 16,
                            color: AppColors.shieldPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.loc.addDefensiveScript,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'reset',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.restore_rounded,
                            size: 16,
                            color: AppColors.amberWarning,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.loc.resetToDefaultScripts,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
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
                  tooltip: 'Close Shield',
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.amberWarning.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    size: 11,
                    color: AppColors.amberWarning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'LOCKED (${_countdownSeconds}s)',
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.amberWarning,
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStateContent() {
    switch (_currentState) {
      case SOSState.grounding:
        return _buildState1Grounding();
      case SOSState.countdown:
        return _buildState2CountdownLock();
      case SOSState.carousel:
      case SOSState.exitLog:
        return _buildState3ScriptsCarousel();
    }
  }

  // ---------------------------------------------------------------------------
  // STATE 1: TACTILE GROUNDING (0.0s - 0.5s)
  // ---------------------------------------------------------------------------
  Widget _buildState1Grounding() {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.amberMuted,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.amberWarning.withValues(alpha: 0.6),
              ),
            ),
            child: Text(
              'Tongue to roof of mouth | Feet on ground',
              style: AppTextStyles.labelBadge.copyWith(
                color: AppColors.amberWarning,
                letterSpacing: 1.5,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.space32),
          Text(
            context.loc.looseTeethInstruction,
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.space24),
          Text(
            'Vagus nerve activation: Halting amygdala fight-or-flight cascade...',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STATE 2: THE 3-SECOND MANDATORY LOCK (0.5s - 3.5s)
  // ---------------------------------------------------------------------------
  Widget _buildState2CountdownLock() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Body Anchor Reminder Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderMedium),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.accessibility_new_rounded,
                  size: 16,
                  color: AppColors.shieldPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.loc.looseTeethInstruction,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Minimalist Circular 3-Second SVG / CustomPaint Progress Indicator
          SizedBox(
            width: 220,
            height: 220,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _progressController,
                _pulseController,
              ]),
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Concentric Pulse Circle
                    Transform.scale(
                      scale: _pulseScaleAnimation.value,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.shieldPrimary.withValues(alpha: 0.06),
                          border: Border.all(
                            color: AppColors.shieldPrimary.withValues(alpha: 0.2),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),

                    // Custom Circular Progress Ring (0 to 360 degrees)
                    CustomPaint(
                      size: const Size(200, 200),
                      painter: _CircularCountdownPainter(
                        progress: _progressController.value,
                        trackColor: AppColors.borderSubtle,
                        progressColor: AppColors.shieldPrimary,
                      ),
                    ),

                    // Center Countdown Digit & Status
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_countdownSeconds',
                          style: AppTextStyles.metricLarge.copyWith(
                            fontSize: 54,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'MANDATORY LOCK',
                          style: AppTextStyles.labelBadge.copyWith(
                            color: AppColors.amberWarning,
                            fontSize: 9.0,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 32),

          // Observational Directive
          Text(
            'Do not speak. Observing...',
            style: AppTextStyles.heading.copyWith(
              color: AppColors.shieldPrimary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.loc.observeToneInstruction,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),

          // Lockdown Notice
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                'NEURO-GROUNDING IN PROGRESS: BACK GESTURE DISABLED',
                style: AppTextStyles.labelBadge.copyWith(
                  fontSize: 9.0,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STATE 3: DEFENSIVE SCRIPTS ACTIVE (Indefinite)
  // ---------------------------------------------------------------------------
  Widget _buildState3ScriptsCarousel() {
    final allScripts = _storage.getAllDefensiveScripts();
    final List<String> availableCategories = [
      'All',
      if (_pinnedScriptIds.isNotEmpty) 'Pinned',
      ...DefensiveScriptsVault.getCategories(allScripts).where((c) => c != 'All'),
    ];

    final List<DefensiveScript> scripts;
    if (_selectedCategory == 'Pinned') {
      scripts = allScripts
          .where((s) => _pinnedScriptIds.contains(s.id))
          .toList();
    } else {
      scripts =
          DefensiveScriptsVault.getByCategory(_selectedCategory, allScripts);
    }

    if (_activeScriptIndex >= scripts.length && scripts.isNotEmpty) {
      _activeScriptIndex = scripts.length - 1;
    }

    return Column(
      children: [
        // Category Selector Chips & + Add Script Chip
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: availableCategories.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == availableCategories.length) {
                  return ActionChip(
                    avatar: const Icon(
                      Icons.add_rounded,
                      size: 14,
                      color: AppColors.shieldPrimary,
                    ),
                    label: Text(
                      context.loc.addScriptAction,
                    ),
                    onPressed: () => _openScriptEditor(null),
                    backgroundColor: AppColors.surfaceElevated,
                    side: const BorderSide(
                      color: AppColors.shieldPrimary,
                      width: 1.0,
                    ),
                    labelStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.shieldPrimary,
                    ),
                    visualDensity: VisualDensity.compact,
                  );
                }

                final cat = availableCategories[index];
                final isSelected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      HapticService.selectionClick();
                      setState(() {
                        _selectedCategory = cat;
                        _activeScriptIndex = 0;
                      });
                      if (_pageController.hasClients) {
                        _pageController.jumpToPage(0);
                      }
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
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.shieldPrimary
                        : AppColors.textSecondary,
                  ),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
        ),

        // Carousel of Response Cards or Empty State
        if (scripts.isEmpty)
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.loc.noScriptsInCategory,
                      style: AppTextStyles.heading.copyWith(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.loc.tapToAddScriptHint,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _openScriptEditor(null),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: Text(context.loc.addDefensiveScript),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.shieldPrimary,
                            foregroundColor: AppColors.background,
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _confirmResetScripts,
                          icon: const Icon(Icons.restore_rounded, size: 16),
                          label: Text(context.loc.resetToDefaultScripts),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side:
                                const BorderSide(color: AppColors.borderMedium),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          // Carousel of Response Cards
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: scripts.length,
              onPageChanged: (idx) {
                HapticService.lightImpact();
                setState(() => _activeScriptIndex = idx);
              },
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final script = scripts[index];
                return _buildExecutiveScriptCard(script);
              },
            ),
          ),

          // Pagination Dots & Navigation Prompt
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SCRIPT ${_activeScriptIndex + 1} OF ${scripts.length}',
                  style: AppTextStyles.labelBadge.copyWith(fontSize: 9.5),
                ),
                Row(
                  children: List.generate(
                    math.min(scripts.length, 6),
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      width: _activeScriptIndex == i ? 16 : 5,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _activeScriptIndex == i
                            ? AppColors.shieldPrimary
                            : AppColors.borderMedium,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                Text(
                  'SWIPE FOR MORE →',
                  style: AppTextStyles.labelBadge.copyWith(
                    fontSize: 9.5,
                    color: AppColors.shieldPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExecutiveScriptCard(DefensiveScript script) {
    return Container(
      margin: const EdgeInsets.fromLTRB(6, 6, 6, 8),
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        border: Border.all(color: AppColors.borderMedium, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Tag & Tone
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
                  script.category.toUpperCase(),
                  style: AppTextStyles.labelBadge.copyWith(
                    color: AppColors.shieldPrimary,
                    fontSize: 9.5,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.record_voice_over_rounded,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      script.toneGuidance,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 10.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => _openScriptEditor(script),
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.all(3.0),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _confirmDeleteScript(script),
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.all(3.0),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: AppColors.roseDanger,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () async {
                      if (_storage.isInitialized) {
                        await _storage.togglePinnedScript(script.id);
                        setState(() {
                          _pinnedScriptIds = _storage.getPinnedScriptIds();
                        });
                        HapticService.selectionClick();
                      }
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Icon(
                        _pinnedScriptIds.contains(script.id)
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        size: 16,
                        color: _pinnedScriptIds.contains(script.id)
                            ? AppColors.shieldPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Hostile Trigger
          Text(
            'HOSTILE TRIGGER',
            style: AppTextStyles.labelBadge.copyWith(
              color: AppColors.roseDanger,
              fontSize: 9.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            script.hostileTrigger,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // Primary Verbatim Rebuttal Script
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimens.space14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                border: Border.all(
                  color: AppColors.shieldPrimary.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              child: SingleChildScrollView(
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
                          'DEFENSIVE RESPONSE SCRIPT',
                          style: AppTextStyles.labelBadge.copyWith(
                            color: AppColors.shieldPrimary,
                            fontSize: 9.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '"${script.executiveScript}"',
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 17,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // High-Contrast Crisp Subtext Block
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.borderSubtle,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.psychology_outlined,
                              size: 14,
                              color: AppColors.shieldPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'SUBTEXT: ',
                                    style: AppTextStyles.labelBadge.copyWith(
                                      color: AppColors.shieldPrimary,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: script.tacticalRationale,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w400,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons: [Copy Text] and [Handled (Neutral)]
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleCopyScript(script.executiveScript),
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: Text(context.loc.copyTextAction),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderMedium),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimens.radiusSmall,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleHandledNeutral(script),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text(context.loc.handledNeutralAction),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: AppColors.background,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimens.radiusSmall,
                      ),
                    ),
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

/// CustomPainter that renders a smooth 360-degree countdown ring
class _CircularCountdownPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color trackColor;
  final Color progressColor;

  _CircularCountdownPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc running clockwise from top (-pi / 2)
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularCountdownPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
