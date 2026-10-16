import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/features/wisdom/utils/resource_launcher_service.dart';

void main() {
  group('ResourceLauncherService Tests', () {
    test('extractYoutubeVideoId extracts 11-char ID from various YouTube URL formats', () {
      // Standard watch URL
      expect(
        ResourceLauncherService.extractYoutubeVideoId('https://www.youtube.com/watch?v=2B_E4r_J2cE'),
        equals('2B_E4r_J2cE'),
      );

      // Shortened youtu.be URL
      expect(
        ResourceLauncherService.extractYoutubeVideoId('https://youtu.be/R9OCA6UFE-0'),
        equals('R9OCA6UFE-0'),
      );

      // Embedded URL
      expect(
        ResourceLauncherService.extractYoutubeVideoId('https://www.youtube.com/embed/dQw4w9WgXcQ'),
        equals('dQw4w9WgXcQ'),
      );

      // Shorts URL
      expect(
        ResourceLauncherService.extractYoutubeVideoId('https://youtube.com/shorts/dQw4w9WgXcQ'),
        equals('dQw4w9WgXcQ'),
      );

      // Invalid / non-youtube
      expect(
        ResourceLauncherService.extractYoutubeVideoId('https://classics.mit.edu/Antoninus/meditations.html'),
        isNull,
      );
      expect(
        ResourceLauncherService.extractYoutubeVideoId(''),
        isNull,
      );
    });

    test('isYoutubeUrl correctly detects YouTube domains', () {
      expect(ResourceLauncherService.isYoutubeUrl('https://www.youtube.com/watch?v=abc'), isTrue);
      expect(ResourceLauncherService.isYoutubeUrl('https://youtu.be/abc'), isTrue);
      expect(ResourceLauncherService.isYoutubeUrl('https://m.youtube.com/watch?v=abc'), isTrue);
      expect(ResourceLauncherService.isYoutubeUrl('https://drive.google.com/file/d/123/view'), isFalse);
      expect(ResourceLauncherService.isYoutubeUrl('https://classics.mit.edu'), isFalse);
    });

    test('isGoogleDriveUrl correctly detects Google Drive & Docs domains', () {
      expect(ResourceLauncherService.isGoogleDriveUrl('https://drive.google.com/file/d/xyz/view'), isTrue);
      expect(ResourceLauncherService.isGoogleDriveUrl('https://docs.google.com/document/d/abc'), isTrue);
      expect(ResourceLauncherService.isGoogleDriveUrl('https://classics.mit.edu'), isFalse);
    });

    test('normalizeGoogleDriveUrl transforms /view to /preview for embedded reader', () {
      const driveViewUrl = 'https://drive.google.com/file/d/1A2B3C4D5E/view?usp=sharing';
      final normalized = ResourceLauncherService.normalizeGoogleDriveUrl(driveViewUrl);
      expect(normalized, contains('/preview'));
      expect(normalized, isNot(contains('/view')));

      const regularWebUrl = 'https://classics.mit.edu/Epictetus/epicench.html';
      expect(ResourceLauncherService.normalizeGoogleDriveUrl(regularWebUrl), equals(regularWebUrl));
    });
  });
}
