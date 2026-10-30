import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';

enum BreathingPhase { inhale, holdFull, exhale, holdEmpty }

/// BreathingPulseVisualizer runs an authentic 4-4-4-4 Box Breathing somatic cycle
/// (4s Inhale -> 4s Hold Full -> 4s Exhale -> 4s Hold Empty = 16s total)
/// with expanding and contracting concentric rings and haptic pulses.
class BreathingPulseVisualizer extends StatefulWidget {
  const BreathingPulseVisualizer({super.key});

  @override
  State<BreathingPulseVisualizer> createState() =>
      _BreathingPulseVisualizerState();
}

class _BreathingPulseVisualizerState extends State<BreathingPulseVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  BreathingPhase _currentPhase = BreathingPhase.inhale;
  int _secondsGrounded = 0;
  Timer? _groundedTimer;

  @override
  void initState() {
    super.initState();

    // 4-4-4-4 Box Breathing: 4s per phase = 16,000ms total
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16000),
    );

    _scaleAnimation = TweenSequence<double>([
      // Phase 1 (0.00 -> 0.25): Inhale (Expand from 0.65 to 1.0)
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.65,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25.0,
      ),
      // Phase 2 (0.25 -> 0.50): Hold Full (Stay at 1.0)
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 25.0),
      // Phase 3 (0.50 -> 0.75): Exhale (Contract from 1.0 to 0.65)
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.65,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25.0,
      ),
      // Phase 4 (0.75 -> 1.00): Hold Empty (Stay at 0.65)
      TweenSequenceItem(tween: ConstantTween<double>(0.65), weight: 25.0),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      // Inhale
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.3,
          end: 0.9,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25.0,
      ),
      // Hold Full
      TweenSequenceItem(tween: ConstantTween<double>(0.9), weight: 25.0),
      // Exhale
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.9,
          end: 0.3,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25.0,
      ),
      // Hold Empty
      TweenSequenceItem(tween: ConstantTween<double>(0.35), weight: 25.0),
    ]).animate(_controller);

    _controller.addListener(_handleAnimationProgress);
    _controller.repeat();

    _groundedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsGrounded++;
        });
      }
    });

    // Initial haptic trigger
    HapticService.breathingStepPulse();
  }

  void _handleAnimationProgress() {
    final val = _controller.value;
    BreathingPhase nextPhase;

    if (val < 0.25) {
      nextPhase = BreathingPhase.inhale;
    } else if (val < 0.50) {
      nextPhase = BreathingPhase.holdFull;
    } else if (val < 0.75) {
      nextPhase = BreathingPhase.exhale;
    } else {
      nextPhase = BreathingPhase.holdEmpty;
    }

    if (nextPhase != _currentPhase) {
      setState(() {
        _currentPhase = nextPhase;
      });
      // Fire tactile haptic pulse at every phase change
      HapticService.breathingStepPulse();
    }
  }

  @override
  void dispose() {
    _groundedTimer?.cancel();
    _controller.removeListener(_handleAnimationProgress);
    _controller.dispose();
    super.dispose();
  }

  String _getPhaseTitle(BuildContext context) {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return context.loc.boxBreathInhaleVisual;
      case BreathingPhase.holdFull:
        return context.loc.boxBreathHoldFullVisual;
      case BreathingPhase.exhale:
        return context.loc.boxBreathExhaleVisual;
      case BreathingPhase.holdEmpty:
        return context.loc.boxBreathHoldEmptyVisual;
    }
  }

  String _getPhaseSubtitle(BuildContext context) {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return context.loc.breathNavelExpand;
      case BreathingPhase.holdFull:
        return context.loc.boxBreathingHoldFullGuidance;
      case BreathingPhase.exhale:
        return context.loc.boxBreathingExhaleGuidance;
      case BreathingPhase.holdEmpty:
        return context.loc.boxBreathingHoldEmptyGuidance;
    }
  }

  Color get _phaseAccent {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return AppColors.shieldPrimary;
      case BreathingPhase.holdFull:
        return const Color(0xFF818CF8); // Indigo / composure
      case BreathingPhase.exhale:
        return AppColors.emeraldSuccess;
      case BreathingPhase.holdEmpty:
        return const Color(0xFFF59E0B); // Amber / still awareness
    }
  }

  int get _secondsLeftInPhase {
    final val = _controller.value;
    final phaseProgress = (val % 0.25) / 0.25;
    final remaining = 4 - (phaseProgress * 4).floor();
    return remaining.clamp(1, 4);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: AppDimens.space20,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          // Top Status Bar: Seconds Grounded
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _phaseAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.loc.parasympatheticPacerBadge,
                    style: AppTextStyles.labelBadge.copyWith(fontSize: 9.5),
                  ),
                ],
              ),
              Text(
                context.loc.secondsGroundedLabel(_secondsGrounded),
                style: AppTextStyles.metricSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space24),

          // Central Breathing Circle
          SizedBox(
            height: 180,
            width: 180,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final scale = _scaleAnimation.value;
                final opacity = _opacityAnimation.value;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Ring
                    Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _phaseAccent.withValues(alpha: (opacity * 0.12).clamp(0.0, 1.0)),
                          border: Border.all(
                            color: _phaseAccent.withValues(alpha: (opacity * 0.4).clamp(0.0, 1.0)),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Middle Concentric Ring
                    Transform.scale(
                      scale: 0.75 + (scale - 0.65) * 0.6,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _phaseAccent.withValues(alpha: (opacity * 0.2).clamp(0.0, 1.0)),
                          border: Border.all(
                            color: _phaseAccent.withValues(alpha: (opacity * 0.6).clamp(0.0, 1.0)),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Core Orb
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceElevated,
                        border: Border.all(color: _phaseAccent, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: _phaseAccent.withValues(alpha: 0.4),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              (_currentPhase == BreathingPhase.holdFull)
                                  ? Icons.lock_clock_rounded
                                  : (_currentPhase == BreathingPhase.holdEmpty)
                                      ? Icons.spa_rounded
                                      : Icons.air_rounded,
                              size: 24,
                              color: _phaseAccent,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_secondsLeftInPhase}s',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _phaseAccent,
                                fontFamily: 'Noto Sans Devanagari',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppDimens.space20),

          // Phase Headline & Instruction
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey<BreathingPhase>(_currentPhase),
              children: [
                Text(
                  _getPhaseTitle(context),
                  style: AppTextStyles.heading.copyWith(
                    color: _phaseAccent,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimens.space4),
                Text(
                  _getPhaseSubtitle(context),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
