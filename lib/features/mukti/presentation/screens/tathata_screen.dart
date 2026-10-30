import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../widgets/mukti_shared_widgets.dart';

/// TathataScreen — Practice 2: तथता (Reality Alignment)
/// A 3-question guided acceptance exercise for when things go wrong.
/// Philosophy: "What happened, happened. Complaint does not change it."
class TathataScreen extends StatefulWidget {
  const TathataScreen({super.key});

  @override
  State<TathataScreen> createState() => _TathataScreenState();
}

enum _TathataStep { intro, q1, q2, q3, result }

class _TathataScreenState extends State<TathataScreen> {
  _TathataStep _step = _TathataStep.intro;
  String? _q1Answer;
  double _controlPct = 30;
  final TextEditingController _q3Ctrl = TextEditingController();

  @override
  void dispose() {
    _q3Ctrl.dispose();
    super.dispose();
  }

  void _advanceTo(_TathataStep step) {
    HapticService.selectionClick();
    setState(() => _step = step);
  }

  String _responseText(AppLocalizations loc) {
    if (_controlPct <= 30) {
      return loc.tathataLowControlResponse(_controlPct.round());
    }
    return loc.tathataHighControlResponse(_controlPct.round());
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          switchInCurve: Curves.easeOut,
          child: switch (_step) {
            _TathataStep.intro => _buildIntro(loc),
            _TathataStep.q1 => _buildQ1(loc),
            _TathataStep.q2 => _buildQ2(loc),
            _TathataStep.q3 => _buildQ3(loc),
            _TathataStep.result => _buildResult(loc),
          },
        ),
      ),
    );
  }

  Widget _buildIntro(AppLocalizations loc) {
    return MuktiPaddedColumn(key: const ValueKey('intro'), children: [
      const SizedBox(height: 48),
      MuktiPillarBadge(loc.tathataPillarBadge),
      const SizedBox(height: 32),
      Text(
        loc.tathataOpeningQuote,
        textAlign: TextAlign.center,
        style: AppTextStyles.displayLarge.copyWith(height: 1.7),
      ),
      const SizedBox(height: 20),
      Text(
        loc.tathataSubtitle,
        textAlign: TextAlign.center,
        style: AppTextStyles.subhead
            .copyWith(height: 1.6, color: AppColors.textMuted),
      ),
      const Spacer(),
      const _TathataProgress(current: 0),
      const SizedBox(height: 24),
      MuktiPrimaryButton(
        label: loc.tathataTriggerButton,
        onTap: () => _advanceTo(_TathataStep.q1),
        icon: Icons.arrow_forward_ios_rounded,
      ),
      const SizedBox(height: 12),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(loc.witnessSkip,
            style: AppTextStyles.subhead.copyWith(color: AppColors.textMuted)),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _buildQ1(AppLocalizations loc) {
    return MuktiPaddedColumn(key: const ValueKey('q1'), children: [
      const SizedBox(height: 48),
      const _TathataProgress(current: 1),
      const SizedBox(height: 32),
      Text(loc.tathataQ1,
          textAlign: TextAlign.center,
          style: AppTextStyles.displayMedium.copyWith(height: 1.6)),
      const SizedBox(height: 36),
      _TathataChoiceButton(
        label: loc.tathataQ1Yes,
        selected: _q1Answer == 'yes',
        color: AppColors.emeraldSuccess,
        onTap: () {
          setState(() => _q1Answer = 'yes');
          Future.delayed(const Duration(milliseconds: 300),
              () => _advanceTo(_TathataStep.q2));
        },
      ),
      const SizedBox(height: 12),
      _TathataChoiceButton(
        label: loc.tathataQ1No,
        selected: _q1Answer == 'no',
        color: AppColors.shieldPrimary,
        onTap: () {
          setState(() => _q1Answer = 'no');
          Future.delayed(const Duration(milliseconds: 300),
              () => _advanceTo(_TathataStep.q2));
        },
      ),
      const SizedBox(height: 12),
      _TathataChoiceButton(
        label: loc.tathataQ1Partial,
        selected: _q1Answer == 'partial',
        color: AppColors.amberWarning,
        onTap: () {
          setState(() => _q1Answer = 'partial');
          Future.delayed(const Duration(milliseconds: 300),
              () => _advanceTo(_TathataStep.q2));
        },
      ),
      const Spacer(),
    ]);
  }

  Widget _buildQ2(AppLocalizations loc) {
    return MuktiPaddedColumn(key: const ValueKey('q2'), children: [
      const SizedBox(height: 48),
      const _TathataProgress(current: 2),
      const SizedBox(height: 32),
      Text(loc.tathataQ2,
          textAlign: TextAlign.center,
          style: AppTextStyles.displayMedium.copyWith(height: 1.6)),
      const SizedBox(height: 12),
      Text('${_controlPct.round()}%',
          style: AppTextStyles.displayLarge
              .copyWith(fontSize: 48, color: AppColors.shieldPrimary)),
      const SizedBox(height: 16),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: AppColors.shieldPrimary,
          inactiveTrackColor: AppColors.borderMedium,
          thumbColor: AppColors.shieldPrimary,
          overlayColor: AppColors.shieldGlow,
          trackHeight: 2.5,
        ),
        child: Slider(
          value: _controlPct,
          min: 0,
          max: 100,
          divisions: 20,
          label: '${_controlPct.round()}%',
          onChanged: (v) => setState(() => _controlPct = v),
        ),
      ),
      Text(loc.tathataQ2Hint,
          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
      const SizedBox(height: 36),
      MuktiPrimaryButton(
        label: muktiContinueLabel(loc),
        onTap: () => _advanceTo(_TathataStep.q3),
        icon: Icons.arrow_forward_ios_rounded,
      ),
      const Spacer(),
    ]);
  }

  Widget _buildQ3(AppLocalizations loc) {
    return MuktiPaddedColumn(key: const ValueKey('q3'), children: [
      const SizedBox(height: 48),
      const _TathataProgress(current: 3),
      const SizedBox(height: 32),
      Text(loc.tathataQ3,
          textAlign: TextAlign.center,
          style: AppTextStyles.displayMedium.copyWith(height: 1.6)),
      const SizedBox(height: 32),
      MuktiMinimalTextField(controller: _q3Ctrl, hint: loc.tathataQ3Hint),
      const SizedBox(height: 32),
      MuktiPrimaryButton(
        label: loc.tathataSaveButton,
        onTap: () => _advanceTo(_TathataStep.result),
        icon: Icons.check_rounded,
      ),
      const Spacer(),
    ]);
  }

  Widget _buildResult(AppLocalizations loc) {
    return MuktiPaddedColumn(key: const ValueKey('result'), children: [
      const Spacer(),
      const Icon(Icons.water_drop_outlined,
          color: AppColors.shieldPrimary, size: 52),
      const SizedBox(height: 32),
      Text(
        _responseText(loc),
        textAlign: TextAlign.center,
        style: AppTextStyles.displayMedium.copyWith(height: 1.7),
      ),
      const SizedBox(height: 20),
      if (_q3Ctrl.text.trim().isNotEmpty)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Text(
            '"${_q3Ctrl.text.trim()}"',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
        ),
      const Spacer(),
      MuktiPrimaryButton(
        label: muktiGoBackLabel(loc),
        onTap: () => Navigator.of(context).pop(),
        icon: Icons.arrow_back_ios_new_rounded,
      ),
      const SizedBox(height: 32),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private widgets local to this screen
// ─────────────────────────────────────────────────────────────────────────────

class _TathataProgress extends StatelessWidget {
  final int current;
  const _TathataProgress({required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i < current;
        final isCurrent = i == current - 1;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 28 : 8,
          height: 3,
          decoration: BoxDecoration(
            color: active || isCurrent
                ? AppColors.shieldPrimary
                : AppColors.borderMedium,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

class _TathataChoiceButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _TathataChoiceButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
        border: Border.all(
          color: selected ? color : AppColors.borderMedium,
          width: selected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selected)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.check_circle_rounded, color: color, size: 18),
                ),
              Text(
                label,
                style: AppTextStyles.titleSmall.copyWith(
                  color: selected ? color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
