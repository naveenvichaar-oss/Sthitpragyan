import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// VoiceTtsService provides a calm, measured executive voice cadence
/// for listening to Daily Rules, Wisdom Vault passages, and SOS scripts.
class VoiceTtsService {
  static final VoiceTtsService _instance = VoiceTtsService._internal();
  factory VoiceTtsService() => _instance;
  VoiceTtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _initialized = false;

  final ValueNotifier<String?> currentlySpeakingText = ValueNotifier<String?>(null);

  Future<void> init() async {
    if (_initialized) return;

    try {
      await _flutterTts.setLanguage('en-US');
      // Calm, grounded executive cadence
      await _flutterTts.setSpeechRate(0.44); // Measured pacing
      await _flutterTts.setPitch(0.92); // Deeper, calm pitch
      await _flutterTts.setVolume(1.0);

      _flutterTts.setStartHandler(() {
        debugPrint('[VoiceTtsService] TTS playback started.');
      });

      _flutterTts.setCompletionHandler(() {
        currentlySpeakingText.value = null;
        debugPrint('[VoiceTtsService] TTS playback completed.');
      });

      _flutterTts.setCancelHandler(() {
        currentlySpeakingText.value = null;
      });

      _flutterTts.setErrorHandler((dynamic msg) {
        debugPrint('[VoiceTtsService] TTS error: $msg');
        currentlySpeakingText.value = null;
      });

      _initialized = true;
    } catch (e) {
      debugPrint('[VoiceTtsService] Initialization error: $e');
    }
  }

  bool isSpeakingText(String text) {
    return currentlySpeakingText.value == text;
  }

  Future<void> speak(String text) async {
    try {
      if (!_initialized) {
        await init();
      }

      // If already speaking the same text, stop it
      if (currentlySpeakingText.value == text) {
        await stop();
        return;
      }

      // If speaking something else, stop first
      if (currentlySpeakingText.value != null) {
        await _flutterTts.stop();
      }

      // Automatically configure voice language for Devanagari Hindi vs English
      final hasDevanagari = RegExp(r'[\u0900-\u097F]').hasMatch(text);
      try {
        await _flutterTts.setLanguage(hasDevanagari ? 'hi-IN' : 'en-US');
      } catch (_) {}

      currentlySpeakingText.value = text;
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('[VoiceTtsService] speak error: $e');
      currentlySpeakingText.value = null;
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      currentlySpeakingText.value = null;
    } catch (e) {
      debugPrint('[VoiceTtsService] stop error: $e');
    }
  }
}
