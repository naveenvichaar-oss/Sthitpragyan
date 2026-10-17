import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/gong_audio_service.dart';
import '../../../../core/utils/haptic_service.dart';

/// MicroIgnitionTimerDialog implements the 5-Minute Friction-Breaker rule:
/// Initiating any delayed, high-resistance task for strictly 5 minutes.
/// Cognitive resistance collapses once the physical motion of execution begins.
class MicroIgnitionTimerDialog extends StatefulWidget {
  final String? initialTask;

  const MicroIgnitionTimerDialog({
    super.key,
    this.initialTask,
  });

  static Future<void> show(BuildContext context, {String? initialTask}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => MicroIgnitionTimerDialog(initialTask: initialTask),
    );
  }

  @override
  State<MicroIgnitionTimerDialog> createState() =>
      _MicroIgnitionTimerDialogState();
}

class _MicroIgnitionTimerDialogState extends State<MicroIgnitionTimerDialog> {
  static const int _totalSeconds = 300; // 5 minutes
  int _remainingSeconds = _totalSeconds;
  bool _isRunning = false;
  bool _isCompleted = false;
  Timer? _ticker;

  final HiveStorage _storage = HiveStorage();
  late TextEditingController _taskController;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(
      text: widget.initialTask ?? 'Critical Immediate Deliverable',
    );
    // Auto-start timer immediately upon opening for zero friction
    _startTimer();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _taskController.dispose();
    super.dispose();
  }

  void _startTimer() {
    HapticService.selectionClick();
    _ticker?.cancel();
    setState(() {
      _isRunning = true;
      _isCompleted = false;
    });

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    HapticService.selectionClick();
    _ticker?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    HapticService.selectionClick();
    _ticker?.cancel();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
      _isCompleted = false;
    });
  }

  void _onTimerComplete() async {
    setState(() {
      _isRunning = false;
      _isCompleted = true;
    });
    // Play celebratory calm gong tone
    await GongAudioService().playDeepGong();
    await _storage.incrementMicroIgnitionCount();
  }

  String _formatTime(int totalSecs) {
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    final minStr = mins.toString().padLeft(2, '0');
    final secStr = secs.toString().padLeft(2, '0');
    return '$minStr:$secStr';
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1.0 - (_remainingSeconds / _totalSeconds);

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: AppDimens.space24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header with Badge & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 13,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          context.loc.microIgnitionRule.toUpperCase(),
                          style: AppTextStyles.labelBadge.copyWith(
                            color: const Color(0xFFF59E0B),
                            fontSize: 8.5,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Task Title Input / Preview
              TextField(
                controller: _taskController,
                textAlign: TextAlign.center,
                style: AppTextStyles.heading.copyWith(fontSize: 15),
                decoration: InputDecoration(
                  hintText: context.loc.microIgnitionQuestion,
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Stoic Philosophy Description
              Text(
                context.loc.microIgnitionDescription,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // 3. Circular Progress Visualizer
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: AppColors.surfaceElevated,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isCompleted
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(_remainingSeconds),
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontFamily: 'monospace',
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isCompleted
                            ? 'MOMENTUM READY'
                            : _isRunning
                                ? 'ACTIVE IGNITION'
                                : 'PAUSED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: _isCompleted
                              ? const Color(0xFF10B981)
                              : _isRunning
                                  ? const Color(0xFFF59E0B)
                                  : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // 4. Status or Completion Message
              if (_isCompleted) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '✓ 5-MINUTE FRICTION BROKEN',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Inertia is dissolved. You now have kinetic momentum.\nContinue seamlessly into Deep Work.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 5. Timer Controls
              Row(
                children: [
                  Expanded(
                    child: _isCompleted
                        ? ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text(
                              'CLOSE & CONTINUE',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isRunning
                                  ? AppColors.surfaceElevated
                                  : const Color(0xFFF59E0B),
                              foregroundColor: _isRunning
                                  ? AppColors.textPrimary
                                  : Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: Icon(
                              _isRunning
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 18,
                            ),
                            label: Text(
                              _isRunning ? 'PAUSE' : 'START IGNITION',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                            onPressed: _isRunning ? _pauseTimer : _startTimer,
                          ),
                  ),
                  if (!_isCompleted) ...[
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(
                        Icons.refresh_rounded,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      tooltip: 'Reset to 5:00',
                      onPressed: _resetTimer,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
