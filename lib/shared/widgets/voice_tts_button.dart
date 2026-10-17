import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/database/hive_storage.dart';
import '../../core/services/voice_tts_service.dart';
import '../../core/utils/haptic_service.dart';
import '../../features/journal/presentation/widgets/audio_memo_recorder_modal.dart';

/// VoiceTtsButton renders a minimalist audio icon that triggers calm executive TTS narration.
/// If the user has recorded their own voice memo for this specific rule/shloka,
/// it prioritizes playing that custom audio recording over synthetic TTS.
class VoiceTtsButton extends StatefulWidget {
  final String textToSpeak;
  final double size;
  final Color? color;
  final String? tooltip;
  final String? customAudioPath;
  final String? audioTopicKey;
  final bool allowRecording;

  const VoiceTtsButton({
    super.key,
    required this.textToSpeak,
    this.size = 18.0,
    this.color,
    this.tooltip,
    this.customAudioPath,
    this.audioTopicKey,
    this.allowRecording = true,
  });

  @override
  State<VoiceTtsButton> createState() => _VoiceTtsButtonState();
}

class _VoiceTtsButtonState extends State<VoiceTtsButton> {
  final VoiceTtsService _ttsService = VoiceTtsService();
  final HiveStorage _storage = HiveStorage();

  bool get _hasCustomRecording {
    if (widget.customAudioPath != null && widget.customAudioPath!.isNotEmpty) {
      return kIsWeb || File(widget.customAudioPath!).existsSync();
    }
    if (widget.audioTopicKey != null && _storage.isInitialized) {
      final overridePath = _storage.getCustomAudioOverride(widget.audioTopicKey!);
      if (overridePath != null && overridePath.isNotEmpty) {
        return kIsWeb || File(overridePath).existsSync();
      }
    }
    return false;
  }

  void _handleTap() {
    HapticService.selectionClick();
    _ttsService.speakOrPlay(
      text: widget.textToSpeak,
      customAudioPath: widget.customAudioPath,
      audioTopicKey: widget.audioTopicKey,
    );
  }

  Future<void> _handleLongPress() async {
    if (!widget.allowRecording || widget.audioTopicKey == null) return;

    HapticService.heavyImpact();
    final currentCustomPath = _storage.getCustomAudioOverride(widget.audioTopicKey!);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusMedium)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.shieldPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.mic_rounded, size: 18, color: AppColors.shieldPrimary),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AUDIO NARRATION OVERRIDE', style: AppTextStyles.labelBadge),
                        SizedBox(height: 2),
                        Text('Personal Voice Memo', style: AppTextStyles.heading),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                currentCustomPath != null
                    ? 'A personal voice recording is active for this item and will be prioritized over the synthetic TTS engine.'
                    : 'Record your own voice reciting this rule or shloka. The app will play your authentic voice instead of synthetic TTS.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11.5),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(bottomSheetContext).pop();
                    final newPath = await AudioMemoRecorderModal.show(
                      context,
                      existingPath: currentCustomPath,
                    );
                    if (newPath != null && mounted) {
                      await _storage.setCustomAudioOverride(widget.audioTopicKey!, newPath);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Personal voice memo saved and set as primary audio!'),
                          backgroundColor: AppColors.emeraldSuccess,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.mic_rounded, size: 18),
                  label: Text(currentCustomPath != null ? 'RE-RECORD VOICE MEMO' : 'RECORD YOUR VOICE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.shieldPrimary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (currentCustomPath != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () async {
                      Navigator.of(bottomSheetContext).pop();
                      await _storage.setCustomAudioOverride(widget.audioTopicKey!, null);
                      setState(() {});
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reverted back to synthetic calm executive voice.'),
                            backgroundColor: AppColors.surface,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.roseDanger),
                    label: const Text('Remove Personal Memo (Revert to Calm Voice)', style: TextStyle(color: AppColors.roseDanger, fontSize: 12)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: _ttsService.currentlySpeakingText,
      builder: (context, currentSpeaking, _) {
        final isSpeaking = currentSpeaking == widget.textToSpeak;
        final hasCustom = _hasCustomRecording;

        final activeColor = isSpeaking
            ? AppColors.emeraldSuccess
            : (hasCustom
                ? AppColors.shieldPrimary
                : (widget.color ?? AppColors.textMuted));

        final defaultTooltip = isSpeaking
            ? 'Stop audio'
            : (hasCustom
                ? 'Play personal voice memo (Hold to manage)'
                : 'Listen in calm voice with gravitas (Hold to record own voice)');

        return GestureDetector(
          onLongPress: _handleLongPress,
          child: IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSpeaking
                      ? Icons.volume_up_rounded
                      : (hasCustom ? Icons.record_voice_over_rounded : Icons.volume_mute_rounded),
                  size: widget.size,
                  color: activeColor,
                ),
                if (hasCustom && !isSpeaking)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.emeraldSuccess,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: widget.tooltip ?? defaultTooltip,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: _handleTap,
          ),
        );
      },
    );
  }
}
