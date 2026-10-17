import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../database/hive_storage.dart';

/// VoiceTtsService provides a calm, resonant executive voice cadence (gravitas)
/// for Daily Rules, Wisdom Vault passages, and SOS scripts.
/// Supports natural/neural voice engine selection and prioritizes custom voice memo overrides.
class VoiceTtsService {
  static final VoiceTtsService _instance = VoiceTtsService._internal();
  factory VoiceTtsService() => _instance;
  VoiceTtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  AudioPlayer? _audioPlayer;
  bool _initialized = false;

  final ValueNotifier<String?> currentlySpeakingText =
      ValueNotifier<String?>(null);

  // Acoustic tuning parameters for gravitas and calm authority
  static const double speechRate = 0.42; // Deliberate, steady, contemplative pace
  static const double pitch = 0.85;      // Warmer, deeper, and resonant tone
  static const double volume = 1.0;

  // Cached best voice descriptors per language prefix
  final Map<String, Map<String, String>> _cachedVoices = {};

  Future<void> init() async {
    if (_initialized) return;

    try {
      await _applyAcousticParameters();

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

      // Initialize custom audio player for voice memo overrides
      _audioPlayer = AudioPlayer();
      _audioPlayer!.onPlayerComplete.listen((_) {
        currentlySpeakingText.value = null;
        debugPrint('[VoiceTtsService] Custom audio playback completed.');
      });
      _audioPlayer!.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed || state == PlayerState.stopped) {
          currentlySpeakingText.value = null;
        }
      });

      _initialized = true;
    } catch (e) {
      debugPrint('[VoiceTtsService] Initialization error: $e');
    }
  }

  /// Configures acoustic tuning parameters for calm executive authority
  Future<void> _applyAcousticParameters() async {
    try {
      await _flutterTts.setSpeechRate(speechRate);
      await _flutterTts.setPitch(pitch);
      await _flutterTts.setVolume(volume);
    } catch (e) {
      debugPrint('[VoiceTtsService] Error setting acoustic parameters: $e');
    }
  }

  /// Intelligently queries available voices and picks high-quality natural/neural voice
  Future<void> _configureBestNaturalVoice(String langCode) async {
    final isHindi = langCode.startsWith('hi');
    final targetPrefix = isHindi ? 'hi' : 'en';

    if (_cachedVoices.containsKey(targetPrefix)) {
      try {
        await _flutterTts.setVoice(_cachedVoices[targetPrefix]!);
        return;
      } catch (_) {}
    }

    try {
      final dynamic rawVoices = await _flutterTts.getVoices;
      if (rawVoices is List && rawVoices.isNotEmpty) {
        Map<String, dynamic>? bestVoice;
        int highestScore = -100;

        for (final item in rawVoices) {
          if (item is Map) {
            final name = (item['name'] ?? '').toString().toLowerCase();
            final locale = (item['locale'] ?? '').toString().toLowerCase();

            // Match target locale
            final localeMatches = locale.startsWith(targetPrefix) ||
                locale.contains('${targetPrefix}_') ||
                locale.contains('$targetPrefix-');

            if (!localeMatches && !name.contains(targetPrefix)) {
              continue;
            }

            int score = 10;

            // Prioritize high-quality neural, wavenet, natural, and studio engines
            if (name.contains('wavenet') || name.contains('neural')) {
              score += 60;
            }
            if (name.contains('natural') ||
                name.contains('studio') ||
                name.contains('journey')) {
              score += 50;
            }
            if (name.contains('enhanced') ||
                name.contains('premium') ||
                name.contains('network')) {
              score += 40;
            }
            // Gravitas: deeper / calm timbre
            if (name.contains('male') ||
                name.contains('deep') ||
                name.contains('resonant')) {
              score += 20;
            }
            // Heavily penalize legacy robotic/flat voices
            if (name.contains('espeak') ||
                name.contains('legacy') ||
                name.contains('robot')) {
              score -= 80;
            }

            if (score > highestScore) {
              highestScore = score;
              bestVoice = Map<String, dynamic>.from(item);
            }
          }
        }

        if (bestVoice != null && bestVoice['name'] != null) {
          final voiceMap = <String, String>{
            'name': bestVoice['name'].toString(),
            if (bestVoice['locale'] != null)
              'locale': bestVoice['locale'].toString(),
          };
          _cachedVoices[targetPrefix] = voiceMap;
          await _flutterTts.setVoice(voiceMap);
          debugPrint(
            '[VoiceTtsService] Selected natural voice for $targetPrefix: ${voiceMap['name']} (score: $highestScore)',
          );
        }
      }
    } catch (e) {
      debugPrint('[VoiceTtsService] Natural voice selection warning: $e');
    }
  }

  bool isSpeakingText(String text) {
    return currentlySpeakingText.value == text;
  }

  /// Speaks synthetic TTS or plays local custom audio memo if recorded
  Future<void> speakOrPlay({
    required String text,
    String? customAudioPath,
    String? audioTopicKey,
  }) async {
    if (!_initialized) {
      await init();
    }

    // Toggle off if currently speaking or playing this exact text
    if (currentlySpeakingText.value == text) {
      await stop();
      return;
    }

    // Stop whatever was playing
    await stop();

    // 1. Check for custom audio file override (recorded voice memo)
    String? resolvedAudioPath = customAudioPath;
    if ((resolvedAudioPath == null || resolvedAudioPath.isEmpty) &&
        audioTopicKey != null) {
      resolvedAudioPath = HiveStorage().getCustomAudioOverride(audioTopicKey);
    }

    if (resolvedAudioPath != null && resolvedAudioPath.isNotEmpty) {
      final fileExists = kIsWeb || File(resolvedAudioPath).existsSync();
      if (fileExists) {
        try {
          debugPrint(
            '[VoiceTtsService] Playing custom voice memo override: $resolvedAudioPath',
          );
          currentlySpeakingText.value = text;
          final Source source = (kIsWeb ||
                  resolvedAudioPath.startsWith('http://') ||
                  resolvedAudioPath.startsWith('https://'))
              ? UrlSource(resolvedAudioPath)
              : DeviceFileSource(resolvedAudioPath);

          await _audioPlayer?.play(source);
          return;
        } catch (e) {
          debugPrint('[VoiceTtsService] Error playing custom audio override: $e');
          // Fall back gracefully to synthetic TTS below
        }
      }
    }

    // 2. Fall back to natural, acoustically tuned synthetic TTS
    await speak(text);
  }

  /// Plays synthetic TTS with acoustic parameters for gravitas (0.42 pace, 0.85 pitch)
  Future<void> speak(String text) async {
    try {
      if (!_initialized) {
        await init();
      }

      if (currentlySpeakingText.value == text) {
        await stop();
        return;
      }

      if (currentlySpeakingText.value != null) {
        await stop();
      }

      // Automatically configure language and best natural voice
      final hasDevanagari = RegExp(r'[\u0900-\u097F]').hasMatch(text);
      final lang = hasDevanagari ? 'hi-IN' : 'en-US';

      try {
        await _flutterTts.setLanguage(lang);
      } catch (_) {}

      await _configureBestNaturalVoice(hasDevanagari ? 'hi' : 'en');
      await _applyAcousticParameters();

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
      await _audioPlayer?.stop();
      currentlySpeakingText.value = null;
    } catch (e) {
      debugPrint('[VoiceTtsService] stop error: $e');
    }
  }
}
