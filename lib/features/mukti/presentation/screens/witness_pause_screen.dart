import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../widgets/mukti_shared_widgets.dart';

/// WitnessPauseScreen — Practice 1: साक्षी विराम (Sky & Cloud Pause)
/// A 90-second guided emotional witnessing exercise.
/// Philosophy: "You are not the emotion. You are the one watching it."
class WitnessPauseScreen extends StatefulWidget {
  const WitnessPauseScreen({super.key});

  @override
  State<WitnessPauseScreen> createState() => _WitnessPauseScreenState();
}

enum _WitnessPhase { intro, timer, prompt, complete }

class _WitnessPauseScreenState extends State<WitnessPauseScreen>
    with SingleTickerProviderStateMixin {
  _WitnessPhase _phase = _WitnessPhase.intro;
  int _secondsLeft = 90;
  Timer? _timer;
  final TextEditingController _emotionCtrl = TextEditingController();
  late AnimationController _cloudAnim;
  late Animation<double> _cloudX;
  late Animation<double> _cloudOpacity;

  @override
  void initState() {
    super.initState();
    _cloudAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _cloudX = Tween<double>(begin: -0.3, end: 1.3).animate(
      CurvedAnimation(parent: _cloudAnim, curve: Curves.linear),
    );
    _cloudOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.7), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.7), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.0), weight: 20),
    ]).animate(_cloudAnim);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cloudAnim.dispose();
    _emotionCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    HapticService.mediumImpact();
    setState(() => _phase = _WitnessPhase.timer);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          t.cancel();
          _phase = _WitnessPhase.prompt;
        }
      });
    });
  }

  void _submitEmotion() {
    HapticService.selectionClick();
    setState(() => _phase = _WitnessPhase.complete);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.loc.witnessLogSaved),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          switchInCurve: Curves.easeOut,
          child: switch (_phase) {
            _WitnessPhase.intro => _buildIntro(loc),
            _WitnessPhase.timer => _buildTimer(loc),
            _WitnessPhase.prompt => _buildPrompt(loc),
            _WitnessPhase.complete => _buildComplete(loc),
          },
        ),
      ),
    );
  }

  Widget _buildIntro(AppLocalizations loc) {
    return MuktiPaddedColumn(key: const ValueKey('intro'), children: [
      const SizedBox(height: 48),
      MuktiPillarBadge(loc.witnessPillarBadge),
      const SizedBox(height: 32),
      Text(
        loc.witnessOpeningQuote,
        textAlign: TextAlign.center,
        style: AppTextStyles.displayLarge.copyWith(height: 1.6),
      ),
      const SizedBox(height: 24),
      Text(
        loc.witnessCloudInstruction,
        textAlign: TextAlign.center,
        style: AppTextStyles.subhead.copyWith(height: 1.7),
      ),
      const Spacer(),
      MuktiCloudVisualizer(cloudX: _cloudX, cloudOpacity: _cloudOpacity),
      const Spacer(),
      MuktiPrimaryButton(label: loc.witnessBegin, onTap: _startTimer),
      const SizedBox(height: 12),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(loc.witnessSkip,
            style: AppTextStyles.subhead.copyWith(color: AppColors.textMuted)),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _buildTimer(AppLocalizations loc) {
    final pct = _secondsLeft / 90.0;
    return MuktiPaddedColumn(key: const ValueKey('timer'), children: [
      const Spacer(),
      MuktiCloudVisualizer(cloudX: _cloudX, cloudOpacity: _cloudOpacity),
      const SizedBox(height: 40),
      Text(loc.witnessTimerLabel, style: AppTextStyles.labelBadge),
      const SizedBox(height: 16),
      SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: pct,
                strokeWidth: 3,
                color: AppColors.shieldPrimary,
                backgroundColor: AppColors.borderSubtle,
              ),
            ),
            Text(
              '$_secondsLeft',
              style: AppTextStyles.displayLarge
                  .copyWith(fontSize: 52, color: AppColors.shieldPrimary),
            ),
          ],
        ),
      ),
      const SizedBox(height: 28),
      Text(loc.witnessCloudInstruction,
          textAlign: TextAlign.center,
          style: AppTextStyles.subhead.copyWith(height: 1.7)),
      const Spacer(),
    ]);
  }

  Widget _buildPrompt(AppLocalizations loc) {
    return MuktiPaddedColumn(key: const ValueKey('prompt'), children: [
      const Spacer(),
      Text(
        loc.witnessEmotionPrompt,
        textAlign: TextAlign.center,
        style: AppTextStyles.displayMedium.copyWith(height: 1.6),
      ),
      const SizedBox(height: 32),
      MuktiMinimalTextField(
          controller: _emotionCtrl, hint: loc.witnessEmotionHint),
      const SizedBox(height: 32),
      MuktiPrimaryButton(
        label: muktiContinueLabel(loc),
        onTap: _submitEmotion,
        icon: Icons.check_rounded,
      ),
      const Spacer(),
    ]);
  }

  Widget _buildComplete(AppLocalizations loc) {
    return MuktiPaddedColumn(key: const ValueKey('complete'), children: [
      const Spacer(),
      const Icon(Icons.visibility_outlined,
          color: AppColors.shieldPrimary, size: 56),
      const SizedBox(height: 32),
      Text(
        loc.witnessCompletionMessage,
        textAlign: TextAlign.center,
        style: AppTextStyles.displayMedium.copyWith(height: 1.7),
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
