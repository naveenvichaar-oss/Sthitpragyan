import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';

enum BreathingPhase { inhale, hold, exhale }

/// BreathingPulseVisualizer runs a rhythmic 3-second breathing cycle
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

    // 3-second cycle per phase (Inhale: 3s -> Hold: 3s -> Exhale: 3s = 9s total)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    );

    _scaleAnimation = TweenSequence<double>([
      // 0.0 -> 0.33: Inhale (Expand from 0.65 to 1.0)
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.65,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 33.3,
      ),
      // 0.33 -> 0.66: Hold (Stay at 1.0)
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 33.3),
      // 0.66 -> 1.0: Exhale (Contract from 1.0 to 0.65)
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.65,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 33.4,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      // Inhale
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.3,
          end: 0.85,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 33.3,
      ),
      // Hold
      TweenSequenceItem(tween: ConstantTween<double>(0.85), weight: 33.3),
      // Exhale
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.85,
          end: 0.3,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 33.4,
      ),
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

    if (val < 0.33) {
      nextPhase = BreathingPhase.inhale;
    } else if (val < 0.66) {
      nextPhase = BreathingPhase.hold;
    } else {
      nextPhase = BreathingPhase.exhale;
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
        return context.loc.breathInhaleVisual;
      case BreathingPhase.hold:
        return context.loc.breathHoldVisual;
      case BreathingPhase.exhale:
        return context.loc.breathExhaleVisual;
    }
  }

  String _getPhaseSubtitle(BuildContext context) {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return context.loc.breathNavelExpand;
      case BreathingPhase.hold:
        return context.loc.breathSteadfastObserver;
      case BreathingPhase.exhale:
        return context.loc.breathReleaseCortisol;
    }
  }

  Color get _phaseAccent {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return AppColors.shieldPrimary;
      case BreathingPhase.hold:
        return const Color(0xFF818CF8); // Indigo / composure
      case BreathingPhase.exhale:
        return AppColors.emeraldSuccess;
    }
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
                    'PARASYMPATHETIC PACER',
                    style: AppTextStyles.labelBadge.copyWith(fontSize: 9.5),
                  ),
                ],
              ),
              Text(
                '${_secondsGrounded}s GROUNDED',
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
                          color: _phaseAccent.withOpacity(opacity * 0.12),
                          border: Border.all(
                            color: _phaseAccent.withOpacity(opacity * 0.4),
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
                          color: _phaseAccent.withOpacity(opacity * 0.2),
                          border: Border.all(
                            color: _phaseAccent.withOpacity(opacity * 0.6),
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
                            color: _phaseAccent.withOpacity(0.4),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _currentPhase == BreathingPhase.hold
                              ? Icons.lock_outline_rounded
                              : Icons.air_rounded,
                          size: 32,
                          color: _phaseAccent,
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
