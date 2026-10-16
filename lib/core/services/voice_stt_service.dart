import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// VoiceSttService provides zero-latency on-device speech-to-text dictation
/// for the 3-Index Evening Journal and Slip-Up Post-Mortem debriefs.
class VoiceSttService {
  static final VoiceSttService _instance = VoiceSttService._internal();
  factory VoiceSttService() => _instance;
  VoiceSttService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  final ValueNotifier<bool> isListening = ValueNotifier<bool>(false);

  Future<bool> init() async {
    if (_isAvailable) return true;

    try {
      _isAvailable = await _speech.initialize(
        onError: (val) {
          debugPrint('[VoiceSttService] Error: $val');
          isListening.value = false;
        },
        onStatus: (status) {
          debugPrint('[VoiceSttService] Status: $status');
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
          }
        },
      );
      return _isAvailable;
    } catch (e) {
      debugPrint('[VoiceSttService] Initialization failed: $e');
      _isAvailable = false;
      return false;
    }
  }

  Future<void> startListening({
    required Function(String recognizedWords) onResult,
  }) async {
    try {
      final available = await init();
      if (!available) {
        debugPrint('[VoiceSttService] Speech recognition is unavailable on this device.');
        return;
      }

      isListening.value = true;
      await _speech.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(seconds: 45),
          pauseFor: const Duration(seconds: 4),
          cancelOnError: true,
        ),
      );
    } catch (e) {
      debugPrint('[VoiceSttService] startListening error: $e');
      isListening.value = false;
    }
  }

  Future<void> stopListening() async {
    try {
      await _speech.stop();
      isListening.value = false;
    } catch (e) {
      debugPrint('[VoiceSttService] stopListening error: $e');
      isListening.value = false;
    }
  }

  Future<void> toggleListening({
    required Function(String recognizedWords) onResult,
  }) async {
    if (isListening.value) {
      await stopListening();
    } else {
      await startListening(onResult: onResult);
    }
  }
}
