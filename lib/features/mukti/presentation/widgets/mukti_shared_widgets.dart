import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';

/// Shared UI primitives for the Mukti MVP screens.
/// Keep these in one file to avoid cross-screen imports.

class MuktiPaddedColumn extends StatelessWidget {
  final List<Widget> children;
  const MuktiPaddedColumn({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: children,
        ),
      ),
    );
  }
}

class MuktiPillarBadge extends StatelessWidget {
  final String label;
  const MuktiPillarBadge(this.label, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.shieldPrimary.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: AppTextStyles.labelBadge.copyWith(color: AppColors.shieldPrimary)),
    );
  }
}

class MuktiPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  const MuktiPrimaryButton({super.key, required this.label, required this.onTap, this.icon});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon ?? Icons.play_arrow_rounded, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.shieldPrimary,
          foregroundColor: AppColors.background,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: AppTextStyles.titleSmall,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class MuktiMinimalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const MuktiMinimalTextField({super.key, required this.controller, required this.hint});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
      cursorColor: AppColors.shieldPrimary,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.subhead.copyWith(color: AppColors.textMuted),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderMedium),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.shieldPrimary, width: 1.5),
        ),
      ),
    );
  }
}

class MuktiCloudVisualizer extends StatelessWidget {
  final Animation<double> cloudX;
  final Animation<double> cloudOpacity;
  const MuktiCloudVisualizer(
      {super.key, required this.cloudX, required this.cloudOpacity});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0F172A).withValues(alpha: 0.6),
                AppColors.background,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: cloudX,
          builder: (context, _) {
            return Positioned(
              left: MediaQuery.of(context).size.width * cloudX.value - 60,
              top: 28,
              child: Opacity(
                opacity: cloudOpacity.value.clamp(0.0, 1.0),
                child: Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.shieldPrimary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shieldPrimary.withValues(alpha: 0.08),
                        blurRadius: 20,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ]),
    );
  }
}

/// Returns the localized "Continue" label independent of language.
String muktiContinueLabel(AppLocalizations loc) =>
    loc.isHindi ? 'आगे बढ़ें' : 'Continue';

/// Returns the localized "Go Back" label independent of language.
String muktiGoBackLabel(AppLocalizations loc) =>
    loc.isHindi ? 'वापस जाएं' : 'Go Back';
