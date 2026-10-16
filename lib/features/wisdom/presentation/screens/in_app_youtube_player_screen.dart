import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/haptic_service.dart';
import 'in_app_web_viewer_screen.dart';

/// InAppYouTubePlayerScreen plays YouTube videos directly inside Sthitaprajna
/// with full playback, pause, progress scrubbing, and fullscreen controls.
class InAppYouTubePlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String? category;
  final String? notes;
  final String originalUrl;

  const InAppYouTubePlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
    this.category,
    this.notes,
    required this.originalUrl,
  });

  static Future<void> open(
    BuildContext context, {
    required String videoId,
    required String title,
    String? category,
    String? notes,
    required String originalUrl,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => InAppYouTubePlayerScreen(
          videoId: videoId,
          title: title,
          category: category,
          notes: notes,
          originalUrl: originalUrl,
        ),
      ),
    );
  }

  @override
  State<InAppYouTubePlayerScreen> createState() => _InAppYouTubePlayerScreenState();
}

class _InAppYouTubePlayerScreenState extends State<InAppYouTubePlayerScreen> {
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubePlayerValue>? _subscription;
  String? _initError;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && widget.videoId.isNotEmpty) {
      _initPlayer();
    } else if (widget.videoId.isEmpty) {
      _initError = 'Invalid or missing YouTube Video ID.';
    }
  }

  void _initPlayer() {
    try {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: widget.videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
          enableCaption: true,
        ),
      );

      _subscription = _controller?.stream.listen((_) {
        if (mounted) setState(() {});
      });
    } catch (e) {
      debugPrint('[InAppYouTubePlayerScreen] init error: $e');
      _initError = 'Could not load in-app YouTube player ($e)';
    }
  }

  @override
  void deactivate() {
    _controller?.pauseVideo();
    super.deactivate();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller?.close();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _launchExternalYouTube() async {
    HapticService.selectionClick();
    try {
      final uri = Uri.parse(widget.originalUrl);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open external app: $e'),
            backgroundColor: AppColors.surfaceElevated,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || _initError != null || _controller == null) {
      return _buildFallbackScaffold();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          tooltip: 'Close',
          onPressed: () {
            HapticService.selectionClick();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.title,
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.shieldPrimary),
            tooltip: 'Open in YouTube App',
            onPressed: _launchExternalYouTube,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Embedded Video Player with integrated player controls
          Container(
            color: Colors.black,
            child: YoutubePlayer(
              controller: _controller!,
              aspectRatio: 16 / 9,
              enableFullScreenOnVerticalDrag: true,
            ),
          ),

          // Video Metadata & Executive Brief
          Padding(
            padding: const EdgeInsets.all(AppDimens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badges
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'YOUTUBE VIDEO',
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 8.5,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                    if (widget.category != null && widget.category!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        widget.category!.toUpperCase(),
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 9.0,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),

                // Full Title
                Text(
                  widget.title,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),

                if (widget.notes != null && widget.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(AppDimens.space12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EXECUTIVE TAKEAWAY & CONTEXT',
                          style: AppTextStyles.labelBadge.copyWith(
                            color: AppColors.shieldPrimary,
                            fontSize: 9.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.notes!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticService.selectionClick();
                          InAppWebViewerScreen.open(
                            context,
                            url: widget.originalUrl,
                            title: widget.title,
                            category: widget.category,
                          );
                        },
                        icon: const Icon(Icons.language_rounded, size: 16),
                        label: const Text('OPEN IN WEBVIEW'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.borderMedium),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _launchExternalYouTube,
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: const Text('YOUTUBE APP'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceElevated,
                          foregroundColor: AppColors.shieldPrimary,
                          side: const BorderSide(color: AppColors.shieldPrimary, width: 0.8),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackScaffold() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: AppTextStyles.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_circle_fill_rounded,
                  size: 40,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: AppTextStyles.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _initError ?? 'Native in-app video player is unavailable in this environment.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      HapticService.selectionClick();
                      InAppWebViewerScreen.open(
                        context,
                        url: widget.originalUrl,
                        title: widget.title,
                        category: widget.category,
                      );
                    },
                    icon: const Icon(Icons.language_rounded, size: 16),
                    label: const Text('OPEN IN WEBVIEW'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.borderMedium),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _launchExternalYouTube,
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text('OPEN IN YOUTUBE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
