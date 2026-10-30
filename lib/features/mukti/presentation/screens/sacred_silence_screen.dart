import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../widgets/mukti_shared_widgets.dart';

/// SacredSilenceScreen — Practice 3: मौन संग (Sacred Silence)
/// A distraction-free timer for sitting with oneself.
/// No music. No guidance. Only the breath.
class SacredSilenceScreen extends StatefulWidget {
  const SacredSilenceScreen({super.key});

  @override
  State<SacredSilenceScreen> createState() => _SacredSilenceScreenState();
}

enum _SilencePhase { setup, inProgress, reflection, complete }

class _SacredSilenceScreenState extends State<SacredSilenceScreen>
    with SingleTickerProviderStateMixin {
  _SilencePhase _phase = _SilencePhase.setup;
  int _durationMinutes = 5;
  int _secondsLeft = 300;
  int _totalSeconds = 300;
  Timer? _timer;
  late AnimationController _breathAnim;
  late Animation<double> _breathScale;

  @override
  void initState() {
    super.initState();
    _breathAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _breathScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _breathAnim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathAnim.dispose();
    super.dispose();
  }

  void _selectDuration(int minutes) {
    setState(() {
      _durationMinutes = minutes;
      _secondsLeft = minutes * 60;
      _totalSeconds = minutes * 60;
    });
    HapticService.selectionClick();
  }

  void _beginSilence() {
    HapticService.mediumImpact();
    setState(() {
      _phase = _SilencePhase.inProgress;
      _secondsLeft = _durationMinutes * 60;
      _totalSeconds = _durationMinutes * 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          t.cancel();
          HapticService.mediumImpact();
          _phase = _SilencePhase.reflection;
        }
      });
    });
  }

  void _selectReflection(String choice) {
    HapticService.selectionClick();
    setState(() => _phase = _SilencePhase.complete);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.loc.silenceLogSaved),
            backgroundColor: AppColors.surfaceElevated,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  String _formatTime(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          switchInCurve: Curves.easeOut,
          child: switch (_phase) {
            _SilencePhase.setup => _buildSetup(loc),
            _SilencePhase.inProgress => _buildInProgress(loc),
            _SilencePhase.reflection => _buildReflection(loc),
            _SilencePhase.complete => _buildComplete(loc),
          },
        ),
      ),
    );
  }

  Widget _buildSetup(AppLocalizations loc) {
    return MuktiPaddedColumn(key: const ValueKey('setup'), children: [
      const SizedBox(height: 48),
      MuktiPillarBadge(loc.silencePillarBadge),
      const SizedBox(height: 32),
      Text(
        loc.silenceOpeningQuote,
        textAlign: TextAlign.center,
        style: AppTextStyles.displayLarge.copyWith(height: 1.7),
      ),
      const SizedBox(height: 12),
      Text(
        loc.silenceSubtitle,
        textAlign: TextAlign.center,
        style: AppTextStyles.subhead
            .copyWith(color: AppColors.textMuted, height: 1.6),
      ),
      const Spacer(),
      Text(loc.silenceDurationLabel, style: AppTextStyles.labelBadge),
      const SizedBox(height: 20),
      Row(
        children: [
          _DurationChip(
            label: loc.silence5min,
            selected: _durationMinutes == 5,
            onTap: () => _selectDuration(5),
          ),
          const SizedBox(width: 10),
          _DurationChip(
            label: loc.silence10min,
            selected: _durationMinutes == 10,
            onTap: () => _selectDuration(10),
          ),
          const SizedBox(width: 10),
          _DurationChip(
            label: loc.silence15min,
            selected: _durationMinutes == 15,
            onTap: () => _selectDuration(15),
          ),
        ],
      ),
      const SizedBox(height: 32),
      MuktiPrimaryButton(
        label: loc.silenceBeginButton,
        onTap: _beginSilence,
        icon: Icons.self_improvement_rounded,
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

  Widget _buildInProgress(AppLocalizations loc) {
    final pct = _secondsLeft / _totalSeconds;
    return Container(
      key: const ValueKey('inProgress'),
      color: AppColors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 1.5,
                    color: AppColors.shieldPrimary.withValues(alpha: 0.3),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                AnimatedBuilder(
                  animation: _breathScale,
                  builder: (_, __) {
                    return Transform.scale(
                      scale: _breathScale.value,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.shieldPrimary.withValues(alpha: 0.06),
                          border: Border.all(
                            color: AppColors.shieldPrimary.withValues(
                                alpha: 0.12 + 0.08 * _breathScale.value),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _formatTime(_secondsLeft),
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.shieldPrimary.withValues(alpha: 0.7),
                              letterSpacing: 2,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            loc.silenceBreathLabel,
            style: AppTextStyles.subhead.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(flex: 2),
          _StarField(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildReflection(AppLocalizations loc) {
    return MuktiPaddedColumn(key: const ValueKey('reflection'), children: [
      const Spacer(),
      Text(
        loc.silenceTimerDoneMessage,
        textAlign: TextAlign.center,
        style: AppTextStyles.displayMedium.copyWith(height: 1.6),
      ),
      const SizedBox(height: 36),
      Text(
        loc.silenceEndPrompt,
        textAlign: TextAlign.center,
        style: AppTextStyles.subhead
            .copyWith(color: AppColors.textSecondary, height: 1.6),
      ),
      const SizedBox(height: 32),
      _ReflectionChoice(
        label: loc.silenceEndOptThoughts,
        icon: Icons.bubble_chart_outlined,
        onTap: () => _selectReflection('thoughts'),
      ),
      const SizedBox(height: 12),
      _ReflectionChoice(
        label: loc.silenceEndOptPeace,
        icon: Icons.spa_outlined,
        onTap: () => _selectReflection('peace'),
      ),
      const SizedBox(height: 12),
      _ReflectionChoice(
        label: loc.silenceEndOptRestless,
        icon: Icons.wind_power_outlined,
        onTap: () => _selectReflection('restless'),
      ),
      const Spacer(),
    ]);
  }

  Widget _buildComplete(AppLocalizations loc) {
    return MuktiPaddedColumn(key: const ValueKey('complete'), children: [
      const Spacer(),
      const Icon(Icons.self_improvement_rounded,
          color: AppColors.shieldPrimary, size: 56),
      const SizedBox(height: 32),
      Text(
        loc.silenceTimerDoneMessage,
        textAlign: TextAlign.center,
        style: AppTextStyles.displayMedium.copyWith(height: 1.7),
      ),
      const SizedBox(height: 12),
      Text(
        loc.silenceStreakDays(1),
        style: AppTextStyles.labelBadge.copyWith(color: AppColors.shieldPrimary),
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

class _DurationChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DurationChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.shieldPrimary.withValues(alpha: 0.12)
                : AppColors.surface,
            border: Border.all(
              color: selected ? AppColors.shieldPrimary : AppColors.borderSubtle,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall.copyWith(
              color: selected ? AppColors.shieldPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReflectionChoice extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ReflectionChoice(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderMedium),
          borderRadius: BorderRadius.circular(10),
          color: AppColors.surface,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textMuted, size: 20),
            const SizedBox(width: 16),
            Text(label, style: AppTextStyles.titleSmall),
          ],
        ),
      ),
    );
  }
}

/// Minimal static star-field background decoration for in-progress silence screen.
class _StarField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rng = math.Random(42);
    return SizedBox(
      height: 60,
      child: CustomPaint(
        painter: _StarPainter(rng),
        size: Size(MediaQuery.of(context).size.width, 60),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final math.Random rng;
  _StarPainter(this.rng);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.shieldPrimary.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 30; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.2 + 0.3;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => false;
}
