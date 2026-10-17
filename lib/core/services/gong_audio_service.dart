import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../utils/haptic_service.dart';
import 'voice_tts_service.dart';

/// GongAudioService generates and plays a solemn, deep Tibetan singing bowl gong tone
/// (108 Hz fundamental resonance with exponential harmonic decay) with zero external network assets.
class GongAudioService {
  static final GongAudioService _instance = GongAudioService._internal();
  factory GongAudioService() => _instance;
  GongAudioService._internal();

  AudioPlayer? _player;
  Uint8List? _cachedGongWav;

  /// Plays the deep calm gong tone with haptic feedback and optional voice cadence anchor
  Future<void> playDeepGong({bool speakAnchor = false}) async {
    try {
      HapticService.heavyImpact();
      SystemSound.play(SystemSoundType.alert);

      _player ??= AudioPlayer();
      _cachedGongWav ??= _generateGongWav(
        sampleRate: 22050,
        durationSeconds: 3.5,
        fundamentalFreq: 108.0,
      );

      await _player!.play(BytesSource(_cachedGongWav!));

      if (speakAnchor) {
        Future.delayed(const Duration(milliseconds: 600), () {
          VoiceTtsService().speak(
            'Done is better than perfect. 3, 2, 1... Execute.',
          );
        });
      }
    } catch (e) {
      debugPrint('[GongAudioService] Playback error: $e');
      // Graceful fallback to system sound and haptics
      HapticService.heavyImpact();
      if (speakAnchor) {
        VoiceTtsService().speak(
          'Done is better than perfect. 3, 2, 1... Execute.',
        );
      }
    }
  }

  /// Synthesizes a 16-bit PCM Mono WAV buffer in memory
  Uint8List _generateGongWav({
    required int sampleRate,
    required double durationSeconds,
    required double fundamentalFreq,
  }) {
    final numSamples = (sampleRate * durationSeconds).toInt();
    final pcmBytes = Uint8List(numSamples * 2);
    final byteData = ByteData.view(pcmBytes.buffer);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;

      // Exponential decay envelope
      final decay1 = math.exp(-t / 1.8);
      final decay2 = math.exp(-t / 1.1);
      final decay3 = math.exp(-t / 0.6);
      final decay4 = math.exp(-t / 0.35);

      // Multi-harmonic singing bowl synthesis
      final s1 = 0.52 * math.sin(2 * math.pi * fundamentalFreq * t) * decay1;
      final s2 = 0.28 * math.sin(2 * math.pi * (fundamentalFreq * 2.01) * t) * decay2;
      final s3 = 0.12 * math.sin(2 * math.pi * (fundamentalFreq * 3.03) * t) * decay3;
      final s4 = 0.08 * math.sin(2 * math.pi * (fundamentalFreq * 5.0) * t) * decay4;

      final sampleVal = (s1 + s2 + s3 + s4).clamp(-1.0, 1.0);
      final intSample = (sampleVal * 32767).toInt();

      byteData.setInt16(i * 2, intSample, Endian.little);
    }

    // Build standard 44-byte RIFF/WAV Header
    final header = Uint8List(44);
    final headerData = ByteData.view(header.buffer);
    final totalDataLen = pcmBytes.length;
    final totalFileLen = totalDataLen + 36;

    // RIFF chunk descriptor
    headerData.setUint8(0, 0x52); // 'R'
    headerData.setUint8(1, 0x49); // 'I'
    headerData.setUint8(2, 0x46); // 'F'
    headerData.setUint8(3, 0x46); // 'F'
    headerData.setUint32(4, totalFileLen, Endian.little);
    headerData.setUint8(8, 0x57);  // 'W'
    headerData.setUint8(9, 0x41);  // 'A'
    headerData.setUint8(10, 0x56); // 'V'
    headerData.setUint8(11, 0x45); // 'E'

    // 'fmt ' sub-chunk
    headerData.setUint8(12, 0x66); // 'f'
    headerData.setUint8(13, 0x6D); // 'm'
    headerData.setUint8(14, 0x74); // 't'
    headerData.setUint8(15, 0x20); // ' '
    headerData.setUint32(16, 16, Endian.little); // Subchunk1Size for PCM
    headerData.setUint16(20, 1, Endian.little);  // AudioFormat 1 = PCM
    headerData.setUint16(22, 1, Endian.little);  // NumChannels 1 = Mono
    headerData.setUint32(24, sampleRate, Endian.little); // SampleRate
    headerData.setUint32(28, sampleRate * 2, Endian.little); // ByteRate (SampleRate * NumChannels * BitsPerSample/8)
    headerData.setUint16(32, 2, Endian.little);  // BlockAlign (NumChannels * BitsPerSample/8)
    headerData.setUint16(34, 16, Endian.little); // BitsPerSample 16

    // 'data' sub-chunk
    headerData.setUint8(36, 0x64); // 'd'
    headerData.setUint8(37, 0x61); // 'a'
    headerData.setUint8(38, 0x74); // 't'
    headerData.setUint8(39, 0x61); // 'a'
    headerData.setUint32(40, totalDataLen, Endian.little);

    final wavFile = Uint8List(44 + totalDataLen);
    wavFile.setRange(0, 44, header);
    wavFile.setRange(44, 44 + totalDataLen, pcmBytes);
    return wavFile;
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
