import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';

/// 2-Minute Box Breathing Drill Modal for acute physiological de-escalation
/// 4-Phase Cycle: Inhale (4s) -> Hold (4s) -> Exhale (4s) -> Hold (4s)
class BoxBreathingDrillModal extends StatefulWidget {
  final VoidCallback onCompleted;

  const BoxBreathingDrillModal({super.key, required this.onCompleted});

  static Future<bool?> show(
    BuildContext context, {
    required VoidCallback onCompleted,
  }) {
    HapticService.heavyImpact();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      isDismissible: true,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => BoxBreathingDrillModal(onCompleted: onCompleted),
    );
  }

  @override
  State<BoxBreathingDrillModal> createState() => _BoxBreathingDrillModalState();
}

enum BreathPhase { inhale, holdFull, exhale, holdEmpty }

class _BoxBreathingDrillModalState extends State<BoxBreathingDrillModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cycleController;

  static const int _totalDurationSeconds = 120; // 2 minutes
  int _remainingSeconds = _totalDurationSeconds;
  Timer? _countdownTimer;

  BreathPhase _currentPhase = BreathPhase.inhale;
  int _phaseSecondsRemaining = 4;
  bool _isRunning = true;

  @override
  void initState() {
    super.initState();

    // 16-second total box cycle (4s per phase)
    _cycleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..addListener(_handleCycleProgress);

    _cycleController.repeat();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) return;

      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;

          // Calculate current phase from 16-second cycle
          final cycleSec = 16 - (_remainingSeconds % 16);
          final phaseIdx = (cycleSec - 1) ~/ 4;
          final secInPhase = ((cycleSec - 1) % 4) + 1;
          _phaseSecondsRemaining = 4 - ((secInPhase - 1) % 4);

          BreathPhase newPhase;
          switch (phaseIdx) {
            case 0:
              newPhase = BreathPhase.inhale;
              break;
            case 1:
              newPhase = BreathPhase.holdFull;
              break;
            case 2:
              newPhase = BreathPhase.exhale;
              break;
            case 3:
            default:
              newPhase = BreathPhase.holdEmpty;
              break;
          }

          if (newPhase != _currentPhase) {
            _currentPhase = newPhase;
            HapticService.lightImpact();
          }
        } else {
          _completeDrill();
        }
      });
    });
  }

  void _handleCycleProgress() {
    // Keep animation active
  }

  void _togglePlayPause() {
    HapticService.selectionClick();
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _cycleController.repeat();
      } else {
        _cycleController.stop();
      }
    });
  }

  void _completeDrill() {
    _countdownTimer?.cancel();
    _cycleController.stop();
    HapticService.success();
    widget.onCompleted();
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _cycleController.dispose();
    super.dispose();
  }

  String _formatTotalTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _phaseTitle {
    switch (_currentPhase) {
      case BreathPhase.inhale:
        return context.loc.boxBreathingInhaleTitle;
      case BreathPhase.holdFull:
        return context.loc.boxBreathingHoldFullTitle;
      case BreathPhase.exhale:
        return context.loc.boxBreathingExhaleTitle;
      case BreathPhase.holdEmpty:
        return context.loc.boxBreathingHoldEmptyTitle;
    }
  }

  String get _phaseGuidance {
    switch (_currentPhase) {
      case BreathPhase.inhale:
        return context.loc.boxBreathingInhaleGuidance;
      case BreathPhase.holdFull:
        return context.loc.boxBreathingHoldFullGuidance;
      case BreathPhase.exhale:
        return context.loc.boxBreathingExhaleGuidance;
      case BreathPhase.holdEmpty:
        return context.loc.boxBreathingHoldEmptyGuidance;
    }
  }

  double get _currentScale {
    final val = _cycleController.value; // 0.0 to 1.0 over 16 seconds
    if (val < 0.25) {
      // Inhale: 0.0 to 0.25 -> scale 0.65 to 1.0
      return 0.65 + (val / 0.25) * 0.35;
    } else if (val < 0.50) {
      // Hold full: 0.25 to 0.50 -> steady at 1.0
      return 1.0;
    } else if (val < 0.75) {
      // Exhale: 0.50 to 0.75 -> scale 1.0 down to 0.65
      final p = (val - 0.50) / 0.25;
      return 1.0 - (p * 0.35);
    } else {
      // Hold empty: 0.75 to 1.0 -> steady at 0.65
      return 0.65;
    }
  }

  Color get _phaseColor {
    switch (_currentPhase) {
      case BreathPhase.inhale:
        return AppColors.shieldPrimary;
      case BreathPhase.holdFull:
        return const Color(0xFFFBBF24); // Warm Gold
      case BreathPhase.exhale:
        return const Color(0xFF38BDF8); // Calming Sky
      case BreathPhase.holdEmpty:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedRatio = 1.0 - (_remainingSeconds / _totalDurationSeconds);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderBright,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ADRENALINE RESET PROTOCOL',
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.shieldPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '2-Minute Box Breathing',
                    style: AppTextStyles.heading,
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.close_rounded, size: 22),
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress Bar
          LinearProgressIndicator(
            value: completedRatio,
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.shieldPrimary),
            minHeight: 3,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 24),

          // Center Animated Breathing Geometry
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _cycleController,
                builder: (context, child) {
                  final scale = _currentScale;
                  final color = _phaseColor;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Glowing Pulse Ring
                      Container(
                        width: 220 * scale,
                        height: 220 * scale,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(28 * scale),
                          border: Border.all(
                            color: color.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.12),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),

                      // Inner Solid Box
                      Container(
                        width: 160 * scale,
                        height: 160 * scale,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(20 * scale),
                          border: Border.all(color: color, width: 2.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_phaseSecondsRemaining',
                              style: TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 44,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                            Text(
                              'SECONDS',
                              style: AppTextStyles.labelBadge.copyWith(
                                fontSize: 9,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Current Phase & Guidance
          Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _phaseTitle,
                  key: ValueKey(_phaseTitle),
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 18,
                    color: _phaseColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _phaseGuidance,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Timer readout & Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL REMAINING',
                    style: AppTextStyles.labelBadge.copyWith(fontSize: 9),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTotalTime(_remainingSeconds),
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      _isRunning
                          ? Icons.pause_circle_rounded
                          : Icons.play_circle_rounded,
                      size: 36,
                      color: AppColors.shieldPrimary,
                    ),
                    tooltip: _isRunning ? 'Pause' : 'Resume',
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _completeDrill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusSmall,
                        ),
                      ),
                    ),
                    child: const Text(
                      'COMPLETE DRILL',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
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
