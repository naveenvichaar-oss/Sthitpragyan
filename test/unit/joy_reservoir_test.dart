import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/core/localization/app_localizations.dart';
import 'package:sthitaprajna/features/joy_reservoir/data/models/joy_item.dart';
import 'package:sthitaprajna/features/joy_reservoir/data/services/joy_audio_service.dart';
import 'package:sthitaprajna/features/sharing/services/sharing_intent_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JoyItem Model & Media Detection Tests', () {
    test('Correctly identifies offline local audio files vs web links', () {
      final localItem1 = JoyItem(
        id: '1',
        title: 'Morning Rain',
        category: JoyCategory.music,
        mediaUrlOrPath: '/storage/emulated/0/Download/rain.mp3',
        timestamp: DateTime.now(),
      );
      expect(localItem1.isLocalAudio, isTrue);
      expect(localItem1.isYouTube, isFalse);
      expect(localItem1.isYouTubeMusic, isFalse);

      final localItem2 = JoyItem(
        id: '2',
        title: 'Forest Flute',
        category: JoyCategory.music,
        mediaUrlOrPath: 'C:\\Users\\NAVEEN\\Music\\flute.wav',
        timestamp: DateTime.now(),
      );
      expect(localItem2.isLocalAudio, isTrue);

      final webItem = JoyItem(
        id: '3',
        title: 'Marconi Union',
        category: JoyCategory.music,
        mediaUrlOrPath: 'https://music.youtube.com/watch?v=UfcAVejslrU',
        timestamp: DateTime.now(),
      );
      expect(webItem.isLocalAudio, isFalse);
      expect(webItem.isYouTube, isTrue);
      expect(webItem.isYouTubeMusic, isTrue);

      final ytStandardItem = JoyItem(
        id: '4',
        title: 'Bansuri Meditation',
        category: JoyCategory.music,
        mediaUrlOrPath: 'https://youtu.be/kJQP7kiw5Fk?si=123',
        timestamp: DateTime.now(),
      );
      expect(ytStandardItem.isLocalAudio, isFalse);
      expect(ytStandardItem.isYouTube, isTrue);
      expect(ytStandardItem.isYouTubeMusic, isFalse);
    });

    test('Serializes toMap and fromMap with offline media paths', () {
      final item = JoyItem(
        id: 'test_joy_1',
        title: 'Evening Sunset Raga',
        category: JoyCategory.music,
        mediaUrlOrPath: '/app_flutter/joy_audio/raga_marwa.mp3',
        note: 'Deep tranquility after a chaotic workday.',
        timestamp: DateTime(2026, 4, 15, 18, 30),
      );

      final map = item.toMap();
      final restored = JoyItem.fromMap(map);

      expect(restored.id, item.id);
      expect(restored.title, item.title);
      expect(restored.category, JoyCategory.music);
      expect(restored.mediaUrlOrPath, item.mediaUrlOrPath);
      expect(restored.isLocalAudio, isTrue);
      expect(restored.note, item.note);
      expect(restored.timestamp, item.timestamp);
    });
  });

  group('JoyAudioService Tests', () {
    test('formatDuration formats Duration instances accurately into mm:ss', () {
      expect(JoyAudioService.formatDuration(Duration.zero), '00:00');
      expect(JoyAudioService.formatDuration(const Duration(seconds: 45)), '00:45');
      expect(JoyAudioService.formatDuration(const Duration(minutes: 3, seconds: 12)), '03:12');
      expect(JoyAudioService.formatDuration(const Duration(minutes: 65, seconds: 5)), '05:05');
    });

    test('Initial audio player state reports inactive and not playing', () {
      final service = JoyAudioService();
      expect(service.isPlaying('non_existent_id'), isFalse);
      expect(service.isPaused('non_existent_id'), isFalse);
      expect(service.isActive('non_existent_id'), isFalse);
    });
  });

  group('SharingIntentService YouTube / YouTube Music Parsing Tests', () {
    test('Extracts YouTube Music song URL and title from Android share intent', () {
      const shareText =
          'Check out this song on YouTube Music: Weightless - Marconi Union https://music.youtube.com/watch?v=UfcAVejslrU&si=xyz';
      final parsed = SharingIntentService.parseSharedContent(shareText);

      expect(parsed.isYouTubeOrMusic, isTrue);
      expect(parsed.isYouTubeMusic, isTrue);
      expect(parsed.url, 'https://music.youtube.com/watch?v=UfcAVejslrU&si=xyz');
      expect(parsed.title, 'Weightless - Marconi Union');
    });

    test('Extracts YouTube Music playlist URL with fallback title', () {
      const shareText = 'https://music.youtube.com/playlist?list=PLw-VjHDlEOgs658kAHR_LAa4P9VC.';
      final parsed = SharingIntentService.parseSharedContent(shareText);

      expect(parsed.isYouTubeOrMusic, isTrue);
      expect(parsed.isYouTubeMusic, isTrue);
      expect(parsed.url, 'https://music.youtube.com/playlist?list=PLw-VjHDlEOgs658kAHR_LAa4P9VC');
      expect(parsed.title, 'YouTube Music Playlist');
    });

    test('Extracts standard YouTube watch and youtu.be links', () {
      const shareText1 = 'Bansuri Meditation - Pandit Chaurasia https://youtu.be/0w5_v_Z8e04';
      final parsed1 = SharingIntentService.parseSharedContent(shareText1);

      expect(parsed1.isYouTubeOrMusic, isTrue);
      expect(parsed1.isYouTubeMusic, isFalse);
      expect(parsed1.url, 'https://youtu.be/0w5_v_Z8e04');
      expect(parsed1.title, 'Bansuri Meditation - Pandit Chaurasia');

      const shareText2 = 'https://www.youtube.com/watch?v=kJQP7kiw5Fk';
      final parsed2 = SharingIntentService.parseSharedContent(shareText2);

      expect(parsed2.isYouTubeOrMusic, isTrue);
      expect(parsed2.url, 'https://www.youtube.com/watch?v=kJQP7kiw5Fk');
      expect(parsed2.title, 'YouTube Serenity Audio');
    });

    test('Handles regular web URLs gracefully without marking as YouTube', () {
      const shareText = 'Stanford Article on Equanimity https://plato.stanford.edu/entries/stoicism/';
      final parsed = SharingIntentService.parseSharedContent(shareText);

      expect(parsed.isYouTubeOrMusic, isFalse);
      expect(parsed.isYouTubeMusic, isFalse);
      expect(parsed.url, 'https://plato.stanford.edu/entries/stoicism/');
      expect(parsed.title, 'Stanford Article on Equanimity');
    });
  });

  group('Bilingual Localization for Joy Reservoir & Audio Tests', () {
    test('English localizations contain all new keys', () {
      final loc = AppLocalizations(const Locale('en'));
      expect(loc.selectLocalAudio, 'Select Local Audio');
      expect(loc.localAudioAnchor, 'Offline Local Audio');
      expect(loc.localAudioFile, 'Local Audio File');
      expect(loc.playAudio, 'Play Audio');
      expect(loc.pauseAudio, 'Pause Audio');
      expect(loc.stopAudio, 'Stop Audio');
      expect(loc.openInYoutube, 'Play in YouTube');
      expect(loc.openInYoutubeMusic, 'Open in YouTube Music');
      expect(loc.externalPlayer, 'Open in Native Player');
      expect(loc.joyAnchorSaved, contains('Joy Box'));
      expect(loc.allAnchors, 'ALL ANCHORS');
    });

    test('Hindi localizations contain authentic Devanagari high-register translations', () {
      final loc = AppLocalizations(const Locale('hi'));
      expect(loc.selectLocalAudio, 'डिवाइस से ऑडियो चुनें');
      expect(loc.localAudioAnchor, 'ऑफ़लाइन स्थानीय ऑडियो');
      expect(loc.localAudioFile, 'स्थानीय ऑडियो फ़ाइल');
      expect(loc.playAudio, 'ऑडियो चलाएं');
      expect(loc.pauseAudio, 'रोकें');
      expect(loc.stopAudio, 'बंद करें');
      expect(loc.openInYoutube, 'यूट्यूब में चलाएं');
      expect(loc.openInYoutubeMusic, 'यूट्यूब म्यूज़िक में खोलें');
      expect(loc.externalPlayer, 'बाहरी ऐप में चलाएं');
      expect(loc.joyAnchorSaved, contains('जॉय बॉक्स'));
      expect(loc.allAnchors, 'सभी लंगर');
    });
  });
}
