import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/services/gong_audio_service.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/execution_trigger.dart';
import 'micro_ignition_timer_dialog.dart';

/// ZeroSnoozeAnchorModal displays the minimalist, solemn full-screen anchor
/// when an execution block triggers. Procrastination is eliminated by eliminating snoozing.
class ZeroSnoozeAnchorModal extends StatefulWidget {
  final ExecutionTrigger trigger;

  const ZeroSnoozeAnchorModal({
    super.key,
    required this.trigger,
  });

  static Future<void> show(BuildContext context, ExecutionTrigger trigger) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return ZeroSnoozeAnchorModal(trigger: trigger);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<ZeroSnoozeAnchorModal> createState() => _ZeroSnoozeAnchorModalState();
}

class _ZeroSnoozeAnchorModalState extends State<ZeroSnoozeAnchorModal>
    with SingleTickerProviderStateMixin {
  final HiveStorage _storage = HiveStorage();
  late AnimationController _pulseController;
  int _countdown = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Play solemn deep gong chime upon opening
    GongAudioService().playDeepGong(speakAnchor: true);

    // 3-2-1 Visual Countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
        HapticService.selectionClick();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onCommitExecution() async {
    HapticService.heavyImpact();
    await _storage.recordExecutionCompletion(widget.trigger.id);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Committed: "${widget.trigger.title}". Non-negotiable execution in progress.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onLaunchMicroIgnition() {
    HapticService.selectionClick();
    Navigator.of(context).pop();
    MicroIgnitionTimerDialog.show(context, initialTask: widget.trigger.title);
  }

  @override
  Widget build(BuildContext context) {
    final isCounting = _countdown > 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. Austere Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.borderSubtle,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.notifications_active_outlined,
                          size: 14,
                          color: AppColors.shieldPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ZERO-SNOOZE COMMITMENT • ${widget.trigger.devanagariSubtitle}',
                          style: AppTextStyles.labelBadge.copyWith(
                            color: AppColors.shieldPrimary,
                            fontSize: 9.5,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 2. Pulse Ring with 3-2-1 Countdown
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (_pulseController.value * 0.05);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            border: Border.all(
                              color: isCounting
                                  ? AppColors.shieldPrimary
                                  : const Color(0xFF10B981),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isCounting
                                        ? AppColors.shieldPrimary
                                        : const Color(0xFF10B981))
                                    .withValues(alpha: 0.25),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: isCounting
                                ? Text(
                                    '$_countdown',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 54,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1,
                                    ),
                                  )
                                : const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.bolt_rounded,
                                        size: 42,
                                        color: Color(0xFF10B981),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'EXECUTE',
                                        style: TextStyle(
                                          color: Color(0xFF10B981),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 36),

                  // 3. Block Title
                  Text(
                    widget.trigger.title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 22,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4. Stoic Dictum Anchor
                  Text(
                    'Done is better than perfect.\n3-2-1... Execute.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.scriptVerbatim.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 5. Intent Details
                  Text(
                    widget.trigger.intent,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 44),

                  // 6. Non-Negotiable Commitment Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: const Text(
                        'I AM EXECUTING NOW',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      onPressed: _onCommitExecution,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5-Minute Micro-Ignition (Friction-Breaker)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(
                          color: AppColors.borderSubtle,
                          width: 1.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.timer_outlined, size: 18),
                      label: const Text(
                        'START 5-MIN MICRO-IGNITION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      onPressed: _onLaunchMicroIgnition,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
