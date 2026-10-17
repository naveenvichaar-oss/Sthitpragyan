import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_service.dart';
import '../data/models/resource_link.dart';
import '../presentation/screens/in_app_web_viewer_screen.dart';
import '../presentation/screens/in_app_youtube_player_screen.dart';

/// ResourceLauncherService coordinates opening all external resources
/// (YouTube videos, Google Drive PDFs, Google Keep notes, Web articles)
/// seamlessly INSIDE the app rather than kicking users out to third-party apps.
class ResourceLauncherService {
  ResourceLauncherService._();

  /// Extracts the canonical 11-character YouTube video ID from various URL formats.
  static String? extractYoutubeVideoId(String url) {
    final raw = url.trim();
    if (raw.isEmpty) return null;

    // 1. Official youtube_player_flutter conversion
    try {
      final converted = YoutubePlayerController.convertUrlToId(raw);
      if (converted != null && converted.isNotEmpty) {
        return converted;
      }
    } catch (_) {}

    // 2. High-precision regex fallback (supports shorts, embed, watch?v=, youtu.be/)
    final regExp = RegExp(
      r'(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=|shorts\/))([\w-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(raw);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    return null;
  }

  /// Determines if a URL points to YouTube.
  static bool isYoutubeUrl(String url) {
    final lower = url.trim().toLowerCase();
    return lower.contains('youtube.com') ||
        lower.contains('youtu.be') ||
        lower.contains('m.youtube.com');
  }

  /// Determines if a URL points to Google Drive or Google Docs.
  static bool isGoogleDriveUrl(String url) {
    final lower = url.trim().toLowerCase();
    return lower.contains('drive.google.com') || lower.contains('docs.google.com');
  }

  /// Normalizes a Google Drive URL for clean in-app embedded viewing.
  static String normalizeGoogleDriveUrl(String url) {
    final trimmed = url.trim();
    // If a Google Drive link ends in /view or /edit, /preview provides a clean embedded reader
    if (trimmed.contains('drive.google.com/file/d/')) {
      if (trimmed.endsWith('/view') || trimmed.contains('/view?')) {
        return trimmed.replaceAll(RegExp(r'/view(\?.*)?$'), '/preview');
      }
    }
    return trimmed;
  }

  /// Opens a [ResourceLink] inside the application.
  static Future<void> openResource(
    BuildContext context, {
    required ResourceLink resource,
  }) async {
    HapticService.selectionClick();
    return openUrl(
      context,
      url: resource.url,
      title: resource.title,
      category: resource.category,
      notes: resource.notes,
      mediaType: resource.effectiveMediaType,
    );
  }

  /// Opens any given web or video URL inside the app seamlessly.
  static Future<void> openUrl(
    BuildContext context, {
    required String url,
    String? title,
    String? category,
    String? notes,
    ResourceMediaType? mediaType,
  }) async {
    final rawUrl = url.trim();
    if (rawUrl.isEmpty) {
      _showFeedback(context, 'Resource URL is empty.');
      return;
    }

    final effectiveTitle = (title != null && title.trim().isNotEmpty)
        ? title.trim()
        : 'External Resource';

    // 1. YouTube link handling: In-app video player
    final isYt = (mediaType == ResourceMediaType.youTube) || isYoutubeUrl(rawUrl);
    if (isYt) {
      final videoId = extractYoutubeVideoId(rawUrl);
      if (videoId != null && videoId.isNotEmpty) {
        try {
          await InAppYouTubePlayerScreen.open(
            context,
            videoId: videoId,
            title: effectiveTitle,
            category: category,
            notes: notes,
            originalUrl: rawUrl,
          );
          return;
        } catch (e) {
          debugPrint('[ResourceLauncherService] InAppYouTubePlayer error: $e');
          // Fall through to in-app webview or external browser
        }
      }
    }

    // 2. Google Drive / Web Articles / Keep notes: In-app Web Viewer
    try {
      final targetUrl = isGoogleDriveUrl(rawUrl)
          ? normalizeGoogleDriveUrl(rawUrl)
          : rawUrl;

      await InAppWebViewerScreen.open(
        context,
        url: targetUrl,
        title: effectiveTitle,
        category: category,
      );
      return;
    } catch (e) {
      debugPrint('[ResourceLauncherService] InAppWebViewer error: $e');
    }

    // 3. Fallback: Safe external launcher
    await fallbackLaunch(context, rawUrl);
  }

  /// Safe fallback that launches the URL externally if in-app viewers fail.
  static Future<void> fallbackLaunch(BuildContext context, String url) async {
    try {
      var uri = Uri.parse(url.trim());
      if (!uri.hasScheme) {
        uri = Uri.parse('https://${url.trim()}');
      }

      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        _showFeedback(context, 'Unable to open link ($e).');
      }
    }
  }

  static void _showFeedback(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.shieldPrimary),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
          ],
        ),
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }
}
