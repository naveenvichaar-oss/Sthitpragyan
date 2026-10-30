import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';

/// SOSShieldButton is the primary emergency trigger.
/// Designed for instant tactile access during acute corporate hostility,
/// ambush meetings, panic, or boundary infringement.
class SOSShieldButton extends StatefulWidget {
  final VoidCallback onPressed;

  const SOSShieldButton({super.key, required this.onPressed});

  @override
  State<SOSShieldButton> createState() => _SOSShieldButtonState();
}

class _SOSShieldButtonState extends State<SOSShieldButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.15, end: 0.45).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticService.heavyImpact();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: _handleTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.shieldPrimary.withValues(
                  alpha: (_glowAnimation.value + 0.2).clamp(0.0, 1.0),
                ),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shieldPrimary.withValues(
                    alpha: (_glowAnimation.value * 0.4).clamp(0.0, 1.0),
                  ),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Shield Emblem
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceElevated,
                    border: Border.all(
                      color: AppColors.shieldPrimary.withValues(alpha: 0.8),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shieldPrimary.withValues(
                          alpha: _glowAnimation.value.clamp(0.0, 1.0),
                        ),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield_rounded,
                      size: 28,
                      color: AppColors.shieldPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.roseMuted,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.roseDanger.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              'SOS PROTOCOL',
                              style: AppTextStyles.labelBadge.copyWith(
                                color: AppColors.roseDanger,
                                fontSize: 9.0,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'INSTANT DEPLOY',
                            style: AppTextStyles.labelBadge.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 9.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.loc.sosCenterButton,
                        style: AppTextStyles.heading,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.loc.sosShieldSub,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.shieldPrimary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
