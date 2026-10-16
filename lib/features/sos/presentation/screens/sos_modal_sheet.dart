import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/defensive_scripts_vault.dart';
import '../../journal/data/models/journal_models.dart';

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
                          : AppColors.amberWarning.withOpacity(0.5),
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
            IconButton(
              onPressed: () {
                HapticService.lightImpact();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close_rounded, size: 22),
              color: AppColors.textSecondary,
              splashRadius: 20,
              tooltip: 'Close Shield',
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.amberWarning.withOpacity(0.4),
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
                color: AppColors.amberWarning.withOpacity(0.6),
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
            'दाँत ढीले रखें। जीभ तालू से सटाएं। पैर जमीन पर।',
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
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
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
                  'दाँत ढीले रखें • जीभ तालू से सटाएं • पैर जमीन पर',
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
                          color: AppColors.shieldPrimary.withOpacity(0.06),
                          border: Border.all(
                            color: AppColors.shieldPrimary.withOpacity(0.2),
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
            'सामने वाले की टोन और आंखों का विचलन केवल देखें।',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              fontSize: 14.5,
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
    final scripts = DefensiveScriptsVault.getByCategory(_selectedCategory);

    return Column(
      children: [
        // Category Selector Chips
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: DefensiveScriptsVault.categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
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
                  Text(
                    script.toneGuidance,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10.5,
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
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
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
                  color: AppColors.shieldPrimary.withOpacity(0.4),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(height: 8),
                  Text(
                    '"${script.executiveScript}"',
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 17,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Subtext: ${script.tacticalRationale}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
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
                  label: const Text('COPY TEXT'),
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
                  label: const Text('HANDLED (NEUTRAL)'),
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
