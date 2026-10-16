import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/voice_stt_service.dart';
import '../../core/utils/haptic_service.dart';

/// VoiceDictationButton renders a microphone icon to dictate
/// journal entries or slip-up reflection notes directly via STT.
class VoiceDictationButton extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onDictated;

  const VoiceDictationButton({
    super.key,
    required this.controller,
    this.onDictated,
  });

  @override
  State<VoiceDictationButton> createState() => _VoiceDictationButtonState();
}

class _VoiceDictationButtonState extends State<VoiceDictationButton> {
  final VoiceSttService _sttService = VoiceSttService();
  String _startingText = '';

  void _toggleDictation() async {
    HapticService.selectionClick();

    if (_sttService.isListening.value) {
      await _sttService.stopListening();
      return;
    }

    _startingText = widget.controller.text.trim();

    await _sttService.startListening(
      onResult: (words) {
        final prefix = _startingText.isEmpty ? '' : '$_startingText ';
        final fullText = '$prefix$words';
        widget.controller.text = fullText;
        widget.controller.selection = TextSelection.fromPosition(
          TextPosition(offset: fullText.length),
        );
        widget.onDictated?.call(fullText);
      },
    );

    if (!_sttService.isAvailable && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Speech recognition is initializing or unavailable. You can type directly.',
            style: TextStyle(fontSize: 12),
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _sttService.isListening,
      builder: (context, listening, _) {
        return IconButton(
          icon: Icon(
            listening ? Icons.mic_rounded : Icons.mic_none_rounded,
            size: 20,
            color: listening ? AppColors.roseDanger : AppColors.shieldPrimary,
          ),
          tooltip: listening ? 'Stop voice dictation' : 'Start voice dictation',
          onPressed: _toggleDictation,
          visualDensity: VisualDensity.compact,
        );
      },
    );
  }
}
