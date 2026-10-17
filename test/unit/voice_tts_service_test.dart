import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sthitaprajna/core/database/hive_storage.dart';
import 'package:sthitaprajna/core/services/voice_tts_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('sthitaprajna_tts_test_');

    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return tempDir.path;
    });

    await HiveStorage().init();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('VoiceTtsService Gravitas Acoustic Parameters Tests', () {
    test('Acoustic parameters enforce calm executive cadence', () {
      expect(VoiceTtsService.speechRate, equals(0.42),
          reason: 'speechRate must be 0.42 for deliberate, steady, contemplative pace');
      expect(VoiceTtsService.pitch, equals(0.85),
          reason: 'pitch must be 0.85 for warmer, deeper, and resonant gravitas tone');
      expect(VoiceTtsService.volume, equals(1.0),
          reason: 'volume must be 1.0 for clear executive projection');
    });

    test('currentlySpeakingText starts null and updates reactively', () {
      final service = VoiceTtsService();
      expect(service.currentlySpeakingText.value, isNull);
      expect(service.isSpeakingText('test'), isFalse);
    });
  });

  group('Custom Audio Memo Override Persistence Tests', () {
    test('HiveStorage saves and retrieves custom voice memo override for rules', () async {
      final storage = HiveStorage();
      const topicKey = 'rule_8';
      const fakeAudioPath = '/data/user/0/com.sthitaprajna/app_flutter/.hidden_vault/shloka_memo.m4a';

      expect(storage.hasCustomAudioOverride(topicKey), isFalse);

      await storage.setCustomAudioOverride(topicKey, fakeAudioPath);
      expect(storage.hasCustomAudioOverride(topicKey), isTrue);
      expect(storage.getCustomAudioOverride(topicKey), equals(fakeAudioPath));

      // Clear override reverts back to synthetic TTS
      await storage.setCustomAudioOverride(topicKey, null);
      expect(storage.hasCustomAudioOverride(topicKey), isFalse);
      expect(storage.getCustomAudioOverride(topicKey), isNull);
    });

    test('Custom audio override takes priority when valid path exists', () async {
      final storage = HiveStorage();
      const topicKey = 'wisdom_108';

      // Create a temporary audio file on disk
      final audioFile = File('${tempDir.path}/test_recording.m4a');
      await audioFile.writeAsString('FAKE AUDIO BYTES');

      await storage.setCustomAudioOverride(topicKey, audioFile.path);
      expect(storage.getCustomAudioOverride(topicKey), equals(audioFile.path));
      expect(File(storage.getCustomAudioOverride(topicKey)!).existsSync(), isTrue);
    });
  });
}
