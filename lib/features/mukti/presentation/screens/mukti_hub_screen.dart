import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import 'sacred_silence_screen.dart';
import 'tathata_screen.dart';
import 'witness_pause_screen.dart';

/// MuktiHubScreen — The psychological freedom hub.
/// Hosts 3 core practices: साक्षी विराम, तथता, मौन संग.
/// Philosophy: Detachment, Acceptance, Aloneness — the three pillars of inner freedom.
class MuktiHubScreen extends StatelessWidget {
  const MuktiHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Header ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.shieldPrimary.withValues(alpha: 0.35)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        loc.muktiPhilosophyBadge,
                        style: AppTextStyles.labelBadge
                            .copyWith(color: AppColors.shieldPrimary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.muktiHubTitle,
                      style: AppTextStyles.displayLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loc.muktiHubSubtitle,
                      style: AppTextStyles.subhead.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    // Philosophy intro card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Text(
                        loc.muktiIntroText,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.65,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ─── 3 Practice Cards ───
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Practice 1: साक्षी विराम
                  _PracticeCard(
                    pillarNumber: '01',
                    pillarBadge: loc.witnessPillarBadge,
                    title: loc.witnessTitle,
                    subtitle: loc.witnessSubtitle,
                    triggerLabel: loc.witnessTriggerButton,
                    accentColor: AppColors.shieldPrimary,
                    icon: Icons.visibility_outlined,
                    onTap: () {
                      HapticService.selectionClick();
                      Navigator.of(context).push(
                        _smoothRoute(const WitnessPauseScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Practice 2: तथता
                  _PracticeCard(
                    pillarNumber: '02',
                    pillarBadge: loc.tathataPillarBadge,
                    title: loc.tathataTitle,
                    subtitle: loc.tathataSubtitle,
                    triggerLabel: loc.tathataTriggerButton,
                    accentColor: AppColors.emeraldSuccess,
                    icon: Icons.water_drop_outlined,
                    onTap: () {
                      HapticService.selectionClick();
                      Navigator.of(context).push(
                        _smoothRoute(const TathataScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Practice 3: मौन संग
                  _PracticeCard(
                    pillarNumber: '03',
                    pillarBadge: loc.silencePillarBadge,
                    title: loc.silenceTitle,
                    subtitle: loc.silenceSubtitle,
                    triggerLabel: loc.silenceTriggerButton,
                    accentColor: AppColors.amberWarning,
                    icon: Icons.self_improvement_rounded,
                    onTap: () {
                      HapticService.selectionClick();
                      Navigator.of(context).push(
                        _smoothRoute(const SacredSilenceScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // Zero telemetry notice
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        context.loc.zeroTelemetryNotice,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PageRoute<void> _smoothRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 450),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Practice Card Widget
// ─────────────────────────────────────────────────────────────────────────────

class _PracticeCard extends StatefulWidget {
  final String pillarNumber;
  final String pillarBadge;
  final String title;
  final String subtitle;
  final String triggerLabel;
  final Color accentColor;
  final IconData icon;
  final VoidCallback onTap;

  const _PracticeCard({
    required this.pillarNumber,
    required this.pillarBadge,
    required this.title,
    required this.subtitle,
    required this.triggerLabel,
    required this.accentColor,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_PracticeCard> createState() => _PracticeCardState();
}

class _PracticeCardState extends State<_PracticeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressAnim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _pressAnim;
  }

  @override
  void dispose() {
    _pressAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressAnim.reverse(),
      onTapUp: (_) {
        _pressAnim.forward();
        widget.onTap();
      },
      onTapCancel: () => _pressAnim.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top accent strip + pillar number
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.6),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Pillar number
                        Text(
                          widget.pillarNumber,
                          style: AppTextStyles.labelBadge.copyWith(
                            color: widget.accentColor.withValues(alpha: 0.5),
                            fontSize: 11,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: widget.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.pillarBadge,
                            style: AppTextStyles.caption.copyWith(
                              color: widget.accentColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(widget.icon,
                            color: widget.accentColor.withValues(alpha: 0.6),
                            size: 22),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(widget.title, style: AppTextStyles.heading),
                    const SizedBox(height: 6),
                    Text(
                      widget.subtitle,
                      style: AppTextStyles.subhead.copyWith(
                        height: 1.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // CTA button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.accentColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.triggerLabel,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: widget.accentColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: widget.accentColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
