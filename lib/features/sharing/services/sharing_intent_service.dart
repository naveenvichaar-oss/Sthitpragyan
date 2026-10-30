import 'dart:async';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../../core/navigation/app_navigator.dart';
import '../../joy_reservoir/data/models/joy_item.dart';
import '../../joy_reservoir/presentation/screens/joy_reservoir_screen.dart';
import '../presentation/widgets/incoming_share_modal_sheet.dart';

/// Parsed result of incoming plain-text share intents
class ParsedSharedContent {
  final String? url;
  final String? title;
  final bool isYouTubeOrMusic;
  final bool isYouTubeMusic;

  const ParsedSharedContent({
    this.url,
    this.title,
    this.isYouTubeOrMusic = false,
    this.isYouTubeMusic = false,
  });
}

/// SharingIntentService listens for system share intents and triggers
/// contextual routing directly to Joy Reservoir (for YouTube/YouTube Music)
/// or the generalized "Save to Sthitaprajna" modal sheet.
class SharingIntentService {
  static final SharingIntentService _instance = SharingIntentService._internal();
  factory SharingIntentService() => _instance;
  SharingIntentService._internal();

  StreamSubscription<List<SharedMediaFile>>? _intentSub;
  bool _initialized = false;

  /// Extracts URLs and clean titles from raw shared text (e.g. YouTube / YouTube Music shares)
  static ParsedSharedContent parseSharedContent(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      return const ParsedSharedContent();
    }

    // 1. Extract URL (http:// or https://)
    final urlRegExp = RegExp(r'https?://[^\s]+');
    final match = urlRegExp.firstMatch(text);

    if (match == null) {
      return ParsedSharedContent(title: text);
    }

    var extractedUrl = match.group(0)!;
    // Strip trailing punctuation like commas, periods, or brackets
    extractedUrl = extractedUrl.replaceAll(RegExp(r'[.,;!>)]+$'), '');

    final lowerUrl = extractedUrl.toLowerCase();
    final isYtMusic = lowerUrl.contains('music.youtube.com');
    final isYtStandard = lowerUrl.contains('youtube.com') ||
        lowerUrl.contains('youtu.be') ||
        lowerUrl.contains('m.youtube.com');
    final isYouTubeOrMusic = isYtMusic || isYtStandard;

    // 2. Extract remaining text as candidate title
    var titleCandidate = text.replaceAll(match.group(0)!, '').trim();
    // Strip standard Android share prefixes
    titleCandidate = titleCandidate
        .replaceAll(
          RegExp(
            r'^(Check out this song on YouTube Music:?|Check out this track on YouTube Music:?|Listen to .* on YouTube Music:?|Watch on YouTube:?|Check out this video:?|Listen to:?|Watch:?)\s*',
            caseSensitive: false,
          ),
          '',
        )
        .trim();

    // Clean trailing dashes, colons or slashes
    titleCandidate = titleCandidate.replaceAll(RegExp(r'[\s\-:]+$'), '').trim();

    if (titleCandidate.isEmpty) {
      if (isYtMusic) {
        titleCandidate = lowerUrl.contains('playlist')
            ? 'YouTube Music Playlist'
            : 'YouTube Music Track';
      } else if (isYtStandard) {
        titleCandidate = lowerUrl.contains('playlist')
            ? 'YouTube Playlist'
            : 'YouTube Serenity Audio';
      } else {
        titleCandidate = 'Shared Audio Anchor';
      }
    }

    return ParsedSharedContent(
      url: extractedUrl,
      title: titleCandidate,
      isYouTubeOrMusic: isYouTubeOrMusic,
      isYouTubeMusic: isYtMusic,
    );
  }

  /// Initializes intent interception using top-level application context
  void init(BuildContext context) {
    if (_initialized) return;
    _initialized = true;

    try {
      // 1. Listen for incoming shares while the app is in background/foreground
      _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
        (List<SharedMediaFile> files) {
          if (files.isNotEmpty) {
            final effectiveContext = AppNavigator.currentContext ?? context;
            if (effectiveContext.mounted) {
              final first = files.first;
              _processSharedFile(effectiveContext, first);
              ReceiveSharingIntent.instance.reset();
            }
          }
        },
        onError: (err) {
          debugPrint('[SharingIntentService] getMediaStream error: $err');
        },
      );

      // 2. Handle cold launch from share sheet
      ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> files) {
        if (files.isNotEmpty) {
          final effectiveContext = AppNavigator.currentContext ?? context;
          if (effectiveContext.mounted) {
            final first = files.first;
            _processSharedFile(effectiveContext, first);
            ReceiveSharingIntent.instance.reset();
          }
        }
      }).catchError((err) {
        debugPrint('[SharingIntentService] getInitialMedia error: $err');
      });
    } catch (e) {
      debugPrint('[SharingIntentService] Platform initialization error: $e');
    }
  }

  void _processSharedFile(BuildContext context, SharedMediaFile file) {
    final effectiveContext = AppNavigator.currentContext ?? context;
    if (!effectiveContext.mounted) return;

    final path = file.path;
    final isImage = file.type == SharedMediaType.image;

    // Detect YouTube / YouTube Music shares and route directly to Joy Reservoir
    if (!isImage) {
      final parsed = parseSharedContent(path);
      if (parsed.isYouTubeOrMusic && parsed.url != null) {
        JoyReservoirScreen.open(
          effectiveContext,
          initialCategory: JoyCategory.music,
          initialTitle: parsed.title,
          initialUrlOrPath: parsed.url,
        );
        return;
      }
    }

    // Default generalized share sheet for other destinations
    IncomingShareModalSheet.show(
      effectiveContext,
      rawContent: path,
      mediaPath: isImage ? path : null,
    );
  }

  /// Manually triggers the share interceptor modal for testing or user paste
  void triggerManualShare(
    BuildContext context, {
    required String content,
    String? mediaPath,
  }) {
    final effectiveContext = AppNavigator.currentContext ?? context;
    if (mediaPath == null) {
      final parsed = parseSharedContent(content);
      if (parsed.isYouTubeOrMusic && parsed.url != null) {
        JoyReservoirScreen.open(
          effectiveContext,
          initialCategory: JoyCategory.music,
          initialTitle: parsed.title,
          initialUrlOrPath: parsed.url,
        );
        return;
      }
    }

    IncomingShareModalSheet.show(
      effectiveContext,
      rawContent: content,
      mediaPath: mediaPath,
    );
  }

  void dispose() {
    _intentSub?.cancel();
    _intentSub = null;
    _initialized = false;
  }
}
