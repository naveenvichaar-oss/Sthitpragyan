import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/voice_tts_service.dart';
import '../../core/utils/haptic_service.dart';

/// VoiceTtsButton renders a minimalist audio speaker icon
/// that triggers calm executive Text-to-Speech narration.
class VoiceTtsButton extends StatelessWidget {
  final String textToSpeak;
  final double size;
  final Color? color;
  final String? tooltip;

  const VoiceTtsButton({
    super.key,
    required this.textToSpeak,
    this.size = 18.0,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final ttsService = VoiceTtsService();

    return ValueListenableBuilder<String?>(
      valueListenable: ttsService.currentlySpeakingText,
      builder: (context, currentSpeaking, _) {
        final isSpeaking = currentSpeaking == textToSpeak;
        final activeColor = isSpeaking
            ? AppColors.emeraldSuccess
            : (color ?? AppColors.textMuted);

        return IconButton(
          icon: Icon(
            isSpeaking ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
            size: size,
            color: activeColor,
          ),
          tooltip: tooltip ?? (isSpeaking ? 'Stop narration' : 'Listen with calm voice'),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            HapticService.selectionClick();
            if (isSpeaking) {
              ttsService.stop();
            } else {
              ttsService.speak(textToSpeak);
            }
          },
        );
      },
    );
  }
}
